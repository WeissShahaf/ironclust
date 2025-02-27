% modified by James Jun on Sep 12 2019 from github.com/mouseland/Kilosort2
% repository
% this function generates simulated recording with given parameterset

function generate_eMouse_drift(fpath, NchanTOT, t_record, fDrift, KS2path)
if nargin<1, fpath=[]; end
if nargin<2, NchanTOT = []; end
if nargin<3, t_record = []; end
if nargin<4, fDrift = []; end
if nargin<5, KS2path=[]; end
if isempty(NchanTOT), NchanTOT=64; end
if isempty(t_record), t_record=1200; end
if isempty(fDrift), fDrift=1; end

% fpath    = 'D:\drift_simulations\test\'; % where on disk do you want the simulation? ideally an SSD...

%KS2 path -- also has the waveforms for the simulation
% KS2path = 'C:\Users\labadmin\Documents\Kilosort2-determ\Kilosort2\';
% 
% % add paths to the matlab path
% addpath(genpath('C:\Users\labadmin\Documents\Kilosort2-determ\Kilosort2')); % path to kilosort2 folder
% addpath('C:\Users\labadmin\Documents\kilosort\npy-matlab-master\');
% KS2path = fileparts(mfilename('fullpath'));
if isempty(KS2path)
    KS2path = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'kilosort2');
end

if isempty(fpath), fpath = './'; end
if ~exist(fpath, 'dir'); mkdir(fpath); end


% path to whitened, filtered proc file (on a fast SSD)
% rootH = 'C:\Users\labadmin\Documents\kilosort_datatemp';

% path to config file; if running the default config, no need to change.
% pathToYourConfigFile = [KS2path,'eMouse_drift\']; % path to config file

% Create the channel map for this simulation; default is a small 64 site
% probe with imec 3A geometry.
% NchanTOT = 64;
chanMapName = make_eMouseChannelMap_3A_short(fpath, NchanTOT);
% ops.chanMap             = fullfile(fpath, chanMapName);

% Run the configuration file, it builds the structure of options (ops)

% run(fullfile(pathToYourConfigFile, 'config_eMouse_drift_KS2.m'))


% This part simulates and saves data. There are many options you can change inside this 
% function, if you want to vary the SNR or firing rates, # of cells, etc.
% There are also parameters to set the amplitude and character of the tissue drift. 
% You can vary these to make the simulated data look more like your data
% or test the limits of the sorting with different parameters.

make_eMouseData_drift_(fpath, KS2path, chanMapName, t_record, fDrift);
end %func


function make_eMouseData_drift_(fpath, KS2path, chanMapName, t_record, fDrift)
% this script makes a binary file of simulated eMouse recording
% written by Jennifer Colonell, based on Marius Pachitariu's original eMouse simulator for Kilosort 1
% Adds the ability to simulate simple drift of the tissue relative to the
% probe sites.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% you can play with the parameters just below here to achieve a signal more similar to your own data!!! 
useGPU = 1;
useParPool = 1;

norm_amp  = 20; % if 0, use amplitudes of input waveforms; if > 0, set all amplitudes to norm_amp*rms_noise
mu_mean   = 0.75; % mean of mean spike amplitudes. Incoming waveforms are in uV; make <1 to make sorting harder
rms_noise = 12; % rms noise in uV. Will be added to the spike signal. 15-20 uV an OK estimate from real data
% t_record  = 1200; % duration in seconds of simulation. longer is better (and slower!) (1000)
fr_bounds = [1 10]; % min and max of firing rates ([1 10])
tsmooth   = 0.5; % gaussian smooth the noise with sig = this many samples (increase to make it harder) (0.5)
chsmooth  = 0.5; % smooth the noise across channels too, with this sig (increase to make it harder) (0.5)
amp_std   = .1; % standard deviation of single spike amplitude variability (increase to make it harder, technically std of gamma random variable of mean 1) (.25)
fs        = 30000; % sample rate for the simulation. Incoming waveforms must be sampled at this freq.
nt        = 81; % number of timepoints expected. All waveforms must have this time window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%drift params. See the comments in calcYPos_v2 for details
drift.addDrift = fDrift;
drift.sType = 'rigid';  %'rigid' or 'point';
drift.tType = 'sine';   %'exp' or 'sine'
drift.y0 = 3800;        %in um, position along probe where motion is largest
                        %y = 0 is the tip of the probe                        
drift.halfDistance = 1000;   %in um, distance along probe over which the motion decays
drift.amplitude = 10;    %in um
drift.halfLife = 10;     %in seconds
drift.period = 600;      %in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%waveform source data
% waveform files to use for the simulation
% these come in two types: 
%     3A data, used for "large" units that cover > 100 um in Y
%     Data from Kampff ultradense survey, analyzed by Nick Steimetz and
%     Susu Chen, for "small" units that cover < 100 um in Y
% Interpolation of large units uses a linear "scattered interpolant"
% Interpolation of small units uses a grid interpolant.
% currently, the signal at the simulated sites is taken as the interpolated
% field value at the center of the site. This is likely appropriate for
% mapping 3A data onto simulated 3A data (or 3B data). For creating 3A data
% from the Kampff data, averaging over site area might be more realistic.

%fileCopies specifies how many repeats of each file (to make dense data
%sets). The units will be placed at random x and y on the probe, but
%using many copies can lead to too many very similar units.


%get waveforms from eMouse folder in KS2
filePath{1} = [KS2path,'\eMouse_drift\','kampff_St_unit_waves_allNeg_2X'];
fileCopies(1) = 2;
filePath{2} = [KS2path,'\eMouse_drift\','121817_single_unit_waves_allNeg.mat'];
fileCopies(2) = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%other parameters
bPair     = 0; % set to 0 for randomly distributed units, 1 for units in pairs
pairDist  = 50; % distance between paired units
bPlot     = 0; %make diagnostic plots of waveforms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng('default');
rng(101);  % set the seed of the random number generator; default = 101

bitPerUV = 0.42667; %imec 3A or 3B, gain = 500

%  load channel map file built with make_eMouseChannelMap_3A_short.m

chanMapFile = fullfile(fpath, chanMapName);
load(chanMapFile);


Nchan = numel(chanMap);
invChanMap(chanMap) = [1:Nchan]; % invert the  channel map here--create the order in which to write output

% range of y positions to place units
minY = min(ycoords(find(connected==1)));
maxY = max(ycoords(find(connected==1)));
minX = min(xcoords(find(connected==1)));
maxX = max(xcoords(find(connected==1)));


%build the complete filePath list for waveforms
nUniqueFiles = numel(filePath);
currCount = nUniqueFiles;
for i = 1:nUniqueFiles
    for j = 1:fileCopies(i)-1
        currCount = currCount + 1;
        filePath{currCount} = filePath{i};
    end
end


nFile = length(filePath);

% for i = 1: nFile
%     fprintf('%s\n',filePath{i});
% end


NN = 0; %number of units included
uF = {}; %cell array for interpolants
uR = []; %array of max/min X and Y for points that can be interpolateed
         %structure with uR.maxX, uR.maxY, uR.minX, uR.minY
origLabel = []; %array of original labels


for fileIndex = 1:nFile
    % generate waveforms for the simulation
    uData = load(filePath{fileIndex});
    if (uData.fs ~= fs)
        fprintf( 'Waveform file %d has wrong sample rate.\n', fileIndex );
        fprintf( 'Skipping to next file.');
        continue
    end
    if (uData.nt ~= nt)
        fprintf( 'Waveform file %d has wrong time window.\n', fileIndex );
        fprintf( 'Skipping to next file.');
        continue
    end
    if ~( strcmp(uData.dataType, '3A') || strcmp(uData.dataType, 'UD') )
        fprintf( 'Waveform file %d has unknown sample type.\n', fileIndex );
        fprintf( 'Skipping to next file.');
        continue
    end
    
    
    nUnit = length(uData.uColl);
    unitRange = NN+1:NN+nUnit;  %for now, using all the units we have
    
    if strcmp(uData.dataType, '3A')
        uType(unitRange) = 0;
    end
    if strcmp(uData.dataType, 'UD')
        uType(unitRange) = 1;
    end
    
    %vary intensity for each unit
    if uType(NN+1) == 0
        scaleIntensity = mu_mean*(1 + (rand(nUnit,1) - 0.5));
    end
    if uType(NN+1) == 1     %these are already small, so don't make them smaller.
        scaleIntensity = (1 + (rand(nUnit,1)-0.5));
    end

   if (norm_amp > 0)
        %get min and max intensity, and normalize to norm_amp X the rms noise
        targAmp = rms_noise*norm_amp;
        for i = 1:nUnit          
            maxAmp = max(max(uData.uColl(i).waves)) - min(min(uData.uColl(i).waves));
            uData.uColl(i).waves = uData.uColl(i).waves*(targAmp/maxAmp);
        end
    else
        for i = 1:nUnit
            uData.uColl(i).waves = uData.uColl(i).waves*scaleIntensity(i);
        end
    end
  
    %for these units, create an intepolant which will be used to
    %calculate the waveform at arbitrary sites
    
    if (uType(unitRange(1)) == 1)
        [uFcurr, uRcurr] = makeGridInt_( uData.uColl, nt );
    else
        [uFcurr, uRcurr] = makeScatInt_( uData.uColl, nt );
    end
    
    %append these to the array over all units
    uF = [uF, uFcurr];
    uR = [uR, uRcurr];
    
    for i = unitRange
        origLabel(i) = uData.uColl(i-NN).label;
    end
    
    NN = NN + nUnit;
end


% distribute units along the length the probe, either in pairs separated
% by unitDist um, or fully randomly.
% for now, keep x = the original position (i.e. don't try to recenter)
uX = zeros(1,NN);
uY = zeros(1,NN);
uX = uX + ((maxX - minX)/2 + minX);

yRange = maxY - minY;

unitOrder = randperm(NN);   %really only important for the pairs

if ~bPair    
    uX(unitOrder) = (maxX - minX)/2 + minX;
    uY(unitOrder) = minY + yRange * rand(NN,1);
else
    %pairs will be placed at regular spacing (so the spacing is controlled)
    %want to avoid placing units at the ends of the probe
    endBuff = 50; %min distance in um from end of probe
    if (mod(NN,2))
        %odd number of units; pair up the first NN - 1
        %place the first units between (minY + pairDist) and maxY
        nPair = (NN-1)/2;
        % (0:nPair) = nPair + 1 positions; one extra for the loner
        pairPos = minY + endBuff + (pairDist/2) + ...
            (0:nPair)*(yRange - pairDist - 2*endBuff)/(nPair);
        uY(unitOrder(1:2:NN-2)) =  pairPos(1:nPair) + (pairDist/2);
        uY(unitOrder(2:2:NN-1)) = pairPos(1:nPair) - (pairDist/2);
        uY(unitOrder(NN)) = pairPos(nPair + 1);
    else
        %even number of units; pair them all
        nPair = NN/2;
        pairPos = minY + endBuff + (pairDist/2) + ...
            (0:nPair-1)*(yRange - pairDist - 2*endBuff)/(nPair-1);
        uY(unitOrder(1:2:NN-2)) = pairPos(1:nPair) + (pairDist/2);
        uY(unitOrder(2:2:NN-1)) = pairPos(1:nPair) - (pairDist/2); 
    end
end
    
% calculate monitor sites for these units
monSite = zeros(1,NN);
for i = 1:NN
    [currWav, uSites] = intWav_( uF{i}, uX(i), uY(i), uR(i), xcoords, ycoords, connected, nt );
%         fprintf( 'site %d: ',i);
%         for uCount = 1:length(uSites)
%             fprintf( '%d,', uSites(uCount));         
%         end
%         fprintf( '\n' );
    monSite(i) = pickMonSite_( currWav, uSites, connected );
    if( monSite(i) < 0 )
        fprintf( 'All sites nearby unit %d are not connected. Probably an error.\n', i);
        return;
    end
end


if (bPlot)
    
    %write out units and positions to console
    fprintf( 'label\torig label\ty position\tmonitor site\n' );
    for i = 1:NN
        fprintf( '%d\t%d\t%.1f\t%d\n', i, origLabel(i), uY(i), monSite(i) );
    end
    
    %for an overview of the units included, plot waves over the whole
    %probe, at the initial position, and shifted by 1*delta, and 2*delta
   
    deltaUM = 10;
    
    %set up waves for whole probe
    testwav = zeros(Nchan,nt);

    %for each unit, find the sites with signal, calculate the waveform based on
    %the current probe position (using the interpolant) and add to wav

    for i = 1:NN       
        [currWav, uSites] = intWav_( uF{i}, uX(i), uY(i), uR(i), xcoords, ycoords, connected, nt );
        testwav(uSites,:) = testwav(uSites,:) + currWav;
    end

    
    %calculate waveforms with units shifted by deltaUM
    testwav2 = zeros(Nchan,nt);
    for i = 1:NN
        currYPos = uY(i) + deltaUM;
        [currWav, uSites] = intWav_( uF{i}, uX(i), currYPos, uR(i), xcoords, ycoords, connected, nt );
        testwav2(uSites,:) = testwav2(uSites,:) + currWav;
    end
    
    %calculate waveforms with units shifted by 2*deltaUM
    testwav3 = zeros(Nchan,nt);
    
    for i = 1:NN
        currYPos = uY(i) + 2*deltaUM;
        [currWav, uSites] = intWav_( uF{i}, uX(i), currYPos, uR(i), xcoords, ycoords, connected, nt );
        testwav3(uSites,:) = testwav3(uSites,:) + currWav;
    end
    figure(1);
    tRange = 1.1*nt;
    yRange = 1.1*( max(max(testwav)) - min(min(testwav)) );
    
    %properties of the 3A probe. 
    %TODO: add derivation of these from xcoords, ycoords
    xMin = 11;
    yMin = 20;
    xStep = 16;
    yStep = 20;
    
    tDat = 1:nt;
    %only plotting 1-384 (rather than 1-385) because 385 is unconnected 
    %digital channel
    
    for i = 1:Nchan-1
        currDat = testwav( i, : ); 
        currDat2 = testwav2(i,:);
        currDat3 = testwav3(i,:);
        xPlotPos = (xcoords(i) - xMin)/xStep;
        xOff = tRange * xPlotPos + nt/3;
        yOff = yRange * (ycoords(i) - yMin)/yStep;
        figure(1);
        %plot(tDat + xOff, currDat + yOff,'b-');
        %plot(tDat + xOff, scatDat + yOff,'b-');
        plot(tDat + xOff, currDat + yOff,'b-', tDat + xOff, currDat3 + yOff, 'r-' );
        if(xPlotPos == 0)
          msgstr=sprintf('ch%d',i);
          text(xOff,yOff+50,msgstr);  
        end
        hold on
    end
    
    %plot signals at monitor sites at initial position.
    figure(2);
    
    %some plotting params
    colorStr ={};
    colorStr{1} = '-b';
    colorStr{2} = '-r';
    %fprintf('unit\tmaxAmp\n');
    for i = 1:NN
        [currWav, uSites] = intWav_( uF{i}, uX(i), uY(i), uR(i), xcoords, ycoords, connected, nt );
        cM = find(uSites == monSite(i));
        currDat = currWav(cM,:);
        %fprintf( '%d\t%.2f\n', i, (max(currDat)-min(currDat)));
        currColor = colorStr{uType(i) + 1};
        plot(tDat,currDat,currColor);
        hold on;
    end
    
    
end


bContinue = 1;




%same for range of firing rates (note that we haven't included any info
%about the original firign rates of the units
fr = fr_bounds(1) + (fr_bounds(2)-fr_bounds(1)) * rand(NN,1); % create variability in firing rates

% totfr = sum(fr); % total firing rate

spk_times = [];
clu = [];

if bContinue        %done with setup, now starting the time consuming stuff
    
for j = 1:length(fr)      %loop over neurons
    %generate a set of time differences bewteen spikes
    %random numbers from a geometric distribution with with probability
    %(sample time)*firing rate = (1/sample rate)*firing rate =
    %(1/(samplerate*firingrate))
    %geometric distribution an appropriate model for the number of trials
    %before a success (neuron firing)
    %second two params for geornd are size of the array, here 2*firing
    %rate*total time of the simulation. 
    dspks = int64(geornd(1/(fs/fr(j)), ceil(2*fr(j)*t_record),1));
    dspks(dspks<ceil(fs * 2/1000)) = [];  % remove ISIs below the refractory period
    res = cumsum(dspks);
    spk_times = cat(1, spk_times, res);
    clu = cat(1, clu, j*ones(numel(res), 1));
end
[spk_times, isort] = sort(spk_times);
clu = clu(isort);
clu       = clu(spk_times<t_record*fs);
spk_times = spk_times(spk_times<t_record*fs);
nspikes = numel(spk_times);

% this generates single spike amplitude with mean = 1 and std deviation
% ~amp_std, while ensuring all values are positive
amps = gamrnd(1/amp_std^2,amp_std^2, nspikes,1); 

%
buff = 128;
NT   = 4 * fs + buff; % batch size + buffer

fidW     = fopen(fullfile(fpath, 'sim_binary.imec.ap.bin'), 'w');

t_all    = 0;

if useGPU
    %set up the random number generators for run to run reproducibility 
    gpurng('default'); % start with a default set
    gpurng(101); % set the seed
    %gpurng('shuffle'); uncomment to have the seed set using the clock
end

%record a y position for each spike time
yDriftRec = zeros( length(spk_times), 5, 'double' );
allspks = 0;

if (useParPool)
    %delete any currently running pool
    delete(gcp('nocreate'))
    %create parallel pool
    locCluster = parcluster('local');
    parpool('local',locCluster.NumWorkers);
    %get a handle to it
    p = gcp(); 
    %add variables to the workers
    p_xcoords = parallel.pool.Constant(xcoords);
    p_ycoords = parallel.pool.Constant(ycoords);
    p_connected = parallel.pool.Constant(connected);
    p_uF = parallel.pool.Constant(uF);
    p_uX = parallel.pool.Constant(uX);
    p_uY = parallel.pool.Constant(uY);
    p_uR = parallel.pool.Constant(uR);
end

while t_all<t_record
    if useGPU
        enoise = gpuArray.randn(NT, Nchan, 'single');
    else
        enoise = randn(NT, Nchan, 'single');
    end
    if t_all>0
        enoise(1:buff, :) = enoise_old(NT-buff + [1:buff], :);
    end
    
    dat = enoise;
    dat = my_conv2(dat, [tsmooth chsmooth], [1 2]);
    %rescale the smoothed data to make the std = 1;
    dat = zscore(dat, 1, 1);
    dat = gather_try(dat);
    %multiply the final noise calculation by the expected rms in uV
    dat = dat*rms_noise;
    %fprintf( 'Noise mean = %.3f; std = %.3f\n', mean(dat(:,1)), std(dat(:,1)));
    if t_all>0
        dat(1:buff/2, :) = dat_old(NT-buff/2 + [1:buff/2], :);
    end
    
    dat(:, find(connected==0)) = 0; % these are the reference and dig channels
    
    % now we add spikes on non-dead channels.
    ibatch = (spk_times >= t_all*fs) & (spk_times < t_all*fs+NT-buff);
    ts = spk_times(ibatch) - t_all*fs;
    ids = clu(ibatch);
    am = amps(ibatch);
    tRange = int64(1:nt);
    tic
    
    if (useParPool)
        %     %first run a parfor loop for the time consuming calculation of the
        %     %interpolated waves
        
        currWavArray = zeros(length(ts),Nchan,nt,'double'); %actual array much shorter
        currSiteArray = zeros(length(ts),Nchan,'uint16'); %record indices of the sites in currWavArray;
        currNsiteArray = zeros(length(ts),'uint16'); %record number of sites
        
        parfor i = 1:length(ts)
            cc = ids(i); %current cluster index
            currT = t_all + double(ts(i))/fs;
            currYPos = calcYPos_v2_( currT, p_uY.Value(cc), drift );
            [currWav, uSites] = ...
                intWav_( p_uF.Value{cc}, p_uX.Value(cc), currYPos, p_uR.Value(cc), p_xcoords.Value, p_ycoords.Value, p_connected.Value, nt );
            nSite = length(uSites);
            currWavArray(i,:,:) = padarray(currWav * am(i),[(Nchan-nSite),0],0,'post');
            currSiteArray(i, :) = padarray(uSites,(Nchan-nSite),0,'post')';
            currNsiteArray(i) = nSite;
        end
        
    end
    
    for i = 1:length(ts)
        %for a given time, need to calcuate the wave that correspond to
        %the current position of the probe.
        allspks = allspks + 1;
        currT = t_all + double(ts(i))/fs;
        cc = ids(i); %current cluster index
        
        %get current position of this unit
        currYPos = calcYPos_v2_( currT, uY(cc), drift );
        
        %currYdrift = calcYPos( currT, ycoords );
        yDriftRec(allspks,1) = currT;
        yDriftRec(allspks,2) = currYPos;
        yDriftRec(allspks,3) = cc; %record the unit label in the drift record
        
        
        if (useParPool)
            %get the waves for this unit from the big precalculated array
            uSites = squeeze(currSiteArray(i,1:currNsiteArray(i)));
            tempWav = squeeze(currWavArray(i,1:currNsiteArray(i),:));
            dat(ts(i) + tRange, uSites) = dat(ts(i) + tRange, uSites) + tempWav';
        else
            %calculate the interpolants now
            [tempWav, uSites] = ...
                intWav_( uF{cc}, uX(cc), currYPos, uR(cc), xcoords, ycoords, connected, nt );
            
            dat(ts(i) + tRange, uSites) = dat(ts(i) + tRange, uSites) +...
                am(i) * tempWav(:,:)';
        end
        
        cM = find(uSites == monSite(cc));
        %if drift has moved the monitor site outside the footprint of the
        %unit, the recorded amplitudes just stay = 0;
        
        if ( cM )
            yDriftRec(allspks,4) = max(tempWav(cM,:)) - min(tempWav(cM,:));
            yDriftRec(allspks,5) = max(dat(ts(i) + tRange,monSite(cc))) - min(dat(ts(i) + tRange,monSite(cc)));
        end
        
    end
    
    dat_old    =  dat;
    %convert to 16 bit integers; waveforms are in uV
    dat = int16(bitPerUV * dat);
    fwrite(fidW, dat(1:(NT-buff),invChanMap)', 'int16');
    t_all = t_all + (NT-buff)/fs;
    elapsedTime = toc;
    fprintf( 'created %.2f seconds of data; nSpikes %d; calcTime: %.3f\n ', t_all, length(ts), elapsedTime );
    enoise_old = enoise;
    clear currWavArray;
    clear currNSiteArray;
    clear currSiteArray;
end

fclose(fidW); % all done

gtRes = spk_times + nt/2; % add back the time of the peak for the templates (half the time span of the defined waveforms)
gtClu = clu;

save(fullfile(fpath, 'eMouseGroundTruth'), 'gtRes', 'gtClu')
save(fullfile(fpath, 'eMouseSimRecord'), 'yDriftRec' );

end

end %func


function [uF, uR] = makeScatInt_( uColl, nt )
    %create an interpolating function for each unit in
    % the array uColl
    uF = {};
    % array of maximum radii for each unit. only sites within this radius
    % will get get contributions from this unit
    uR = [];
    for i = 1:length(uColl)
        %reshape waves to a 1D vector       
        wave_pts = reshape(uColl(i).waves',[uColl(i).nChan*nt,1]);      
        xpts = repelem(uColl(i).xC,nt)';
        ypts = repelem(uColl(i).yC,nt)';
        tpts = (repmat(1:nt,1,uColl(i).nChan))';
        %specify points as y, x to be congruent with row,column of grid
        %interpolant.
        uF{i} = scatteredInterpolant( ypts, xpts, tpts, wave_pts, 'linear', 'nearest' );
        uR(i).minX = min(uColl(i).xC);
        uR(i).maxX = max(uColl(i).xC);
        uR(i).minY = min(uColl(i).yC);
        uR(i).maxY = max(uColl(i).yC);
        %earlier version that used y extend
        %uR(i) = min( max(uColl(i).yC), abs(min(uColl(i).yC)) );  
    end
    
end %func


function [uF, uR] = makeGridInt_( uColl, nt )
    %Reshape the array of [nsite, nt] into [Y, X, nt]
    %Note that this is dependent on how the data were stored:
    %here, assumes the sites are stored in row major order.
    %Could also derive this from the X and Y coordinates for generality
    
    %create an interpolating function for each unit in
    % the array uColl
    uF = {};
    % array of maximum radii for each unit. only sites within this radius
    % will get get contributions from this unit
    uR = [];

    for i = 1:length(uColl)         
        sCol = length(unique(uColl(i).xC));
        sRow = length(unique(uColl(i).yC));
        %reshape waveform array into [sRow x sCol x nt array]
        %the data are stored as (1,1),(1,2),(1,3)...(2,1),(2,3)
        %reshape transforms as "row fast", so need to reshape and permute
        v = permute(reshape(uColl(i).waves,[sCol,sRow,nt]),[2,1,3]);
        xVal = uColl(i).xC(1:sCol);
        %pick off first element of each column to get y values
        colOne = (0:sRow-1)*sCol + 1;
        yVal = uColl(i).yC(colOne);
        tVal = 1:nt;
        %remember: y = rows, x = columns!
        [Y,X,T] = ndgrid(yVal, xVal, tVal);
        uF{i} = griddedInterpolant(Y,X,T,v,'makima');
        uR(i).minX = min(uColl(i).xC);
        uR(i).maxX = max(uColl(i).xC);
        uR(i).minY = min(uColl(i).yC);
        uR(i).maxY = max(uColl(i).yC);
        %earlier version that just used y extent
        %uR(i) = min( max(uColl(i).yC), abs(min(uColl(i).yC)) );  
    end
    
end %func

 
function uSites = findSites_( xPos, yPos, xcoords, ycoords, connected, uR )

    %find the sites currently in range for this unit at this point in time
    %(i.e. this value of yDrift)
    % xPos, yPos are the coordinates of the com of the unit signal in the 
    % coordinates of the probe at the current time
    % xcoords and ycoords are the positions of the sites, assumed constant
    % motion of the probe should be modeled as rigid motion of the units

    %calculate distance from xPos, yPos for each site
    xDist = xcoords - xPos;
    yDist = ycoords - yPos;
    
    uSites = find( (xDist >= uR.minX) & (xDist <= uR.maxX) & ...
                   (yDist >= uR.minY) & (yDist <= uR.maxY) & ...
           	       (connected==1) );
%     dist_sq = (xPos - xcoords).^2 + (yPos - (ycoords + yDrift)).^2;
%     % want to exclude sites that aren't connected; just add a constant so
%     % they won't pass the distance test
%     dist_sq(find(connected==0)) = dist_sq(find(connected==0)) + 10*maxRad^2;
%     uSites = find( dist_sq < maxRad^2 );
        
end


function [uWav, uSites] = intWav_( currF, xPos, yPos, uR, xcoords, ycoords, connected, nt )

    % figure out for which sites we need to calculate the waveform
    uSites = findSites_( xPos, yPos, xcoords, ycoords, connected, uR );
    
    % given an array of sites on the probe, calculate the waveform using
    % the interpolant determined for this unit  
    % xPos and yPos are the positions of the current unit
    % nt = number of timepoints
 
    currX = xcoords - xPos;
    currY = ycoords - yPos;
    
    nSites = length(uSites);
    xq = double(repelem(currX(uSites), nt));
    yq = double(repelem(currY(uSites), nt));
    tq = (double(repmat(1:nt, 1, nSites )))';
    %remember, y = rows in the grid, and x = columns in the grid
    %interpolation, and scattered interpolation set to match.
    uWav = currF( yq, xq, tq );
    uWav = (reshape(uWav', [nt,nSites]))';
    
end %func


function [uWav, uSites] = dumWav_( currF, xPos, yPos, uR, xcoords, ycoords, connected, nt )

    % figure out for which sites we need to calculate the waveform
    uSites = findSites_( xPos, yPos, xcoords, ycoords, connected, uR );
    uWav = zeros(length(uSites),nt);    
end %func


function monSite = pickMonSite_( currWav, uSites, connected )

    % find the connected site with the largest expected signal with no
    % drift. If all uSites are unconnected, returns an error
    
    %calc amplitudes for each site
    currAmp = max(currWav,[],2) - min(currWav,[],2);
    
    %sort amplitudes
    [sortAmp, ind] = sort(currAmp,'descend');
    
    monSite = -1;
    i = 1;
    
    while ( i < length(uSites) && monSite < 0 )
        if (connected(uSites(ind(i))))
            monSite = uSites(ind(i));
        else
            i = i + 1;
        end
    end
        
end %func


function currYPos = calcYPos_v2_( t, yPos0, drift  )
%   calculate current position of a unit given the current time and 
%   initial position (yPos0)

%   The pattern of tissue motion in space is set by drift.sType:
%       'rigid' -- all the units move together
%       'point' -- motion is largest at a point y0 (furthest from tip) and 
%         decreases exponentially for units far from y0. Need to
%         specify y0 and the halfDistance
%
%   The pattern of tissue motion in time is set by drift.tType:
%       'exp' -- initial fast transition followed by exponential
%            decay; specify stepsize (fast transition distance); halfLife (sec)
%            and period (in sec).
%       'sine' -- specify amplitude and period
%
%   Drift parameter values for 20 um p-p, uniform sine motion, with period = 300 s:    
%     drift.sType = 'rigid';        %'rigid' or 'point';
%     drift.tType = 'sine';          %'exp' or 'sine'
%     
%     drift.y0 = 3800;        %in um, position along probe where motion is largest
%                             %conventially, y = 0 is the bottom of the probe
%     drift.halfDistance = 1000;     %in um
%     
%     drift.amplitude = 10;         %in um. For a sine wave, the peak to
%                                    peak variation is 2Xdrift.amplitude
%     drift.halfLife = 10;          %in seconds
%     drift.period = 300;           %in seconds
%     
if (drift.addDrift)
    switch drift.tType
        case 'exp'
            timeIntoCycle = t - (floor(t/drift.period))*drift.period;
            delta = drift.amplitude*exp(-timeIntoCycle/drift.halfLife);
        case 'sine'          
            delta = drift.amplitude*sin(t*2*pi()/drift.period);
        otherwise
            fprintf( 'unknown parameter in drift calculation \n')
            return;
    end       
    
    switch drift.sType
        case 'rigid'
            %delta is equal for any position
        case 'point'
            %delta falls off exponentially from y0
            delta = delta * exp( -abs(drift.y0 - yPos0)/drift.halfDistance ); 
        otherwise
            fprintf( 'unknown parameter in drift calculation \n')
            return;
    end
    currYPos = yPos0 + delta;
else
    currYPos = yPos0;
end

end %func




%
% Run kilosort2 on the simulated data

% if( sortData ) 
%    
%         % common options for every probe
%         gpuDevice(1);   %re-initialize GPU
%         ops.sorting     = 1; % type of sorting, 2 is by rastermap, 1 is old
%         ops.NchanTOT    = NchanTOT; % total number of channels in your recording
%         ops.trange      = [0 Inf]; % TIME RANGE IN SECONDS TO PROCESS
% 
% 
%         ops.fproc       = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD
% 
%         % find the binary file in this folder
%         rootZ     = fpath;
%         ops.rootZ = rootZ;
% 
%         ops.fbinary     = fullfile(rootZ,  'sim_binary.imec.ap.bin');
% 
% 
%         % preprocess data to create temp_wh.dat
%         rez = preprocessDataSub(ops);
% 
%         % pre-clustering to re-order batches by depth
%         rez = clusterSingleBatches(rez);
%         
%         % main optimization
%         % learnAndSolve8;
%         rez = learnAndSolve8b(rez);
%         
% 
%         % final splits
%         rez = find_merges(rez, 1);
%         
% 
%         % final splits by SVD
%         rez    = splitAllClusters(rez, 1);
%         
%         % final splits by amplitudes
%         rez = splitAllClusters(rez, 0);
%     
%         % decide on cutoff
%         rez = set_cutoff(rez);
%          
%         % this saves to Phy
%         rezToPhy(rez, rootZ);
% 
%         % discard features in final rez file (too slow to save)
%         rez.cProj = [];
%         rez.cProjPC = [];
%         
%         fname = fullfile(rootZ, 'rezFinal.mat');
%         save(fname, 'rez', '-v7.3');
%         
%         sum(rez.good>0)
%         fileID = fopen(fullfile(rootZ, 'cluster_group.tsv'),'w');
%         fprintf(fileID, 'cluster_id%sgroup', char(9));
%         fprintf(fileID, char([13 10]));
%         for k = 1:length(rez.good)
%             if rez.good(k)
%                 fprintf(fileID, '%d%sgood', k-1, char(9));
%                 fprintf(fileID, char([13 10]));
%             end
%         end
%         fclose(fileID);
%         
%         % remove temporary file
%         delete(ops.fproc);
% end
% 
% 
% if runBenchmark
%  load(fullfile(fpath, 'rezFinal.mat'));
%  benchmark_drift_simulation(rez, fullfile(fpath, 'eMouseGroundTruth.mat'),...
%      fullfile(fpath,'eMouseSimRecord.mat'));
% end
