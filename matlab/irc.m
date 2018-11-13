%--------------------------------------------------------------------------
% IronClust (irc)
% James Jun, Flatiron Institute

function varargout = irc(varargin)
% Memory-efficient version 
% P is static and loaded from file
% Dynamic variables are set in S0=get(0,'UserData')

persistent vcFile_prm_ % remember the currently working prm file

% input parse
if nargin<1, vcCmd = 'version'; else vcCmd = varargin{1}; end
if nargin<2, vcArg1 = ''; else vcArg1 = varargin{2}; end
if nargin<3, vcArg2 = ''; else vcArg2 = varargin{3}; end
if nargin<4, vcArg3 = ''; else vcArg3 = varargin{4}; end
if nargin<5, vcArg4 = ''; else vcArg4 = varargin{5}; end
if nargin<6, vcArg5 = ''; else vcArg5 = varargin{6}; end
if nargin<7, vcArg6 = ''; else vcArg6 = varargin{7}; end
if nargin<8, vcArg7 = ''; else vcArg7 = varargin{8}; end
if nargin<9, vcArg8 = ''; else vcArg8 = varargin{9}; end

if read_cfg_('reset_path'), reset_path_(); end
warning off;

%-----
% Command type A: supporting functions
fExit = 1;
switch lower(vcCmd)
    % No arguments        
    case 'hash', varargout{1} = file2hash_(); return; 
    case 'addpath', addpath_(); return; %add path of current irc
    case 'mcc', mcc_(); return; %matlab compiler
    case {'setprm' 'set', 'set-prm'}, vcFile_prm_ = vcArg1; return;
    case 'changelog', edit_('changelog.md'); web_('changelog.md'); return;
    case {'help', '-h', '?', '--help'}, help_(vcArg1); about_();
    case 'about', about_();

    % one argument
    case 'copyto-voms', copyto_voms_(vcArg1); return;     
    case 'copyfrom-voms', copyfrom_voms_(vcArg1); return;     
    case 'waitfor', waitfor_file_(vcArg1, vcArg2);
    case 'copyto', copyto_(vcArg1); return; %copy source code to destination    
    case 'version'
        if nargout==0, version_(vcArg1);
        else [varargout{1}, varargout{2}] = version_(vcArg1);
        end
    case 'clear', clear_(vcArg1);
    case 'mda-cut', mda_cut_(vcArg1);
    case 'doc', doc_('IronClust manual.pdf');
    case 'doc-edit', doc_('IronClust manual.docx');
    case 'update', git_pull_(vcArg1);
    case 'git-pull', git_pull_(vcArg1);
    case 'install', install_();
    case 'commit', commit_(vcArg1);
    case 'wiki', wiki_(vcArg1);
    case 'wiki-download', wiki_download_();
    case 'gui', gui_(vcArg1, vcFile_prm_);
    case 'issue', issue_('post');        
    case 'which', return;    
    case 'download', download_(vcArg1);
    case {'makeprm', 'createprm', 'makeprm-all'}
%         makeprm_(vcFile_bin, vcFile_prb, fAsk, vcFile_template, vcDir_prm)
        vcFile_prm_ = makeprm_(vcArg1, vcArg2, 1, vcArg3, vcArg4);
        if nargout>0, varargout{1} = vcFile_prm_; end
        if isempty(vcFile_prm_), return; end
        if strcmpi(vcCmd, 'makeprm-all'), irc('all', vcFile_prm_); end
    case 'makeprm-mda'
        vcFile_prm_ = makeprm_mda_(vcArg1, vcArg2, vcArg3, vcArg4, vcArg5);
        if nargout>0, varargout{1} = vcFile_prm_; end        
    case 'makeprm-f', makeprm_(vcArg1, vcArg2, 0, vcArg3, vcArg4);
    case 'import-tsf', import_tsf_(vcArg1);
    case 'import-h5', import_h5_(vcArg1);
    case 'import-jrc1', import_jrc1_(vcArg1);
    case 'export-jrc1', export_jrc1_(vcArg1);
    case 'convert-mda', convert_mda_(vcArg1);
    case 'export-mda', export_mda_(vcArg1, vcArg2);
    case 'import-intan', vcFile_prm_ = import_intan_(vcArg1, vcArg2, vcArg3); return;
    case {'import-nsx', 'import-ns5'}, vcFile_prm_ = import_nsx_(vcArg1, vcArg2, vcArg3); return;
    case 'convert-h5-mda', convert_h5_mda_(vcArg1, vcArg2); return;
    case 'export-gt', export_gt_(vcArg1, vcArg2); return;
    
%     case 'nsx-info', [~, ~, S_file] = nsx_info_(vcArg1); assignWorkspace_(S_file); return;
    case 'load-nsx', load_nsx_(vcArg1); return;
    case 'load-bin'
        mnWav = load_bin_(vcArg1, vcArg2); 
        assignWorkspace_(mnWav);
    case 'import-gt', import_gt_(vcArg1, vcArg2);   
    case 'unit-test', unit_test_(vcArg1, vcArg2, vcArg3);    
    case 'compile', compile_cuda_(vcArg1, vcArg2); 
    case 'compile-ksort', compile_ksort_();
    case 'test', varargout{1} = test_(vcArg1, vcArg2, vcArg3, vcArg4, vcArg5);
    case 'call'
        if ~isempty(vcArg3)
            varargout{1} = call_(vcArg1, vcArg2, vcArg3); 
        else
            switch nargout
                case 0, call_(vcArg1, vcArg2);
                case 1, varargout{1} = call_(vcArg1, vcArg2);
                case 2, [varargout{1}, varargout{2}] = call_(vcArg1, vcArg2);
                case 3, [varargout{1}, varargout{2}, varargout{3}] = call_(vcArg1, vcArg2);
                case 4, [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = call_(vcArg1, vcArg2);
            end %switch
        end
    case 'export', export_(vcArg1, vcArg2, vcArg3);    
    case {'dependencies', 'toolbox', 'toolboxes'}, disp_dependencies_();
    case {'caim', '2p'}, caim_(vcArg1, vcArg2, vcArg3);
    case 'prb2geom', prb2geom_(vcArg1, vcArg2); 
    case 'transpose-bin', transpose_bin_(vcArg1, vcArg2, vcArg3, vcArg4);
    otherwise, fExit = 0;
end
if fExit, return; end

%-----
% Command type B: Requires .prm file
if nargin>=2
    vcFile_prm = vcArg1; 
    vcFile_prm_ = vcFile_prm; 
else
    vcFile_prm = vcFile_prm_;    
end
if isempty(vcFile_prm), disp('Please specify .prm file.'); return; end
if isempty(vcArg1) && ~isempty(vcFile_prm), disp(['Working on ', vcFile_prm]); end
fExit = 1;
switch lower(vcCmd)    
    case 'probe', probe_(vcFile_prm);
    case {'make-trial', 'maketrial', 'load-trial', 'loadtrial'}, make_trial_(vcFile_prm, 0);
    case {'loadtrial-imec', 'load-trial-imec', 'make-trial-imec', 'maketrial-imec'}, make_trial_(vcFile_prm, 1);
    case 'edit', edit_(vcFile_prm); 
        
    case 'batch', batch_(vcArg1, vcArg2); 
%     case 'batch-makeprm' batch_makeprm_(vcArg1, vcArg2);
    case {'batch-verify', 'batch-validate'}, batch_verify_(vcArg1, vcArg2); 
    case {'batch-plot', 'batch-activity'}, batch_plot_(vcArg1, vcArg2); 
    case 'batch-mda', varargout{1} = batch_mda_(vcArg1, vcArg2, vcArg3);
    case 'sbatch-mda', [varargout{1}, varargout{2}] = sbatch_mda_(vcArg1, vcArg2, vcArg3, vcArg4);
            
    case 'describe', describe_(vcFile_prm); 
    case 'import-silico', import_silico_(vcFile_prm, 0);     
    case 'import-silico-sort', import_silico_(vcFile_prm, 1); 
    case {'import-kilosort', 'import-ksort'}, import_ksort_(vcFile_prm, 0); 
    case {'import-kilosort-sort', 'import-ksort-sort'}, import_ksort_(vcFile_prm, 1);  
    case {'kilosort', 'ksort'}, kilosort_(vcFile_prm); import_ksort_(vcFile_prm, 0); 
    case 'export-imec-sync', export_imec_sync_(vcFile_prm);
    case 'export-prm', export_prm_(vcFile_prm, vcArg2);        
    case 'dir'
        if any(vcFile_prm=='*')
            dir_files_(vcFile_prm, vcArg2, vcArg3);
        else
            fExit = 0;
        end
    otherwise
        fExit = 0;
end
% if contains_(lower(vcCmd), 'verify'), fExit = 0; end
if fExit, return; end

%-----
% Command type C: Requires P structure (loaded from .prm)
if ~matchFileExt_(vcFile_prm, '.prm'), fprintf(2, 'Must provide .prm file\n'); return ;end
if ~exist_file_(vcFile_prm, 1), return; end
P = loadParam_(vcFile_prm, 0); 
if isempty(P), return; end    
fError = 0;
switch lower(vcCmd)    
    case 'manual-gt', manual_(P, 'groundtruth'); return;
    case 'plot-clupairs', plot_clu_pairs_(P);
    case 'preview', preview_(P); 
    case 'preview-test', preview_(P, 1); gui_test_(P, 'Fig_preview');
    case 'traces', traces_(P, 0, vcArg2);
    case 'traces-lfp', traces_lfp_(P)
    case 'dir', dir_files_(P.csFile_merge);
    case 'traces-test'
        traces_(P, 1); traces_test_(P);
    case {'run', 'run-algorithm'}
        run_algorithm_(P);
    case {'full', 'all'}
        fprintf('Performing "irc detect", "irc sort", "irc manual" operations.\n');
        detect_(P); sort_(P, 0); describe_(P.vcFile_prm); manual_(P); return;      
    case {'spikesort', 'detectsort', 'detect-sort', 'spikesort-verify', 'spikesort-validate', 'spikesort-manual', 'detectsort-manual'}
        run_irc_(P);
    case 'gtsort'
        fprintf('Performing "irc detect" using groundtruth, and "irc sort" operations.\n');
        S_gt = load_gt_(P.vcFile_gt);
        if isempty(S_gt)
            fprintf(2, 'Error loading groundtruth: %s\n', P.vcFile_gt);
            return; 
        end
        detect_(P, S_gt.viTime, S_gt.viSite); sort_(P, 0); describe_(P.vcFile_prm);
    case {'show-gt', 'showgt'}
        show_gt_(P);
    case {'detect', 'spikedetect'}
        detect_(P); describe_(P.vcFile_prm);
    case {'sort', 'cluster', 'clust', 'sort-verify', 'sort-validate', 'sort-manual'}
        sort_(P);
        describe_(P.vcFile_prm);
    case {'auto', 'auto-verify', 'auto-manual'}
        auto_(P); describe_(P.vcFile_prm);
    case 'manual-test'
        manual_(P, 'debug'); manual_test_(P); return;          
    case 'manual-test-menu'
        manual_(P, 'debug'); manual_test_(P, 'Menu'); return;                   
    case {'kilosort-verify', 'ksort-verify'}
        kilosort_(P); import_ksort_(P); describe_(P.vcFile_prm); 
    case {'export-wav', 'export-raw'} % load raw and assign workspace
        mnWav = load_file_(P.vcFile, [], P);
        if strcmpi(vcCmd, 'export-wav')
            if P.fft_thresh>0, mnWav = fft_clean_(mnWav, P); end
            mnWav = filt_car_(mnWav, P);
        end
        mnWav = gather_(mnWav);
        assignWorkspace_(mnWav);
        try
            S_prb = load_prb_(P.probe_file);
            assignWorkspace_(S_prb);
        catch
            error('Probe file not found: %s', P.probe_file);
        end
    case 'export-spk'
        S0 = get(0, 'UserData');
        trSpkWav = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkwav.jrc'), 'int16', S0.dimm_spk);
        assignWorkspace_(trSpkWav);        
    case 'export-raw'
        S0 = get(0, 'UserData');
        trWav_raw = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkraw.jrc'), 'int16', S0.dimm_spk);
        assignWorkspace_(trWav_raw);  
    case {'export-spkwav', 'spkwav'}, export_spkwav_(P, vcArg2); % export spike waveforms
    case {'export-chan'}, export_chan_(P, vcArg2); % export channels
    case {'export-car'}, export_car_(P, vcArg2); % export common average reference
    case {'export-spkwav-diff', 'spkwav-diff'}, export_spkwav_(P, vcArg2, 1); % export spike waveforms        
    case 'export-spkamp', export_spkamp_(P, vcArg2); %export microvolt unit
    case {'export-csv', 'exportcsv'}, varargout{1} = export_csv_(P);
    case {'export-quality', 'exportquality', 'quality'}, export_quality_(P);
    case {'export-csv-msort', 'exportcsv-msort'}, export_csv_msort_(P);
    case {'activity', 'plot-activity'}, plot_activity_(P);    
    case {'export-fet', 'export-features', 'export-feature'}, export_fet_(P);
    case 'export-diff', export_diff_(P); %spatial differentiation for two column probe
    case 'import-lfp', import_lfp_(P); 
    case 'export-lfp', export_lfp_(P); 
    case 'drift', plot_drift_(P);  
    case 'plot-rd', plot_rd_(P);
    otherwise, fError = 1;
end %switch

% supports compound commands (ie. 'sort-verify', 'sort-manual').
if contains_(lower(vcCmd), {'verify', 'validate'})
    validate_(P, vcArg2);
elseif contains_(lower(vcCmd), {'manual',' gui', 'ui'})
    manual_(P);
elseif fError
    help_();
end
end %func


%--------------------------------------------------------------------------
function flag = contains_(vc, cs)
% check if vs contains any of cs
if ischar(cs), cs = {cs}; end
flag = 0;
for i = 1:numel(cs)
    if ~isempty(strfind(vc, cs{i}))
        flag = 1; 
        break; 
    end
end
end %func


%--------------------------------------------------------------------------
function [viSite_spk2, viSite_spk3] = find_site_spk23_(tnWav_spk, viSite_spk, P)
% find second min, excl local ref sites
fUse_min = 0;
imin0 = 1 - P.spkLim(1);
viSites2 = 2:(2*P.maxSite+1-P.nSites_ref);
miSites2 = P.miSites(viSites2,viSite_spk);
%[~,viSite_spk2] = min(squeeze_(tnWav_spk(imin0,viSites2,:)));
tnWav_spk2 = tnWav_spk(:,viSites2,:);
if fUse_min
    mnMin_spk = squeeze_(min(tnWav_spk2));
else
%     mnMin_spk = -squeeze_(std(single(tnWav_spk(:,viSites2,:))));
    mnMin_spk = squeeze_(min(tnWav_spk2) - max(tnWav_spk2)); % use Vpp to determine second peak site
end
if nargout==1
    [~, viSite_spk] = min(mnMin_spk);
    viSite_spk2 = int32(mr2vr_sub2ind_(miSites2, viSite_spk, []));
else
    [~, miSite_spk2] = sort(mnMin_spk, 'ascend');
    viSite_spk2 = int32(mr2vr_sub2ind_(miSites2, miSite_spk2(1,:), []));
    viSite_spk3 = int32(mr2vr_sub2ind_(miSites2, miSite_spk2(2,:), []));
end
end %func


%--------------------------------------------------------------------------
function tnWav_spk1 = mn2tn_wav_spk2_(mnWav1, viSite_spk, viTime_spk, P)
nTime_search = 2;

nSpks = numel(viSite_spk);
nSites = numel(P.viSite2Chan);
spkLim_wav = P.spkLim;
nSites_spk = (P.maxSite * 2) + 1;
tnWav_spk1 = zeros(diff(spkLim_wav) + 1, nSites_spk, nSpks, 'like', mnWav1);
% nTime_search = 2;
for iSite = 1:nSites
    viiSpk11 = find(viSite_spk == iSite);
    if isempty(viiSpk11), continue; end
    viTime_spk11 = viTime_spk(viiSpk11); %already sorted by time
    viSite11 = P.miSites(:,iSite);
        
    if nTime_search > 0 % deal with single sample shift
        viTime_spk11 = search_min_(mnWav1(:,iSite), viTime_spk11, nTime_search);
    end
    tnWav_spk1(:,:,viiSpk11) = permute(gather_(mr2tr3_(mnWav1, spkLim_wav, viTime_spk11, viSite11)), [1,3,2]); %raw    
end
end %func


%--------------------------------------------------------------------------
% 6/20/2018 JJJ
% Search the min time from the range started
function [viSpk, viUpdated, viShifted] = search_min_(vnWav1, viSpk, nSearch)
% center the wave at the min

mi_ = bsxfun(@plus, viSpk(:)', cast(-nSearch:nSearch, 'like', viSpk)');
mi_(mi_<1) = 1;
mi_(mi_>numel(vnWav1)) = numel(vnWav1);
[~, viShift_spk11] = min(vnWav1(mi_));
iTime0 = nSearch + 1;
viUpdated = find(viShift_spk11 ~= iTime0);
viShifted = viShift_spk11(viUpdated) - iTime0;
viSpk(viUpdated) = viSpk(viUpdated) + cast(viShifted(:), 'like', viSpk);
end %func


%--------------------------------------------------------------------------
function csHelp = help_(vcCommand)
if nargin<1, vcCommand = ''; end
if ~isempty(vcCommand), wiki_(vcCommand); return; end

csHelp = {...
    ''; 
    'Usage: irc command arg1 arg2 ...';
    '  You can also run "irc command ..." to explicitly specify the version number.';
    '';
    '[Documentation and help]';
    '  irc help';
    '    Display a help menu'; 
    '  irc doc';
    '    Open a help document (pdf)';         
    '  irc version';
    '    Display the version number and the updated date';            
    '  irc about';
    '    Display about information';       
    '  irc which';
    '    Display the file path for the IronClust code called';           
    '  irc wiki';
    '    Open a IronClust Wiki on GitHub';     
    '  irc wiki-download';
    '    Download the IronClust Wiki on GitHub to ./wiki/';    
    '  irc issue';
    '    Post an issue at GitHub (log-in with your GitHub account)';        
    '';
    '[Main commands]';
    '  irc edit (myparam.prm)';
    '    Edit .prm file currently working on'; 
    '  irc setprm myparam.prm';
    '    Select a .prm file to use'; 
    '  irc clear';
    '    Clear cache';
    '  irc clear myparam.prm';
    '    Delete previous results (files: _jrc.mat, _spkwav.jrc, _spkraw.jrc, _spkfet.jrc)';        
    '  irc spikesort myparams.prm';
    '    Run the whole suite (spike detection and clustering) ';
    '  irc detect myparams.prm';
    '    Run spike detection and extract spike waveforms';
    '    Output files: _jrc.mat, _spkwav.jrc (filtered spike waveforms), _spkraw.jrc (raw spike waveforms), _spkfet.jrc (features)';
    '  irc sort myparams.prm';
    '    Cluster spikes (after spike detection)';
    '    Output files: _jrc.mat';
    '  irc auto myparams.prm';
    '    Recluster spikes after updating post-clustering paramters';
    '  irc download sample';
    '    Download sample data from Neuropix phase 2 probe';
    '  irc probe {myprobe.prb, myparams.prm}';
    '    Plot probe layout'; 
    '  irc makeprm myrecording.bin myprobe.prb';
    '    create a new parameter file based on the default template file (default.prm) and probe file';
    '  irc makeprm myrecording.bin myprobe.prb mytemplate.prm';
    '    create a new parameter file based on the specified template file and probe file';    
    '  irc traces myparams.prm';
    '    Displays raw trace';
    '  irc describe myparams.prm';
    '    Display information about a clu dataset ';
    '  irc manual myparams.prm';
    '    Run the manual clustering GUI ';
    '  irc auto-manual myparams.prm';
    '    Run the auto clustering and do the manual clustering next';        
    '  irc plot-activity myparams.prm';
    '    Show firing rate as a function of time and depth';         
    '  irc verify myparams.prm';
    '    Compares against ground truth file (_gt.mat)';
    '  irc drift myparams.prm';
    '    Visualize drift.';       
    '  irc plot-rd myparams.prm';
    '    Rho vs. Delta plot used in DPCLUS clustering (Rodriguez-Laio).';      
    '  irc batch myparam.batch (command)';
    '    Batch process list of prm files';         
    '  irc batch myparam.batch template.prm';
    '    Batch process list of .bin files using a template prm file';             
    '';
    '[Export]';
    '  irc export myparams.prm';
    '    Export the global struct (S0) to the workspace. This is also contained in _jrc.mat output file.';    
    '  irc export-csv myparams.prm';
    '    Export clustered information to a csv file (spike time, cluster #, max site#)';
    '  irc export-quality myparams.prm';
    '    Export unit quality information to a csv file (ends with "_quality.csv")';    
    '  irc export-jrc1 myparams.prm';
    '    Export to version 1 format (write to _evt.mat and _clu.mat)';
    '  irc import-jrc1 myparams.prm';
    '    Import from version 1 format';    
    '  irc export-imec-sync myparams.prm';
    '    Export Sync channel (uint16) to the workspace (vnSync)';            
    '  irc export-wav myparams.prm';
    '    Export the entire filtered traces (mnWav) to the Workpace';
    '  irc export-raw myparams.prm';
    '    Export the entire raw traces (mnWav) to the Workpace';    
    '  irc export-spkwav myparams.prm (clu#)';
    '    Export spike waveforms organized by clusters to the Workspace';
    '  irc export-spk myparams.prm';
    '    Export spike waveforms to the Workspace, sorted by the time of spike';    
    '  irc export-spkamp myparams.prm (clu#)';
    '    Export spike amplitudes to the Workspace'; 
    '  irc export-fet myparams.prm';
    '    Export feature matrix (trFet) and sites (miFet_sites) to the Workspace';     
    '  irc export-prm myparams.prm (myparam_full.prm)';
    '    Export complete list of parameters to a new file.';
    '    If the second argument is omitted, the current parameter file is updated.';
    '    If some parameter values are missing, they will be copied from the default template file (default.prm).';
    '';
    '[Import]';
    '  irc import-gt groundtruth_file myparam.prm';
    '    Import a groundtruth_file and update myparam.prm file';
    '    groundtruth_file can be firings_true.mda (MountainLab) format or numpy2matlab format (Catalin Mitelut)';
    '    it creates a matlab file with two fields: viClu and viTime';
    '  irc import-intan intanrec*.dat myprobe.prb';
    '    Import from intan recordings, which saved each channel as -A###.dat file in int16 format.';        
    '    Combine .dat files to a single .bin file and saves to the directory above.';
    '    Generate .prm file by combining the .bin and .prb file names (e.g. binfile_prbfile.prm).';    
    '  irc import-nsx myrec.ns5 myprobe.prb';
    '    Imports Neuroshare format and export the analog channels to .bin file.';
    '    Generates .prm file by combining the .bin and .prb file names (e.g. binfile_prbfile.prm).';
    '';
    '[Sorting multiple recordings together]';
    '  irc dir myparam.prm'; 
    '    List all recording files to be clustered together (csFile_merge)';
    '  irc traces myparam.prm';
    '    List all recording files and select which one to display';
    '  irc traces myparam.prm File#';
    '    Direcly specify the file number to display';
    '';
    '[Deployment]';
    '  irc update';
    '    Update to the latest version from GitHub (valid only if installed by "git checkout" command)';
    ' irc update version_tag';
    '    Revert to a specific release version ("version_tag") from GitHub (valid only if installed by "git checkout" command)';    
    '  irc unit-test';
    '    Run a suite of unit teste.';       
    '  irc install';
    '    Install irc by compiling codes';    
    '  irc compile';
    '    Recompile CUDA code (GPU codes, *.cu)';     
    '';
};
if nargout==0, disp_cs_(csHelp); end
end %func


%--------------------------------------------------------------------------
function disp_cs_(cs)
% display cell string
cellfun(@(s)fprintf('%s\n',s), cs);
end %func


%--------------------------------------------------------------------------
function probe_(vcFile_prb)
% if nargin<1, vcFile_prb='imec2.prb'; end

% set prb file
if matchFileExt_(vcFile_prb, {'.bin', '.dat'})
    vcFile_prb = subsFileExt_(vcFile_prb, '.prm');
end
if matchFileExt_(vcFile_prb, '.prm')
    vcFile_prm = vcFile_prb;
    P = loadParam_(vcFile_prm);
    vcFile_prb = P.probe_file;
    if ~exist_file_(vcFile_prb)
        vcFile_prb = replacePath_(vcFile_prb, vcFile_prm);
    end
end
vcFile_prb = find_prb_(vcFile_prb); 
if isempty(vcFile_prb), fprintf(2, 'Probe file doesn''t exist.\n'); return; end
S_prb = load_prb_(vcFile_prb);
hFig = create_figure_('FigProbe', [0 0 .5 1], vcFile_prb, 1, 1);
hPatch = plot_probe_(S_prb.mrSiteXY, S_prb.vrSiteHW, S_prb.viSite2Chan, S_prb.viShank_site);
axis equal;
edit_(vcFile_prb); %show probe file
figure(hFig);
end %func


%--------------------------------------------------------------------------
% 11/5/17 JJJ: Find .prb file in ./prb/ folder first
% 9/26/17 JJJ: Find .prb file. Look in ./prb/ folder if doesn't exist
function vcFile_prb = find_prb_(vcProbeFile)
% Find a prb file
if exist_file_(vcProbeFile)
    vcFile_prb = vcProbeFile;
else
    % strip directory and find in the path
    [~, vcFile_, vcExt_] = fileparts(vcProbeFile);
    vcProbeFile_ = [vcFile_, vcExt_];
    vcFile_prb = fullfile(ircpath_(), 'prb', vcProbeFile_);
    
    % search recursively
    if ~exist_file_(vcFile_prb)
        vcFile_prb = search_file_(vcProbeFile_, [ircpath_(), 'prb', filesep()]);
    end
end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Created and tested
function vcFile_full = ircpath_(vcFile, fConditional)
% make it a irc path
% Add a full path if the file doesn't exist in the current folder
% 

if nargin<1, vcFile = ''; end
if nargin<2, fConditional = 0; end

ircpath = fileparts(mfilename('fullpath'));
if fConditional
    if exist_file_(vcFile)
        vcFile_full = vcFile;
        return;
    end
end
vcFile_full = [ircpath, filesep(), vcFile];
% if exist(vcFile_full, 'file') ~= 2
%     vcFile_full = [];
% end
end %func


%--------------------------------------------------------------------------
function download_(vcMode)
S_cfg = read_cfg_();
% if strcmpi(pwd(), S_cfg.path_alpha), disp('cannot overwrite alpha'); return; end
switch lower(vcMode)   
    case {'sample', 'neuropix2', 'neuropixels2', 'phase2', 'phaseii'}
        csLink = S_cfg.path_sample_phase2;
    case {'sample3', 'neuropix3' 'neuropixels3', 'phase3', 'phaseiii'}
        csLink = S_cfg.path_sample_phase3;
    otherwise
        disp('Invalid selection. Try "irc download sample or irc download sample3".');
        return;
end %switch

t1 = tic;
fprintf('Downloading sample files. This can take up to several minutes.\n');
vlSuccess = download_files_(csLink);
fprintf('\t%d/%d files downloaded. Took %0.1fs\n', ...
    sum(vlSuccess), numel(vlSuccess), toc(t1));
end %func


%--------------------------------------------------------------------------
function keyPressFcn_Fig_traces_(hFig, event)
% 2017/6/22 James Jun: Added nTime_traces multiview

global mnWav1 mrWav1 mnWav
S0 = get(0, 'UserData'); 
P = S0.P;
S_fig = get(hFig, 'UserData');
factor = 1 + 3 * key_modifier_(event, 'shift');
nSites = numel(P.viSite2Chan);

switch lower(event.Key)
    case 'h', msgbox_(S_fig.csHelp, 1);
        
    case {'uparrow', 'downarrow'}
        if isfield(S_fig, 'chSpk')
            S_fig.maxAmp = change_amp_(event, S_fig.maxAmp, S_fig.hPlot, S_fig.chSpk);
        else
            S_fig.maxAmp = change_amp_(event, S_fig.maxAmp, S_fig.hPlot);
        end
        title_(S_fig.hAx, sprintf(S_fig.vcTitle, S_fig.maxAmp));        
        set(hFig, 'UserData', S_fig);
        
    case {'leftarrow', 'rightarrow', 'j', 'home', 'end'}
        switch lower(event.Key)
            case 'leftarrow'
                nlim_bin = S_fig.nlim_bin - (S_fig.nLoad_bin) * factor; %no overlap
                if nlim_bin(1)<1
                    msgbox_('Beginning of file', 1); 
                    nlim_bin = [1, S_fig.nLoad_bin]; 
                end
            case 'rightarrow'
                nlim_bin = S_fig.nlim_bin + (S_fig.nLoad_bin + 1) * factor; %no overlap
                if nlim_bin(2) > S_fig.nSamples_bin
                    msgbox_('End of file', 1); 
                    nlim_bin = [-S_fig.nLoad_bin+1, 0] + S_fig.nSamples_bin;
                end
            case 'home' %beginning of file
                nlim_bin = [1, S_fig.nLoad_bin];
            case 'end' %end of file
                nlim_bin = [-S_fig.nLoad_bin+1, 0] + S_fig.nSamples_bin;
            case 'j'
                vcAns = inputdlg_('Go to time (s)', 'Jump to time', 1, {'0'});
                if isempty(vcAns), return; end
                try
                    nlim_bin = round(str2double(vcAns)*P.sRateHz) + [1, S_fig.nLoad_bin];
                catch
                    return;
                end
        end %switch
        nTime_traces = get_(P, 'nTime_traces');
        [cvn_lim_bin, viRange_bin] = sample_skip_(nlim_bin, S_fig.nSamples_bin, nTime_traces); 
        if P.fTranspose_bin
            fseek_(S_fig.fid_bin, nlim_bin(1), P);
            if nTime_traces > 1
                mnWav1 = load_bin_multi_(S_fig.fid_bin, cvn_lim_bin, P)';
            else
                mnWav1 = load_bin_(S_fig.fid_bin, P.vcDataType, [P.nChans, S_fig.nLoad_bin])';            
            end
        else
            mnWav1 = mnWav(viRange_bin, :);
        end
        mnWav1 = uint2int_(mnWav1);
        S_fig.nlim_bin = nlim_bin;
        set_fig_(hFig, S_fig);
        Fig_traces_plot_(1); %redraw
        
    case 'f' %apply filter
        S_fig.vcFilter = str_toggle_(S_fig.vcFilter, 'on', 'off');
        set_fig_(hFig, S_fig);
        Fig_traces_plot_();        
        
    case 'g' %grid toggle on/off
        S_fig.vcGrid = str_toggle_(S_fig.vcGrid, 'on', 'off');
        grid(S_fig.hAx, S_fig.vcGrid);
        set(hFig, 'UserData', S_fig);
        
    case 'r' %reset view
        fig_traces_reset_(S_fig);        
        
    case 'e' %export current view        
        assignWorkspace_(mnWav1, mrWav1);
        disp('mnWav1: raw traces, mrWav1: filtered traces');
        
    case 'p' %power spectrum
        iSite_show = inputdlg_num_(sprintf('Site# to show (1-%d, 0 for all)', nSites), 'Site#', 0);
        if isnan(iSite_show), return; end        
        hFig = create_figure_('FigPsd', [.5 0 .5 1], P.vcFile_prm, 1, 1); %show to the right
        % ask user which channels to plot
        if iSite_show>0
            mrWav2 = mrWav1(:, iSite_show);
        else
            mrWav2 = mrWav1;
        end
        plotMedPower_(mrWav2, 'sRateHz', P.sRateHz/P.nSkip_show, 'viChanExcl', P.viSiteZero);
        
    case 's' %show/hide spikes
        S_fig.vcSpikes = str_toggle_(S_fig.vcSpikes, 'on', 'off');
        set_fig_(hFig, S_fig);
        Fig_traces_plot_();
        
    case 't' %show/hide traces
        S_fig.vcTraces = str_toggle_(S_fig.vcTraces, 'on', 'off');
        set_fig_(hFig, S_fig);
        Fig_traces_plot_();         
        
    case 'c' %channel query
        msgbox_('Draw a rectangle', 1);
        hRect = imrect_();
        if isempty(hRect), return ;end
        vrPos_rect = getPosition(hRect);            
        S_plot = get(S_fig.hPlot, 'UserData');
        vrX = get(S_fig.hPlot, 'XData');
        vrY = get(S_fig.hPlot, 'YData');
        viIndex = find(vrX >= vrPos_rect(1) & vrX <= sum(vrPos_rect([1,3])) & vrY >= vrPos_rect(2) & vrY <= sum(vrPos_rect([2,4])));
        if isempty(viIndex), delete_multi_(hRect); return; end
        index_plot = round(median(viIndex));
        [time1, iSite] = ind2sub(size(mrWav1), index_plot);        
        mrX = reshape(vrX, S_plot.dimm);
        mrY = reshape(vrY, S_plot.dimm);
        hold(S_fig.hAx, 'on');
        hPoint = plot(vrX(index_plot), vrY(index_plot), 'r*');
        hLine = plot(S_fig.hAx, mrX(:,iSite), mrY(:,iSite), 'r-');
        hold(S_fig.hAx, 'off');
        iChan = P.viSite2Chan(iSite);
        msgbox_(sprintf('Site: %d/ Chan: %d', iSite, iChan), 1);
        delete_multi_(hRect, hLine, hPoint);
end %return if S_fig didn't change
end %func


%--------------------------------------------------------------------------
function vc = str_toggle_(vc, vc1, vc2)
% toggle vc1 to vc2
if strcmpi(vc, vc1)
    vc = vc2; 
else
    vc = vc1;
end
end %func


%--------------------------------------------------------------------------
function [maxAmp, mrAmp_prev] = change_amp_(event, maxAmp, varargin)
% varargin: plot object to rescale
% Change amplitude scaling 
% change_amp_(event, maxAmp, varargin)
% change_amp_(event) % directly set
% if nargin<3, hPlot=[]; end
factor = sqrt(2);
if key_modifier_(event, 'shift'), factor = factor ^ 4; end
mrAmp_prev = maxAmp;
if strcmpi(event.Key, 'uparrow')
    maxAmp = maxAmp / factor;
elseif strcmpi(event.Key, 'downarrow')
    maxAmp = maxAmp * factor;
end
for iPlot = 1:numel(varargin)
    try
        multiplot(varargin{iPlot}, maxAmp);
    catch            
    end
end
% handle_fun_(@rescale_plot_, hPlot, maxAmp);
end %func


%--------------------------------------------------------------------------
function flag = key_modifier_(event, vcKey)
% Check for shift, alt, ctrl press
try
    flag = any(strcmpi(event.Modifier, vcKey));
catch
    flag = 0;
end
end %func


%--------------------------------------------------------------------------
function val = read_cfg_(vcName, fVerbose)
% read configuration file that stores path to folder
% load from default.cfg but override with user.cfg if it exists
if nargin<2, fVerbose = 0; end

S_cfg = file2struct_(ircpath_('default.cfg'));
if exist_file_(ircpath_('user.cfg'))
    S_cfg1 = file2struct_(ircpath_('user.cfg')); %override
    S_cfg = struct_merge_(S_cfg, S_cfg1, {'path_dropbox', 'path_backup', 'default_prm'});
    if fVerbose, fprintf('Configuration loaded from user.cfg.\n'); end
else
    if fVerbose, fprintf('Configuration loaded from default.cfg.\n'); end
end

% set path
if ispc()
    [path_alpha, path_github, path_ironclust] = ...
        deal(S_cfg.path_alpha, S_cfg.path_github, S_cfg.path_ironclust);
elseif isunix()
    [path_alpha, path_github, path_ironclust] = ...
        deal(S_cfg.path_alpha_linux, S_cfg.path_github_linux, S_cfg.path_ironclust_linux);
end
S_cfg = struct_add_(S_cfg, path_alpha, path_github, path_ironclust);

if nargin==0
    val = S_cfg;
else
    try
        val = S_cfg.(vcName);
    catch
        disperr_(['read_cfg_: error reading ', ircpath_('default.cfg')]);
        switch lower(vcName)
            case 'default_prm'
                val = 'default.prm';
            otherwise
                val = [];
        end
    end
end
end %func


%--------------------------------------------------------------------------
% update ironclust_alpha to ironclust/matlab directory
function commit_(vcArg1)
% commit_()
%   Full validation and update
% commit_('log')
%   Update 'changelog.md' only
% commit_('skip')
%   Skip unit test

if nargin<1, vcArg1=''; end
t1 = tic;
S_cfg = read_cfg_();

if ~strcmpi(pwd(), S_cfg.path_alpha), disp('must commit from alpha'); return; end

% just update the log
if strcmpi(vcArg1, 'log')
%     sprintf('copyfile changelog.md ''%s'' f;', S_cfg.path_dropbox);
    copyfile_('changelog.md', S_cfg.path_github, S_cfg.path_ironclust);
    disp('Commited changelog.md');
    return;
elseif ~strcmpi(vcArg1, 'skip')
    disp('Running unit tests before commit... ');
    nTests_fail = unit_test_(); %run full unit test
    if nTests_fail > 0
        fprintf(2, 'Commit aborted, %d unit tests failed\n.', nTests_fail);
        return;
    end
else
    fprintf(2, 'Skipping unit test...\n');
end

delete_files_(find_empty_files_());

% commit irc related files only
%try commit_irc_(S_cfg, path_github, 0); catch; disperr_(); end
try commit_irc_(S_cfg, S_cfg.path_ironclust, 0); catch; disperr_(); end
%vcFile_mp = strrep(path_ironclust, 'IronClust', 'ml_ironclust.mp');
%try fileattrib(vcFile_mp, '+x'); fprintf('chmod +x %s\n',vcFile_mp); catch; end
%try movefile(fullfile(path_ironclust, 'p_ironclust.m'), strrep(path_ironclust, 'matlab', '')); catch; disperr_(); end

edit_('changelog.md');
fprintf('Commited, took %0.1fs.\n', toc(t1));
end


%--------------------------------------------------------------------------
% 8/22/18 JJJ: changed from the cell output to varargout
% 9/26/17 JJJ: Created and tested
function varargout = struct_get_(varargin)
% Obtain a member of struct
% cvr = cell(size(varargin));
% if varargin is given as cell output is also cell
S = varargin{1};
for iArg=1:nargout
    vcName = varargin{iArg+1};
    if iscell(vcName)
        csName_ = vcName;
        cell_ = cell(size(csName_));
        for iCell = 1:numel(csName_)
            vcName_ = csName_{iCell};
            if isfield(S, vcName_)
                cell_{iCell} = S.(vcName_);
            end
        end %for
        varargout{iArg} = cell_;
    elseif ischar(vcName)
        if isfield(S, vcName)
            varargout{iArg} = S.(vcName);
        else
            varargout{iArg} = [];
        end
    else
        varargout{iArg} = [];
    end
end %for
end %func


%--------------------------------------------------------------------------
% 8/22/18 JJJ: changed from the cell output to varargout
% 9/26/17 JJJ: Created and tested
function S_copy = struct_copy_(varargin)
% Obtain a member of struct
% cvr = cell(size(varargin));
S = varargin{1};
S_copy = struct();
for iArg=2:nargin
    vcName = varargin{iArg};
    if isfield(S, vcName)
        S_copy.(vcName) = S.(vcName);
    else
        S_copy.(vcName) = [];
    end
end %for
end %func


%--------------------------------------------------------------------------
% 9/3/18 JJJ: set struct
function S = struct_set_(varargin)
% S = struct_set_(S, var1, var2, ...)
S = varargin{1};
for iArg=2:nargin
    try
        vcName = inputname(iArg);
        S.(vcName) = varargin{iArg};
    catch
        ;
    end
end %for
end %func


%--------------------------------------------------------------------------
function S0 = detect_(P, viTime_spk0, viSite_spk0)
if nargin<2, viTime_spk0 = []; end
if nargin<3, viSite_spk0 = []; end

global tnWav_raw tnWav_spk trFet_spk;
runtime_detect = tic;
% Clear memory (S0 is cleared)
set(0, 'UserData', []);
[tnWav_raw, tnWav_spk, trFet_spk] = deal([]);

vcDetect = get_set_(P, 'vcDetect', 'min');
switch lower(vcDetect)
    case 'min'
        S0 = file2spk_(P, viTime_spk0, viSite_spk0);
    case 'xcov'
        S0 = detect_xcov_(P, viTime_spk0, viSite_spk0);
end
if get_set_(P, 'fRamCache', 1)
    tnWav_raw = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkraw.jrc'), 'int16', S0.dimm_raw);
    tnWav_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkwav.jrc'), 'int16', S0.dimm_spk); 
end
trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet); 
S0.mrPos_spk = spk_pos_(S0, trFet_spk);

% measure time
S0.runtime_detect = toc(runtime_detect);
fprintf('Detection took %0.1fs for %s\n', S0.runtime_detect, P.vcFile_prm);

set(0, 'UserData', S0);
save0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
delete_(strrep(P.vcFile_prm, '.prm', '_log.mat')); %delete log file when detecting
end %func


%--------------------------------------------------------------------------
% 9/23/2018 JJJ: added a case when nSites_spk=inf (using alll sites)
function mrPos_spk = spk_pos_(S0, trFet_spk, nSites_spk)
if nargin<2, trFet_spk = get_spkfet_(S0.P); end
P = S0.P;
nSpk = size(trFet_spk,3);

if nargin<3
    nSites_spk = 1 + P.maxSite*2 - P.nSites_ref; 
    miSites_spk = single(P.miSites(1:nSites_spk, S0.viSite_spk));
elseif isinf(nSites_spk)
    nSites_spk = size(P.mrSiteXY,1);
    miSites_spk = repmat(int32(1:nSites_spk)', [1,nSpk]);
end

mrVp = squeeze_(trFet_spk(1:nSites_spk,1,:)) .^ 2;
vrVp = sum(mrVp);

mrX_spk = reshape(P.mrSiteXY(miSites_spk,1), size(miSites_spk));
mrY_spk = reshape(P.mrSiteXY(miSites_spk,2), size(miSites_spk));

mrPos_spk = zeros(nSpk, 2, 'single');
mrPos_spk(:,1) = sum(mrVp .* mrX_spk) ./ vrVp;
mrPos_spk(:,2) = sum(mrVp .* mrY_spk) ./ vrVp;
end %func


%--------------------------------------------------------------------------
function S0 = sort_(P, fLoad)
% Extract feature and sort
if nargin<2, fLoad = 1; end
if ~is_detected_(P), detect_(P); end
if fLoad
    [S0, P] = load_cached_(P); 
else
    S0 = get(0, 'UserData');
end

runtime_sort = tic;
% Sort and save
S_clu = fet2clu_(S0, P);
[S_clu, S0] = S_clu_commit_(S_clu, 'sort_');
% S0 = set0_(P); %, dimm_fet, cvrTime_site, cvrVpp_site, cmrFet_site, P);

% measure time
runtime_sort = toc(runtime_sort);
fprintf('Sorting took %0.1fs for %s\n', runtime_sort, P.vcFile_prm);
S0 = set0_(runtime_sort, P);
S0 = clear_log_(S0);

save0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
end %func


%--------------------------------------------------------------------------
function mr = vr_shift_(vr, viShift)
% viShift = [0, -1,-.5,.5,1]; %[0, -.5, .5]
% viShift = [0, -1:.25:-.25,.25:.25:1]; 
nShifts = numel(viShift);
vr = vr(:);
vi0 = (1:numel(vr))';
mr = zeros(numel(vr), nShifts, 'like', vr);
for iShift = 1:nShifts
    dn = viShift(iShift);
    if dn~=0
        mr(:,iShift) = interp1(vi0, vr, vi0+dn, 'pchip', 'extrap');
    else
        mr(:,iShift) = vr; 
    end    
end
end %func


%--------------------------------------------------------------------------
% CAR subtraction using outer half of sites
function tr = trWav_car_(tr, P)
vcSpkRef = get_set_(P, 'vcSpkRef', 'nmean');
if ~strcmpi(P.vcSpkRef, 'nmean'), return; end
tr = single(permute(tr, [1,3,2]));
dimm_tr = size(tr);
viSite_ref = ceil(size(tr,3)/2):size(tr,3);
if numel(viSite_ref) < 4, return; end % do not use for small number of sites

mrWav_ref = mean(tr(:,:,viSite_ref), 3);
tr = meanSubt_(reshape(bsxfun(@minus, reshape(tr,[],dimm_tr(3)), mrWav_ref(:)), dimm_tr));
tr = permute(tr, [1,3,2]);
end %func


%--------------------------------------------------------------------------
% 8/1/17 JJJ: Bugfix: If S_clu is empty, reload _jrc.mat file
function [S0, P] = load_cached_(P, fLoadWav)
% Load cached data either from RAM or disk
% Usage
% S0 = load_cached_(P)
% S0 = load_cached_(vcFile)
% P0: Previously stored P in S0, S0.P = P overwritten
if nargin<2, fLoadWav=1; end

global tnWav_spk tnWav_raw trFet_spk %spike waveform (filtered)
if ischar(P), P = loadParam_(P); end
S0 = get(0, 'UserData'); 
fClear_cache = 1;
if ~isempty(S0)
    if isfield(S0, 'P')
        if strcmpi(P.vcFile_prm, S0.P.vcFile_prm)
            fClear_cache = 0;
        end
    end    
end
if fClear_cache
    [S0, tnWav_spk, tnWav_raw, trFet_spk] = deal([]);
end

% Load from disk
try
    fLoad0 = 0;
    if isempty(S0)
        fLoad0 = 1; 
    elseif isempty(get_(S0, 'S_clu'))
        fLoad0 = 1;
    end
    
    vcFile_jrc = strrep(P.vcFile_prm, '.prm', '_jrc.mat');
    if ~exist_file_(vcFile_jrc), S0.P=P; return; end
    if fLoad0, S0 = load0_(vcFile_jrc); end
    if isempty(S0), S0.P = []; end
    [P0, S0.P] = deal(S0.P, P); %swap
    if isempty(tnWav_spk) || isempty(tnWav_raw) || isempty(trFet_spk)
        if ~fLoadWav, return; end
        if isempty(S0), return; end %no info                
        try
            if get_set_(P, 'fRamCache', 1)            
                trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet);
                tnWav_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkwav.jrc'), 'int16', S0.dimm_spk);
                tnWav_raw = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkraw.jrc'), 'int16', S0.dimm_raw);                
            else
                trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet);
            end
        catch
            disperr_();
        end        
    end
    P = upgrade_param_(S0, P0);
    S0.P = P;
catch hErr
    disperr_('load_cached_ error', hErr);
end
end


%--------------------------------------------------------------------------
function P = upgrade_param_(S0, P0)
% Upgrade parameter struct P based on the old value P0

% upgrade raw 
P = S0.P;
nSamples_raw = S0.dimm_raw(1);
nSamples_raw_P = diff(S0.P.spkLim_raw) + 1;
if nSamples_raw_P ~= nSamples_raw
    spkLim_raw = P.spkLim * 2;
    nSamples_raw_P = diff(spkLim_raw) + 1;
    if nSamples_raw_P == nSamples_raw
        P.spkLim_raw = spkLim_raw;
        P.spkLim_raw_factor = 2;
        P.spkLim_raw_ms = [];
    elseif nSamples_raw == S0.dimm_spk(1)
        P.spkLim_raw = P.spkLim;
        P.spkLim_raw_factor = 1;
        P.spkLim_raw_ms = [];
        P.spkLim_factor_merge = 1;
    else
        P.spkLim_raw = P0.spkLim_raw;
        P.spkLim_raw_factor = P.spkLim_raw(1) /  P.spkLim(1);
        P.spkLim_raw_ms = [];
%         disperr_('Dimension of spkLim_raw is inconsistent between S0 and P');
    end
end

% upgrade P.maxSite and P.nSites_ref (v3.1.1 to v3.1.9)
nSites_spk = S0.dimm_raw(2);
nSites_spk_P = P.maxSite * 2 + 1;
if nSites_spk_P ~= nSites_spk
    P.maxSite = (nSites_spk-1)/2;
    P.nSites_ref = nSites_spk - S0.dimm_fet(1);
    P.miSites = findNearSites_(P.mrSiteXY, P.maxSite, P.viSiteZero, P.viShank_site);
end
end %func


%--------------------------------------------------------------------------
function varargout = trWav2fet_cov_(trWav2, P)
% tnWav1: nT x nSites_spk x nSpk
% subtract ref
% nSites_spk = 1 + 2 * P.maxSite - P.nSites_ref; % size(tnWav_spk, 2);
vnDelay_fet = get_set_(P, 'vnDelay_fet', [0,3]);

[nT, nSpk, nSites_spk] = size(trWav2);
[cvi2, cvi1] = shift_range_(nT, [], vnDelay_fet);
cmrFet = cell(numel(vnDelay_fet), 1);
for iDelay = 1:numel(vnDelay_fet)
    mr1_ = meanSubt_(trWav2(cvi1{iDelay},:,1));
    mr1_ = bsxfun(@rdivide, mr1_, sqrt(mean(mr1_.^2))); %zscore fast   
    tr1_ = repmat(mr1_, [1,1,nSites_spk]);
    tr2_ = meanSubt_(trWav2(cvi2{iDelay},:,:));
    cmrFet{iDelay} = permute(mean(tr1_ .* tr2_, 1), [3,2,1]);
end %for

if nargout==1
    varargout{1} = cell2mat_(cmrFet);
else
    varargout = cmrFet;
end
end %func


%--------------------------------------------------------------------------
function [trWav2, mrWav_ref] = spkwav_car_(trWav2, P, nSites_spk, viSite2_spk)
%function [trWav2, mrWav_ref] = trWav_car_sort_(trWav2, P)
%  trWav2: nT x nSpk x nSites, single
fMeanSubt = 0;
if nargin<3, nSites_spk = []; end
if nargin<4, viSite2_spk = []; end
vcSpkRef = get_set_(P, 'vcSpkRef', 'nmean');
if strcmpi(vcSpkRef, 'nmean')
    fSort_car = 1;
else
    fSort_car = -1; % no local subtraction
end
% fSort_car = get_set_(P, 'fSort_car', 1);
if isempty(nSites_spk)
    nSites_spk = 1 + 2 * P.maxSite - P.nSites_ref; % size(tnWav_spk, 2);
end
if nSites_spk==1, mrWav_ref=[]; return; end

% if P.nSites_ref==0, fSort_car = -1; end
% nSites_spk = 1 + 2 * P.maxSite; % size(tnWav_spk, 2);
dimm1 = size(trWav2);
[nT_spk, nSpk] = deal(dimm1(1), dimm1(2));
switch fSort_car
    case 1 % use n sites having the least SD as reference sites
        if isempty(viSite2_spk)
%             viSite_ref_ = 2:nSites_spk;
%             viSite_ref_ = ceil(nSites_spk/2):nSites_spk;
            viSite_ref_ = ceil(size(trWav2,3)/2):size(trWav2,3);
            mrWav_ref = mean(trWav2(:,:,viSite_ref_), 3);
        else
            trWav3 = trWav2(:,:,1:nSites_spk);
            trWav3(:,:,1) = 0;
            for iSpk1 = 1:numel(viSite2_spk)
                trWav3(:,iSpk1,viSite2_spk(iSpk1)) = 0;
            end
            mrWav_ref = sum(trWav3, 3) / (nSites_spk-2);
        end
    case 3
        mrWav_ref = mean(trWav2(:,:,2:end), 3);
    case 2
        [~, miSites_ref] = sort(squeeze_(var(trWav2)), 2, 'descend'); % use lest activities for ref
        %miSites_ref = miSites_ref(:,nSites_spk+1:end);
        miSites_ref = miSites_ref(:,3:nSites_spk);
        ti_dimm1 = repmat((1:nT_spk)', [1, nSpk, P.nSites_ref]);
        ti_dimm2 = repmat(1:nSpk, [nT_spk,1,P.nSites_ref]);
        ti_dimm3 = repmat(shiftdim(miSites_ref,-1), [nT_spk,1,1]);
        mrWav_ref = mean(trWav2(sub2ind(size(trWav2), ti_dimm1, ti_dimm2, ti_dimm3)),3);
    case 0
        mrWav_ref = mean(trWav2(:,:,nSites_spk+1:end), 3);
    case 4
        mrWav_ref = mean(trWav2(:,:,1:nSites_spk), 3);
    case 5
        mrWav_ref = mean(trWav2(:,:,2:end), 3);        
    case -1
        mrWav_ref = [];
end
trWav2 = trWav2(:,:,1:nSites_spk);
dimm2 = size(trWav2);
if ismatrix(trWav2), dimm2(end+1) = 1; end
if ~isempty(mrWav_ref)
    trWav2 = reshape(bsxfun(@minus, reshape(trWav2,[],dimm2(3)), mrWav_ref(:)), dimm2);
end
if fMeanSubt, trWav2 = meanSubt_spk_(trWav2); end
end %func


%--------------------------------------------------------------------------
function mr_ref = tr_sort_ref_(trWav_spk1, viSites_ref)
%  trWav_spk1: nT x nSpk x nSites, single
fUseMin = 0;
dimm1 = size(trWav_spk1);
tr0 = gather_(trWav_spk1);
%tr = permute(gather_(trWav_spk1), [3,1,2]);
mr_ref = zeros(dimm1([1,2]), 'like', tr0);
if fUseMin
    P = get0_('P');
    iT0 = 1 - P.spkLim(1);
    [~, miSites_ref] = sort(permute(tr0(iT0,:,:), [3,2,1]), 'ascend');
else % use std
    [~, miSites_ref] = sort(permute(var(tr0), [3,2,1]), 'descend'); % use lest activities for ref
end
miSites_ref = miSites_ref(viSites_ref,:);
for iSpk1=1:dimm1(2)
    %mr_ref(:,iSpk1) = mean(tr(miSites_ref(:,iSpk1),:,iSpk1));
    mr_ref(:,iSpk1) = mean(tr0(:,iSpk1,miSites_ref(:,iSpk1)), 3);
end
end %func


%--------------------------------------------------------------------------
function vr = mr2vr_sub2ind_(mr, vi1, vi2)
if isempty(mr), vr = []; return; end
if nargin<3, vi2=[]; end
if isempty(vi1), vi1 = 1:size(mr,1); end
if isempty(vi2), vi2 = 1:size(mr,2); end
vr = mr(sub2ind(size(mr), vi1(:), vi2(:)));
end %func


%--------------------------------------------------------------------------
function [fid, nBytes, header_offset] = fopen_(vcFile, vcMode)
if nargin < 2, vcMode = 'r'; end
try
    if matchFileExt_(vcFile, {'.ns5', '.ns2'})
        [fid, nBytes, header_offset] = fopen_nsx_(vcFile);
    else
        fid = fopen(vcFile, vcMode);
        nBytes = getBytes_(vcFile);   
        header_offset = 0;
    end
catch
    disperr_();
    fid = []; 
    nBytes = [];
end
end %func



%--------------------------------------------------------------------------
% 1/18/2018 JJJ: fixed GPU error problem. return 
function nBytes = mem_max_(P)
% Return available memory
if nargin<0, P = get0_('P'); end
fGpu = get_set_(P, 'fGpu', 0);

load_factor = 16;
if fGpu
    try
        S_gpu = gpuDevice(1);
%         load_factor = load_factor * get_set_(P, 'nLoads_gpu', 8);
        nBytes_gpu = floor(S_gpu.AvailableMemory / load_factor);
    catch
        fGpu = 0;
    end
end
S = memory_();
nBytes = floor(S.MaxPossibleArrayBytes / load_factor);
if fGpu, nBytes = min(nBytes, nBytes_gpu); end
% 
% if fGpu
%     try
%         S = gpuDevice(); % does not reset GPU
%         nBytes = floor(S(1).AvailableMemory());
%         nBytes = floor(nBytes / get_set_(P, 'nLoads_gpu', 16));
%     catch
%         fGpu = 0;
%     end
% end
% if ~fGpu
end %func


%--------------------------------------------------------------------------
% 17/12/1 JJJ: Load size is not limited by FFT cleanup process (fft_thresh>0)
function [nLoad1, nSamples_load1, nSamples_last1] = plan_load_(nBytes_file, P)
% plan load file size according to the available memory and file size (nBytes_file1)
% LOAD_FACTOR = 8; % Memory usage overhead

nSamples1 = floor(nBytes_file / bytesPerSample_(P.vcDataType) / P.nChans);
% nSamples_max = floor(mem_max_(P) / P.nChans / 4); % Bound by MAX_BYTES_LOAD
if ~isfield(P, 'MAX_BYTES_LOAD'), P.MAX_BYTES_LOAD = []; end
if isempty(P.MAX_BYTES_LOAD), P.MAX_BYTES_LOAD = floor(mem_max_(P)); end
if isempty(P.MAX_LOAD_SEC)
   nSamples_max = floor(P.MAX_BYTES_LOAD / P.nChans / bytesPerSample_(P.vcDataType));
else
    nSamples_max = floor(P.sRateHz * P.MAX_LOAD_SEC);
end

if ~P.fTranspose_bin %load all in one, Catalin's format
    [nLoad1, nSamples_load1, nSamples_last1] = deal(1, nSamples1, nSamples1);
else
    [nLoad1, nSamples_load1, nSamples_last1] = partition_load_(nSamples1, nSamples_max);
end
end %func


%--------------------------------------------------------------------------
function [nLoad1, nSamples_load1, nSamples_last1] = partition_load_(nSamples1, nSamples_max)
nLoad1 = setlim_(ceil(nSamples1 / nSamples_max), [1, inf]); 
nSamples_load1 = min(nSamples1, nSamples_max);
if nLoad1 == 1
    nSamples_load1 = nSamples1;
    nSamples_last1 = nSamples1;
else
    nSamples_last1 = mod(nSamples1, nSamples_load1);
    if nSamples_last1==0
        nSamples_last1 = nSamples_load1;
    elseif nSamples_last1 < nSamples_load1/2
        % if last part is too small increase the size
        nLoad1 = nLoad1 - 1;
        nSamples_last1 = nSamples_last1 + nSamples_load1;
    end
end
end %func


%--------------------------------------------------------------------------
% 17/9/13 JJJ: Created and tested
function vr = setlim_(vr, lim_)
% Set low and high limits
vr = min(max(vr, lim_(1)), lim_(2));
end %func


%--------------------------------------------------------------------------
function mnWav1 = load_file_preview_(fid_bin, P)
% preview
if P.nPad_filt > 0
    [mnWav1, dimm_wav] = load_file_(fid_bin, P.nPad_filt, P);
    frewind_(fid_bin, dimm_wav, P.vcDataType);
else
    mnWav1 = [];
end
end %func


%--------------------------------------------------------------------------
% 1/18/2018 JJJ: vrWav_mean1 output removed
function [mnWav1, dimm_wav] = load_file_(fid_bin, nSamples_load1, P, fSingle)
% load file to memory. 
% [Input]
% fid_bin: file ID or file name
% nSamples_load1: Number of samples to load 
%
% [Output]
% mnWav1: int16 (# samples/chan x chan)
% vrWav_mean1: average across chan output

if ischar(fid_bin)
    vcFile = fid_bin;
    if ~exist_file_(vcFile)
        error('File does not exist: %s\n', vcFile);
    end    
    [fid_bin, nBytes_file1] = fopen_(vcFile, 'r');
    if ~isempty(get_(P, 'header_offset'))
        nBytes_file1 = nBytes_file1 - P.header_offset;
        fseek(fid_bin, P.header_offset, 'bof');
    end
    nSamples_load1 = floor(nBytes_file1 / P.nChans / bytesPerSample_(P.vcDataType));    
else
    vcFile = '';
end
if nargin<4, fSingle = 0; end

if P.fTranspose_bin
    dimm_wav = [P.nChans, nSamples_load1];    
else %Catalin's format
    dimm_wav = [nSamples_load1, P.nChans];
end
mnWav1 = fread_(fid_bin, dimm_wav, P.vcDataType);
% [mnWav1, P.fGpu] = gpuArray_(mnWav1, P.fGpu);
switch(P.vcDataType)
    case 'uint16', mnWav1 = int16(single(mnWav1)-2^15);
    case {'float', 'float32', 'float64', 'single', 'double'}, mnWav1 = int16(mnWav1 / P.uV_per_bit);
end
if get_(P, 'fInverse_file'), mnWav1 = -mnWav1; end %flip the polarity

% extract channels
viSite2Chan = get_(P, 'viSite2Chan');
if P.fTranspose_bin
    if ~isempty(viSite2Chan), mnWav1 = mnWav1(viSite2Chan,:);  end
    mnWav1 = mnWav1';
else %Catalin's format. time x nChans
    if ~isempty(viSite2Chan), mnWav1 = mnWav1(:,viSite2Chan); end
    if ~isempty(get_(P, 'tlim_load'))
        nSamples = size(mnWav1,1);
        nlim_load = min(max(round(P.tlim_load * P.sRateHz), 1), nSamples);
        mnWav1 = mnWav1(nlim_load(1):nlim_load(end), :);
    end
end
%     vrWav_mean1 = single(mean(mnWav1, 2)');
if fSingle, mnWav1 = single(mnWav1) * P.uV_per_bit; end
if ~isempty(vcFile), fclose(fid_bin); end
end %func


%--------------------------------------------------------------------------
function varargout = get_(varargin)
% retrieve a field. if not exist then return empty
% [val1, val2] = get_(S, field1, field2, ...)

if nargin==0, varargout{1} = []; return; end
S = varargin{1};
if isempty(S), varargout{1} = []; return; end

for i=2:nargin
    vcField = varargin{i};
    try
        varargout{i-1} = S.(vcField);
    catch
        varargout{i-1} = [];
    end
end
end %func


%--------------------------------------------------------------------------
function [P, vcFile_prm] = loadParam_(vcFile_prm, fEditFile)
% Load prm file

if nargin<2, fEditFile = 0; end
assert(exist_file_(vcFile_prm), sprintf('.prm file does not exist: %s\n', vcFile_prm));
P0 = file2struct_(ircpath_(read_cfg_('default_prm', 0)));  %P = defaultParam();
P = file2struct_(vcFile_prm);
if ~isfield(P, 'template_file'), P.template_file = ''; end
if ~isempty(P.template_file)
    assert_(exist_file_(P.template_file), sprintf('template file does not exist: %s', P.template_file));
    P = struct_merge_(file2struct_(P.template_file), P);
end
P.vcFile_prm = vcFile_prm;
assert_(isfield(P, 'vcFile'), sprintf('Check "%s" file syntax', vcFile_prm));

if ~exist_file_(P.vcFile) && isempty(get_(P, 'csFile_merge'))
    P.vcFile = replacePath_(P.vcFile, vcFile_prm);
    if ~exist_file_(P.vcFile)
        fprintf('vcFile not specified. Assuming multi-file format ''csFiles_merge''.\n');
    end
end


%-----
% Load prb file
if ~isfield(P, 'probe_file'), P.probe_file = P0.probe_file; end
try    
    probe_file_ = find_prb_(P.probe_file);
    if isempty(probe_file_)
        P.probe_file = replacePath_(P.probe_file, vcFile_prm); 
        assert_(exist_file_(P.probe_file), 'prb file does not exist');
    else
        P.probe_file = probe_file_;
    end
    P0 = load_prb_(P.probe_file, P0);
catch
    fprintf('loadParam: %s not found.\n', P.probe_file);
end
P = struct_merge_(P0, P);    
P = calc_maxSite_(P);
if fEditFile
    fprintf('Auto-set: maxSite=%0.1f, nSites_ref=%0.1f\n', P.maxSite, P.nSites_ref);    
end

% check GPU
P.fGpu = ifeq_(license('test', 'Distrib_Computing_Toolbox'), P.fGpu, 0);
if P.fGpu, P.fGpu = ifeq_(gpuDeviceCount()>0, 1, 0); end

% Legacy support
if isfield(P, 'fTranspose'), P.fTranspose_bin = P.fTranspose; end

% Compute fields
P = struct_default_(P, 'fWav_raw_show', 0);
P = struct_default_(P, 'vcFile_prm', subsFileExt_(P.vcFile, '.prm'));
P = struct_default_(P, 'vcFile_gt', '');
% if isempty(get_(P, 'vcFile_gt')) % explicitly specify the ground truth
% files
%     P.vcFile_gt = subsFileExt_(P.vcFile_prm, '_gt.mat'); 
% end
P.spkRefrac = round(P.spkRefrac_ms * P.sRateHz / 1000);
P.spkLim = round(P.spkLim_ms * P.sRateHz / 1000);
P.spkLim_raw = calc_spkLim_raw_(P);

if isempty(get_(P, 'nDiff_filt'))
    if isempty(get_(P, 'nDiff_ms_filt'))
        P.nDiff_filt = 0;
    else
        P.nDiff_filt = ceil(P.nDiff_ms_filt * P.sRateHz / 1000);
    end
end
if ~isempty(get_(P, 'viChanZero')) && isempty(P.viSiteZero)
    [~, viSiteZero] = ismember(P.viChanZero, P.viSite2Chan);
    P.viSiteZero = viSiteZero(viSiteZero>0);
end
if ~isempty(get_(P, 'viSiteZero')), P.viSiteZero(P.viSiteZero > numel(P.viSite2Chan)) = []; end
if ~isfield(P, 'viShank_site'), P.viShank_site = []; end
try P.miSites = findNearSites_(P.mrSiteXY, P.maxSite, P.viSiteZero, P.viShank_site); catch; end %find closest sites
% LFP sampling rate
if ~isempty(get_(P, 'nSkip_lfp'))
    P.sRateHz_lfp = P.sRateHz / P.nSkip_lfp;
else
    P.sRateHz_lfp = get_set_(P, 'sRateHz_lfp', 2500);
    P.nSkip_lfp = round(P.sRateHz / P.sRateHz_lfp);
end
P.bytesPerSample = bytesPerSample_(P.vcDataType);
P = struct_default_(P, 'vcFile_prm', subsFileExt_(P.vcFile, '.prm'));
if ~isempty(get_(P, 'gain_boost')), P.uV_per_bit = P.uV_per_bit / P.gain_boost; end
P.spkThresh = P.spkThresh_uV / P.uV_per_bit;
P = struct_default_(P, 'cvrDepth_drift', {});
P = struct_default_(P, {'maxSite_fet', 'maxSite_detect', 'maxSite_sort','maxSite_pix', 'maxSite_dip', 'maxSite_merge', 'maxSite_show'}, P.maxSite);
P = struct_default_(P, 'mrColor_proj', [.75 .75 .75; 0 0 0; 1 0 0]);
P.mrColor_proj = reshape(P.mrColor_proj(:), [], 3); %backward compatible
P = struct_default_(P, {'blank_thresh', 'thresh_corr_bad_site', 'tlim_load'}, []);
if numel(P.tlim)==1, P.tlim = [0, P.tlim]; end
if isfield(P, 'rejectSpk_mean_thresh'), P.blank_thresh = P.rejectSpk_mean_thresh; end
P.vcFilter = get_filter_(P);
if isempty(get_(P, 'vcFilter_show'))
    P.vcFilter_show = P.vcFilter;
end
assert_(validate_param_(P), 'Parameter file contains error.');
if fEditFile, edit_(P.vcFile_prm); end % Show settings file
end %func


%--------------------------------------------------------------------------
function spkLim_raw = calc_spkLim_raw_(P)
% Calculate the raw spike waveform range

spkLim_raw_ms = get_(P, 'spkLim_raw_ms');
if isempty(spkLim_raw_ms)
    spkLim = round(P.spkLim_ms * P.sRateHz / 1000);
    spkLim_raw = spkLim * get_set_(P, 'spkLim_raw_factor', 2); % backward compatible
else
    spkLim_raw = round(P.spkLim_raw_ms * P.sRateHz / 1000);
end
end %func


%--------------------------------------------------------------------------
% 10/25/17 JJJ: Created and tested
function P = calc_maxSite_(P)
% Auto determine maxSite from the radius and site ifno
nSites = numel(P.viSite2Chan);
P.maxSite = min(get_(P, 'maxSite'), (nSites-1)/2);   
P.nSites_ref = get_(P, 'nSites_ref');
if ~isempty(P.maxSite) && ~isempty(P.nSites_ref), return; end
mrDist_site = pdist2(P.mrSiteXY, P.mrSiteXY);
maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
nSites_fet = max(sum(mrDist_site <= maxDist_site_um)); % 11/7/17 JJJ: med to max
if isempty(P.nSites_ref) 
    maxDist_site_spk_um = get_set_(P, 'maxDist_site_spk_um', maxDist_site_um+25);        
    nSites_spk = max(sum(mrDist_site <= maxDist_site_spk_um)); % 11/7/17 JJJ: med to max
    maxSite = (nSites_spk-1)/2;
    P.nSites_ref = nSites_spk - nSites_fet;
else        
    nSites_spk = nSites_fet + P.nSites_ref;
    maxSite = (nSites_spk-1)/2;
end

if isempty(P.maxSite), P.maxSite = maxSite; end
% fprintf('Auto-set: maxSite=%0.1f, nSites_ref=%0.1f\n', P.maxSite, P.nSites_ref);
end %func


%--------------------------------------------------------------------------
% 9/27/17 JJJ: Created and tested
function vcFilter = get_filter_(P)
if isfield(P, 'vcFilter')
    vcFilter = P.vcFilter;
else
    if get_(P, 'nDiff_filt') > 0
        vcFilter = 'sgdiff'; %sgdiff?
    else
        vcFilter = 'bandpass';
    end
end
end %func


%--------------------------------------------------------------------------
function [viSpk, vrSpk, viSite] = spikeMerge_(cviSpk, cvrSpk, P)
% provide spike index (cviSpk) and amplitudes (cvrSPk) per sites

nSites = numel(cviSpk);
viSpk = cell2mat_(cviSpk);      vrSpk = cell2mat_(cvrSpk);
viSite = cell2mat_(cellfun(@(vi,i)repmat(i,size(vi)), cviSpk, num2cell((1:nSites)'), 'UniformOutput', false));
[viSpk, viSrt] = sort(viSpk);   vrSpk = vrSpk(viSrt);   viSite = viSite(viSrt);
viSite = int32(viSite); 
viSpk = int32(viSpk);   

[cviSpkA, cvrSpkA, cviSiteA] = deal(cell(nSites,1));
fParfor = get_set_(P, 'fParfor', 1);
if fParfor
    try
        parfor iSite = 1:nSites %parfor speedup: 2x %parfor
            try
                [cviSpkA{iSite}, cvrSpkA{iSite}, cviSiteA{iSite}] = ...
                    spikeMerge_single_(viSpk, vrSpk, viSite, iSite, P);            
            catch
                fprint(2, 'Parfor error, retrying using a single thread.\n');
            end
        end
    catch
        fParfor = 0; 
    end
end %if
if ~fParfor
    for iSite = 1:nSites
        try
            [cviSpkA{iSite}, cvrSpkA{iSite}, cviSiteA{iSite}] = ...
                spikeMerge_single_(viSpk, vrSpk, viSite, iSite, P);            
        catch
            disperr_();
        end
    end
end

% merge parfor output and sort
viSpk = cell2mat_(cviSpkA);
vrSpk = cell2mat_(cvrSpkA);
viSite = cell2mat_(cviSiteA);
[viSpk, viSrt] = sort(viSpk); %sort by time
vrSpk = gather_(vrSpk(viSrt));
viSite = viSite(viSrt);
end %func


%--------------------------------------------------------------------------
function [viSpkA, vrSpkA, viSiteA] = spikeMerge_single_1_(viSpk, vrSpk, viSite, iSite, P)

maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
nPad_pre = get_set_(P, 'nPad_pre', 0);
nRefrac = int32(abs(P.spkRefrac));
spkLim = [-nRefrac, nRefrac];

% filter local sites only
vii1 = find(viSite == iSite);
viSpk1 = viSpk(vii1);
vrSpk1 = vrSpk(vii1);
viSiteNear = findNearSite_(P.mrSiteXY, iSite, maxDist_site_um);
vi2 = find(ismember(viSite, viSiteNear));
viSpk2 = viSpk(vi2); 
vrSpk2 = vrSpk(vi2);
viSite2 = viSite(vi2);
n2 = numel(viSpk2);
    
vlSpk1 = false(size(viSpk1));
i2prev = 1;
for iSpk1=1:numel(viSpk1)
    iSpk11 = viSpk1(iSpk1);
    rSpk11 = vrSpk1(iSpk1); 

    % check for duplicate detection. search nearby spikes
    spkLim11 = iSpk11 + spkLim;
    [vii2, i2prev] = findRange_(viSpk2, spkLim11(1), spkLim11(2), i2prev, n2); 
    if numel(vii2)==1, vlSpk1(iSpk1) = 1; continue; end %no other spikes detected
    vrSpk22 = vrSpk2(vii2);

    %invalid if larger (more negative) spike found
    if any(vrSpk22 < rSpk11), continue; end %wouldn't work for biopolar spike

    % check for equal amplitude, pick first occured
    vii22Eq = find(vrSpk22 == rSpk11);
    if numel(vii22Eq) > 1
        viSpk22 = viSpk2(vii2);
        viSpk222 = viSpk22(vii22Eq);
        minTime = min(viSpk222);
        if minTime ~= iSpk11, continue; end 
        if sum(minTime == viSpk222) > 1 %pick lower site
            viSite22 = viSite2(vii2);
            if min(viSite22(vii22Eq)) ~= iSite, continue; end
        end
    end
    vlSpk1(iSpk1) = 1; % set this spike as valid
end %for

% Trim
viiSpk1 = find(vlSpk1); %speed up since used multiple times
viSpkA = viSpk1(viiSpk1);
vrSpkA = vrSpk1(viiSpk1);
viSiteA = repmat(int32(iSite), size(viiSpk1));
% fprintf('.'); %progress. how about within parfor?

% apply spike merging on the same site
% if ~isempty(refrac_factor) && refrac_factor~=0
%     nRefrac2 = int32(double(nRefrac) * refrac_factor);
%     [viSpkA, vrSpkA, viSiteA] = spike_refrac_(viSpkA, vrSpkA, viSiteA, nRefrac2); %same site spikes
% end
end %func


%--------------------------------------------------------------------------
function [viTime_spk2, vnAmp_spk2, viSite_spk2] = spikeMerge_single_(viTime_spk, vnAmp_spk, viSite_spk, iSite1, P)
% maxDist_site_um = get_set_(P, 'maxDist_site_spk_um', 75);
maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
nlimit = int32(abs(P.spkRefrac));
% spkLim = [-nlimit, nlimit];

% Find spikes from site 1
viSpk1 = int32(find(viSite_spk == iSite1)); % pre-cache
[viTime_spk1, vnAmp_spk1] = deal(viTime_spk(viSpk1), vnAmp_spk(viSpk1));

% Find neighboring spikes
viSite1 = findNearSite_(P.mrSiteXY, iSite1, maxDist_site_um);
viSpk12 = int32(find(ismember(viSite_spk, viSite1)));

% Coarse selection
% viTime_spk12 = viTime_spk(viSpk12);
% [viTbin_spk1, viTbin_spk12] = multifun_(@(x)int32(round(double(x)/double(nlimit))), viTime_spk1, viTime_spk12);
% vlKeep12 = ismember(viTbin_spk12, viTbin_spk1) | ismember(viTbin_spk12, viTbin_spk1+1) | ismember(viTbin_spk12, viTbin_spk1-1);
% viSpk12 = viSpk12(vlKeep12);

[viTime_spk12, vnAmp_spk12, viSite_spk12] = deal(viTime_spk(viSpk12), vnAmp_spk(viSpk12), viSite_spk(viSpk12));

% Fine selection
vlKeep_spk1 = true(size(viSpk1));
for iDelay = -nlimit:nlimit    
    [vi12_, vi1_] = ismember(viTime_spk12, viTime_spk1 + iDelay);    
    vi12_ = find(vi12_);
    if iDelay == 0 % remove self if zero delay
        vi12_(viSpk12(vi12_) == viSpk1(vi1_(vi12_))) = [];
    end
    vi12_(vnAmp_spk12(vi12_) > vnAmp_spk1(vi1_(vi12_))) = []; % keep more negative spikes
    vlAmpEq = vnAmp_spk12(vi12_) == vnAmp_spk1(vi1_(vi12_));
    if any(vlAmpEq)
        if iDelay > 0 % spk1 occurs before spk12, thus keep 
            vi12_(vlAmpEq) = [];
        elseif iDelay == 0 % keep only if site is lower
            vlAmpEq(iSite1 > viSite_spk12(vi12_(vlAmpEq))) = 0;
            vi12_(vlAmpEq) = []; %same site same time same ampl is not possible
        end
    end
    vlKeep_spk1(vi1_(vi12_)) = 0;
end %for

% Keep the peak spikes only
viiSpk1 = find(vlKeep_spk1); %speed up since used multiple times
[viTime_spk2, vnAmp_spk2] = deal(viTime_spk1(viiSpk1), vnAmp_spk1(viiSpk1));
viSite_spk2 = repmat(int32(iSite1), size(viiSpk1));
end %func


%--------------------------------------------------------------------------
function viSiteNear = findNearSite_(mrSiteXY, iSite, maxDist_site_um)
vrDist = pdist2_(mrSiteXY(iSite,:), mrSiteXY);
viSiteNear = find(vrDist <= maxDist_site_um);
end %func


%--------------------------------------------------------------------------
function [vlKeep_ref, vrMad_ref] = car_reject_(vrWav_mean1, P)
blank_period_ms = get_set_(P, 'blank_period_ms', 5); 
blank_thresh = get_set_(P, 'blank_thresh', []);
[vlKeep_ref, vrMad_ref] = deal([]);
% if isempty(blank_thresh) || blank_thresh==0, return; end

% tbin_ref = .01; %10 msec bin
vrWav_mean1 = single(vrWav_mean1);
nwin = round(P.sRateHz * blank_period_ms / 1000);
if nwin <= 1
    if nargout < 2
        vlKeep_ref = thresh_mad_(abs(vrWav_mean1), blank_thresh);
    else
        [vlKeep_ref, vrMad_ref] = thresh_mad_(abs(vrWav_mean1), blank_thresh);
    end
else
    vrRef_bin = std(reshape_vr2mr_(vrWav_mean1, nwin), 1,1);
    if nargout < 2
        vlKeep_ref = thresh_mad_(vrRef_bin, blank_thresh);
    else
        [vlKeep_ref, vrMad_ref] = thresh_mad_(vrRef_bin, blank_thresh);        
        vrMad_ref = expand_vr_(vrMad_ref, nwin, size(vrWav_mean1));
    end
    vlKeep_ref = expand_vr_(vlKeep_ref, nwin, size(vrWav_mean1));
end
% figure; plot(vrMad_ref); hold on; plot(find(~vlKeep_ref), vrMad_ref(~vlKeep_ref), 'r.')
end %func


%--------------------------------------------------------------------------
% 8/16/17 JJJ: created and tested
function vr1 = expand_vr_(vr, nwin, dimm1);
if nargin<3, dimm1 = [numel(vr) * nwin, 1]; end
if islogical(vr)
    vr1 = false(dimm1);
else
    vr1 = zeros(dimm1, 'like', vr);
end
vr = repmat(vr(:)', [nwin, 1]);
vr = vr(:);
[n,n1] = deal(numel(vr), numel(vr1));
if n1 > n
    vr1(1:n) = vr;
    vr1(n+1:end) = vr1(n);
elseif numel(vr1) < n
    vr1 = vr(1:n1);
else
    vr1 = vr;
end
end %func


%--------------------------------------------------------------------------
function flag = is_detected_(P)
% return true if already detected. .spkwav file must exist

[vcFile_jrc_mat, vcFile_spkwav, vcFile3, vcFile4] = ...
    subsFileExt_(P.vcFile_prm, '_jrc.mat', '_spkwav.jrc', '_spkraw.jrc', '_spkfet.jrc');    
flag = all(exist_file_({vcFile_jrc_mat, vcFile_spkwav, vcFile3, vcFile4}));

% flag = all(exist_file_({vcFile_spkwav, vcFile_jrc_mat, vcFile_fet}));
% if flag, flag = getBytes_(vcFile_spkwav) > 0; end
end %func


%--------------------------------------------------------------------------
function flag = is_sorted_(P)
% return true if already detected. .spkwav file must exist
flag = 0;

try    
    [vcFile_jrc, vcFile2, vcFile3, vcFile4] = ...
        subsFileExt_(P.vcFile_prm, '_jrc.mat', '_spkwav.jrc', '_spkraw.jrc', '_spkfet.jrc');    
    if ~all(exist_file_({vcFile_jrc, vcFile2, vcFile3, vcFile4})), return; end
    
    csNames = whos('-file', vcFile_jrc);
    csNames = {csNames.name};
    flag = ismember('S_clu', csNames);
catch    
    return;
end

% S0 = load0_();
% S_clu = get_(S0, 'S_clu');
% flag = ~isempty(S_clu);
end %func


%--------------------------------------------------------------------------
% 12/28/17 JJJ: Support for cviShank added (reintroduced in v3.2.1)
% 9/26/17 JJJ: Added prb directory
function P = load_prb_(vcFile_prb, P)
% P = load_prb_(vcFile_prb)
% P = load_prb_(vcFile_prb, P)

% append probe file to P
if nargin<2, P = []; end

% Find the probe file
vcFile_prb = find_prb_(vcFile_prb);
if isempty(vcFile_prb)
    error(['Probe file does not exist: ', vcFile_prb]);
end

P.probe_file = vcFile_prb;
%     [P.viSite2Chan, P.mrSiteXY, P.vrSiteHW, P.cviShank] = read_prb_file(vcFile_prb);
S_prb = file2struct_(vcFile_prb);
S_prb.pad = get_set_(S_prb, 'pad', [12 12]);
P.viSite2Chan = S_prb.channels;
P.mrSiteXY = S_prb.geometry;
if size(P.mrSiteXY,2)~=2
    try
        P.mrSiteXY = reshape(P.mrSiteXY(:), 2, [])'; 
    catch
        error(['Invalid probe file format: geometry dimension error: ', vcFile_prb]);
    end
end
P.vrSiteHW = S_prb.pad;
shank = get_(S_prb, 'shank');
cviShank = get_(S_prb, 'cviShank');
if isempty(shank) && ~isempty(cviShank), shank = cviShank; end
if isempty(shank)
    P.viShank_site = ones(size(S_prb.channels));     
elseif iscell(shank)
    P.viShank_site = cell2mat(arrayfun(@(i)i*ones(size(shank{i})), 1:numel(shank), 'UniformOutput', 0));
    assert(numel(P.viShank_site) == numel(S_prb.channels), 'cviShank must index all sites');
else
    P.viShank_site = S_prb.shank;
end
S_prb = remove_struct_(S_prb, 'channels', 'geometry', 'pad', 'ref_sites', ...
    'viHalf', 'i', 'vcFile_file2struct', 'shank', 'cviShank');

% P = copyStruct_(P, S_prb, {'cviShank', 'maxSite', 'um_per_pix'});
if isfield(P, 'nChans')
    P.viChan_aux = setdiff(1:P.nChans, 1:max(P.viSite2Chan)); %aux channel. change for
else
    P.viChan_aux = [];
end
P = struct_merge_(P, S_prb);
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Created and tested
function vcFile = search_file_(vcFile, csDir)
% Search file in the provided directory location if it doesn't exist
if exist_file_(vcFile), return ;end

if ischar(csDir), csDir = {csDir}; end
for iDir = 1:numel(csDir)
    vcFile_ = subsDir_(vcFile, csDir{iDir});
    if exist_file_(vcFile_)
        vcFile = vcFile_;
        return;
    end
end
vcFile = []; % file not found
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Created and tested
function vcFile_new = subsDir_(vcFile, vcDir_new)
% vcFile_new = subsDir_(vcFile, vcFile_copyfrom)
% vcFile_new = subsDir_(vcFile, vcDir_copyfrom)

% Substitute dir
if isempty(vcDir_new), vcFile_new = vcFile; return; end

[vcDir_new,~,~] = fileparts(vcDir_new); % extrect directory part. danger if the last filesep() doesn't exist
[vcDir, vcFile, vcExt] = fileparts(vcFile);
vcFile_new = fullfile(vcDir_new, [vcFile, vcExt]);
end % func


%--------------------------------------------------------------------------
function S = remove_struct_(S, varargin)
% remove fields from a struct
for i=1:numel(varargin)
    if isfield(S, varargin{i})
        S = rmfield(S, varargin{i});
    end
end
end %func


%--------------------------------------------------------------------------
% 9/13/17 JJJ: Edge case error fixed (vi2 indexing) for small block many loads
% 8/17/17 JJJ: fix for missing spikes
function viSpk1 = find_peak_(vrWav1, thresh1, nneigh_min)
% nneigh_min: number of neighbors around the spike below the threshold
%  0,1,2. # neighbors of minimum point below negative threshold 
% thresh1: absolute value. searching for negative peaks only

if nargin<3, nneigh_min = []; end
if isempty(nneigh_min), nneigh_min = 1; end

viSpk1 = [];
if isempty(vrWav1), return; end
vl1 = vrWav1 < -abs(thresh1);
vi2 = find(vl1);
%vi2 = find(vrWav1 < -thresh1);
if isempty(vi2), return; end

if vi2(1)<=1
    if numel(vi2) == 1, return; end
    vi2(1) = []; 
end    
if vi2(end)>=numel(vrWav1)
    if numel(vi2) == 1, return; end
    vi2(end) = []; 
end
vrWav12 = vrWav1(vi2);
viSpk1 = vi2(vrWav12 <= vrWav1(vi2+1) & vrWav12 <= vrWav1(vi2-1));
if isempty(viSpk1), return; end
% viSpk1 = vi2(find(diff(diff(vrWav1(vi2))>0)>0) + 1); % only negative peak

% if viSpk1(1) <= 1, viSpk1(1) = 2; end
% if viSpk1(end) >= numel(vrWav1), viSpk1(end) = numel(vrWav1)-1; end
switch nneigh_min
    case 1
        viSpk1 = viSpk1(vl1(viSpk1-1) | vl1(viSpk1+1));
%         viSpk1 = viSpk1(vrWav1(viSpk1-1) < -thresh1 | vrWav1(viSpk1+1) < -thresh1);
    case 2
        viSpk1 = viSpk1(vl1(viSpk1-1) & vl1(viSpk1+1));
%         viSpk1 = viSpk1(vrWav1(viSpk1-1) < -thresh1 & vrWav1(viSpk1+1) < -thresh1);
end
end %func


%--------------------------------------------------------------------------
function vr = cell2mat_(cvr)
% create a matrix that is #vectors x # cells
% remove empty
vi = find(cellfun(@(x)~isempty(x), cvr));
vr = cell2mat(cvr(vi));
end %func


%--------------------------------------------------------------------------
% 10/11/17 JJJ: new and faster. tested
function [vii, ic] = findRange_(vi, a, b, i, n)
% a: start value
% b: end value
% i: index of vi to start searching
% vii: index of vi that is between a and b
% vii = [];
ic = 1;
ia = 0;
vii = [];
if b < vi(1), return; end % exception condition added
if a > vi(end), ic = n; return; end
while 1
    v_ = vi(i);        
    if v_ < a, ic = i; end
    if ia==0
        if v_ >= a, ia = i; end
    else
        if v_ > b, ib = i-1; break; end
    end            
    if i<n
        i = i + 1;
    else
        ib = n;
        break;
    end    
end
if ia > 0
    vii = ia:ib;
end
end %func


%--------------------------------------------------------------------------
function dimm_mr = write_bin_(vcFile, mr)
t1=tic;
dimm_mr = size(mr);
fVerbose = 1;
if isempty(mr), return; end
if isstruct(mr)
    save(vcFile, '-struct', 'mr', '-v7.3'); % save to matlab file
else
    if ischar(vcFile)
        fid_w = fopen(vcFile, 'W'); 
    else
        fid_w = vcFile;
    end
    fwrite(fid_w, mr, class(mr));
    if ischar(vcFile)
        fclose(fid_w); 
    else
        fVerbose = 0;
    end
end
if fVerbose
    fprintf('Writing to %s took %0.1fs\n', vcFile, toc(t1));
end
end %func


%--------------------------------------------------------------------------
function write_struct_(vcFile, S)
% Write a struct S to file vcFile
try
    warning off
    t1=tic;    
%     S = struct_remove_handles(S); %remove figure handle
    save(vcFile, '-struct', 'S');
    fprintf('Wrote to %s, took %0.1fs.\n', vcFile, toc(t1));
catch
    fprintf(2, 'Writing struct to file %s failed.\n', vcFile);
end
end %func


%--------------------------------------------------------------------------
% 2018/6/1: Added support for .prm format
function mnWav = load_bin_(vcFile, vcDataType, dimm, header)
% mnWav = load_bin_(vcFile, dimm, vcDataType)
% mnWav = load_bin_(fid, dimm, vcDataType)
% mnWav = load_bin_(vcFile_prm)
% [Input arguments]
% header: header bytes

if nargin<2, vcDataType = []; end
if nargin<3, dimm = []; end
if nargin<4, header = 0; end
if isempty(vcDataType), vcDataType = 'int16'; end
mnWav = [];

if ischar(vcFile)
    if matchFileEnd_(vcFile, '.prm')
        vcFile_prm = vcFile;    
        if ~exist_file_(vcFile_prm, 1), return; end        
        P = loadParm_(vcFile_prm);
        [vcFile, vcDataType, header] = deal(P.vcFile, P.vcDataType, P.header);
        nBytes_file = filesize_(vcFile);
        nSamples_file = floor((nBytes_file - header) / bytesPerSample_(vcDataType));
        if P.fTranspose_bin
            dimm = [P.nChans, nSamples];
        else
            dimm = [nSamples, P.nChans];
        end
    end
    fid = []; 
    if ~exist_file_(vcFile, 1), return; end
    fid = fopen(vcFile, 'r');
    if header>0, fseek(fid, header, 'bof'); end
    if isempty(dimm) % read all
        S_file = dir(vcFile);
        if numel(S_file)~=1, return; end % there must be one file
        nData = floor((S_file(1).bytes - header) / bytesPerSample_(vcDataType));
        dimm = [nData, 1]; %return column
    end
else % fid directly passed
    fid = vcFile;
    if isempty(dimm), dimm = inf; end
end
try
    t1 = tic;
    mnWav = fread_(fid, dimm, vcDataType);
    if ischar(vcFile)
        fclose(fid);
        fprintf('Loading %s took %0.1fs\n', vcFile, toc(t1)); 
    end
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
function mnWav = load_bin_multi_(fid, cvi_lim_bin, P)
mnWav = cell(size(cvi_lim_bin));
fpos = 0;
for i=1:numel(cvi_lim_bin)
    lim1 = cvi_lim_bin{i};
    if i>1, fseek_(fid, lim1(1), P); end    
    mnWav{i} = load_bin_(fid, P.vcDataType, [P.nChans, diff(lim1)+1]);
    if i==1, fpos = ftell(fid); end
end %for
mnWav = cell2mat_(mnWav);
fseek(fid, fpos, 'bof'); % restore the file position
end %func


%--------------------------------------------------------------------------
function [vrY, vrY2] = centroid_mr_(mrVpp, vrYe, mode1)
% [vrX, vrY] = centroid_mr_(mrVpp, vrPos)
% [mrXY] = centroid_mr_(mrVpp, vrPos)
% mrVpp: nSites x nSpk

if nargin<3, mode1 = 1; end
if isrow(vrYe), vrYe = vrYe'; end
% mrVpp_sq = abs(mrVpp);
switch mode1    
    case 1
        mrVpp = abs(mrVpp);
    case 2
        mrVpp = mrVpp.^2; 
    case 3
        mrVpp = sqrt(abs(mrVpp)); 
    case 4
        mrVpp = mrVpp.^2; 
        mrVpp = bsxfun(@minus, mrVpp, min(mrVpp));   
end

vrVpp_sum = sum(mrVpp);
% vrX = sum(bsxfun(@times, mrVpp_sq, mrSiteXY(:,1))) ./  vrVpp_sq_sum;
vrY = sum(bsxfun(@times, mrVpp, vrYe)) ./  vrVpp_sum;
if nargout>=2
    vrY2 = sum(bsxfun(@times, mrVpp, vrYe.^2)) ./  vrVpp_sum;
    vrY2 = sqrt(abs(vrY2 - vrY.^2));
end
end %func


%--------------------------------------------------------------------------
function S_clu = fet2clu_(S0, P)
% can process different shanks separately
fprintf('Clustering\n');
vcCluster = get_set_(P, 'vcCluster', 'spacetime');
switch lower(vcCluster)
    case 'spacetime'
        S_clu = cluster_spacetime_(S0, P);        
    case 'drift'
        S_clu = cluster_drift_(S0, P);     
    case {'drift-knn' ,'knn'}
        S_clu = cluster_drift_knn_(S0, P);        
    case 'xcov' % waveform-covariance based clustering
        S_clu = cluster_xcov_(S0, P);
    otherwise
        error('fet2clu_: unsupported vcCluster: %s', vcCluster);
end
S_clu = postCluster_(S_clu, P);
fprintf('\tClustering took %0.1f s\n', S_clu.t_runtime);

fprintf('\nauto-merging...\n'); t_automerge=tic;
if get_set_(P, 'fRepeat_clu', 0), S_clu = S_clu_reclust_(S_clu, S0, P); end
S_clu = post_merge_(S_clu, P, 0);
t_automerge = toc(t_automerge);
fprintf('\n\tauto-merging took %0.1fs\n', t_automerge);
S_clu.viClu_auto = S_clu.viClu;
S_clu.t_automerge = t_automerge;
end %func


%--------------------------------------------------------------------------
function [vi1, vl1] = partition_vi_(vi, n, nBins, iBin)
lim1 = round([iBin-1, iBin] / nBins * n) + 1;
lim1 = min(max(lim1, 1), n+1);
vl1 = vi >= lim1(1) & vi < lim1(2);
vi1 = vi(vl1);
end %func


%--------------------------------------------------------------------------
function d = eucl2_dist_(X, Y)
% a: m x d1; b: m x d2
% aa=sum(a.*a,1); bb=sum(b.*b,1); ab=a'*b; 
% d = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab));
% X = [mrFet1_, mrFet2_];
d = bsxfun(@plus, sum(Y.^2), bsxfun(@minus, sum(X.^2)', 2*X'*Y));
end %func


%--------------------------------------------------------------------------
function S_clu = cluster_spacetime_(S0, P, vlRedo_spk, viSpk_drift)
% this clustering is natively suited for 2D electrode arrays and drifting dataset
% There is no x,y position in the clustering dataset
global trFet_spk
if ~isfield(P, 'CHUNK'), P.CHUNK = 16; end
if ~isfield(P, 'fTwoStep'), P.fTwoStep = 0; end
if ~isfield(P, 'mrSiteXY'), P.mrSiteXY = []; end
if ~isfield(P, 'min_count'), P.min_count = []; end
if nargin<3, vlRedo_spk=[]; end
if nargin<4, viSpk_drift=[]; end

% g = gpuDevice();
t_func = tic;
nSites = numel(P.viSite2Chan);
nSpk = numel(S0.viTime_spk);
vrRho = zeros(nSpk, 1, 'single');
vrDelta = zeros(nSpk, 1, 'single');   
viNneigh = zeros(nSpk, 1, 'uint32');
vrDc2_site = zeros(nSites, 1, 'single');
nTime_clu = get_set_(P, 'nTime_clu', 1);
P.nTime_clu = nTime_clu;
P.dc_subsample = 1000; 
P.knn = get_set_(P, 'knn', 0);

% clear memory
cuda_rho_();
cuda_delta_();
if get_set_(P, 'fDenoise_fet', 0)
    trFet_spk = denoise_fet_(trFet_spk, P, vlRedo_spk);
end

%-----
% Calculate dc2 (global)
if get_set_(P, 'fDc_global', 0)
    dc2 = calc_dc2_(S0, P, vlRedo_spk, viSpk_drift);
else
    dc2 = [];
end

%-----
% Calculate Rho
fprintf('Calculating Rho\n\t'); t1=tic;
for iSite = 1:nSites
    [mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_] = fet12_site_(trFet_spk, S0, P, iSite, vlRedo_spk, viSpk_drift);    
    if isempty(mrFet12_), continue; end 
    if P.fGpu
        [mrFet12_, viiSpk12_ord_] = deal(gpuArray_(mrFet12_), gpuArray_(viiSpk12_ord_));
    end
    if P.knn > 0
        dc2_ = 1;
    elseif isempty(dc2)
        dc2_ = compute_dc2_(mrFet12_, viiSpk12_ord_, n1_, n2_, P); % Compute DC in CPU
    else
        dc2_ = dc2.^2;
    end            
    vrRho_ = cuda_rho_(mrFet12_, viiSpk12_ord_, n1_, n2_, dc2_, P); 
    viSpk_site_ = S0.cviSpk_site{iSite};
    if ~isempty(vlRedo_spk), viSpk_site_ = viSpk_site_(vlRedo_spk(viSpk_site_)); end
    vrRho(viSpk_site_) = gather_(vrRho_);
    vrDc2_site(iSite) = gather_(dc2_);
    [mrFet12_, viiSpk12_ord_, vrRho_] = deal([]);
    fprintf('.');    
end
% if get_set_(P, 'knn', 30) > 0
%     vrRho_ = vrRho_ / max(vrRho_) * .1;
% end
fprintf('\n\ttook %0.1fs\n', toc(t1));

%-----
% Calculate Delta
fprintf('Calculating Delta\n\t'); t2=tic;
for iSite = 1:nSites
    [mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_] = fet12_site_(trFet_spk, S0, P, iSite, vlRedo_spk, viSpk_drift);
    if isempty(mrFet12_), continue; end    
    viiRho12_ord_ = rankorder_(vrRho(viSpk12_), 'descend');    
    if P.fGpu
        [mrFet12_, viiSpk12_ord_, viiRho12_ord_] = deal(gpuArray_(mrFet12_), gpuArray_(viiSpk12_ord_), gpuArray_(viiRho12_ord_));
    end
    try
        [vrDelta_, viNneigh_] = cuda_delta_(mrFet12_, viiSpk12_ord_, viiRho12_ord_, n1_, n2_, vrDc2_site(iSite), P);
        [vrDelta_, viNneigh_] = gather_(vrDelta_, viNneigh_);
    catch
        disperr_(sprintf('error at site# %d', iSite));
    end
    viSpk_site_ = S0.cviSpk_site{iSite};
    if ~isempty(vlRedo_spk), viSpk_site_ = viSpk_site_(vlRedo_spk(viSpk_site_)); end
    vrDelta(viSpk_site_) = vrDelta_;
    viNneigh(viSpk_site_) = viSpk12_(viNneigh_);
    [mrFet12_, viiRho12_ord_, viiSpk12_ord_] = deal([]); %vrDelta_, viNneigh_, viSpk12_
    fprintf('.');
end
% Deal with nan delta
viNan_delta = find(isnan(vrDelta));
if ~isempty(viNan_delta)
    vrDelta(viNan_delta) = max(vrDelta);
end
% [vrDelta, viNneigh] = multifun_(@gather_, vrDelta, viNneigh);
fprintf('\n\ttook %0.1fs\n', toc(t2));

if ~isempty(vlRedo_spk)
    vrRho = vrRho(vlRedo_spk);
    vrDelta = vrDelta(vlRedo_spk);        
    viNneigh = reverse_lookup_(viNneigh(vlRedo_spk), find(vlRedo_spk));
end

if get_set_(P, 'knn',0) > 0
%     [vrRho, vrDelta] = deal(vrRho0, vrDelta0);
    [vrRho0, vrDelta0] = deal(vrRho, vrDelta);
    vrDelta = vrDelta .* vrRho;
    vrRho = vrRho / max(vrRho) / 10;    
%     figure; plot(log10(vrRho), log10(vrDelta), '.');
end

%-----
% package
% if P.fGpu
%     [vrRho, vrDelta, viNneigh] = multifun_(@gather_, vrRho, vrDelta, viNneigh);
% end
t_runtime = toc(t_func);
trFet_dim = size(trFet_spk); %[1, size(mrFet1,1), size(mrFet1,2)]; %for postCluster
[~, ordrho] = sort(vrRho, 'descend');
S_clu = struct('rho', vrRho, 'delta', vrDelta, 'ordrho', ordrho, 'nneigh', viNneigh, ...
    'P', P, 't_runtime', t_runtime, 'halo', [], 'viiSpk', [], 'trFet_dim', trFet_dim, 'vrDc2_site', vrDc2_site);

% figure; loglog(vrRho, vrDelta, '.');
end %func


%--------------------------------------------------------------------------
% 2018/5/3: CPU-based clustering fixed
function vrRho1 = cuda_rho_(mrFet12, viiSpk12_ord, n1, n2, dc2, P)
% Ultimately use CUDA to do this distance computation
% mrFet12_: already in GPU
% viiSpk12: ordered list

persistent CK nC_
if nargin==0, nC_ = 0; return; end
if isempty(nC_), nC_ = 0; end
[nC, n12] = size(mrFet12); %nc is constant with the loop
dn_max = int32(round((n1+n2) / P.nTime_clu));
nC_max = get_set_(P, 'nC_max', 45);
dc2 = single(dc2);
knn = get_set_(P, 'knn', 0); % set to 0 to disable
if P.fGpu && knn==0
    try        
        if (nC_ ~= nC) % create cuda kernel
            nC_ = nC;
            CK = parallel.gpu.CUDAKernel('irc_cuda_rho.ptx','irc_cuda_rho.cu');
            CK.ThreadBlockSize = [P.nThreads, 1];          
            CK.SharedMemorySize = 4 * P.CHUNK * (2 + nC_max + 2 * P.nThreads); % @TODO: update the size
        end
        CK.GridSize = [ceil(n1 / P.CHUNK / P.CHUNK), P.CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
        vrRho1 = zeros([1, n1], 'single', 'gpuArray'); 
        vnConst = int32([n1, n12, nC, dn_max, get_set_(P, 'fDc_spk', 0)]);
        vrRho1 = feval(CK, vrRho1, mrFet12, viiSpk12_ord, vnConst, dc2);
        return;
    catch        
        disperr_('CUDA kernel failed. Re-trying in CPU.');
        nC_ = 0;
    end
end

if knn==0
    viiSpk1_ord = viiSpk12_ord(1:n1)';
    mlKeep12_ = abs(bsxfun(@minus, viiSpk12_ord, viiSpk1_ord)) <= dn_max;    
    vrRho1 = sum((eucl2_dist_(mrFet12, mrFet12(:,1:n1)) < dc2) & mlKeep12_); %do not include self    
    vrRho1 = single(vrRho1 ./ sum(mlKeep12_));
else % try using parfor
%     vrRho1 = calc_rho_parfor_(mrFet12, viiSpk12_ord, n1, dn_max, knn);    
    vrRho1 = calc_rho_knn_(mrFet12, viiSpk12_ord, n1, dn_max, knn);
end
end %func


%--------------------------------------------------------------------------
function vrRho1 = calc_rho_knn_(mrFet12, viiSpk12_ord, n1, dn_max, knn, fGpu)
if nargin<6, fGpu = isGpu_(mrFet12); end
step = 1024;

try
    [gmrFet12, gviiSpk12_ord] = deal(gpuArray_(mrFet12, fGpu), gpuArray_(viiSpk12_ord, fGpu));       
catch
    [gmrFet12, gviiSpk12_ord] = deal(gather_(mrFet12), gather_(viiSpk12_ord));
    fGpu = 0;
end
vrRho1 = zeros(1, n1, 'like', gmrFet12);
% [gmrFet1, gviiSpk1_ord] = deal(gmrFet12(:,1:n1), gviiSpk12_ord(1:n1));
for i1=1:step:n1
    if i1+step-1 <= n1
        vi1 = i1:(i1+step-1);
    else
        vi1 = i1:n1;
    end
    mr12_ = eucl2_dist_(gmrFet12, gmrFet12(:,vi1));
    mr12_(abs(bsxfun(@minus, gviiSpk12_ord, gviiSpk12_ord(vi1)')) > dn_max) = nan;
    mr12_ = sort(mr12_); 
    vrRho1(vi1) = 1 ./ sqrt(mr12_(knn,:));
end
vrRho1 = gather_(vrRho1);
end %func


%--------------------------------------------------------------------------
function vr = sort_k_(mr, k)

vi_col = 1:size(mr,2);
dimm = size(mr);
for i=1:k
    [vr, vi_min] = min(mr);
    if i==k, break; end
    mr(sub2ind(dimm, vi_min, vi_col)) = nan;
end
end %func


%--------------------------------------------------------------------------
% 2018/6/29 JJJ
function vrRho1 = calc_rho_parfor_(mrFet12, viiSpk12_ord, n1, dn_max, knn)
tic
vrRho1 = zeros(1, n1, 'like', mrFet12);
nWorkers = 4;
cvrRho1 = cell(nWorkers, 1);
cvi1 = vi2cell_(1:n1, nWorkers);
parfor (iWorker=1:nWorkers, nWorkers)
    vi1 = cvi1{iWorker};
    mlRemove1 = abs(bsxfun(@minus, viiSpk12_ord, viiSpk12_ord(vi1)')) > dn_max;    
    mrDist1 = eucl2_dist_(mrFet12, mrFet12(:,vi1));
    mrDist1(mlRemove1) = nan;
    mrDist1 = sort(mrDist1);
    cvrRho1{iWorker} = 1./ sqrt(mrDist1(knn,:)');
end
vrRho1 = cell2mat(cvrRho1);
toc
end %func


%--------------------------------------------------------------------------
% 2018/6/29 JJJ
function cvi1 = vi2cell_(vi, nCell);
cvi1 = cell(nCell, 1);
nPerCell = ceil(numel(vi) / nCell);
viEdge = [1, (1:nCell-1)*nPerCell, numel(vi)];

for iCell = 1:nCell
    cvi1{iCell} = vi(viEdge(iCell):(viEdge(iCell+1)-1));
end
end %func


%--------------------------------------------------------------------------
% 2018/5/3: CPU-based clustering fixed
function [vrDelta1, viNneigh1] = cuda_delta_(mrFet12, viiSpk12_ord, viiRho12_ord, n1, n2, dc2, P)
% Ultimately use CUDA to do this distance computation
persistent CK nC_
if nargin==0, nC_ = 0; return; end
if isempty(nC_), nC_ = 0; end
if isempty(dc2) || isnan(dc2), dc2 = 1; end
    
[nC, n12] = size(mrFet12); %nc is constant with the loop
dn_max = int32(round((n1+n2) / P.nTime_clu));
nC_max = get_set_(P, 'nC_max', 45);
SINGLE_INF = 3.402E+38;
if P.fGpu
    try
        if (nC_ ~= nC) % create cuda kernel
            nC_ = nC;
            CK = parallel.gpu.CUDAKernel('iron_cuda_delta.ptx','iron_cuda_delta.cu');
            CK.ThreadBlockSize = [P.nThreads, 1];          
            CK.SharedMemorySize = 4 * P.CHUNK * (3 + nC_max + 2*P.nThreads); % @TODO: update the size
        end
        CK.GridSize = [ceil(n1 / P.CHUNK / P.CHUNK), P.CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
        vrDelta1 = zeros([1, n1], 'single', 'gpuArray'); 
        viNneigh1 = zeros([1, n1], 'uint32', 'gpuArray'); 
        vnConst = int32([n1, n12, nC, dn_max, get_set_(P, 'fDc_spk', 0)]);
        [vrDelta1, viNneigh1] = feval(CK, vrDelta1, viNneigh1, mrFet12, viiSpk12_ord, viiRho12_ord, vnConst, dc2);
        % [vrDelta1_, viNneigh1_] = deal(vrDelta1, viNneigh1);
        return;
    catch        
        disperr_('CUDA kernel failed. Re-trying in CPU.');
        nC_ = 0;
    end
end
mrDist12_ = eucl2_dist_(mrFet12, mrFet12(:,1:n1));  %not sqrt
mlRemove12_ = bsxfun(@ge, viiRho12_ord, viiRho12_ord(1:n1)') ...
    | abs(bsxfun(@minus, viiSpk12_ord, viiSpk12_ord(1:n1)')) > dn_max;
mrDist12_(mlRemove12_) = nan;
[vrDelta1, viNneigh1] = min(mrDist12_);
vrDelta1 = sqrt(vrDelta1 / dc2);
viNan = find(isnan(vrDelta1));
viNneigh1(viNan) = viNan;
vrDelta1(viNan) = sqrt(SINGLE_INF/dc2);
end
    
    
%--------------------------------------------------------------------------
function dc2_ = compute_dc2_(mrFet12, viiSpk12_ord, n1_, n2_, P)
% subsample
% fSubsample12 = 1;
if get_set_(P, 'fDc_spk', 0)
    dc2_ = (P.dc_percent/100).^2; 
    return; 
end % spike-specific dc
if 0 % 122717 JJJ
    [n1_max, n2_max] = deal(P.dc_subsample, P.dc_subsample * 40);
else % old
    [n1_max, n2_max] = deal(P.dc_subsample, P.dc_subsample * 4);
end
vi1_ = subsample_vr_(1:n1_, n1_max);
viiSpk1_ord_ = viiSpk12_ord(vi1_);
mrFet1_ = mrFet12(:,vi1_);

vi12_ = subsample_vr_(1:n1_, n2_max);
viiSpk12_ord = viiSpk12_ord(vi12_);
mrFet12 = mrFet12(:,vi12_);
for iRetry=1:2
    try
        mrDist11_2_ = eucl2_dist_(mrFet12, mrFet1_);
        % if get_set_(P, 'f_dpclus', 1)
        mlKeep11_2_ = abs(bsxfun(@minus, viiSpk12_ord, viiSpk1_ord_')) < (n1_+n2_) / P.nTime_clu;
        mrDist11_2_(~mlKeep11_2_) = nan;
    catch
        mrFet12 = gather_(mrFet12);
    end
end
if get_set_(P, 'fDc_subsample_mode', 0)
    mrDist11_2_(mrDist11_2_<=0) = nan;
    dc2_ = quantile(mrDist11_2_(~isnan(mrDist11_2_)), P.dc_percent/100);
else
    mrDist_sub = gather_(mrDist11_2_);
    mrDist_sub(mrDist_sub<=0) = nan;
    if 1
        dc2_ = nanmedian(quantile(mrDist_sub, P.dc_percent/100));
    else
        dc2_ = nan;
    end
    if isnan(dc2_), dc2_ = quantile(mrDist_sub(:), P.dc_percent/100); end
end
end %func


%--------------------------------------------------------------------------
function vr = quantile_(mr, p)
n = size(mr,1);
idx = max(min(round(n * p), n), 1);
mr = sort(mr, 'ascend');
vr = mr(idx,:);
end %func


%--------------------------------------------------------------------------
function [mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_, viDrift_spk12_] = ...
    fet12_site_(trFet_spk, S0, P, iSite, vlRedo_spk, viDrift_spk)
% decide whether to use 1, 2, or 3 features
if nargin<5, vlRedo_spk = []; end
if nargin<6, viDrift_spk = []; end

nFet_use = get_set_(P, 'nFet_use', 2);
[viSpk1_, viSpk2_] = multifun_(@int32, S0.cviSpk_site{iSite}, S0.cviSpk2_site{iSite});
if ~isempty(vlRedo_spk)
    viSpk1_ = viSpk1_(vlRedo_spk(viSpk1_));
    viSpk2_ = viSpk2_(vlRedo_spk(viSpk2_));
end
[mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_, viDrift_spk12_] = deal([]);
if isempty(viSpk1_), return; end
if isempty(viSpk2_), nFet_use=1; end
switch nFet_use
    case 3
        viSpk3_ = int32(S0.cviSpk3_site{iSite});
        if ~isempty(viSpk3_), viSpk3_ = viSpk3_(vlRedo_spk(viSpk3_)); end
        mrFet12_ = [squeeze_(trFet_spk(:,1,viSpk1_),2), squeeze_(trFet_spk(:,2,viSpk2_),2), squeeze_(trFet_spk(:,3,viSpk3_),2)];
        viSpk12_ = [viSpk1_; viSpk2_; viSpk3_];
        [n1_, n2_] = deal(numel(viSpk1_), numel(viSpk2_) + numel(viSpk3_));
    case 2
        mrFet12_ = [squeeze_(trFet_spk(:,1,viSpk1_),2), squeeze_(trFet_spk(:,2,viSpk2_),2)];
        viSpk12_ = [viSpk1_; viSpk2_];
        [n1_, n2_] = deal(numel(viSpk1_), numel(viSpk2_));
    case 1
        mrFet12_ = squeeze_(trFet_spk(:,1,viSpk1_),2);
        viSpk12_ = viSpk1_;
        [n1_, n2_] = deal(numel(viSpk1_), numel(viSpk2_));
end
try
    nSites_fet = 1 + P.maxSite*2 - P.nSites_ref;    
    if get_set_(P, 'fSpatialMask_clu', 1) && nSites_fet >= get_set_(P, 'min_sites_mask', 5)
        nFetPerChan = size(mrFet12_,1) / nSites_fet;
        vrSpatialMask = spatialMask_(P, iSite, nSites_fet, P.maxDist_site_um);
        vrSpatialMask = repmat(vrSpatialMask(:), [nFetPerChan, 1]);
        mrFet12_ = bsxfun(@times, mrFet12_, vrSpatialMask(:));
    end
catch
    disperr_('Spatial mask error');
end
if get_set_(P, 'fSqrt_fet', 0), mrFet12_ = signsqrt_(mrFet12_); end
if get_set_(P, 'fLog_fet', 0), mrFet12_ = signlog_(mrFet12_); end
if get_set_(P, 'fSquare_fet', 0), mrFet12_ = (mrFet12_).^2; end
if ~isempty(viDrift_spk), viDrift_spk12_ = viDrift_spk(viSpk12_); end
viiSpk12_ord_ = rankorder_(viSpk12_, 'ascend');
end %func


%--------------------------------------------------------------------------
% 11/7/17 JJJ: Created
function [vrWeight_site1, vrDist_site1] = spatialMask_(P, iSite, nSites_spk, decayDist_um)
if nargin<3, nSites_spk = size(P.miSites,1); end
if nargin<4, decayDist_um = P.maxDist_site_um; end

mrSiteXY1 = P.mrSiteXY(P.miSites(1:nSites_spk, iSite),:);
vrDist_site1 = pdist2(mrSiteXY1(1,:), mrSiteXY1);
vrWeight_site1 = 2.^(-vrDist_site1 / decayDist_um); 
vrWeight_site1 = vrWeight_site1(:);
vrDist_site1 = vrDist_site1(:);
end %func


%--------------------------------------------------------------------------
function [mrFet1_, mrFet2_, viSpk1_, viSpk2_, n1_, n2_, viiSpk12_ord_] = fet12_site_1_(mrFet1, mrFet2, S0, P, iSite)

[viSpk1_, viSpk2_] = deal(S0.cviSpk_site{iSite}, S0.cviSpk2_site{iSite});
[mrFet1_, mrFet2_] = deal(mrFet1(:,viSpk1_), mrFet2(:,viSpk2_));
[n1_, n2_] = deal(numel(viSpk1_), numel(viSpk2_));
if P.fGpu
   [mrFet1_, mrFet2_, viSpk1_, viSpk2_] = multifun_(@gpuArray_, mrFet1_, mrFet2_, viSpk1_, viSpk2_);
end
viiSpk12_ord_ = rankorder_([viSpk1_; viSpk2_], 'ascend');
end %func


%--------------------------------------------------------------------------
function validate_(P, fPlot_gt) 
% Usage
% ------
% validate(P);
% validate(vcFile_prm);
% validate(P, fPlot_gt);
% validate(vcFile_prm, fPlot_gt);

% persistent S_gt vcFile_prm_ % tnWav_spk tnWav_gt
% S0 = load_cached_(P, 0);
fMergeCheck = 0; %kilosort-style validation
fShowTable = 1;
if nargin<2, fPlot_gt = []; end
if ischar(P), P = loadParam_(P); end

if ~is_detected_(P), detect_(P); end
if ~is_sorted_(P), sort_(P); end    

S_cfg = read_cfg_();
P.snr_thresh_gt = get_(S_cfg, 'snr_thresh_gt');
snr_thresh_stat = P.snr_thresh_gt / 2; % use lower so that this can be raised if needed
fUseCache_gt = get_set_(S_cfg, 'fUseCache_gt', 1);

set(0, 'UserData', []); %clear cache
S0 = load_cached_(P, 1); %do not load waveforms
% S0 = load0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
S_clu = S0.S_clu;

% Load ground truth file
if ~exist_file_(P.vcFile_gt), P.vcFile_gt = subsFileExt_(P.vcFile, '_gt.mat'); end
vcFile_gt1 = strrep(P.vcFile_prm, '.prm', '_gt1.mat');
fProcess_gt = 1;
if exist_file_(vcFile_gt1) && fUseCache_gt
    S_gt = load(vcFile_gt1);
    if isfield(S_gt, 'vrSnr_sd_clu')
        fprintf('Loaded from cache: %s\n', vcFile_gt1);
        fProcess_gt = 0; 
    end
end   
if fProcess_gt
    S_gt0 = load_gt_(P.vcFile_gt, P);
    if isempty(S_gt0), fprintf(2, 'Groundtruth does not exist. Run "irc import" to create a groundtruth file.\n'); return; end
    S_gt = gt2spk_(S_gt0, P, snr_thresh_stat);
    struct_save_(S_gt, vcFile_gt1);
    fprintf('Wrote to cache: %s\n', vcFile_gt1);
end
S_gt = S_gt_snr_thresh_(S_gt, P.snr_thresh_gt); % trim by SNR threshold
S_score = struct_(...
    'vrVmin_gt', S_gt.vrVmin_clu, 'vnSite_gt', S_gt.vnSite_clu, ... 
    'vrSnr_gt', S_gt.vrSnr_clu, 'vrSnr_min_gt', S_gt.vrSnr_clu, ...
    'vrSnr_sd_gt', S_gt.vrSnr_sd_clu, 'trWav_gt', S_gt.trWav_clu, ...
    'viSite_gt', S_gt.viSite_clu, 'cviSpk_gt', S_gt.cviSpk_clu, ...
    'vrVpp_clu', S_gt.vrVpp_clu, 'vrVmin_clu', S_gt.vrVmin_clu);

% Compare S_clu with S_gt
nSamples_jitter = round(P.sRateHz / 1000); %1 ms jitter
fprintf('verifying cluster...\n'); 
[mrMiss, mrFp, vnCluGt, miCluMatch, S_score_clu] = ...
    clusterVerify(S_gt.viClu, S_gt.viTime, S_clu.viClu, S0.viTime_spk, nSamples_jitter);  %S_gt.viTime
if fMergeCheck, compareClustering2_(S_gt.viClu, S_gt.viTime, S_clu.viClu+1, S0.viTime_spk); end

Sgt = S_gt; %backward compatibility
S_score = struct_add_(S_score, mrMiss, mrFp, vnCluGt, miCluMatch, P, Sgt, S_score_clu);
S_score.cviTime_clu = S_clu.cviSpk_clu(S_score_clu.viCluMatch)';
S_score.vrVrms_site = single(S0.vrThresh_site) / S0.P.qqFactor;

% Burst stats
[vlHit_gtspk, vnBurst_gtspk] = deal(cell2vec_(S_score_clu.cvlHit_gt), cell2vec_(S_gt.cvnBurst_clu));
[vpHit_burst, vnHit_burst] = grpstats(vlHit_gtspk, vnBurst_gtspk, {'mean', 'numel'});
cvpHit_burst_gt = cellfun(@(vl_,vi_)grpstats(vl_,vi_+1,'mean'), S_score_clu.cvlHit_gt(:), S_gt.cvnBurst_clu(:), 'UniformOutput', 0);
mpHit_burst_gt = cell2mat_nan_(cvpHit_burst_gt)';
S_burst = makeStruct_(cvpHit_burst_gt, vlHit_gtspk, vnBurst_gtspk, vpHit_burst, vnHit_burst, mpHit_burst_gt);
S_score = struct_add_(S_score, S_burst);

% Overlap stats
S_overlap = analyze_overlap_(S_gt, S_cfg, P);
cvnOverlap_gt = S_overlap.cvnOverlap_gt;
vnOverlap_gtspk = cell2vec_(cvnOverlap_gt);
[vpHit_overlap, vnHit_overlap] = grpstats(vlHit_gtspk, cell2vec_(cvnOverlap_gt), {'mean', 'numel'});
cvpHit_overlap_gt = cellfun(@(vl_,vi_)grpstats(vl_,vi_+1,'mean'), S_score_clu.cvlHit_gt(:), cvnOverlap_gt(:), 'UniformOutput', 0);
mpHit_overlap_gt = cell2mat_nan_(cvpHit_overlap_gt)';
S_overlap = struct_add_(S_overlap, ...
    cvpHit_overlap_gt, vlHit_gtspk, vnOverlap_gtspk, vpHit_overlap, vnHit_overlap, mpHit_overlap_gt);
S_score = struct_add_(S_score, S_overlap);

fprintf('SNR_gt (Vp/Vrms): %s\n', sprintf('%0.1f ', S_score.vrSnr_gt));
fprintf('nSites>thresh (GT): %s\n', sprintf('%d ', S_score.vnSite_gt));
write_struct_(strrep(P.vcFile_prm, '.prm', '_score.mat'), S_score);
set0_(S_score);       
assignWorkspace_(S_score); %put in workspace

vnSpk_gt = cellfun(@numel, S_score_clu.cviSpk_gt_hit) + cellfun(@numel, S_score_clu.cviSpk_gt_miss);
[vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, fVerbose] = ...
    deal(S_score.vrSnr_min_gt, S_score_clu.vrFp, S_score_clu.vrMiss, ...
        S_score_clu.vrAccuracy, S_score.vnSite_gt, vnSpk_gt, 0);
disp_score_(makeStruct_(vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, fVerbose, S_burst, S_overlap));

% plot if not running from the cluster
if isempty(fPlot_gt), fPlot_gt = get_(S_cfg, 'fPlot_gt'); end
if isUsingBuiltinEditor_()
    try
        vrAccuracy = S_score.S_score_clu.vrAccuracy;        
        switch fPlot_gt
            case 5 % variance ratio
                figure;
                set(gcf,'Color','w', 'Name', P.vcFile_prm);
                RMS_var = S_gt.vrSnr_sd_clu.^2;
                plot_gt_2by2_(RMS_var, vrAccuracy, vrFp, vrFn);
            case 4
                figure;
                set(gcf,'Color','w', 'Name', P.vcFile_prm);
                RMS_min = vrSnr;
                plot_gt_2by2_(RMS_min, vrAccuracy, vrFp, vrFn);
            case 3
                figure;
                set(gcf,'Color','w', 'Name', P.vcFile_prm);
                vrVmin = abs(S_score.Sgt.vrVmin_clu);
                plot_gt_2by2_(vrVmin, vrAccuracy, vrFp, vrFn);
            case 2
                vrVpp = S_score.Sgt.vrVpp_clu;
                figure;
                set(gcf,'Color','w', 'Name', P.vcFile_prm);
                plot_gt_2by2_(vrVpp, vrAccuracy, vrFp, vrFn);   
            case 1
                plot_gt_(S_score, P);
                return;
            otherwise
                return;
        end
        csCode = file2cellstr_([mfilename(), '.m']);
        set(gcf,'UserData', makeStruct_(P, S_score, csCode));   
        vcFile_fig = filename_timestamp_(strrep(P.vcFile_prm, '.prm', '_gt.fig'));
        save_fig_(vcFile_fig, gcf);
    catch
        disperr_();
    end
end
end %func


%--------------------------------------------------------------------------
% 9/17/2018 JJJ: select ground-truth clusters above certan SNR
% passthrough except specified arrays which needs to be resized
function S_gt = S_gt_snr_thresh_(S_gt, snr_thresh_gt)

fSort_snr = 1; % sort from small to large

% select a subset of clusters
vcSnr_gt = read_cfg_('vcSnr_gt');
if strcmpi(vcSnr_gt, 'min')
    S_gt.vrSnr_clu = S_gt.vrSnr_min_clu;
elseif strcmpi(vcSnr_gt, 'sd')
    S_gt.vrSnr_clu = S_gt.vrSnr_sd_clu;
end
viClu_keep = find(S_gt.vrSnr_clu >= snr_thresh_gt);
if fSort_snr 
    [~, viSrt_] = sort(S_gt.vrSnr_clu(viClu_keep), 'ascend');
    viClu_keep = viClu_keep(viSrt_);
end
S_ = struct_copy_(S_gt, ...
    'vnSite_clu', 'viSite_clu', 'vrSnr_clu', 'vrSnr_sd_clu', 'vrSnr_min_clu', 'vrVmin_clu', ...
    'viClu_keep', 'viClu_keep', 'vrSnr_clu', 'cvnBurst_clu', ...
    'miSites_clu', 'trWav_clu', 'trWav_raw_clu', 'vrSnr_clu');
S_ = struct_select_dimm_(S_, viClu_keep, 1);
S_gt = struct_merge_(S_gt, S_);

% update cluster number
vlSpk_keep = ismember(S_gt.viClu, viClu_keep); 
[S_gt.viClu, S_gt.viTime] = multifun_(@(x)x(vlSpk_keep), S_gt.viClu, S_gt.viTime);    
viMap = 1:max(viClu_keep);
nClu_keep = numel(viClu_keep);
viMap(viClu_keep) = 1:nClu_keep;
S_gt.viClu = viMap(S_gt.viClu); % compact, no-gap
S_gt.cviSpk_clu = arrayfun(@(iClu)int32(find(S_gt.viClu == iClu)), 1:nClu_keep, 'UniformOutput', 0);
end %func


%--------------------------------------------------------------------------
function mr = cell2mat_nan_(cvr)
% create a matrix that is max(numel(vr)) x # cells
% fill with zero for the missing entries
vnCell = cellfun(@numel, cvr);
nCells = numel(vnCell);
mr = nan(max(vnCell), nCells);
for iCell=1:nCells
    vr_ = cvr{iCell};
    mr(1:vnCell(iCell), iCell) = vr_(:);
end
end %func


%--------------------------------------------------------------------------
% Concatenate cells to vector and provide cell index and matrix indices
% function [vr, vi_cell, vi_vec] = cell2col_(cvr)
% if nargin<2, fCol = 1; end %column or row vector
% cvr = cvr(:);
% vn_cell = cellfun(@numel, cvr);
% nCells = numel(vn_cell);
% viCell = (1:nCells)';
% viCell(vn_cell==0) = [];
% 
% vr = cell2mat(cellfun(@(x)x(:), cvr, 'UniformOutput', 0));
% 
% if nargout>=2
%     vi_cell = cell2mat(arrayfun(@(x,y)repmat(x, [y,1]), viCell, vn_cell, 'UniformOutput', 0));
% end
% if nargout>=3
%     vi_vec = cell2mat(arrayfun(@(x)(1:x)', vn_cell, 'UniformOutput', 0));
% end
% end %func


%--------------------------------------------------------------------------
% Import ground truth file, deal with multiple formats
function S_gt = load_gt_(vcFile_gt, P)
% S_gt contains viTime and viClu
if nargin<2, P = get0_('P'); end
if ~exist_file_(vcFile_gt), S_gt=[]; return; end
S = load(vcFile_gt);
if isfield(S, 'S_gt')
    S_gt = S.S_gt;  
elseif isfield(S, 'Sgt')
    S_gt = S.Sgt;       
elseif isfield(S, 'viClu') && isfield(S, 'viTime')
    S_gt = S;
elseif isfield(S, 'viClu') && isfield(S, 'viSpk')
    S_gt.viTime = S.viSpk;    
    S_gt.viClu = S.viClu;    
else
    % Convert Nick's format to IronClust fomat
    if isfield(S, 'gtTimes')
        S_gt.viTime = cell2mat_(S.gtTimes');
        S_gt.viClu = cell2mat_(arrayfun(@(i)ones(size(S.gtTimes{i}))*i, 1:numel(S.gtTimes), 'UniformOutput', 0)');
    else
        error('no field found.');
    end
    [S_gt.viTime, ix] = sort(S_gt.viTime, 'ascend');
    S_gt.viClu = S_gt.viClu(ix);
end
if ~isempty(get_(P, 'tlim_load'))
    nSamples = double(S_gt.viTime(end));
    nlim_load = min(max(round(P.tlim_load * P.sRateHz), 1), nSamples);
    viKeep = find(S_gt.viTime >= nlim_load(1) & S_gt.viTime <= nlim_load(2));
    [S_gt.viTime, S_gt.viClu] = multifun_(@(x)x(viKeep), S_gt.viTime, S_gt.viClu);
end
[viClu_unique, ~, viClu] = unique(S_gt.viClu);
if max(S_gt.viClu) > numel(viClu_unique)
    S_gt.viClu = viClu;
end
if isfield(S_gt, 'viSite')
    if min(S_gt.viSite) == 0, S_gt.viSite = S_gt.viSite + 1; end
end
end %func


%--------------------------------------------------------------------------
function [S_gt, tnWav_spk, tnWav_raw] = gt2spk_(S_gt, P, snr_thresh, fProcessRaw)
% convert ground truth to spike waveforms
% fSubtract_nmean = 0;
% fSubtract_ref = 1;
% P.fGpu = 0;
MAX_SAMPLE = 1000; %mean calc
nSubsample_clu = get_set_(P, 'nSubsample_clu', 8);

if nargin<3, snr_thresh = []; end
if nargin<4, fProcessRaw = (nargout == 3); end

S_cfg = read_cfg_();
t1 = tic;
fprintf('Computing ground truth units...\n');
viClu = int32(S_gt.viClu); 
viTime_spk = int32(S_gt.viTime);
nSites = numel(P.viSite2Chan);

% Overload with default.cfg setting for GT units

[vcFilter_gt, freqLim_gt, nDiff_filt_gt, spkLim_ms_gt] = ...
    struct_get_(S_cfg, 'vcFilter_gt', 'freqLim_gt', 'nDiff_filt_gt', 'spkLim_ms_gt');
P1 = struct('vcCommonRef', 'none', 'vcSpkRef', 'none', ... %'fGpu', 0,
    'vcFilter', vcFilter_gt, 'freqLim', freqLim_gt, ...
    'nDiff_filt', nDiff_filt_gt, 'spkLim_ms', spkLim_ms_gt);
P1 = struct_merge_(P, P1);
P1.spkLim = round(P1.spkLim_ms * P1.sRateHz / 1000);

mnWav = load_file_(P.vcFile, [], P1);
if fProcessRaw
    tnWav_raw = permute(mn2tn_gpu_(mnWav, P.spkLim_raw, viTime_spk), [1,3,2]);
end
[mnWav, ~] = filt_car_(mnWav, P1);
% if fSubtract_nmean % Apply nmean CAR to ground truth spikes (previous standard)
%     P1=P; P1.vcCommonRef = 'nmean'; mnWav = wav_car_(mnWav, P1);
% end
tnWav_spk = permute(mn2tn_gpu_(mnWav, P1.spkLim, viTime_spk), [1,3,2]);
[vrVrms_site, vrVsd_site] = mr2rms_(mnWav, 1e6);
[vrVrms_site, vrVsd_site] = gather_(vrVrms_site * P.uV_per_bit, vrVsd_site * P.uV_per_bit);

clear mnWav;

% determine mean spikes
nClu = max(viClu);
trWav_clu = zeros(size(tnWav_spk,1), nSites, nClu, 'single');
if fProcessRaw
    trWav_raw_clu = zeros(size(tnWav_raw,1), nSites, nClu, 'single');
else
    trWav_raw_clu = [];
end
cviSpk_clu = arrayfun(@(iClu)int32(find(viClu == iClu)), 1:nClu, 'UniformOutput', 0);
for iClu=1:nClu
    viSpk_clu1 = cviSpk_clu{iClu};
    viSpk1 = subsample_vr_(viSpk_clu1, MAX_SAMPLE);
    if isempty(viSpk1), continue; end
    try
        trWav_clu(:,:,iClu) = mean(tnWav_spk(:,:,viSpk1), 3) * P.uV_per_bit; %multiply by scaling factor?
    catch
        ;
    end
    if fProcessRaw
        trWav_raw_clu(:,:,iClu) = mean_tnWav_raw_(tnWav_raw(:,:,viSpk1), P);
    end
    fprintf('.');
end

% Find center location and spike SNR
% mrVmin_clu = shiftdim(min(trWav_clu,[],1));
% [vrVmin_clu, viSite_clu] = min(mrVmin_clu,[],1); %center sites

mrVmin_clu = squeeze_(min(trWav_clu,[],1));
[vrVmin_clu, viSite_clu] = min(mrVmin_clu,[],1);
[vrVpp_clu, viSite_Vpp_clu] = max(squeeze_(max(trWav_clu) - min(trWav_clu)));

% cluster specifications
vrVmin_clu = abs(vrVmin_clu);
vrVsd_clu = sqrt(squeeze(max(mean(trWav_clu.^2),[],2)))';
vrSnr_min_clu = (vrVmin_clu ./ vrVrms_site(viSite_clu))';
vrSnr_sd_clu = (vrVsd_clu ./ vrVsd_site(viSite_clu))'; % F. Franke noise definion
vrThresh_site = vrVrms_site * P.qqFactor;
vnSite_clu = sum(bsxfun(@lt, mrVmin_clu, -vrThresh_site(viSite_clu)));
if strcmpi(S_cfg.vcSnr_gt, 'min')
    vrSnr_clu = vrSnr_min_clu;
elseif strcmpi(S_cfg.vcSnr_gt, 'sd')
    vrSnr_clu = vrSnr_sd_clu;
end
vnSpk_clu = cellfun(@numel, cviSpk_clu);
S_ = makeStruct_(viSite_clu, vrVmin_clu, vrSnr_clu, vnSite_clu, ...
    vrSnr_sd_clu, vrSnr_min_clu, trWav_clu, trWav_raw_clu, ...
    vrVpp_clu, viSite_Vpp_clu, vnSpk_clu);

if ~isempty(snr_thresh)
    viClu_keep = find(abs(vrSnr_clu) > snr_thresh);    
    S_ = struct_select_dimm_(S_, viClu_keep, 1);
    
    % reassign cluster number
    vlSpk_keep = ismember(viClu, viClu_keep);
    [S_gt.viClu, S_gt.viTime] = multifun_(@(x)x(vlSpk_keep), S_gt.viClu, S_gt.viTime);    
    viMap = 1:max(viClu_keep);
    nClu_keep = numel(viClu_keep);
    viMap(viClu_keep) = 1:nClu_keep;
    S_gt.viClu = viMap(S_gt.viClu); % compact, no-gap
    S_gt.cviSpk_clu = arrayfun(@(iClu)int32(find(S_gt.viClu == iClu)), 1:nClu_keep, 'UniformOutput', 0);
else
    viClu_keep = 1:max(S_gt.viClu);    
end
S_gt = struct_merge_(S_gt, S_);
miSites_clu = P.miSites(:, S_gt.viSite_clu);
cvnBurst_clu = analyze_burst_(S_gt.viTime, S_gt.viClu, S_cfg);
S_gt = struct_add_(S_gt, viClu_keep, vrVrms_site, vrVsd_site, miSites_clu, cvnBurst_clu);
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 17/11/20 JJJ: created
% function vr1 = fft_align_mean_(mr)
% % take the median phase
% if ndims(mr)==3
%     mr1 = zeros(size(mr,1), size(mr,2), 'like', mr);
%     for i1=1:size(mr,2)
%         mr1(:,i1) = fft_align_mean_(squeeze(mr(:,i1,:)));
%     end
%     vr1 = mr1;
%     return;
% end
% mrF = fft(mr);
% vrAbs1 = mean(abs(mrF),2);
% vrAng1 = median(unwrap(angle(mrF)),2);
% vr1 = real(ifft(complex(vrAbs1.*cos(vrAng1), vrAbs1.*sin(vrAng1))));
% end %func


%--------------------------------------------------------------------------
function [via1, via2, via3, via4, vib1, vib2, vib3, vib4] = sgfilt4_(n1, fGpu)
persistent n1_prev_ via1_ via2_ via3_ via4_ vib1_ vib2_ vib3_ vib4_
if nargin<2, fGpu=0; end

% Build filter coeff
if isempty(n1_prev_), n1_prev_ = 0; end
try a = size(via1_); catch, n1_prev_ =0; end
if n1_prev_ ~= n1 %rebuild cache
    vi0 = int32(1:n1);        
    vi0 = gpuArray_(vi0, fGpu);
    via4_ = vi0+4; via4_(end-3:end)=n1;   vib4_ = vi0-4; vib4_(1:4)=1;
    via3_ = vi0+3; via3_(end-2:end)=n1;   vib3_ = vi0-3; vib3_(1:3)=1;
    via2_ = vi0+2; via2_(end-1:end)=n1;   vib2_ = vi0-2; vib2_(1:2)=1;
    via1_ = vi0+1; via1_(end)=n1;         vib1_ = vi0-1; vib1_(1)=1;
    n1_prev_ = n1;
end

% Copy from cache
via4 = via4_;   vib4 = vib4_;
via3 = via3_;   vib3 = vib3_;
via2 = via2_;   vib2 = vib2_;
via1 = via1_;   vib1 = vib1_;
end %func


%--------------------------------------------------------------------------
function [miA, miB, viC] = sgfilt_init_(nData, nFilt, fGpu)
persistent miA_ miB_ viC_ nData_ nFilt_
if nargin<2, fGpu=0; end

% Build filter coeff
if isempty(nData_), nData_ = 0; end
try a = size(miA_); catch, nData_ = 0; end
if nData_ == nData && nFilt_ == nFilt
    [miA, miB, viC] = deal(miA_, miB_, viC_);
else
    vi0 = gpuArray_(int32(1):int32(nData), fGpu)';
    vi1 = int32(1):int32(nFilt);
    miA = min(max(bsxfun(@plus, vi0, vi1),1),nData);
    miB = min(max(bsxfun(@plus, vi0, -vi1),1),nData);
    viC = gpuArray_(int32(-nFilt:nFilt), fGpu);
    [nData_, nFilt_, miA_, miB_, viC_] = deal(nData, nFilt, miA, miB, viC);
end
end %func


%--------------------------------------------------------------------------
function [vrVrms_site, vrVsd_site] = mr2rms_(mr, max_sample)
% uses median to estimate RMS
if nargin<2, max_sample = []; end
if ~isempty(max_sample), mr = subsample_mr_(mr, max_sample, 1); end
vrVrms_site = median(abs(mr));
vrVrms_site = single(vrVrms_site) / 0.6745;
if nargout>=2, vrVsd_site = std(single(mr)); end
end


%--------------------------------------------------------------------------
function [S_clu, S0] = post_merge_(S_clu, P, fPostCluster)
% waveform based merging. find clusters within maxSite
% also removes duplicate spikes
if nargin<3, fPostCluster=1; end

nRepeat_merge = get_set_(P, 'nRepeat_merge', 10);
% refresh clu, start with fundamentals
S_clu = struct_copy_(S_clu, 'rho', 'delta', 'ordrho', 'nneigh', 'P', ...
    't_runtime', 'halo', 'viiSpk', 'trFet_dim', 'vrDc2_site', 'miKnn', 'viClu', 'icl');

if fPostCluster, S_clu = postCluster_(S_clu, P); end

S_clu = S_clu_refresh_(S_clu);
S_clu.viClu_premerge = S_clu.viClu;

if get_set_(P, 'fTemplateMatch_post', 1)
    S_clu = templateMatch_post_(S_clu, P);
%     S_clu = featureMatch_post_(S_clu, P);
end

% S_clu = fix_overlap_(S_clu, P); % halo detection (vlHalo)    
% S_clu = S_clu_remove_count_(S_clu, P); %remove low-count clusters
S_clu = post_merge_wav_(S_clu, 0, P);
% S_clu = S_clu_cleanup_(S_clu, P);
% S_clu = S_clu_remove_count_(S_clu, P); %remove low-count clusters

S_clu = S_clu_sort_(S_clu, 'viSite_clu');
S_clu = S_clu_update_wav_(S_clu, P);

% set diagonal element
[S_clu, S0] = S_clu_commit_(S_clu, 'post_merge_');
S_clu.mrWavCor = set_diag_(S_clu.mrWavCor, S_clu_self_corr_(S_clu, [], S0));
S_clu.P = P;
S_clu = S_clu_position_(S_clu);
S_clu.csNote_clu = cell(S_clu.nClu, 1);  %reset note
S_clu = S_clu_quality_(S_clu, P);
[S_clu, S0] = S_clu_commit_(S_clu, 'post_merge_');
end %func


%--------------------------------------------------------------------------
% 10/1/2018 JJJ: template matching at the cluster outer edge using core set
% assume all spikes come from the same site
function S_clu = templateMatch_post_(S_clu, P)
% global tnWav_spk
% only for tetrode
% if ~all(get0_('viSite_spk')==1)
%     fprintf(2, 'templateMatch_post_: skipped\n');
%     return;
% end
fUse_raw = 0;

fprintf('Template matching (post-hoc)\n'); t1=tic;
[viClu, miKnn] = struct_get_(S_clu, 'viClu', 'miKnn');
viSite_spk = get0_('viSite_spk');
frac_thresh = get_set_(P, 'thresh_core_knn', .75);
nTemplates = get_set_(P, 'nTemplates_clu', 100); %P.knn;
nShift_max = ceil(diff(P.spkLim) * P.frac_shift_merge / 2);
viShift = -nShift_max:nShift_max;

tnWav_spk = get_spkwav_(P, fUse_raw); % use raw waveform
switch 0
    case 2 %subtract reference
        tnWav_spk = trWav_car_(tnWav_spk, P);
    case 1 %denoise using knn
        tnWav_spk = tr_denoise_knn_(tnWav_spk, miKnn, P);
    case 0
        ; %no preconditioning
end

% create template (nTemplate per cluster)
[cviSpk_in_clu, cviSpk_out_clu, ctrWav_in_clu, cviSite_in_clu] = deal(cell(S_clu.nClu, 1));
fh_car = @(tr)tr - repmat(mean(tr,2), [1,size(tr,2),1]);
fh_wav = @(vi)single(tnWav_spk(:,:,vi));
switch 1
    case 3 % knn smoothed waveform returned
        fh_trimmean = @(vi)tr2mr_trimmean_(fh_wav(vi));
        fh_mr = @(vi)tr2mr_mean_knn_(tnWav_spk, miKnn, viSite_spk, vi); 
    case 2 % spatial ref
        fh_trimmean = @(vi)tr2mr_trimmean_(fh_car(fh_wav(vi)));
        fh_mr = @(vi)reshape(fh_car(fh_wav(vi)), [], numel(vi));        
    case 1 
        fh_trimmean = @(vi)tr2mr_trimmean_(fh_wav(vi));
        fh_mr = @(vi)single(reshape(tnWav_spk(:,:,vi), [], numel(vi)));
end
fh_med = @(vi)single(median(tnWav_spk(:,:,vi),3));
fh_mean = @(vi)single(mean(tnWav_spk(:,:,vi),3));
fh_pv1 = @(vi)tr_pv1_(single(tnWav_spk(:,:,vi)));
fh_meanalign = @(vi)tr_mean_align_(single(tnWav_spk(:,:,vi)));
fh_denoise = @(vi)tr2mr_denoise_(single(tnWav_spk(:,:,vi)));
nSites = max(viSite_spk);
vlCore_spk = false(size(viSite_spk));
fprintf('\tComputing template\n\t'); t_template = tic;
for iClu = 1:S_clu.nClu
    % identify spikes to recluster by segregating into core-set and outer-set     
    viSpk1 = find(S_clu.viClu == iClu);
    viSpk1 = viSpk1(:);
    viSite_clu1 = viSite_spk(viSpk1);
    miKnn_clu1 = miKnn(:,viSpk1);
    vrFracSame_spk1 = mean(viClu(miKnn_clu1) == iClu);
    vlCore1 = vrFracSame_spk1 >= frac_thresh;
    vlCore_spk(viSpk1) = vlCore1;
    viSpk_clu1 = viSpk1(vlCore1);
    cviSpk_in_clu{iClu} = viSpk_clu1;
    cviSpk_out_clu{iClu} = viSpk1(~vlCore1);
    
    % create a template using core-set members
    viiSpk1 = subsample_vr_(find(vlCore1), nTemplates);  
    if isempty(viiSpk1), continue; end
    trWav11 = zeros(size(tnWav_spk,1), size(tnWav_spk,2), numel(viiSpk1), 'single');
    viSite11 = viSite_spk(viSpk1(viiSpk1));
    miKnn11 = miKnn_clu1(:,viiSpk1);
    vlKeep11 = true(size(viiSpk1));
    for ii1 = 1:numel(viiSpk1)
        iSite11 = viSite11(ii1);
        viSpk11 = miKnn11(:,ii1);   
        if isempty(viSpk11), continue; end
        switch 1
            case 2
                viSpk11 = miKnn(:, viSpk11);
            case 1
                viSpk11 = miKnn(1:4, viSpk11);
        end
        viSpk11 = viSpk11(:);
        viSpk11 = viSpk11(viSite_spk(viSpk11) == iSite11);
        if numel(viSpk11) < P.knn
            vlKeep11(ii1) = 0;
            continue;
        end        
%         trWav11(:,:,ii1) = fh_denoise(viSpk11);
        trWav11(:,:,ii1) = fh_trimmean(viSpk11);
%         trWav11(:,:,ii1) = fh_meanalign(viSpk11(viSite11(ii1) == viSite_spk(viSpk11)));
%           trWav11(:,:,ii1) = fh_meanalign(viSpk11(viSite11(ii1) == viSite_spk(viSpk11)));
%         trWav11(:,:,ii1) = fh_pv1(viSpk11);
%         trWav11(:,:,ii1) = fh_mean(viSpk11);
    end
    ctrWav_in_clu{iClu} = trWav11(:,:,vlKeep11);
    cviSite_in_clu{iClu} = viSite11(vlKeep11);
    fprintf('.');
end
fprintf('\n\ttook %0.1fs\n', toc(t_template));

% Match outer-set members to cluster templates
viSpk_out = cell2mat_(cviSpk_out_clu);
viSite_spkout = viSite_spk(viSpk_out);
cviiSpk_out_site = arrayfun(@(i)find(viSite_spkout==i), 1:nSites, 'UniformOutput', 0);
fh_dist = @(mr, vr)sum(bsxfun(@minus, mr, vr).^2);
viClu_spkout = zeros(numel(viSpk_out), 1);
% find template locations by sites
[ctrWav_in_site, cviClu_in_site] = deal(cell(1, nSites));
for iSite = 1:nSites
    [ctrWav_, cviClu_] = deal(cell(1, S_clu.nClu));
    for iClu = 1:S_clu.nClu
        [trWav_in1, viSite_in1] = deal(ctrWav_in_clu{iClu}, cviSite_in_clu{iClu});
        vl_ = viSite_in1==iSite;
        if ~any(vl_), continue; end
        ctrWav_{iClu} = trWav_in1(:,:,vl_);
        cviClu_{iClu} = repmat(iClu, sum(vl_), 1);
    end
    ctrWav_in_site{iSite} = cat(3, ctrWav_{:});
    cviClu_in_site{iSite} = cat(1, cviClu_{:});
end

% template matching step
fprintf('\tReassigning spikes\n\t');
switch 1
    case 2 % find the nearest point in the core set
        viSpk_out = find(~vlCore_spk);
        for ii1 = 1:numel(viSpk_out) 
            iSpk_out1 = viSpk_out(ii1);
            viSpk1 = miKnn(:,iSpk_out1);
            vii_in1 = find(vlCore_spk(viSpk1));
            while isempty(vii_in1)
                viSpk1 = miKnn(1:4,viSpk1);
                viSpk1 = viSpk1(:);
                vii_in1 = find(vlCore_spk(viSpk1));
            end
            viSpk_in1 = viSpk1(vii_in1);
            viClu(iSpk_out1) = mode(viClu(viSpk_in1));
        end
        S_clu.viClu_prematch = S_clu.viClu;
        S_clu.viClu = viClu;
        frac_changed = mean(S_clu.viClu_prematch ~= S_clu.viClu);

    case 1
        for iSite = 1:nSites
            [vii_spkout1, trWav_in1, viClu_in1] = ...
                deal(cviiSpk_out_site{iSite}, ctrWav_in_site{iSite}, cviClu_in_site{iSite});
            if isempty(viClu_in1), continue; end
            if isempty(vii_spkout1), continue; end
            mrWav_spkout1 = fh_mr(viSpk_out(vii_spkout1))';
            nClu_site1 = size(trWav_in1,3);
            trWav_in1 = gpuArray_(trWav_in1, P.fGpu);
            mrWav_spkout1 = gpuArray_(mrWav_spkout1, P.fGpu);
            mrDist1 = inf(numel(vii_spkout1), numel(viShift), 'like', mrWav_spkout1);
            miiClu_min1 = zeros(numel(vii_spkout1), numel(viShift), 'int32');
            vrWin11 = std(mrWav_spkout1);
            for iShift = 1:numel(viShift)
                mrTemplate11 = shift_tr2mr_(trWav_in1, viShift(iShift))';
                switch 1
                    case 5
%                         vrWin11 = std(mrTemplate11);
%                         vrWin11 = hanning(size(mrTemplate11,2))';
                        [mrDist1(:,iShift), vii_] = pdist2(mrTemplate11.*vrWin11, mrWav_spkout1.*vrWin11, 'euclidean', 'smallest', 1);            
                    case 4
                        [mrDist1(:,iShift), vii_] = pdist2(mrTemplate11, mrWav_spkout1, 'euclidean', 'smallest', 1);
                    case 3
                        [mrDist1(:,iShift), vii_] = min(pdist2(mrTemplate11, mrWav_spkout1, 'cityblock'),[],1);              
                    case 2
                        [mrDist1(:,iShift), vii_] = min(maddist2_(mrTemplate11, mrWav_spkout1),[],1);                  
                    case 1
                        [mrDist1(:,iShift), vii_] = min(pdist2(mrTemplate11, mrWav_spkout1),[],1);  
                end
                miiClu_min1(:,iShift) = gather_(vii_);
            end
            [~, viMin1] = min(mrDist1, [], 2);
            vi_ = sub2ind(size(mrDist1), (1:size(mrDist1,1))', viMin1);
            viClu_spkout(vii_spkout1) = viClu_in1(miiClu_min1(vi_));
            fprintf('.');
        end
    S_clu.viClu_prematch = S_clu.viClu;
    S_clu.viClu(viSpk_out) = viClu_spkout;
    frac_changed = mean(S_clu.viClu_prematch ~= S_clu.viClu);
end %switch
fprintf('\n\tReassigned %0.1f%% spikes, took %0.1fs\n', frac_changed*100, toc(t1));

% merge the templates
if 1
    nClu = S_clu.nClu;
    fprintf('Merging templates\n\t'); t_merge=tic;
    fh_norm = @(x)bsxfun(@rdivide, x, std(x,1)*sqrt(size(x,1)));
    switch 2
        case 2, fh_norm_tr = @(x)fh_norm(reshape(x, [], size(x,3)));
        case 1, fh_norm_tr = @(x)fh_norm(reshape(meanSubt_(x), [], size(x,3)));
    end
    mrDist_clu = nan(S_clu.nClu, 'single');
    for iClu1 = 1:S_clu.nClu
        viSite1 = cviSite_in_clu{iClu1};
        if isempty(viSite1), continue; end
        mr1_ = fh_norm_tr(ctrWav_in_clu{iClu1});
        if 1 %shift template in time
            mr1_ = fh_norm_tr(shift_trWav_(ctrWav_in_clu{iClu1}, viShift));
            viSite1 = repmat(viSite1(:), numel(viShift), 1);
        end
        for iClu2 = iClu1+1:S_clu.nClu
            viSite2 = cviSite_in_clu{iClu2};
            viSite12 = intersect(viSite1, viSite2);
            if isempty(viSite12), continue; end
            mr2_ = fh_norm_tr(ctrWav_in_clu{iClu2});        
            for iSite12_ = 1:numel(viSite12)
                iSite12 = viSite12(iSite12_);
                mrDist12 = mr2_(:, viSite2==iSite12)' * mr1_(:, viSite1==iSite12);
                mrDist_clu(iClu2, iClu1) = max(mrDist_clu(iClu2, iClu1), max(mrDist12(:)));
            end
        end
        fprintf('.');
    end %for
    mlWavCor_clu = mrDist_clu >= P.maxWavCor;
    viMap_clu = int32(ml2map_(mlWavCor_clu));
    vlPos = S_clu.viClu > 0;
    S_clu.viClu(vlPos) = viMap_clu(S_clu.viClu(vlPos)); %translate cluster number
    S_clu = S_clu_refresh_(S_clu);
    nClu_post = S_clu.nClu;
    nClu_pre = nClu;
    fprintf('\nMerged %d waveforms (%d->%d), took %0.1fs\n', nClu-nClu_post, nClu, nClu_post, toc(t_merge));
end
end %func


%--------------------------------------------------------------------------
function mrD12 = maddist2_(mr1, mr2)
% [mr1, mr2] = deal(mr1', mr2');
mr1 = gather_(mr1');
mr2 = gather_(mr2');
mrD12 = zeros(size(mr1,2), size(mr2,2), 'single');
try
    parfor i2=1:size(mr2,2)
        mrD12(:,i2) = median_(abs(mr1 - mr2(:,i2)));
    end
catch
    for i2=1:size(mr2,2)
        mrD12(:,i2) = median_(abs(mr1 - mr2(:,i2)));
    end
end
end %func


%--------------------------------------------------------------------------
function vr = median_(mr)
vr = sort(mr);
imid = ceil(size(mr,1)/2);
vr = vr(imid,:);
end %func


%--------------------------------------------------------------------------
function mrWav_spk1 = tr2mr_mean_knn_(tnWav_spk, miKnn, viSite_spk, viSpk1)
mrWav_spk1 = zeros(size(tnWav_spk,1)*size(tnWav_spk,2), numel(viSpk1), 'single');
viSite_spk1 = viSite_spk(viSpk1);
for ii1 = 1:numel(viSpk1)
    vi1 = miKnn(:,viSpk1(ii1));
    vi1 = vi1(viSite_spk(vi1) == viSite_spk1(ii1));
    mr1 = mean(single(tnWav_spk(:,:,vi1)), 3);
    mrWav_spk1(:,ii1) = mr1(:);
end
end %func


%--------------------------------------------------------------------------
% Denoise waveform using svd
function tnWav_spk1 = tr_denoise_site_(tnWav_spk, viSite_spk, P)
% Usages
% -----
% tnWav_spk1 = tr_denoise_site_(tnWav_spk)
% tnWav_spk1 = tr_denoise_site_(tnWav_spk, viSite_spk, P)

if nargin<2, viSite_spk = ones(1, size(tnWav_spk,3));  end
if nargin<3, P=[]; end

nPc = 5;
fprintf('Denoising using pca...\n\t'); t1=tic;
[nT, nC, nSpk] = size(tnWav_spk);
tnWav_spk1 = zeros(size(tnWav_spk), 'like', tnWav_spk);
if ~isempty(P)
    nSites = numel(P.viSite2Chan);
else
    nSites = max(viSite_spk);
end

for iSite = 1:nSites
    viSpk1 = find(viSite_spk==iSite);
    if isempty(viSpk1), continue; end
    trWav1 = tnWav_spk(:,:,viSpk1);
    trWav1 = single(permute(trWav1, [1,3,2]));
    for iC = 1:nC
        mr_ = meanSubt_(trWav1(:,:,iC));
        [V_,D_] = eig(mr_ * mr_');
        V_ = V_(:,end-nPc+1:end);
        tnWav_spk1(:,iC,viSpk1) = V_ * (V_' * mr_);;
    end
    fprintf('.');
end
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% Denoise waveform using svd
function tnWav_spk1 = tr_denoise_knn_(tnWav_spk, miKnn, P)
nPc = 5;
fprintf('Denoising using pca...\n'); t1=tic;
[nT, nC, nSpk] = size(tnWav_spk);
tnWav_spk1 = zeros(size(tnWav_spk), 'like', tnWav_spk);
parfor iSpk = 1:nSpk
    mrWav1 = single(reshape(tnWav_spk(:,:,miKnn(:,iSpk)), nT, []));
    
    mrWav1 = mrWav1 - mean(mrWav1);
    [V,D] = eig(mrWav1 * mrWav1');
    V = V(:,end-nPc+1:end);
    tnWav_spk1(:,:,iSpk) = V * (V' * mrWav1(:,1:nC));
    
%     [a,b,c] = pca(single(mrWav1), 'NumComponents', nPc);
%     tnWav_spk(:,:,iSpk) = b*a(1:nC,:)';
%     myfig; plot(mrWav1(:,1:nC)); myfig; plot(mrWav2);
end
fprintf('\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 10/1/2018 JJJ: template matching at the cluster outer edge using core set
% assume all spikes come from the same site
function S_clu = featureMatch_post_(S_clu, P)
global trFet_spk

fprintf('Feature matching (post-hoc)\n\t'); t1=tic;

[viClu, miKnn] = struct_get_(S_clu, 'viClu', 'miKnn');
frac_thresh = get_set_(P, 'thresh_core_knn', .75);
nTemplates = get_set_(P, 'nTemplates_clu', 100); %P.knn;

% create template (nTemplate per cluster)
[cviSpk_in_clu, cviSpk_out_clu, cmrFet_in_clu, cviSite_in_clu] = deal(cell(S_clu.nClu, 1));
% fh_mr = @(vi)single(reshape(tnWav_spk(:,:,vi), [], numel(vi)));
% fh_med = @(vi)single(median(tnWav_spk(:,:,vi),3));
% fh_mean = @(vi)single(mean(tnWav_spk(:,:,vi),3));
% fh_pv1 = @(vi)tr_pv1_(single(tnWav_spk(:,:,vi)));
% fh_meanalign = @(vi)tr_mean_align_(single(tnWav_spk(:,:,vi)));
% fh_trimmean = @(vi)tr2mr_trimmean_(mrFet_spk(:,1,vi)));
viSite_spk = get0_('viSite_spk');
nSites = max(viSite_spk);

for iClu = 1:S_clu.nClu
    % identify spikes to recluster by segregating into core-set and outer-set     
    viSpk1 = find(S_clu.viClu == iClu);
    viSpk1 = viSpk1(:);
    viSite_clu1 = viSite_spk(viSpk1);
    miKnn_clu1 = miKnn(:,viSpk1);
    vrFracSame_spk1 = mean(viClu(miKnn_clu1) == iClu);
    vlCore1 = vrFracSame_spk1 >= frac_thresh;
    viSpk_clu1 = viSpk1(vlCore1);
    cviSpk_in_clu{iClu} = viSpk_clu1;
    cviSpk_out_clu{iClu} = viSpk1(~vlCore1);
    
    % create a template using core-set members
    viiSpk1 = subsample_vr_(find(vlCore1), nTemplates);  
    if isempty(viiSpk1), continue; end
    mrFet11 = zeros(size(trFet_spk,1), numel(viiSpk1), 'single');
    viSite11 = viSite_spk(viSpk1(viiSpk1));
    miKnn11 = miKnn_clu1(:,viiSpk1);
    for ii1 = 1:numel(viiSpk1)
        iSite11 = viSite11(ii1);
        viSpk11 = miKnn11(:,ii1);   
        viSpk11 = viSpk11(viSite_spk(viSpk11) == iSite11);
        if 1
            viSpk11 = miKnn(1:2, viSpk11);
            viSpk11 = viSpk11(viSite_spk(viSpk11(:)) == iSite11);
        end
        mrFet11(:,ii1) = mean(squeeze_(trFet_spk(:,1,viSpk11)),2);
    end
    cmrFet_in_clu{iClu} = mrFet11;
    cviSite_in_clu{iClu} = viSite11;
end

% Match outer-set members to cluster templates
viSpk_out = cell2mat_(cviSpk_out_clu);
viSite_spkout = viSite_spk(viSpk_out);
cviiSpk_out_site = arrayfun(@(i)find(viSite_spkout==i), 1:nSites, 'UniformOutput', 0);
fh_dist = @(mr, vr)sum(bsxfun(@minus, mr, vr).^2);
viClu_spkout = zeros(numel(viSpk_out), 1);
% find template locations by sites
[cmrFet_in_site, cviClu_in_site] = deal(cell(1, nSites));
for iSite = 1:nSites
    [cmrFet_, cviClu_] = deal(cell(1, S_clu.nClu));
    for iClu = 1:S_clu.nClu
        [mrFet_in1, viSite_in1] = deal(cmrFet_in_clu{iClu}, cviSite_in_clu{iClu});
        vl_ = viSite_in1==iSite;
        if ~any(vl_), continue; end
        cmrFet_{iClu} = mrFet_in1(:,vl_);
        cviClu_{iClu} = repmat(iClu, sum(vl_), 1);
    end
    cmrFet_in_site{iSite} = cat(2, cmrFet_{:});
    cviClu_in_site{iSite} = cat(1, cviClu_{:});
end

% template matching step
for iSite = 1:nSites
    [vii_spkout1, mrFet_in1, viClu_in1] = ...
        deal(cviiSpk_out_site{iSite}, cmrFet_in_site{iSite}, cviClu_in_site{iSite});
    if isempty(viClu_in1), continue; end
    mrFet_spkout1 = squeeze_(trFet_spk(:,1,viSpk_out(vii_spkout1)));
    nClu_site1 = size(mrFet_in1,2);
    mrFet_in1 = gpuArray_(mrFet_in1, P.fGpu);
    mrFet_spkout1 = gpuArray_(mrFet_spkout1, P.fGpu);
    [~, viMin1] = min(pdist2_(mrFet_in1', mrFet_spkout1'));
    viClu_spkout(vii_spkout1) = viClu_in1(viMin1);
    fprintf('.');
end
S_clu.viClu_prematch = S_clu.viClu;
S_clu.viClu(viSpk_out) = viClu_spkout;
frac_changed = mean(S_clu.viClu_prematch ~= S_clu.viClu);
fprintf('\n\tReassigned %0.1f%% spikes, took %0.1fs\n', frac_changed*100, toc(t1));

% merge the templates
if 1
    nClu = S_clu.nClu;
    fprintf('Merging templates\n\t'); t_merge=tic;
    fh_norm = @(x)bsxfun(@rdivide, meanSubt_(x), std(x,1)*sqrt(size(x,1)));
    mrDist_clu = nan(S_clu.nClu, 'single');
    for iClu1 = 1:S_clu.nClu
        viSite1 = cviSite_in_clu{iClu1};
        if isempty(viSite1), continue; end
        mr1_ = fh_norm(cmrFet_in_clu{iClu1});
        for iClu2 = iClu1+1:S_clu.nClu
            viSite2 = cviSite_in_clu{iClu2};
            viSite12 = intersect(viSite1, viSite2);
            if isempty(viSite12), continue; end
            mr2_ = fh_norm(cmrFet_in_clu{iClu2});        
            for iSite12_ = 1:numel(viSite12)
                iSite12 = viSite12(iSite12_);
                mrDist12 = mr2_(:, viSite2==iSite12)' * mr1_(:, viSite1==iSite12);
                mrDist_clu(iClu2, iClu1) = max(mrDist_clu(iClu2, iClu1), max(mrDist12(:)));
            end
        end
        fprintf('.');
    end %for
    mlWavCor_clu = mrDist_clu >= P.maxWavCor;
    viMap_clu = int32(ml2map_(mlWavCor_clu));
    vlPos = S_clu.viClu > 0;
    S_clu.viClu(vlPos) = viMap_clu(S_clu.viClu(vlPos)); %translate cluster number
    S_clu = S_clu_refresh_(S_clu);
    nClu_post = S_clu.nClu;
    nClu_pre = nClu;
    fprintf('\nMerged %d waveforms (%d->%d), took %0.1fs\n', nClu-nClu_post, nClu, nClu_post, toc(t_merge));
end
end %func


%--------------------------------------------------------------------------
function mr = tr_mean_align_(tr)
mr = reshape(tr,[],size(tr,3));

figure; hold on;
vr_mean = mean(mr,2);
for iRepeat = 1:3
    vr_rms = sum(bsxfun(@minus, mr, vr_mean).^2);
    vr_mean = mean(mr(:,vr_rms<=median(vr_rms)),2);
    vr_mean_a = vr_mean([2:end,end]);
    vr_mean_b = vr_mean([1,1:end-1]);
    [~,viMax] = max([vr_mean, vr_mean_a, vr_mean_b]' * mr);
    mr(:,viMax==2) = mr([1,1:end-1],viMax==2);
    mr(:,viMax==3) = mr([2:end,end],viMax==3);
    vr_mean = mean(mr,2);
    
    plot(vr_mean);
end

end %func


%--------------------------------------------------------------------------
function mrPv = tr_pv1_(tr)
mr = reshape(tr,[],size(tr,3));
[vrPc,vrPv,c] = pca(mr, 'NumComponents', 1);
mrPv = reshape(vrPv*mean(vrPc), size(tr,1), size(tr,2));
end %func


%--------------------------------------------------------------------------
function mr_shift = shift_tr2mr_(tr, nShift)
n = size(tr,1);
vi0 = 1:n;
vi_ = min(max(vi0 + nShift, 1), n);
mr_shift = reshape(tr(vi_,:,:), [], size(tr,3));
end %func


%--------------------------------------------------------------------------
function mr_shift = shift_mrWav_(mr, viShift)
mr_shift = zeros(numel(mr), numel(viShift), 'single');
n = size(mr,1);
vi0 = 1:n;
for iShift = 1:numel(viShift)
    vi_ = min(max(vi0 + viShift(iShift), 1), n);
    vr_ = mr(vi_,:);
    mr_shift(:,iShift) = vr_(:);
end
end %func


%--------------------------------------------------------------------------
function tr = shift_trWav_(tr, viShift)
ctr = cell(numel(viShift), 1);
n = size(tr,1);
vi0 = 1:n;
for iShift=1:numel(viShift)
    iShift_ = viShift(iShift);
    switch 1
        case 2
            ctr{iShift} = interp1(vi0, tr, vi0 + iShift_, 'pchip', 'extrap'); 
        case 1
            vi_ = min(max(vi0 + iShift_, 1), n);
            ctr{iShift} = tr(vi_,:,:);
    end
end %for
tr = cat(3, ctr{:});
end % func


%--------------------------------------------------------------------------
function S_clu = post_merge_wav_(S_clu, fMerge, P)
fRemove_duplicate = get_set_(P, 'fRemove_duplicate', 1);
S_clu = rmfield_(S_clu, 'trWav_raw_clu', 'tmrWav_raw_clu', 'mrWavCor');

mrDist_site = pdist(P.mrSiteXY); 
dist_merge = min(mrDist_site(mrDist_site>0));
% dist_merge = get_set_(P, 'maxDist_site_merge_um', 35);

if fMerge
    maxWavCor = get_set_(P, 'maxWavCor', 1);
    if maxWavCor < 1 && maxWavCor > 0
    %    for merge_factor = [.1, 1]
        for merge_factor = [1]
            S_clu = post_merge_wav4_(S_clu, merge_factor*dist_merge, P);
        end
    end %if
end

% Old format compatibility
S_clu = S_clu_wav_(S_clu);
S_clu.mrWavCor = S_clu_wavcor_(S_clu, P);  

if fRemove_duplicate
    [~,viSite_min_clu] = min(min(S_clu.tmrWav_spk_clu),[],2);
    vrDist_clu = sqrt(sum((P.mrSiteXY(S_clu.viSite_clu,:) - P.mrSiteXY(viSite_min_clu,:)).^2, 2));
    vlKeep_clu = vrDist_clu < P.maxDist_site_um;    
    if ~all(vlKeep_clu)
        S_clu = S_clu_keep_(S_clu, vlKeep_clu); 
        fprintf('%d duplicate units removed\n', sum(~vlKeep_clu));
    end    
end
end %func


%--------------------------------------------------------------------------
% 9/3/2018 JJJ: pca based waveform merging
function S_clu = post_merge_wav5_(S_clu, dist_merge_um, P)
% use centroid based method
% fRemove_duplicate = 1;
% global trFet_spk
% S_clu = rmfield_(S_clu, 'trWav_raw_clu', 'tmrWav_raw_clu', 'mrWavCor');
% compute waveforms for cluster centers
% Compute spkwav
MAX_SAMPLE = 4000;        
FRAC_NEAR = 1/2; % 1/2 is better than 1/4
% NUM_PCA = 2;
WAV_COR = P.maxWavCor;
% WAV_COR = 1;

tnWav_spk = get_spkwav_(P, 0); % use raw waveform
% nCl = numel(S_clu.icl);
viSite_spk = get0_('viSite_spk');
mrPos_spk = get0_('mrPos_spk');
% assert no empty clusters
nClu = max(S_clu.viClu);
cviSpk_clu = arrayfun(@(x)find(S_clu.viClu==x), 1:nClu, 'UniformOutput', 0);
cviSpk_sub_clu = cellfun(@(x)subsample_vr_(x,MAX_SAMPLE), cviSpk_clu, 'UniformOutput', 0);
cviSite_sub_clu = cellfun(@(x)viSite_spk(x), cviSpk_sub_clu, 'UniformOutput', 0);
cmrPos_sub_clu = cellfun(@(x)mrPos_spk(x,:), cviSpk_sub_clu, 'UniformOutput', 0);
cvrPos_sub_clu = cellfun(@(x)sum(x'.^2), cmrPos_sub_clu, 'UniformOutput', 0);
ctrWav_sub_clu = cellfun(@(vi_)single(tnWav_spk(:,:,vi_)), cviSpk_sub_clu, 'UniformOutput', 0);

% determine cluster centers
mrPos_clu = cell2mat(cellfun(@(x)median(mrPos_spk(x,:))', cviSpk_sub_clu, 'UniformOutput', 0))';
mrDist_clu = squareform(pdist(mrPos_clu));

t1=tic;
mlWavCor_clu = set_diag_(false(nClu), true(nClu,1));
miSites = P.miSites;
norm_ = @(x)(x-mean(x))/std(x,1);
corr_ = @(x,y)mean(norm_(x).*norm_(y));
frac_shift_merge = get_set_(P, 'frac_shift_merge', .1);
nShift = round(frac_shift_merge * size(tnWav_spk,1));
viShift = -nShift:nShift;
for iClu1 = 1:nClu
    viClu2 = find(mrDist_clu(1:iClu1-1,iClu1) <= dist_merge_um); %<= P.maxDist_site_um);    
    if isempty(viClu2), continue; end
    
    [viSpk1, viSite_spk1, trWav_spk1] = ...
        deal(cviSpk_sub_clu{iClu1}, cviSite_sub_clu{iClu1}, ctrWav_sub_clu{iClu1});
    [mrPos1_T, vrPos1] = deal(cmrPos_sub_clu{iClu1}', cvrPos_sub_clu{iClu1});
    vlWavCor1 = mlWavCor_clu(:,iClu1);
    
    for iClu2_ = 1:numel(viClu2)            
        iClu2 = viClu2(iClu2_);
        vlWavCor2 = mlWavCor_clu(:,iClu2) | mlWavCor_clu(iClu2,:)';
        vlWavCor2 = any(mlWavCor_clu(:,vlWavCor2),2);
        vlWavCor1 = any(mlWavCor_clu(:,vlWavCor1),2);
        if any(vlWavCor2 & vlWavCor1)
            vlWavCor1(vlWavCor2) = true;
%             vlWavCor1(iClu2) = true; 
            continue;
        end              
        
        [viSpk2, viSite_spk2, trWav_spk2] = ...
            deal(cviSpk_sub_clu{iClu2}, cviSite_sub_clu{iClu2}, ctrWav_sub_clu{iClu2});
        [mrPos2, vrPos2] = deal(cmrPos_sub_clu{iClu2}, cvrPos_sub_clu{iClu2});
        mrDist21 = bsxfun(@plus, vrPos1, bsxfun(@minus, vrPos2', 2*mrPos2*mrPos1_T)); %faster
        [viSpk1_, viiSpk1_] = sortby_(viSpk1, min(mrDist21,[],1), 'ascend');
        [viSpk2_, viiSpk2_] = sortby_(viSpk2, min(mrDist21,[],2), 'ascend');
        [viSpk1_, viiSpk1_] = deal(viSpk1_(1:end*FRAC_NEAR), viiSpk1_(1:end*FRAC_NEAR));
        [viSpk2_, viiSpk2_] = deal(viSpk2_(1:end*FRAC_NEAR), viiSpk2_(1:end*FRAC_NEAR));
        [viSite_spk1_, viSite_spk2_] = deal(viSite_spk1(viiSpk1_), viSite_spk2(viiSpk2_));
        [iSite1_, iSite2_] = deal(mode(viSite_spk1_), mode(viSite_spk2_));
        [viSite1_, viSite2_] = deal(miSites(:,iSite1_), miSites(:,iSite2_));
                
        if iSite1_ ~= iSite2_
            [~, viSite12_, viSite21_] = intersect(viSite1_, viSite2_); % don't repeat
            trSpk1_ = trWav_spk1(:,viSite12_,viiSpk1_(viSite_spk1_==iSite1_));
            trSpk2_ = trWav_spk2(:,viSite21_,viiSpk2_(viSite_spk2_==iSite2_));
        else
            trSpk1_ = trWav_spk1(:,:,viiSpk1_(viSite_spk1_==iSite1_));
            trSpk2_ = trWav_spk2(:,:,viiSpk2_(viSite_spk2_==iSite2_));           
        end
%         mr1_ = tr_pv_(trSpk1_, NUM_PCA);
%         mr2_ = tr_pv_(trSpk2_, NUM_PCA);
%         mr1_ = pca(reshape(trSpk1_, size(trSpk1_,1), [])', 'NumComponents', NUM_PCA);
%         mr2_ = pca(reshape(trSpk2_, size(trSpk2_,1), [])', 'NumComponents', NUM_PCA);
%         wavcor12_ = mr1_(:)' * mr2_(:) / NUM_PCA;

% %         [mrSpk1_, mrSpk2_] = deal(gpuArray_(tnSpk1_, P.fGpu), gpuArray_(tnSpk2_, P.fGpu));
        [mrSpk1_, mrSpk2_] = deal(mean(trSpk1_,3), mean(trSpk2_,3));
        wavcor12_ = corr_(mrSpk1_(:), mrSpk2_(:));
        vlWavCor1(iClu2) = wavcor12_ >= WAV_COR; 
    end %for
    mlWavCor_clu(:,iClu1) = vlWavCor1;
    fprintf('.');
end 
% fprintf('\n\t%0.1fs\n', toc(t1));

% Generate a map and merge clusters by translating index
viMap_clu = int32(ml2map_(mlWavCor_clu));
vlPos = S_clu.viClu > 0;
S_clu.viClu(vlPos) = viMap_clu(S_clu.viClu(vlPos)); %translate cluster number
S_clu = S_clu_refresh_(S_clu);
nClu_post = numel(unique(viMap_clu));
nClu_pre = nClu;
fprintf('\nMerged %d waveforms (%d->%d), took %0.1fs\n', nClu-nClu_post, nClu, nClu_post, toc(t1));

end %func


%--------------------------------------------------------------------------
function [mrPv1, vrD1] = tr_pv_(tr, nPc)
mr = reshape(tr, size(tr,1), []);
mr = bsxfun(@minus, mr, mean(mr));
mrCov = mr*mr';

% tr_ = reshape(mr, size(tr));
% mrCov = zeros(size(tr,1));
% for i=1:size(tr,3)
%     mr_ = tr_(:,:,i);
%     mrCov = mrCov + mr_*mr_';
% end
% mrCov = mrCov / size(tr,3);

% mr = mean(tr,3);
% mr = bsxfun(@minus, mr, mean(mr));
% mrCov = mr*mr';

[mrPv1, vrD1] = eig(mrCov); 
vrD1 = flipud(diag(vrD1));
mrPv1 = fliplr(mrPv1);

if nargin<2, nPc = size(mrPv1,2); end
    
% mr = reshape(mr, [], size(tr,3));
% mrCov = mr * mr';
if nargin>=2
    mrPv1 = mrPv1(:,1:nPc); 
    vrD1 = vrD1(1:nPc);
end

vlFlip = abs(min(mrPv1)) < abs(max(mrPv1));
mrPv1(:,vlFlip) = -mrPv1(:,vlFlip);
end %func


%--------------------------------------------------------------------------
function S_clu = post_merge_wav4_(S_clu, dist_merge_um, P)
% use centroid based method
% fRemove_duplicate = 1;
% global trFet_spk
% S_clu = rmfield_(S_clu, 'trWav_raw_clu', 'tmrWav_raw_clu', 'mrWavCor');
% compute waveforms for cluster centers
% Compute spkwav
MAX_SAMPLE = 4000;        
FRAC_NEAR = 1/2; % 1/2 is better than 1/4
vcMode_dist = 'space'; % time, space, spacetime
fUseFirstBurst = 1; % 9/14/2018 JJJ: only use the first spike in burst to compute ave waveform

tnWav_spk = get_spkwav_(P, 0); % use raw waveform
[viSite_spk, mrPos_spk, dimm_fet, viTime_spk] = ...
    get0_('viSite_spk', 'mrPos_spk', 'dimm_fet', 'viTime_spk');
viTime_spk = viTime_spk(:);
% nSites_fet = dimm_fet(1) / P.nPcPerChan;;
n_burst = round(read_cfg_('interval_ms_burst') * P.sRateHz / 1000);

% assert no empty clusters
nClu = max(S_clu.viClu);
cviSpk_clu = arrayfun(@(x)find(S_clu.viClu==x), 1:nClu, 'UniformOutput', 0);
[cviSpk_burst0_clu, cviSpk_burst1_clu] = cellfun(@(x)separate_burst_(x, viTime_spk, n_burst), cviSpk_clu, 'UniformOutput', 0);
vrFracBurst_clu = cellfun(@numel,cviSpk_burst1_clu) ./ cellfun(@numel,cviSpk_clu);
if ~fUseFirstBurst, cviSpk_burst0_clu = cviSpk_clu; end
cviSpk_sub_clu = cellfun(@(x)subsample_vr_(x,MAX_SAMPLE), cviSpk_burst0_clu, 'UniformOutput', 0);
cviSite_sub_clu = cellfun(@(x)viSite_spk(x), cviSpk_sub_clu, 'UniformOutput', 0);
cmrPos_sub_clu = cellfun(@(x)mrPos_spk(x,:), cviSpk_sub_clu, 'UniformOutput', 0);
cvrPos_sub_clu = cellfun(@(x)sum(x'.^2), cmrPos_sub_clu, 'UniformOutput', 0);
ctrWav_sub_clu = cellfun(@(vi_)single(tnWav_spk(:,:,vi_)), cviSpk_sub_clu, 'UniformOutput', 0);
cviTime_sub_clu = cellfun(@(vi_)viTime_spk(vi_), cviSpk_sub_clu, 'UniformOutput', 0);

% determine cluster centers
mrPos_clu = cell2mat(cellfun(@(x)median(mrPos_spk(x,:))', cviSpk_sub_clu, 'UniformOutput', 0))';
mrDist_clu = squareform(pdist(mrPos_clu));

t1=tic;
mlWavCor_clu = set_diag_(false(nClu), true(nClu,1));
miSites = P.miSites;
diff_rat_ = @(x,y)abs(x-y)/max(x,y);
% norm_ = @(x)(x-mean(x))/std(x,1);
% corr_ = @(x,y)mean(norm_(x).*norm_(y));
frac_shift_merge = get_set_(P, 'frac_shift_merge', .1);
nShift = round(frac_shift_merge * size(tnWav_spk,1));
viShift = -nShift:nShift;
for iClu1 = 1:nClu
    viClu2 = find(mrDist_clu(1:iClu1-1,iClu1) <= dist_merge_um); %<= P.maxDist_site_um);    
    if isempty(viClu2), continue; end
    
    [viSpk1, viSite_spk1, trWav_spk1] = ...
        deal(cviSpk_sub_clu{iClu1}, cviSite_sub_clu{iClu1}, ctrWav_sub_clu{iClu1});
    [mrPos1_T, vrPos1] = deal(cmrPos_sub_clu{iClu1}', cvrPos_sub_clu{iClu1});
    vlWavCor1 = mlWavCor_clu(:,iClu1);
    
    for iClu2_ = 1:numel(viClu2)            
        iClu2 = viClu2(iClu2_);
        vlWavCor2 = mlWavCor_clu(:,iClu2) | mlWavCor_clu(iClu2,:)';
        vlWavCor2 = any(mlWavCor_clu(:,vlWavCor2),2);
        vlWavCor1 = any(mlWavCor_clu(:,vlWavCor1),2);
        if any(vlWavCor2 & vlWavCor1)
            vlWavCor1(vlWavCor2) = true;
            continue;
        end              
        
        [viSpk2, viSite_spk2, trWav_spk2] = ...
            deal(cviSpk_sub_clu{iClu2}, cviSite_sub_clu{iClu2}, ctrWav_sub_clu{iClu2});
        [mrPos2, vrPos2] = deal(cmrPos_sub_clu{iClu2}, cvrPos_sub_clu{iClu2});
        switch vcMode_dist
            case 'space'
                mrDist21 = bsxfun(@plus, vrPos1, bsxfun(@minus, vrPos2', 2*mrPos2*mrPos1_T));
            case 'time'
                mrDist21 = abs(bsxfun(@minus, cviTime_sub_clu{iClu2}, cviTime_sub_clu{iClu1}'));
            case 'spacetime'
                mrDist21_s = bsxfun(@plus, vrPos1, bsxfun(@minus, vrPos2', 2*mrPos2*mrPos1_T));
                mrDist21_t = abs(bsxfun(@minus, cviTime_sub_clu{iClu2}, cviTime_sub_clu{iClu1}'));
                rat_ = median(min(mrDist21_s)) / single(median(min(mrDist21_t)));
                mrDist21 = mrDist21_s + single(mrDist21_t) * rat_;
        end
        [viSpk1_, viiSpk1_] = sortby_(viSpk1, min(mrDist21,[],1), 'ascend');
        [viSpk2_, viiSpk2_] = sortby_(viSpk2, min(mrDist21,[],2), 'ascend');
        [viSpk1_, viiSpk1_] = deal(viSpk1_(1:end*FRAC_NEAR), viiSpk1_(1:end*FRAC_NEAR));
        [viSpk2_, viiSpk2_] = deal(viSpk2_(1:end*FRAC_NEAR), viiSpk2_(1:end*FRAC_NEAR));
        [viSite_spk1_, viSite_spk2_] = deal(viSite_spk1(viiSpk1_), viSite_spk2(viiSpk2_));
        [iSite1_, iSite2_] = deal(mode(viSite_spk1_), mode(viSite_spk2_));
        [viSite1_, viSite2_] = deal(miSites(:,iSite1_), miSites(:,iSite2_));

        if iSite1_ ~= iSite2_
            [viSite12_, viSite21_] = intersect_uniq_(viSite1_, viSite2_); % don't repeat
            trSpk1_ = trWav_spk1(:,viSite12_,viiSpk1_(viSite_spk1_==iSite1_));
            trSpk2_ = trWav_spk2(:,viSite21_,viiSpk2_(viSite_spk2_==iSite2_));
        else
            trSpk1_ = trWav_spk1(:,:,viiSpk1_(viSite_spk1_==iSite1_));
            trSpk2_ = trWav_spk2(:,:,viiSpk2_(viSite_spk2_==iSite2_));            
        end
        [mrSpk1_, mrSpk2_] = deal(tr2mr_trimmean_(trSpk1_), tr2mr_trimmean_(trSpk2_));
        mr1_ = tr2mr_norm_(mr2tr_move_(mrSpk1_, viShift))';
        wavcor12_ = max(mr1_ * tr2mr_norm_(mrSpk2_));
        vlWavCor1(iClu2) = wavcor12_ >= P.maxWavCor;
    end %for
    mlWavCor_clu(:,iClu1) = vlWavCor1;
    fprintf('.');
end 
% fprintf('\n\t%0.1fs\n', toc(t1));

% Generate a map and merge clusters by translating index
viMap_clu = int32(ml2map_(mlWavCor_clu));
vlPos = S_clu.viClu > 0;
S_clu.viClu(vlPos) = viMap_clu(S_clu.viClu(vlPos)); %translate cluster number
S_clu = S_clu_refresh_(S_clu);
nClu_post = numel(unique(viMap_clu));
nClu_pre = nClu;
fprintf('\nMerged %d waveforms (%d->%d), took %0.1fs\n', nClu-nClu_post, nClu, nClu_post, toc(t1));
end %func


%--------------------------------------------------------------------------
% denoise using population svd
function mr = tr2mr_denoise_(tr, nPc)
if ismatrix(tr)
    mr=tr; 
    return; 
end
if nargin<2, nPc = []; end
if isempty(nPc), nPc = 1; end

mr = mean(tr,3);
% vr_mean = mean(mr,1);
[a,b,c] = svd(mr , 'econ');
switch 1
    case 4
        mr = mr - vr_mean;
    case 3
        ;
    case 2
        mr = a(:,1:nPc) * b(1:nPc,1:nPc) * c(1:nPc,:);
    case 1
        mr = a(:,1:nPc) * b(1:nPc,:) * c ;
end
% myfig; plot(mr,'k'); plot(mr1,'b');

end %fun


%--------------------------------------------------------------------------
function [mr, vi_use] = tr2mr_trimmean_(tr)
if ismatrix(tr)
    mr=tr; 
    vi_use=1; 
    return; 
end
mr1 = reshape(tr, [], size(tr,3));
fh_err = @(vr_)sum(bsxfun(@minus, mr1, vr_).^2);
% vrErr = sum(bsxfun(@minus, mr1, mean(mr1,2)).^2); % compare mean vs median
vrErr = fh_err(mean(mr1,2));
vi_use = find(vrErr <= median(vrErr)); % use half
if 0
    vrErr = fh_err(mean(mr1(:,vi_use),2));
    vi_use = find(vrErr <= median(vrErr));
end
try
    mr = mean(tr(:,:,vi_use), 3);
catch
    mr = mean(tr,3);
end
end %func


%--------------------------------------------------------------------------
% 9/17/2018 JJJ: Faster ismember function
function [ia,ib] = intersect_uniq_(a,b)
% a and b are already unique
[tf,ib] = ismember(a,b);
ia = find(tf);
ib = ib(ia);
% c = a(ia);
end %func


%--------------------------------------------------------------------------
function [vi_burst0, vi_burst1] = separate_burst_(vi, viTime_spk, n_burst)
vl = diff(viTime_spk(vi)) > n_burst;
vi_burst0 = vi(find(vl)+1);
vi_burst1 = vi(find(~vl)+1);
end %func


%--------------------------------------------------------------------------
function tr1 = nmean_subt_(tr, nSites_fet)
if size(tr,2) <= nSites_fet, return; end
nSpk = size(tr,3);

tr1 = zeros([size(tr,1), nSites_fet, nSpk], 'like', tr);
for iSpk=1:nSpk
    mr_ = tr(:,:,iSpk);
    vr_ = mean(mr_(:,nSites_fet+1:end),2);
    tr1(:,:,iSpk) = bsxfun(@minus, mr_(:,1:nSites_fet), vr_);
end
end %func


%--------------------------------------------------------------------------
function mr = nmean_subt_mr_(mr, nSites_fet)
if size(mr,2) <= nSites_fet, return; end

% mr1 = mr(:,1:nSites_fet);
mr_ref = mr(:,nSites_fet+1:end);
mr = bsxfun(@minus, mr, mean(mr_ref,2));
end %func


%--------------------------------------------------------------------------
function [vr1, ix] = sortby_(vr1, vr2, vcOrder)
% sort vr1 using vr2 order
% arrays only
if nargin<3, vcOrder = 'ascend'; end
[~,ix] = sort(vr2, vcOrder);
vr1 = vr1(ix);
end %func


%--------------------------------------------------------------------------
function [mrWav1, viSite1, iSite1] = mean_wav_spk_(tnWav1, viSite_spk1, miSites)

fFast = 1;

nSites = size(miSites,2);
[nSamples, nSites_fet, nSpk1] = size(tnWav1);
% trWav_ = nan([size(tnWav_spk,1), nSites, numel(viSpk1)], 'single');
% viSite_spk1 = viSite_spk(viSpk1);
% iSite1 = mode(viSite_spk1);
if fFast
    iSite1 = mode(viSite_spk1);
    viSite1 = miSites(:,iSite1);
    mrWav1 = mean(tnWav1(:,:,viSite_spk1==iSite1), 3);
    mrWav1 = single(mrWav1);
    return;
end
[viSite_uniq1, vnSite_uniq1, cviSpk_uniq1] = unique_count_(viSite_spk1);
iSite1 = viSite_uniq1(1);
nUniq1 = numel(cviSpk_uniq1);
viSite1 = miSites(:,iSite1);

viSpk1 = cviSpk_uniq1{1};
mrWav1 = single(mean(tnWav1(:,:,viSpk1),3) * vnSite_uniq1(1));
vnCount_site = ones(1, nSites_fet) * vnSite_uniq1(1);
for iUniq1 = 2:numel(viSite_uniq1)
    iSite2 = viSite_uniq1(iUniq1);
    viSite2 = miSites(:,iSite2);
    viSpk2 = cviSpk_uniq1{iUniq1};
    [~,viSite12_, viSite21_] = intersect(viSite1, viSite2); % don't repeat
    viSite1_nan_ = setdiff(1:nSites_fet, viSite12_);    
    mrWav1(:,viSite12_) = mrWav1(:,viSite12_) + mean(tnWav1(:,viSite21_,viSpk2),3) * vnSite_uniq1(iUniq1);
    vnCount_site(viSite12_) = vnCount_site(viSite12_) + vnSite_uniq1(iUniq1);
end
mrWav1 = bsxfun(@rdivide, mrWav1, vnCount_site);
end %func


%--------------------------------------------------------------------------
function S_clu = post_merge_wav3_(S_clu, nRepeat_merge, P)
% fRemove_duplicate = 1;
% create covariance matrix (mrDist_wav)
t1=tic;
% compute waveforms for cluster centers
% Compute spkwav
tnWav_ = get_spkwav_(P, 0); % use raw waveform
nCl = numel(S_clu.icl);
viSite_spk = get0_('viSite_spk');
S0.mrPos_spk = get0_('mrPos_spk');

minFrac = 0.01;
mrWavCor_cl = zeros(nCl);
% nSites_fet = P.maxSite*2+1-P.nSites_ref;
% nSites_fet = size(tnWav_,2);

for iCl1 = 1:nCl-1 % iterate by site pairs instead?
    viSpk_cl1 = find(S_clu.viClu == iCl1);
    viSite_cl1 = viSite_spk(viSpk_cl1);
    mrPos_cl1 = S0.mrPos_spk(viSpk_cl1,:);
%     iSite_cl1 = mode(viSite_cl1);
%     mrWav_cl1 = mean(tnWav_(:,:,viSpk_cl1(viSite_cl1==iSite_cl1)),3);

    viSpk_cl12 = S_clu.miKnn(:,viSpk_cl1); % check for neighboring clusters
    viSpk_cl12 = S_clu.miKnn(:,viSpk_cl12(:)); % check for neighboring clusters
    viSpk_cl12 = unique(viSpk_cl12(:)); % search within two degrees of separation
    viClu12 = S_clu.viClu(viSpk_cl12);
    
    [viClu12_uniq, vnClu12_uniq] = unique_count_(viClu12);
%     viClu12_uniq = viClu12_uniq(viClu12_uniq~=iCl1);
    vrFrac_cl12 = vnClu12_uniq / sum(vnClu12_uniq);
    viClu12_uniq = viClu12_uniq(vrFrac_cl12 > minFrac & viClu12_uniq > iCl1);
    if isempty(viClu12_uniq), continue; end
    iSite1 = mode(viSite_cl1);
    mrWav1_ = mean(tnWav_(:,:,viSpk_cl1(viSite_cl1==iSite1)),3);
    mrWav1_norm_ = tr2mr_norm_(mr2tr_move_(mrWav1_,-2:2))';
    for iiCl2 = 1:numel(viClu12_uniq)
        iCl2 = viClu12_uniq(iiCl2);
%         viSpk_cl2 = viSpk_cl12(viClu12==iCl2); % overlapping
        viSpk_cl2 = find(S_clu.viClu==iCl2); % all
        viSite_cl2 = viSite_spk(viSpk_cl2);
        mrWav2_ = mean(tnWav_(:,:,viSpk_cl2(viSite_cl2==iSite1)),3);
%         ml_ = miClu12 == iCl2;
%         [viSpk_cl1_, viSpk_cl2_] = deal(viSpk_cl1(any(ml_)), miSpk_cl12(ml_));
%         [viSite_cl1_, viSite_cl2_] = deal(viSite_spk(viSpk_cl1_), viSite_spk(viSpk_cl2_));
%         iSite12_ = mode([viSite_cl1_(:); viSite_cl2_(:)]);
%         mrWav2_ = mean(tnWav_(:,:,viSpk_cl2_(viSite_cl2_==iSite1)),3);
%         mrWav1_ = mean(tnWav_(:,1:nSites_fet,viSpk_cl1_(viSite_cl1_==iSite12_)),3);
%         mrWav2_ = mean(tnWav_(:,1:nSites_fet,viSpk_cl2_(viSite_cl2_==iSite12_)),3);
%         mnWav2_ = mean(tnWav_(:,1:nSites_fet,viSpk_cl2_(viSite_cl2_==iSite1)),3);
        
        mrWavCor_cl(iCl2, iCl1) = max(mrWav1_norm_ * tr2mr_norm_(mrWav2_));
    end
end

% Generate a map and merge clusters by translating index
viMap_cl = int32(ml2map_(mrWavCor_cl >= P.maxWavCor));
vlPos = S_clu.viClu > 0;
S_clu.viClu(vlPos) = viMap_cl(S_clu.viClu(vlPos)); %translate cluster number
S_clu = S_clu_refresh_(S_clu);
nClu_post = numel(unique(viMap_cl));
nClu_pre = nCl;
fprintf('Merged %d waveforms (%d->%d), took %0.1fs\n', nCl-nClu_post, nCl, nClu_post, toc(t1));

end %func


%--------------------------------------------------------------------------
% 8/29/2018 JJJ: Non-iterative, single-pass waveform merging algorithm
function S_clu = post_merge_wav2_(S_clu, nRepeat_merge, P)
% create covariance matrix (mrDist_wav)
t1=tic;
% compute waveforms for cluster centers
% Compute spkwav
tnWav_ = get_spkwav_(P, 0); % use raw waveform
nCl = numel(S_clu.icl);
viSite_spk = get0_('viSite_spk');
trWav_cl = zeros(size(tnWav_,1), size(tnWav_,2), nCl, 'single');
% viSite_cl = viSite_spk(S_clu.icl);
[vpFracSite_cl, vpEqualCl_cl, viSite_cl] = deal(zeros(nCl, 1, 'single'));
% miKnn2 = S_clu.miKnn(1:end/4,:);
% S_clu.vnSpk_clu
for iCl=1:nCl    
    iSpk0_clu_ = S_clu.icl(iCl);
    iClu = S_clu.viClu(iSpk0_clu_);
    assert(iCl==iClu, 'cluster index should not change');
%     viSpk1_cl_ = S_clu.miKnn(:,iSpk0_clu_);
    viSpk2_cl_ = find(S_clu.viClu==iCl);
%     viSpk2_cl_ = miKnn2(:,viSpk1_cl_);  viSpk2_cl_ = viSpk2_cl_(:);
    viSite2_cl_ = viSite_spk(viSpk2_cl_);
%     viSite1_clu_ = viSite_spk(viSpk1_clu_);
    iSite_cl_ = mode(viSite2_cl_);
    viSite_cl(iCl) = iSite_cl_;    
    vl_ = iSite_cl_ == viSite2_cl_; % & iClu0 == S_clu.viClu(viSpk2_clu_); % do not use cluster index for 
    if ~any(vl_), continue; end
    tnWav_cl_ = tnWav_(:,:,viSpk2_cl_(vl_));
%     trWav_cl(:,:,iCl) = tr2mr_pv_(tnWav_cl_);
    trWav_cl(:,:,iCl) = meanSubt_(mean(tnWav_cl_, 3));
    vpFracSite_cl(iCl) = mean(vl_);
end

maxDist_site_merge_um = get_set_(P, 'maxDist_site_merge_um', 35);
mlNear_clu = squareform(pdist(P.mrSiteXY(viSite_cl,:)) <= maxDist_site_merge_um);
mlNear_clu = set_diag_(mlNear_clu, ones(nCl,1));
mrWavCor_cl = zeros(nCl, 'single');
mrWav_norm_cl = tr2mr_norm_(trWav_cl);
% single-pass waveform merge, reindex viClu
for iCl = 1:nCl % iterate by site pairs instead?
    viCl_near_ = find(mlNear_clu(1:iCl,iCl)); % self included at the end
    if isempty(viCl_near_), continue; end
    viSite_near_ = viSite_cl(viCl_near_);
    miSite_cl_near_ = P.miSites(:,viSite_near_);
    [mrWav_cl_, viSite_cl_] = deal(trWav_cl(:,:,iCl), miSite_cl_near_(:,end));
    tmrWav_delay_cl_ = mr2tr_move_(mrWav_cl_, -2:2);
    mrWav_norm_cl_ = tr2mr_norm_(tmrWav_delay_cl_)';
    for iClu_near_ = 1:numel(viCl_near_)
        iClu_ = viCl_near_(iClu_near_);
        if viSite_near_(iClu_near_) == viSite_near_(end)
            mrWavCor_cl(iClu_, iCl) = max(mrWav_norm_cl_ * mrWav_norm_cl(:,iClu_));
        else
            [~,vi1_,vi2_] = intersect(viSite_cl_, miSite_cl_near_(:,iClu_near_));
            mrWav_norm_cl1_ = tr2mr_norm_(tmrWav_delay_cl_(:,vi1_,:))';
            mrWavCor_cl(iClu_, iCl) = max(mrWav_norm_cl1_ * tr2mr_norm_(trWav_cl(:,vi2_,iClu_)));
        end
    end
end

% Generate a map and merge clusters by translating index
mlMerge_cl = mrWavCor_cl >= P.maxWavCor;
viMap_cl = int32(ml2map_(mlMerge_cl));
vlPos = S_clu.viClu > 0;
S_clu.viClu(vlPos) = viMap_cl(S_clu.viClu(vlPos)); %translate cluster number
S_clu = S_clu_refresh_(S_clu);
nClu_post = numel(unique(viMap_cl));
nClu_pre = nCl;
fprintf('Merged %d waveforms (%d->%d), took %0.1fs\n', nCl-nClu_post, nCl, nClu_post, toc(t1));

end %func


%--------------------------------------------------------------------------
function [mrPv, vrD1] = tr2mr_pv_(trWav)
% Extract the first component
trWav = meanSubt_(trWav);
mr_ = reshape(trWav,[],size(trWav,3));

mrCov = mr_ * mr_';
[mrPv1, vrD1] = eig(mrCov);
mrPv1 = zscore_(fliplr(mrPv1)); % sort largest first
vrPv = mrPv1(:,1);
mrPv = reshape(vrPv, [], size(trWav,2));
vrD1 = flipud(diag(vrD1));

% mrMean = mean(trWav,3);
% vrMean = zscore_(mrMean(:));

% spike center should be negative
% iMid = 1-P.spkLim(1);
% vrSign = (mrPv1(iMid,:) < 0) * 2 - 1; %1 or -1 depending on the sign
% mrPv = bsxfun(@times, mrPv1, vrSign);
end %func


%--------------------------------------------------------------------------
function tr = mr2tr_move_(mr, viMove)

% fix tr1 and move tr2
tr = zeros([size(mr,1), size(mr,2), numel(viMove)], 'like', mr);
for iShift = 1:numel(viMove)
    tr(:,:,iShift) = shift_mr_(mr, viMove(iShift));
end
end %func


%--------------------------------------------------------------------------
function [viMapClu, viUniq_] = ml2map_(ml)
% ml: connectivity matrix to merge
% viMapClu: old to new index
nRepeat = 10;

nCl = size(ml,1);
ml = set_diag_(ml | ml', true(nCl,1)); %format ml
viMapClu = 1:nCl;
for iCl = 1:nCl
    viCl_ = find(ml(:,iCl));
    if isempty(viCl_), continue; end
    viMapClu(viCl_) = min(viCl_);
end
for iRepeat = 1:nRepeat
    fChanged = 0;
    for iCl1 = 1:nCl
        iCl1_ = viMapClu(iCl1);
        vi1_ = find(ml(:,iCl1));
        for iCl2 = 1:nCl
            iCl2_ = viMapClu(iCl2);
            if ml(iCl1,iCl2)
                if iCl1_ > iCl2_
                    viMapClu(vi1_) = iCl2_;
                    iCl1_ = iCl2_;
                    fChanged = 1; 
                elseif iCl1_ < iCl2_
                    viMapClu(ml(:,iCl2)) = iCl1_;    
                    fChanged = 1;
                end           
            end
        end
    end
    if ~fChanged, break; end
end

% Compact the map so the index doesn't have a gap
viUniq_ = unique(viMapClu);
viMap_(viUniq_) = 1:numel(viUniq_);
viMapClu = viMap_(viMapClu);
end %func


%--------------------------------------------------------------------------
function [vi_uniq, vn_uniq, cvi_uniq] = unique_count_(vi)
% count number of unique elements and sort by vn_uniq
vi_uniq = unique(vi);
cvi_uniq = arrayfun(@(x)find(vi==x), vi_uniq, 'UniformOutput', 0);
vn_uniq = cellfun(@numel, cvi_uniq);
[vn_uniq, ix] = sort(vn_uniq, 'descend');
vi_uniq = vi_uniq(ix);
cvi_uniq = cvi_uniq(ix);
end %func


%--------------------------------------------------------------------------
function S_clu = post_merge_wav1_(S_clu, nRepeat_merge, P)
% S0 = get(0, 'UserData');
% create covariance matrix (mrDist_wav)
S_clu = S_clu_wav_(S_clu);

S_clu.mrWavCor = S_clu_wavcor_(S_clu, P);  
for iRepeat = 1:nRepeat_merge %single-pass vs dual-pass correction
    [S_clu, nMerges_clu] = S_clu_wavcor_merge_(S_clu, P);
    if nMerges_clu < 1, break; end
end %for

end %func


%--------------------------------------------------------------------------
% 8/22/18 JJJ: Calculate raw cluster waveform
function [tmrWav_raw_clu, trWav_raw_clu] = calc_raw_clu_(S_clu, P)
fprintf('Computing average raw waveforms per unit\n\t'); t1=tic;
S0 = get0_();
nSites = numel(P.viSite2Chan);
[nSamples, nSites_spk] = deal(S0.dimm_spk(1), S0.dimm_spk(2));
if isfield(S_clu, 'nClu')
    nClu = S_clu.nClu;
else
    nClu = max(S_clu.viClu);
end

tnWav_ = get_spkwav_(P, 1);
nSamples_raw = S0.dimm_raw(1);
trWav_raw_clu = zeros(nSamples_raw, nSites_spk, nClu, 'single'); 
tmrWav_raw_clu = zeros(nSamples_raw, nSites, nClu, 'single');

[S_clu.tmrWav_raw_clu, S_clu.trWav_raw_clu] = deal(tmrWav_raw_clu, trWav_raw_clu);
for iClu=1:nClu       
    [mrWav_clu1, viSite_clu1] = clu_wav_(S_clu, tnWav_, iClu, S0);                                
    if isempty(mrWav_clu1), continue; end       
    [tmrWav_raw_clu(:,viSite_clu1,iClu), trWav_raw_clu(:,:,iClu)] = deal(mrWav_clu1 * P.uV_per_bit);
    fprintf('.');
end %clu
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_update_wav_(S_clu, P, S0)
if nargin<2, P = get0_('P'); end
if nargin<3, S0 = get(0, 'UserData'); end

S_clu = S_clu_wav_(S_clu, [], [], S0);

% compute raw waveform if not done yet
if isempty(get_(S_clu, 'tmrWav_raw_clu'))
    [S_clu.tmrWav_raw_clu, S_clu.trWav_raw_clu] = calc_raw_clu_(S_clu, P);
end

S_clu.mrWavCor = S_clu_wavcor_(S_clu, P);  
S_clu.mrWavCor = set_diag_(S_clu.mrWavCor, S_clu_self_corr_(S_clu));
end %func


%--------------------------------------------------------------------------
% 10/12/17 JJJ: Works for non-square matrix and constant. Tested
function mr = set_diag_(mr, vr)
n = min(min(size(mr)), numel(vr));
% m = numel(vr);
% mr(sub2ind([n,n], 1:m, 1:m)) = vr;
mr(sub2ind(size(mr), 1:n, 1:n)) = vr(1:n);
end %func


%--------------------------------------------------------------------------
function [vr, vi] = get_diag_(mr)
n = min(size(mr));
vi = sub2ind([n,n], 1:n, 1:n);
vr = mr(vi);
end %func


%--------------------------------------------------------------------------
function batch_(vcFile_batch, vcCommand)
% batch process parameter files (.batch) file
% batch_(myfile.batch, vcCommand): contains a list of .prm files
% batch_(vcFile_batch, vcFile_template): batch contains .bin files
% batch_(vcFile_batch, vcFile_prb): batch contains .bin files

if nargin<2, vcCommand=[]; end
if isempty(vcCommand), vcCommand = 'run'; end

if matchFileExt_(vcCommand, {'.prm', '.prb'})
    vcFile_template = vcCommand;
    vcCommand = 'run';
    fMakePrm = 1;
else
    vcFile_template = ircpath_(read_cfg_('default_prm'));
    fMakePrm = 0;
end

csFiles_prm = load_batch_(vcFile_batch);
vlFile_err = true(size(csFiles_prm));
csErr_file = cell(size(csFiles_prm));

for iFile = 1:numel(csFiles_prm)
    vcFile_prm_ = csFiles_prm{iFile};
    %if matchFileExt_(vcFile_prm_, {'.bin', '.dat'})
    if ~matchFileEnd_(vcFile_prm_, '.prm')
        vcFile_prm_ = makeprm_(vcFile_prm_, vcFile_template, 0);
    end
    try            
        irc('clear');
        fprintf('Processing file %d/%d: %s\n', iFile, numel(csFiles_prm), vcFile_prm_); 
        irc(vcCommand, vcFile_prm_);
        vlFile_err(iFile) = 0;
    catch
        csErr_file{iFile} = lasterr();
        fprintf(2, 'Error in file %d/%d: %s\n', iFile, numel(csFiles_prm), vcFile_prm_);
        fprintf(2, '\t%s\n\n', csErr_file{iFile});
    end
end %for

% summary
if any(vlFile_err) %error found
    fprintf(2,'Errors found in the .prm files below:\n');
    viFile_err = find(vlFile_err);
    for iErr = 1:numel(viFile_err)
        vcFile_err_ = csFiles_prm{viFile_err(iErr)};
        fprintf(2,'\tError %d/%d: %s\n', iErr, numel(viFile_err), vcFile_err_);
        fprintf(2,'\t\t%s\n\n', csErr_file{iFile});
    end
else
    fprintf('All %d files processed successfully\n', numel(csFiles_prm));
end
edit_(vcFile_batch);
end %func


%--------------------------------------------------------------------------
function [mnWav1, vnWav1_mean] = wav_car_(mnWav1, P)
% take common average referencing (CAR) on the filtered trace (mnWav1)
% fprintf('Common average referencing (CAR)\n\t'); t1=tic;
fRepairSites = 0; % bad sites get repaired by averaging vertical neighbors
vnWav1_mean = [];
switch lower(P.vcCommonRef)
    case {'tmean', 'nmean'}
        trimLim = [.25, .75];    
        maxSite_ref = (P.nSites_ref + P.nSites_excl_ref - 1)/2;
        miSite_ref = findNearSites_(P.mrSiteXY, maxSite_ref, P.viSiteZero, P.viShank_site);
        miSite_ref = miSite_ref(P.nSites_excl_ref+1:end, :); %excl three nearest sites
        viChan_keep = round(trimLim * size(miSite_ref,1));
        viChan_keep = (viChan_keep(1)+1):viChan_keep(2);
        mnWav1_pre = mnWav1;
        if strcmpi(P.vcCommonRef, 'tmean')
            for iChan=1:size(mnWav1,2)
                mnWav2 = sort(mnWav1_pre(:, miSite_ref(:,iChan)), 2);
                gvr_tmean = sum(mnWav2(:,viChan_keep), 2); %may go out of range
                gvr_tmean = int16(single(gvr_tmean)/numel(viChan_keep));
                mnWav1(:,iChan) = mnWav1_pre(:,iChan) - gvr_tmean;
                fprintf('.');
            end
        else
            for iChan=1:size(mnWav1,2)
                gvr_tmean = sum(mnWav1_pre(:, miSite_ref(:,iChan)), 2); %may go out of range
                gvr_tmean = int16(single(gvr_tmean)/size(miSite_ref,1));
                mnWav1(:,iChan) = mnWav1_pre(:,iChan) - gvr_tmean;
                fprintf('.');
            end
        end
        
    case 'mean'
        vnWav1_mean = mean_excl_(mnWav1, P);
        mnWav1 = bsxfun(@minus, mnWav1, vnWav1_mean);
        
    case 'median'
        vnWav1_median = median_excl_(mnWav1, P);
        mnWav1 = bsxfun(@minus, mnWav1, vnWav1_median);        
        
    case 'whiten'
        [mnWav1, mrWhiten] = whiten_(mnWav1, P);
end
% viSiteZero should be treated carefully. try to repair using nearest sites?
if get_(P, 'fMeanSite_drift')
    mnWav1 = meanSite_drift_(mnWav1, P); 
elseif fRepairSites
    mnWav1 = meanSite_drift_(mnWav1, P, P.viSiteZero); 
else
    mnWav1(:, P.viSiteZero) = 0;
end
% fprintf('\n\ttook %0.1fs.\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 17/12/11 JJJ: Created. Apply spatial whitening
function [mnWav2, mrWhiten] = whiten_(mnWav1, P)
nLoads_gpu = get_set_(P, 'nLoads_gpu', 8);
nSamples_max = round(size(mnWav1,1) / nLoads_gpu);
fprintf('Whitening\n\t'); t1 = tic;
[mr_sub, vi_sub] = subsample_mr_(mnWav1, nSamples_max, 1);
viSites = setdiff(1:size(mnWav1,2), P.viSiteZero);
if ~isempty(P.viSiteZero), mr_sub = mr_sub(:,viSites); end
mr_sub = single(mr_sub);

mrXXT = mr_sub' * mr_sub;
[U,D] = eig(mrXXT + eps('single'));
Sinv = diag(1./sqrt(diag(D)));
scale = mean(sqrt(diag(mrXXT)));
mrWhiten = (U * Sinv * U') * scale;

% mr_sub1 = mr_sub * (U * Sinv * U');
% mrXXT1 = mr_sub1' * mr_sub1;
% figure; imagesc(mrXXT1 - eye(size(mrXXT1)))

% apply whitening matrix
mnWav2 = zeros(size(mnWav1), 'like', mnWav1);
if ~isempty(P.viSiteZero), mnWav1 = mnWav1(:,viSites); end
mnWav1 = single(mnWav1);
for iSite1 = 1:numel(viSites)
    iSite = viSites(iSite1);
    mnWav2(:,iSite) = int16(mnWav1 * mrWhiten(:,iSite1));
    fprintf('.');
end %for
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function batch_verify_(vcFile_batch, vcCommand)
% batch process parameter files (.batch) file
% Example
%   irc batch-verify skip my.batch
%       just does the verification plot for all files in .batch file

fShowTable = 0; % show unit SNR table
fVerbose = 0;

if ~exist_file_(vcFile_batch, 1), return; end

% edit_(vcFile_batch); %show script
if nargin<2, vcCommand=[]; end
if isempty(vcCommand), vcCommand='run'; end
csFiles_prm = load_batch_(vcFile_batch);

if ~strcmpi(vcCommand, 'skip')
    for iFile=1:numel(csFiles_prm)
        try
            vcFile_prm1 = csFiles_prm{iFile};
            irc('clear');
            irc(vcCommand, vcFile_prm1);
            if ~contains_(vcCommand, 'verify')
                validate_(loadParam_(vcFile_prm1,0), 0); % try silent verify and collect result
            end
        catch
            disperr_(lasterr());
        end
    end %for
end
fprintf('\nSummary for %s\n', vcFile_batch);

% Collect data
[cvrSnr, cvrFp, cvrFn, cvrAccuracy, cvnSite, cvnSpk, cmpHit_burst, cmpHit_overlap, cvrVpp, cvrVmin] = ...
    deal(cell(size(csFiles_prm)));
[S_burst, S_overlap] = deal(struct());
for iFile=1:numel(csFiles_prm)    
    try
        vcFile_prm_ = csFiles_prm{iFile};
        S_score_ = load(strrep(vcFile_prm_, '.prm', '_score.mat'));  
        P = loadParam_(vcFile_prm_, 0);
        set0_(P);
        S_ = S_score_.S_score_clu;
        cvrSnr{iFile} = gather_(S_score_.vrSnr_min_gt');  
        [cvrVpp{iFile}, cvrVmin{iFile}] = deal(S_score_.vrVpp_clu, S_score_.vrVmin_clu);
        [cvrFp{iFile}, cvrFn{iFile}, cvrAccuracy{iFile}] = deal(S_.vrFp, S_.vrMiss, S_.vrAccuracy);
        cvnSpk{iFile} = cellfun(@numel, S_.cviSpk_gt_hit) + cellfun(@numel, S_.cviSpk_gt_miss);        
        cvnSite{iFile} = S_score_.vnSite_gt;
%         disp(csFiles_prm{iFile});
%         disp_score_(cvrSnr{iFile}, cvrFp{iFile}, cvrFn{iFile}, cvrAccuracy{iFile}, cvnSite{iFile}, cvnSpk{iFile}, 0);
        S_burst = struct_append_(S_burst, struct_copy_(get_(S_score_, 'S_burst'), 'vnBurst_gtspk', 'mpHit_burst_gt', 'vlHit_gtspk'));
        S_overlap = struct_append_(S_overlap, struct_copy_(get_(S_score_, 'S_overlap'), 'vnOverlap_gtspk', 'mpHit_overlap_gt', 'vlHit_gtspk'));
    catch
        disperr_();
    end
end

[vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, vrVpp, vrVmin] = ...
    multifun_(@(x)cell2mat_(x'), cvrSnr, cvrFp, cvrFn, cvrAccuracy, cvnSite, cvnSpk, cvrVpp, cvrVmin);

[vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, vrVpp, vrVmin] = ...
    select_vr_(vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, vrVpp, vrVmin, ...
        find(vrSnr >= read_cfg_('snr_thresh_gt'))); % filter by SNR, @TODO: burst and overlap

disp('All files pooled:');
disp_score_(makeStruct_(vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, fVerbose, S_burst, S_overlap));
S_score = makeStruct_(vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, vrVpp, vrVmin, S_burst, S_overlap);

% Plot
fPlot_gt = read_cfg_('fPlot_gt');
switch fPlot_gt
    case 4
        figure;
        set(gcf,'Color','w', 'Name', vcFile_batch);
        SNR_min = vrSnr;
        plot_gt_2by2_(SNR_min, vrAccuracy, vrFp, vrFn);
        
    case 3
        figure;
        set(gcf,'Color','w', 'Name', vcFile_batch);
        Vmin = vrVmin;
        plot_gt_2by2_(Vmin, vrAccuracy, vrFp, vrFn);
        
    case 2
        figure;
        set(gcf,'Color','w', 'Name', vcFile_batch);
        Vpp = vrVpp;
        plot_gt_2by2_(Vpp, vrAccuracy, vrFp, vrFn);        
        
    otherwise
        vpp_bin = 1; %25 for vpp
        vrError = 1 - vrAccuracy;
        [vrFp, vrFn, vrError] = deal(vrFp*100, vrFn*100, vrError*100);
        figure;  ax=[];
        ax(1)=subplot(421); hold on;
        plot(vrSnr(:), vrError(:), 'k.', 'MarkerSize', 2);
        boxplot_(vrError(:), vrSnr(:), vpp_bin, [3, 30]); ylabel('Error (%)'); 
        set(gca,'XTickLabel', {}); grid on; set(gca,'YScale','linear');
        set(gca, 'YLim', [0 15], 'YTick', 0:3:15);
        title_(vcFile_batch);

        ax(2)=subplot(423);  hold on;
        plot(vrSnr(:), vrFn(:), 'k.', 'MarkerSize', 2);
        boxplot_(vrFn(:), vrSnr(:), vpp_bin, [3, 30]); ylabel('False Negative(%)'); 
        set(gca,'XTickLabel', {}); grid on; set(gca,'YScale','linear');
        set(gca, 'YLim', [0 15], 'YTick', 0:3:15);
        set(gcf,'Color','w');

        ax(3)=subplot(425); hold on;
        plot(vrSnr(:), vrFp(:), 'k.', 'MarkerSize', 2);
        boxplot_(vrFp(:), vrSnr(:), vpp_bin, [3, 30]); ylabel('False Positive (%)'); 
        set(gca,'XTickLabel', {}); grid on; set(gca,'YScale','linear');
        set(gca, 'YLim', [0 15], 'YTick', 0:3:15);
        % title_(vcFile_batch);

        ax(4)=subplot(427);  hold on;
        plot(vrSnr(:), vnSite(:), 'k.', 'MarkerSize', 2);
        boxplot_(vnSite(:), vrSnr(:), vpp_bin, [3, 30]); ylabel('#sites>thresh'); 
        xlabel('SNR (Vp/Vrms)'); grid on; set(gca,'YScale','linear');
        set(gcf,'Color','w');
        set(gca, 'YLim', [0 15], 'YTick', 0:3:15);
        linkaxes(ax,'x'); xlim_([5, 25]); 
        return;
end %switch
csCode = file2cellstr_([mfilename(), '.m']);
set(gcf,'UserData', makeStruct_(P, S_score, csCode));
vcFile_fig = strrep(vcFile_batch, '.batch', '_gt.fig');
save_fig_(filename_timestamp_(vcFile_fig), gcf);
end %func


%--------------------------------------------------------------------------
% 11/2/2018 JJJ: Fixed the dir absolute path problem
function vcFile1 = filename_timestamp_(vcFile)
vcDatestr = datestr(now, 'yymmdd-HHMMSS');
[~, ~, vcExt] = fileparts(vcFile);
if isempty(vcExt)
    vcFile1 = [vcFile1, '_', vcDatestr];
else
    vcFile1 = strrep(vcFile, vcExt, ['_', vcDatestr, vcExt]);
end
end %func


%--------------------------------------------------------------------------
function plot_gt_2by2_(vrVmin, vrAccuracy, vrFp, vrFn)
try
    markerSize = 10;
    fh_text = @(label,vr)sprintf('%s: %0.2f/%0.2f(%d)<%0.2f-%0.2f>', ...
        label, nanmean(vr), nanstd(vr), sum(~isnan(vr)), quantile(vr,.25), quantile(vr,.75));

    vcXlabel = sprintf('Amplitude (%s)', inputname(1));
    for iPlot = 1:4
        subplot(2,2,iPlot);
        switch iPlot
            case 1
                plot(vrVmin, vrAccuracy, '.', 'MarkerSize', markerSize); 
                xylabel_(gca, vcXlabel, 'Accuracy', fh_text('Accuracy', vrAccuracy));
            case 2
                plot(vrVmin, vrFp, '.', 'MarkerSize', markerSize); 
                xylabel_(gca, vcXlabel, '');
                xylabel_(gca, vcXlabel, 'False Positive', fh_text('False Positive', vrFp));
            case 3
                plot(vrVmin, vrFn, '.', 'MarkerSize', markerSize); 
                xylabel_(gca, vcXlabel, 'False Negative', fh_text('False Negative', vrFn));
            case 4
                plot(vrFp, vrFn, '.', 'MarkerSize', markerSize); 
                xylabel_(gca, 'False Positive', 'False Negative');   
                set(gca,'XLim', [-.05, 1.05], 'XTick', 0:.2:1); 
        end %switch
        grid on;
        set(gca,'YLim', [-.05, 1.05], 'YTick', 0:.2:1);   
    end %for
catch
    disperr_('plot_gt_2by2_');
end
end %func


%--------------------------------------------------------------------------
function S = struct_append_(S, S1, iDimm)
if nargin<3, iDimm = 1; end
if isempty(S1), return; end
csNames = fieldnames(S1);
for iField = 1:numel(csNames)
    vcName_ = csNames{iField};
    try
        S.(vcName_) = cat(iDimm, get_(S, vcName_), get_(S1, vcName_)); % merge in 
    catch
        ;
    end
end
end %func


%--------------------------------------------------------------------------
% 9/1/2018 JJJ: Removes fields from the struct
function S = struct_remove_(varargin)
S = varargin{1};
if isempty(S), return; end
for i=2:nargin
    vcName_ = varargin{i};
    if iscell(vcName_)
       S = struct_remove(S, vcName_{:});
        continue;
    end
    if ~ischar(vcName_), continue; end
    if isfield(S, vcName_), S = rmfield(S, vcName_); end
end
end %func


%--------------------------------------------------------------------------
function disp_score_(S_score)
% vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, fVerbose)
P = get0_('P');
[vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk, fVerbose, S_burst, S_overlap] = ...
    struct_get_(S_score, 'vrSnr', 'vrFp', 'vrFn', 'vrAccuracy', 'vnSite', 'vnSpk', 'fVerbose', 'S_burst', 'S_overlap');
% snr_thresh_gt = get_set_(P, 'snr_thresh_gt', 8);
snr_thresh_gt = read_cfg_('snr_thresh_gt');
if isempty(fVerbose), fVerbose = 0; end
fSort_snr = 1;
fprintf('SNR(%s)>%d Groundtruth Units\n', read_cfg_('vcSnr_gt'), snr_thresh_gt);
[vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk] = ...
    multifun_(@(x)x(:), vrSnr, vrFp, vrFn, vrAccuracy, vnSite, vnSpk);
[vrFp_pct, vrFn_pct, vrAccuracy_pct] = deal(vrFp*100, vrFn*100, vrAccuracy*100);

vrScore2 = 100-vrFp_pct/2-vrFn_pct/2;
fprintf('\tSNR (Vp/Vrms): '); disp_stats_(vrSnr);
fprintf('\tFalse Positive (%%): '); disp_stats_(vrFp_pct);
fprintf('\tFalse Negative (%%): '); disp_stats_(vrFn_pct);
fprintf('\tAccuracy (%%): '); disp_stats_(vrAccuracy_pct);
fprintf('\tscore (1-FP-FN) (%%): '); disp_stats_(100-vrFp_pct-vrFn_pct);
fprintf('\tscore2 1-(FP+FN)/2 (%%): '); disp_stats_(vrScore2);

if isempty(vnSite), return; end
[vrSnr, vrFp_pct, vrFn_pct, vrAccuracy_pct, vnSite, vnSpk, vrScore2] = ...
    multifun_(@(x)x(:), vrSnr, vrFp_pct, vrFn_pct, vrAccuracy_pct, vnSite, vnSpk, vrScore2);
[vrSnr, vrFp_pct, vrFn_pct, vrAccuracy_pct, vrScore2] = ...
    multifun_(@(x)round(x*10)/10, vrSnr, vrFp_pct, vrFn_pct, vrAccuracy_pct, vrScore2);

if ~isempty(S_burst)
    fprintf('Burst-related %% errors (n:# ground-truth clusters)\n');
    nBurst_max = max(S_burst.vnBurst_gtspk);
    vpBurst_pct = arrayfun(@(x)mean(S_burst.vnBurst_gtspk==x), 0:nBurst_max) * 100;
    csCaptions_ = arrayfun(@(x)sprintf('burst%d(%0.1f%%)',x,vpBurst_pct(x+1)), 0:nBurst_max, 'UniformOutput', 0);
    disp_stats_(100 - S_burst.mpHit_burst_gt * 100, csCaptions_);
end
if ~isempty(S_overlap)
    fprintf('Overlap-related %% errors (n:# ground-truth clusters)\n');
    nOverlap_max = max(S_overlap.vnOverlap_gtspk);
    vpOverlap_pct = arrayfun(@(x)mean(S_overlap.vnOverlap_gtspk==x), 0:nOverlap_max) * 100;
    csCaptions_ = arrayfun(@(x)sprintf('overlap%d(%0.1f%%)',x,vpOverlap_pct(x+1)), 0:nOverlap_max, 'UniformOutput', 0);
    disp_stats_(100 - S_overlap.mpHit_overlap_gt * 100, csCaptions_);
end
% analyze both in a table
if ~isempty(S_burst) && ~isempty(S_overlap)
    [vlHit_gtspk, vnBurst_gtspk, vnOverlap_gtspk] = ...
        deal(logical(S_burst.vlHit_gtspk), int8(S_burst.vnBurst_gtspk(:)), int8(S_overlap.vnOverlap_gtspk(:)));
    % build matrix table
    [nOverlap_max, nBurst_max] = deal(max(vnOverlap_gtspk), max(vnBurst_gtspk));
    [xx_,yy_] = meshgrid(0:nBurst_max, 0:nOverlap_max);
    mpError_burst_overlap = 100 - round(arrayfun(@(x,y)mean(vlHit_gtspk(vnBurst_gtspk==x & vnOverlap_gtspk==y)), xx_, yy_)*1000)/10;
    mpFrac_burst_overlap = round(arrayfun(@(x,y)mean(vnBurst_gtspk==x & vnOverlap_gtspk==y), xx_, yy_)*1000)/10;   
    fprintf('Average error-rate: %0.1f%% (n_spikes=%d)\n', (1-mean(vlHit_gtspk))*100, sum(vlHit_gtspk));
    disp_mr_(mpError_burst_overlap, ...
        arrayfun(@(x)sprintf('burst%d',x), 0:nBurst_max, 'UniformOutput', 0), ...
        arrayfun(@(x)sprintf('overlap%d',x), 0:nOverlap_max, 'UniformOutput', 0), 'Error (% misassigned)');
    disp_mr_(mpFrac_burst_overlap, ...
        arrayfun(@(x)sprintf('burst%d',x), 0:nBurst_max, 'UniformOutput', 0), ...
        arrayfun(@(x)sprintf('overlap%d',x), 0:nOverlap_max, 'UniformOutput', 0), 'Fraction of gt-spikes (%)');
end

if fVerbose % && numel(viClu_gt) < 32
    disp(table(vrSnr, vrScore2, vrFp_pct, vrFn_pct, vrAccuracy_pct, vnSite, vnSpk));
end
end %func


%--------------------------------------------------------------------------
% display a matrix
function tbl = disp_mr_(mr, csCol, csRow, vcTitle)
if nargin<4, vcTitle = inputname(1); end
cvr_ = mr2cvr_(mr);
tbl = table(cvr_{:}, 'RowNames', csRow, 'VariableNames', csCol);
disp(vcTitle);
disp(tbl);
end %func


%--------------------------------------------------------------------------
function cvr = mr2cvr_(mr)
cvr = arrayfun(@(x)mr(:,x), 1:size(mr,2), 'UniformOutput', 0);
end %func


%--------------------------------------------------------------------------
% 8/16/2018 JJJ: Name change from import_gt_silico_ to import_gt_
% 8/14/2018 JJJ: Accepts two arguments
function [vcFile_gt_mat, S_gt] = import_gt_(vcFile_gt, vcFile_prm)
% Usage
%-----
% import_gt_(vcFile_mat)
%   create a groundtruth file (ends with _gt.mat)
% import_gt_(vcFile_mat, vcFile_prm)
%   Create a ground truth file where vcFile_prm exists using vcFile_prm
%   prefix

if nargin<2, vcFile_prm = ''; end

viSite = [];
if matchFileExt_(vcFile_gt, '.mat')
    % catalin's raster function
    S = load(vcFile_gt);    
    vnSpk = cellfun(@numel, S.a);    
    viClu = int32(cell2mat_(arrayfun(@(n)n*ones(1, vnSpk(n)), 1:numel(vnSpk), 'UniformOutput', 0)));
    viTime = int32(cell2mat_(S.a) * 20); % Convert to sample # (saved in ms unit & sampling rate =20KHZ)
elseif matchFileExt_(vcFile_gt, '.mda')
    % import Jeremy Magland format
    mr = int32(readmda_(vcFile_gt)');
    [viSite, viTime, viClu] = deal(mr(:,1), mr(:,2), mr(:,3));
elseif matchFileExt_(vcFile_gt, '.npy')
    % Pierre Yger format
    viTime = int32(readNPY_(vcFile_gt));
    viClu = int32(ones(size(viTime)));
    vcFile_gt_txt = strrep(vcFile_gt, '.triggers.npy', '.txt');
    if exist_file_(vcFile_gt_txt)
        iChan_gt = get_(meta2struct_(vcFile_gt_txt), 'channel') + 1;        
        iSite_gt = chan2site_prb_(iChan_gt, 'mea256yger.prb');
        if ~isempty(iSite_gt)
            viSite = repmat(int32(iSite_gt), size(viTime)); 
        end
    end
end

% Output to file
[viClu, viTime] = deal(viClu(:), viTime(:));
S_gt = makeStruct_(viClu, viTime);
if ~isempty(viSite), S_gt.viSite = viSite; end
if isempty(vcFile_prm)
    vcFile_gt_mat = subsFileExt_(vcFile_gt, '_gt.mat');
else
    vcFile_gt_mat = subsFileExt_(vcFile_prm, '_gt.mat');
    edit_prm_file_(struct('vcFile_gt', vcFile_gt_mat), vcFile_prm); % update groundtruth file field
%     edit_(vcFile_prm);
end
write_struct_(vcFile_gt_mat, S_gt);
end %func


%--------------------------------------------------------------------------
function iSite = chan2site_prb_(iChan, vcFile_prb)
% iChan: 1 base array index
iSite = [];
if isempty(iChan), return; end
vcFile_prb = find_prb_(vcFile_prb);
if ~exist_file_(vcFile_prb)
    fprintf(2, 'chan2site_prb_: probe file not found: %s\n', vcFile_prb); 
    return;
end
% S_ = file2struct_(vcFile_prb);
viSite2Chan = get_(file2struct_(vcFile_prb), 'channels');
if isempty(viSite2Chan), return; end
iSite = find(iChan == viSite2Chan); % same as reverse lookup

% if isfield(S_, 'mrChanXY')
%     mrChanXY = get_(S_, 'mrChanXY'); % use this if geometry gets edited by ref channels
% else
% end
% if isempty(mrChanXY), return; end
% 
% xy = mrChanXY(iChan,:);
% [~,iSite] = min(pdist2_(xy, S_.geometry));
end %func


%--------------------------------------------------------------------------
function close_hFig_traces_(hFig, event)
try
    if ~ishandle(hFig), return; end
    if ~isvalid(hFig), return; end
    S_fig = get(hFig, 'UserData');    
    fclose_(S_fig.fid_bin);
    try delete(hFig); catch; end %close one more time
catch
    disperr_();
    close(hFig);
end
end %func


%--------------------------------------------------------------------------
function fid = fclose_(fid, fVerbose)
% Sets fid = [] if closed properly
if nargin<2, fVerbose = 0; end
if isempty(fid), return; end
if ischar(fid), return; end
try 
    fclose(fid); 
    fid = [];
    if fVerbose, disp('File closed.'); end
catch
    disperr_(); 
end
end %func


%--------------------------------------------------------------------------
function hTitle = title_(hAx, vc)
% title_(vc)
% title_(hAx, vc)

if nargin==1, vc=hAx; hAx=[]; end
% Set figure title

if isempty(hAx), hAx = gca; end
hTitle = get_(hAx, 'Title');
if isempty(hTitle)
    hTitle = title(hAx, vc, 'Interpreter', 'none', 'FontWeight', 'normal');
else
    set_(hTitle, 'String', vc, 'Interpreter', 'none', 'FontWeight', 'normal');
end
end %func


%--------------------------------------------------------------------------
function [mnWav2, vnWav2_mean] = filt_car_(mnWav2, P, mnWav1_pre, mnWav1_post, fTrim_pad)
% Apply filter and CAR
% @TODO: edge case
if nargin<3, mnWav1_pre = []; end
if nargin<4, mnWav1_post = []; end
if nargin<5, fTrim_pad = 1; end
n_pre = size(mnWav1_pre,1);
n_post = size(mnWav1_post,1);
if n_pre > 0 || n_post > 0
    mnWav2 = [mnWav1_pre; mnWav2; mnWav1_post];
end
P.vcFilter = get_filter_(P);
switch lower(P.vcFilter)
    case 'user'
        %         vnFilter_user = -[5,0,-3,-4,-3,0,5]; % sgdiff acceleration
        vnFilter_user = single(get_set_(P, 'vnFilter_user', []));
        assert_(~isempty(vnFilter_user), 'Set vnFilter_user to use vcFilter=''user''');
        for i=1:size(mnWav2,2)
            mnWav2(:,i) = conv(mnWav2(:,i), vnFilter_user, 'same'); 
        end
    case 'fir1'
        n5ms = round(P.sRateHz / 1000 * 5); % must be odd
        vrFilter = single(fir1_(n5ms, P.freqLim/P.sRateHz*2));
        for i=1:size(mnWav2,2)
            mnWav2(:,i) = conv(mnWav2(:,i), vrFilter, 'same'); 
        end        
    case 'ndiff', mnWav2 = ndiff_(mnWav2, P.nDiff_filt);
    case 'fftdiff', mnWav2 = fftdiff_(mnWav2, P);        
    case {'sgdiff', 'sgfilt'}
        mnWav2 = sgfilt_(mnWav2, P.nDiff_filt);
    case 'bandpass'
        mnWav2 = ms_bandpass_filter_(mnWav2, P);
%         try
% %             mnWav2 = filtfilt_chain(single(gather_(mnWav2)), setfield(P, 'fGpu', 0));
%         catch
%             fprintf('GPU filtering failed. Trying CPU filtering.\n');
%             mnWav2 = filtfilt_chain(single(mnWav2), setfield(P, 'fGpu', 0));
%         end
%         mnWav2 = int16(mnWav2);
    case {'none', 'skip'} % no filter is applied
        ;
    case 'ndist'
        mnWav2 = ndist_filt_(mnWav2, get_set_(P, 'ndist_filt', 5));
    otherwise
        error('filt_car_: invalid filter option (vcFilter=''%s'')', P.vcFilter);
end  %switch

% trim padding
if (n_pre > 0 || n_post > 0) && fTrim_pad
    mnWav2 = mnWav2(n_pre+1:end-n_post,:);
end

%global subtraction before 
[mnWav2, vnWav2_mean] = wav_car_(mnWav2, P); 
end %func


%--------------------------------------------------------------------------
function mnWav1 = fftdiff_(mnWav, P)
    
fGpu = isGpu_(mnWav);
nLoads_gpu = get_set_(P, 'nLoads_gpu', 8);  % GPU load limit    

% [fGpu, nLoads_gpu] = deal(0, 1); %debug

nSamples = size(mnWav,1);
[nLoad1, nSamples_load1, nSamples_last1] = partition_load_(nSamples, round(nSamples/nLoads_gpu));
mnWav1 = zeros(size(mnWav), 'like', mnWav);    
freqLim_ = P.freqLim / (P.sRateHz / 2);
for iLoad = 1:nLoad1
    iOffset = (iLoad-1) * nSamples_load1;
    if iLoad<nLoad1
        vi1 = (1:nSamples_load1) + iOffset;
    else
        vi1 = (1:nSamples_last1) + iOffset;
    end
    mnWav1_ = mnWav(vi1,:);
    if fGpu % use GPU
        try 
            mnWav1(vi1,:) = fftdiff__(mnWav1_, freqLim_);
        catch
            fGpu = 0;
        end
    end
    if ~fGpu % use CPU 
        mnWav1(vi1,:) = fftdiff__(gather_(mnWav1_), freqLim_);
    end
end %for
end %func


%--------------------------------------------------------------------------
function mnWav1 = fftdiff__(mnWav, freqLim_)
% apply fft to diffrentiate
% mnWav = gather_(mnWav);

n = size(mnWav,1);
% n1 = round(n/2*freqLim_(1));
% n2 = round(n/2*diff(freqLim_));

n1 = round(n/2 * freqLim_(2));
npow2 = 2^nextpow2(n);
% w = single([linspace(0, 1, n2), linspace(1, 0, n2)])';
% w = [zeros(n1, 1, 'single'); w; zeros(npow2-2*n1-4*n2, 1, 'single'); -w; zeros(n1, 1, 'single')];
% w = single(pi*1i) * w;
w = single(pi*1i) * single([linspace(0, 1, n1), linspace(1, -1, npow2-2*n1), linspace(-1, 0, n1)]');
mnWav1 = real(ifft(bsxfun(@times, fft(single(mnWav), npow2), w), 'symmetric'));
mnWav1 = cast(mnWav1(1:n,:), class_(mnWav));
end %func


%--------------------------------------------------------------------------
function mnWav1 = fread_(fid_bin, dimm_wav, vcDataType)
% Get around fread bug (matlab) where built-in fread resize doesn't work

% defensive programming practice
if strcmpi(vcDataType, 'float'), vcDataType = 'single'; end
if strcmpi(vcDataType, 'float32'), vcDataType = 'single'; end
if strcmpi(vcDataType, 'float64'), vcDataType = 'double'; end

try
    if isempty(dimm_wav)
        mnWav1 = fread(fid_bin, inf, ['*', vcDataType]);
    else
        if numel(dimm_wav)==1, dimm_wav = [dimm_wav, 1]; end
        mnWav1 = fread(fid_bin, prod(dimm_wav), ['*', vcDataType]);
        if numel(mnWav1) == prod(dimm_wav)
            mnWav1 = reshape(mnWav1, dimm_wav);
        else
            dimm2 = floor(numel(mnWav1) / dimm_wav(1));
            if dimm2 >= 1
                mnWav1 = reshape(mnWav1, dimm_wav(1), dimm2);
            else
                mnWav1 = [];
            end
        end
    end
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
function frewind_(fid_bin, dimm_wav, vcDataType)
% move the file pointer back by the dimm_wav, vcDatatype
fseek(fid_bin, -1 * prod(dimm_wav) * bytesPerSample_(vcDataType), 'cof');
end %func


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: return recording duration in sec
function t_dur = recording_duration_(P, S0)
% t_dur = recording_duration_(P)
% t_dur = recording_duration_(P, S0)

if nargin<2, S0 = []; end
if isempty(S0)
    csFile_merge = get_(P, 'csFile_merge');
    if isempty(csFile_merge)
        nBytes_file = filesize_(P.vcFile) - get_set_(P, 'header_offset', 0);
        t_dur = nBytes_file / bytesPerSample_(P.vcDataType) / P.nChans / P.sRateHz;
    else % multi-file format, check csFiles_merge
        % currently unsupported
        error('recording_duration_: not implemented yet');
    end
else % old method used in describe_ command
    t_dur = double(max(S0.viTime_spk) - min(S0.viTime_spk)) / P.sRateHz;   
end
end %func


%--------------------------------------------------------------------------
function csDesc = describe_(vcFile_prm)
%describe_()
%describe_(vcFile_prm)
%describe_(S0)

% describe _jrc.mat file
if nargin==0
    S0 = get(0, 'UserData'); 
elseif isstruct(vcFile_prm)
    S0 = vcFile_prm;
else
    S0 = load(strrep(vcFile_prm, '.prm', '_jrc.mat'));
end
P = S0.P;

nSites = numel(P.viSite2Chan);
tDur = recording_duration_(P, S0); 
nSpk = numel(S0.viTime_spk);
nSitesPerEvent = P.maxSite*2+1;
nFeatures = S0.dimm_fet(1);

csDesc = {};
    csDesc{end+1} = sprintf('Recording file');
    csDesc{end+1} = sprintf('    Recording file          %s', P.vcFile);
    csDesc{end+1} = sprintf('    Probe file              %s', P.probe_file);
    csDesc{end+1} = sprintf('    Recording Duration      %0.1fs ', tDur);
    csDesc{end+1} = sprintf('    #Sites                  %d', nSites);
    csDesc{end+1} = sprintf('Events');
    csDesc{end+1} = sprintf('    #Spikes                 %d', nSpk);
    csDesc{end+1} = sprintf('    Feature                 %s', P.vcFet);
    csDesc{end+1} = sprintf('    #Sites/event            %d', nSitesPerEvent);
    csDesc{end+1} = sprintf('    #Features/event         %d', nFeatures);    
if ~isempty(get_(S0, 'nLoads'))
    csDesc{end+1} = sprintf('    #Loads                  %d', S0.nLoads);
end

if isfield(S0, 'S_clu')
    S_clu = S0.S_clu;
    csDesc{end+1} = sprintf('Cluster');    
    csDesc{end+1} = sprintf('    #Clusters               %d', S_clu.nClu);
    csDesc{end+1} = sprintf('    #Unique events          %d', sum(S_clu.viClu>0));
    csDesc{end+1} = sprintf('    min. spk/clu            %d', P.min_count);
end
try
    runtime_total = S0.runtime_detect + S0.runtime_sort;
    try
        t_cluster = S0.S_clu.t_runtime;
        t_automerge = S0.runtime_sort - t_cluster;
    catch
        [t_cluster, t_automerge] = deal(0);
    end
    csDesc{end+1} = sprintf('Runtime (s)');
    csDesc{end+1} = sprintf('    Detect + feature        %0.1fs', S0.runtime_detect);    
    csDesc{end+1} = sprintf('    Cluster + auto-merge    %0.1fs', S0.runtime_sort);
    csDesc{end+1} = sprintf('        Cluster             %0.1fs', t_cluster);
    csDesc{end+1} = sprintf('        auto-merge          %0.1fs', t_automerge);
    csDesc{end+1} = sprintf('    Total                   %0.1fs', runtime_total);
    csDesc{end+1} = sprintf('    Runtime speed           x%0.1f realtime', tDur / runtime_total);
catch
    ;
end

if nargout==0
    cellfun(@(x)disp(x), csDesc);
end

end %func


%--------------------------------------------------------------------------
function [viTime1, viSite1, viSpk1] = trimSpikes_(nlim_show)
error('not implemented');

viTime1=[];  viSite1=[];
if ~isfield(P, 'viSpk') || ~isfield(P, 'viSite'), return; end
ilim = round(P.tlim * P.sRateHz);
viSpk1 = find(P.viSpk >= ilim(1) & P.viSpk < ilim(end));
viTime1 = P.viSpk(viSpk1) - ilim(1);
viSite1 = P.viSite(viSpk1);
end %func


%--------------------------------------------------------------------------
function delete_multi_(varargin)
% provide cell or multiple arguments
for i=1:nargin
    try
        vr1 = varargin{i};
        if numel(vr1)==1
            delete(varargin{i}); 
        elseif iscell(vr1)
            for i1=1:numel(vr1)
                try
                    delete(vr1{i1});
                catch
                end
            end
        else
            for i1=1:numel(vr1)
                try
                    delete(vr1(i1));
                catch
                end
            end
        end
    catch
    end
end
end %func


%--------------------------------------------------------------------------
function vi = cell2vi_(cvi)
% convert cell index to array of index
vn_site = cellfun(@(x)numel(x), cvi); %create uniform output
vi = cell(numel(cvi), 1);
for iSite=1:numel(cvi)
    vi{iSite} = iSite * ones(vn_site(iSite), 1);
end
vi = cell2mat_(vi);
end %func


%--------------------------------------------------------------------------
function out = inputdlg_num_(vcGuide, vcVal, vrVal)
csAns = inputdlg_(vcGuide, vcVal, 1, {num2str(vrVal)});
try
    out = str2double(csAns{1});
catch
    out = nan;
end
end %func


%--------------------------------------------------------------------------
function manual_(P, vcMode)
% display manual sorting interface
% vcMode: %{'normal', 'debug', 'groundtruth'}

global fDebug_ui trFet_spk

if nargin<2, vcMode = 'normal'; end 

% Load info
if strcmpi(vcMode, 'groundtruth')
    S0 = gt2S0_(P);
else
    if ~is_sorted_(P)
        fprintf(2, 'File must to be sorted first (run "irc spikesort %s")\n', P.vcFile_prm); 
        return; 
    end
    [S0, P] = load_cached_(P);
    if ~isfield(S0, 'mrPos_spk')
        S0.mrPos_spk = spk_pos_(S0, trFet_spk);
        set(0, 'UserData', S0);
    end
end
fDebug_ui = 0;
P.fGpu = 0; %do not use GPU for manual use
set0_(fDebug_ui, P);
switch lower(vcMode)
    case 'groundtruth'
        ;
    case 'normal'
        if ~isempty(get_set_(S0, 'cS_log', {}))
            switch lower(questdlg_('Load last saved?', 'Confirmation'))
                case 'no'
                    [S_clu, S0] = post_merge_(S0.S_clu, P);
                    S0 = clear_log_(S0);
                case 'cancel'
                    return;
                case 'yes'
                    S0 = set0_(P); %update the P structure
                    S0.S_clu = S_clu_update_wav_(S0.S_clu, P);                
            end
        end
        
    case 'debug'
        fDebug_ui = 1;
        S0 = set0_(fDebug_ui);
        [S_clu, S0] = post_merge_(S0.S_clu, P); %redo the clustering (reset to auto)
        S0 = set0_(P);
end

% Create figures
hMsg = msgbox_('Plotting... (this closes automatically)'); t1=tic;
set(0, 'UserData', S0);
S0 = figures_manual_(P); %create figures for manual interface
clear mouse_figure;
clear get_fig_cache_ get_tag_ %clear persistent figure handles

% Set fields
S0 = struct_merge_(S0, ...
    struct('iCluCopy', 1, 'iCluPaste', [], 'hCopy', [], 'hPaste', [], 'nSites', numel(P.viSite2Chan)));
set(0, 'UserData', S0);

% hFigRD
try
    S0.S_clu = plot_FigRD_(S0.S_clu, P); % ask user before doing so
catch
    ;
end
% Set initial amplitudes
set(0, 'UserData', S0);
plot_FigWavCor_(S0);  % hFigWavCor
S0 = plot_FigWav_(S0); % hFigWav %do this after for ordering

% hFigProj, hFigHist, hFigIsi, hFigCorr, hFigPos, hFigMap, hFigTime
close_(get_fig_('FigTrial')); %close previous FigTrial figure
close_(get_fig_('FigTrial_b')); %close previous FigTrial figure
S0 = button_CluWav_simulate_(1, [], S0); %select first clu
auto_scale_proj_time_(S0);
S0 = keyPressFcn_cell_(get_fig_cache_('FigWav'), {'z'}, S0); %zoom
%S0.cS_log = load_(strrep(P.vcFile_prm, '.prm', '_log.mat'), 'cS_log', 0); 
S_log = load_(strrep(P.vcFile_prm, '.prm', '_log.mat'), [], 0);
if ~isempty(S_log), S0.cS_log = {S_log}; end
save_log_('start', S0); %crash proof log

% Finish up
close_(hMsg);
fprintf('UI creation took %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function S0 = figures_manual_(P)
% 'iFig', [], 'name', '', 'pos', [], 'fToolbar', 0, 'fMenubar', 0);
create_figure_('FigPos', [0 0 .15 .5], ['Unit position; ', P.vcFile_prm], 1, 0);
create_figure_('FigMap', [0 .5 .15 .5], ['Probe map; ', P.vcFile_prm], 1, 0);  

create_figure_('FigWav', [.15 .2 .35 .8],['Averaged waveform: ', P.vcFile_prm], 0, 1);
create_figure_('FigTime', [.15 0 .7 .2], ['Time vs. Amplitude; (Sft)[Up/Down] channel; [h]elp; [a]uto scale; ', P.vcFile]);

create_figure_('FigProj', [.5 .2 .35 .5], ['Feature projection: ', P.vcFile_prm]);
create_figure_('FigWavCor', [.5 .7 .35 .3], ['Waveform correlation (click): ', P.vcFile_prm]);

create_figure_('FigHist', [.85 .75 .15 .25], ['ISI Histogram: ', P.vcFile_prm]);
create_figure_('FigIsi', [.85 .5 .15 .25], ['Return map: ', P.vcFile_prm]);
create_figure_('FigCorr', [.85 .25 .15 .25], ['Time correlation: ', P.vcFile_prm]);
create_figure_('FigRD', [.85 0 .15 .25], ['Cluster rho-delta: ', P.vcFile_prm]);

%drawnow;
csFig = {'FigPos', 'FigMap', 'FigTime', 'FigWav', 'FigWavCor', 'FigProj', 'FigRD', 'FigCorr', 'FigIsi', 'FigHist'};
cvrFigPos0 = cellfun(@(vc)get(get_fig_(vc), 'OuterPosition'), csFig, 'UniformOutput', 0);
S0 = set0_(cvrFigPos0, csFig);
end %func


%--------------------------------------------------------------------------
function S0 = button_CluWav_simulate_(iCluCopy, iCluPaste, S0)
if nargin<3,  S0 = get(0, 'UserData'); end
if nargin<2, iCluPaste = []; end
if iCluCopy == iCluPaste, iCluPaste = []; end
hFig = gcf;
figure_wait_(1, hFig);

S0 = update_cursor_(S0, iCluCopy, 0);
S0 = update_cursor_(S0, iCluPaste, 1);
S0 = keyPressFcn_cell_(get_fig_cache_('FigWav'), {'j','t','c','i','v','e','f'}, S0); %'z' to recenter
set(0, 'UserData', S0);

auto_scale_proj_time_(S0);
plot_raster_(S0); %psth
figure_wait_(0, hFig);
end


%--------------------------------------------------------------------------
function  S0 = update_cursor_(S0, iClu, fPaste)
if isempty(iClu), return; end
if isempty(S0), S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;
% [hFig, S_fig] = get_fig_cache_('FigWav');

if ~isfield(S0, 'hCopy'), S0.hCopy = []; end
if ~isfield(S0, 'hPaste'), S0.hPaste = []; end

if ~fPaste
    iCluCopy = iClu;    
    if iCluCopy <1 || iCluCopy > S_clu.nClu, return; end
    update_plot_(S0.hPaste, nan, nan); %hide paste
    S0.iCluPaste = []; 
    [S0.iCluCopy, S0.hCopy] = plot_tmrWav_clu_(S0, iCluCopy, S0.hCopy, [0 0 0]);
else
    iCluPaste = iClu;    
    if iCluPaste < 1 || iCluPaste > S_clu.nClu || S0.iCluCopy == iCluPaste, return; end
    [S0.iCluPaste, S0.hPaste] = plot_tmrWav_clu_(S0, iCluPaste, S0.hPaste, [1 0 0]);
end
% set(hFig, 'UserData', S_fig);
cursor_FigWavCor_(S0);
if nargout==0, set(0, 'UserData', S0); end
end %func


%--------------------------------------------------------------------------
function cursor_FigWavCor_(S0)
if nargin==0, S0 = get(0, 'UseData'); end
P = S0.P; S_clu = S0.S_clu;

[hFig, S_fig] = get_fig_cache_('FigWavCor');
if isempty(S_fig)
    [hFig, S_fig] = plot_FigWavCor_(S0);
end
iClu1 = S0.iCluCopy;
if isempty(S0.iCluPaste)
    iClu2 = S0.iCluCopy;
else
    iClu2 = S0.iCluPaste;
end

cor12 = S_clu.mrWavCor(iClu1, iClu2);
set(S_fig.hCursorV, 'XData', iClu1*[1,1], 'YData', [.5, S_clu.nClu+.5]);
title_(S_fig.hAx, sprintf('Clu%d vs. Clu%d: %0.3f; %s', iClu1, iClu2, cor12, S_fig.vcTitle));    
if iClu1==iClu2, color_H = [0 0 0]; else color_H = [1 0 0]; end
set(S_fig.hCursorH, 'YData', iClu2*[1,1], 'XData', [.5, S_clu.nClu+.5], 'Color', color_H);
xlim_(S_fig.hAx, trim_lim_(iClu1 + [-6,6], [.5, S_clu.nClu+.5]));
ylim_(S_fig.hAx, trim_lim_(iClu2 + [-6,6], [.5, S_clu.nClu+.5]));
end %func


%--------------------------------------------------------------------------
function nFailed = unit_test_(vcArg1, vcArg2, vcArg3)
% 2017/2/24. James Jun. built-in unit test suite (request from Karel Svoboda)
% run unit test
%[Usage]
% unit_test()
%   run all
% unit_test(iTest)
%   run specific test again and show profile
% unit_test('show')
%   run specific test again and show profile
% @TODO: test using multiple datasets and parameters.
global fDebug_ui;

if nargin<1, vcArg1 = ''; end
if nargin<2, vcArg2 = ''; end
if nargin<3, vcArg3 = ''; end

cd(fileparts(mfilename('fullpath'))); % move to ironclust folder
if ~exist_file_('sample.bin'), irc('download', 'sample'); end

nFailed = 0;
profile('clear'); %reset profile stats
csCmd = {...  
    'close all; clear all;', ... %start from blank
    'irc clear sample_sample.prm', ...    
    'irc compile', ...
    'irc probe sample.prb', ...
    'irc makeprm sample_list.txt sample.prb', ...
    'irc makeprm sample.bin sample.prb', ...        
    'irc makeprm sample.bin sample.prb default.prm c:/temp/', ...     
    'irc probe sample_sample.prm', ...    
    'irc import-lfp sample_sample.prm', ...    
    'irc traces-lfp sample_sample.prm', ...    
    'irc traces sample_sample.prm', 'irc traces', ...
    'irc traces-test sample_sample.prm', ...    
    'irc preview-test sample_sample.prm', ...    
    'irc makeprm sample.bin sample.prb', ...
    'irc detectsort sample_sample.prm', 'irc clear sample_sample.prm', ...
    'irc probe sample_sample_merge.prm', 'irc detectsort sample_sample_merge.prm', 'irc clear sample_sample_merge.prm', ... %multishank, multifile test
    'irc detect sample_sample.prm', 'irc sort sample_sample.prm', ...        
    'irc export-csv sample_sample.prm', ...
    'irc export-quality sample_sample.prm', ...
    'irc export-spkwav sample_sample.prm', ...
    'irc export-spkwav sample_sample.prm 1', ...
    'irc export-spkamp sample_sample.prm', ...
    'irc export-spkamp sample_sample.prm 1', ...
    'irc export-jrc1 sample_sample.prm', ...
    'irc export-fet sample_sample.prm', ...
    'irc plot-activity sample_sample.prm', ... %     'irc kilosort sample_sample.prm', ...
    'irc clear sample_sample.prm', ...
    'irc traces-test sample_sample.prm', ...
    'irc detectsort sample_sample.prm', ...    
    'irc auto sample_sample.prm', ...    
    'irc manual-test sample_sample.prm', ...
    }; %last one should be the manual test

if ~isempty(vcArg1)
    switch lower(vcArg1)
        case {'show', 'info', 'list', 'help'}
            arrayfun(@(i)fprintf('%d: %s\n', i, csCmd{i}), 1:numel(csCmd)); 
            return;
        case {'manual', 'ui', 'ui-manual'}
            iTest = numel(csCmd); % + [-1,0];
        case {'traces', 'ui-traces'}
            iTest = numel(csCmd)-2; % second last
        otherwise
            iTest = str2num(vcArg1);
    end        
    fprintf('Running test %s: %s\n', vcArg1, csCmd{iTest});
    csCmd = csCmd(iTest);
end

vlPass = false(size(csCmd));
[csError, cS_prof] = deal(cell(size(csCmd)));
vrRunTime = zeros(size(csCmd));
for iCmd = 1:numel(csCmd)   
    eval('close all; fprintf(''\n\n'');'); %clear memory
    fprintf('Test %d/%d: %s\n', iCmd, numel(csCmd), csCmd{iCmd}); 
    t1 = tic;        
    profile('on');
    fDebug_ui = 1;
    set0_(fDebug_ui);
    try
        if any(csCmd{iCmd} == '(' | csCmd{iCmd} == ';') %it's a function        
            evalin('base', csCmd{iCmd}); %run profiler 
        else % captured by profile
            csCmd1 = strsplit(csCmd{iCmd}, ' ');
            feval(csCmd1{:});
        end
        vlPass(iCmd) = 1; %passed test        
    catch
        csError{iCmd} = lasterr();
        fprintf(2, '\tTest %d/%d failed\n', iCmd, numel(csCmd));
    end
    vrRunTime(iCmd) = toc(t1);
    cS_prof{iCmd} = profile('info');    
end
nFailed = sum(~vlPass);

fprintf('Unit test summary: %d/%d failed.\n', sum(~vlPass), numel(vlPass));
for iCmd = 1:numel(csCmd)
    if vlPass(iCmd)
        fprintf('\tTest %d/%d (''%s'') took %0.1fs.\n', iCmd, numel(csCmd), csCmd{iCmd}, vrRunTime(iCmd));
    else
        fprintf(2, '\tTest %d/%d (''%s'') failed:%s\n', iCmd, numel(csCmd), csCmd{iCmd}, csError{iCmd});
    end        
end

if numel(cS_prof)>1
    assignWorkspace_(cS_prof);
    disp('To view profile, run: profview(0, cS_prof{iTest});');
else
    profview(0, cS_prof{1});
end
fDebug_ui = [];
set0_(fDebug_ui);
end %func


%--------------------------------------------------------------------------
function y = log10_(y)
vl_nan = y<=0;
y = log10(y);
y(vl_nan) = nan;
end %func


%--------------------------------------------------------------------------
function S_clu = plot_FigRD_(S_clu, P)
% P = funcDefStr_(P, ...
%     'delta1_cut', .5, 'rho_cut', -2.5, 'fDetrend', 0, 'fAskUser', 1, ...
%     'min_count', 50, 'y_max', 2, 'rhoNoise', 0, 'minGamma', -1, 'fNormDelta', 0, 'fExclMaxRho', 0, 'fLabelClu', 1);
% P.y_max = 1;
% P.fAskUser = 1;

[hFig, S_fig] = get_fig_cache_('FigRD');
figure(hFig); clf;

if isfield(S_clu, 'cS_clu_shank')
    cellfun(@(S_clu1)plot_FigRD_(S_clu1, P), S_clu.cS_clu_shank);
    return;
end

if isempty(P.delta1_cut), P.delta1_cut = S_clu.P.delta1_cut; end
if isempty(P.rho_cut), P.rho_cut = S_clu.P.rho_cut; end
if isempty(P.min_count), P.min_count = S_clu.P.min_count; end
if ~isfield(P, 'vcDetrend_postclu'), P.vcDetrend_postclu = 'none'; end

switch P.vcDetrend_postclu
    case 'none'
        icl = find(S_clu.rho(:) > 10^(P.rho_cut) & S_clu.delta(:) > 10^(P.delta1_cut));
        x = log10_(S_clu.rho(:));
        y = log10_(S_clu.delta(:));
        fDetrend = 0;
    case 'global'
        [icl, x, y] = detrend_local_(S_clu, P, 0);
        vl_nan = y<=0;
        y = log10_(y);
        fDetrend = 1;
    case 'local'
        [icl, x, y] = detrend_local_(S_clu, P, 1);
        y = log10_(y);
        fDetrend = 1;
end

hold on; plot(x, y, '.');
axis tight;
axis_([-4 -.5 -1 2])
set(gcf,'color','w');
set(gcf, 'UserData', struct('x', x, 'y', y)); grid on; 
set(gca,'XScale','linear', 'YScale', 'linear');
plot(P.rho_cut*[1 1], get(gca,'YLim'), 'r--', get(gca,'XLim'), P.delta1_cut*[1, 1], 'r--');
xlabel('log10 rho'); ylabel(sprintf('log10 delta (detrend=%d)', fDetrend));

% label clusters
if isfield(S_clu, 'icl')
    icl = S_clu.icl; % do not overwrite
end
x_icl = double(x(icl));
y_icl = double(y(icl));
% if P.fLabelClu
%     arrayfun(@(i)text(x_icl(i), y_icl(i), sprintf('%dn%d',i,S_clu.vnSpk_clu(i)), 'VerticalAlignment', 'bottom'), 1:numel(icl));
% end
hold on; 
plot(x_icl, y_icl, 'r.');
grid on; 
% nClu = numel(unique(S_clu.viClu(S_clu.viClu>0))); %numel(icl)
title_(sprintf('rho-cut:%f, delta-cut:%f', P.rho_cut, P.delta1_cut));
drawnow;
end %func


%--------------------------------------------------------------------------
% 8/3/2018 JJJ: use custom fir1 if signal processing toolbox is not
% installed
function vrFilter = fir1_(n, w)
try
    vrFilter = fir1(n,w);
catch
    vrFilter = fir1_octave(n,w); % signal processing toolbox does not exist
end
end %func


%--------------------------------------------------------------------------
function S0 = plot_FigWav_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;

[hFig, S_fig] = get_fig_cache_('FigWav'); 

% Show number of spikes per clusters
% hold on; tight_plot(gca, [.04 .04], [.04 .02]);
P.LineWidth = 1; %plot a thicker line
P.viSite_clu = S_clu.viSite_clu;
nSites = numel(P.viSite2Chan);
if isempty(S_fig)
    % initialize
    S_fig.maxAmp = P.maxAmp;
    S_fig.hAx = axes_new_(hFig);
    set(gca, 'Position', [.05 .05 .9 .9], 'XLimMode', 'manual', 'YLimMode', 'manual'); 
    xlabel('Cluster #');    ylabel('Site #');   grid on;    
    S_fig.vcTitle = 'Scale: %0.1f uV; [H]elp; [Left/Right]:Select cluster; (Sft)[Up/Down]:scale; [M]erge; [S]plit auto; [D]elete; [A]:Resample spikes; [P]STH; [Z]oom; in[F]o; [Space]:Find similar';
    title_(sprintf(S_fig.vcTitle, S_fig.maxAmp)); %update scale
    
%     set(gca, 'ButtonDownFcn', @(src,event)button_CluWav_(src,event), 'BusyAction', 'cancel');
    set(hFig, 'KeyPressFcn', @keyPressFcn_FigWav_, 'CloseRequestFcn', @exit_manual_, 'BusyAction', 'cancel');
    axis_([0, S_clu.nClu + 1, 0, nSites + 1]);
    add_menu_(hFig, P);      
    mouse_figure(hFig, S_fig.hAx, @button_CluWav_);
    S_fig = plot_spkwav_(S_fig, S0); %plot spikes
    S_fig = plot_tnWav_clu_(S_fig, P); %do this after plotSpk_
    S_fig.cvhHide_mouse = mouse_hide_(hFig, S_fig.hSpkAll, S_fig);
else
%     mh_info = [];
    S_fig = plot_spkwav_(S_fig, S0); %plot spikes
    try delete(S_fig.vhPlot); catch; end %delete old text
    S_fig = rmfield_(S_fig, 'vhPlot');
    S_fig = plot_tnWav_clu_(S_fig, P); %do this after plotSpk_
end

% create text
% S0 = set0_(mh_info);
fText = get_set_(S_fig, 'fText', get_set_(P, 'Text', 1));
S_fig = figWav_clu_count_(S_fig, S_clu, fText);
S_fig.csHelp = { ...            
    '[Left-click] Cluter select/unselect (point at blank)', ...
    '[Right-click] Second cluster select (point at blank)', ...
    '[Pan] hold wheel and drag', ...
    '[Zoom] mouse wheel', ...
    '[X + wheel] x-zoom select', ...
    '[Y + wheel] y-zoom select', ...
    '[SPACE] clear zoom', ...
    '[(shift) UP]: increase amplitude scale', ...
    '[(shift) DOWN]: decrease amplitude scale', ...
    '------------------', ...
    '[H] Help', ...       
    '[S] Split auto', ...
    '[W] Spike waveforms (toggle)', ...                                  
    '[M] merge cluster', ...
    '[D] delete cluster', ...
    '[A] Resample spikes', ...
    '[Z] zoom selected cluster', ...
    '[R] reset view', ...
    '------------------', ...
    '[U] update all', ...  
    '[C] correlation plot', ...            
    '[T] show amp drift vs time', ...            
    '[J] projection view', ...            
    '[V] ISI return map', ...
    '[I] ISI histogram', ...
    '[E] Intensity map', ...
    '[P] PSTH display', ...
    '[O] Overlap average waveforms across sites', ...
    }; 
set(hFig, 'UserData', S_fig);
xlabel('Clu #'); ylabel('Site #');
end %func


%--------------------------------------------------------------------------
function add_menu_(hFig, P)
drawnow;
posvec = get(hFig, 'OuterPosition');

set(hFig, 'MenuBar','None');
mh_file = uimenu(hFig,'Label','File'); 
uimenu(mh_file,'Label', 'Save', 'Callback', @save_manual_);
uimenu(mh_file,'Label', 'Save figures as .fig', 'Callback', @(h,e)save_figures_('.fig'));
uimenu(mh_file,'Label', 'Save figures as .png', 'Callback', @(h,e)save_figures_('.png'));
uimenu(mh_file,'Label', 'Describe', 'Callback', @(h,e)msgbox_(describe_()), 'Separator', 'on');
uimenu(mh_file,'Label', 'Edit prm file', 'Callback', @edit_prm_);
uimenu(mh_file,'Label', 'Reload prm file', 'Callback', @reload_prm_);
uimenu(mh_file,'Label', 'Export units to csv', 'Callback', @export_csv_, 'Separator', 'on');
uimenu(mh_file,'Label', 'Export unit qualities to csv', 'Callback', @(h,e)export_quality_);
uimenu(mh_file,'Label', 'Export all mean unit waveforms', 'Callback', @export_tmrWav_clu_);
uimenu(mh_file,'Label', 'Export selected mean unit waveforms', 'Callback', @(h,e)export_mrWav_clu_);
uimenu(mh_file,'Label', 'Export all waveforms from the selected unit', 'Callback', @(h,e)export_tnWav_spk_);
uimenu(mh_file,'Label', 'Export firing rate for all units', 'Callback', @(h,e)export_rate_);
uimenu(mh_file,'Label', 'Exit', 'Callback', @exit_manual_, 'Separator', 'on', 'Accelerator', 'Q');

mh_edit = uimenu(hFig,'Label','Edit'); 
uimenu(mh_edit,'Label', '[M]erge', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'm'));
uimenu(mh_edit,'Label', 'Merge auto', 'Callback', @(h,e)merge_auto_());
uimenu(mh_edit,'Label', '[D]elete', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'd'), 'Separator', 'on');
uimenu(mh_edit,'Label', 'Delete auto', 'Callback', @(h,e)delete_auto_());
uimenu(mh_edit,'Label', '[S]plit', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 's'), 'Separator', 'on');
uimenu(mh_edit,'Label', 'Auto split max-chan', 'Callback', @(h,e)auto_split_(0));
uimenu(mh_edit,'Label', 'Auto split multi-chan', 'Callback', @(h,e)auto_split_(1));
uimenu(mh_edit,'Label', 'Annotate', 'Callback', @(h,e)unit_annotate_());

mh_view = uimenu(hFig,'Label','View'); 
uimenu(mh_view,'Label', 'Show traces', 'Callback', @(h,e)traces_());
uimenu(mh_view,'Label', 'View all [R]', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'r'));
uimenu(mh_view,'Label', '[Z]oom selected', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'z'));
uimenu(mh_view,'Label', '[W]aveform (toggle)', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'w'));
uimenu(mh_view,'Label', '[N]umbers (toggle)', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'n'));
uimenu(mh_view,'Label', 'Show raw waveform', 'Callback', @(h,e)raw_waveform_(h), ...
    'Checked', ifeq_(get_(P, 'fWav_raw_show'), 'on', 'off'));
%uimenu(mh_view,'Label', 'Threshold by sites', 'Callback', @(h,e)keyPressFcn_thresh_(hFig, 'n'));
% uimenu(mh_view,'Label', '.prm file', 'Callback', @edit_prm_);
uimenu(mh_view,'Label', 'Reset window positions', 'Callback', @reset_position_);

mh_proj = uimenu(hFig,'Label','Projection'); 
uimenu(mh_proj, 'Label', 'vpp', 'Callback', @(h,e)proj_view_(h), ...
    'Checked', if_on_off_(P.vcFet_show, {'vpp', 'vmin'}));
uimenu(mh_proj, 'Label', 'pca', 'Callback', @(h,e)proj_view_(h), ...
    'Checked', if_on_off_(P.vcFet_show, {'pca'}));
uimenu(mh_proj, 'Label', 'ppca', 'Callback', @(h,e)proj_view_(h), ...
    'Checked', if_on_off_(P.vcFet_show, {'ppca', 'private pca'}));
% uimenu(mh_proj, 'Label', 'cov', 'Callback', @(h,e)proj_view_(h), ...
%     'Checked', if_on_off_(P.vcFet_show, {'cov', 'spacetime'}));

mh_trials = uimenu(hFig,'Label','Trials', 'Tag', 'mh_trials');
set_userdata_(mh_trials, P);
update_menu_trials_(mh_trials);

mh_info = uimenu(hFig,'Label','','Tag', 'mh_info'); 
uimenu(mh_info, 'Label', 'Annotate unit', 'Callback', @unit_annotate_);
uimenu(mh_info, 'Label', 'single', 'Callback', @(h,e)unit_annotate_(h,e,'single'));
uimenu(mh_info, 'Label', 'multi', 'Callback', @(h,e)unit_annotate_(h,e,'multi'));
uimenu(mh_info, 'Label', 'noise', 'Callback', @(h,e)unit_annotate_(h,e,'noise'));
uimenu(mh_info, 'Label', 'clear annotation', 'Callback', @(h,e)unit_annotate_(h,e,''));
uimenu(mh_info, 'Label', 'equal to', 'Callback', @(h,e)unit_annotate_(h,e,'=%d'));

mh_history = uimenu(hFig, 'Label', 'History', 'Tag', 'mh_history'); 

mh_help = uimenu(hFig,'Label','Help'); 
uimenu(mh_help, 'Label', '[H]elp', 'Callback', @help_FigWav_);
uimenu(mh_help, 'Label', 'Wiki on GitHub', 'Callback', @(h,e)wiki_());
uimenu(mh_help, 'Label', 'About', 'Callback', @(h,e)msgbox_(about_()));
uimenu(mh_help, 'Label', 'Post an issue on GitHub', 'Callback', @(h,e)issue_('search'));
uimenu(mh_help, 'Label', 'Search issues on GitHub', 'Callback', @(h,e)issue_('post'));

drawnow;
set(hFig, 'OuterPosition', posvec);
end %func


%--------------------------------------------------------------------------
function S_fig = plot_spkwav_(S_fig, S0)
% fPlot_raw = 0;
if nargin<2, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
[P, viSite_spk, S_clu] = deal(S0.P, S0.viSite_spk, S0.S_clu);
tnWav = get_spkwav_(P);

[cvrX, cvrY, cviSite] = deal(cell(S_clu.nClu, 1));
vnSpk = zeros(S_clu.nClu, 1);
miSites_clu = P.miSites(:, S_clu.viSite_clu);
if isfield(S_fig, 'maxAmp')
    maxAmp = S_fig.maxAmp;
else
    maxAmp = P.maxAmp;
end
for iClu = 1:S_clu.nClu        
    try
        viSpk_show = randomSelect_(S_clu_viSpk_(S_clu, iClu, viSite_spk), P.nSpk_show);
        if P.fWav_raw_show
            trWav1 = raw2uV_(tnWav(:,:,viSpk_show), P);
            trWav1 = fft_lowpass_(trWav1, get_set_(P, 'fc_spkwav_show', []), P.sRateHz);
        else
            trWav1 = tnWav2uV_(tnWav(:,:,viSpk_show), P);
        end        
        viSite_show = miSites_clu(:, iClu);
        [cvrY{iClu}, cvrX{iClu}] = tr2plot_(trWav1, iClu, viSite_show, maxAmp, P);
        cviSite{iClu} = viSite_show;
        vnSpk(iClu) = size(trWav1, 3); %subsample 
    catch
        disperr_();
    end
end
S = makeStruct_(cvrY, cviSite, vnSpk);
try
    set(S_fig.hSpkAll, 'XData', cell2mat_(cvrX), 'YData', cell2mat_(cvrY), 'UserData', S);
catch
    S_fig.hSpkAll = plot(S_fig.hAx, cell2mat_(cvrX), cell2mat_(cvrY), 'Color', [.5 .5 .5], 'LineWidth', .5); %, P.LineStyle); 
    set(S_fig.hSpkAll, 'UserData', S);
end
end %func


%--------------------------------------------------------------------------
function exit_manual_(src, event)
try    
    if ~ishandle(src), return; end
    if ~isvalid(src), return; end
    S0 = get(0, 'UserData'); 
    P = S0.P;
%     if ~get_set_([], 'fDebug_ui', 0)
    fExit = save_manual_(P);
    if ~fExit, return; end 
    if ~isfield(S0, 'csFig')
        S0.csFig = {'FigPos', 'FigMap', 'FigTime', 'FigWav', 'FigWavCor', 'FigProj', 'FigRD', 'FigCorr', 'FigIsi', 'FigHist'};
    end
    delete_multi_(get_fig_all_(S0.csFig), src);
    close_(get_fig_('FigTrial'));
    close_(get_fig_('FigTrial_b'));
    close_(get_fig_('FigAux'));    
catch
    disperr_();
    close(src);
end
set(0, 'UserData', []); % clear previous
end %func


%--------------------------------------------------------------------------
function fExit = save_manual_(varargin) 
% TODO: remove figure handles from S0
if nargin==1
    P = varargin{1};
else
    P = get0_('P');
end
vcFile_jrc = subsFileExt_(P.vcFile_prm, '_jrc.mat');
fExit = 1;
switch lower(questdlg_(['Save to ', vcFile_jrc, ' ?'], 'Confirmation', 'Yes'))
    case 'yes'
        hMsg = msgbox_('Saving... (this closes automatically)');
        save0_(vcFile_jrc); % 1 will skip figure saving
        fExit = 1;
        close_(hMsg);
    case 'no'
        fExit = 1;
    case 'cancel' 
        fExit = 0;
        return;
end
end %func;


%--------------------------------------------------------------------------
function cvhHide_mouse = mouse_hide_(hFig, hObj_hide, S_fig)
% hide during mouse pan to speed up     
if nargin<3, S_fig = get(hFig, 'UserData'); end
% if nargin<3, S0 = get(0, 'UserData'); end
if nargin == 0 %clear field
%     try S_fig = rmfield(S_fig, 'vhFig_mouse'); catch; end
    try S_fig = rmfield(S_fig, 'cvhHide_mouse'); catch; end
else
    if ~isfield(S_fig, 'vhFig_mouse') && ~isfield(S_fig, 'cvhHide_mouse')
%         S_fig.vhFig_mouse = hFig;
        S_fig.cvhHide_mouse = {hObj_hide};    
    else
%         S_fig.vhFig_mouse(end+1) = hFig;
        S_fig.cvhHide_mouse{end+1} = hObj_hide;
    end
end
cvhHide_mouse = S_fig.cvhHide_mouse;
if nargout==0, set(hFig, 'UserData', S_fig); end
end %func


%--------------------------------------------------------------------------
function S_fig = plot_tnWav_clu_(S_fig, P)
% Substituting plot_spk_
S0 = get(0, 'UserData'); 
S_clu = S0.S_clu;
if ~isfield(P, 'LineWidth'), P.LineWidth=1; end
trWav_clu = ifeq_(P.fWav_raw_show, S_clu.tmrWav_raw_clu, S_clu.tmrWav_clu);
[nSamples, nSites, nClu] = size(trWav_clu);
nChans_show = size(P.miSites, 1);
miSites_clu = P.miSites(:, S_clu.viSite_clu);
% nSites = numel(P.viSite2Chan);

% determine x
x_offset = P.spkLim(2) / (diff(P.spkLim)+1); %same for raw and filt
vrX = (1:nSamples*nClu)/nSamples + x_offset;
vrX(1:nSamples:end) = nan;
vrX(nSamples:nSamples:end) = nan;
trWav_clu = trWav_clu / S_fig.maxAmp;

% nChans_show = size(P.miSites,1);
mrX = repmat(vrX(:), [1, nChans_show]);
mrX = reshape(mrX, [nSamples, nClu, nChans_show]);
mrX = reshape(permute(mrX, [1 3 2]), [nSamples*nChans_show, nClu]);

mrY = zeros(nSamples * nChans_show, nClu, 'single');
for iClu=1:nClu
    viSites1 = miSites_clu(:,iClu);
    mrY1 = trWav_clu(:,viSites1,iClu);
    mrY1 = bsxfun(@plus, mrY1, single(viSites1'));
    mrY(:,iClu) = mrY1(:);
end
    
% if isempty(P.LineStyle)
if isfield(S_fig, 'vhPlot')
    plot_update_(S_fig.vhPlot, mrX, mrY); 
else
    S_fig.vhPlot = plot_group_(S_fig.hAx, mrX, mrY, 'LineWidth', P.LineWidth); 
end
% else
%     S_fig.vhPlot = plot_group_(S_fig.hAx, mrX, mrY, P.LineStyle, 'LineWidth', P.LineWidth); 
% end
set(S_fig.hAx, 'YTick', 1:nSites, 'XTick', 1:nClu);
end %func


%--------------------------------------------------------------------------
function [hFig, S_fig] = plot_FigWavCor_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
S_clu = S0.S_clu; P = S0.P;
[hFig, S_fig] = get_fig_cache_('FigWavCor'); 

figure_wait_(1, hFig);
nClu = S_clu.nClu;
% Plot
if isempty(S_fig)
    S_fig.hAx = axes_new_(hFig);
    set(S_fig.hAx, 'Position', [.1 .1 .8 .8], 'XLimMode', 'manual', 'YLimMode', 'manual', 'Layer', 'top');
    set(S_fig.hAx, {'XTick', 'YTick'}, {1:nClu, 1:nClu});
    axis_(S_fig.hAx, [0 nClu 0 nClu]+.5);
    axis(S_fig.hAx, 'xy');
    grid(S_fig.hAx, 'on');
    xlabel(S_fig.hAx, 'Clu#'); 
    ylabel(S_fig.hAx, 'Clu#');
    S_fig.hImWavCor = imagesc(S_clu.mrWavCor, P.corrLim);  %clears title and current figure
    S_fig.hCursorV = line([1 1], [.5 nClu+.5], 'Color', [0 0 0], 'LineWidth', 1.5); 
    S_fig.hCursorH = line([.5 nClu+.5], [1 1], 'Color', [1 0 0], 'LineWidth', 1.5);             
    colorbar(S_fig.hAx);
    S_fig.vcTitle = '[S]plit; [M]erge; [D]elete';
    set(hFig, 'KeyPressFcn', @keyPressFcn_FigWavCor_);
    mouse_figure(hFig, S_fig.hAx, @button_FigWavCor_);
    S_fig.hDiag = plotDiag_([0, nClu, .5], 'Color', [0 0 0], 'LineWidth', 1.5);
else
    set(S_fig.hImWavCor, 'CData', S_clu.mrWavCor);
    set(S_fig.hCursorV, 'xdata', [1 1], 'ydata', [.5 nClu+.5]);
    set(S_fig.hCursorH, 'xdata', .5+[0 nClu], 'ydata', [1 1]);
end
% output
set(hFig, 'UserData', S_fig);
figure_wait_(0, hFig);
end %func


%--------------------------------------------------------------------------
function selfcorr = S_clu_self_corr_(S_clu, iClu1, S0)
% plot top half vs bottom half correlation. sum of vpp
if nargin<2, iClu1 = []; end
if nargin<3, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
[viSite_spk, P] = deal(S0.viSite_spk, S0.P);
tnWav_raw = get_spkwav_(P, get_set_(P, 'fWavRaw_merge', 1));

if isempty(iClu1)
    fprintf('Computing self correlation\n\t'); t1=tic;
    selfcorr = zeros(1, S_clu.nClu);
    for iClu=1:S_clu.nClu
        selfcorr(iClu) = S_clu_self_corr__(S_clu, tnWav_raw, iClu, viSite_spk);
        fprintf('.');
    end
    fprintf('\n\ttook %0.1fs\n', toc(t1));
else
    selfcorr = S_clu_self_corr__(S_clu, tnWav_raw, iClu1, viSite_spk);
end
end %func


%--------------------------------------------------------------------------
function selfcorr = S_clu_self_corr__(S_clu, tnWav_spk, iClu1, viSite_spk)
% cluster self-correlation. low means bad. return 1-corr score
MAX_SAMPLE = 4000;
if nargin<4, viSite_spk = get0_('viSite_spk'); end

[viSpk_clu1, viiSpk_clu1] = S_clu_viSpk_(S_clu, iClu1, viSite_spk);

viSpk_clu1 = randomSelect_(viSpk_clu1, MAX_SAMPLE);
% trWav1 = meanSubt_(single(tnWav_spk(:,:,viSpk_clu1))); 
trWav1 = tnWav_spk(:,:,viSpk_clu1);
vrVpp = squeeze_(squeeze_(max(trWav1(:,1,:)) - min(trWav1(:,1,:))));
% vrVpp = sum(squeeze_(max(tnWav_spk) - min(trWav1)));
[~, viSrt] = sort(vrVpp);
imid = round(numel(viSrt)/2);
mrWavA = meanSubt_(mean(trWav1(:, :, viSrt(1:imid)), 3));
mrWavB = meanSubt_(mean(trWav1(:, :, viSrt(imid+1:end)), 3));
% selfcorr = calc_corr_(mrWavA(:), mrWavB(:));
% selfcorr = mean(mean(zscore_(mrWavA) .* zscore_(mrWavB)));
% selfcorr = mean(zscore_(mrWavA(:)) .* zscore_(mrWavB(:)));
selfcorr = corr_(mrWavA(:), mrWavB(:));
end %func


%--------------------------------------------------------------------------
function [viSpk_clu1, viiSpk_clu1] = S_clu_viSpk_(S_clu, iClu1, viSite_spk)
% get a subset of cluster that is centered
% return only centered spikes
% if nargin<2, S0 = get(0, 'UserData'); end
% S_clu = S0.S_clu;
if nargin<3, viSite_spk = get0_('viSite_spk'); end
iSite_clu1 = S_clu.viSite_clu(iClu1);
viSpk_clu1 = S_clu.cviSpk_clu{iClu1};
viSite_clu1 = viSite_spk(viSpk_clu1);
viiSpk_clu1 = find(viSite_clu1 == iSite_clu1);
viSpk_clu1 = viSpk_clu1(viiSpk_clu1);
end %func


%--------------------------------------------------------------------------
function vrX = wav_clu_x_(iClu, P)
% determine x range of a cluster
if P.fWav_raw_show    
    spkLim = P.spkLim_raw;
    dimm_raw = get0_('dimm_raw');
    if dimm_raw(1) ~= diff(spkLim)+1, spkLim = P.spkLim * 2; end %old format
else
    spkLim = P.spkLim;
end
nSamples = diff(spkLim) + 1;
x_offset = spkLim(2) / nSamples + iClu - 1;

vrX = (1:nSamples) / nSamples + x_offset;
vrX([1,end]) = nan;
vrX = single(vrX(:));
end %func


%--------------------------------------------------------------------------
function update_plot_(hPlot, vrX, vrY, S_plot)
% update the plot with new x and y 

if nargin<4, S_plot = []; end
if isempty(hPlot), return; end
% selective plot to speed up plotting speed
if isempty(vrY) || isempty(vrX)
    hide_plot_(hPlot);
%     set(hPlot, 'XData', nan, 'YData', nan);  %visible off
    return;
end

% only update if both x and y are changed
vrX1 = get(hPlot, 'XData');
vrY1 = get(hPlot, 'YData');
fUpdate = 1;
if (numel(vrX1) == numel(vrX)) && (numel(vrY1) == numel(vrY))
    if (std(vrX1(:) - vrX(:)) == 0) && (std(vrY1(:) - vrY(:)) == 0)
        fUpdate = 0; 
    end
end
if fUpdate, set(hPlot, 'xdata', vrX, 'ydata', vrY); end
if ~isempty(S_plot), set(hPlot, 'UserData', S_plot); end
end %func


%--------------------------------------------------------------------------
% find intersection of two limit ranges
function xlim1 = trim_lim_(xlim1, xlim0)
dx = diff(xlim1);

if xlim1(1)<xlim0(1), xlim1 = xlim0(1) + [0, dx]; end
if xlim1(2)>xlim0(2), xlim1 = xlim0(2) + [-dx, 0]; end
xlim1(1) = max(xlim1(1), xlim0(1));
xlim1(2) = min(xlim1(2), xlim0(2));
end %func


%--------------------------------------------------------------------------
% 8/9/17 JJJ: Generalized to any figure objects
function S0 = keyPressFcn_cell_(hObject, csKey, S0)
% Simulate key press function

if nargin<3, S0 = get(0, 'UserData'); end
% figure_wait_(1); 
event1.Key = '';
if ischar(csKey), csKey = {csKey}; end
nKeys = numel(csKey);
keyPressFcn_ = get(hObject, 'KeyPressFcn');
for i=1:nKeys
    event1.Key = csKey{i};
    S0 = keyPressFcn_(hObject, event1, S0);
end
% drawnow;
% figure_wait_(0);
if nargout==0, set(0, 'UserData', S0); end
end %func


%--------------------------------------------------------------------------
function S0 = keyPressFcn_FigWav_(hObject, event, S0) %amp dist
global fDebug_ui

if nargin<3, S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;
P.LineStyle=[];
nSites = numel(P.viSite2Chan);
hFig = hObject;
S_fig = get(hFig, 'UserData');

switch lower(event.Key)
    case {'uparrow', 'downarrow'}
        rescale_FigWav_(event, S0, P);
        clu_info_(S0); %update figpos

    case {'leftarrow', 'rightarrow', 'home', 'end'}
        % switch the current clu
        if strcmpi(event.Key, 'home')
            S0.iCluCopy = 1;
        elseif strcmpi(event.Key, 'end')
            S0.iCluCopy = S_clu.nClu;
        elseif ~key_modifier_(event, 'shift');
            if strcmpi(event.Key, 'leftarrow')
                if S0.iCluCopy == 1, return; end
                S0.iCluCopy = S0.iCluCopy - 1;
            else
                if S0.iCluCopy == S_clu.nClu, return; end
                S0.iCluCopy = S0.iCluCopy + 1;
            end
        else
            if isempty(S0.iCluPaste)
                S0.iCluPaste = S0.iCluCopy;
            end
            if strcmpi(event.Key, 'leftarrow')
                if S0.iCluPaste == 1, return; end
                S0.iCluPaste = S0.iCluPaste - 1;
            else
                if S0.iCluPaste == S_clu.nClu, return; end
                S0.iCluPaste = S0.iCluPaste + 1;
            end
        end
        S0 = button_CluWav_simulate_(S0.iCluCopy, S0.iCluPaste, S0); %select first clu
        if strcmpi(event.Key, 'home') || strcmpi(event.Key, 'end') %'z' to recenter
            S0 = keyPressFcn_cell_(get_fig_cache_('FigWav'), {'z'}, S0); 
        end        
    case 'm', S0 = ui_merge_(S0); % merge clusters                
    case 'space'
        % auto-select nearest cluster for black
        mrWavCor = S_clu.mrWavCor;
        mrWavCor(S0.iCluCopy,S0.iCluCopy) = -inf;
        [~,S0.iCluPaste] = max(mrWavCor(:,S0.iCluCopy));
        set(0, 'UserData', S0);
        button_CluWav_simulate_([], S0.iCluPaste);        
    case 's', auto_split_(1, S0);        
    case 'r' %reset view
        figure_wait_(1);
        axis_([0, S0.S_clu.nClu + 1, 0, numel(P.viSite2Chan) + 1]);
        figure_wait_(0);        
    case {'d', 'backspace', 'delete'}, S0 = ui_delete_(S0);        
    case 'z' %zoom
        iClu = S0.iCluCopy;
        iSiteClu = S_clu.viSite_clu(S0.iCluCopy);
        set_axis_(hFig, iClu+[-1,1]*5, iSiteClu+[-1,1]*(P.maxSite*2), [0 S_clu.nClu+1], [0 nSites+1]);
    case 'c', plot_FigCorr_(S0);        
    case 'v', plot_FigIsi_(S0);        
    case 'a', update_spikes_(S0); clu_info_(S0);        
    case 'f', clu_info_(S0);               
    case 'h', msgbox_(S_fig.csHelp, 1);
    case 'w', toggleVisible_(S_fig.hSpkAll); %toggle spike waveforms        
    case 't', plot_FigTime_(S0); % time view        
    case 'j', plot_FigProj_(S0); %projection view        
    case 'n'
        fText = get_set_(S_fig, 'fText', get_set_(P, 'fText', 1));
        figWav_clu_count_(S_fig, S_clu, ~fText);          
    case 'i', plot_FigHist_(S0); %ISI histogram               
    case 'e', plot_FigMap_(S0);        
    case 'u', update_FigCor_(S0);        
    case 'p' %PSTH plot
        if isempty(P.vcFile_trial), msgbox_('''vcFile_trial'' not set. Reload .prm file after setting (under "File menu")'); return; end
        plot_raster_(S0, 1);
    otherwise, figure_wait_(0); %stop waiting
end
figure_(hObject); %change the focus back to the current object
end %func


%--------------------------------------------------------------------------
function export_rate_()
S_clu = get0_('S_clu');
mrRate_clu = clu_rate_(S_clu); 
csMsg = assignWorkspace_(mrRate_clu);
fprintf(csMsg);
msgbox_(csMsg, 1);
end %func


%--------------------------------------------------------------------------
function plot_FigCorr_(S0)
% hFigCorr plot
jitter_ms = .5; % bin size for correlation plot
nLags_ms = 25; %show 25 msec

if nargin<1, S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;
P.jitter_ms = jitter_ms;
P.nLags_ms = nLags_ms;

[hFig, S_fig] = get_fig_cache_('FigCorr'); 
iClu1 = get_set_(S0, 'iCluCopy', 1);
iClu2 = get_set_(S0, 'iCluPaste', 1);
if isempty(iClu2), iClu2 = iClu1; end

jitter = round(P.sRateHz / 1000 * P.jitter_ms); %0.5 ms
nLags = round(P.nLags_ms / P.jitter_ms);

vi1 = int32(double(S_clu_time_(S_clu, iClu1)) /jitter);

if iClu1~=iClu2
    vi1 = [vi1, vi1-1, vi1+1]; %allow missing one
end
vi2 = int32(double(S_clu_time_(S_clu, iClu2)) /jitter);
viLag = -nLags:nLags;
vnCnt = zeros(size(viLag));
for iLag=1:numel(viLag)
    if iClu1 == iClu2 && viLag(iLag)==0, continue; end
    vnCnt(iLag) = numel(intersect(vi1, vi2+viLag(iLag)));
end
vrTime_lag = viLag * P.jitter_ms;

%--------------
% draw
if isempty(S_fig)
    S_fig.hAx = axes_new_(hFig);
    S_fig.hBar = bar(vrTime_lag, vnCnt, 1);     
    xlabel('Time (ms)'); 
    ylabel('Counts');
    grid on; 
    set(S_fig.hAx, 'YScale', 'log');
else
    set(S_fig.hBar, 'XData', vrTime_lag, 'YData', vnCnt);
end
title_(S_fig.hAx, sprintf('Clu%d vs Clu%d', iClu1, iClu2));
xlim_(S_fig.hAx, [-nLags, nLags] * P.jitter_ms);
set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function plot_FigTime_(S0)
% plot FigTime window. Uses subsampled data

if nargin<1, S0 = get(0, 'UserData'); end
S_clu = S0.S_clu; P = S0.P; 
[hFig, S_fig] = get_fig_cache_('FigTime');

%----------------
% collect info
iSite = S_clu.viSite_clu(S0.iCluCopy);
[vrFet0, vrTime0] = getFet_site_(iSite, [], S0);    % plot background    
[vrFet1, vrTime1, vcYlabel, viSpk1] = getFet_site_(iSite, S0.iCluCopy, S0); % plot iCluCopy

vcTitle = '[H]elp; (Sft)[Left/Right]:Sites/Features; (Sft)[Up/Down]:Scale; [B]ackground; [S]plit; [R]eset view; [P]roject; [M]erge; (sft)[Z] pos; [E]xport selected; [C]hannel PCA';
if ~isempty(S0.iCluPaste)
    [vrFet2, vrTime2] = getFet_site_(iSite, S0.iCluPaste, S0);
    vcTitle = sprintf('Clu%d (black), Clu%d (red); %s', S0.iCluCopy, S0.iCluPaste, vcTitle);
else
    vrFet2 = [];
    vrTime2 = [];
    vcTitle = sprintf('Clu%d (black); %s', S0.iCluCopy, vcTitle);
end
time_lim = double([0, abs(S0.viTime_spk(end))] / P.sRateHz);

%------------
% draw
if isempty(S_fig)
    S_fig.maxAmp = P.maxAmp;
    S_fig.hAx = axes_new_(hFig);
    set(S_fig.hAx, 'Position', [.05 .2 .9 .7], 'XLimMode', 'manual', 'YLimMode', 'manual');
    
    % first time
    S_fig.hPlot0 = line(nan, nan, 'Marker', '.', 'Color', P.mrColor_proj(1,:), 'MarkerSize', 5, 'LineStyle', 'none');
    S_fig.hPlot1 = line(nan, nan, 'Marker', '.', 'Color', P.mrColor_proj(2,:), 'MarkerSize', 5, 'LineStyle', 'none');
    S_fig.hPlot2 = line(nan, nan, 'Marker', '.', 'Color', P.mrColor_proj(3,:), 'MarkerSize', 5, 'LineStyle', 'none');   %place holder  
    xlabel('Time (s)'); 
    grid on;    
    
    % rectangle plot
    vrPos_rect = [time_lim(1), S_fig.maxAmp, diff(time_lim), S_fig.maxAmp];
    S_fig.hRect = imrect_(S_fig.hAx, vrPos_rect); %default position?
    if ~isempty(S_fig.hRect)
        setColor(S_fig.hRect, 'r');
        setPositionConstraintFcn(S_fig.hRect, ...
            makeConstrainToRectFcn('imrect',time_lim, [-4000 4000]));  
    end
    set(hFig, 'KeyPressFcn', @keyPressFcn_FigTime_);
    S_fig.cvhHide_mouse = mouse_hide_(hFig, S_fig.hPlot0, S_fig);
    if ~isempty(P.time_tick_show) %tick mark
        set(S_fig.hAx, 'XTick', time_lim(1):P.time_tick_show:time_lim(end));
    end
end
vpp_lim = [0, abs(S_fig.maxAmp)];
% iFet = S_fig.iFet;
% iFet = 1;
if ~isfield(S_fig, 'iSite'), S_fig.iSite = []; end
update_plot_(S_fig.hPlot0, vrTime0, vrFet0);
update_plot_(S_fig.hPlot1, vrTime1, vrFet1);
update_plot_(S_fig.hPlot2, vrTime2, vrFet2);
imrect_set_(S_fig.hRect, time_lim, vpp_lim);
mouse_figure(hFig, S_fig.hAx); % allow zoom using wheel
% button click function to select individual spikes, all spikes plotted

if isfield(S_fig, 'vhAx_track')
    toggleVisible_({S_fig.vhAx_track, S_fig.hPlot0_track, S_fig.hPlot1_track, S_fig.hPlot2_track}, 0);
    toggleVisible_({S_fig.hAx, S_fig.hRect, S_fig.hPlot1, S_fig.hPlot2, S_fig.hPlot0}, 1);
end

if ~isfield(S_fig, 'fPlot0'), S_fig.fPlot0 = 1; end
toggleVisible_(S_fig.hPlot0, S_fig.fPlot0);

axis_(S_fig.hAx, [time_lim, vpp_lim]);
title_(S_fig.hAx, vcTitle);    
ylabel(S_fig.hAx, vcYlabel);

S_fig = struct_merge_(S_fig, makeStruct_(iSite, time_lim, P, vpp_lim, viSpk1));
S_fig.csHelp = {...
    'Up/Down: change channel', ...
    'Left/Right: Change sites', ...
    'Shift + Left/Right: Show different features', ...
    'r: reset scale', ...
    'a: auto-scale', ...
    'c: show pca across sites', ...
    'e: export cluster info', ...
    'f: export cluster feature', ...
    'Zoom: mouse wheel', ...
    'H-Zoom: press x and wheel. space to reset', ...
    'V-Zoom: press y and wheel. space to reset', ...
    'Drag while pressing wheel: pan'};
        
set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function [vrFet1, vrTime1, vcYlabel, viSpk1] = getFet_site_(iSite, iClu, S0)
% just specify iSite to obtain background info
% 2016 07 07 JJJ
% return feature correspojnding to a site and cluster
% requiring subsampled info: cvrVpp_site and cmrFet_site. store in S0

if nargin < 2, iClu = []; end
if nargin<3, S0 = get(0, 'UserData'); end
% S_clu = S0.S_clu;
P = S0.P;
if ~isfield(P, 'vcFet_show'), P.vcFet_show = 'vpp'; end
[vrFet1, viSpk1] = getFet_clu_(iClu, iSite, S0);
vrTime1 = double(S0.viTime_spk(viSpk1)) / P.sRateHz;

% label
switch lower(P.vcFet_show)
    case {'vpp', 'vmin'} %voltage feature
        vcYlabel = sprintf('Site %d (\\mu%s)', iSite, P.vcFet_show);
    otherwise %other feature options
        vcYlabel = sprintf('Site %d (%s)', iSite, P.vcFet_show);
end

end %func 


%--------------------------------------------------------------------------
function [viTime1, viSpk1, viSpk2] = S_clu_time_(S_clu, iClu)
% return time of cluster time in adc sample index unit.
% viSpk2: spike indices of centered spikes in cluster iClu

S0 = get(0, 'UserData');
if isfield(S_clu, 'cviSpk_clu')
    viSpk1 = S_clu.cviSpk_clu{iClu};
    viTime1 = S0.viTime_spk(viSpk1);
else
    viSpk1 = find(S_clu.viClu == iClu);
    viTime1 = S0.viTime_spk(viSpk1);
end
if nargout>=3
    iSite1 = S_clu.viSite_clu(iClu);
    viSpk2 = viSpk1(S0.viSite_spk(viSpk1) == iSite1);
end
end %func


%--------------------------------------------------------------------------
function [viTime_clu1, viSpk_clu1] = clu_time_(iClu1)
% returns time in sec
[S_clu, viTime_spk] = get0_('S_clu', 'viTime_spk');
viSpk_clu1 = S_clu.cviSpk_clu{iClu1};
viTime_clu1 = viTime_spk(S_clu.cviSpk_clu{iClu1});
end %func


%--------------------------------------------------------------------------
function imrect_set_(hRect, xpos, ypos)
vrPos = getPosition(hRect);
if ~isempty(xpos)
    vrPos(1) = min(xpos);
    vrPos(3) = abs(diff(xpos));
end
if ~isempty(ypos)
    vrPos(2) = min(ypos);
    vrPos(4) = abs(diff(ypos));
end
setPosition(hRect, vrPos);
end %func


%--------------------------------------------------------------------------
function flag = isVisible_(hObj)
flag = strcmpi(get(hObj, 'Visible'), 'on');
end %func


%--------------------------------------------------------------------------
function plot_FigProj_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
S_clu = S0.S_clu; P = S0.P;
[hFig, S_fig] = get_fig_cache_('FigProj');

iClu1 = S0.iCluCopy;
iClu2 = S0.iCluPaste;
update_plot2_proj_(); %erase prev objects

%---------------
% Compute
iSite1 = S_clu.viSite_clu(iClu1);
% miSites = P.miSites;
if ~isfield(P, 'viSites_show')
    P.viSites_show = sort(P.miSites(:, iSite1), 'ascend');
end
viSites_show = P.viSites_show;
nSites = numel(P.viSites_show);
cell_plot = {'Marker', 'o', 'MarkerSize', 1, 'LineStyle', 'none'};
switch lower(P.vcFet_show)
    case {'vpp', 'vmin', 'vmax'}
        vcXLabel = 'Site # (%0.0f \\muV; upper: V_{min}; lower: V_{max})';
        vcYLabel = 'Site # (%0.0f \\muV_{min})';
    otherwise
        vcXLabel = sprintf('Site # (%%0.0f %s; upper: %s1; lower: %s2)', P.vcFet_show, P.vcFet_show, P.vcFet_show);
        vcYLabel = sprintf('Site # (%%0.0f %s)', P.vcFet_show);    
end
vcTitle = '[H]elp; [S]plit; [B]ackground; (Sft)[Up/Down]:Scale; [Left/Right]:Sites; [M]erge; [F]eature';

%----------------
% display
if isempty(S_fig)
    S_fig.maxAmp = P.maxAmp;    
    S_fig.hAx = axes_new_(hFig);
    set(S_fig.hAx, 'Position', [.1 .1 .85 .85], 'XLimMode', 'manual', 'YLimMode', 'manual');
    S_fig.hPlot0 = line(nan, nan, 'Color', P.mrColor_proj(1,:), 'Parent', S_fig.hAx);
    S_fig.hPlot1 = line(nan, nan, 'Color', P.mrColor_proj(2,:), 'Parent', S_fig.hAx); %place holder
    S_fig.hPlot2 = line(nan, nan, 'Color', P.mrColor_proj(3,:), 'Parent', S_fig.hAx); %place holder
    set([S_fig.hPlot0, S_fig.hPlot1, S_fig.hPlot2], cell_plot{:}); %common style
    S_fig.viSites_show = []; %so that it can update
    S_fig.vcFet_show = 'vpp';
    % plot boundary
    plotTable_([0, nSites], '-', 'Color', [.5 .5 .5]); %plot in one scoop
    plotDiag_([0, nSites], '-', 'Color', [0 0 0], 'LineWidth', 1.5); %plot in one scoop
    mouse_figure(hFig);
    set(hFig, 'KeyPressFcn', @keyPressFcn_FigProj_);
    S_fig.cvhHide_mouse = mouse_hide_(hFig, S_fig.hPlot0, S_fig);
    set_fig_(hFig, S_fig);
end
% get features for x0,y0,S_plot0 in one go
%[mrMin, mrMax, vi0, vi1, vi2] = fet2proj_(S0, P.viSites_show);
[mrMin0, mrMax0, mrMin1, mrMax1, mrMin2, mrMax2] = fet2proj_(S0, P.viSites_show);
% S_fig.maxAmp %debug
if ~isfield(S_fig, 'viSites_show'), S_fig.viSites_show = []; end
if ~equal_vr_(S_fig.viSites_show, P.viSites_show) || ...
    ~equal_vr_(S_fig.vcFet_show, P.viSites_show)
    plot_proj_(S_fig.hPlot0, mrMin0, mrMax0, P, S_fig.maxAmp);
end

plot_proj_(S_fig.hPlot1, mrMin1, mrMax1, P, S_fig.maxAmp);
if ~isempty(iClu2)
    plot_proj_(S_fig.hPlot2, mrMin2, mrMax2, P, S_fig.maxAmp);
    vcTitle = sprintf('Clu%d (black), Clu%d (red); %s', iClu1, iClu2, vcTitle);
else
    update_plot_(S_fig.hPlot2, nan, nan);
    vcTitle = sprintf('Clu%d (black); %s', iClu1, vcTitle);
end

% Annotate axes
axis_(S_fig.hAx, [0 nSites 0 nSites]);
set(S_fig.hAx,'XTick',.5:1:nSites,'YTick',.5:1:nSites, 'XTickLabel', P.viSites_show, 'YTickLabel', P.viSites_show, 'Box', 'off');
xlabel(S_fig.hAx, sprintf(vcXLabel, S_fig.maxAmp));   
ylabel(S_fig.hAx, sprintf(vcYLabel, S_fig.maxAmp));  
title_(S_fig.hAx, vcTitle);
vcFet_show = P.vcFet_show;
S_fig = struct_merge_(S_fig, ...
    makeStruct_(vcTitle, iClu1, iClu2, viSites_show, vcXLabel, vcYLabel, vcFet_show));
S_fig.csHelp = { ...
    '[D]raw polygon', ...
    '[S]plit cluster', ...
    '(shift)+Up/Down: change scale', ...
    '[R]eset scale', ...
    'Zoom: mouse wheel', ...
    'Drag while pressing wheel: pan'};
set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function update_plot2_proj_(vrX, vrY)
if nargin==0, vrX=nan; vrY=nan; end
[hFig, S_fig] = get_fig_cache_('FigProj');
% erase polygon
if nargin==0
    try
        update_plot_(S_fig.hPlot2, vrX, vrY);
        delete(findobj(get(S_fig.hAx, 'Child'), 'Type', 'hggroup'));
    catch
        ;
    end
end
end


%--------------------------------------------------------------------------
function [S_clu, vlKeep_clu] = S_clu_refresh_(S_clu, fRemoveEmpty, viSite_spk)

if nargin<2, fRemoveEmpty=1; end
nClu = double(max(S_clu.viClu));
S_clu.nClu = nClu;
if nargin<3, viSite_spk = get0_('viSite_spk'); end
% if isfield(S_clu, 'viSpk_shank'), viSite_spk = viSite_spk(S_clu.viSpk_shank); end
% gviClu = gpuArray_(S_clu.viClu);
% S_clu.cviSpk_clu = arrayfun(@(iClu)gather_(find(gviClu==iClu)), 1:nClu, 'UniformOutput', 0);
S_clu.cviSpk_clu = arrayfun(@(iClu)find(S_clu.viClu==iClu), 1:nClu, 'UniformOutput', 0);
S_clu.vnSpk_clu = cellfun(@numel, S_clu.cviSpk_clu); 
S_clu.viSite_clu = double(arrayfun(@(iClu)mode(viSite_spk(S_clu.cviSpk_clu{iClu})), 1:nClu));
if fRemoveEmpty, [S_clu, vlKeep_clu] = S_clu_remove_empty_(S_clu); end
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_map_index_(S_clu, viMap_clu)
% update viClu
vlPos = S_clu.viClu > 0;
viMap_clu = int32(viMap_clu);
S_clu.viClu(vlPos) = viMap_clu(S_clu.viClu(vlPos)); %translate cluster number
% S_clu = S_clu_refresh_(S_clu, 0); % computational efficiency
% S_clu = S_clu_count_(S_clu);
% S_clu.nClu = numel(unique(viMap_clu));
S_clu.cviSpk_clu = arrayfun(@(iClu)find(S_clu.viClu==iClu), 1:S_clu.nClu, 'UniformOutput', 0);
S_clu.vnSpk_clu = cellfun(@numel, S_clu.cviSpk_clu);
viSite_spk = get0_('viSite_spk');
S_clu.viSite_clu = double(arrayfun(@(iClu)mode(viSite_spk(S_clu.cviSpk_clu{iClu})), 1:S_clu.nClu));
end %func


%--------------------------------------------------------------------------
function [S_clu, vlKeep_clu] = S_clu_remove_empty_(S_clu)
vlKeep_clu = S_clu.vnSpk_clu>0;
if all(vlKeep_clu), return; end

% waveform
S_clu = S_clu_select_(S_clu, vlKeep_clu);
if min(S_clu.viClu) < 1
    S_clu.viClu(S_clu.viClu<1) = 0;
    [~,~,S_clu.viClu] = unique(S_clu.viClu+1);        
    S_clu.viClu = S_clu.viClu-1;
else
    [~,~,S_clu.viClu] = unique(S_clu.viClu);        
end
S_clu.viClu = int32(S_clu.viClu);
S_clu.nClu = double(max(S_clu.viClu));
end %func


%--------------------------------------------------------------------------
function [S_clu, vlKeep_clu] = S_clu_keep_(S_clu, vlKeep_clu)

% waveform
S_clu = S_clu_select_(S_clu, vlKeep_clu);
viClu_remove = find(~vlKeep_clu);
% if min(S_clu.viClu) < 1
S_clu.viClu(S_clu.viClu<1 | ismember(S_clu.viClu, viClu_remove)) = 0;
[~,~,S_clu.viClu] = unique(S_clu.viClu+1);        
S_clu.viClu = S_clu.viClu-1;
% else
%     [~,~,S_clu.viClu] = unique(S_clu.viClu);        
% end
S_clu.viClu = int32(S_clu.viClu);
S_clu.nClu = double(max(S_clu.viClu));
end %func


%--------------------------------------------------------------------------
function [mrFet1, mrFet2, mrFet3, trWav2_spk] = trWav2fet_(tnWav1_spk, P, nSites_spk, viSite2_spk)
% [mrFet1, mrFet2, mrFet3, trWav_spk2] = trWav2fet_(tnWav_spk1, P)
% mrFet = trWav2fet_(tnWav_spk1, P)
if nargin<3, nSites_spk = []; end
if nargin<4, viSite2_spk = []; end

[mrFet1, mrFet2, mrFet3] = deal(single([]));
trWav2_spk = single(permute(tnWav1_spk, [1,3,2]));    
trWav2_spk = spkwav_car_(trWav2_spk, P, nSites_spk, viSite2_spk);
% if get_set_(P, 'fMeanSubt_fet', 1), trWav2_spk = meanSubt_(trWav2_spk); end % 12/16/17 JJJ experimental

switch lower(P.vcFet) %{'xcor', 'amp', 'slope', 'pca', 'energy', 'vpp', 'diff248', 'spacetime'}       
    case 'xcov'
        nChans_xcov = min(size(trWav2_spk,3), 6); % generates n^2 features
        trWav3_spk = permute(gather_(trWav2_spk(:,:,1:nChans_xcov)),[1,3,2]);
        mrFet1 = xcov_fet_(trWav3_spk, P.nDelays_xcov);
%         [mrFet1, mrFet2, mrFet3] = trWav2xcov_(trWav2_spk, P);
        
    case {'spacetime', 'cov', 'cov2'}
        mrFet1 = trWav2fet_cov_(trWav2_spk, P);
        
    case 'cov_prev'
        nDelay = 3;
        gtrWav1 = meanSubt_(trWav2_spk); 
        mr1 = zscore_(gtrWav1(:,:,1));                
        mr2 = zscore_(gtrWav1([ones(1,nDelay),1:end-nDelay],:,1)); 
        mrFet1 = mean(gtrWav1 .* repmat(mr1, [1,1,size(gtrWav1,3)]), 1);
        mrFet2 = mean(gtrWav1 .* repmat(mr2, [1,1,size(gtrWav1,3)]), 1);
        mrFet1 = shiftdim(mrFet1,1)';
        mrFet2 = shiftdim(mrFet2,1)';       
        
    case {'vpp', 'vppsqrt'}
        mrFet1 = shiftdim(max(trWav2_spk) - min(trWav2_spk))';
        if strcmpi(P.vcFet, 'vppsqrt'), mrFet1 = sqrt(mrFet1); end
        
    case {'amp', 'vmin'}
        mrFet1 = shiftdim(abs(min(trWav2_spk)))';
        
    case {'vminmax', 'minmax'}
        mrFet1 = shiftdim(abs(min(trWav2_spk)))';
        mrFet2 = shiftdim(abs(max(trWav2_spk)))';
        
    case 'energy'
        mrFet1 = shiftdim(std(trWav2_spk,1))';
        
    case 'energy2'
        nDelay = 3;
        mrFet1 = shiftdim(std(trWav2_spk,1))';
        trcov_ = @(a,b)shiftdim(sqrt(abs(mean(a.*b) - mean(a).*mean(b))));        
        mrFet2 = trcov_(trWav2_spk(1:end-nDelay,:,:), trWav2_spk(nDelay+1:end,:,:))';
        %mrFet1 = shiftdim(std(trWav_spk1,1))';
        
    case {'pca', 'gpca', 'fpca', 'spca'}
        %  Compute PrinVec, 2D, max channel only
        if strcmpi(P.vcFet, 'fpca')
            trWav2_spk0 = trWav2_spk;
            trWav2_spk = fft(trWav2_spk);
            trWav2_spk = abs(trWav2_spk(1:end/2,:,:));
        end
        if strcmpi(P.vcFet, 'pca')
            mrPv = tnWav2pv_(trWav2_spk, P);
        else
            mrPv_global = get0_('mrPv_global');
            if isempty(mrPv_global)
                [mrPv_global, vrD_global] = tnWav2pv_(trWav2_spk, P);
                [mrPv_global, vrD_global] = gather_(mrPv_global, vrD_global);
                if strcmpi(P.vcFet, 'spca') % shifted pca
                    mrPv_global = repmat(mrPv_global(:,1), [1, numel(vrD_global)]);
                    mrPv_global(1:end-2,2) = mrPv_global(3:end,1);
                    mrPv_global(3:end,3) = mrPv_global(1:end-2,1);
                end
                set0_(mrPv_global, vrD_global);
            end
            mrPv = mrPv_global;
        end
        if 0 % temporal broadening
            nDelays = 2;
            vi0 = nDelays+1:size(trWav2_spk,1)-nDelays;
            trWav_ = trWav2_spk(vi0,:,:);
            for iDelay = [-nDelays:-1,1:nDelays]
                trWav_ = trWav_ + trWav2_spk(vi0+iDelay,:,:);
            end
            trWav2_spk(vi0,:,:) = trWav_ / (nDelays*2+1);
        end
        [mrFet1, mrFet2, mrFet3] = project_interp_(trWav2_spk, mrPv, P);
end
if nargout==1
    switch P.nPcPerChan
        case 2
            mrFet1 = cat(1, mrFet1, mrFet2);
        case 3
            mrFet1 = cat(1, mrFet1, mrFet2, mrFet3);
    end %switch    
end
end %func


%--------------------------------------------------------------------------
function [mrFet1, mrFet2, mrFet3] = project_interp_(trWav2_spk, mrPv, P);
[mrFet1, mrFet2, mrFet3] = deal([]);
dimm1 = size(trWav2_spk);
if ismatrix(trWav2_spk), dimm1(end+1) = 1; end
mrWav_spk1 = reshape(trWav2_spk, dimm1(1), []);  
fGpu = isGpu_(trWav2_spk);
mrPv = gather_(mrPv);
mrFet1 = reshape(mrPv(:,1)' * mrWav_spk1, dimm1(2:3))';
if P.nPcPerChan >= 2
    mrFet2 = reshape(mrPv(:,2)' * mrWav_spk1, dimm1(2:3))';
end
if P.nPcPerChan >= 3
    mrFet3 = reshape(mrPv(:,3)' * mrWav_spk1, dimm1(2:3))';
end

% find optimal delay by interpolating 2x
if ~get_set_(P, 'fInterp_fet', 0), return; end
switch 1
    case 3
        viShift = [0, -1,-.5,.5,1,1.5,-1.5];     
    case 2
        viShift = [0, -1,-.5,.5,1,1.5,-1.5,2,-2]; 
    case 1
        viShift = [0, -1,-.5,.5,1]; 
end
mrPv1 = vr2mr_shift_(mrPv(:,1), viShift, fGpu);
if ~isempty(mrFet2), mrPv2 = vr2mr_shift_(mrPv(:,2), viShift, fGpu); end
if ~isempty(mrFet3), mrPv3 = vr2mr_shift_(mrPv(:,3), viShift, fGpu); end

[~, viMax_spk] = max(abs(mrPv1' * trWav2_spk(:,:,1)));
for iShift=2:numel(viShift)
    viSpk2 = find(viMax_spk == iShift);
    if isempty(viSpk2), continue; end
    mrWav_spk2 = reshape(trWav2_spk(:,viSpk2,:), dimm1(1), []);
    mrFet1(:,viSpk2) = reshape(mrPv1(:,iShift)' * mrWav_spk2, [], dimm1(3))';
    if ~isempty(mrFet2)
        mrFet2(:,viSpk2) = reshape(mrPv2(:,iShift)' * mrWav_spk2, [], dimm1(3))';
    end
    if ~isempty(mrFet3)
        mrFet3(:,viSpk2) = reshape(mrPv3(:,iShift)' * mrWav_spk2, [], dimm1(3))';
    end
end %for
end %func


%--------------------------------------------------------------------------
function mrPv1 = vr2mr_shift_(vr1, viShift, fGpu)
if nargin<3, fGpu = 0; end
vr1 = gather_(vr1);
vi0 = (1:numel(vr1))';
mrPv1 = zeros(numel(vr1), numel(viShift), 'like', vr1);
mrPv1(:,1) = vr1;
for iShift = 2:numel(viShift)
    mrPv1(:,iShift) = zscore(interp1(vi0, vr1, vi0+viShift(iShift), 'pchip', 'extrap'));
end
if fGpu, mrPv1 = gpuArray_(mrPv1); end
end %func


%--------------------------------------------------------------------------
function [mrPv, vrD1] = tnWav2pv_(tr, P)
%tr: nSamples x nSpikes x nChans
MAX_SAMPLE = 10000;        
% if set, align waveform after upsampling and downsample
fInterp_pca = get_set_(P, 'fInterp_pca', 0);

if nargin<2, P = get0_('P'); end
% if nargin<3, viSites_ref = []; end
% if isempty(tr)
%     nSpk = size(tnWav_spk,3);
%     viSpk_sub = subsample_vr_(1:nSpk, MAX_SAMPLE);
%     tr = permute(tnWav_spk(:,:,viSpk_sub), [1 3 2]);
%     tr = single(tr);
%     tr = spkwav_car_(tr, P);
%     mrSpkWav1 = tr(:,:,1);
% else
viSpk_sub = subsample_vr_(1:size(tr,2), MAX_SAMPLE);
mrSpkWav1 = tr(:,viSpk_sub, 1); 
if fInterp_pca
    [mrSpkWav1, viOriginal] = interp_align_(mrSpkWav1, P);
end

mrCov = mrSpkWav1 * mrSpkWav1';
[mrPv1, vrD1] = eig(mrCov);
mrPv1 = zscore_(fliplr(mrPv1)); % sort largest first
vrD1 = flipud(diag(vrD1));
if fInterp_pca, mrPv1 = mrPv1(viOriginal,:); end

% spike center should be negative
iMid = 1-P.spkLim(1);
vrSign = (mrPv1(iMid,:) < 0) * 2 - 1; %1 or -1 depending on the sign
mrPv = bsxfun(@times, mrPv1, vrSign);
end


%--------------------------------------------------------------------------
% 10/18/17 JJJ: created
function [mr_int, viOriginal] = interp_align_(mr, P)
nInterp_spk = 2;
% viTime0 = 1:size(tnWav_spk,1);

imin_int = (-P.spkLim(1))*nInterp_spk+1;
[mr_int, vi_int] = interpft_(mr, nInterp_spk);
[~, viMin_int] = min(mr_int);     
viShift_spk = imin_int - viMin_int;
for iShift = -nInterp_spk+1:nInterp_spk-1
    if iShift==0, continue; end
    vi_ = find(viShift_spk  == iShift);
    if isempty(vi_), continue; end
    mr_int(:,vi_) = shift_mr_(mr_int(:,vi_), iShift);
end
viOriginal = (0:size(mr,1)-1)*nInterp_spk + 1; % check
mr_int = meanSubt_(mr_int);
end %func


%--------------------------------------------------------------------------
function [mrMin0, mrMax0, mrMin1, mrMax1, mrMin2, mrMax2] = fet2proj_(S0, viSites0)
% show spikes excluding the clusters excluding clu1 and 2
P = S0.P;
S_clu = S0.S_clu;
iClu1 = S0.iCluCopy;
iClu2 = S0.iCluPaste;

% select subset of spikes
viSpk0 = find(ismember(S0.viSite_spk, viSites0));
viTime0 = S0.viTime_spk(viSpk0);
%time filter
if ~isfield(P, 'tlim_proj'), P.tlim_proj = []; end
if ~isempty(P.tlim_proj) 
    nlim_proj = round(P.tlim_proj * P.sRateHz);
    viSpk01 = find(viTime0>=nlim_proj(1) & viTime0<=nlim_proj(end));
    viSpk0 = viSpk0(viSpk01);
    viTime0 = viTime0(viSpk01);
end
viClu0 = S_clu.viClu(viSpk0);
viSpk00 = randomSelect_(viSpk0, P.nShow_proj*2);
viSpk01 = randomSelect_(viSpk0(viClu0 == iClu1), P.nShow_proj);
if ~isempty(iClu2)
    viSpk02 = randomSelect_(viSpk0(viClu0 == iClu2), P.nShow_proj);
else
    [mrMin2, mrMax2] = deal([]);
end
switch lower(P.vcFet_show)
    case {'pca'} %channel by channel pca. do it by channel
        % determine pca vector from cluster 1
        [mrPv1, mrPv2] = pca_pv_spk_(S_clu.cviSpk_clu{iClu1}, viSites0);
        [mrMin0, mrMax0] = pca_pc_spk_(viSpk00, viSites0, mrPv1, mrPv2); %getall spikes whose center lies in certain range
        [mrMin1, mrMax1] = pca_pc_spk_(viSpk01, viSites0, mrPv1, mrPv2); %getall spikes whose center lies in certain range
        if ~isempty(iClu2)  
            [mrMin2, mrMax2] = pca_pc_spk_(viSpk02, viSites0, mrPv1, mrPv2);
        end 
                
    case {'ppca', 'private pca'} %channel by channel pca. do it by channel
        % determine pca vector from cluster 1
        [mrPv1, mrPv2] = pca_pv_clu_(viSites0, iClu1, iClu2);            
        [mrMin0, mrMax0] = pca_pc_spk_(viSpk00, viSites0, mrPv1, mrPv2); %getall spikes whose center lies in certain range
        [mrMin1, mrMax1] = pca_pc_spk_(viSpk01, viSites0, mrPv1, mrPv2); %getall spikes whose center lies in certain range
        if ~isempty(iClu2)              
            [mrMin2, mrMax2] = pca_pc_spk_(viSpk02, viSites0, mrPv1, mrPv2);
        end
        
    otherwise % generic
        [mrMin0, mrMax0] = getFet_spk_(viSpk00, viSites0, S0); %getall spikes whose center lies in certain range
        [mrMin1, mrMax1] = getFet_spk_(viSpk01, viSites0, S0); %getall spikes whose center lies in certain range
        if ~isempty(iClu2)  
            [mrMin2, mrMax2] = getFet_spk_(viSpk02, viSites0, S0);
        end            
end %switch
[mrMin0, mrMax0, mrMin1, mrMax1, mrMin2, mrMax2] = ...
    multifun_(@(x)abs(x), mrMin0, mrMax0, mrMin1, mrMax1, mrMin2, mrMax2);
end %func


%--------------------------------------------------------------------------
function [mrMin, mrMax] = getFet_spk_(viSpk1, viSites1, S0)
% get feature for the spikes of interest

if nargin<3, S0 = get(0, 'UserData'); end
P = S0.P;

switch lower(P.vcFet_show)
    case {'vmin', 'vpp'}   
        tnWav_spk1 = tnWav2uV_(tnWav_spk_sites_(viSpk1, viSites1, S0), P);
        [mrMin, mrMax] = multifun_(@(x)abs(permute(x,[2,3,1])), min(tnWav_spk1), max(tnWav_spk1));
    case {'cov', 'spacetime'}
        [mrMin, mrMax] = calc_cov_spk_(viSpk1, viSites1);
    case 'pca'
        [mrMin, mrMax] = pca_pc_spk_(viSpk1, viSites1); %getall spikes whose center lies in certain range
    otherwise
        error('not implemented yet');
end
end %func


%--------------------------------------------------------------------------
function [mrVpp1, mrVpp2] = calc_cov_spk_(viSpk1, viSites1)

[viSite_spk, P] = get0_('viSite_spk', 'P');
tnWav_spk = get_spkwav_(P, 0); % get filtered waveform

nSpk1 = numel(viSpk1);
viSites_spk1 = viSite_spk(viSpk1);
tnWav_spk1 = gpuArray_(tnWav_spk(:,:,viSpk1), P.fGpu); 
nSites_spk = 1 + P.maxSite * 2;
[mrVpp1_, mrVpp2_] = trWav2fet_(tnWav_spk1, P, nSites_spk);
[mrVpp1_, mrVpp2_] = multifun_(@(x)gather_(abs(x)), mrVpp1_, mrVpp2_);

% re-project to common basis
viSites_spk_unique = unique(viSites_spk1);
[mrVpp1, mrVpp2] = deal(zeros([numel(viSites1), nSpk1], 'like', mrVpp1_));
for iSite1 = 1:numel(viSites_spk_unique) %only care about the first site
    iSite11 = viSites_spk_unique(iSite1); %center sites group
    viSpk11 = find(viSites_spk1 == iSite11); %dangerous error
    viSites11 = P.miSites(:, iSite11);        
    [vlA11, viiB11] = ismember(viSites11, viSites1);
    mrVpp1(viiB11(vlA11),viSpk11) = mrVpp1_(vlA11,viSpk11);
    mrVpp2(viiB11(vlA11),viSpk11) = mrVpp2_(vlA11,viSpk11);
end    
end %func


%--------------------------------------------------------------------------
function tnWav1 = tnWav1_sites_1_(tnWav1_, miSites1, viSites1)
[nT_spk, nSites_spk, nSpk1] = size(tnWav1_);
nSites1 = numel(viSites1);
% assert_(nSites_spk==nSites1, 'tnWav1_sites_: nSites must agree');
tnWav1 = zeros([nT_spk, nSpk1, nSites1], 'like', tnWav1_); %subset of spk, complete
for iSite1 = 1:nSites1
    [viSite11, viiSpk11] = find(miSites1 == viSites1(iSite1));
    nSpk11 = numel(viiSpk11);
    mnWav_spk11 = reshape(tnWav1_(:, :, viiSpk11), nT_spk, []);
    mnWav_spk11 = mnWav_spk11(:, sub2ind([nSites_spk, nSpk11], viSite11', 1:nSpk11));
    tnWav1(:, viiSpk11, iSite1) = mnWav_spk11;
end
tnWav1 = permute(tnWav1, [1,3,2]);
end %func


%--------------------------------------------------------------------------
% 171201 JJJ: Unique sites handling for diagonal plotting
function tnWav_spk1 = tnWav_spk_sites_(viSpk1, viSites1, S0, fWav_raw_show)
% reorder tnWav1 to viSites1
% P = get0_('P');
% if nargin<3, fWav_raw_show = P.fWav_raw_show; end
if nargin<3, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
if nargin<4, fWav_raw_show = get_set_(S0.P, 'fWav_raw_show', 0); end

% unique exception handling %171201 JJJ
[viSites1_uniq, ~, viiSites1_uniq] = unique(viSites1);
if numel(viSites1_uniq) ~= numel(viSites1)
    tnWav_spk11 = tnWav_spk_sites_(viSpk1, viSites1_uniq, S0, fWav_raw_show);
    tnWav_spk1 = tnWav_spk11(:,viiSites1_uniq,:);
    return;
end

[viSite_spk, P] = deal(S0.viSite_spk, S0.P);
tnWav = get_spkwav_(P, fWav_raw_show);
nT_spk = size(tnWav, 1);
nSpk1 = numel(viSpk1);
viSites_spk1 = viSite_spk(viSpk1);
viSites_spk_unique = unique(viSites_spk1);
tnWav_spk1 = zeros([nT_spk, numel(viSites1), nSpk1], 'like', tnWav);
for iSite1 = 1:numel(viSites_spk_unique) %only care about the first site
    iSite11 = viSites_spk_unique(iSite1); %center sites group
    viSpk11 = find(viSites_spk1 == iSite11); %dangerous error
    viSites11 = P.miSites(:, iSite11);        
    [vlA11, viiB11] = ismember(viSites11, viSites1);
    tnWav_spk1(:,viiB11(vlA11),viSpk11) = tnWav(:,vlA11,viSpk1(viSpk11));
end    
end %func


%--------------------------------------------------------------------------
function tnWav1 = tnWav1_sites_2_(tnWav1_, viSites_spk1, viSites1, P)
% reorder tnWav1 to viSites1

[nT_spk, nSites_spk, nSpk1] = size(tnWav1_);
% nSites1 = numel(viSites1);
nSites = numel(P.viSite2Chan);
tnWav1 = zeros([nT_spk, nSites, nSpk1], 'like', tnWav1_); %full
% assert_(nSites_spk==nSites1, 'tnWav1_sites_: nSites must agree');
% tnWav1 = zeros([nT_spk, nSpk1, nSites1], 'like', tnWav1_); %subset of spk, complete
for iSite1 = 1:numel(viSites1)
    iSite11 = viSites1(iSite1);
    viSpk1 = find(viSites_spk1 == iSite11);
    if isempty(viSpk1), return; end
    viSites11 = P.miSites(:, iSite11);
    tnWav1(:,viSites11,viSpk1) = tnWav1_(:,:,viSpk1);
end
% tnWav1 = permute(tnWav1, [1,3,2]);
tnWav1 = tnWav1(:, viSites1, :); %reduced subset
end %func


%--------------------------------------------------------------------------
function flag = equal_vr_(vr1, vr2)
if all(size(vr1) == size(vr2))
    ml = vr1 == vr2;
    flag = all(ml(:));
else
    flag = 0;
end
end %func


%--------------------------------------------------------------------------
function plot_proj_(hPlot, mrMin, mrMax, P, maxAmp)
if nargin<5
    [hFig, S_fig] = get_fig_cache_('FigProj');
    maxAmp = S_fig.maxAmp;
end
[vrX, vrY, viPlot, tr_dim] = amp2proj_(mrMin, mrMax, maxAmp, P.maxSite_show, P);

% make struct
maxPair = P.maxSite_show;
viSites_show = P.viSites_show;
S_plot = makeStruct_(mrMax, mrMin, viSites_show, viPlot, tr_dim, maxPair, maxAmp);

update_plot_(hPlot, vrX, vrY, S_plot);
end %func


%--------------------------------------------------------------------------
function [vrX, vrY, viPlot, tr_dim] = amp2proj_(mrMin, mrMax, maxAmp, maxPair, P)
if nargin<4, maxPair = []; end
if nargin<5, P = get0_('P'); end
% switch lower(P.vcFet_show)
%     case {'vpp', 'vmin', 'vmax'}
%         mrMax = linmap_(mrMax', [0, maxAmp/2], [0,1], 1);
%         mrMin = linmap_(mrMin', [0, maxAmp], [0,1], 1);
%     otherwise
mrMax = linmap_(mrMax', [0, 1] * maxAmp, [0,1], 1);
mrMin = linmap_(mrMin', [0, 1] * maxAmp, [0,1], 1);            
% end
[nEvt, nChans] = size(mrMin);
if isempty(maxPair), maxPair = nChans; end
[trX, trY] = deal(nan([nEvt, nChans, nChans], 'single'));
for chY = 1:nChans
    vrY1 = mrMin(:,chY);
    vlY1 = vrY1>0 & vrY1<1;
    for chX = 1:nChans
        if abs(chX-chY) > maxPair, continue; end
        if chY > chX
            vrX1 = mrMin(:,chX);
        else
            vrX1 = mrMax(:,chX);
        end
        viPlot1 = find(vrX1>0 & vrX1<1 & vlY1);
        trX(viPlot1,chY,chX) = vrX1(viPlot1) + chX - 1;
        trY(viPlot1,chY,chX) = vrY1(viPlot1) + chY - 1;
    end
end
% plot projection
viPlot = find(~isnan(trX) & ~isnan(trY));
vrX = trX(viPlot);  vrX=vrX(:);
vrY = trY(viPlot);  vrY=vrY(:);
tr_dim = size(trX);
end %func


%--------------------------------------------------------------------------
function plot_FigHist_(S0)

if nargin<1, S0 = get(0, 'UserData'); end
S_clu = S0.S_clu; P = S0.P;
[hFig, S_fig] = get_fig_cache_('FigHist');

nBins_hist = 50; % @TODO: put this in param file

vrX = logspace(0, 4, nBins_hist);
vrY1 = isi_hist_(S0.iCluCopy, vrX); 
vcTitle = sprintf('Cluster %d', S0.iCluCopy);

% draw
if isempty(S_fig) %first time the iCluPaste is always empty
    S_fig.hAx = axes_new_(hFig);
    S_fig.hPlot1 = stairs(S_fig.hAx, nan, nan, 'k'); 
    S_fig.hPlot2 = stairs(S_fig.hAx, nan, nan, 'r');     
    xlim_(S_fig.hAx, [1 10000]); %in msec
    grid(S_fig.hAx, 'on');
    xlabel(S_fig.hAx, 'ISI (ms)');
    ylabel(S_fig.hAx, 'Prob. Density');
    set(S_fig.hAx, 'XScale', 'log');
end
update_plot_(S_fig.hPlot1, vrX, vrY1);
if ~isempty(S0.iCluPaste)
    vrY2 = isi_hist_(S0.iCluPaste, vrX);
    vcTitle = sprintf('Cluster %d (black) vs %d (red)', S0.iCluCopy, S0.iCluPaste);
    update_plot_(S_fig.hPlot2, vrX, vrY2);
else
    update_plot_(S_fig.hPlot2, nan, nan);
end
title_(S_fig.hAx, vcTitle);

set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function vnHist = isi_hist_(iClu1, vrX)
P = get0_('P');
vrTime1 = double(clu_time_(iClu1)) / P.sRateHz;
vnHist = hist(diff(vrTime1)*1000, vrX);
vnHist(end)=0;
vnHist = vnHist ./ sum(vnHist);
end


%--------------------------------------------------------------------------
function plot_FigIsi_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;
[hFig, S_fig] = get_fig_cache_('FigIsi');

[vrX1, vrY1] = get_returnMap_(S0.iCluCopy, P);                        
if isempty(S_fig)
    S_fig.hAx = axes_new_(hFig);
    S_fig.hPlot1 = plot(S_fig.hAx, nan, nan, 'ko');
    S_fig.hPlot2 = plot(S_fig.hAx, nan, nan, 'ro');
    set(S_fig.hAx, 'XScale','log', 'YScale','log');   
    xlabel('ISI_{k} (ms)'); ylabel('ISI_{k+1} (ms)');
    axis_(S_fig.hAx, [1 10000 1 10000]);
    grid(S_fig.hAx, 'on');
    % show refractory line
    line(get(S_fig.hAx,'XLim'), P.spkRefrac_ms*[1 1], 'Color', [1 0 0]);
    line(P.spkRefrac_ms*[1 1], get(S_fig.hAx,'YLim'), 'Color', [1 0 0]);
end  
update_plot_(S_fig.hPlot1, vrX1, vrY1);
if ~isempty(S0.iCluPaste)    
    [vrX2, vrY2] = get_returnMap_(S0.iCluPaste, P);
    update_plot_(S_fig.hPlot2, vrX2, vrY2);
else
    update_plot_(S_fig.hPlot2, nan, nan);
end

set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function [vrX, vrY] = get_returnMap_(iClu, P)
vrTime1 = double(clu_time_(iClu)) / P.sRateHz;
vrIsi1 = diff(vrTime1 * 1000); % in msec
vrX = vrIsi1(1:end-1);
vrY = vrIsi1(2:end);
viShow = randperm(numel(vrX), min(P.nShow, numel(vrX)));
vrX = vrX(viShow);
vrY = vrY(viShow);
end


%--------------------------------------------------------------------------
function plot_FigMap_(S0)
if nargin<1, S0 = get(0, 'UserData'); end 
P = S0.P; S_clu = S0.S_clu;
[hFig, S_fig] = get_fig_cache_('FigMap');

mrWav1 = S_clu.tmrWav_clu(:,:,S0.iCluCopy);
vrVpp = squeeze_(max(mrWav1) - min(mrWav1));
mrVpp = repmat(vrVpp(:)', [4, 1]);
if isempty(S_fig)
    S_fig.hAx = axes_new_(hFig);
    [S_fig.mrPatchX, S_fig.mrPatchY] = probe_map_(P);
    S_fig.hPatch = patch(S_fig.mrPatchX, S_fig.mrPatchY, mrVpp, ...
        'EdgeColor', 'k', 'FaceColor', 'flat');
    S_fig.alim = [min(S_fig.mrPatchX(:)), max(S_fig.mrPatchX(:)), min(S_fig.mrPatchY(:)), max(S_fig.mrPatchY(:))];
    colormap jet;
    mouse_figure(hFig);   
    nSites = size(P.mrSiteXY,1);    
    csText = arrayfun(@(i)sprintf('%d', i), 1:nSites, 'UniformOutput', 0);
    S_fig.hText = text(P.mrSiteXY(:,1), P.mrSiteXY(:,2), csText, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');    
    xlabel('X Position (\mum)');
    ylabel('Y Position (\mum)');
else    
    set(S_fig.hPatch, 'CData', mrVpp);    
end
title_(S_fig.hAx, sprintf('Max: %0.1f \\muVpp', max(vrVpp)));
axis_(S_fig.hAx, S_fig.alim);
caxis(S_fig.hAx, [0, max(vrVpp)]);

set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function [mrPatchX, mrPatchY] = probe_map_(P)
vrX = [0 0 1 1] * P.vrSiteHW(2); 
vrY = [0 1 1 0] * P.vrSiteHW(1);
mrPatchX = bsxfun(@plus, P.mrSiteXY(:,1)', vrX(:));
mrPatchY = bsxfun(@plus, P.mrSiteXY(:,2)', vrY(:));
end %func


%--------------------------------------------------------------------------
function clu_info_(S0)
% This also plots cluster position
if nargin<1, S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;
mh_info = get_tag_('mh_info', 'uimenu');
S_clu1 = get_cluInfo_(S0.iCluCopy);
if ~isempty(S0.iCluPaste)
    S_clu2 = get_cluInfo_(S0.iCluPaste);
    vcLabel = sprintf('Unit %d "%s" vs. Unit %d "%s"', ...
        S0.iCluCopy, S_clu.csNote_clu{S0.iCluCopy}, ...
        S0.iCluPaste, S_clu.csNote_clu{S0.iCluPaste});
    set(mh_info, 'Label', vcLabel);
else
    S_clu2 = [];
    vcLabel = sprintf('Unit %d "%s"', S0.iCluCopy, S_clu.csNote_clu{S0.iCluCopy});
    set(mh_info, 'Label', vcLabel);
end
plot_FigPos_(S_clu1, S_clu2);
end %func


%--------------------------------------------------------------------------
function S_cluInfo = get_cluInfo_(iClu)

% determine cluster position
if isempty(iClu), S_cluInfo=[]; return; end
[S0, P, S_clu] = get0_();

iSite1 = S_clu.viSite_clu(iClu);
viSite = P.miSites(:, iSite1);

xyPos = [S_clu.vrPosX_clu(iClu), S_clu.vrPosY_clu(iClu)];
vcPos = sprintf('Unit %d (x,y):(%0.1f, %0.1f)[pix]', iClu, xyPos/P.um_per_pix);
if P.fWav_raw_show
    mrWav_clu = S_clu.tmrWav_raw_clu(:,viSite,iClu);    
else
    mrWav_clu = S_clu.tmrWav_clu(:,viSite,iClu);    
end
trWav = trWav_clu_(iClu, P.nSpk_show * 1); 
if P.fWav_raw_show
    trWav = fft_lowpass_(trWav, get_set_(P, 'fc_spkwav_show', []), P.sRateHz);
end
S_cluInfo = makeStruct_(xyPos, iClu, mrWav_clu, viSite, vcPos, trWav);
try
    S_cluInfo.l_ratio = S_clu.vrLRatio_clu(iClu);
    S_cluInfo.isi_ratio = S_clu.vrIsiRatio_clu(iClu);
    S_cluInfo.iso_dist = S_clu.vrIsoDist_clu(iClu);
    S_cluInfo.snr = S_clu.vrSnr_clu(iClu);
    S_cluInfo.uVmin = S_clu.vrVmin_uv_clu(iClu);
    S_cluInfo.uVpp = S_clu.vrVpp_uv_clu(iClu);
catch    
end
end %func


%--------------------------------------------------------------------------
function plot_FigPos_(S_clu1, S_clu2)
[hFig, S_fig] = get_fig_cache_('FigPos');
[S0, P, S_clu] = get0_();

% plot waveform in space
if isempty(S_fig)
    S_fig.hAx = axes_new_(hFig);
else
    cla(S_fig.hAx); hold(S_fig.hAx, 'on');
end
plot_unit_(S_clu1, S_fig.hAx, [0 0 0]);
%vrPosXY1 = [S_clu.vrPosX_clu(S_clu1.iClu), S_clu.vrPosY_clu(S_clu1.iClu)] / P.um_per_pix;
vrPosXY1 = [S_clu.vrPosX_clu(S_clu1.iClu), S_clu.vrPosY_clu(S_clu1.iClu)];
nSpk1 = S_clu.vnSpk_clu(S_clu1.iClu);
if isempty(S_clu2)        
    vcTitle = sprintf('Unit %d: %d spikes; (X,Y)=(%0.1f, %0.1f)um', S_clu1.iClu, nSpk1, vrPosXY1);
    try
        vcTitle = sprintf('%s\nSNR=%0.1f; %0.1fuVmin %0.1fuVpp (IsoD,ISIr,Lrat)=(%0.1f,%0.2f,%0.1f)', ...
            vcTitle, S_clu1.snr, S_clu1.uVmin, S_clu1.uVpp, S_clu1.iso_dist, S_clu1.isi_ratio, S_clu1.l_ratio);
    catch
    end
else
    nSpk2 = S_clu.vnSpk_clu(S_clu2.iClu);
    vrPosXY2 = [S_clu.vrPosX_clu(S_clu2.iClu), S_clu.vrPosY_clu(S_clu2.iClu)];
    plot_unit_(S_clu2, S_fig.hAx, [1 0 0]);
    vcTitle = sprintf('Units %d/%d (black/red); (%d/%d) spikes\nSNR=%0.1f/%0.1f; (X,Y)=(%0.1f/%0.1f, %0.1f/%0.1f)um', ...
        S_clu1.iClu, S_clu2.iClu, nSpk1, nSpk2, S_clu1.snr, S_clu2.snr, ...
        vrPosXY1(1), vrPosXY2(1), vrPosXY1(2), vrPosXY2(2));
end
title_(S_fig.hAx, vcTitle);
set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function plot_unit_(S_clu1, hAx, vcColor0)
if isempty(S_clu1), return; end
if nargin<2, hAx = axes_new_('FigWav'); end
if nargin<3, vcColor0 = [0 0 0]; end
[S0, P, S_clu] = get0_();
[~, S_figWav] = get_fig_cache_('FigWav');
maxAmp = S_figWav.maxAmp;
% plot individual unit
nSamples = size(S_clu1.mrWav_clu,1);
vrX = (1:nSamples)'/nSamples;
vrX([1,end])=nan; % line break

if ~isequal(vcColor0, [0 0 0])
    trWav1 = zeros(1,1,0);
else
    trWav1 = S_clu1.trWav;
end

% show example traces
for iWav = size(trWav1,3):-1:0
    if iWav==0
        mrY1 = S_clu1.mrWav_clu / maxAmp;
        lineWidth=1.5;
        vcColor = vcColor0;
    else
        mrY1 = trWav1(:,:,iWav) / maxAmp;
        lineWidth=.5;
        vcColor = .5*[1,1,1];
    end
    vrX1_site = P.mrSiteXY(S_clu1.viSite, 1) / P.um_per_pix;
    vrY1_site = P.mrSiteXY(S_clu1.viSite, 2) / P.um_per_pix;
    mrY1 = bsxfun(@plus, mrY1, vrY1_site');
    mrX1 = bsxfun(@plus, repmat(vrX, [1, size(mrY1, 2)]), vrX1_site');
    line(mrX1(:), mrY1(:), 'Color', vcColor, 'Parent', hAx, 'LineWidth', lineWidth);
end
xlabel(hAx, 'X pos [pix]');
ylabel(hAx, 'Z pos [pix]');
grid(hAx, 'on');
xlim_(hAx, [min(mrX1(:)), max(mrX1(:))]);
ylim_(hAx, [floor(min(mrY1(:))-1), ceil(max(mrY1(:))+1)]);
end %func


%--------------------------------------------------------------------------
function trWav1 = trWav_clu_(iClu1, nSpk_show)
% Get a subset of spike waveforms of a cluster

if nargin<2, nSpk_show=inf; end
S0 = get(0, 'UserData');
P = S0.P;
tnWav_ = get_spkwav_(P);
[viSpk_clu1, viiSpk_clu1] = S_clu_viSpk_(S0.S_clu, iClu1, S0.viSite_spk);
viSpk_clu1 = randomSelect_(viSpk_clu1, nSpk_show);
if P.fWav_raw_show
    trWav1 = raw2uV_(tnWav_(:,:,viSpk_clu1), P);
else
    trWav1 = tnWav2uV_(tnWav_(:,:,viSpk_clu1), P);
end
end %func


%--------------------------------------------------------------------------
function rescale_FigWav_(event, S0, P)
% figure_wait_(1);
set(0, 'UserData', S0);

[S_fig, maxAmp_prev, hFigWav] = set_fig_maxAmp_('FigWav', event);                
set_fig_(hFigWav, plot_tnWav_clu_(S_fig, P));
multiplot(S0.hCopy, S_fig.maxAmp);
if ~isempty(S0.iCluPaste)
    multiplot(S0.hPaste, S_fig.maxAmp);
end
rescale_spikes_(S_fig.hSpkAll, maxAmp_prev, P);
title_(S_fig.hAx, sprintf(S_fig.vcTitle, S_fig.maxAmp)); %update scale
end


%--------------------------------------------------------------------------
function rescale_FigTime_(event, S0, P)
% rescale_FigTime_(event, S0, P)
% rescale_FigTime_(maxAmp, S0, P)
if nargin<2, S0 = []; end
if nargin<3, P = []; end

if isempty(S0), S0 = get0_(); end
if isempty(P), P = S0.P; end
S_clu = S0.S_clu;

[S_fig, maxAmp_prev] = set_fig_maxAmp_('FigTime', event);
ylim_(S_fig.hAx, [0, 1] * S_fig.maxAmp);
imrect_set_(S_fig.hRect, [], [0, S_fig.maxAmp]);
iSite = S_clu.viSite_clu(S0.iCluCopy);

% switch lower(P.vcFet_show)
%     case {'vpp', 'vmin'} %voltage feature
%         vcYlabel = sprintf('Site %d (\\mu%s)', iSite, P.vcFet_show);
%     otherwise %other feature options
%         vcYlabel = sprintf('Site %d (%s)', iSite, P.vcFet_show);
% end
% ylabel(S_fig.hAx, vcYlabel);

end %func


%--------------------------------------------------------------------------
function button_CluWav_(xyPos, vcButton)
if strcmpi(vcButton, 'normal')
    event.Button = 1;
elseif strcmpi(vcButton, 'alt')
    event.Button = 3;
else
    return;
end
xPos = round(xyPos(1));
S0 = get(0, 'UserData');
switch(event.Button)
    case 1 %left click. copy clu and delete existing one
        S0 = update_cursor_(S0, xPos, 0);
    case 2 %middle, ignore
        return; 
    case 3 %right click. paste clu
        S0 = update_cursor_(S0, xPos, 1);
end
figure_wait_(1);
S0 = keyPressFcn_cell_(get_fig_cache_('FigWav'), {'j','t','c','i','v','e','f'}, S0); %'z'
auto_scale_proj_time_(S0);
set(0, 'UserData', S0);
plot_raster_(S0);
figure_wait_(0);
end %func


%--------------------------------------------------------------------------
function keyPressFcn_FigTime_(hObject, event, S0)

if nargin<3, S0 = get(0, 'UserData'); end
[P, S_clu, hFig] = deal(S0.P, S0.S_clu, hObject);
S_fig = get(hFig, 'UserData');

nSites = numel(P.viSite2Chan);
% set(hObject, 'Pointer', 'watch');
% figure_wait(1);
switch lower(event.Key)
    case {'leftarrow', 'rightarrow'}
        if ~isVisible_(S_fig.hAx)
            msgbox_('Channel switching is disabled in the position view'); return; 
        end
        factor = key_modifier_(event, 'shift')*3 + 1;
        if strcmpi(event.Key, 'rightarrow')
            S_fig.iSite = min(S_fig.iSite + factor, nSites);
        else
            S_fig.iSite = max(S_fig.iSite - factor, 1);
        end
        set(hFig, 'UserData', S_fig);        
        update_FigTime_();                

    case {'uparrow', 'downarrow'} %change ampl
        if ~isVisible_(S_fig.hAx)
            msgbox_('Zoom is disabled in the position view'); return; 
        end
        rescale_FigTime_(event, S0, P);
        
    case 'r' %reset view
        if ~isVisible_(S_fig.hAx), return; end
        axis_(S_fig.hAx, [S_fig.time_lim, S_fig.vpp_lim]);
        imrect_set_(S_fig.hRect, S_fig.time_lim, S_fig.vpp_lim);

    case 'm' %merge
        ui_merge_(S0);
        
    case 'h' %help
        msgbox_(S_fig.csHelp, 1);
        
    case 'b' %background spike toggle
        if isVisible_(S_fig.hAx)  
            S_fig.fPlot0 = toggleVisible_(S_fig.hPlot0);
        else
            S_fig.fPlot0 = toggleVisible_(S_fig.hPlot0_track);
        end
        set(hFig, 'UserData', S_fig);
        
    case 't'
        plot_FigTime_(S0);
        
%     case 'z' % track depth
%         disp('FigTime:''z'' not implemented yet');
%         plot_SpikePos_(S0, event);
        
    case 's' %split. draw a polygon
        if ~isempty(S0.iCluPaste)
            msgbox_('Select one cluster'); return;
        end
        try
            hPoly = impoly_();
            if isempty(hPoly); return ;end
            mrPolyPos = getPosition(hPoly);
            vrX1 = double(get(S_fig.hPlot1, 'XData'));
            vrY1 = double(get(S_fig.hPlot1, 'YData'));
            vlIn = inpolygon(vrX1, vrY1, mrPolyPos(:,1), mrPolyPos(:,2));
            hSplit = line(vrX1(vlIn), vrY1(vlIn), 'Color', [1 0 0], 'Marker', '.', 'LineStyle', 'none');
            if strcmpi(questdlg_('Split?', 'Confirmation', 'Yes'), 'yes')
                split_clu_(S0.iCluCopy, vlIn);
            end
            delete_multi_(hPoly, hSplit);
        catch
            disp(lasterror());
        end
        
    case 'p' %update projection view
        vrPos = getPosition(S_fig.hRect);
        tlim_proj = [vrPos(1), sum(vrPos([1,3]))];
        P.tlim_proj = tlim_proj;
        plot_FigProj_(S0);
        
%     case 'f' % feature display instead of amplitude display
%         if strcmpi(P.vcFet_show, 'fet')
%             P.vcFet_show = 'vpp';
%         else
%             P.vcFet_show = 'fet';
%         end
%         set0_(P);
%         update_FigTime_();     
        
    case 'c' % compare pca across channels
        disp('FigTime: Not implemented yet'); return;
%         hMsg = msgbox_('Plotting...');
%         figure; hold on;
%         [mrWav_mean1, viSite1] = mrWav_int_mean_clu_(S0.iCluCopy);
%         [~, mrPv1] = pca(mrWav_mean1, 'NumComponents', P.nPc_dip, 'Center', 1);
%         mrPv1 = norm_mr_(mrPv1);
%         
%         if key_modifier_(event, 'control') %show chain of clusters
%             trPv1 = mrPv1;
%             iClu_next = get_next_clu_(S_clu, S0.iCluCopy);
%             viClu_track = S0.iCluCopy;
%             while ~isempty(iClu_next)
%                 [mrWav_mean1, viSite1] = mrWav_int_mean_clu_(iClu_next);
%                 [~, mrPv1a] = pca(mrWav_mean1, 'NumComponents', P.nPc_dip, 'Center', 1);        
%                 mrPv1a = norm_mr_(mrPv1a);
%                 mrPv1 = flip_prinvec_(mrPv1a, mean(trPv1,3));
%                 trPv1 = cat(3, trPv1, mrPv1);
%                 viClu_track(end+1) = iClu_next;
%                 
%                 iClu_next = get_next_clu_(S_clu, iClu_next);
%             end      
%             multiplot(plot(nan,nan,'k'), 1, 1:size(trPv1,1), trPv1);
% %             mr2plot(norm_mr_(mrPv1), 'scale', 1, 'LineStyle', 'k');
%             vcTitle = sprintf('PCA across chan: Clu %s', sprintf('%d,', viClu_track));
%         elseif ~isempty(S0.iCluPaste)            
%             [mrWav_mean2, viSite1] = mrWav_int_mean_clu_(S0.iCluPaste);
%             [~, mrPv2] = pca(mrWav_mean2, 'NumComponents', P.nPc_dip);     
%             mrPv2 = match_mrPv_(mrPv2, mrPv1);
% %             mrPv2 = flip_prinvec_(mrPv2, mrPv1);
%             mr2plot(norm_mr_(mrPv1), 'scale', 1, 'LineStyle', 'k');
%             mr2plot(norm_mr_(mrPv2), 'scale', 1, 'LineStyle', 'r--');            
%             vcTitle = sprintf('PCA across chan: Clu %d vs %d', S0.iCluCopy, S0.iCluPaste);            
%         else        
%             mr2plot(norm_mr_(mrPv1), 'scale', 1, 'LineStyle', 'r');
%             vcTitle = sprintf('PCA across chan: Clu %d', S0.iCluCopy);                        
%         end
% %         mr2plot(mrPv1, 'scale', 1, 'LineStyle', 'k');
%         grid on; 
%         title_(vcTitle);
% %         if ~isempty(S0.iCluPaste)   
% %             compare_interp_(Sclu, S0.iCluCopy, S0.iCluPaste);
% %         end
%         try close(hMsg); catch; end
        
%     case 'f' %feature export
%         eval(sprintf('mrFet_clu%d = getFet_clu_(S0.iCluCopy);', S0.iCluCopy));
%         mrDist1 = squareform(pdist(mrFet1'));
%         vrFet1 = sqrt(sum(mrFet1.^2));
%         mrDist1 = bsxfun(@rdivide, mrDist1, vrFet1); %norm        
%         eval(sprintf('assignWorkspace_(mrFet_clu%d);', S0.iCluCopy));
        
    case 'e' %export selected to workspace
        disp('FigTime: ''e'' not implemented yet'); return;
end %switch
% drawnow;
% figure_wait(0);
end %func


%--------------------------------------------------------------------------
function rescale_spikes_(hSpkAll, maxAmp_prev, P)
S = get(hSpkAll, 'UserData');
[~, S_fig] = get_fig_cache_('FigWav');
S0 = get(0, 'UserData');
cvrY = S.cvrY;
cviSite = S.cviSite;
% nSamples = diff(P.spkLim)+1;
scale = S_fig.maxAmp / maxAmp_prev;
for iClu=1:numel(cvrY)
    viSite1 = cviSite{iClu};
    nSites1 = numel(viSite1);
    trY = reshape(cvrY{iClu}, [], nSites1, S.vnSpk(iClu));
    for iSite1 = 1:nSites1
        y_off = viSite1(iSite1);
        trY(:,iSite1,:) = (trY(:,iSite1,:) - y_off) / scale + y_off;
    end
    cvrY{iClu} = trY(:);
end
S.cvrY = cvrY;
set(hSpkAll, 'YData', cell2mat_(cvrY), 'UserData', S);
end


%--------------------------------------------------------------------------
function keyPressFcn_FigProj_(hFig, event)
S0 = get(0, 'UserData');
[P, S_clu] = deal(S0.P, S0.S_clu);
[hFig, S_fig] = get_fig_cache_('FigProj');
% nSites = numel(P.viSite2Chan);
S_plot1 = get(S_fig.hPlot1, 'UserData');
viSites_show = S_plot1.viSites_show;
% nSites = numel(viSites_show);
% set(hObject, 'Pointer', 'watch');
figure_wait_(1);
switch lower(event.Key)
    case {'uparrow', 'downarrow'}
        rescale_FigProj_(event, hFig, S_fig, S0);

    case {'leftarrow', 'rightarrow'} % change channels
        fPlot = 0;
        if strcmpi(event.Key, 'leftarrow')
            if min(S_fig.viSites_show)>1
                S_fig.viSites_show=S_fig.viSites_show-1; 
                fPlot = 1;
            end
        else
            if max(S_fig.viSites_show) < max(P.viSite2Chan)
                S_fig.viSites_show=S_fig.viSites_show+1;                 
                fPlot = 1;
            end
        end
        if fPlot
            set(hFig, 'UserData', S_fig);
            S0.P.viSites_show = S_fig.viSites_show;
            plot_FigProj_(S0);
        end
        
    case 'r' %reset view
        axis_([0 numel(viSites_show) 0 numel(viSites_show)]);

    case 's' %split
        figure_wait_(0);
        if ~isempty(S0.iCluPaste)
            msgbox_('Select one cluster to split'); return;
        end
        S_plot1 = select_polygon_(S_fig.hPlot1); 
        if ~isempty(S_plot1)
            [fSplit, vlIn] = plot_split_(S_plot1);
            if fSplit
                S_clu = split_clu_(S0.iCluCopy, vlIn);
            else
                update_plot2_proj_();
%                 delete_multi_(S_plot1.hPoly);
            end
        end
        
    case 'm'
        ui_merge_(S0);
        
    case 'f'
        disp('keyPressFcn_FigProj_: ''f'': not implemented yet');
%         if strcmpi(P.vcFet_show, 'vpp')
%             S0.vcFet_show = P.vcFet;
%         else
%             S0.vcFet_show = 'vpp';
%         end
%         set(0, 'UserData', S0);        
%         plot_FigProj_();        
        
    case 'b' %background spikes
        toggleVisible_(S_fig.hPlot0);

    case 'h' %help
        msgbox_(S_fig.csHelp, 1);
end %switch
% drawnow;
figure_wait_(0);
end %func


%--------------------------------------------------------------------------
% 122917 JJJ: modified
function S_fig = rescale_FigProj_(event, hFig, S_fig, S0)
% S_fig = rescale_FigProj_(event, hFig, S_fig, S0)
% S_fig = rescale_FigProj_(maxAmp)

if nargin<2, hFig = []; end
if nargin<3, S_fig = []; end
if nargin<4, S0 = []; end
if isempty(hFig) || isempty(S_fig), [hFig, S_fig] = get_fig_cache_('FigProj'); end
if isempty(S0), S0 = get(0, 'UserData'); end
P = S0.P;

if isnumeric(event)
    S_fig.maxAmp = event;
else
    S_fig.maxAmp = change_amp_(event, S_fig.maxAmp);     
end
vhPlot = [S_fig.hPlot0, S_fig.hPlot1, S_fig.hPlot2];
if isempty(S0.iCluPaste), vhPlot(end) = []; end
rescaleProj_(vhPlot, S_fig.maxAmp, S0.P);
switch lower(P.vcFet_show)
    case {'vpp', 'vmin', 'vmax'}
        S_fig.vcXLabel = 'Site # (%0.0f \\muV; upper: V_{min}; lower: V_{max})';
        S_fig.vcYLabel = 'Site # (%0.0f \\muV_{min})';
    otherwise
        S_fig.vcXLabel = sprintf('Site # (%%0.0f %s; upper: %s1; lower: %s2)', P.vcFet_show, P.vcFet_show, P.vcFet_show);
        S_fig.vcYLabel = sprintf('Site # (%%0.0f %s)', P.vcFet_show);    
end
xlabel(S_fig.hAx, sprintf(S_fig.vcXLabel, S_fig.maxAmp));   
ylabel(S_fig.hAx, sprintf(S_fig.vcYLabel, S_fig.maxAmp));  
if nargout==0
    set(hFig, 'UserData', S_fig);
end
end


%--------------------------------------------------------------------------
function rescaleProj_(vhPlot1, maxAmp, P)
if nargin<3, P = get0_('P'); end
for iPlot=1:numel(vhPlot1)
    hPlot1 = vhPlot1(iPlot);
    S_plot1 = get(hPlot1, 'UserData');
    update_plot2_proj_();
    S_plot1 = struct_delete_(S_plot1, 'hPoly'); %, 'hPlot_split'
    [vrX, vrY, viPlot, tr_dim] = amp2proj_(S_plot1.mrMin, S_plot1.mrMax, maxAmp, P.maxSite_show, P);
    S_plot1 = struct_add_(S_plot1, viPlot, vrX, vrY, maxAmp);
    set(hPlot1, 'XData', vrX, 'YData', vrY, 'UserData', S_plot1);
end
end %func


%--------------------------------------------------------------------------
function button_FigWavCor_(xyPos, vcButton)
S0 = get(0, 'UserData');
xyPos = round(xyPos);
switch lower(vcButton)
    case 'normal' %left click        
        S0.iCluCopy = xyPos(1);
        if diff(xyPos) == 0
            S0.iCluPaste = [];
        else
            S0.iCluPaste = xyPos(2);
        end
        S0 = button_CluWav_simulate_(S0.iCluCopy, S0.iCluPaste, S0);
        S0 = keyPressFcn_cell_(get_fig_cache_('FigWav'), {'z'}, S0); %zoom        
end %switch
end %func


%--------------------------------------------------------------------------
function [mrFet1, viSpk1] = getFet_clu_(iClu1, iSite, S0)
% get features on-fly
MAX_SAMPLE = 10000;     % max points ti display
if nargin<3
    [S_clu, P, viSite_spk] = get0_('S_clu', 'P', 'viSite_spk');
else
    [S_clu, P, viSite_spk] = deal(S0.S_clu, S0.P, S0.viSite_spk);
end
% if nargin<2, viSite = P.miSites(:, S0.S_clu.viSite_clu(iClu1)); end
if isempty(iClu1) % select spikes based on sites
    n_use = 1 + round(P.maxSite);
    viSite_ = P.miSites(1:n_use, iSite);
    try
        viSpk1 = cell2mat_([S0.cviSpk_site(viSite_)]');
    catch
        viSpk1 = find(ismember(viSite_spk, viSite_));
    end
    viSpk1 = randomSelect_(viSpk1, MAX_SAMPLE);    
else
    viSpk1 = S_clu.cviSpk_clu{iClu1};
end

switch lower(P.vcFet_show)
    case {'vmin', 'vpp'}
        mrWav_spk1 = squeeze_(tnWav2uV_(tnWav_spk_sites_(viSpk1, iSite, S0), P));
        mrFet1 = max(mrWav_spk1)-min(mrWav_spk1);
    case 'cov'
        mrFet1 = calc_cov_spk_(viSpk1, iSite);
    case {'pca', 'gpca'}
        mrFet1 = pca_pc_spk_(viSpk1, iSite);
    case {'ppca', 'private pca'}
        [mrPv1, mrPv2] = pca_pv_clu_(iSite, S0.iCluCopy);
        mrFet1 = pca_pc_spk_(viSpk1, iSite, mrPv1, mrPv2);
    otherwise
        error('not implemented yet');
end
mrFet1 = squeeze_(abs(mrFet1));
end %func


%--------------------------------------------------------------------------
function [vi1, vrX1, vrY1, xlim1, ylim1] = imrect_plot_(hRect, hPlot1)
% return points inside
vrX = get(hPlot1, 'XData');
vrY = get(hPlot1, 'YData');
vrPos_rect = getPosition(hRect);
xlim1 = vrPos_rect(1) + [0, vrPos_rect(3)];
ylim1 = vrPos_rect(2) + [0, vrPos_rect(4)];
vi1 = find(vrX>=xlim1(1) & vrX<=xlim1(2) & vrY>=ylim1(1) & vrY<=ylim1(2));
if nargout>=2
    vrX1 = vrX(vi1);
    vrY1 = vrY(vi1);
end
end %func


%--------------------------------------------------------------------------
function [tnWav_raw, tnWav_spk, viTime_spk] = mn2tn_wav_(mnWav_raw, mnWav_spk, viSite_spk, viTime_spk, P)
nSpks = numel(viTime_spk);
nSites = numel(P.viSite2Chan);
spkLim_wav = P.spkLim;
spkLim_raw = P.spkLim_raw;
nSites_spk = (P.maxSite * 2) + 1;
tnWav_raw = zeros(diff(spkLim_raw) + 1, nSites_spk, nSpks, 'like', mnWav_raw);
tnWav_spk = zeros(diff(spkLim_wav) + 1, nSites_spk, nSpks, 'like', mnWav_spk);

% Realignment parameters
fRealign_spk = get_set_(P, 'fRealign_spk', 0); %0,1,2
viTime_spk = gpuArray_(viTime_spk, isGpu_(mnWav_raw));
viSite_spk = gpuArray_(viSite_spk, isGpu_(mnWav_raw));
if isempty(viSite_spk)
    tnWav_raw = permute(mr2tr3_(mnWav_raw, spkLim_raw, viTime_spk), [1,3,2]);
    tnWav_spk = permute(mr2tr3_(mnWav_spk, spkLim_wav, viTime_spk), [1,3,2]);
else
    for iSite = 1:nSites
        viiSpk11 = find(viSite_spk == iSite);
        if isempty(viiSpk11), continue; end
        viTime_spk11 = viTime_spk(viiSpk11); %already sorted by time
        viSite11 = P.miSites(:,iSite);
        try
            tnWav_spk1 = mr2tr3_(mnWav_spk, spkLim_wav, viTime_spk11, viSite11);
            if fRealign_spk==1
                [tnWav_spk1, viTime_spk11] = spkwav_realign_(tnWav_spk1, mnWav_spk, spkLim_wav, viTime_spk11, viSite11, P);
                viTime_spk(viiSpk11) = viTime_spk11;
            elseif fRealign_spk==2
                tnWav_spk1 = spkwav_align_(tnWav_spk1, P);
            end
            tnWav_spk(:,:,viiSpk11) = permute(tnWav_spk1, [1,3,2]);
            tnWav_raw(:,:,viiSpk11) = permute(mr2tr3_(mnWav_raw, spkLim_raw, viTime_spk11, viSite11), [1,3,2]); %raw
        catch % GPU failure
            disperr_('mn2tn_wav_: GPU failed'); 
        end
    end
end
if 1 %10/19/2018 JJJ
    tnWav_spk = meanSubt_spk_(tnWav_spk);
    tnWav_raw = meanSubt_spk_(tnWav_raw);
end
end %func


%--------------------------------------------------------------------------
% 10/18/17 JJJ: created
function [tnWav_spk1, viSpk_left, viSpk_right] = spkwav_align_(tnWav_spk1, P)
nInterp_spk = 2;
% viTime0 = 1:size(tnWav_spk,1);

imin_int = (-P.spkLim(1))*nInterp_spk+1;
[mnWav_spk1_int, vi_int] = interpft_(tnWav_spk1(:,:,1), nInterp_spk);
[~,viMin_int] = min(mnWav_spk1_int);     
viSpk_right = find(viMin_int == imin_int+1);  
viSpk_left = find(viMin_int == imin_int-1);   
if ~isempty(viSpk_right)
    tnWav_spk1_right = interpft_(tnWav_spk1(:,viSpk_right,:), nInterp_spk);
    tnWav_spk1(1:end-1,viSpk_right,:) = tnWav_spk1_right(2:nInterp_spk:end,:,:);
end
if ~isempty(viSpk_left)
    tnWav_spk1_left = interpft_(tnWav_spk1(:,viSpk_left,:), nInterp_spk);
    tnWav_spk1(2:end,viSpk_left,:) = tnWav_spk1_left(2:nInterp_spk:end,:,:); %todo for nInterp_spk~=2
end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Bugfix: returning S0 so that the cluster can be updated
function S0 = ui_delete_(S0)
if nargin<1, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
P = S0.P;
if ~isempty(S0.iCluPaste)
    msgbox_('Must select one cluster', 1); return;
end        
figure_wait_(1);

iClu_del = S0.iCluCopy;
% hMsg = msgbox_open_('Deleting...');
S0.S_clu = delete_clu_(S0.S_clu, S0.iCluCopy);
set(0, 'UserData', S0);
plot_FigWav_(S0); %redraw plot 
% S0.S_clu.mrWavCor = wavCor_delete_(S0.iCluCopy); 
FigWavCor_update_(S0);
S0.iCluCopy = min(S0.iCluCopy, S0.S_clu.nClu);
% set(0, 'UserData', S0);
button_CluWav_simulate_(S0.iCluCopy);

% close_(hMsg);
figure_wait_(0);
fprintf('%s [W] deleted Clu %d\n', datestr(now, 'HH:MM:SS'), iClu_del);
S0 = save_log_(sprintf('delete %d', iClu_del), S0);
set(0, 'UserData', S0);
end


%--------------------------------------------------------------------------
function FigWavCor_update_(S0)
if nargin<1, S0 = get(0, 'UserData'); end

[hFig, S_fig] = get_fig_cache_('FigWavCor');
set(S_fig.hImWavCor, 'CData', S0.S_clu.mrWavCor);
% plotDiag_([0, nSites], '-', 'Color', [0 0 0], 'LineWidth', 1.5, 'Parent', S_fig.); %plot in one scoop
nClu = size(S0.S_clu.mrWavCor, 1);
[vrX, vrY] = plotDiag__([0, nClu, .5]);
set(S_fig.hDiag, 'XData', vrX, 'YData', vrY);
end %func


%--------------------------------------------------------------------------
% 10/27/17 JJJ: Delete multiple clusters
function S_clu = delete_clu_(S_clu, viClu_delete)
% sets the cluster to zero
nClu_prev = S_clu.nClu;
viClu_keep = setdiff(1:nClu_prev, viClu_delete);
try
    S_clu = S_clu_select_(S_clu, viClu_keep); % remap all
catch
    disp('err');
end

iClu_del = min(S_clu.viClu) - 1;
if iClu_del==0, iClu_del = -1; end
vlDelete_spk = ismember(S_clu.viClu, viClu_delete);
S_clu.viClu(vlDelete_spk) = iClu_del;
nClu_new = numel(viClu_keep);

vlMap = S_clu.viClu > 0;
viMap = zeros(1, nClu_prev);
viMap(viClu_keep) = 1:nClu_new;
S_clu.viClu(vlMap) = viMap(S_clu.viClu(vlMap));
S_clu.nClu = nClu_new;
% update viClu
% if viClu_delete < max(S_clu.viClu)
%     viUpdate = find(S_clu.viClu>viClu_delete);
%     S_clu.viClu(viUpdate) = S_clu.viClu(viUpdate) - 1;
% end
% for iClu3 = viClu_delete+1:S_clu.nClu % update cluster chain info
%     S_clu = S_clu_update_note_(S_clu, iClu3, get_next_clu_(S_clu, iClu3) - 1);
% end
assert_(S_clu_valid_(S_clu), 'Cluster number is inconsistent after deleting');
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_update_note_(S_clu, iClu1, iClu_next)
if isempty(iClu_next), return ;end
vcNote_clu1 = S_clu.csNote_clu{iClu1};
if isempty(vcNote_clu1), return; end
iStart = find(vcNote_clu1 == '=', 1, 'first');
if isempty(iStart), return; end
vcPre = vcNote_clu1(1:iStart);
vcNote_clu1 = vcNote_clu1(iStart+1:end);
iEnd = find(vcNote_clu1 == ',' | vcNote_clu1 == ';' | vcNote_clu1 == ' ', 1, 'first');
if ~isempty(iEnd)
    vcNote_clu1 = vcNote_clu1(1:iEnd-1); 
    vcPost = vcNote_clu1(iEnd:end);
else
    vcPost = '';
end
S_clu.csNote_clu{iClu1} = sprintf('%s%d%s', vcPre, iClu_next, vcPost);

if isnan(iClu_next), iClu_next = []; return; end
end %func


%--------------------------------------------------------------------------
function iClu_next = get_next_clu_(S_clu, iClu1)
%  get a next cluster number reading from Sclu.csNote_clu "=Clu#"
iClu_next = [];
vcNote_clu1 = S_clu.csNote_clu{iClu1};
if isempty(vcNote_clu1), return; end
iStart = find(vcNote_clu1 == '=', 1, 'first');
if isempty(iStart), return; end
vcNote_clu1 = vcNote_clu1(iStart+1:end);
iEnd = find(vcNote_clu1 == ',' | vcNote_clu1 == ';' | vcNote_clu1 == ' ', 1, 'first');
if ~isempty(iEnd), vcNote_clu1 = vcNote_clu1(1:iEnd-1); end
iClu_next = str2double(vcNote_clu1);
if isnan(iClu_next), iClu_next = []; return; end
end %func


%--------------------------------------------------------------------------
function restore_clu_(varargin)
% restore last deleted. most negative clu is last deleted
% error('to be fixed. Fix centroid code');
S0 = get(0, 'UserData');
[P, S_clu] = deal(S0.P, S0.S_clu);
iClu_del = min(S_clu.viClu);
if iClu_del >=0, msgbox_('Deleted cluster is not found'); return; end

figure_wait_(1);
% if deleted add a clu at the end and zoom at it
% change clusters
iClu_new = double(max(S_clu.viClu) + 1);
S_clu.viClu(S_clu.viClu == iClu_del) = iClu_new;
S_clu.nClu = iClu_new;
S_clu = S_clu_update_(S_clu, iClu_new, P);
S_clu.csNote_clu{end+1} = '';
[S_clu, iClu_new] = clu_reorder_(S_clu);

% update all the other views
% delete_multi_(S0.vhPlot, S0.vhText);
% S0.S_clu = S_clu; set(0, 'UserData', S0);
[S_clu, S0] = S_clu_commit_(S_clu);
plot_FigWav_(S0); %redraw plot
plot_FigWavCor_(S0);
% S0 = set0_(mrWavCor);
set(0, 'UserData', S0);

% append to the end for now
button_CluWav_simulate_(iClu_new);
keyPressFcn_cell_(get_fig_cache_('FigWav'), 'z');
fprintf('%s [W] Restored Clu %d\n', datestr(now, 'HH:MM:SS'), iClu_new);
figure_wait_(0);
end


%--------------------------------------------------------------------------
function [vrY, vrX] = tr2plot_(trWav, iClu, viSite_show, maxAmp, P)
if nargin<2, iClu=1; end
iClu = double(iClu);
if nargin<5, P = get0_('P'); end %S0 = get(0, 'UserData'); P = S0.P;
% [~, S_fig] = get_fig_cache_('FigWav');
% if isfield(S_fig, 'maxAmp')
%     maxAmp = S_fig.maxAmp;    
% else
%     maxAmp = P.maxAmp;
% end

if nargin<3, viSite_show = []; end
% P = funcDefStr_(P, 'LineStyle', 'k', 'spkLim', [-10 24], 'maxAmp', 500, 'viSite_show', []);
% P.LineStyle
% if isempty(P.LineStyle), P.LineStyle='k'; end
if isempty(viSite_show), viSite_show = 1:size(trWav,2); end

[nSamples, nChans, nSpk] = size(trWav);
nSites_show = numel(viSite_show);
trWav = single(trWav) / maxAmp;
trWav = trWav + repmat(single(viSite_show(:)'), [size(trWav,1),1,size(trWav,3)]);
trWav([1,end],:,:) = nan;
vrY = trWav(:);

if nargout>=2
    vrX = wav_clu_x_(iClu, P); 
    vrX = repmat(vrX(:), [1, nSites_show * nSpk]);
    vrX = single(vrX(:));
end
end


%--------------------------------------------------------------------------
% 8/7/17 JJJ: tested and documented, file creation date
function [csFile_merge, vcDir] = dir_file_(vcFile_dir, fSortByDate)
% function [csFile_merge, vcDir, csFile_merge1] = dir_file_(vcFile_dir, fSortByDate)
% search for files and sort by date

if nargin<2, fSortByDate=1; end

[vcDir, ~, ~] = fileparts(vcFile_dir);
if isempty(vcDir), vcDir = '.'; end
csFile_merge = dir_(vcFile_dir);

% vsDir = dir(vcFile_dir);
% vrDatenum = cell2mat_({vsDir.datenum});
% csFile_merge = {vsDir.name};
switch fSortByDate
    case 0
        ; %no change
    case 1
        vrDatenum = file_created_meta_(csFile_merge, 'creationTime');
        [~,ix] = sort(vrDatenum, 'ascend');
        csFile_merge = csFile_merge(ix);        
    case 2
        vrDatenum = file_created_(csFile_merge, 'creationTime');
        [~,ix] = sort(vrDatenum, 'ascend');
        csFile_merge = csFile_merge(ix);
    case 3
        vrDatenum = file_created_(csFile_merge, 'lastModifiedTime');
        [~,ix] = sort(vrDatenum, 'ascend');
        csFile_merge = csFile_merge(ix);
    case 4
        [csFile_merge, ix] = sort_nat_(csFile_merge, 'ascend');        
    otherwise
        fprintf(2, 'dir_file_: Invalid option: %d\n', fSortByDate);
end
% csFile_merge1 = csFile_merge; 
% csFile_merge = cellfun(@(vc)[vcDir, filesep(), vc], csFile_merge, 'UniformOutput', 0);
end %func


%--------------------------------------------------------------------------
function S0 = ui_merge_(S0)
if nargin<1, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
P = S0.P;

if isempty(S0.iCluPaste)
    msgbox_('Right-click a cluster to merge.', 1); return;
end
if S0.iCluCopy == S0.iCluPaste
    msgbox_('Cannot merge to itself.', 1); return;
end

figure_wait_(1);
S0.S_clu = merge_clu_(S0.S_clu, S0.iCluCopy, S0.iCluPaste, P);
set(0, 'UserData', S0);
plot_FigWav_(S0); %redraw plot
S0.iCluCopy = min(S0.iCluCopy, S0.iCluPaste);
S0.iCluPaste = [];
set(0, 'UserData', S0);
update_plot_(S0.hPaste, nan, nan);
S0 = update_FigCor_(S0);        
S0 = button_CluWav_simulate_(S0.iCluCopy, [], S0);
S0 = save_log_(sprintf('merge %d %d', S0.iCluCopy, S0.iCluPaste), S0);
set(0, 'UserData', S0);

% msgbox_close(hMsg);
figure_wait_(0);
% S_clu = S0.S_clu;
end %func


%--------------------------------------------------------------------------
function S_clu = merge_clu_(S_clu, iClu1, iClu2, P)
if iClu1>iClu2, [iClu1, iClu2] = swap_(iClu1, iClu2); end

S_clu = merge_clu_pair_(S_clu, iClu1, iClu2);
S_clu = S_clu_refrac_(S_clu, P, iClu1); % remove refrac
S_clu = S_clu_update_(S_clu, iClu1, P);
S_clu = delete_clu_(S_clu, iClu2);
% S_clu = S_clu_remove_empty_(S_clu);
assert_(S_clu_valid_(S_clu), 'Cluster number is inconsistent after merging');
fprintf('%s [W] merging Clu %d and %d\n', datestr(now, 'HH:MM:SS'), iClu1, iClu2);
end %func


%--------------------------------------------------------------------------
function S0 = update_FigCor_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
P = S0.P; S_clu = S0.S_clu;
[hFig, S_fig] = get_fig_cache_('FigWavCor');

% figure(hFig);   
% hMsg = msgbox_open('Computing Correlation');

xylim = get(gca, {'XLim', 'YLim'});
S0.S_clu = S_clu;
plot_FigWavCor_(S0);
set(gca, {'XLim', 'YLim'}, xylim);

set(S_fig.hCursorV, 'XData', S0.iCluCopy*[1 1]);
set(S_fig.hCursorH, 'YData', S0.iCluCopy*[1 1]);

if nargout==0
    set(0, 'UserData', S0); %update field
end
end %func


%--------------------------------------------------------------------------
function vlSuccess = download_files_(csLink, csDest)
% download file from the web
if nargin<2, csDest = link2file_(csLink); end
vlSuccess = false(size(csLink));
for iFile=1:numel(csLink)    
    try
        % download from list of files    
        fprintf('\tDownloading %s: ', csLink{iFile});
        vcFile_out1 = websave(csDest{iFile}, csLink{iFile});
        fprintf('saved to %s\n', vcFile_out1);
        vlSuccess(iFile) = 1;
    catch
        fprintf(2, '\n\tCannot download. Check internet connection.\n');
    end
end %for
end %func


%--------------------------------------------------------------------------
function auto_split_(fMulti, S0)
% Auto-split feature that calls Hidehiko Inagaki's code
% 20160426
if nargin<1, fMulti = 0; end
if nargin<2, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
[P, S_clu] = deal(S0.P, S0.S_clu);

if ~isempty(S0.iCluPaste), msgbox_('Select one cluster', 1); return; end
if S_clu.vnSpk_clu(S0.iCluCopy)<3
    msgbox_('At least three spikes required for splitting', 1); return; 
end
    
hMsg = msgbox_('Splitting... (this closes automatically)');
iClu1 = S0.iCluCopy;
iSite1 = S_clu.viSite_clu(iClu1);
if fMulti
    viSites1 = P.miSites(1:end-P.nSites_ref, iSite1);
else
    viSites1 = iSite1;
end
% mrSpkWav1 = tnWav2uV_(tnWav_sites_(tnWav_spk, S_clu.cviSpk_clu{iClu1}, viSites1));
mrSpkWav1 = tnWav2uV_(tnWav_spk_sites_(S_clu.cviSpk_clu{iClu1}, viSites1, S0), P, 0);
% mrSpkWav1 = tnWav2uV_(tnWav_spk_sites_(find(S_clu.viClu==iClu1), viSites1, S0), P);
mrSpkWav1 = reshape(mrSpkWav1, [], size(mrSpkWav1,3));
[vlSpkIn, mrFet_split, vhAx, hFigTemp] = auto_split_wav_(mrSpkWav1, [], 2);
hPoly = [];
try 
    drawnow; 
    close(hMsg); 
catch
    ;
end
while 1
    vcAns = questdlg_('Split?', 'confirmation', 'Yes', 'No', 'Manual', 'Yes');
    switch lower(vcAns)
        case 'yes'
            close(hFigTemp);
            break;
        case {'no', ''}
            close(hFigTemp); return;
        case 'manual'
            vcAns = questdlg_('Select projection', '', 'PC1 vs PC2', 'PC3 vs PC2', 'PC1 vs PC3', 'PC1 vs PC2');
            switch vcAns
                case 'PC1 vs PC2', [hAx_, iAx1, iAx2] = deal(vhAx(1), 1, 2);
                case 'PC3 vs PC2', [hAx_, iAx1, iAx2] = deal(vhAx(2), 3, 2);
                case 'PC1 vs PC3', [hAx_, iAx1, iAx2] = deal(vhAx(3), 1, 3);
                otherwise
                    close(hFigTemp); return; 
            end            
%             msgbox_(sprintf('Draw a polygon in PC%d vs PC%d', iAx1, iAx2), 1);
            axes(hAx_); 
            cla(hAx_);
            [vrX1, vrY1] = deal(mrFet_split(:,iAx1), mrFet_split(:,iAx2));
            plot(hAx_, vrX1, vrY1, 'k.');
            close_(hPoly);
            hPoly = impoly_();
            mrPolyPos = getPosition(hPoly);              
            vlSpkIn = inpolygon(vrX1, vrY1, mrPolyPos(:,1), mrPolyPos(:,2));
            plot(hAx_, vrX1(vlSpkIn), vrY1(vlSpkIn), 'b.', vrX1(~vlSpkIn), vrY1(~vlSpkIn), 'r.');
    end %switch
end
split_clu_(iClu1, vlSpkIn);
end %func


%--------------------------------------------------------------------------
function edit_prm_(hObject, event)
% Edit prm file

P = get0_('P');
edit_(P.vcFile_prm);
end %func


%--------------------------------------------------------------------------
function vcFile_csv = export_csv_(varargin)
% export_csv_(hObject, event)
% if nargin<2, 
fZeroIndex = 0; %zero-based index export (disable to export as matlab index starting from 1)
vcFile_csv = '';

% S0 = get(0, 'UserData');
if nargin==2
    [S0, P, S_clu] = get0_();
elseif nargin==1
    P = varargin{1};
    vcFile_prm = P.vcFile_prm;
    S0 = load_cached_(P, 0);
    if isempty(S0), fprintf(2, 'Cannot find _jrc.mat.\n'); return; end %exit if file doesn't exist
    P = S0.P;
end

% vcFile_clu = subsFileExt(P.vcFile_prm, '_clu.mat');
% Sclu = load(vcFile_clu); %load Sclu    
% if isfield(Sclu, 'Sclu'), Sclu = Sclu.Sclu; end

if isfield(S0, 'S_clu')
    viClu = double(S0.S_clu.viClu);
else
    fprintf(2, 'Cannot find S_clu.\n');
end
vrTime = double(S0.viTime_spk) / P.sRateHz;
viSite = double(S0.viSite_spk) - fZeroIndex; %zero base

vcFile_csv = subsFileExt_(P.vcFile_prm, '.csv');
dlmwrite(vcFile_csv, [vrTime(:), viClu(:), viSite(:)], 'precision', 9);
fprintf('Wrote to %s. Columns:\n', vcFile_csv);
fprintf('\tColumn 1: Spike time (s)\n');
fprintf('\tColumn 2: Unit# (positive #: valid units, 0: noise cluster, negative #: deleted clusters)\n');
fprintf('\tColumn 3: Site# (starts with 1)\n');
end %func


%--------------------------------------------------------------------------
function export_csv_msort_(varargin)
% export_csv_(hObject, event)
% if nargin<2, 
fZeroIndex = 0; %zero-based index export (disable to export as matlab index starting from 1)

% S0 = get(0, 'UserData');
if nargin==2
    [S0, P, S_clu] = get0_();
elseif nargin==1
    P = varargin{1};
    vcFile_prm = P.vcFile_prm;
    S0 = load_cached_(P, 0);
    if isempty(S0), fprintf(2, 'Cannot find _jrc.mat.\n'); return; end %exit if file doesn't exist
    P = S0.P;
end

% vcFile_clu = subsFileExt(P.vcFile_prm, '_clu.mat');
% Sclu = load(vcFile_clu); %load Sclu    
% if isfield(Sclu, 'Sclu'), Sclu = Sclu.Sclu; end

if isfield(S0, 'S_clu')
    viClu = double(S0.S_clu.viClu);
else
    fprintf(2, 'Cannot find S_clu.\n');
end
vrTime = double(S0.viTime_spk);
viSite = double(S0.viSite_spk) - fZeroIndex; %zero base

vcFile_csv = subsFileExt_(P.vcFile_prm, '_msort.csv');
dlmwrite(vcFile_csv, [vrTime(:), viClu(:)], 'precision', 9);
fprintf('wrote to %s\n', vcFile_csv);
fprintf('\ttime\tclu# (starts with 1)\n');
end %func


%--------------------------------------------------------------------------
function hMsgbox = msgbox_(csMsg, fBlock, fModal)
% msgbox. Don't display if fDebug_ui is set
hMsgbox = []; 
if nargin<2, fBlock = 0; end
if nargin<3, fModal = 0; end
global fDebug_ui
if fDebug_ui==1, return; end
if fBlock    
    uiwait(msgbox(csMsg, 'modal'));
else
    try
        hMsgbox = msgbox(csMsg, ifeq_(fModal, 'modal', 'non-modal'));
    catch
        ;
    end
end
end %func


%--------------------------------------------------------------------------
function unit_annotate_(hObject, event, vcLabel)
S0 = get(0, 'UserData');
S_clu = S0.S_clu;
iClu1 = S0.iCluCopy;
if ~isfield(S_clu, 'csNote_clu'), S_clu.csNote_clu = cell(S_clu.nClu, 1); end
if nargin==3
    if isempty(vcLabel), vcLabel='';
    elseif vcLabel(1) == '='
        if ~isempty(S0.iCluPaste)
            vcLabel = sprintf('=%d', S0.iCluPaste);
        else
            msgbox_('Right-click another unit to set equal to.');
            return;
            vcLabel = '';
        end
    end
    S0.S_clu.csNote_clu{iClu1} = vcLabel;    
else
    vcNote1 = S_clu.csNote_clu{iClu1};
    if isempty(vcNote1), vcNote1=''; end
    csAns = inputdlg_(sprintf('Clu%d', iClu1), 'Annotation', 1, {vcNote1});
    if isempty(csAns), return; end
    vcLabel = csAns{1};
    S0.S_clu.csNote_clu{iClu1} = vcLabel;
end

% set(0, 'UserData', S0);
clu_info_(S0); %update label
save_log_(sprintf('annotate %d %s', iClu1, vcLabel), S0);
% update cluster
end %func


%--------------------------------------------------------------------------
function reload_prm_(hObject, event)
% Edit prm file
% 2016 07 06
[S0, P] = get0_();
S0.P = loadParam_(P.vcFile_prm);
set(0, 'UserData', S0);
end %func


%--------------------------------------------------------------------------
function reset_position_(hObject, event)
% bottom to top left to right
S0 = get(0, 'UserData');
% P = S0.P;
for iFig=1:numel(S0.csFig)
    hFig1 = get_fig_cache_(S0.csFig{iFig});
    if ishandle(hFig1)
        set(hFig1, 'OuterPosition', S0.cvrFigPos0{iFig});
        figure(hFig1); %bring it to foreground
    end
end
end %func


%--------------------------------------------------------------------------
% function about_()
% 7/24/17 JJJ: Updated requirements and contact info
function csAbout = about_(varargin)
[vcVer, vcDate] = version_();
csAbout = { ...            
    ''; 
    sprintf('IronClust %s (irc.m)', vcVer);
    sprintf('  Last updated on %s', vcDate);
    '  Created by James Jun (jamesjun@gmail.com)';
    '';
    'Hardware Requirements';
    '  32GB ram (or 1/4 of recording size)';
    '  NVIDIA GPU (Compute Capability 3.5+: Kepler, Maxwell or Pascal)';    
    '';
    'Software Requirements';
    '  Matlab (R2014b or higher) with Toolboxes below';
    '    Parallel Processing, Image processing, Signal Processing, Statistics and Machine Learning';
    '  CUDA version supported by Matlab prallel processing toolbox (link below)';
    '    CUDA 8.0 (R2017a,b) link: https://developer.nvidia.com/cuda-downloads';
    '    CUDA 7.5 (R2016a,b) link: https://developer.nvidia.com/cuda-75-downloads-archive';
    '    CUDA 7.0 (R2015b) link: https://developer.nvidia.com/cuda-toolkit-70';
    '    CUDA 6.5 (R2015a) link: https://developer.nvidia.com/cuda-toolkit-65';
    '    CUDA 6.0 (R2014b) link: https://developer.nvidia.com/cuda-toolkit-60';
    '  Latest NVidia GPU driver (link below)';
    '    http://www.nvidia.com/Download/index.aspx';
    '  Visual Studio 2013 Express (link below)';
    '    https://www.dropbox.com/s/jrpmto1mwdp4uga/en_visual_studio_express_2013_for_windows_desktop_with_update_5_x86_web_installer_6815514.exe?dl=1'
}; 
if nargout==0, disp_cs_(csAbout); end
end


%--------------------------------------------------------------------------
function keyPressFcn_FigWavCor_(hObject, event)
S0 = get(0, 'UserData');
switch lower(event.Key)
    case 'm' %merge
        ui_merge_(S0);
    case 's' %split
        auto_split_(1); %multi
    case {'d', 'backspace', 'delete'} %delete
        ui_delete_(S0);        
end %switch
end %func


%--------------------------------------------------------------------------
function help_FigWav_(hObject, event)
[~, S_fig] = get_fig_cache_('FigWav');
msgbox_(S_fig.csHelp, 1);
end %func


%--------------------------------------------------------------------------
function csFile = link2file_(csLink)
csFile = cell(size(csLink));
for i=1:numel(csLink)        
    vcFile1 = csLink{i};
    iBegin = find(vcFile1=='/', 1, 'last'); % strip ?    
    if ~isempty(iBegin), vcFile1 = vcFile1(iBegin+1:end); end

    iEnd = find(vcFile1=='?', 1, 'last'); % strip ?
    if ~isempty(iEnd), vcFile1 = vcFile1(1:iEnd-1); end
    csFile{i} = vcFile1;
end
end %func


%--------------------------------------------------------------------------
function S = select_polygon_(hPlot)
S = get(hPlot, 'UserData');
% try delete(S.hPlot_split); catch; end
update_plot2_proj_();
% try delete(S.hPoly); catch; end

S.hPoly = impoly_(); %get a polygon drawing from user
if isempty(S.hPoly), S=[]; return; end;
mrPolyPos = getPosition(S.hPoly);

vrXp = get(hPlot, 'XData');
vrYp = get(hPlot, 'YData');
vlKeep1 = inpolygon(vrXp, vrYp, mrPolyPos(:,1), mrPolyPos(:,2));
% viKeep1 = find(inpoly([vrXp(:), vrYp(:)], mrPolyPos));

[viEvtPlot,~,~] = ind2sub(S.tr_dim, S.viPlot); 
viEvtKeep1 = unique(viEvtPlot(vlKeep1));
viEvtKeep = find(ismember(viEvtPlot, viEvtKeep1));

update_plot2_proj_(vrXp(viEvtKeep), vrYp(viEvtKeep));
% S.hPlot_split = line(vrXp(viEvtKeep), vrYp(viEvtKeep), 'Color', [1 0 0], 'Marker', 'o', 'MarkerSize', 1, 'LineStyle', 'none'); 
% nSites = S.tr_dim(2);
% axis([0 nSites 0 nSites]); %reset view

set(hPlot, 'UserData', S);
hold off;
end %fund


%--------------------------------------------------------------------------
function [S_clu, iClu2] = clu_reorder_(S_clu, iClu1, iClu2)
% Move iClu2 next to iClu1
% from end to location. iClu1: place next to iClu1
% reorder clu location
% cluster is already appended
if nargin<2,  iClu2 = S_clu.nClu; end

if nargin < 2
    iClu1 = find(S_clu.viSite_clu < S_clu.viSite_clu(end), 1, 'last');
    if isempty(iClu1), return; end
end
iClu2 = iClu1+1; %move one right to iClu1
if iClu2 == S_clu.nClu, return; end %if no change in position return

vlAdd = S_clu.viClu>iClu1 & S_clu.viClu < S_clu.nClu;
S_clu.viClu(S_clu.viClu == S_clu.nClu) = iClu2;
S_clu.viClu(vlAdd) = S_clu.viClu(vlAdd) + 1;

viMap_clu = 1:S_clu.nClu;
viMap_clu(iClu2) = S_clu.nClu;
viMap_clu(iClu1+2:end) = (iClu1+1):(S_clu.nClu-1);

S_clu = S_clu_select_(S_clu, viMap_clu);
end %func


%--------------------------------------------------------------------------
function export_mrWav_clu_(h,e)
% Export selected cluster waveforms (iCopy, iPaste) set in the GUI

S0 = get(0, 'UserData');
P = S0.P;
S_clu = S0.S_clu;
viSite1 = P.miSites(:,S_clu.viSite_clu(S0.iCluCopy));
mrWav_clu1 = S_clu.tmrWav_clu(:,viSite1,S0.iCluCopy);
eval(sprintf('mrWav_clu%d = mrWav_clu1;', S0.iCluCopy));
eval(sprintf('assignWorkspace_(mrWav_clu%d);', S0.iCluCopy));
if ~isempty(S0.iCluPaste);
    mrWav_clu2 = S_clu.tmrWav_clu(:,viSite1,S0.iCluPaste);
    eval(sprintf('mrWav_clu%d = mrWav_clu2;', S0.iCluPaste));
    eval(sprintf('assignWorkspace_(mrWav_clu%d);', S0.iCluPaste));
end
end %func


%--------------------------------------------------------------------------
function export_tmrWav_clu_(hObject, event)
% exports spike waveforms by clusters
[S_clu, P] = get0_('S_clu', 'P');
tmrWav_clu = S_clu.tmrWav_clu;
assignWorkspace_(tmrWav_clu);
end %func


%--------------------------------------------------------------------------
function export_tnWav_spk_(h,e)
% Export all spike waveforms from selected cluster

S0 = get(0, 'UserData');
P = S0.P;
tnWav_spk = get_spkwav_(P, 0);
tnWav_raw = get_spkwav_(P, 1);
S_clu = S0.S_clu;
iClu1 = S0.iCluCopy;
viSpk1 = S_clu.cviSpk_clu{iClu1};
nSpk1 = numel(viSpk1);
nSites = numel(P.viSite2Chan);
dimm_spk1 = size(tnWav_spk);    dimm_spk1(2) = nSites;  
dimm_raw1 = size(tnWav_raw);    dimm_raw1(2) = nSites;
tnWav_spk1 = zeros(dimm_spk1, 'like', tnWav_spk);
tnWav_raw1 = zeros(dimm_raw1, 'like', tnWav_raw);
miSites_spk1 = P.miSites(:, S0.viSite_spk);
for iSpk = 1:nSpk1
    tnWav_spk1(:, miSites_spk1(:,iSpk), iSpk) = tnWav_spk(:,:,iSpk);
    tnWav_raw1(:, miSites_spk1(:,iSpk), iSpk) = tnWav_raw(:,:,iSpk);
end
eval(sprintf('tnWav_spk_clu%d = tnWav_spk1;', iClu1));
eval(sprintf('assignWorkspace_(tnWav_spk_clu%d);', iClu1));
eval(sprintf('tnWav_raw_clu%d = tnWav_raw1;', iClu1));
eval(sprintf('assignWorkspace_(tnWav_raw_clu%d);', iClu1));
end %func


%--------------------------------------------------------------------------
function save_figures_(vcExt)
% bottom to top left to right
global fDebug_ui
try
    vcPrefix = sprintf('irc_%s_', datestr(now, 'yymmdd-HHMM'));
    csAns = inputdlg_('Figure name prefix', 'Save figure set', 1, {vcPrefix});
    if isempty(csAns), return; end
    vcPrefix = csAns{1};

    csFig = get0_('csFig');
    fprintf('Saving figures...\n'); t1=tic;
    for iFig=1:numel(csFig)
    %     hFig1 = P.vhFig(iField);
        hFig1 = get_fig_cache_(csFig{iFig});
        if ~ishandle(hFig1), continue; end
        vcFile1 = [vcPrefix, get(hFig1, 'Tag'), vcExt];
        if fDebug_ui==1, continue; end
    %     if get_set_([], 'fDebug_ui', 0), continue; end %skip saving for debugging
        switch lower(vcExt)
            case '.fig'
                savefig(hFig1, vcFile1, 'compact');
            otherwise
                saveas(hFig1, vcFile1, vcExt(2:end));
        end
        fprintf('\t%s\n', vcFile1);
    end
    fprintf('\ttook %0.1fs\n', toc(t1));
catch
    fprintf(2, 'Saving figure failed: %s\n', vcExt);
end
end %func


%--------------------------------------------------------------------------
% deprecated
function plot_SpikePos_(S0, event)


fPlotX = 0; fPlotAllSites = 0; skip_bg = 4;
if key_modifier_(event, 'shift'), fPlotX = 1; end
if key_modifier_(event, 'alt'), fPlotAllSites = 1; end
if isempty(S0), S0 = get(0, 'UserData'); end
P = S0.P;
S_clu = S0.S_clu;
[hFig, S_fig] = get_fig_cache_('FigTime');
nSites = numel(P.viSite2Chan);
if nargin<2, fPlotX = 0; end %plot x if set

if fPlotAllSites
    viSites = 1:nSites;
else
    iSite_clu = S_clu.viSite_clu(S0.iCluCopy); %only plot spikes from site     
    viSites =  P.miSites(:, iSite_clu)';
end

% determine spike positinos
[vrX0, vrY0, vrA0, viClu0, vrT0] = get_spike_clu_(S_clu, viSites); %background
[vrX2, vrY2, vrA2, viClu2, vrT2] = deal([]);
if ~fPlotAllSites
    [vrX1, vrY1, vrA1, viClu1, vrT1] = multiindex_(find(viClu0==S0.iCluCopy), ...
        vrX0, vrY0, vrA0, viClu0, vrT0);
    if ~isempty(S0.iCluPaste)
        [vrX2, vrY2, vrA2, viClu2, vrT2] = multiindex_(find(viClu0==S0.iCluPaste), ...
            vrX0, vrY0, vrA0, viClu0, vrT0);
    end
else
    % display chain
    viClu_Chain(1) = S0.iCluCopy;
    iClu_next = get_next_clu_(S_clu, S0.iCluCopy);  
    while ~isempty(iClu_next)        
        viClu_Chain(end+1) = iClu_next;
        iClu_next = get_next_clu_(S_clu, iClu_next);        
    end
    [vrX1, vrY1, vrA1, viClu1, vrT1] = multiindex_(find(ismember(viClu0, viClu_Chain)), ...
        vrX0, vrY0, vrA0, viClu0, vrT0);
end

% if fPlot_ampDist, plot_ampDist_(cmrVpp_site, P); end

if skip_bg>1 % subsample background
    [vrA0, vrX0, vrY0, vrT0, viClu0] = multiindex_(1:skip_bg:numel(vrA0), ...
        vrA0, vrX0, vrY0, vrT0, viClu0);
end

S_fig.xylim = [get(S_fig.hAx, 'XLim'), get(S_fig.hAx, 'YLim')]; %store limits
S_fig.xylim_track = S_fig.xylim;

%------------
% Draw
if ~isfield(S_fig, 'vhAx_track')
    S_fig.vhAx_track = axes('Parent', hFig, 'Position', [.05 .2 .9 .7], 'XLimMode', 'manual', 'YLimMode', 'manual');
    hold(S_fig.vhAx_track, 'on');     
    xlabel(S_fig.vhAx_track, 'Time (s)');     
    S_fig.hPlot0_track = scatter(nan, nan, 5, nan, 'filled'); %place holder
    S_fig.hPlot1_track = line(nan, nan, 'Color', [0 0 1], 'Marker', 'o', 'MarkerSize', 5, 'LineStyle', 'none');
    S_fig.hPlot2_track = line(nan, nan, 'Color', [1 0 0], 'Marker', 'o', 'MarkerSize', 5, 'LineStyle', 'none');
else
    toggleVisible_({S_fig.vhAx_track, S_fig.hPlot0_track, S_fig.hPlot1_track, S_fig.hPlot2_track}, 1);
    set(S_fig.vhAx_track, 'Visible', 'on');    
end
% axes(S_fig.vhAx_track);
mouse_figure(hFig, S_fig.vhAx_track);
toggleVisible_({S_fig.hAx, S_fig.hRect, S_fig.hPlot0, S_fig.hPlot1, S_fig.hPlot2}, 0);
if ~isfield(S_fig, 'fPlot0'), S_fig.fPlot0 = 1; end
toggleVisible_(S_fig.hPlot0_track, S_fig.fPlot0);
if fPlotX
    set(S_fig.hPlot0_track, 'XData', vrT0, 'YData', vrX0, 'CData', log10(vrA0));
    update_plot_(S_fig.hPlot1_track, vrT1, vrX1);
    update_plot_(S_fig.hPlot2_track, vrT2, vrX2);
    ylabel(S_fig.vhAx_track, 'X Pos [pix]');
    S_fig.xylim_track(3:4) = [0 1.5];
else
    set(S_fig.hPlot0_track, 'XData', vrT0, 'YData', vrY0, 'CData', log10(vrA0));
    update_plot_(S_fig.hPlot1_track, vrT1, vrY1);
    update_plot_(S_fig.hPlot2_track, vrT2, vrY2);
    ylabel(S_fig.vhAx_track, 'Y Pos [pix]');
    S_fig.xylim_track(3:4) = round(median(vrY1)) + [-1,1] * floor(P.maxSite);
end
axis_(S_fig.vhAx_track, S_fig.xylim_track);
colormap(S_fig.vhAx_track, flipud(colormap('gray')));
set(S_fig.vhAx_track, 'CLim', [.5 3.5]);
grid(S_fig.vhAx_track, 'on');

% Set title
if isempty(S0.iCluPaste)
    vcTitle = sprintf('Color: log10 Vpp [uV]; Clu%d(black); Press [T] to return; [B]ackground', S0.iCluCopy);
else
    vcTitle = sprintf('Color: log10 Vpp [uV]; Clu%d(black); Clu%d(red); Press [T] to return; [B]ackground', S0.iCluCopy, S0.iCluPaste);
end
title(S_fig.vhAx_track, vcTitle);
set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function [vrX_spk, vrY_spk, vrA_spk, viClu_spk, vrT_spk] = get_spike_clu_(S_clu, viSites, viClu_plot)

if nargin<3, viClu_plot=[]; end
S0 = get(0, 'UserData');
P = S0.P;

nSpikes = numel(S0.viTime_spk);
[vrX_spk, vrY_spk, vrA_spk, viClu_spk, vrT_spk] = deal(nan(nSpikes, 1, 'single'));
for iSite = viSites
    viSite1 = P.miSites(:, iSite);
    viSpk1 = find(S0.viSite_spk == iSite);
    viClu1 = S_clu.viClu(viSpk1);
    if ~isempty(viClu_plot)        
        vl1_clu = ismember(viClu1, viClu_plot);
        viSpk1 = viSpk1(vl1_clu);
        viClu1 = viClu1(vl1_clu);
    end
    if isempty(viSpk1), continue; end
    viTime1 = S0.viTime_spk(viSpk1);    
%     [vrX_spk(viSpk1), vrY_spk(viSpk1), vrA_spk(viSpk1)] = ...
%         spikePos_(viSpk1, viSite1, P);
    viClu_spk(viSpk1) = viClu1;
    vrT_spk(viSpk1) = viTime1;
end %for

% select
vl_spk = ~isnan(vrY_spk);
vrA_spk = (vrA_spk(vl_spk));
vrY_spk = vrY_spk(vl_spk) / P.um_per_pix;
vrX_spk = vrX_spk(vl_spk) / P.um_per_pix;
vrT_spk = single(vrT_spk(vl_spk)) / P.sRateHz;
viClu_spk = viClu_spk(vl_spk);

% sort by amplitude
[vrA_spk, vrX_spk, vrY_spk, vrT_spk, viClu_spk] = ...
    sort_ascend_(vrA_spk, vrX_spk, vrY_spk, vrT_spk, viClu_spk);
end %func


%--------------------------------------------------------------------------
% function [vrX1_spk, vrY1_spk, vrVpp_spk, mrVpp1, trWav1] = spikePos_(viSpk1, viSite1, P)
% % Get spike position from a spike index viSpk1
% % Determine Vpp
% % viTime1 = randomSelect(viTime1, P.nShow_proj); %select fewer
% % [trWav1, mrVpp1] = mr2tr_spk_(mrWav, viTime1, viSite1, P);
% 
% fCentroid = 0;
% 
% if fCentroid
%     P.fInterp_mean = 0;
% %     [mrWav_mean1, imax_site1, trWav_int1] = interp_align_mean_(trWav1, P);
%     mrXY_spk = centroid_pca_(trWav1, P.mrSiteXY(viSite1, :));
% end
% vrX1_site = P.mrSiteXY(viSite1, 1);
% vrY1_site = P.mrSiteXY(viSite1, 2);    
% mrVpp1_sq = mrVpp1.^2;
% vrVpp1_sq_sum = sum(mrVpp1_sq);
% if ~fCentroid
%     vrX1_spk = sum(bsxfun(@times, mrVpp1_sq, vrX1_site)) ./ vrVpp1_sq_sum;
%     vrY1_spk = sum(bsxfun(@times, mrVpp1_sq, vrY1_site)) ./ vrVpp1_sq_sum;
% else
%     vrX1_spk = mrXY_spk(:,1);
%     vrY1_spk = mrXY_spk(:,1);
% end
% vrVpp_spk = sqrt(vrVpp1_sq_sum);
% end %func


%--------------------------------------------------------------------------
function update_FigTime_()
% display features in a new site

[hFig, S_fig] = get_fig_cache_('FigTime');
S0 = get(0, 'UserData');
P = S0.P;
if ~isVisible_(S_fig.hAx), return ;end
% P.vcFet_show = S_fig.csFet{S_fig.iFet};
set0_(P);
[vrFet0, vrTime0, vcYlabel] = getFet_site_(S_fig.iSite, [], S0);
if ~isfield(S_fig, 'fPlot0'), S_fig.fPlot0 = 1; end
toggleVisible_(S_fig.hPlot0, S_fig.fPlot0);
update_plot_(S_fig.hPlot0, vrTime0, vrFet0);
set(S_fig.hPlot1, 'YData', getFet_site_(S_fig.iSite, S0.iCluCopy, S0));
% set(S_fig.hPlot0, 'XData', vrTime0, 'YData', vrFet0);
if ~isempty(S0.iCluPaste)
    set(S_fig.hPlot2, 'YData', getFet_site_(S_fig.iSite, S0.iCluPaste, S0));
else
    hide_plot_(S_fig.hPlot2);
%     set(S_fig.hPlot2, 'XData', nan, 'YData', nan);
end
% switch lower(P.vcFet_show)
%     case 'vpp'
ylim_(S_fig.hAx, [0, 1] * S_fig.maxAmp);
imrect_set_(S_fig.hRect, [], [0, 1] * S_fig.maxAmp);    
%     otherwise
%         ylim_(S_fig.hAx, [0, 1] * P.maxAmp);
%         imrect_set_(S_fig.hRect, [], [0, 1] * P.maxAmp);    
% end
grid(S_fig.hAx, 'on');
ylabel(S_fig.hAx, vcYlabel);
end %func


%--------------------------------------------------------------------------
function S_clu = split_clu_(iClu1, vlIn)
% split cluster. 
figure_wait_(1); 
[P, S_clu, viSite_spk] = get0_('P', 'S_clu', 'viSite_spk');
hMsg = msgbox_open_('Splitting...');
figure(get_fig_cache_('FigWav'));

% create a new cluster (add at the end)
n2 = sum(vlIn); %number of clusters to split off
iClu2 = max(S_clu.viClu) + 1;

% update cluster count and index
S_clu.nClu = double(iClu2);
S_clu.vnSpk_clu(iClu1) = S_clu.vnSpk_clu(iClu1) - n2;
S_clu.vnSpk_clu(iClu2) = sum(vlIn);
viSpk1 = find(S_clu.viClu==iClu1);
viSpk2 = viSpk1(vlIn);
viSpk1 = viSpk1(~vlIn);
[iSite1, iSite2] = deal(mode(viSite_spk(viSpk1)), mode(viSite_spk(viSpk2)));
if iSite1 > iSite2 % order by the cluster site location
    [iSite2, iSite1] = deal(iSite1, iSite2);
    [viSpk2, viSpk1] = deal(viSpk1, viSpk2);
    vlIn = ~vlIn;
end
[S_clu.cviSpk_clu{iClu1}, S_clu.cviSpk_clu{iClu2}] = deal(viSpk1, viSpk2);
[S_clu.viSite_clu(iClu1), S_clu.viSite_clu(iClu2)] = deal(iSite1, iSite2);

try % erase annotaiton    
    S_clu.csNote_clu{iClu1} = ''; 
    S_clu.csNote_clu{end+1} = '';  %add another entry
catch
end
S_clu.viClu(viSpk2) = iClu2; %change cluster number
S_clu = S_clu_update_(S_clu, [iClu1, iClu2], P);

% Bring the new cluster right next to the old one using index swap
[S_clu, iClu2] = clu_reorder_(S_clu, iClu1); 

% update all the other views
[S_clu, S0] = S_clu_commit_(S_clu, 'split_clu_');
plot_FigWav_(S0); %redraw plot
plot_FigWavCor_(S0);
save_log_(sprintf('split %d', iClu1), S0); %@TODO: specify which cut to use

% select two clusters being split
button_CluWav_simulate_(iClu1, iClu2);
close_(hMsg);
fprintf('%s [W] splited Clu %d\n', datestr(now, 'HH:MM:SS'), iClu1);
figure_wait_(0);
end %func


%--------------------------------------------------------------------------
function [fSplit, vlIn] = plot_split_(S1)
% find site
mrPolyPos = getPosition(S1.hPoly);
site12_show = floor(mean(mrPolyPos));
site12 = S1.viSites_show(site12_show+1);  

% get amp
S0 = get(0, 'UserData');
S_clu = S0.S_clu;
P = S0.P;
iClu1 = S0.iCluCopy;
if ismember(P.vcFet_show, {'pca', 'ppca', 'gpca'})
    fWav_raw_show = 0;
else
    fWav_raw_show = get_set_(P, 'fWav_raw_show', 0);
end
trWav12 = tnWav2uV_(tnWav_spk_sites_(S_clu.cviSpk_clu{iClu1}, site12, S0, fWav_raw_show), P);
if diff(site12) == 0, trWav12(:,2,:) = trWav12(:,1,:); end
vxPoly = (mrPolyPos([1:end,1],1) - site12_show(1)) * S1.maxAmp;
vyPoly = (mrPolyPos([1:end,1],2) - site12_show(2)) * S1.maxAmp;
switch lower(P.vcFet_show)   
    case {'vpp', 'vmin', 'vmax'}     
        mrAmin12 = abs(squeeze_(min(trWav12)))';
        mrAmax12 = abs(squeeze_(max(trWav12)))';
        vyPlot = mrAmin12(:,2);
        vcYlabel = sprintf('Site %d (min amp)', site12(2));
        if site12(2) > site12(1)
            vxPlot = mrAmin12(:,1);
            vcXlabel = sprintf('Site %d (min amp)', site12(1));
        else
            vxPlot = mrAmax12(:,1);
            vcXlabel = sprintf('Site %d (max amp)', site12(1));
            vxPoly = vxPoly; %max amp are scaled half
        end  
        
    case {'cov', 'spacetime'}   
        [mrAmin12, mrAmax12] = calc_cov_spk_(S_clu.cviSpk_clu{iClu1}, site12);
        [mrAmin12, mrAmax12] = multifun_(@(x)abs(x'), mrAmin12, mrAmax12);
        vyPlot = mrAmin12(:,2);
        vcYlabel = sprintf('Site %d (cov1)', site12(2));
        if site12(2) > site12(1)
            vxPlot = mrAmin12(:,1);
            vcXlabel = sprintf('Site %d (cov1)', site12(1));
        else
            vxPlot = mrAmax12(:,1);
            vcXlabel = sprintf('Site %d (cov2)', site12(1));
        end  
        
    case {'pca', 'ppca', 'gpca'}
        if strcmpi(P.vcFet_show, 'ppca')
            [mrPv1, mrPv2] = pca_pv_clu_(site12, S0.iCluCopy, S0.iCluPaste);
            [mrAmin12, mrAmax12] = pca_pc_spk_(S_clu.cviSpk_clu{iClu1}, site12, mrPv1, mrPv2);
        else
            [mrAmin12, mrAmax12] = pca_pc_spk_(S_clu.cviSpk_clu{iClu1}, site12);
        end
        [mrAmin12, mrAmax12] = multifun_(@(x)x', mrAmin12, mrAmax12);
        vyPlot = mrAmin12(:,2);
        vcYlabel = sprintf('Site %d (PC1)', site12(2));
        if site12(2) > site12(1)
            vxPlot = mrAmin12(:,1);
            vcXlabel = sprintf('Site %d (PC1)', site12(1));
        else
            vxPlot = mrAmax12(:,1);
            vcXlabel = sprintf('Site %d (PC2)', site12(1));
        end 
        
    otherwise 
        error('plot_split: vcFetShow: not implemented');
%         vxPoly = (mrPolyPos([1:end,1],1) - site12_show(1)) * S1.maxAmp;
%         vyPoly = (mrPolyPos([1:end,1],2) - site12_show(2)) * S1.maxAmp;        
%         trFet12 = trFet_([], site12, S_clu.cviSpk_clu{iClu1});
%         vyPlot = squeeze_(trFet12(1, 2, :));
%         vcYlabel = sprintf('Site %d (%s1)', site12(2), P.vcFet);
%         if site12(2) > site12(1)
%             vxPlot = squeeze_(trFet12(1, 1, :));
%             vcXlabel = sprintf('Site %d (%s1)', site12(1), P.vcFet);
%         else
%             vxPlot = squeeze_(trFet12(min(2,P.nPcPerChan), 1, :));
%             vcXlabel = sprintf('Site %d (%s2)', site12(1), P.vcFet);
%         end       
end

vlIn = inpolygon(vxPlot, vyPlot, vxPoly, vyPoly);

% Plot temporary figure (auto-close)
hFig = figure(10221); clf;
resize_figure_(hFig, [0 0 .5 1]);
subplot(2,2,[1,3]); hold on;
line(vxPlot, vyPlot, 'Color', P.mrColor_proj(2,:), 'Marker', 'o', 'MarkerSize', 2, 'LineStyle', 'none');
hPlot = line(vxPlot(vlIn), vyPlot(vlIn), 'Color', P.mrColor_proj(3,:), 'Marker', 'o', 'MarkerSize', 2, 'LineStyle', 'none');
% plot(vxPoly, vyPoly, 'b+-'); %boundary
title(sprintf('Cluster %d (%d spikes)', iClu1, S_clu.vnSpk_clu(iClu1)));
xlabel(sprintf('Site %d', site12(1)));
ylabel(vcYlabel);   xlabel(vcXlabel);
grid on;

% user edit polygon
hPoly = impoly_(gca, [vxPoly(:), vyPoly(:)]);
hFunc = makeConstrainToRectFcn('impoly',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(hPoly, hFunc); 

hMsgbox = msgbox_('Press OK after adjusting polygon', 0);
uiwait(hMsgbox);

vlIn = poly_mask_(hPoly, vxPlot, vyPlot);
set(hPlot, 'XData', vxPlot(vlIn), 'YData',vyPlot(vlIn));
% if P.fWav_raw_show
%     trWav12_raw = tnWav2uV_(tnWav_spk_sites_(S_clu.cviSpk_clu{iClu1}, site12, 1));
%     mrWavX = squeeze_(trWav12_raw(:, 1, :));
%     mrWavY = squeeze_(trWav12_raw(:, 2, :));
% else
    mrWavX = squeeze_(trWav12(:, 1, :));
    mrWavY = squeeze_(trWav12(:, 2, :));
% end        
spkLim = ifeq_(P.fWav_raw_show, P.spkLim_raw, P.spkLim);
vrT = (spkLim(1):spkLim(end)) / P.sRateHz * 1000;
viIn = randomSelect_(find(vlIn), P.nSpk_show);
viOut = randomSelect_(find(~vlIn), P.nSpk_show);

if isempty(viIn) || isempty(viOut)
    fSplit = 0; 
    close_(hFig);
    return;
end

subplot 222; hold on;
plot(vrT, mrWavX(:,viOut), 'k', vrT, mrWavX(:,viIn), 'r');
title(vcXlabel); ylabel('Voltage (\muV)'); xlabel('Time (ms)');
grid on;

subplot 224; hold on;
plot(vrT, mrWavY(:,viOut), 'k', vrT, mrWavY(:,viIn), 'r');
title(vcYlabel); ylabel('Voltage (\muV)'); xlabel('Time (ms)');
grid on;

if strcmpi(questdlg_('Split?', 'Confirmation', 'Yes', 'No', 'Yes'), 'Yes')    
    fSplit = 1;
else
    fSplit = 0;
end
close_(hFig);
end %func


%--------------------------------------------------------------------------
function update_spikes_(varargin)
S0 = get(0, 'UserData');
hMsg = msgbox_open_('Updating spikes');
fig_prev = gcf;
figure_wait_(1);
[~, S_fig] = get_fig_cache_('FigWav');
% plot_tnWav_clu_(S_fig, S0.P); %do this after plotSpk_
plot_spkwav_(S_fig, S0);
close_(hMsg);
figure_wait_(0);
figure(fig_prev);
end %func


%--------------------------------------------------------------------------
function [mrPos_spk, mrVpp_spk] = tnWav_centroid_(tnWav_spk, viSite_spk, P)
% 2 x nSpk matrix containing centroid and amplitude

mrVpp_spk = trWav2fet_(tnWav_spk, P); % apply car
% mrVpp_spk = tr2Vpp(tnWav_spk, P)';

mrVpp_spk1 = mrVpp_spk .^ 2; % compute covariance with the center site
mrVpp_spk1 = bsxfun(@rdivide, mrVpp_spk1, sum(mrVpp_spk1, 1));
miSite_spk = P.miSites(:, viSite_spk);
mrSiteXY = single(P.mrSiteXY);
mrSiteX_spk = reshape(mrSiteXY(miSite_spk(:), 1), size(miSite_spk));
mrSiteY_spk = reshape(mrSiteXY(miSite_spk(:), 2), size(miSite_spk));
mrPos_spk = [sum(mrVpp_spk1 .* mrSiteX_spk, 1); sum(mrVpp_spk1 .* mrSiteY_spk, 1)];   
end %func


%--------------------------------------------------------------------------
function [mrPos_spk, viSpk_re] = position_spk_(viSite_spk, tnWav_spk, P)

mrPos_site1 = P.mrSiteXY(P.miSites(1, viSite_spk), :)'; %first pos

% determine centroid location and second largest amplitude
[mrPos_spk, mrA_spk] = tnWav_centroid_(tnWav_spk, viSite_spk, P);
[~, viiSite2_spk] = max(mrA_spk((2:end), :)); %find second max
miSites2 = P.miSites(2:end, :);
viiSite2_spk = sub2ind(size(miSites2), viiSite2_spk(:), viSite_spk(:));
viSite_spk2 = miSites2(viiSite2_spk);

% Find where second largest site is closer to the spike centroid
mrPos_site2 = P.mrSiteXY(viSite_spk2, :)';
dist__ = @(mr1,mr2)sum((mr1-mr2).^2);
viSpk_re = find(dist__(mrPos_spk,mrPos_site2) < dist__(mrPos_spk, mrPos_site1));
end %func


%--------------------------------------------------------------------------
function viTime1 = recenter_spk_(mrWav, viTime, viSite, P)
spkLim = [-1,1] * abs(P.spkLim(1));
viTime0 = [spkLim(1):spkLim(end)]'; %column
miTime = bsxfun(@plus, int32(viTime0), int32(viTime(:)'));
miTime = min(max(miTime, 1), size(mrWav, 1));
miSite = repmat(viSite(:)', numel(viTime0), 1); 
mrWav_spk = mrWav(sub2ind(size(mrWav), miTime, miSite));
[~, viMin_spk] = min(mrWav_spk,[],1);
viTime_off = int32(gather_(viMin_spk') + spkLim(1) - 1);
viTime1 = viTime + viTime_off;
% disp(mean(viTime_off~=0))
end %func


%--------------------------------------------------------------------------
function hPatch = plot_probe_(mrSiteXY, vrSiteHW, viSite2Chan, vrVpp, hFig)
if nargin<3, viSite2Chan=[]; end
if nargin<4, vrVpp=[]; end
if nargin<5, hFig=[]; end

if isempty(hFig)
    hFig = gcf;
else
    figure(hFig);
end

vrX = [0 0 1 1] * vrSiteHW(2); 
vrY = [0 1 1 0] * vrSiteHW(1);

mrPatchX = bsxfun(@plus, mrSiteXY(:,1)', vrX(:));
mrPatchY = bsxfun(@plus, mrSiteXY(:,2)', vrY(:));
nSites = size(mrSiteXY,1);    
if ~isempty(vrVpp)
    hPatch = patch(mrPatchX, mrPatchY, repmat(vrVpp(:)', [4, 1]), ...
        'EdgeColor', 'k', 'FaceColor', 'flat', 'FaceAlpha', .5); %[0 0 0], 'EdgeColor', 'none', 'FaceColor', 'flat', 'FaceVertexCData', [0 0 0], 'FaceAlpha', 0); 
    caxis([0, max(vrVpp)]);
    colormap jet;
else
    hPatch = patch(mrPatchX, mrPatchY, 'w', 'EdgeColor', 'k'); %[0 0 0], 'EdgeColor', 'none', 'FaceColor', 'flat', 'FaceVertexCData', [0 0 0], 'FaceAlpha', 0); 
end
if ~isempty(viSite2Chan)
    csText = arrayfun(@(i)sprintf('%d/%d', i, viSite2Chan(i)), 1:numel(viSite2Chan), 'UniformOutput', 0);
else
    csText = arrayfun(@(i)sprintf('%d', i), 1:nSites, 'UniformOutput', 0);
end
hText = text(mrSiteXY(:,1), mrSiteXY(:,2), csText, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
axis_([min(mrPatchX(:)), max(mrPatchX(:)), min(mrPatchY(:)), max(mrPatchY(:))]);
title('Site# / Chan# (zoom: wheel; pan: hold wheel & drag)');
% vrPos = get(gcf, 'Position');
xlabel('X Position (\mum)');
ylabel('Y Position (\mum)');
mouse_figure(hFig);
end


%--------------------------------------------------------------------------
function S_clu = postCluster_(S_clu, P)
% fSortClu = 0; %debug
if isfield(S_clu, 'viClu')
    S_clu = rmfield(S_clu, 'viClu');
end
if isempty(S_clu), return; end

if get_set_(P, 'knn', 0) > 0, P.vcDetrend_postclu = 'knn'; end

switch lower(P.vcDetrend_postclu)
%         case {'hidehiko', 'hide'}
%             S_clu.icl = selec_rho_delta_with_slope(S_clu, P.delta1_cut);
    case 'local' % 
        S_clu.icl = detrend_local_(S_clu, P, 1);
    case 'none'
        S_clu.icl = find(S_clu.rho(:) > 10^(P.rho_cut) & S_clu.delta(:) > 10^(P.delta1_cut));
    case 'global'
        S_clu.icl = detrend_local_(S_clu, P, 0);
    case 'logz'
        S_clu.icl = log_ztran_(S_clu.rho, S_clu.delta, P.rho_cut, 4+P.delta1_cut);
    case 'knn'
        S_clu.icl = find(S_clu.delta(:) > 1);
    otherwise
        fprintf(2, 'postCluster_: vcDetrend_postclu = ''%s''; not supported.\n', P.vcDetrend_postclu);
end
% end

% Update P
S_clu.P.min_count = P.min_count;
S_clu.P.delta1_cut = P.delta1_cut;
S_clu.P.rho_cut = P.rho_cut;
S_clu.viClu = [];
S_clu = assign_clu_count_(S_clu, P); % enforce min count algorithm    

% debug output
if nargout==0
    vrXp = log10(S_clu.rho);
    vrYp = log10(S_clu.delta);
    figure; hold on; 
    plot(vrXp, vrYp, 'b.', vrXp(S_clu.icl), vrYp(S_clu.icl), 'ro');
    plot(get(gca, 'XLim'), P.delta1_cut*[1 1], 'r-');
    plot(P.rho_cut*[1 1], get(gca, 'YLim'), 'r-');
    xlabel('log10 rho');
    ylabel('log10 delta');    
end 
end %func


%--------------------------------------------------------------------------
% 8/24/2018 JJJ: Halo detection code. need knn
function S_clu = fix_overlap_(S_clu, P)
% keep knn index of neighbors. noise clusters get second chance with
% collided spikes
fMode = 1;
% # Exit conditions
frac_equal_knn = get_(P, 'frac_equal_knn');
if isempty(frac_equal_knn) || frac_equal_knn==0, return; end
if ~isfield(S_clu, 'miKnn'), S_clu.vlHalo = []; return; end

% # Detect
t1=tic;
miClu_knn = S_clu.viClu(S_clu.miKnn); % first row it itself
mlEq_knn = bsxfun(@eq, miClu_knn, S_clu.viClu(:)');
vrEq_knn = mean(mlEq_knn);
vlHalo = vrEq_knn < frac_equal_knn;
S_clu.vlHalo = vlHalo;
miKnn_halo = S_clu.miKnn(:,vlHalo);
S_clu.viClu(vlHalo) = 0;
miClu_halo = S_clu.viClu(miKnn_halo); % first row it itself
viClu_pre = S_clu.viClu;
switch fMode 
    case 1 % Fix1: copy the median neighbor
        S_clu.viClu(vlHalo) = median(miClu_halo);
    case 2 % Fix2: copy the highest rho value
        [~, viRho_max_halo] = max(S_clu.rho(miKnn_halo));
        S_clu.viClu(vlHalo) = S_clu.viClu(mr2vr_sub2ind_(miKnn_halo, viRho_max_halo));
end
fprintf('fix_overlap_: reassigned %0.1f%% events near the cluster boundaries, took %0.1fs\n', ...
    mean(viClu_pre ~= S_clu.viClu)*100, toc(t1));

% mrRho_knn(mlEq_knn) = 0;
% vrVpp_spk = squeeze(max(tnWav_spk(:,1,:)) - min(tnWav_spk(:,1,:)));

% mrRho_knn = S_clu.rho(S_clu.miKnn);
% mrRho_knn(mlEq_knn) = 0;
% [vrRho_max, viRho_max] = max(mrRho_knn);
% vrRho_ave = vrRho_max(:)/2 + S_clu.rho(:)/2;
% viClu_uniq = setdiff(unique(viClu(:))', 0);
% vrRho_cut_clu = arrayfun(@(x)max(vrRho_ave(viClu==x)), viClu_uniq);
% vlHalo = false(size(viClu));
% for iClu1 = viClu_uniq
%     vi_ = find(viClu == iClu1);
%     vlHalo(vi_) = S_clu.rho(vi_) < vrRho_cut_clu(iClu1);
% end
end %func


%--------------------------------------------------------------------------
function [icl, x, y] = log_ztran_(x, y, x_cut, y_cut)
% [icl, x, y] = detrend_ztran_(x, y, x_cut, y_cut)
% [icl, x, y] = detrend_ztran_(x, y, n_icl)
if nargin == 3
    n_icl = x_cut;
else
    n_icl = [];
end

x = log10(x(:));
y = log10(y(:));

vlValid = isfinite(x) & isfinite(y);
y(vlValid) = zscore_(y(vlValid));

if isempty(n_icl)
    icl = find(x>=x_cut & y>=y_cut);
else
    [~, ix] = sort(y(vlValid), 'descend');   
    viValid = find(vlValid);
    icl = viValid(ix(1:n_icl));
end

if nargout==0
    figure; plot(x,y,'.', x(icl),y(icl),'ro'); grid on; 
end
end %func


%--------------------------------------------------------------------------
function [icl, x, z] = detrend_ztran_(x0, y0, x_cut, y_cut)
% [icl, x, y] = detrend_ztran_(x, y, x_cut, y_cut)
% [icl, x, y] = detrend_ztran_(x, y, n_icl)
if nargin == 3
    n_icl = x_cut;
else
    n_icl = [];
end
y_thresh_mad = 20;
x = log10(x0(:));
y = (y0(:));
vlValid_x = x>=x_cut & x <= -1;
z_max = 100;

% compute y_mad
y_med = median(y(vlValid_x));
y_mad = y - y_med;
y_mad = y_mad / median(y_mad);
vlValid_y = abs(y_mad) < y_thresh_mad;
% vl_y0 = y0<=0;
% y = y0;
% y(vl_y0) = min(y(~vl_y0));
% y = log10(y0(:));
% max_y = max(y);

vlValid = isfinite(x) & isfinite(y);
% viDetrend = find(vlValid  & (y < max_y/4) & (x >= x_cut));
viDetrend = find(vlValid  & vlValid_y & vlValid_x);
x1 = x(viDetrend);
y1 = y(viDetrend);
xx1 = [x1+eps('single'), ones(numel(x1),1)];
m = xx1 \ y1; %determine slope based on acceptable units

xx = [x+eps('single'), ones(numel(x),1)];
y2 = y - xx * m; %detrend data
mu2 = mean(y2(viDetrend));
sd2 = std(y2(viDetrend));
z = (y2 - mu2) / sd2; %z transformation
z(z>z_max) = z_max;

if isempty(n_icl)
    icl = find(x>=x_cut & z>=10^y_cut);
else
    [~, ix] = sort(z(vlValid), 'descend');   
    viValid = find(vlValid);
    icl = viValid(ix(1:n_icl));
end

if nargout==0
    figure; plot(x,z,'.', x(icl),z(icl),'ro'); grid on; 
    title(sprintf('%d clu', numel(icl)));
end
end %func


%--------------------------------------------------------------------------
function [cl, icl] = assignCluster_(cl, ordrho, nneigh, icl)
ND = numel(ordrho);
nClu = numel(icl);

if isempty(cl)
    cl = zeros([ND, 1], 'int32');
    cl(icl) = 1:nClu;
end

if numel(icl) == 0 || numel(icl) == 1
    cl = ones([ND, 1], 'int32');
    icl = ordrho(1);
else
    nneigh1 = nneigh(ordrho);
    for i=1:10
        vi = find(cl(ordrho)<=0);
        if isempty(vi), break; end
        vi=vi(:)';        
        for ii = vi
            cl(ordrho(ii)) = cl(nneigh1(ii));        
        end
        n1 = sum(cl<=0);
        if n1==0, break; end
        fprintf('i:%d, n0=%d, ', i, n1);
    end
    cl(cl<=0) = 1; %background
end
end %func


%--------------------------------------------------------------------------
function viClu = assignCluster_site_(S_clu, S0)
nRepeat = 100;

nSites = numel(S0.cviSpk_site);
viClu = zeros(numel(S_clu.rho), 1, 'int32');
viClu(S_clu.icl) = 1:numel(S_clu.icl);
% for iRepeat = 1:nRepeat
for iSite = 1:nSites
    viSpk_ = S0.cviSpk_site{iSite};     %find(S0.viSite_spk == iSite);    
    if isempty(viSpk_), continue; end
%     viSpk_ = viSpk_(S0.viSite_spk(S_clu.nneigh(viSpk_)) == iSite); % in group spikes only
%     viSpk_ = viSpk_(ismember(S_clu.nneigh(viSpk_), viSpk_));        
    cl_ = viClu(viSpk_);
    ordrho_ = rankorder_(S_clu.rho(viSpk_), 'descend');
    [vl_, nneigh_] = ismember(S_clu.nneigh(viSpk_), viSpk_);
    vi_ = find(vl_);
    vi_ = vi_(:)';
    for iRepeat = 1:nRepeat
        vi_(cl_(ordrho_(vi_))~=0) = [];        
        if isempty(vi_), break; end
        for i_ = vi_
            cl_(ordrho_(i_)) = cl_(nneigh_(i_));
        end
    end
    viClu(viSpk_) = cl_;
end %for
%     fprintf('%d: %f\n', iRepeat, mean(viClu>0));
end %func


%--------------------------------------------------------------------------
function S_clu = assign_clu_count_(S_clu, P)
nRepeat_max = 1000;
if isempty(P.min_count), P.min_count = 0; end
if ~isfield(S_clu, 'viClu'), S_clu.viClu = []; end
if isempty(S_clu.viClu)
    nClu_pre = [];
else
    nClu_pre = S_clu.nClu;
end
nClu_rm = 0;
fprintf('assigning clusters, nClu:%d\n', numel(S_clu.icl)); t1=tic;

if get_set_(P, 'f_assign_site_clu', 0)
    S_clu.viClu = assignCluster_site_(S_clu, get0_());
end

switch 4
    case 5
        nClu_pre = numel(S_clu.icl);
        [S_clu.viClu, S_clu.icl] = assignCluster_(S_clu.viClu, S_clu.ordrho, S_clu.nneigh, S_clu.icl);
        [S_clu.viClu, S_clu.icl] = dpclus_remove_count_(S_clu.viClu, S_clu.icl, P.min_count);
%         viMap = S_clu_peak_merge_(S_clu, P); % merge peaks based on their waveforms
%         S_clu.viClu = map_index_(viMap, S_clu.viClu, 0);
%         S_clu = S_clu_remove_count_(S_clu, P);
        S_clu = S_clu_refresh_(S_clu); % reassign cluster number?
        nClu_rm = nClu_pre - S_clu.nClu;        
    
    case 4
        nClu_pre = numel(S_clu.icl);
        [S_clu.viClu, S_clu.icl] = assignCluster_(S_clu.viClu, S_clu.ordrho, S_clu.nneigh, S_clu.icl);
        [S_clu.viClu, S_clu.icl] = dpclus_remove_count_(S_clu.viClu, S_clu.icl, P.min_count);
        viMap = S_clu_peak_merge_(S_clu, P); % merge peaks based on their waveforms
        S_clu.viClu = map_index_(viMap, S_clu.viClu, 0);
%         S_clu = S_clu_remove_count_(S_clu, P);
        S_clu = S_clu_refresh_(S_clu); % reassign cluster number?
        nClu_rm = nClu_pre - S_clu.nClu;        
    
    case 1 % don't use small clusters
        vlKill_spk = false(size(S_clu.ordrho));
        for iRepeat=1:nRepeat_max % repeat 1000 times max  
            [S_clu.viClu, S_clu.icl] = assignCluster_(S_clu.viClu, S_clu.ordrho, S_clu.nneigh, S_clu.icl);   
            S_clu = S_clu_refresh_(S_clu);

            % remove clusters unused
            viClu_remove = find(S_clu.vnSpk_clu <= P.min_count);
            vlKill_spk(ismember(S_clu.viClu, viClu_remove)) = true;
            if isempty(viClu_remove), break; end
            S_clu.icl(viClu_remove) = []; 
            S_clu.viClu=[];
            nClu_rm = nClu_rm + numel(viClu_remove);
            if iRepeat==nRepeat_max
                fprintf(2, 'assign_clu_count_: exceeded nRepeat_max=%d\n', nRepeat_max);
            end
        end
        S_clu.viClu(vlKill_spk) = 0;
        S_clu = S_clu_refresh_(S_clu);
    
    case 2 % merge small clusters to large clusters
        for iRepeat=1:nRepeat_max % repeat 1000 times max  
            [S_clu.viClu, S_clu.icl] = assignCluster_(S_clu.viClu, S_clu.ordrho, S_clu.nneigh, S_clu.icl);   
            S_clu = S_clu_refresh_(S_clu);
                
            % remove clusters unused
            viClu_remove = find(S_clu.vnSpk_clu <= P.min_count);
            if isempty(viClu_remove), break; end
            S_clu.icl(viClu_remove) = []; 
            S_clu.viClu=[];
            nClu_rm = nClu_rm + numel(viClu_remove);
            if iRepeat==nRepeat_max
                fprintf(2, 'assign_clu_count_: exceeded nRepeat_max=%d\n', nRepeat_max);
            end
        end
        
    case 3
        nClu_pre = numel(S_clu.icl);
        [S_clu.viClu, S_clu.icl] = assignCluster_(S_clu.viClu, S_clu.ordrho, S_clu.nneigh, S_clu.icl);
        viMap = S_clu_peak_merge_(S_clu, P); % merge peaks based on their waveforms
        S_clu.viClu = map_index_(viMap, S_clu.viClu, 0);
        S_clu = S_clu_remove_count_(S_clu, P);
        nClu_rm = nClu_pre - S_clu.nClu;
        
end
fprintf('\n\ttook %0.1fs. Removed %d clusters having <%d spikes: %d->%d\n', ...
    toc(t1), nClu_rm, P.min_count, nClu_pre, S_clu.nClu);
end %func


%--------------------------------------------------------------------------
function [viClu_new, icl_new] = dpclus_remove_count_(viClu, icl, min_count)
nClu = numel(icl);
viMap = zeros(nClu,1);
vnSpk_clu = arrayfun(@(x)sum(viClu==x), 1:nClu);
vlClu_keep = vnSpk_clu >= min_count;
viMap(vlClu_keep) = 1:sum(vlClu_keep);

viClu_new = map_index_(viMap, viClu);
icl_new = icl(vlClu_keep);
end %func


%--------------------------------------------------------------------------
function viB = map_index_(viA2B, viA, default_val)
% default_val: values not found
if nargin<3, default_val = 0; end
vl_ = ismember(viA, 1:numel(viA2B));
if default_val == 0
    viB = zeros(size(viA), 'like', viA);
else
    viB = repmat(default_val, size(viA));
end
viB(vl_) = viA2B(viA(vl_));
end %func


%--------------------------------------------------------------------------
% 9/17/2018 JJJ: merge peaks based on their waveforms
function viMap = S_clu_peak_merge_(S_clu, P) 
knn_merge_thresh = get_set_(P, 'knn_merge_thresh', 1);
% viMap = (1:numel(S_clu.icl))'; return;
% consider cluster count
% remove centers if their knn overlaps

% S_clu.cviSpk_clu = arrayfun(@(iClu)find(S_clu.viClu==iClu), 1:nClu, 'UniformOutput', 0);
% S_clu.vnSpk_clu = cellfun(@numel, S_clu.cviSpk_clu); 


nClu = numel(S_clu.icl);
mnKnn_clu = zeros(nClu);
miKnn = int32(S_clu.miKnn);
miKnn_clu = miKnn(:,S_clu.icl);
for iClu1 = 1:nClu
    viKnn1 = miKnn_clu(:,iClu1);
    for iClu2 = 1:iClu1-1        
        mnKnn_clu(iClu2,iClu1) = sum(ismember(viKnn1, miKnn_clu(:,iClu2)));
    end
end
[viMap, viUniq_] = ml2map_(mnKnn_clu >= knn_merge_thresh);
% S_clu.icl = S_clu.icl(viUniq_);
viMap = viMap(:);

fprintf('S_clu_peak_merge_: %d->%d cluster centers (knn_merge_thresh=%d)\n', ...
    nClu, numel(viUniq_), knn_merge_thresh);

% tnWav_spk = get_spkwav_(P);
% S0 = get0_();
% miKnn = S_clu.miKnn;
% nClu = numel(S_clu.icl);
% viSite_spk = S0.viSite_spk;
% cvrWav_ = cell(1, nClu);
% viSite_clu = zeros(1, nClu);
% for iClu = 1:nClu
%     iSpk0_ = S_clu.icl(iClu);
%     viSpk_ = miKnn(:,iSpk0_);
%     viSite_clu(iClu) = mode(viSite_spk(viSpk_));
%     mrWav_ = nanmean(tnWav_full_(tnWav_spk, S0, viSpk_), 3);
%     cvrWav_{iClu} = mrWav_(:);
% end %for
% mrWav_clu = cell2mat_(cvrWav_);
% 
% % merge waveform if close and similar
% mrDist_clu = squareform(pdist(P.mrSiteXY(viSite_clu,:)));
% mlMerge_clu = mrDist_clu <= P.maxDist_site_merge_um;
% norm_ = @(x)(x-mean(x))/std(x,1);
% corr_ = @(x,y)mean(norm_(x).*norm_(y));
% mrCorr_clu = zeros(nClu);
% mlUse_clu = ~isnan(mrWav_clu);
% for iClu1 = 2:nClu
%     viClu2 = mlMerge_clu(1:iClu1-1,iClu1);
%     vrWav_clu1 = mrWav_clu(:,iClu1);
%     for iClu2_ = 1:numel(viClu2)
%         iClu2 = viClu2(iClu2_);
%         vl_ = mlUse_clu(:,iClu1) & mlUse_clu(:,iClu2);
%         mrCorr_clu(iClu2, iClu1) = corr_(vrWav_clu1(vl_), mrWav_clu(vl_,iClu2));
%     end
% end
end %func


%--------------------------------------------------------------------------
% 9/17/2018 JJJ: Remove low-count clusters and move their spikes to noise
% cluster
function S_clu = S_clu_remove_count_(S_clu, P); %remove low-count clusters
nClu_pre = max(S_clu.viClu);
min_count = get_set_(P, 'min_count', 30);
vnSpk_clu = arrayfun(@(x)sum(S_clu.viClu==x), 1:max(S_clu.viClu));
viClu_remove = find(vnSpk_clu <= min_count);
S_clu.viClu(ismember(S_clu.viClu, viClu_remove)) = 0;
nClu_removed = numel(viClu_remove);
fprintf('S_clu_remove_count_: Removed %d clusters having <%d spikes: %d->%d clusters\n', ...
    nClu_removed, min_count, nClu_pre, nClu_pre - nClu_removed);
S_clu = S_clu_refresh_(S_clu); % reassign cluster number?
end %func


%--------------------------------------------------------------------------
function vlIn = poly_mask_(hPoly, vxPlot, vyPlot)
mrPolyPos = getPosition(hPoly);
vxPoly = mrPolyPos([1:end,1],1);
vyPoly = mrPolyPos([1:end,1],2);
vlIn = inpolygon(vxPlot, vyPlot, vxPoly, vyPoly);
end %func


%--------------------------------------------------------------------------
function varargout = sort_ascend_(varargin)
% sort all the other fields basedon the first field in ascending order
% [a', b', c'] = sort_ascend_(a, b, c)

[varargout{1}, viSrt] = sort(varargin{1}, 'ascend');
for i=2:nargin
    varargout{i} = varargin{i}(viSrt);
end
end %func


%--------------------------------------------------------------------------
function [mr, vr] = norm_mr_(mr)
% Normalize each columns
vr = sqrt(sum(mr .^ 2));
mr = bsxfun(@rdivide, mr, vr);
end %func


%--------------------------------------------------------------------------
% 10/10/17 JJJ: moved tnWav_spk and tnWav_raw internally
function S_clu = S_clu_wav_(S_clu, viClu_update, fSkipRaw, S0)
% average cluster waveforms and determine the center
% only use the centered spikes 
% viClu_copy: waveforms not changing
if nargin<2, viClu_update = []; end
if nargin<3, fSkipRaw = []; end
if nargin<4, S0 = get(0, 'UserData'); end
P = S0.P;
%if isempty(fSkipRaw), fSkipRaw = ~get_set_(P, 'fWavRaw_merge', 1); end
if isempty(fSkipRaw), fSkipRaw = 0; end
% [dimm_spk, dimm_raw] = get0_('dimm_spk', 'dimm_raw');
P.fMeanSubt = 0;
fVerbose = isempty(viClu_update);
if fVerbose, fprintf('Calculating cluster mean waveform.\n\t'); t1 = tic; end
if isfield(S_clu, 'nClu')
    nClu = S_clu.nClu;
else
    nClu = max(S_clu.viClu);
end
nSamples = S0.dimm_spk(1);
nSites = numel(P.viSite2Chan);
nSites_spk = S0.dimm_spk(2); % n sites per event group (maxSite*2+1);
fDrift_merge = get_set_(P, 'fDrift_merge', 1);

% Prepare cluster loop
if isempty(viClu_update)   
    trWav_spk_clu = zeros([nSamples, nSites_spk, nClu], 'single');
    tmrWav_spk_clu = zeros(nSamples, nSites, nClu, 'single');
    vlClu_update = true(nClu, 1);
    mrPos_clu = deal(zeros(2,nClu, 'single'));        
    if ~fSkipRaw
        nSamples_raw = S0.dimm_raw(1);
        trWav_raw_clu = zeros(nSamples_raw, nSites_spk, nClu, 'single'); 
        tmrWav_raw_clu = zeros(nSamples_raw, nSites, nClu, 'single');
    else
        [trWav_raw_clu, tmrWav_raw_clu] = deal([]);
    end
    if fDrift_merge
        [tmrWav_spk_lo_clu, tmrWav_spk_hi_clu] = deal(tmrWav_spk_clu);
        [tmrWav_raw_lo_clu, tmrWav_raw_hi_clu] = deal(tmrWav_raw_clu);
    else
        [tmrWav_raw_lo_clu, tmrWav_raw_hi_clu, tmrWav_spk_lo_clu, tmrWav_spk_hi_clu] = deal([]);
    end
else
    vlClu_update = false(nClu, 1);
    vlClu_update(viClu_update) = 1;
    nClu_pre = size(S_clu.trWav_spk_clu, 3);
    vlClu_update((1:nClu) > nClu_pre) = 1;
    [tmrWav_spk_clu, trWav_spk_clu, mrPos_clu] = struct_get_(S_clu, 'tmrWav_spk_clu', 'trWav_spk_clu', 'mrPos_clu');
    [tmrWav_raw_clu, trWav_raw_clu] = struct_get_(S_clu, 'tmrWav_raw_clu', 'trWav_raw_clu');
    [tmrWav_spk_lo_clu, tmrWav_spk_hi_clu, tmrWav_raw_lo_clu, tmrWav_raw_hi_clu] ...
        = struct_get_(S_clu, 'tmrWav_spk_lo_clu', 'tmrWav_spk_hi_clu', 'tmrWav_raw_lo_clu', 'tmrWav_raw_hi_clu');
end

% Compute spkwav
tnWav_ = get_spkwav_(P, 0);
for iClu=1:nClu       
    if vlClu_update(iClu)
        if ~isempty(tmrWav_spk_lo_clu)
            [mrWav_clu1, viSite_clu1, mrWav_lo_clu1, mrWav_hi_clu1] = clu_wav_(S_clu, tnWav_, iClu, S0);
            if isempty(mrWav_lo_clu1) || isempty(mrWav_hi_clu1), continue; end
            tmrWav_spk_lo_clu(:,viSite_clu1,iClu) = bit2uV_(mrWav_lo_clu1, P);
            tmrWav_spk_hi_clu(:,viSite_clu1,iClu) = bit2uV_(mrWav_hi_clu1, P);
        else
            [mrWav_clu1, viSite_clu1] = clu_wav_(S_clu, tnWav_, iClu, S0);
        end
        if isempty(mrWav_clu1), continue; end
        [tmrWav_spk_clu(:,viSite_clu1,iClu), trWav_spk_clu(:,:,iClu)] = deal(bit2uV_(mrWav_clu1, P));
        try
            mrPos_clu(:,iClu) = median(S0.mrPos_spk(S_clu.cviSpk_clu{iClu}, :));
        catch
            disperr_();
        end
        if fVerbose, fprintf('.'); end
    end    
end %clu

% Compute spkraw
if ~isempty(tmrWav_raw_clu)
    tnWav_ = []; % clear memory
    tnWav_ = get_spkwav_(P, 1);
    for iClu=1:nClu       
        if vlClu_update(iClu)
            if ~isempty(tmrWav_raw_lo_clu)
                [mrWav_clu1, viSite_clu1, mrWav_lo_clu1, mrWav_hi_clu1] = clu_wav_(S_clu, tnWav_, iClu, S0);
                if isempty(mrWav_lo_clu1) || isempty(mrWav_hi_clu1), continue; end                            
                tmrWav_raw_lo_clu(:,viSite_clu1,iClu) = mrWav_lo_clu1 * P.uV_per_bit;
                tmrWav_raw_hi_clu(:,viSite_clu1,iClu) = mrWav_hi_clu1 * P.uV_per_bit;
            else
                [mrWav_clu1, viSite_clu1] = clu_wav_(S_clu, tnWav_, iClu, S0);                                
            end
            if isempty(mrWav_clu1), continue; end       
            [tmrWav_raw_clu(:,viSite_clu1,iClu), trWav_raw_clu(:,:,iClu)] = deal(mrWav_clu1 * P.uV_per_bit);
            if fVerbose, fprintf('.'); end
        end
    end %clu
end

tmrWav_clu = tmrWav_spk_clu; %meanSubt_ after or before?

% measure waveforms
[vrVmin_clu, viSite_min_clu] = min(permute(min(trWav_spk_clu),[2,3,1]),[],1);
vrVmin_clu = abs(vrVmin_clu(:));
viSite_min_clu = viSite_min_clu(:);

S_clu = struct_add_(S_clu, vrVmin_clu, viSite_min_clu, mrPos_clu, tmrWav_clu, ...
    trWav_spk_clu, tmrWav_spk_clu, tmrWav_spk_lo_clu, tmrWav_spk_hi_clu);
if ~isempty(tmrWav_raw_clu), S_clu = struct_add_(S_clu, trWav_raw_clu, tmrWav_raw_clu); end
if ~isempty(tmrWav_raw_lo_clu), S_clu = struct_add_(S_clu, tmrWav_raw_lo_clu, tmrWav_raw_hi_clu); end
if fVerbose, fprintf('\n\ttook %0.1fs\n', toc(t1)); end
end %func


%--------------------------------------------------------------------------
% 10/22/17 JJJ
function [mrWav_clu1, viSite_clu1, mrWav_lo_clu1, mrWav_hi_clu1] = clu_wav_(S_clu, tnWav_, iClu, S0)
if nargin<4, S0 = get(0, 'UserData'); end
fUseCenterSpk = 0; % set to zero to use all spikes
nSamples_max = 1000;

fDrift_merge = get_set_(S0.P, 'fDrift_merge', 0);
[mrWav_clu1, viSite_clu1, mrWav_lo_clu1, mrWav_hi_clu1] = deal([]);
iSite_clu1 = S_clu.viSite_clu(iClu);
viSite_clu1 = S0.P.miSites(:,iSite_clu1);
viSpk_clu1 = S_clu.cviSpk_clu{iClu};% 
viSite_spk1 = S0.viSite_spk(viSpk_clu1);
vlCentered_spk1 = iSite_clu1 == viSite_spk1;
if fUseCenterSpk    
    viSpk_clu1 = viSpk_clu1(vlCentered_spk1);
    viSite_spk1 = viSite_spk1(vlCentered_spk1);
end
if isempty(viSpk_clu1), return; end  
if ~fDrift_merge
    viSpk_clu2 = spk_select_mid_(viSpk_clu1, S0.viTime_spk, S0.P); 
    mrWav_clu1 = mean(single(tnWav_(:,:,viSpk_clu2)), 3);
    mrWav_clu1 = meanSubt_(mrWav_clu1); %122717 JJJ
    return;
end

% use either time or position based partition
vcMode_wav_merge = 'space';
switch vcMode_wav_merge
    case 'time', vrPosY_spk1 = S0.viTime_spk(viSpk_clu1); % todo: search for correlated time bins for non-monotonic drift
    case 'space', vrPosY_spk1 = S0.mrPos_spk(viSpk_clu1,2);  %position based quantile
end

try
    vrYLim = quantile(vrPosY_spk1, [0, 1/3, 2/3, 1]); %[0,1,2,3]/3);
    [viSpk_clu_, viSite_clu_] = spk_select_pos_(viSpk_clu1, vrPosY_spk1, vrYLim(2:3), nSamples_max, viSite_spk1);
    mrWav_clu1 = nanmean_int16_(tnWav_(:,:,viSpk_clu_), 3, fUseCenterSpk, iSite_clu1, viSite_clu_, S0.P); % * S0.P.uV_per_bit;
catch
    disp('error');
end
if nargout > 2
    [viSpk_clu_, viSite_clu_] = spk_select_pos_(viSpk_clu1, vrPosY_spk1, vrYLim(1:2), nSamples_max, viSite_spk1); 
    mrWav_lo_clu1 = nanmean_int16_(tnWav_(:,:,viSpk_clu_), 3, fUseCenterSpk, iSite_clu1, viSite_clu_, S0.P);

    [viSpk_clu_, viSite_clu_] = spk_select_pos_(viSpk_clu1, vrPosY_spk1, vrYLim(3:4), nSamples_max, viSite_spk1);
    mrWav_hi_clu1 = nanmean_int16_(tnWav_(:,:,viSpk_clu_), 3, fUseCenterSpk, iSite_clu1, viSite_clu_, S0.P);
end
end %func


%--------------------------------------------------------------------------
function [mrWav_, mrWav_lo_, mrWav_hi_] = mean_wav_lo_hi_(tnWav_, viSpk_clu1, viSite_spk1, iSite_clu1, nSamples_max, P)

vl_ = viSite_spk1 == iSite_clu1;
viSpk_ = subsample_vr_(viSpk_clu1(vl_), nSamples_max);
viSite_ = subsample_vr_(viSite_spk1(vl_), nSamples_max);
mrWav_ = nanmean_int16_(tnWav_(:,:,viSpk_), 3, 1, iSite_clu1, viSite_, P);

vl_lo = viSite_spk1 < iSite_clu1;
if any(vl_lo)
    viSpk_lo_ = subsample_vr_(viSpk_clu1(vl_lo), nSamples_max);
    viSite_lo_ = subsample_vr_(viSite_spk1(vl_lo), nSamples_max);
    mrWav_lo_ = nanmean_int16_(tnWav_(:,:,viSpk_lo_), 3, 1, iSite_clu1, viSite_lo_, P);
else
    mrWav_lo_ = mrWav_;
end

vl_hi = viSite_spk1 > iSite_clu1;
if any(vl_hi)
    viSpk_hi_ = subsample_vr_(viSpk_clu1(vl_hi), nSamples_max);
    viSite_hi_ = subsample_vr_(viSite_spk1(vl_hi), nSamples_max);
    mrWav_hi_ = nanmean_int16_(tnWav_(:,:,viSpk_hi_), 3, 1, iSite_clu1, viSite_hi_, P);
else
    mrWav_hi_ = mrWav_;
end
end %func


%--------------------------------------------------------------------------
function mrWav_clu1 = nanmean_int16_(tnWav0, dimm_mean, fUseCenterSpk, iSite1, viSite0, P); % * S0.P.uV_per_bit;
fMedian = strcmpi(get_set_(P, 'vcCluWavMode'), 'median');
if fUseCenterSpk
    if fMedian
        mrWav_clu1 = median(single(tnWav0), dimm_mean);
    else
        mrWav_clu1 = mean(single(tnWav0), dimm_mean);
    end
else
    viSite1 = P.miSites(:, iSite1);
    trWav = nan([size(tnWav0,1), numel(viSite1), numel(viSite0)], 'single');
    viSites_uniq = unique(viSite0);
    nSites_uniq = numel(viSites_uniq);
    miSites_uniq = P.miSites(:, viSites_uniq);
    for iSite_uniq1 = 1:nSites_uniq
        iSite_uniq = viSites_uniq(iSite_uniq1);
        viSpk_ = find(viSite0 == iSite_uniq);
        [~, viSite1a_, viSite1b_] = intersect(viSite1, miSites_uniq(:,iSite_uniq1));
        if isempty(viSite1a_), continue; end
        trWav(:, viSite1a_, viSpk_) = tnWav0(:,viSite1b_,viSpk_); % P.miSites(:,iSite_unique)
    end
    if fMedian
        mrWav_clu1 = nanmedian(trWav, dimm_mean);
    else
        mrWav_clu1 = nanmean(trWav, dimm_mean);
    end
end
mrWav_clu1 = meanSubt_(mrWav_clu1); %122717 JJJ
end %func


%--------------------------------------------------------------------------
% 17/12/5 JJJ: If lim_y criteria is not found return the original
function [viSpk_clu2, viSite_clu2] = spk_select_pos_(viSpk_clu1, vrPosY_spk1, lim_y, nSamples_max, viSite_clu1);
vlSpk2 = vrPosY_spk1 >= lim_y(1) & vrPosY_spk1 < lim_y(2);
if ~any(vlSpk2)
    [viSpk_clu2, viSite_clu2] = deal(viSpk_clu1, viSite_clu1); 
    return; 
end
viSpk_clu2 = subsample_vr_(viSpk_clu1(vlSpk2), nSamples_max);
if nargout>=2
    viSite_clu2 = subsample_vr_(viSite_clu1(vlSpk2), nSamples_max);
end
end %func


%--------------------------------------------------------------------------
function [viSpk_clu1, viSite_clu1, vlSpk_clu1] = S_clu_subsample_spk_(S_clu, iClu, S0)
% subsample spikes from the requested cluster centered at the center site and mid-time range (drift)

fSelect_mid = 1;
nSamples_max = 1000;
if nargin<3, S0 = get(0, 'UserData'); end

% [P, viSite_spk] = get0_('P', 'viSite_spk'); end
[viSpk_clu1, viSite_clu1, vlSpk_clu1] = deal([]);
% Subselect based on the center site
viSpk_clu1 = S_clu.cviSpk_clu{iClu};% 
if isempty(viSpk_clu1), return; end
iSite_clu1 = S_clu.viSite_clu(iClu);        
vlSpk_clu1 = iSite_clu1 == S0.viSite_spk(viSpk_clu1);
viSite_clu1 = S0.P.miSites(:,iSite_clu1);
viSpk_clu1 = viSpk_clu1(vlSpk_clu1);
if isempty(viSpk_clu1), return; end

if fSelect_mid
    viSpk_clu1 = spk_select_mid_(viSpk_clu1, S0.viTime_spk, S0.P); 
end
viSpk_clu1 = subsample_vr_(viSpk_clu1, nSamples_max);
end %func


%--------------------------------------------------------------------------
% 10/18/2018 JJJ: Cluster order fixed
function S_clu = S_clu_sort_(S_clu, vcField_sort)
% sort clusters by the centroid position
% vcField_sort: {'', 'vrPosY_clu + vrPosX_clu'}

if nargin<2, vcField_sort = ''; end

% Sort clusters by its sites
if isempty(vcField_sort), vcField_sort = 'viSite_clu'; end

switch vcField_sort
    case 'vrPosY_clu + vrPosX_clu'
        [~, viCluSort] = sort(S_clu.vrPosY_clu + S_clu.vrPosX_clu, 'ascend');
    otherwise
        [~, viCluSort] = sort(S_clu.(vcField_sort), 'ascend');
end
S_clu.viClu = mapIndex_(S_clu.viClu, viCluSort); % fixed
S_clu = struct_reorder_(S_clu, viCluSort, ...
    'cviSpk_clu', 'vrPosX_clu', 'vrPosY_clu', 'vnSpk_clu', 'viSite_clu', 'cviTime_clu', 'csNote_clu');
S_clu = S_clu_refresh_(S_clu);
end %func


%--------------------------------------------------------------------------
function [S_clu, nRemoved] = S_clu_refrac_(S_clu, P, iClu1)
% clu_refrac(Sclu, P)   %process refrac on all clusters
% clu_refrac(Sclu, P, iClu1) %process on specific clusters
% P.nSkip_refrac = 4; 
% P.fShow_refrac = 0;
viTime_spk = get0_('viTime_spk');
% remove refractory spikes
if nargin==2
%     P = varargin{1}; %second input
    nClu = max(S_clu.viClu);
    P.fShow_refrac = 1;
    nRemoved = 0;
    for iClu=1:nClu
        [S_clu, nRemoved1] = S_clu_refrac_(S_clu, P, iClu);
        nRemoved = nRemoved + nRemoved1;
    end
    return;
else
%     iClu1 = varargin{1};
%     P = varargin{2};
    nRemoved = 0;
    if ~isfield(P, 'nSkip_refrac'), P.nSkip_refrac = 4; end
    if ~isfield(P, 'fShow_refrac'), P.fShow_refrac = 1; end
    try
        viSpk1 = S_clu.cviSpk_clu{iClu1};
    catch
        viSpk1 = find(S_clu.viClu == iClu1);
    end
    if isempty(viSpk1), return; end

    viTime1 = viTime_spk(viSpk1);
    nRefrac = round(P.spkRefrac_ms * P.sRateHz / 1000);

    % removal loop
    vlKeep1 = true(size(viTime1));
    while (1)
        viKeep1 = find(vlKeep1);
        viRefrac11 = find(diff(viTime1(viKeep1)) < nRefrac) + 1;
        if isempty(viRefrac11), break; end

        vlKeep1(viKeep1(viRefrac11(1:P.nSkip_refrac:end))) = 0;
    end
    nRemoved = sum(~vlKeep1);
    nTotal1 = numel(vlKeep1);
    S_clu.viClu(viSpk1(~vlKeep1)) = 0;
    
    S_clu.cviSpk_clu{iClu1} = viSpk1(vlKeep1);
    S_clu.vnSpk_clu(iClu1) = sum(vlKeep1);
end

if get_(P, 'fVerbose')
    fprintf('Clu%d removed %d/%d (%0.1f%%) duplicate spikes\n', ...
        iClu1, nRemoved, nTotal1, nRemoved/nTotal1*100);
end
end %func


%--------------------------------------------------------------------------
function manual_test_(P, csCmd)
drawnow;
if nargin<2, csCmd = ''; end
if isempty(csCmd), csCmd = {'Mouse', 'Menu', 'FigWav', 'FigTime', 'FigWavCor', 'FigProj', 'Exit'}; end
if ischar(csCmd), csCmd = {csCmd}; end
S0 = get(0, 'UserData');
S_clu = S0.S_clu;
nClu = S0.S_clu.nClu;

for iCmd = 1:numel(csCmd)
    vcCmd1 = csCmd{iCmd};
    fprintf('\tTesting manual-mode %d/%d: %s\n', iCmd, numel(csCmd), vcCmd1);
    switch vcCmd1
        case 'Mouse' % simualte mouse click
            keyPress_fig_(get_fig_cache_('FigWav'), 'r');    %view whole
            fprintf('\tTesting mouse L/R clicks.\n');            
            viClu_test1 = [subsample_vr_(1:nClu, 5), nClu];
            for iClu1=viClu_test1
                fprintf('\t\tiCluCopy:%d/%d\n', iClu1, numel(viClu_test1));
                update_cursor_([], iClu1, 0); 
                keyPressFcn_cell_(get_fig_cache_('FigWav'), {'c','t','j','i','v','e','f'});
                drawnow;
                viClu_test2 = keep_lim_(iClu1 + [-2:2], [1, nClu]); 
                for iClu2=viClu_test2
                    fprintf('\t\t\tiCluPaste:%d/%d\n', iClu2, numel(viClu_test2));
                    update_cursor_([], iClu2, 1); 
                    keyPressFcn_cell_(get_fig_cache_('FigWav'), {'c','t','j','i','v','e','f'});
                    drawnow;
                end
            end
            
        case 'Menu' % run menu items, except for the exit and save (make a black list)
            menu_test_(get_fig_('FigWav'), {'Show traces', 'Exit'});
            
        case 'FigWav' % test all possible keyboard press
            keyPress_fig_(get_fig_cache_('FigWav'), get_keyPress_('all'));          
            
        case 'FigTime'
            keyPress_fig_(get_fig_cache_('FigTime'), get_keyPress_('all'));          
            
        case 'FigWavCor'
            keyPress_fig_(get_fig_cache_('FigWavCor'), get_keyPress_('all'));           
            
        case 'FigProj'
            keyPress_fig_(get_fig_cache_('FigProj'), get_keyPress_('all'));                             
            
        case 'Exit'
            %fDebug_ui = 0;  set0_(fDebug_ui); % disable debug flag
            exit_manual_(get_fig_cache_('FigWav'));            
%             fDebug_ui = 1;  set0_(fDebug_ui);
            
        otherwise
            fprintf(2, 'Unsupported testing mode: %s\n', vcCmd1);
    end %swtich    
end
end %func


%--------------------------------------------------------------------------
function vrCentroid = com_(vrVpp, vrPos)
vrVpp_sq = vrVpp(:).^2;
vrCentroid = sum(vrVpp_sq .* vrPos(:)) ./ sum(vrVpp_sq);
end %func


%--------------------------------------------------------------------------
function viSpk_clu2 = spk_select_mid_(viSpk_clu1, viTime_spk, P)
% viTime_spk = get0_('viTime_spk');
iSpk_mid = round(numel(viTime_spk)/2);
viSpk_clu1_ord = rankorder_(abs(viSpk_clu1 - iSpk_mid), 'ascend');
nSpk1_max = round(numel(viSpk_clu1) / P.nTime_clu);
viSpk_clu2 = viSpk_clu1(viSpk_clu1_ord <= nSpk1_max);
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_update_(S_clu, viClu1, P)
% update cluster waveform and self correlation score
% mrWav not needed
S0 = get(0, 'UserData');

% find clu center
for iClu = 1:numel(viClu1)
    iClu1 = viClu1(iClu);
    viSpk_clu1 = find(S_clu.viClu == iClu1);
    S_clu.cviSpk_clu{iClu1} = viSpk_clu1;
    S_clu.viSite_clu(iClu1) = mode(S0.viSite_spk(viSpk_clu1));
    S_clu.vnSpk_clu(iClu1) = numel(viSpk_clu1);
end

% update mean waveform
S_clu = S_clu_wav_(S_clu, viClu1);
% [~, S_clu.viSite_clu(iClu1)] = min(S_clu.tmrWav_clu(1-P.spkLim(1),:,iClu1));
% S_clu.viSite_clu(iClu1) = mode(viSite_spk(viSpk_clu1));
vrSelfCorr_clu = get_diag_(S_clu.mrWavCor);
S_clu.mrWavCor = S_clu_wavcor_(S_clu, P, viClu1);
S_clu.mrWavCor = set_diag_(S_clu.mrWavCor, vrSelfCorr_clu);
for iClu = 1:numel(viClu1)
    iClu1 = viClu1(iClu);
    S_clu.mrWavCor(iClu1,iClu1) = S_clu_self_corr_(S_clu, iClu1, S0);
end
S_clu = S_clu_position_(S_clu, viClu1);
S_clu = S_clu_quality_(S_clu, P, viClu1);
% [S_clu, S0] = S_clu_commit_(S_clu, 'S_clu_update_');
end %func


%--------------------------------------------------------------------------
function vhFig = get_fig_all_(csTag)
vhFig = nan(size(csTag));
for iFig=1:numel(csTag)
    try
        vhFig(iFig) = findobj('Tag', csTag{iFig}); 
    catch
%         disperr_();
    end
end %for
end %func


%--------------------------------------------------------------------------
function [hFig, S_fig] = get_fig_(vcTag, hFig)
% return figure handle based on the tag
% cache figure handles
% [usage]
% get_fig_(vcTag)
% get_fig_(vcTag, hFig) %build cache

% multiple tags requested
if iscell(vcTag), hFig = get_fig_all_(vcTag); return; end

S_fig = [];
try
    hFig = findobj('Tag', vcTag, 'Type', 'figure'); 
    if isempty(hFig)
        hFig = create_figure_(vcTag);
        try %set position if exists
            S0 = get(0, 'UserData');
            iFig = find(strcmp(S0.csFig, vcTag), 1, 'first');
            if ~isempty(iFig)
                set(hFig, 'OuterPosition', S0.cvrFigPos0{iFig});
            end
        catch
%             disperr_();
        end
    else
        hFig=hFig(end); %get later one
    end
    if nargout>1, S_fig = get(hFig, 'UserData'); end
catch
    hFig = [];
    disperr_();
end
end %end


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Type Figure added
function hFig = set_fig_(vcTag, S_fig)
% return figure handle based on the tag
% hFig = set_fig_(vcTag, S_fig)
% hFig = set_fig_(hFig, S_fig)
hFig = [];
try
    if ischar(vcTag)
        hFig = findobj('Tag', vcTag, 'Type', 'Figure');
    else
        hFig = vcTag;
    end
    set(hFig, 'UserData', S_fig); %figure property
catch
     disperr_();
end
end %end


%--------------------------------------------------------------------------
function keyPress_fig_(hFig, csKey)
% Simulate key press function
vcTag = get(hFig, 'Tag');
% S0 = get(0, 'UserData'); 
figure(hFig);
figure_wait_(1); 
event1.Key = '';
if ischar(csKey), csKey = {csKey}; end
nKeys = numel(csKey);
keyPressFcn__ = get(hFig, 'KeyPressFcn');
for i=1:nKeys
    try        
        event1.Key = csKey{i};
        keyPressFcn__(hFig, event1);
        fprintf('\tFigure ''%s'': Key ''%s'' success.\n', vcTag, csKey{i});
    catch
        fprintf(2, '\tFigure ''%s'': Key ''%s'' failed.\n', vcTag, csKey{i});
        disperr_();        
    end
%     pause(.1);
end
% drawnow;
figure_wait_(0);
end %func


%--------------------------------------------------------------------------
function csKeys = get_keyPress_(vcType)
% return key press
switch vcType
    case 'all'
        csKeys = [get_keyPress_('arrows'), get_keyPress_('misc'), get_keyPress_('alphanumeric')];
    case 'alphanumeric'
        csKeys = char([double('0'):double('9'), double('A'):double('Z'), double('a'):double('z')]);
        csKeys = num2cell(csKeys);
    case 'arrows'
        csKeys = {'uparrow', 'downarrow', 'leftarrow', 'rightarrow'};
    case 'misc'
        csKeys = {'home', 'end', 'space', 'esc'};
end %switch
end %func


%--------------------------------------------------------------------------
function hPoly = impoly_(varargin)
global fDebug_ui
% if get_set_([], 'fDebug_ui', 0)
if fDebug_ui==1
    hPoly = []; %skip the test if debugging
else
    hPoly = impoly(varargin{:});
end
end


%--------------------------------------------------------------------------
function vi = keep_lim_(vi, lim)
vi = vi(vi>=lim(1) & vi <= lim(end));
end


%--------------------------------------------------------------------------
function [S_fig, maxAmp_prev, hFig] = set_fig_maxAmp_(vcFig, event)
[hFig, S_fig] = get_fig_cache_(vcFig);
if isempty(S_fig)
    P = get0_('P');
    S_fig.maxAmp = P.maxAmp;
end
maxAmp_prev = S_fig.maxAmp;
if isnumeric(event)
    S_fig.maxAmp = event;
else
    S_fig.maxAmp = change_amp_(event, maxAmp_prev);
end
set(hFig, 'UserData', S_fig);
end


%--------------------------------------------------------------------------
function S = rmfield_(S, varargin)
% varargin: list of fields to remove
for i=1:numel(varargin)
    if isfield(S, varargin{i})
        S = rmfield(S, varargin{i});
    end
end
end %func


%--------------------------------------------------------------------------
function hFig = create_figure_(vcTag, vrPos, vcName, fToolbar, fMenubar)
% or call external create_figure()
if nargin<2, vrPos = []; end
if nargin<3, vcName = ''; end
if nargin<4, fToolbar = 0; end
if nargin<5, fMenubar = 0; end
if isempty(vcTag)
    hFig = figure();
elseif ischar(vcTag)
    hFig = figure_new_(vcTag); 
else
    hFig = vcTag;
end
set(hFig, 'Name', vcName, 'NumberTitle', 'off', 'Color', 'w');
clf(hFig);
set(hFig, 'UserData', []); %empty out the user data
if ~fToolbar
    set(hFig, 'ToolBar', 'none'); 
else
    set(hFig, 'ToolBar', 'figure'); 
end
if ~fMenubar
    set(hFig, 'MenuBar', 'none'); 
else
    set(hFig, 'MenuBar', 'figure'); 
end

if ~isempty(vrPos), resize_figure_(hFig, vrPos); end
% clf(hFig);
end %func


%--------------------------------------------------------------------------
function hAx = axes_new_(hFig)
if ischar(hFig), hFig = get_fig_(hFig); end
figure(hFig); %set focus to figure %might be slow
clf(hFig); 
hAx = axes(); 
hold(hAx, 'on');
end %func


%--------------------------------------------------------------------------
function hFig = figure_new_(vcTag, vrPos)
if nargin<2, vrPos = []; end
%remove prev tag duplication
hFig = findobj('Tag', vcTag, 'Type', 'Figure');
if ~ishandle(hFig), hFig = []; end
switch numel(hFig)
    case 0, hFig = figure('Tag', vcTag);
    case 1, clf(hFig);
    otherwise
        delete_multi_(hFig); 
        hFig = figure('Tag', vcTag);
end
figure(hFig);
if ~isempty(vrPos)
    drawnow; 
    resize_figure_(hFig, vrPos); 
end
end %func


%--------------------------------------------------------------------------
function hFig = resize_figure_(hFig, posvec0, fRefocus)
if nargin<3, fRefocus = 1; end
height_taskbar = 40;

pos0 = get(groot, 'ScreenSize'); 
width = pos0(3); 
height = pos0(4) - height_taskbar;
% width = width;
% height = height - 132; %width offset
% width = width - 32;
posvec = [0 0 0 0];
posvec(1) = max(round(posvec0(1)*width),1);
posvec(2) = max(round(posvec0(2)*height),1) + height_taskbar;
posvec(3) = min(round(posvec0(3)*width), width);
posvec(4) = min(round(posvec0(4)*height), height);
% drawnow;
if isempty(hFig) || ~ishandle(hFig)
    hFig = figure; %create a figure
else
    hFig = figure(hFig);
end
drawnow;
set(hFig, 'OuterPosition', posvec, 'Color', 'w', 'NumberTitle', 'off');
end


%--------------------------------------------------------------------------
function traces_test_(P)
drawnow;
% csCmd = {'Mouse', 'Menu', 'FigWav', 'FigTime', 'FigWavCor', 'FigProj', 'Exit'};

% for iCmd = 1:numel(csCmd)
% vcCmd1 = csCmd{iCmd};
% fprintf('\tTesting manual-mode %d/%d: %s\n', iCmd, numel(csCmd), vcCmd1);
hFig = get_fig_('Fig_traces');
keyPress_fig_(hFig, get_keyPress_('all'));
try
    close(hFig); %close traces figure. other figures may remain
    close(get_fig_('FigPsd'));
catch
end
end %func


%--------------------------------------------------------------------------
function gui_test_(P, vcFig, csMenu_skip)
if nargin<3, csMenu_skip = {}; end
drawnow;
hFig = get_fig_(vcFig);
keyPress_fig_(hFig, get_keyPress_('all'));

% Menu test
menu_test_(hFig, csMenu_skip);

try
    close(hFig); %close traces figure. other figures may remain
catch
    ;
end
end %func


%--------------------------------------------------------------------------
function [vlSuccess_menu, csLabel_menu] = menu_test_(hFig, csMenu_skip)
vMenu0 = findobj('Type', 'uimenu', 'Parent', hFig);
cvMenu = cell(size(vMenu0));            
for iMenu0 = 1:numel(vMenu0)
    cvMenu{iMenu0} = findobj('Type', 'uimenu', 'Parent', vMenu0(iMenu0))';
end
vMenu = [cvMenu{:}];
cCallback_menu = get(vMenu, 'Callback');
csLabel_menu = get(vMenu, 'Label');
fprintf('\tTesting menu items\n');

vlSuccess_menu = true(size(csLabel_menu));
for iMenu = 1:numel(csLabel_menu)    
    vcMenu = csLabel_menu{iMenu};             
    if ismember(vcMenu, csMenu_skip), continue; end
    try        
        hFunc = cCallback_menu{iMenu};
        if isempty(hFunc), continue; end
%                     hFunc(hFigWav, []); %call function
        hFunc(vMenu(iMenu), []); %call function
        fprintf('\tMenu ''%s'' success.\n', vcMenu);             
    catch
        fprintf(2, '\tMenu ''%s'' failed.\n', vcMenu);
        disperr_();
        vlSuccess_menu(iMenu) = 0;
    end
end
end %func


%--------------------------------------------------------------------------
function hRect = imrect_(varargin)
global fDebug_ui
    
hRect = []; %skip the test if debugging
% if get_set_([], 'fDebug_ui', 0) && nargin < 2
if fDebug_ui==1 && nargin < 2
    return;
else
    try
        hRect = imrect(varargin{:});
    catch
        fprintf(2, 'Install image processing toolbox\n');
    end
end
end


%--------------------------------------------------------------------------
function csAns = inputdlg_(varargin)
% return default answer
global fDebug_ui
% if get_set_([], 'fDebug_ui', 0)
if fDebug_ui==1
    if numel(varargin)==4
        csAns = varargin{4};
    else
        csAns = [];
    end
else
    csAns = inputdlg(varargin{:});
end
end


%--------------------------------------------------------------------------
function vr_uV = bit2uV_(vn, P)
% use only for filtered traces

if nargin<2, P = get0_('P'); end
% if isempty(get_(P, 'nDiff_filt')), P.nDiff_filt = 0; end
switch lower(get_filter_(P))
    case 'sgdiff'
        norm = sum((1:P.nDiff_filt).^2) * 2;
    case 'ndiff'
        norm = 2^(P.nDiff_filt-1);
    otherwise
        norm = 1;
end
% switch P.nDiff_filt
%     case 0, norm = 1;
%     case 1, norm = 2;
%     case 2, norm = 10;
%     case 3, norm = 28;
%     otherwise, norm = 60;
% end %switch
vr_uV = single(vn) * single(P.uV_per_bit / norm);
end


%--------------------------------------------------------------------------
function vr_uV = uV2bit_(vn, P)
% use only for filtered traces

if nargin<2, P = get0_('P'); end
if isempty(P.nDiff_filt), P.nDiff_filt = 0; end
if strcmpi(P.vcFilter, 'ndiff')
    norm = 2^(P.nDiff_filt-1);
else
    norm = 1;
end
vr_uV = single(vn) / single(P.uV_per_bit / norm);
end


%--------------------------------------------------------------------------
function flag = isvalid_(h)
if isempty(h), flag = 0; return ;end
try
    flag = isvalid(h);
catch
    flag = 0;
end
end %func


%--------------------------------------------------------------------------
% 12/21/17 JJJ: Get the tag by name which is cached (like hash table)
function hObj = get_tag_(vcTag, vcType)
% clear before starting manual
% Return from persistent cache
% Create a new figure if Tag doesn't exist

persistent S_tag_cache_
if nargin<2, vcType = []; end
if isempty(S_tag_cache_)
    S_tag_cache_ = struct(); 
else
    if isfield(S_tag_cache_, vcTag)
        hObj = S_tag_cache_.(vcTag);
        if isvalid_(hObj), return; end
    end
end
hObj = findobj('Tag', vcTag, 'Type', vcType);
S_tag_cache_.(vcTag) = hObj;
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Generalized to any figures previously querried.
function [hFig, S_fig] = get_fig_cache_(vcFig_tag)
% clear before starting manual
% Return from persistent cache
% Create a new figure if Tag doesn't exist

persistent S_fig_cache_
% persistent hFigPos hFigMap hFigWav hFigTime hFigProj hFigWavCor hFigHist hFigIsi hFigCorr hFigRD hFig_traces hFig_preview
if iscell(vcFig_tag)
    if nargout==1
        hFig = cellfun(@(vc)get_fig_cache_(vc), vcFig_tag, 'UniformOutput', 0);
    else
        [hFig, S_fig] = cellfun(@(vc)get_fig_cache_(vc), vcFig_tag, 'UniformOutput', 0);
    end
    return; 
end
if isempty(S_fig_cache_)
    hFig = get_fig_(vcFig_tag);
    S_fig_cache_ = struct(vcFig_tag, hFig);
else
    if isfield(S_fig_cache_, vcFig_tag)
        hFig = S_fig_cache_.(vcFig_tag);
        if isvalid_(hFig)
            hFig = S_fig_cache_.(vcFig_tag);            
        else
            hFig = get_fig_(vcFig_tag);
            S_fig_cache_.(vcFig_tag) = hFig;
        end
    else
        hFig = get_fig_(vcFig_tag);
        S_fig_cache_.(vcFig_tag) = hFig;
    end
end
if nargout>1, S_fig = get(hFig, 'UserData'); end
end %func


%--------------------------------------------------------------------------
function import_jrc1_(vcFile_prm)
% import jrc1 so that i can visualize the output
global tnWav_raw tnWav_spk trFet_spk
% convert jrc1 format (_clu and _evt) to irc format. no overwriting
% receive spike location, time and cluster number. the rest should be taken care by irc processing

% Load info from previous version: time, site, spike
P = loadParam_(vcFile_prm);
Sevt = load(strrep(P.vcFile_prm, '.prm', '_evt.mat'));
if isfield(Sevt, 'Sevt'), Sevt = Sevt.Sevt; end
S0 = struct('viTime_spk', Sevt.viSpk, 'viSite_spk', Sevt.viSite, 'P', P);

[tnWav_raw, tnWav_spk, trFet_spk, S0] = file2spk_(P, S0.viTime_spk, S0.viSite_spk);
set(0, 'UserData', S0);

% Save to file
write_bin_(strrep(P.vcFile_prm, '.prm', '_spkraw.jrc'), tnWav_raw);
write_bin_(strrep(P.vcFile_prm, '.prm', '_spkwav.jrc'), tnWav_spk);
write_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), trFet_spk);
save0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));

% cluster and describe
sort_(P);
S0 = get(0, 'UserData');
Sclu = load_(strrep(P.vcFile_prm, '.prm', '_clu.mat'));
if isfield(Sclu, 'Sclu'), Sclu = Sclu.Sclu; end
if ~isempty(Sclu)
    S0.S_clu.viClu = Sclu.viClu; %skip FigRD step for imported cluster
end
set(0, 'UserData', S0);

describe_(P.vcFile_prm);
end %func


%--------------------------------------------------------------------------
function S_mat = load_(vcFile, csVar, fVerbose)
% return empty if the file doesn't exist
% load_(vcFile)
% load_(vcFile, vcVar)
% load_(vcFile, csVar)
% load_(vcFile, csVar, fVerbose)
% load_(vcFile, [], fVerbose)

S_mat = [];
if isempty(vcFile), return; end
if nargin<2, csVar={}; end
if ischar(csVar), csVar = {csVar}; end
if nargin<3, fVerbose=1; end
if exist_file_(vcFile)
    try
        S_mat = load(vcFile);
    catch
        fprintf(2, 'Invalid .mat format: %s\n', vcFile);
    end
else
    if fVerbose
        fprintf(2, 'File does not exist: %s\n', vcFile);
    end
end
if ~isempty(csVar)
    S_mat = get_(S_mat, csVar{:});
end
end %func


%--------------------------------------------------------------------------
function [viTime_spk, vrAmp_spk, viSite_spk] = detect_spikes_(mnWav3, vnThresh_site, vlKeep_ref, P)
% fMerge_spk = 1;
fMerge_spk = get_set_(P, 'fMerge_spk', 1);

[n1, nSites, ~] = size(mnWav3);
[cviSpk_site, cvrSpk_site] = deal(cell(nSites,1));
if isempty(vnThresh_site)
    vnThresh_site = int16(mr2rms_(gather_(mnWav3), 1e5) * P.qqFactor);
end
fprintf('\tDetecting spikes from each channel.\n\t\t'); t1=tic;
% parfor iSite = 1:nSites   
for iSite = 1:nSites   
    % Find spikes
    [viSpk11, vrSpk11] = spikeDetectSingle_fast_(mnWav3(:,iSite), P, vnThresh_site(iSite));
    fprintf('.');
    
    % Reject global mean
    if isempty(vlKeep_ref)
        cviSpk_site{iSite} = viSpk11;
        cvrSpk_site{iSite} = vrSpk11;        
    else
        [cviSpk_site{iSite}, cvrSpk_site{iSite}] = select_vr_(viSpk11, vrSpk11, find(vlKeep_ref(viSpk11)));
    end
end
vnThresh_site = gather_(vnThresh_site);
nSpks1 = sum(cellfun(@numel, cviSpk_site));
fprintf('\n\t\tDetected %d spikes from %d sites; took %0.1fs.\n', nSpks1, nSites, toc(t1));

% Group spiking events using vrWav_mean1. already sorted by time
if fMerge_spk
    fprintf('\tMerging spikes...'); t2=tic;
    [viTime_spk, vrAmp_spk, viSite_spk] = spikeMerge_(cviSpk_site, cvrSpk_site, P);
    fprintf('\t%d spiking events found; took %0.1fs\n', numel(viSite_spk), toc(t2));
else
    viTime_spk = cell2mat_(cviSpk_site);
    vrAmp_spk = cell2mat_(cvrSpk_site);
    viSite_spk = cell2vi_(cviSpk_site);
    %sort by time
    [viTime_spk, viSrt] = sort(viTime_spk, 'ascend');
    [vrAmp_spk, viSite_spk] = multifun_(@(x)x(viSrt), vrAmp_spk, viSite_spk);
end
vrAmp_spk = gather_(vrAmp_spk);

% Group all sites in the same shank
if get_set_(P, 'fGroup_shank', 0)
    [viSite_spk] = group_shank_(viSite_spk, P); % change the site location to the shank center
end
end %func


%--------------------------------------------------------------------------
function [viSite_spk] = group_shank_(viSite_spk, P)
nSites = numel(P.viSite2Chan);
site2site = zeros([nSites, 1], 'like', viSite_spk);
[a,b,c] = unique(P.viShank_site);
site2site(P.viSite2Chan) = b(c);
viSite_spk = site2site(viSite_spk);
end %func 


%--------------------------------------------------------------------------
function [viTime_spk11, viSite_spk11] = filter_spikes_(viTime_spk0, viSite_spk0, tlim)
% Filter spikes that is within tlim specified

[viTime_spk11, viSite_spk11] = deal([]); 
if isempty(viTime_spk0), return; end
viKeep11 = find(viTime_spk0 >= tlim(1) & viTime_spk0 <= tlim(end));
viTime_spk11 = viTime_spk0(viKeep11)  + (1 - tlim(1)); % shift spike timing
if ~isempty(viSite_spk0)
    viSite_spk11 = viSite_spk0(viKeep11);
else
    viSite_spk11 = [];
end
end %func


%--------------------------------------------------------------------------
function import_silico_(vcFile_prm, fSort)
% need _gt struct?
% import silico ground truth
% S_gt: must contain viTime, viSite, viClu 
% [usage]
% import_silico_(vcFile_prm, 0): use imported sort result (default)
% import_silico_(vcFile_prm, 1): use ironclust sort result
if nargin<2, fSort = 0; end

global tnWav_raw tnWav_spk trFet_spk
% convert jrc1 format (_clu and _evt) to irc format. no overwriting
% receive spike location, time and cluster number. the rest should be taken care by irc processing
P = loadParam_(vcFile_prm); %makeParam_kilosort_
if isempty(P), return; end

P.snr_thresh_gt = read_cfg_('snr_thresh_gt');
snr_thresh_stat = P.snr_thresh_gt * .75;
vcFile_gt1 = strrep(P.vcFile_prm, '.prm', '_gt1.mat');
if exist_file_(vcFile_gt1) 
    S_gt1 = load(vcFile_gt1);
else
    S_gt0 = load_gt_(P.vcFile_gt, P);
    if isempty(S_gt0), fprintf(2, 'Groundtruth does not exist. Run "irc import" to create a groundtruth file.\n'); return; end
    S_gt1 = gt2spk_(S_gt0, P, snr_thresh_stat);
    struct_save_(S_gt1, vcFile_gt1);
end

if ~isfield(S_gt1, 'viSite')
    S_gt1.viSite = S_gt1.viSite_clu(S_gt1.viClu); 
end
S0 = struct('viTime_spk', S_gt1.viTime(:), 'viSite_spk', S_gt1.viSite(:), 'P', P, 'S_gt', S_gt1);

[S0] = file2spk_(P, S0.viTime_spk, S0.viSite_spk);
set(0, 'UserData', S0);

trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet); 
S0.mrPos_spk = spk_pos_(S0, trFet_spk);

% cluster and describe
% S0 = sort_(P);
% if ~fSort %use ground truth cluster 
S0.S_clu = S_clu_new_(S_gt1.viClu, S0);    
% end
set(0, 'UserData', S0);

% Save
save0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
describe_(S0);
end %func


%--------------------------------------------------------------------------
function import_ksort_(vcFile_prm, fSort)
% import_ksort_(P, fSort)
% import_ksort_(vcFile_prm, fSort)
% fMerge_post = 0;
% import kilosort result
% fSort: do sort using irc
if isstruct(vcFile_prm)
    P = vcFile_prm;
    vcFile_prm = P.vcFile_prm;
else
    P = loadParam_(vcFile_prm); %makeParam_kilosort_
end

% S_ksort = load(strrep(P.vcFile_prm, '.prm', '_ksort.mat')); % contains rez structure
if nargin<2, fSort = 0; end %
global tnWav_raw tnWav_spk trFet_spk
% convert jrc1 format (_clu and _evt) to irc format. no overwriting
% receive spike location, time and cluster number. the rest should be taken care by irc processing

% Create a prm file to start with. set the filter parameter correctly. features? 
if isempty(P), return; end
S_ksort = load(strrep(P.vcFile_prm, '.prm', '_ksort.mat')); %get site # and 
viTime_spk = S_ksort.rez.st3(:,1) - 6; %spike time (apply shift factor)
viClu = S_ksort.rez.st3(:,2); % cluster

viClu_post = 1 + S_ksort.rez.st3(:,5);  %post-merging result
tnWav_clu = S_ksort.rez.Wraw; %nC, nT, nClu
tnWav_clu = -abs(tnWav_clu);
tnWav_clu = permute(tnWav_clu, [2,1,3]);
mnMin_clu = squeeze_(min(tnWav_clu, [], 1));
[~, viSite_clu] = min(mnMin_clu, [], 1); %cluster location
viSite = 1:numel(P.viSite2Chan);
viSite(P.viSiteZero) = [];
viSite_clu = viSite(viSite_clu);
viSite_spk = viSite_clu(viClu);
% vnAmp_spk = S_ksort.rez.st3(:,3);

% S0 = struct('viTime_spk', int32(viTime_spk), 'viSite_spk', int32(viSite_spk), 'P', P, 'S_ksort', S_ksort);
S0 = file2spk_(P, int32(viTime_spk), int32(viSite_spk));
S0.P = P;
S0.S_ksort = S_ksort;
tnWav_raw = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkraw.jrc'), 'int16', S0.dimm_raw);
tnWav_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkwav.jrc'), 'int16', S0.dimm_spk); 
trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet); 
S0.mrPos_spk = spk_pos_(S0, trFet_spk);
set(0, 'UserData', S0);

if get_set_(P, 'fMerge_post_ksort', 0)
    S0.S_clu = S_clu_new_(viClu_post, S0);    
else
    S0.S_clu = S_clu_new_(viClu, S0);    
end
S0.S_clu = S_clu_sort_(S0.S_clu, 'viSite_clu'); 
% end
% S0.S_clu = S_clu_new_(S0.S_clu);
set(0, 'UserData', S0);

% Save
save0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
describe_(S0);
end %func


%--------------------------------------------------------------------------
function vl = matchFileExt_(csFiles, vcExt, vlDir)
% vcExt can be a cell
% ignore dir
% matchFileExt_(csFiles, vcExt, vlDir)
% matchFileExt_(csFiles, csExt, vlDir) %multiple extension check
if ischar(csFiles), csFiles={csFiles}; end
vl = false(size(csFiles));

for i=1:numel(csFiles)
    [~,~,vcExt1] = fileparts(csFiles{i});
    vl(i) = any(strcmpi(vcExt1, vcExt));
end
if nargin >= 3
    vl = vl | vlDir; %matches if it's directory
end
end %func


% %--------------------------------------------------------------------------
% function P = file2struct_(vcFile_file2struct)
% % Run a text file as .m script and result saved to a struct P
% % _prm and _prb can now be called .prm and .prb files
% 
% try 
%     P = file2struct__(vcFile_file2struct); % new version
% catch
%     P = file2struct_1_(vcFile_file2struct); % old version
% end
% % if isempty(P)
% %     copyfile(vcFile_file2struct, 'temp_eval.m', 'f');
% %     try
% %         eval('temp_eval.m');
% %     catch
% %         disp(lasterr());
% %     end
% % end
% end %func


%--------------------------------------------------------------------------
% function P = file2struct_1_(vcFile_file2struct)
% if ~exist_file_(vcFile_file2struct)
%     fprintf(2, '%s does not exist.\n', vcFile_file2struct);
%     P = [];
%     return;
% end
% 
% % load text file
% fid=fopen(vcFile_file2struct, 'r');
% csCmd = textscan(fid, '%s', 'Delimiter', '\n');
% fclose(fid);
% csCmd = csCmd{1};
% 
% % parse command
% for iCmd=1:numel(csCmd)
%     try
%         vcLine1 = strtrim(csCmd{iCmd});
%         if isempty(vcLine1), continue; end
%         if find(vcLine1=='%', 1, 'first')==1, continue; end
%         iA = find(vcLine1=='=', 1, 'first');
%         if isempty(iA), continue; end            
%         iB = find(vcLine1=='(', 1, 'first');
%         if ~isempty(iB) && iB<iA, iA=iB; end
%         eval(vcLine1);
%         vcVar1 = strtrim(vcLine1(1:iA-1));
%         eval(sprintf('P.(vcVar1) = %s;', vcVar1));
%     catch
%         fprintf(2, lasterr);
%     end
% end %for
% end %func


%--------------------------------------------------------------------------
% function P = appendStruct_(P, varargin)
% % backward compatibility
% P = struct_merge_(P, varargin{:});
% end


%--------------------------------------------------------------------------
function [vcDir, vcFile, vcExt] = fileparts_(vcPath1)
[vcDir, vcFile, vcExt] = fileparts(vcPath1);
if any(vcFile == '/')
    iSep = find(vcFile=='/', 1, 'last');
elseif any(vcFile == '\')
    iSep = find(vcFile=='\', 1, 'last');
else
    iSep = [];
end % if
if ~isempty(iSep)
    vcDir = [vcDir, vcFile(1:iSep)];
    vcFile = vcFile(iSep+1:end);
end
end %func


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: fileparts corrected
function vcPath = replacePath_(vcPath1, vcPath2)
% replace path1 with path2
[~, vcFname1, vcExt1] = fileparts_(vcPath1);
[vcDir2,~,~] = fileparts(vcPath2);
if ~isempty(vcDir2)
    vcPath = [vcDir2, filesep(), vcFname1, vcExt1];
else
    vcPath = [vcFname1, vcExt1];
end
end %func


%---------------------------------------------------------------------------
function out = ifeq_(if_, true_, false_)
if (if_)
    out = true_;
else
    out = false_;
end
end %func


%--------------------------------------------------------------------------
function figure_wait_(fWait, vhFig)
% set all figures pointers to watch
if nargin<2, vhFig = gcf; end
fWait_prev = strcmpi(get_(vhFig(1), 'Pointer'), 'watch');
if fWait && ~fWait_prev      
    set_(vhFig, 'Pointer', 'watch'); 
    drawnow;
else
    set_(vhFig, 'Pointer', 'arrow');
end
end %func


%--------------------------------------------------------------------------
function nBytes = getBytes_(vcFile)
% S_dir = dir(vcFile);
% if isempty(S_dir), nBytes=[]; return; end
% nBytes = S_dir(1).bytes;
nBytes = filesize_(vcFile);
end %func


%--------------------------------------------------------------------------
% Return [] if multiple files are found
function nBytes = filesize_(vcFile)
S_dir = dir(vcFile);
if numel(S_dir) ~= 1
    nBytes = []; 
else
    nBytes = S_dir(1).bytes;
end
end %func


%--------------------------------------------------------------------------
function S = makeStruct_(varargin)
%MAKESTRUCT all the inputs must be a variable. 
%don't pass function of variables. ie: abs(X)
%instead create a var AbsX an dpass that name
S = struct();
for i=1:nargin, S.(inputname(i)) =  varargin{i}; end
end %func


%--------------------------------------------------------------------------
function [mr, vi] = subsample_mr_(mr, nMax, dimm)
%[mr, vi] = subsample_mr_(mr, nMax, dimm)
% subsample the column
if nargin<3, dimm = 2; end
if isempty(nMax), return ;end

n = size(mr,dimm);
nSkip = max(floor(n / nMax), 1);
vi = 1:nSkip:n;
if nSkip==1, return; end
vi = vi(1:nMax);

switch dimm
    case 2
        mr = mr(:,vi);
    case 1
        mr = mr(vi,:);
end

if nargout>=2
    if n > nMax
        vi = 1:nSkip:n;
        vi = vi(1:nMax);
    else
        vi = 1:n;
    end
end
end %func


%--------------------------------------------------------------------------
function varargout = multifun_(hFun, varargin)
% apply same function to the input, unary function only

if nargout ~= numel(varargin), error('n arg mismatch'); end
for i=1:nargout
    try
        varargout{i} = hFun(varargin{i});
    catch
        varargout{i} = varargin{i};
    end
end
end %func


%--------------------------------------------------------------------------
function mr = reshape_vr2mr_(vr, nwin)
nbins = ceil(numel(vr)/nwin);
vr(nbins*nwin) = 0; %expand size
mr = reshape(vr(1:nbins*nwin), nwin, nbins);
end %func


%--------------------------------------------------------------------------
% 11/10/17: Removed recursive saving
% 9/29/17 Updating the version number when saving IronClust
function S0 = save0_(vcFile_mat, fSkip_fig)
if nargin<2, fSkip_fig = 0; end
% save S0 structure to a mat file
try    
    fprintf('Saving 0.UserData to %s...\n', vcFile_mat);
    warning off;
    S0 = get(0, 'UserData'); %add gather script
    if isfield(S0, 'S0'), S0 = rmfield(S0, 'S0'); end % Remove recursive saving
    
    % update version number
    S0.P.version = version_();
    P = S0.P;
    set0_(P);
    
    struct_save_(S0, vcFile_mat, 1);
    vcFile_prm = S0.P.vcFile_prm;
    export_prm_(vcFile_prm, strrep(vcFile_prm, '.prm', '_full.prm'), 0);    

    % save the rho-delta plot        
    if fSkip_fig, return; end
    if ~isfield(S0, 'S_clu') || ~get_set_(P, 'fSavePlot_RD', 1), return; end
    try
        if isempty(get_(S0.S_clu, 'delta')), return; end % skip kilosort
        save_fig_(strrep(P.vcFile_prm, '.prm', '_RD.png'), plot_rd_(P, S0), 1);
        fprintf('\tYou can use ''irc plot-rd'' command to plot this figure.\n');
    catch
        fprintf(2, 'Failed to save the rho-delta plot: %s.\n', lasterr());
    end    
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
% like gcf but doesn't create a new figure
function hFig = gcf_()
hFig = get(groot(),'CurrentFigure');
end %func


%--------------------------------------------------------------------------
% error tolerent figure selection
function hFig = figure_(hFig)
if nargin<1, hFig = figure(); return; end
if isempty(hFig), return; end
try 
    if gcf() ~= hFig
        figure(hFig);
    end
catch; end
end %func


%--------------------------------------------------------------------------
function [vl, vr] = thresh_mad_(vr, thresh_mad)
% single sided, no absolute value

nsubs = 300000;
offset = median(subsample_vr_(vr, nsubs));
vr = vr - offset; %center the mean
factor = median(abs(subsample_vr_(vr, nsubs)));
if isempty(thresh_mad) || thresh_mad==0
    vl = true(size(vr));
else
    vl = vr < factor * thresh_mad;
end
if nargout>=2
    vr = vr / factor; %MAD unit
end
end %func


%--------------------------------------------------------------------------
function vi = subsample_vr_(vi, nMax)
if numel(vi)>nMax
    nSkip = floor(numel(vi)/nMax);
    if nSkip>1, vi = vi(1:nSkip:end); end
    if numel(vi)>nMax
        try
            nRemove = numel(vi) - nMax;
            viRemove = round(linspace(1, numel(vi), nRemove));
            viRemove = min(max(viRemove, 1), numel(vi));
            vi(viRemove) = [];
        catch
            vi = vi(1:nMax);
        end
    end
end
end %func


%--------------------------------------------------------------------------
function [vrPow, vrFreq] = plotMedPower_(mrData, varargin)

if numel(varargin) ==1
    if ~isstruct(varargin{1}), P.sRateHz = varargin{1}; 
    else P = varargin{1};
    end
else
    P = funcInStr_(varargin{:});
end
    
P = funcDefStr_(P, 'viChanExcl', [1 18 33 50 65 82 97 114], 'sRateHz', 25000, ...
    'nSmooth', 3, 'LineStyle', 'k-', 'fPlot', 1, 'fKHz', 0, 'vcMode', 'max');
    
if iscell(mrData) %batch mode
    csFname = mrData;
    [vrPow, vrFreq] =deal(cell(numel(csFname)));
    for i=1:numel(csFname)
        hold on;
        [vrPow{i}, vrFreq{i}] = plotMedPower_(csFname{i});
    end
    legend(csFname);
    return;
else
    vcFname='';
end
warning off;

mrData = fft(mrData);
mrData = real(mrData .* conj(mrData)) / size(mrData,1) / (P.sRateHz/2);
% mrPowFilt = filter([1 1 1], 3, mrPow);
% mrPow = fftshift(mrPow);
imid0 = ceil(size(mrData,1)/2);
vrFreq = (0:size(mrData,1)-1) * (P.sRateHz/size(mrData,1));
vrFreq = vrFreq(2:imid0);
viChan = setdiff(1:size(mrData,2), P.viChanExcl);
if size(mrData,2)>1
    switch P.vcMode
        case 'mean'
            vrPow = mean(mrData(2:imid0,viChan), 2);    
        case 'max'
            vrPow = max(mrData(2:imid0,viChan), [], 2);    
    end
else
    vrPow = mrData(2:imid0,1);
end
% vrPow = std(mrData(:,viChan), 1, 2);
if P.nSmooth>1, vrPow = filterq_(ones([P.nSmooth,1]),P.nSmooth,vrPow); end

if P.fPlot
    if P.fKHz, vrFreq = vrFreq/1000; end
    plot(vrFreq, pow2db_(vrPow), P.LineStyle);
%     set(gca, 'YScale', 'log'); 
%     set(gca, 'XScale', 'linear'); 
    xlabel('Frequency (Hz)'); ylabel('Mean power across sites (dB uV^2/Hz)');
    % xlim_([0 P.sRateHz/2]);
    grid on;
    try
    xlim_(vrFreq([1, end]));
    set(gcf,'color','w');
    title(vcFname, 'Interpreter', 'none');
    catch
        
    end
end
end %func


%--------------------------------------------------------------------------
function P = funcInStr_( varargin )

if isempty(varargin), P=struct(); return; end
if isstruct(varargin{1}), P = varargin{1}; return; end

csNames = varargin(1:2:end);
csValues = varargin(2:2:end);
P = struct();
for iField=1:numel(csNames)
    if ~isfield(P, csNames{iField})
%         v1 = csValues{iField};
%         eval(sprintf('P.%s = v1;', csNames{iField}));
        P = setfield(P, csNames{iField}, csValues{iField});
    end
end
end %func


%--------------------------------------------------------------------------
function P = funcDefStr_(P, varargin)
csNames = varargin(1:2:end);
csValues = varargin(2:2:end);

for iField=1:numel(csNames)
    if ~isfield(P, csNames{iField})
        P = setfield(P, csNames{iField}, csValues{iField});
    end
end
end %func


%--------------------------------------------------------------------------
function varargout = select_vr_(varargin)
% [var1, var2, ...] = select_vr(var1, var2, ..., index)

% sort ascend
viKeep = varargin{end};
if islogical(viKeep), viKeep = find(viKeep); end
for i=1:(nargin-1)
    if isvector(varargin{i})
        varargout{i} = varargin{i}(viKeep);
    else
        varargout{i} = varargin{i}(viKeep, :);
    end
end
end %func


%--------------------------------------------------------------------------
% 9/17/2018 JJJ: Select dimension and index for all fields in the struct
function S = struct_select_dimm_(S, vi1, fLastDimm)
if nargin<3, fLastDimm = 1; end

csName = fieldnames(S);
for iField = 1:numel(csName)
    vcName_ = csName{iField};
    val_ = S.(vcName_);
    try
        S.(vcName_) = select_dimm_(val_, vi1, fLastDimm);
    catch
        ;
    end
end %for
end %func


%--------------------------------------------------------------------------
% 9/17/2018 JJJ: Select dimension and index
function var1 = select_dimm_(var, vi1, fLastDimm)
% var1 = select_vr(var, index)
% fLastDimm: last dimm chosen if 1, first dimm chosen if 0

if nargin<3, fLastDimm = 1; end
% 
% sort ascend
if islogical(vi1), vi1 = find(vi1); end
if isempty(var)
    var1 = []; 
elseif isvector(var)
    var1 = var(vi1);
elseif ismatrix(var)
    if fLastDimm
        var1 = var(:,vi1);
    else
        var1 = var(vi1,:);
    end
elseif ndims(var) == 3
    if fLastDimm
        var1 = var(:,:,vi1);
    else
        var1 = var(vi1,:,:);
    end
elseif ndims(var) == 4
    if fLastDimm
        var1 = var(:,:,:,vi1);
    else
        var1 = var(vi1,:,:,:);
    end      
elseif ndims(var) == 5
    if fLastDimm
        var1 = var(:,:,:,:,vi1);
    else
        var1 = var(vi1,:,:,:,:);
    end     
else
    error('select_lastdimm_:out_of_range');
end
end %func


%--------------------------------------------------------------------------
% 17/11/10: Removed recursive saving
function S0 = load0_(vcFile_mat)
% Load a mat file structure and set to 0 structure
% S0 = load0_(vcFile_mat)
% S0 = load0_(P)
% only set the S0 if it's found
if isstruct(vcFile_mat)
    P = vcFile_mat;
    vcFile_mat = strrep(P.vcFile_prm, '.prm', '_jrc.mat');
end
S0 = [];
if ~exist_file_(vcFile_mat, 1), return; end
    
try
    fprintf('loading %s...\n', vcFile_mat); t1=tic;
    S0 = load(vcFile_mat);    
    set(0, 'UserData', S0);
    fprintf('\ttook %0.1fs\n', toc(t1));
catch
    S0 = [];
    disperr_();
end
if isfield(S0, 'S0'), S0 = rmfield(S0, 'S0'); end % Remove recursive saving
end %func


%--------------------------------------------------------------------------
function S = struct_add_(varargin)
% S = struct_add_(S, var1, var2, ...)
% output
% S.var1=var1; S.var2=var2; ...

S = varargin{1};
for i=2:numel(varargin)
    try
        S.(inputname(i)) = varargin{i};
    catch
        disperr_();
    end
end
end %func


%--------------------------------------------------------------------------
function [tr, miRange] = mr2tr3_(mr, spkLim, viTime, viSite, fMeanSubt)
% tr: nSamples x nSpikes x nChans

if nargin<4, viSite=[]; end %faster indexing
if nargin<5, fMeanSubt=0; end

% JJJ 2015 Dec 24
% vr2mr2: quick version and doesn't kill index out of range
% assumes vi is within range and tolerates spkLim part of being outside
% works for any datatype
if isempty(viTime), tr=[]; return; end
[N, M] = size(mr);
if ~isempty(viSite), M = numel(viSite); end
if iscolumn(viTime), viTime = viTime'; end

viTime0 = [spkLim(1):spkLim(end)]'; %column
miRange = bsxfun(@plus, int32(viTime0), int32(viTime));
miRange = min(max(miRange, 1), N);
miRange = miRange(:);

if isempty(viSite)
    tr = mr(miRange,:);
else
    tr = mr(miRange, viSite);
end
tr = reshape(tr, [numel(viTime0), numel(viTime), M]);

if fMeanSubt
%     trWav1 = single(permute(trWav1, [1,3,2])); 
    tr = single(tr);
    dimm1 = size(tr);
    tr = reshape(tr, size(tr,1), []);
    tr = bsxfun(@minus, tr, mean(tr)); %mean subtract
    tr = reshape(tr, dimm1);    
end
end %func


%--------------------------------------------------------------------------
function disp_stats_(vr, csCaptions)
if nargin<2, csCaptions = ''; end
% fprintf('n, mu/sd, (med,q25,q75), min-max:\t %d, %0.2f/%0.2f, (%0.2f, %0.2f, %0.2f), %0.2f-%0.2f\n', ...
%     numel(vr), mean(vr), std(vr), quantile(vr, [.5, .25, .75]), min(vr), max(vr));
if isvector(vr)
    vr = vr(~isnan(vr));
    vr = vr(:);
    fprintf('n, mu/sd, (10,25,*50,75,90%%), min-max:\t %d, %0.1f/%0.1f, (%0.1f, %0.1f, *%0.1f, %0.1f, %0.1f), %0.1f-%0.1f\n', ...
        numel(vr), mean(vr), std(vr), quantile(vr, [.1,.25,.5,.75,.9]), min(vr), max(vr));
    return;
elseif ismatrix(vr)
    mr = vr;
    for iCol=1:size(mr,2)
        if isempty(csCaptions)
            fprintf('\tCol%d: ', iCol);
        else
            fprintf('\t%s: ', csCaptions{iCol});
        end
        disp_stats_(mr(:,iCol));
    end
end
end %func

%--------------------------------------------------------------------------
function [mrWav, S_tsf] = importTSF_(fname, varargin)
fid = fopen(fname, 'r');
S_tsf = importTSF_header_(fid);
n_vd_samples = S_tsf.n_vd_samples;
n_electrodes = S_tsf.nChans;
mrWav = reshape(fread(fid, n_vd_samples * n_electrodes, '*int16'), [n_vd_samples,n_electrodes]);
fclose(fid);
end %func


%--------------------------------------------------------------------------
function Sfile = importTSF_header_(arg1)
% Sfile = importTSF_header(vcFname) %pass file name string
% Sfile = importTSF_header(fid) %pass fid

if ischar(arg1)
    fid = fopen(arg1, 'r');
    vcFname = arg1;
else
    fid = arg1;
    vcFname = [];
end

% 16 bytes
header = fread(fid, 16, 'char*1=>char');

% 4x5 bytes
iformat = fread(fid, 1, 'int32');
SampleFrequency = fread(fid, 1, 'int32');
n_electrodes = fread(fid, 1, 'int32');
n_vd_samples = fread(fid, 1, 'int32');
vscale_HP = fread(fid, 1, 'single');

% electrode info
Siteloc = zeros(2, n_electrodes, 'int16'); %2 x n_elec
Readloc = zeros(1, n_electrodes, 'int32'); %read location
for i_electrode = 1:n_electrodes
    Siteloc(:, i_electrode) = fread(fid, 2, 'int16');
    Readloc(i_electrode) = fread(fid, 1, 'int32');
end
if ~isempty(vcFname), fclose(fid); end

Sfile = struct('header', header, 'iformat', iformat, ...
    'sRateHz', SampleFrequency, 'nChans', n_electrodes, ...
    'n_vd_samples', n_vd_samples, 'vscale_HP', vscale_HP, ...
    'Siteloc', Siteloc, 'tLoaded', n_vd_samples/SampleFrequency, 'Readloc', Readloc);
end %func


%--------------------------------------------------------------------------
function dc = calc_dc2_(S0, P, vlRedo_spk, viDrift_spk)
global trFet_spk
if nargin<3, vlRedo_spk=[]; end
if nargin<4, viDrift_spk = []; end
fprintf('Calculating Dc (=distance cut-off)...\n\t'); t1=tic;
nSites = numel(P.viSite2Chan);
vrDc2_site = nan(1, nSites);
for iSite = 1:nSites
    [mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_] = fet12_site_(trFet_spk, S0, P, iSite, vlRedo_spk, viDrift_spk);
    if isempty(mrFet12_), continue; end
    vrDc2_site(iSite) = compute_dc2_(mrFet12_, viiSpk12_ord_, n1_, n2_, P); % Compute DC in CPU
    fprintf('.');    
end
dc = sqrt(abs(quantile(vrDc2_site, .5)));
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function [vi, viSort] = rankorder_(vr, vcOrder)
% warning: 32 bit addressing
if nargin<2, vcOrder = 'ascend'; end
n=numel(vr);
[~,viSort] = sort(vr, vcOrder);
if isGpu_(vr)
    vi = zeros(n,1,'int32', 'gpuArray');
    vi(viSort) = 1:n;
else
    vi=zeros(n,1,'int32');
    vi(viSort) = 1:n;
end
end %func


%--------------------------------------------------------------------------
function mi = rankorder_mr_(mr, val0)
if nargin<2, val0 = 0; end % separate positive and negaitve number ranks

if isrow(mr), mr=mr'; end

dimm1 = size(mr); %=numel(vr);
if numel(dimm1)==3
%     mr = reshape(mr, [], dimm1(3));  % spike by spike order
    mr = mr(:); % global order
end

mi=zeros(size(mr));
for iCol = 1:size(mr,2)
    vr1 = mr(:,iCol);
    vi_p = find(vr1>val0);    
    if ~isempty(vi_p)
        [~, vi_p_srt] = sort(vr1(vi_p), 'ascend');
        mi(vi_p(vi_p_srt), iCol) = 1:numel(vi_p);
    end
    
    vi_n = find(vr1<val0);
    if ~isempty(vi_n)
        [~, vi_n_srt] = sort(vr1(vi_n), 'descend');
        mi(vi_n(vi_n_srt), iCol) = -(1:numel(vi_n));
    end
end
% [~,miSort] = sort(mr, vcOrder);
% vr_ = (1:size(mr,1))';
% for iCol = 1:size(mr,2)
%     vi_ = miSort(:,iCol);
%     mr(vi_, iCol)
%     mi(,iCol) = vr_;
% end

if numel(dimm1)==3, mi = reshape(mi, dimm1); end
end %func



%--------------------------------------------------------------------------
function plot_cdf_(vrSnr, fNorm)
if nargin<2, fNorm=0; end
vrX = sort(vrSnr,'ascend');
vrY = 1:numel(vrSnr);
if fNorm, vrY=vrY/vrY(end); end
stairs(vrY, vrX); 
end %func


%--------------------------------------------------------------------------
function [mr, miRange] = vr2mr3_(vr, vi, spkLim)
% JJJ 2015 Dec 24
% vr2mr2: quick version and doesn't kill index out of range
% assumes vi is within range and tolerates spkLim part of being outside
% works for any datatype

% prepare indices
if size(vi,2)==1, vi=vi'; end %row
viSpk = int32(spkLim(1):spkLim(end))';
miRange = bsxfun(@plus, viSpk, int32(vi));
miRange(miRange<1) = 1; 
miRange(miRange > numel(vr)) = numel(vr); %keep # sites consistent
% miRange = int32(miRange);

% build spike table
nSpks = numel(vi);
mr = reshape(vr(miRange(:)), [], nSpks);
end %func


%--------------------------------------------------------------------------
function [miSites, mrDist] = findNearSites_(mrSiteXY, maxSite, viSiteZero, viShank_site)
% find nearest sites
if nargin < 3, viSiteZero = []; end
if nargin<4, viShank_site = []; end
if numel(unique(viShank_site)) <= 1, viShank_site = []; end

mrSiteXY(viSiteZero,:) = inf;
max_dist = max(pdist(mrSiteXY));
% if ~isempty(viSiteZero)
%     mrSiteXY(viSiteZero,:) = max_dist*2; %bad sites will never be near
% end
nSites = size(mrSiteXY,1);
nNearSites = min(maxSite*2+1, nSites);
[miSites, mrDist] = deal(zeros(nNearSites, nSites));
viNearSites = 1:nNearSites;
for iSite=1:nSites
    if ismember(iSite, viSiteZero), continue; end % exclude zero sites
    vrSiteDist = pdist2_(mrSiteXY(iSite,:), mrSiteXY);
    if ~isempty(viShank_site)
        vrSiteDist(viShank_site(iSite) ~= viShank_site) = max_dist*4;
    end
    [vrSiteDist, viSrt] = sort(vrSiteDist, 'ascend');
    miSites(:,iSite) = viSrt(viNearSites);
    mrDist(:,iSite) = vrSiteDist(viNearSites);
end
end %func


%--------------------------------------------------------------------------
function vrDist_k = knn_sorted_(mrFet_srt, n_neigh, k_nearest)
nSpk = size(mrFet_srt, 1);
% if nargin<3, n_neigh=[]; end
% if nargin<4, k_nearest=[]; end

vrDist_k = zeros(nSpk, 1, 'single');
mrFet_srt = (mrFet_srt);
n1 = n_neigh*2+1;
mrFet_srt1 = mrFet_srt(1:n1,:);
iCirc = 1;
for iSpk = 1:nSpk
%     iSpk = viSpk_sub(iSpk1);
    if iSpk > n_neigh && iSpk <= nSpk-n_neigh
        mrFet_srt1(iCirc,:) = mrFet_srt(iSpk+n_neigh,:);
        iCirc=iCirc+1;
        if iCirc>n1, iCirc=1; end
    end
    vrDist1 = sort(sum(bsxfun(@minus, mrFet_srt1, mrFet_srt(iSpk,:)).^2, 2));
    vrDist_k(iSpk) = vrDist1(k_nearest);
end

vrDist_k = gather_(vrDist_k);
end %func


%--------------------------------------------------------------------------
function boxplot_(vrY, vrX, xbin, xlim1)
% range to plot: xlim1
vcMode = 'both';
fOdd = 0;
if fOdd
    viX = ceil((vrX+xbin/2)/xbin);
else
    viX = ceil(vrX/xbin);
end
ilim = ceil(xlim1/xbin);
viX(viX<ilim(1))=ilim(1);
viX(viX>ilim(end))=ilim(end);

nbins = diff(ilim)+1;
mrYp = zeros(nbins,3);
viXp = (ilim(1):ilim(end));
if fOdd
    vrXp = viXp * xbin - xbin;
else
    vrXp = viXp * xbin - xbin/2;
end
for ibin=1:nbins
    try
        ibin1 = viXp(ibin);
        mrYp(ibin, :) = quantile(vrY(viX==ibin1), [.25, .5, .75]);
    catch
        ;
    end
end
mrXp1 = nan(numel(vrXp), 3);
mrXp1(:,1) = vrXp - xbin/2;
mrXp1(:,2) = vrXp + xbin/2;
switch lower(vcMode)
    case 'stairs'
        vrXp = viXp - xbin/2;
        vrXp(end+1)=vrXp(end)+xbin;
        mrYp(end+1,:) = mrYp(end,:);
        stairs(vrXp, mrYp); grid on; 
    case 'line'
        plot(vrXp, mrYp); grid on; 
    case 'both'
        hold on; grid on;
        vrXp1 = vrXp - xbin/2;
        vrXp1(end+1) = vrXp1(end)+xbin;      
        stairs(vrXp1, mrYp([1:end,end],[1, 3]), 'k-');
%         plot_rect_(mrXp1(:,1:2), mrYp(:,[1,3]), .25);
        plot(mrXp1', repmat(mrYp(:,2), 1, 3)', 'k-', 'LineWidth', 1);
%         stairs(vrXp1, mrYp([1:end,end],[2]), 'k-', 'LineWidth', 1);
%         plot(vrXp, mrYp(:,2), 'k-', 'LineWidth', 1); 
end
end %func


%--------------------------------------------------------------------------
% Use patch 
function plot_rect_(mrX, mrY, faceAlpha, vrColor)
% mrX, mrY: nPoints x 2 (left and right edges)
if nargin<3, faceAlpha = .25; end
if nargin<4, vrColor = [0 0 0]; end
mrX(isnan(mrX)) = 0;
mrY(isnan(mrY)) = 0;
X = mrX(:,[1,2,2,1,1])';
Y = mrY(:,[1,1,2,2,1])';
F = bsxfun(@plus, 5*(1:size(mrX,1))', -4:0);
patch('Vertices', [X(:), Y(:)], 'Faces', F, 'FaceAlpha', faceAlpha, 'EdgeColor', 'none', 'FaceColor', vrColor);
end %func


%--------------------------------------------------------------------------
function close_(hMsg)
try close(hMsg); catch; end
end


%--------------------------------------------------------------------------
function viTime1 = randomSelect_(viTime1, nShow)
if isempty(viTime1), return; end
if numel(viTime1) > nShow
    viTime1 = viTime1(randperm(numel(viTime1), nShow));
end
end %func


%--------------------------------------------------------------------------
function vr = linmap_(vr, lim1, lim2, fSat)
if nargin< 4
    fSat = 0;
end
if numel(lim1) == 1, lim1 = [-abs(lim1), abs(lim1)]; end
if numel(lim2) == 1, lim2 = [-abs(lim2), abs(lim2)]; end

if fSat
    vr(vr>lim1(2)) = lim1(2);
    vr(vr<lim1(1)) = lim1(1);
end
if lim1(1)==lim1(2)
    vr = vr / lim1(1);
else
    vr = interp1(lim1, lim2, vr, 'linear', 'extrap');
end
end %func


%--------------------------------------------------------------------------
function hPlot = plotTable_(lim, varargin)

vrX = floor((lim(1)*2:lim(2)*2+1)/2);
vrY = repmat([lim(1), lim(2), lim(2), lim(1)], [1, ceil(numel(vrX)/4)]);
vrY = vrY(1:numel(vrX));
hPlot = plot([vrX(1:end-1), fliplr(vrY)], [vrY(1:end-1), fliplr(vrX)], varargin{:});
end %func


%--------------------------------------------------------------------------
function hPlot = plotDiag_(lim, varargin)
[vrX, vrY] = plotDiag__(lim);
% vrY = floor((lim(1)*2:lim(2)*2+1)/2);
% vrX = [vrY(2:end), lim(end)];
% hPlot = plot([vrX(1:end-1), fliplr(vrY)], [vrY(1:end-1), fliplr(vrX)], varargin{:});
hPlot = plot(vrX, vrY, varargin{:});
end %func


%--------------------------------------------------------------------------
function [vrX, vrY] = plotDiag__(lim)
% lim: [start, end] or [start, end, offset]

vrY0 = floor((lim(1)*2:lim(2)*2+1)/2);
% vrY0 = lim(1):lim(end);
vrX0 = [vrY0(2:end), lim(2)];
vrX = [vrX0(1:end-1), fliplr(vrY0)];
vrY = [vrY0(1:end-1), fliplr(vrX0)];
if numel(lim)>=3
    vrX = vrX + lim(3);
    vrY = vrY + lim(3);
end
end %func


%--------------------------------------------------------------------------
function vlVisible = toggleVisible_(vhPlot, fVisible)
if isempty(vhPlot), return; end

if iscell(vhPlot)
    cvhPlot = vhPlot;
    if nargin<2
        cellfun(@(vhPlot)toggleVisible_(vhPlot), cvhPlot);
    else
        cellfun(@(vhPlot)toggleVisible_(vhPlot, fVisible), cvhPlot);
    end
    return;
end
try
    if nargin==1
        vlVisible = false(size(vhPlot));
        % toggle visibility
        for iH=1:numel(vhPlot)
            hPlot1 = vhPlot(iH);
            if strcmpi(get(hPlot1, 'Visible'), 'on')
                vlVisible(iH) = 0;
                set(hPlot1, 'Visible', 'off');
            else
                vlVisible(iH) = 1;
                set(hPlot1, 'Visible', 'on');
            end
        end
    else
        % set visible directly
        if fVisible
            vlVisible = true(size(vhPlot));
            set(vhPlot, 'Visible', 'on');
        else
            vlVisible = false(size(vhPlot));
            set(vhPlot, 'Visible', 'off');
        end
    end
catch
    return;
end
end %func


%--------------------------------------------------------------------------
function S = struct_delete_(S, varargin)
% delete and set to empty

for i=1:numel(varargin)
    try 
        delete(S.(varargin{i}));
        S.(varargin{i}) = [];
    catch
        ;
    end
end
end %func


%--------------------------------------------------------------------------
function hMsg = msgbox_open_(vcMessage)
global fDebug_ui

% if get_set_([], 'fDebug_ui', 0), hMsg = []; return; end
if fDebug_ui==1, hMsg = []; return; end
hFig = gcf;
hMsg = msgbox(vcMessage);  
figure(hFig); %drawnow;
end


%--------------------------------------------------------------------------
function [i1, i2] = swap_(i1, i2)
i11 = i1;   i1 = i2;    i2 = i11;
end %func


%--------------------------------------------------------------------------
function Sclu = merge_clu_pair_(Sclu, iClu1, iClu2)
% if iClu1>iClu2, [iClu1, iClu2] = swap(iClu1, iClu2); end

% update vnSpk_clu, viClu, viSite_clu. move iClu2 to iClu1
n1 = Sclu.vnSpk_clu(iClu1);
n2 = Sclu.vnSpk_clu(iClu2);
Sclu.vnSpk_clu(iClu1) = n1 + n2;
Sclu.vnSpk_clu(iClu2) = 0;
Sclu.viClu(Sclu.viClu == iClu2) = iClu1;
Sclu.cviSpk_clu{iClu1} = find(Sclu.viClu == iClu1);
Sclu.cviSpk_clu{iClu2} = [];
try
    Sclu.csNote_clu{iClu1} = '';
    Sclu.csNote_clu{iClu2} = '';
catch
end
end %func


%--------------------------------------------------------------------------
function set_axis_(hFig, xlim1, ylim1, xlim0, ylim0)
% set the window within the box limit
if nargin <= 3
    % square case
    xlim0 = ylim1;
    ylim1 = xlim1;
    ylim0 = xlim0;
end

hFig_prev = gcf;
figure(hFig); 
dx = diff(xlim1);
dy = diff(ylim1);

if xlim1(1)<xlim0(1), xlim1 = xlim0(1) + [0, dx]; end
if xlim1(2)>xlim0(2), xlim1 = xlim0(2) + [-dx, 0]; end
if ylim1(1)<ylim0(1), ylim1 = ylim0(1) + [0, dy]; end
if ylim1(2)>ylim0(2), ylim1 = ylim0(2) + [-dy, 0]; end

xlim1(1) = max(xlim1(1), xlim0(1));
ylim1(1) = max(ylim1(1), ylim0(1));
xlim1(2) = min(xlim1(2), xlim0(2));
ylim1(2) = min(ylim1(2), ylim0(2));

axis_([xlim1, ylim1]);

figure(hFig_prev);
end %func


% %--------------------------------------------------------------------------
% function mrDist_clu = S_clu_wavcor_1_(S_clu, P)
% % oldd version
% % viShift0 = 0; %-2:2; %compare time shifted version
% viShift0 = -6:6; %time shift range
% fWav_cumsum = 0;
% 
% % tmrWav_clu = ifeq_(fWav_cumsum, S_clu.tmrWav_clu, S_clu.tmrWav_spk_clu);
% tmrWav_clu = meanSubt_(S_clu.tmrWav_raw_clu);
% % maxSite = P.maxSite_merge;
% maxSite = ceil(P.maxSite/2);
% mrDist_clu = nan(S_clu.nClu);
% miSites = P.miSites;
% % miSites = P.miSites(1:(maxSite+1), :); % center
% for iClu2 = 1:S_clu.nClu         
%     iSite2 = S_clu.viSite_clu(iClu2);   
%     viSite2 = miSites(:,iSite2);
%     vrWav2 = get_wav_(tmrWav_clu, viSite2, iClu2);
%     mrWav2 = zscore_(shift_vr_(vrWav2(:), viShift0)); %try +/-4 samples
%     viClu1 = find(abs(S_clu.viSite_clu - iSite2) <= maxSite);
%     viClu1(viClu1 == iClu2) = [];
%     viClu1 = viClu1(:)';
%     vlWav2 = vrWav2~=0;
%     for iClu1 = viClu1   
%         try            
%             vrWav1 = zscore_(get_wav_(tmrWav_clu, viSite2, iClu1));
%             n12 = sum(vlWav2 & vrWav1~=0);
%             corr12 = max(vrWav1' * mrWav2) / n12; %numel(vrWav1);
%             mrDist_clu(iClu1, iClu2)=corr12;
%         catch
%             disp('Sclu_wavcor: error');
%         end
%     end
% end
% end %func


%--------------------------------------------------------------------------
function mr = get_wav_(tmrWav_clu, viSite, iClu, viShift)
if nargin <4, viShift = 0; end

mrWav1 = (tmrWav_clu(:,viSite, iClu));
% mrWav1 = zscore_(mrWav1);

% induce waveform shift
cmr = cell(1, numel(viShift));
for iShift = 1:numel(viShift)
	mr1 = shift_mr_(mrWav1, viShift(iShift));    
    mr1 = bsxfun(@minus, mr1, mean(mr1,1));
    cmr{iShift} = mr1(:);
end
% mr = zscore_(cell2mat_(cmr));
mr = cell2mat_(cmr);
end %func


%--------------------------------------------------------------------------
function mr = shift_mr_(mr, n)
if n<0
    n=-n;
    mr(1:end-n, :) = mr(n+1:end, :);
elseif n>0
    mr(n+1:end, :) = mr(1:end-n, :);    
else %n==0
    return;     
end
end %func


%--------------------------------------------------------------------------
function [S_clu, nClu_merged] = S_clu_wavcor_merge_(S_clu, P)

mrWavCor = S_clu.mrWavCor;
nClu = size(mrWavCor, 2);

% Identify clusters to remove, update and same (no change), disjoint sets
% mrWavCor(tril(true(nClu)) | mrWavCor==0) = nan; %ignore bottom half
mrWavCor(tril(true(nClu))) = 0; %ignore bottom half
[vrCor_max, viMap_clu] = max(mrWavCor);
vlKeep_clu = vrCor_max < get_set_(P, 'maxWavCor', 1); % | isnan(vrCor_max);
if all(vlKeep_clu), nClu_merged=0; return ;end
min_cor = min(vrCor_max(~vlKeep_clu));
viClu_same = find(vlKeep_clu);
viMap_clu(vlKeep_clu) = viClu_same;
viClu_same = setdiff(viClu_same, viMap_clu(~vlKeep_clu));
viClu_remove = setdiff(1:nClu, viMap_clu);
viClu_update = setdiff(setdiff(1:nClu, viClu_same), viClu_remove);
% viClu_update = setdiff(1:nClu, viClu_same);

% update cluster number
try S_clu.icl(viClu_remove) = []; catch, end
S_clu = S_clu_map_index_(S_clu, viMap_clu); %index mapped
P.fVerbose = 0;
S_clu = S_clu_refrac_(S_clu, P); % remove refrac spikes

% update cluster waveforms and distance
S_clu = S_clu_wav_(S_clu, viClu_update); %update cluster waveforms
S_clu.mrWavCor = S_clu_wavcor_(S_clu, P, viClu_update);
S_clu = S_clu_remove_empty_(S_clu);

nClu_merged = nClu - S_clu.nClu;
fprintf('\tnClu: %d->%d (%d merged, min-cor: %0.4f)\n', nClu, S_clu.nClu, nClu_merged, min_cor);
end %func


%--------------------------------------------------------------------------
function varargout = multiindex_(viKeep, varargin)
% index first dimension of variables by a given index

if nargout ~= numel(varargin), error('Number of argin=argout'); end
    
if islogical(viKeep), viKeep = find(viKeep); end
for i=1:numel(varargin)
    var1 = varargin{i};
    if isvector(var1)
        varargout{i} = var1(viKeep);
    elseif ismatrix(var1)
        varargout{i} = var1(viKeep,:);
    else %multidimensional variable
        varargout{i} = var1(viKeep,:,:);
    end    
end
end %func


%--------------------------------------------------------------------------
function S = struct_reorder_(S, viKeep, varargin)
for i=1:numel(varargin)
    try
        vcVar = varargin{i};
        if ~isfield(S, vcVar), continue; end %ignore if not
        vr1 = S.(vcVar);
        if isvector(vr1)
            vr1 = vr1(viKeep);
        elseif ismatrix(vr1)
            vr1 = vr1(viKeep, :);
        else
            vr1 = vr1(viKeep, :, :);
        end
        S.(vcVar) = vr1;
    catch
        ;
    end
end
end %func


%--------------------------------------------------------------------------
function [vlIn_spk, mrFet, vhAx, hFig] = auto_split_wav_(mrSpkWav, mrFet, nSplits)
% TODO: ask users number of clusters and split multi-way
%Make automatic split of clusters using PCA + kmeans clustering
%  input Sclu, trSpkWav and cluster_id of the cluster you want to cut

if nargin<2, mrFet = []; end
if nargin<3, nSplits = 2; end

nSpks = size(mrSpkWav,2);
vlIn_spk = false(nSpks,1);
vlIn_spk(1:end/2) = true;

if isempty(mrFet)    
%     [~,mrFet,vrD] = pca(double(mrSpkWav'), 'Centered', 1, 'NumComponents', 3);
    [mrFet,~,vrD] = pca(double(mrSpkWav), 'NumComponents', 3);
end
% nSplit = preview_split_(mrSpkWav1);
% if isnan(nSplit), return; end

hFig = figure;
resize_figure_(hFig, [.5 0 .5 1]);
vhAx = zeros(4,1);
for iAx=1:numel(vhAx)
    vhAx(iAx) = subplot(2,2,iAx, 'Parent', hFig); hold on;
end
if size(mrFet,2) == 3
    plot(vhAx(1), mrFet(:,1), mrFet(:,2), '.'); xylabel_(vhAx(1), 'PC1', 'PC2', 'PC1 vs PC2');
    plot(vhAx(2), mrFet(:,3), mrFet(:,2), '.'); xylabel_(vhAx(2), 'PC3', 'PC2', 'PC3 vs PC2');
    plot(vhAx(3), mrFet(:,1), mrFet(:,3), '.'); xylabel_(vhAx(3), 'PC1', 'PC3', 'PC1 vs PC3');
    drawnow;
else
    plot(vhAx(1), mrFet(vlIn_spk,1), mrFet(vlIn_spk,2), 'b.', mrFet(~vlIn_spk,1), mrFet(~vlIn_spk,2), 'r.');
    return;
end

% Ask how many clusters there are
try    
    % kmean clustering into 2
    idx = kmeans(mrFet, nSplits);     
    d12 = mad_dist_(mrFet(idx==1,:)', mrFet(idx==2,:)'); 
    fprintf('mad_dist: %f\n', d12);
%     idx = kmeans([pca_1,pca_2], NUM_SPLIT);
    vlIn_spk = logical(idx-1);
catch
%         msgbox('Too few spikes to auto-split');
    return;
end
vlOut_spk = ~vlIn_spk;
plot(vhAx(1), mrFet(vlIn_spk,1), mrFet(vlIn_spk,2), 'b.', mrFet(vlOut_spk,1), mrFet(vlOut_spk,2), 'r.');
plot(vhAx(2), mrFet(vlIn_spk,3), mrFet(vlIn_spk,2), 'b.', mrFet(vlOut_spk,3), mrFet(vlOut_spk,2), 'r.');
plot(vhAx(3), mrFet(vlIn_spk,1), mrFet(vlIn_spk,3), 'b.', mrFet(vlOut_spk,1), mrFet(vlOut_spk,3), 'r.');

min_y=min(reshape(mrSpkWav,1,[]));
max_y=max(reshape(mrSpkWav,1,[]));
viSpk1 = subsample_vr_(1:size(mrSpkWav,1), 1000); % show 1000 sites only

hold(vhAx(4), 'on');
title(vhAx(4), 'Mean spike waveforms');
plot(vhAx(4), mean(mrSpkWav(viSpk1,vlIn_spk),2),'b');
plot(vhAx(4), mean(mrSpkWav(viSpk1,vlOut_spk),2),'r');
ylim_([min_y max_y]);
end %func


%--------------------------------------------------------------------------
function ylim_(arg1, arg2)
% ylim function
% ylim_(lim_)
% ylim_(hAx, lim_)
if nargin==1
    [hAx_, lim_] = deal(gca, arg1);
else
    [hAx_, lim_] = deal(arg1, arg2);
end
if any(isnan(lim_)), return; end
try
    ylim(hAx_, sort(lim_));
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
function xlim_(arg1, arg2)
% ylim function
% ylim_(lim_)
% ylim_(hAx, lim_)
if nargin==1
    [hAx_, lim_] = deal(gca, arg1);
else
    [hAx_, lim_] = deal(arg1, arg2);
end
if any(isnan(lim_)), return; end
try
    xlim(hAx_, sort(lim_));
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
function axis_(arg1, arg2)
if nargin==1
    [hAx_, lim_] = deal(gca, arg1);
else
    [hAx_, lim_] = deal(arg1, arg2);
end
if ischar(lim_)
    axis(hAx_, lim_);
    return;
end
if any(isnan(lim_)), return; end
try
    axis(hAx_, [sort(lim_(1:2)), sort(lim_(3:4))]);
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
function [vi, nClu, viA, viAB] = mapIndex_(vi, viA, viB)
% change the index of vi according to the map (viA)

if nargin<2, viA = setdiff(unique(vi), 0); end %excl zero
if nargin<3, viB = 1:numel(viA); end
if isempty(viA), viA = 1:max(vi); end
nClu = viB(end);
viAB(viA) = viB; %create a translation table A->B
vl = vi>0;
vi(vl) = viAB(vi(vl)); %do not map zeros
end %func


%--------------------------------------------------------------------------
function d12 = mad_dist_(mrFet1, mrFet2)
% distance between two clusters
if ~ismatrix(mrFet1)
    mrFet1 = reshape(mrFet1, [], size(mrFet1,3));
end
if ~ismatrix(mrFet2)
    mrFet2 = reshape(mrFet2, [], size(mrFet2,3));
end
vrFet1_med = median(mrFet1, 2);
vrFet2_med = median(mrFet2, 2);
vrFet12_med = vrFet1_med - vrFet2_med;
norm12 = sqrt(sum(vrFet12_med.^2));
vrFet12_med1 = vrFet12_med / norm12;
mad1 = median(abs(vrFet12_med1' * bsxfun(@minus, mrFet1, vrFet1_med)));
mad2 = median(abs(vrFet12_med1' * bsxfun(@minus, mrFet2, vrFet2_med)));
d12 = norm12 / sqrt(mad1.^2 + mad2.^2);
end %func


%--------------------------------------------------------------------------
function mr = filterq_(vrA, vrB, mr, dimm)
% quick filter using single instead of filtfilt
% faster than filtfilt and takes care of the time shift 

if nargin < 4, dimm = 1; end
if numel(vrA)==1, return; end
if isempty(vrB), vrB=sum(vrA); end
%JJJ 2015 09 16
% mr = filter(vrA, vrB, mr, [], dimm);
mr = circshift(filter(vrA, vrB, mr, [], dimm), -ceil(numel(vrA)/2), dimm);
end %func


%--------------------------------------------------------------------------
function S = imec3_imroTbl_(cSmeta)
% Smeta has imroTbl

vcDir_probe = 'C:\Dropbox (HHMI)\IMEC\SpikeGLX_Probe_Cal_Data\';  %this may crash. probe calibaration folder

if isstruct(cSmeta), cSmeta = {cSmeta}; end %turn it into cell of struct
% parse imroTbl
cs_imroTbl = cellfun(@(S)S.imroTbl, cSmeta, 'UniformOutput', 0);
cvn_imroTbl = cellfun(@(vc)textscan(vc, '%d', 'Delimiter', '( ),'), cs_imroTbl, 'UniformOutput', 0);
cvn_imroTbl = cellfun(@(c)c{1}, cvn_imroTbl, 'UniformOutput', 0);   
S.viBank = cellfun(@(vn)vn(7), cvn_imroTbl);
S.viRef = cellfun(@(vn)vn(8), cvn_imroTbl);
S.vrGain_ap = single(cellfun(@(vn)vn(9), cvn_imroTbl));
S.vrGain_lf = single(cellfun(@(vn)vn(10), cvn_imroTbl));
S.nSites_bank = cvn_imroTbl{1}(4);

Smeta1 = cSmeta{1};

% correct gain
nFiles = numel(S.viBank);
nSites = numel(Smeta1.viSites);
[mrScale_ap, mrScale_lf] = deal(ones(nSites, nFiles));
S.vcProbeSN = sprintf('1%d%d', Smeta1.imProbeSN, Smeta1.imProbeOpt);
% read gain correction
vrGainCorr = ones(1, S.nSites_bank*4);
if Smeta1.imProbeOpt ~= 2
    try    
        vcFile_csv = sprintf('%s1%d%d\\Gain correction.csv', vcDir_probe, Smeta1.imProbeSN, Smeta1.imProbeOpt);
        try
            vrGainCorr = csvread(vcFile_csv, 1, 1);
        catch
            vrGainCorr = csvread(vcFile_csv, 0, 0);
        end
    catch
        ;
    end
end

% build scale
for iFile = 1:nFiles
    vrGainCorr1 = vrGainCorr(Smeta1.viSites + double(S.nSites_bank*S.viBank(iFile)));
    mrScale_ap(:,iFile) = 1.2 * 1e6 / 2^10 / S.vrGain_ap(iFile) .* vrGainCorr1;
    mrScale_lf(:,iFile) = 1.2 * 1e6 / 2^10 / S.vrGain_lf(iFile) .* vrGainCorr1;
end
S.mrScale_ap = mrScale_ap;
S.mrScale_lf = mrScale_lf;
end %func


%--------------------------------------------------------------------------
% 122917 JJJ: Got rid of Tab which is slow
function plot_raster_(S0, fNewFig)
%plot_raster_()
%   plot if window open using curretnly selected clusters
%plot_raster_(P, iClu, S_clu)
%   Open window and plot specific clusters and S_clu

persistent hFig hFig_b
if nargin<2, fNewFig = 0; end
% import  trial time
% P = loadParam(vcFile_prm);
if ~isvalid_(hFig) && ~fNewFig, return; end
if nargin<1, S0 = get(0, 'UserData'); end
[P, S_clu, iCluCopy, iCluPaste] = deal(S0.P, S0.S_clu, S0.iCluCopy, S0.iCluPaste);
if isfield(P, 'vcFile_psth'), P.vcFile_trial = P.vcFile_psth; end % old field name

try
    if ~exist_file_(P.vcFile_trial), P.vcFile_trial = subsDir_(P.vcFile_trial, P.vcFile_prm); end
    if ~exist_file_(P.vcFile_trial)
        msgbox_(sprintf('File does not exist: vcFile_trial=%s', P.vcFile_trial), 1);
        return;
    end
    crTime_trial = loadTrial_(P.vcFile_trial);
catch
    return;
end
if ~iscell(crTime_trial), crTime_trial = {crTime_trial}; end
nstims = numel(crTime_trial);
if isempty(crTime_trial), msgbox('Trial file does not exist', 'modal'); return; end

[hFig, hFig_b] = create_figure_psth_(hFig, hFig_b, P, nstims);
plot_figure_psth_(hFig, iCluCopy, crTime_trial, S_clu, P);
if ~isempty(iCluPaste)
    set(hFig_b, 'Visible', 'on');
    plot_figure_psth_(hFig_b, iCluPaste, crTime_trial, S_clu, P);
else
    set(hFig_b, 'Visible', 'off');
end
end %func


%--------------------------------------------------------------------------
function plot_figure_psth_(hFig, iClu, crTime_trial, S_clu, P)
S_fig = get(hFig, 'UserData');
[vhAx1, vhAx2, vcColor] = deal(S_fig.vhAx1, S_fig.vhAx2, S_fig.vcColor);
for iStim = 1:numel(vhAx1)
    cla(vhAx1(iStim));
    cla(vhAx2(iStim));
    vrTime_trial = crTime_trial{iStim}; %(:,1);
    nTrials = numel(vrTime_trial);
    viTime_clu1 = S_clu_time_(S_clu, iClu);
    plot_raster_clu_(viTime_clu1, vrTime_trial, P, vhAx1(iStim));
    plot_psth_clu_(viTime_clu1, vrTime_trial, P, vhAx2(iStim), vcColor);
    title(vhAx2(iStim), sprintf('Cluster %d; %d trials', iClu, nTrials));
end
%     offset = offset + nTrials;
if numel(vhAx1)>2
    set(vhAx1(2:end),'xticklabel',{});
    for ax = vhAx1(2:end)
        xlabel(ax, '')
    end
end % end
end %func


%--------------------------------------------------------------------------
function [hFig, hFig_b] = create_figure_psth_(hFig, hFig_b, P, nStims)

% Figure handle for the iCluCopy
[axoffset, axlen] = deal(.08, 1/nStims);

if ~isvalid_(hFig)    
    hFig = create_figure_('FigTrial', [.5  .5 .35 .5], P.vcFile_trial, 0, 0);
    [vhAx1, vhAx2] = deal(nan(nStims, 1));
    for iStim = 1:nStims
        axoffset_ = axoffset + (iStim-1) * axlen;
        vhAx1(iStim) = axes('Parent', hFig, 'Position',[.08 axoffset_ .9 axlen*.68]);
        vhAx2(iStim) = axes('Parent', hFig, 'Position',[.08 axoffset_ + axlen*.68 .9 axlen*.2]);
    end
    vcColor = 'k';
    set(hFig, 'UserData', makeStruct_(vhAx1, vhAx2, vcColor));
end

% Figure handle for the iCluPaste
if ~isvalid_(hFig_b)
    hFig_b = create_figure_('FigTrial_b', [.5  0 .35 .5], P.vcFile_trial, 0, 0);
    set(hFig_b, 'Visible', 'off');
    [vhAx1, vhAx2] = deal(nan(nStims, 1));
    for iStim = 1:nStims
        axoffset_ = axoffset + (iStim-1) * axlen;
        vhAx1(iStim) = axes('Parent', hFig_b, 'Position',[.08 axoffset_ .9 axlen*.68]);
        vhAx2(iStim) = axes('Parent', hFig_b, 'Position',[.08 axoffset_ + axlen*.68 .9 axlen*.2]);
    end
    vcColor = 'r';
    set(hFig_b, 'UserData', makeStruct_(vhAx1, vhAx2, vcColor));
end
end %func


%--------------------------------------------------------------------------
function plot_psth_clu_(viTime_clu, vrTime_trial, P, hAx, vcColor)
if nargin<4, hAx=gca; end
if nargin<5, vcColor = 'k'; end

tbin = P.tbin_psth;
nbin = round(tbin * P.sRateHz);
nlim = round(P.tlim_psth/tbin);
viTime_Trial = round(vrTime_trial / tbin);

vlTime1=zeros(0);
vlTime1(ceil(double(viTime_clu)/nbin))=1;
mr1 = vr2mr2_(double(vlTime1), viTime_Trial, nlim);
vnRate = mean(mr1,2) / tbin;
vrTimePlot = (nlim(1):nlim(end))*tbin + tbin/2;
bar(hAx, vrTimePlot, vnRate, 1, 'EdgeColor', 'none', 'FaceColor', vcColor);
vrXTick = P.tlim_psth(1):(P.xtick_psth):P.tlim_psth(2);
set(hAx, 'XTick', vrXTick, 'XTickLabel', []);
grid(hAx, 'on');
hold(hAx, 'on'); 
plot(hAx, [0 0], get(hAx,'YLim'), 'r-');
ylabel(hAx, 'Rate (Hz)');
xlim_(hAx, P.tlim_psth);
end


%--------------------------------------------------------------------------
function plot_raster_clu_(viTime_clu, vrTime_trial, P, hAx)
if nargin<4, hAx=gca; end

trialLength = diff(P.tlim_psth); % seconds
nTrials = numel(vrTime_trial);
spikeTimes = cell(nTrials, 1);
t0 = -P.tlim_psth(1);
for iTrial = 1:nTrials
    rTime_trial1 = vrTime_trial(iTrial);
    vrTime_lim1 = rTime_trial1 + P.tlim_psth;
    vrTime_clu1 = double(viTime_clu) / P.sRateHz;
    vrTime_clu1 = vrTime_clu1(vrTime_clu1>=vrTime_lim1(1) & vrTime_clu1<vrTime_lim1(2));    
    vrTime_clu1 = (vrTime_clu1 - rTime_trial1 + t0) / trialLength;
    spikeTimes{iTrial} = vrTime_clu1';
end

% Plot
% hAx_pre = axes_(hAx);
plotSpikeRaster(spikeTimes,'PlotType','vertline','RelSpikeStartTime',0,'XLimForCell',[0 1], ...
    'LineFormat', struct('LineWidth', 1.5), 'hAx', hAx);
% axes_(hAx_pre);
ylabel(hAx, 'Trial #')
% title('Vertical Lines With Spike Offset of 10ms (Not Typical; for Demo Purposes)');
vrXTickLabel = P.tlim_psth(1):(P.xtick_psth):P.tlim_psth(2);
vrXTick = linspace(0,1,numel(vrXTickLabel));
set(hAx, {'XTick', 'XTickLabel'}, {vrXTick, vrXTickLabel});
grid(hAx, 'on');
hold(hAx, 'on'); 
plot(hAx, [t0,t0]/trialLength, get(hAx,'YLim'), 'r-');
xlabel(hAx, 'Time (s)');
end %func


%--------------------------------------------------------------------------
function mr = vr2mr2_(vr, viRow, spkLim, viCol)
if nargin<4, viCol = []; end
% JJJ 2015 Dec 24
% vr2mr2: quick version and doesn't kill index out of range
% assumes vi is within range and tolerates spkLim part of being outside
% works for any datatype

% prepare indices
if size(viRow,2)==1, viRow=viRow'; end %row
viSpk = int32(spkLim(1):spkLim(end))';
miRange = bsxfun(@plus, viSpk, int32(viRow));
miRange = min(max(miRange, 1), numel(vr));
if isempty(viCol)
    mr = vr(miRange); %2x faster
else
    mr = vr(miRange, viCol); %matrix passed to save time
end
end %func


%--------------------------------------------------------------------------
function hAx_prev = axes_(hAx)
hAx_prev = gca;
axes(hAx);
end


%--------------------------------------------------------------------------
function [viTime_spk, vrAmp_spk, viSite_spk] = spike_refrac_(viTime_spk, vrAmp_spk, viSite_spk, nRefrac)
% Remove smaller spikes if a bigger one detected within nRefrac
% spike_refrac_(viSpk, vrSpk, [], nRefrac)
% spike_refrac_(viSpk, vrSpk, viSite, nRefrac)
nRepeat_max = 10;
for iRepeat = 1:nRepeat_max
    if isempty(viTime_spk), return ;end
    vnDiff_spk = diff(diff(viTime_spk) <= nRefrac);
    viStart = find(vnDiff_spk > 0) + 1;
    viEnd = find(vnDiff_spk < 0) + 1;
    if isempty(viStart) || isempty(viEnd), return; end
    viEnd(viEnd < viStart(1)) = [];
    if isempty(viEnd), return; end
    viStart(viStart > viEnd(end)) = [];
    nGroup = numel(viStart);
    if nGroup==0, return; end
    assert_(nGroup == numel(viEnd), 'spike_refrac_:nStart==nEnd');    
    vlRemove = false(size(viTime_spk));
    
    for iGroup = 1:nGroup
        vi_ = viStart(iGroup):viEnd(iGroup);
        [~, imax_] = max(vrAmp_spk(vi_));
        vlRemove(vi_(imax_)) = true;
    end
    viTime_spk(vlRemove) = [];
    if ~isempty(vrAmp_spk), vrAmp_spk(vlRemove) = []; end
    if ~isempty(viSite_spk), viSite_spk(vlRemove) = []; end
end
end %func


%--------------------------------------------------------------------------
function [viSpk, vrSpk, viSite] = spike_refrac__(viSpk, vrSpk, viSite, nRefrac)
% Remove smaller spikes if a bigger one detected within nRefrac
% spike_refrac_(viSpk, vrSpk, [], nRefrac)
% spike_refrac_(viSpk, vrSpk, viSite, nRefrac)

nSkip_refrac = 8;
% remove refractory period
vlKeep = true(size(viSpk));
% if isGpu_(viSpk), vlKeep = gpuArray_(vlKeep); end
while (1)
    viKeep1 = find(vlKeep);
    viRefrac1 = find(diff(viSpk(viKeep1)) <= nRefrac);
    if isempty(viRefrac1), break; end
    
    vi1 = viRefrac1(1:nSkip_refrac:end);     
    viRemoveA = viKeep1(vi1);
    viRemoveB = viKeep1(vi1+1);   
    if ~isempty(vrSpk)
        vl1 = abs(vrSpk(viRemoveA)) < abs(vrSpk(viRemoveB));
        vlKeep(viRemoveA(vl1)) = 0;
        vlKeep(viRemoveB(~vl1)) = 0;
    else
        vlKeep(viRemoveB) = 0;
    end
end

viSpk(~vlKeep) = [];
if ~isempty(vrSpk), vrSpk(~vlKeep) = []; end
if ~isempty(viSite), viSite(~vlKeep) = []; end
end %func


%--------------------------------------------------------------------------
function export_jrc1_(vcFile_prm)
% Export to version 1 format (_clu.mat) and (_evt.mat)
% error('export_jrc1_: not implemented yet');
% Load info from previous version: time, site, spike
P = loadParam_(vcFile_prm);
S0 = load(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));

fprintf('Exporting to IronClust ver.1 format\n');
% Build Sevt and save
Sevt = S0;
Sevt = rmfield_(Sevt, 'S_clu', 'cmrFet_site', 'cvrTime_site', 'cvrVpp_site', ...
    'dimm_raw', 'dimm_spk', 'miSites_fet', 'mrFet', 'runtime_detect', 'runtime_sort', ...
    'viSite_spk', 'viT_offset_file', 'viTime_spk', 'vrAmp_spk');
Sevt.cvrSpk_site = vr2cell_(S0.vrAmp_spk, S0.cviSpk_site); %S0.cvrVpp_site;
% Sevt.miSites_fet = S0.miSites_fet;
[Sevt.mrPv, Sevt.mrWav_spk, Sevt.trFet] = deal([]);
Sevt.viSite = S0.viSite_spk;
Sevt.viSpk = S0.viTime_spk;
Sevt.vrSpk = S0.vrAmp_spk;
Sevt.vrThresh_uV = bit2uV_(S0.vrThresh_site, S0.P);
Sevt.dimm_fet = [1, S0.dimm_fet(:)'];
write_struct_(strrep(P.vcFile_prm, '.prm', '_evt.mat'), Sevt);
fprintf('\tEvent struct (Sevt) exported.\n\t');
assignWorkspace_(Sevt);

% S_clu
if isfield(S0, 'S_clu')
    Sclu = S0.S_clu;
    Sclu = rmfield_(Sclu, 'tmrWav_raw_clu', 'tmrWav_spk_clu', 'trWav_raw_clu', 'trWav_spk_clu', 'viSite_min_clu', 'vrVmin_clu');
    Sclu.trWav_dim = [];
    Sclu.viSite = S0.viSite_spk;
    Sclu.viTime = S0.viTime_spk;
    Sclu.vrSnr_Vmin_clu = S0.S_clu.vrSnr_clu;
    write_struct_(strrep(P.vcFile_prm, '.prm', '_clu.mat'), Sclu);
    fprintf('\tCluster struct (Sclu) exported.\n\t');
    assignWorkspace_(Sclu);
end
end %func


%--------------------------------------------------------------------------
function cvr = vr2cell_(vr, cvi)
cvr = cellfun(@(vi)vr(vi), cvi, 'UniformOutput', 0);
end %func


%--------------------------------------------------------------------------
function [S_clu, S0] = S_clu_new_(arg1, S0)
% S_clu = S_clu_new_(S_clu, S0)
% S_clu = S_clu_new_(viClu, S0)

if nargin<2, S0 = get(0, 'UserData'); end
% S_clu = S0.S_clu;
% if ~isstruct(arg1), S_clu = struct(); end
S_clu = get_(S0, 'S_clu'); %previous S_clu
if isempty(S_clu), S_clu = struct(); end
if ~isstruct(arg1)
    S_clu.viClu = arg1; %skip FigRD step for imported cluster
else
    S_clu = struct_merge_(S_clu, arg1);
end
S_clu.viClu = int32(S_clu.viClu);
S_clu = S_clu_refresh_(S_clu, 1, S0.viSite_spk);
S_clu = S_clu_update_wav_(S_clu, S0.P, S0);
S_clu = S_clu_position_(S_clu);
if ~isfield(S_clu, 'csNote_clu')
    S_clu.csNote_clu = cell(S_clu.nClu, 1);  %reset note
end
S_clu = S_clu_quality_(S_clu, S0.P);
[S_clu, S0] = S_clu_commit_(S_clu, 'S_clu_new_');
end %func


%--------------------------------------------------------------------------
function [mr, vi_shuffle] = shuffle_static_(mr, dimm)
% dimm = 1 or 2 (dimension to shuffle
if nargin<2, dimm=1; end
fStatic = 1;
if fStatic
    s = RandStream('mt19937ar','Seed',0); %always same shuffle order
    switch dimm
        case 1
            vi_shuffle = randperm(s, size(mr,1));
            mr = mr(vi_shuffle, :);
        case 2
            vi_shuffle = randperm(s, size(mr,2));
            mr = mr(:, vi_shuffle);
    end
else
    switch dimm
        case 1
            mr = mr(randperm(size(mr,1)), :);
        case 2
            mr = mr(:, randperm(size(mr,2)));
    end
end
end %func


%--------------------------------------------------------------------------
function [allScores, allFPs, allMisses, allMerges] = compareClustering2_(cluGT, resGT, cluTest, resTest)
% function compareClustering(cluGT, resGT, cluTest, resTest[, datFilename])
% - clu and res variables are length nSpikes, for ground truth (GT) and for
% the clustering to be evaluated (Test). 
% kilosort, Marius Pachitariu, 2016-dec-21

t1 = tic; fprintf('kilosort-style ground truth validation\n\t');
[cluGT, cluTest, resTest] = multifun_(@double, cluGT, cluTest, resTest);
resGT = int64(resGT);
GTcluIDs = unique(cluGT);
testCluIDs = unique(cluTest);
jitter = 12;

nSp = zeros(max(testCluIDs), 1);
for j = 1:max(testCluIDs)
    nSp(j) = max(1, sum(cluTest==j));
end
nSp0 = nSp;

for cGT = 1:length(GTcluIDs)
    rGT = int32(resGT(cluGT==GTcluIDs(cGT)));
    S = spalloc(numel(rGT), max(testCluIDs), numel(rGT) * 10);
    % find the initial best match
    mergeIDs = [];
    scores = [];
    falsePos = [];
    missRate = [];
    
    igt = 1;
    
    nSp = nSp0;
    nrGT = numel(rGT);
    flag = false;
    for j = 1:numel(cluTest)
        while (resTest(j) > rGT(igt) + jitter)
            % the curent spikes is now too large compared to GT, advance the GT
            igt = igt + 1;
            if igt>nrGT
               flag = true;
               break;
            end
        end
        if flag, break; end        
        if resTest(j)>rGT(igt)-jitter
            % we found a match, add a tick to the right cluster
              S(igt, cluTest(j)) = 1;
        end
    end
    numMatch = sum(S,1)';
    misses = (nrGT-numMatch)/nrGT; % missed these spikes, as a proportion of the total true spikes
    fps = (nSp-numMatch)./nSp; % number of comparison spikes not near a GT spike, as a proportion of the number of guesses

    sc = 1-(fps+misses);
    best = find(sc==max(sc),1);
    mergeIDs(end+1) = best;
    scores(end+1) = sc(best);
    falsePos(end+1) = fps(best);
    missRate(end+1) = misses(best);
    
%     fprintf(1, '  found initial best %d: score %.2f (%d spikes, %.2f FP, %.2f miss)\n', ...
%         mergeIDs(1), scores(1), sum(cluTest==mergeIDs(1)), fps(best), misses(best));
    
    S0 = S(:, best);
    nSp = nSp + nSp0(best);
    while scores(end)>0 && (length(scores)==1 || ( scores(end)>(scores(end-1) + 1*0.01) && scores(end)<=0.99 ))
        % find the best match
        S = bsxfun(@max, S, S0);
        
        numMatch = sum(S,1)';
        misses = (nrGT-numMatch)/nrGT; % missed these spikes, as a proportion of the total true spikes
        fps = (nSp-numMatch)./nSp; % number of comparison spikes not near a GT spike, as a proportion of the number of guesses
        
        sc = 1-(fps+misses);
        best = find(sc==max(sc),1);
        mergeIDs(end+1) = best;
        scores(end+1) = sc(best);
        falsePos(end+1) = fps(best);
        missRate(end+1) = misses(best);
        
%         fprintf(1, '    best merge with %d: score %.2f (%d/%d new/total spikes, %.2f FP, %.2f miss)\n', ...
%             mergeIDs(end), scores(end), nSp0(best), nSp(best), fps(best), misses(best));
        
        S0 = S(:, best);
        nSp = nSp + nSp0(best);
                
    end
    
    if length(scores)==1 || scores(end)>(scores(end-1)+0.01)
        % the last merge did help, so include it
        allMerges{cGT} = mergeIDs(1:end);
        allScores{cGT} = scores(1:end);
        allFPs{cGT} = falsePos(1:end);
        allMisses{cGT} = missRate(1:end);
    else
        % the last merge actually didn't help (or didn't help enough), so
        % exclude it
        allMerges{cGT} = mergeIDs(1:end-1);
        allScores{cGT} = scores(1:end-1);
        allFPs{cGT} = falsePos(1:end-1);
        allMisses{cGT} = missRate(1:end-1);
    end
    fprintf('.');
end

initScore = zeros(1, length(GTcluIDs));
finalScore = zeros(1, length(GTcluIDs));
numMerges = zeros(1, length(GTcluIDs));
fprintf(1, 'Validation score (Kilosort-style)\n'); 
for cGT = 1:length(GTcluIDs)
     initScore(cGT) = allScores{cGT}(1);
     finalScore(cGT) = allScores{cGT}(end);
     numMerges(cGT) = length(allScores{cGT})-1;
end
finalScores = cellfun(@(x) x(end), allScores);
nMerges = cellfun(@(x) numel(x)-1, allMerges);

fprintf(1, '\tmedian initial score: %.2f; median best score: %.2f\n', median(initScore), median(finalScore));
fprintf(1, '\ttotal merges required: %d\n', sum(numMerges));
fprintf('\t%d / %d good cells, score > 0.8 (pre-merge) \n', sum(cellfun(@(x) x(1), allScores)>.8), numel(allScores))
fprintf('\t%d / %d good cells, score > 0.8 (post-merge) \n', sum(cellfun(@(x) x(end), allScores)>.8), numel(allScores))
fprintf('\tMean merges per good cell %2.2f \n', mean(nMerges(finalScores>.8)))
fprintf('\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function S_ksort = kilosort_(vcFile_prm)
% Run Kilosort
fSavePhy = 1;
fMerge_post = 1;
if ischar(vcFile_prm)
    fprintf('Running kilosort on %s\n', vcFile_prm); 
    P = loadParam_(vcFile_prm);
    if isempty(P), return; end
else
    P = vcFile_prm;
    vcFile_prm = P.vcFile_prm;
    fprintf('Running kilosort on %s\n', vcFile_prm); 
end
runtime_ksort = tic;

% Run kilosort
[fpath, ~, ~] = fileparts(vcFile_prm);
ops = kilosort('config', P); %get config
S_chanMap = kilosort('chanMap', P); %make channel map

[rez, DATA, uproj] = kilosort('preprocessData', ops); % preprocess data and extract spikes for initialization
rez                = kilosort('fitTemplates', rez, DATA, uproj);  % fit templates iteratively
rez                = kilosort('fullMPMU', rez, DATA);% extract final spike times (overlapping extraction)

if fMerge_post
    rez = kilosort('merge_posthoc2', rez); %ask whether to merge or not
end

% save python results file for Phy
if fSavePhy
    try
        kilosort('rezToPhy', rez, fpath); %path to npy2mat needed
    catch
        disperr_();
    end
end

runtime_ksort = toc(runtime_ksort);
fprintf('\tkilosort took %0.1fs for %s\n', runtime_ksort, P.vcFile_prm);

% output kilosort result
S_ksort = struct('rez', rez, 'P', P, 'runtime_ksort', runtime_ksort);
struct_save_(S_ksort, strrep(vcFile_prm, '.prm', '_ksort.mat'), 1);
end %func


%--------------------------------------------------------------------------
function struct_save_(S, vcFile, fVerbose)
% 7/13/17 JJJ: Version check routine
nRetry = 3;
if nargin<3, fVerbose = 0; end
if fVerbose
    fprintf('Saving a struct to %s...\n', vcFile); t1=tic;
end
version_year = version('-release');
version_year = str2double(version_year(1:end-1));
if version_year >= 2017
    for iRetry=1:nRetry
        try
            save(vcFile, '-struct', 'S', '-v7.3', '-nocompression'); %faster    
            break;
        catch
            pause(.5);
        end
        fprintf(2, 'Saving failed: %s\n', vcFile);
    end
else    
    for iRetry=1:nRetry
        try
            save(vcFile, '-struct', 'S', '-v7.3');   
            break;
        catch
            pause(.5);
        end
        fprintf(2, 'Saving failed: %s\n', vcFile);
    end    
end
if fVerbose
    fprintf('\ttook %0.1fs.\n', toc(t1));
end
end %func


%--------------------------------------------------------------------------
function export_imec_sync_(vcFiles_prm)
% sync output for IMEC (export the last channel entries)
try
    P = file2struct_(vcFiles_prm);
    vcFile_bin = P.vcFile;    
    fid = fopen(vcFile_bin, 'r');
    vnSync = fread(fid, inf, '*uint16'); fclose(fid);
    vnSync = vnSync(P.nChans:P.nChans:end); %subsample sync channel
    assignWorkspace_(vnSync);
catch
    fprintf(2, 'error exporting sync: %s\n', lasterr());
end
end


%--------------------------------------------------------------------------
function plot_activity_(P) % single column only
% plot activity as a function of depth and time
global fDebug_ui

tbin = 10; %activity every 10 sec
% plot activity as a function of time
% vcFile_evt = subsFileExt(P.vcFile_prm, '_evt.mat');
S0 = load_cached_(P, 0); %do not load waveforms
nSites = numel(P.viSite2Chan);
% tdur = max(cell2mat_(cellfun(@(x)double(max(x)), Sevt.cviSpk_site, 'UniformOutput', 0))) / P.sRateHz;
tdur = double(max(S0.viTime_spk)) / P.sRateHz; % in sec
nTime = ceil(tdur / tbin);

mrAmp90 = zeros(nTime, nSites);
lim0 = [1, tbin * P.sRateHz];
for iSite=1:nSites
    viSpk1 = find(S0.viSite_spk == iSite);
    vrAmp_spk1 = S0.vrAmp_spk(viSpk1); % % S0.cvrSpk_site{iSite};  %spike amplitude   
    if isempty(vrAmp_spk1), continue; end
    viTime_spk1 = S0.viTime_spk(viSpk1);
    for iTime=1:nTime
        lim1 = lim0 + (iTime-1) * lim0(2);
        vrAmp_spk11 = vrAmp_spk1(viTime_spk1 >= lim1(1) & viTime_spk1 <= lim1(2));
        if isempty(vrAmp_spk11),  continue; end
        mrAmp90(iTime, iSite) = quantile(abs(vrAmp_spk11), .9);
    end
end %for
mrAmp90=mrAmp90';

vlSite_left = P.mrSiteXY(:,1) == 0;
vrSiteY = P.mrSiteXY(:,2);
hFig = create_figure_('FigActivity', [0 0 .5 1], P.vcFile_prm, 1, 1);
subplot 121; imagesc(mrAmp90(vlSite_left, :), 'XData', (1:nTime) * tbin, 'YData', vrSiteY(vlSite_left)); axis xy; xlabel('Time'); ylabel('Sites'); title('Left edge sites');
subplot 122; imagesc(mrAmp90(~vlSite_left, :), 'XData', (1:nTime) * tbin, 'YData', vrSiteY(~vlSite_left)); axis xy; xlabel('Time'); ylabel('Sites'); title('Right edge sites');

[~, iSite_center] = max(mean(mrAmp90,2)); 
viSiteA = iSite_center + [-2:2]; %look neighbors
mrAmp90a = mrAmp90(viSiteA, :);
vrCentroid = bsxfun(@rdivide, sum(bsxfun(@times, mrAmp90a.^2, vrSiteY(viSiteA))), sum(mrAmp90a.^2));
hold on; plot((1:nTime) * tbin, vrCentroid, 'r');

% if get_set_([], 'fDebug_ui', 0), close(hFig); end
if fDebug_ui==1, close(hFig); end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: multiple targeting copy file. Tested
function copyfile__(csFiles, vcDir_dest)
% copyfile_(vcFile, vcDir_dest)
% copyfile_(csFiles, vcDir_dest)
% copyfile_(csFiles, csDir_dest)

% Recursion if cell is used
if iscell(vcDir_dest)
    csDir_dest = vcDir_dest;
    for iDir = 1:numel(csDir_dest)
        try
            copyfile_(csFiles, csDir_dest{iDir});
        catch
            disperr_();
        end
    end
    return;
end

if ischar(csFiles), csFiles = {csFiles}; end
for iFile=1:numel(csFiles)
    vcPath_from_ = csFiles{iFile};
    if exist(vcPath_from_, 'dir') == 7        
        [vcPath_,~,~] = fileparts(vcPath_from_);
        vcPath_from_ =  sprintf('%s%s*', vcPath_, filesep());
        vcPath_to_ = sprintf('%s%s%s%s', vcDir_dest, filesep(), vcPath_, filesep());
        if exist(vcPath_to_, 'dir') ~= 7, mkdir(vcPath_to_); end    
        disp([vcPath_from_, '; ', vcPath_to_]);
    else
        vcPath_to_ = vcDir_dest;
        if exist(vcPath_to_, 'dir') ~= 7
            mkdir(vcPath_to_); 
            disp(['Created a folder ', vcPath_to_]);
        end
    end
    try   
        vcEval1 = sprintf('copyfile ''%s'' ''%s'' f;', vcPath_from_, vcPath_to_);
        eval(vcEval1);
        fprintf('\tCopied %s to %s\n', vcPath_from_, vcPath_to_);
    catch
        fprintf(2, '\tFailed to copy %s\n', vcPath_from_);
    end
end
end %func


%--------------------------------------------------------------------------
% 11/5/17 JJJ: added vcDir_from
% 9/26/17 JJJ: multiple targeting copy file. Tested
function copyfile_(csFiles, vcDir_dest, vcDir_from)
% copyfile_(vcFile, vcDir_dest)
% copyfile_(csFiles, vcDir_dest)
% copyfile_(csFiles, csDir_dest)

if nargin<3, vcDir_from = ''; end
% Recursion if cell is used
if iscell(vcDir_dest)
    csDir_dest = vcDir_dest;
    for iDir = 1:numel(csDir_dest)
        try
            copyfile_(csFiles, csDir_dest{iDir});
        catch
            disperr_();
        end
    end
    return;
end

if ischar(csFiles), csFiles = {csFiles}; end
for iFile=1:numel(csFiles)
    vcPath_from_ = csFiles{iFile};   
    if ~isempty(vcDir_from), vcPath_from_ = fullfile(vcDir_from, vcPath_from_); end
    if exist_dir_(vcPath_from_)
        [vcPath_,~,~] = fileparts(vcPath_from_);
        vcPath_from_ =  sprintf('%s%s*', vcPath_, filesep());
        vcPath_to_ = sprintf('%s%s%s', vcDir_dest, filesep(), dir_filesep_(csFiles{iFile}));
        mkdir_(vcPath_to_);    
%         disp([vcPath_from_, '; ', vcPath_to_]);
    else
        vcPath_to_ = vcDir_dest;
        fCreatedDir_ = mkdir_(vcPath_to_); 
        if fCreatedDir_          
            disp(['Created a folder ', vcPath_to_]);
        end
    end    
    try   
        vcEval1 = sprintf('copyfile ''%s'' ''%s'' f;', vcPath_from_, vcPath_to_);
        eval(vcEval1);
        fprintf('\tCopied ''%s'' to ''%s''\n', vcPath_from_, vcPath_to_);
    catch
        fprintf(2, '\tFailed to copy ''%s''\n', vcPath_from_);
    end
end
end %func


%--------------------------------------------------------------------------
% 11/5/17 JJJ: Created
function vc = dir_filesep_(vc)
% replace the file seperaation characters
if isempty(vc), return; end
vl = vc == '\' | vc == '/';
if any(vl), vc(vl) = filesep(); end
end %func


%--------------------------------------------------------------------------
% 12/5/17 JJJ: Colors are hard coded
% 9/17/17 JJJ: nGroups fixed, can have less than 7 clusters
function vhPlot = plot_group_(hAx, mrX, mrY, varargin)
mrColor = [0, 0.4470, 0.7410; 0.8500, 0.3250, 0.0980; 0.9290, 0.6940, 0.1250; 0.4940, 0.1840, 0.5560; 0.4660, 0.6740, 0.1880; 0.3010, 0.7450, 0.9330; 0.6350, 0.0780, 0.1840]';
nGroups = min(size(mrColor,2), size(mrX,2));
mrColor = mrColor(:,1:nGroups);
vhPlot = zeros(nGroups, 1);
hold(hAx, 'on');
for iGroup=1:nGroups
    vrX1 = mrX(:, iGroup:nGroups:end);
    vrY1 = mrY(:, iGroup:nGroups:end);
    vhPlot(iGroup) = plot(hAx, vrX1(:), vrY1(:), varargin{:}, 'Color', mrColor(:,iGroup)');
end
end %func



%--------------------------------------------------------------------------
function plot_update_(vhPlot, mrX, mrY)
nPlots = numel(vhPlot);
for iPlot=1:nPlots
    vrX1 = mrX(:, iPlot:nPlots:end);
    vrY1 = mrY(:, iPlot:nPlots:end);
    set(vhPlot(iPlot), 'XData', vrX1(:), 'YData', vrY1(:));
end
end %func


%--------------------------------------------------------------------------
function varargout = gather_(varargin)
for i=1:nargin
    varargout{i} = varargin{i};
    if isa(varargin{i}, 'gpuArray')
        try
            varargout{i} = gather(varargin{i});
        catch
            ;
        end
    end
end
end %func


%--------------------------------------------------------------------------
function vc = set_(vc, varargin)
% Set handle to certain values
% set_(S, name1, val1, name2, val2)

if isempty(vc), return; end
if isstruct(vc)
    for i=1:2:numel(varargin)        
        vc.(varargin{i}) = varargin{i+1};
    end
    return;
end
if iscell(vc)
    for i=1:numel(vc)
        try
            set(vc{i}, varargin{:});
        catch
        end
    end
elseif numel(vc)>1
    for i=1:numel(vc)
        try
            set(vc(i), varargin{:});
        catch
        end
    end
else
    try
        set(vc, varargin{:});
    catch
    end 
end
end %func


%--------------------------------------------------------------------------
function vr = tnWav2uV_(vn, P, fMeanSubt)
% Integrate the waveform
if nargin<3, fMeanSubt=1; end
if nargin<2, P = get0_('P'); end
vr = bit2uV_(vn, P);
% if P.nDiff_filt>0, 
if fMeanSubt, vr = meanSubt_(vr); end
% end
end %func


%--------------------------------------------------------------------------
function export_spkwav_(P, vcArg2, fDiff)
% Export spike waveforms organized by clusters
% export_spkwav_(P)
% export_spkwav_(P, viClu)
global fDebug_ui

if nargin<2, vcArg2 = ''; end
if nargin<3, fDiff = 0; end
if isempty(vcArg2)
    viClu = [];
    fPlot = 0;
else
    viClu = str2num(vcArg2);
    if isempty(viClu), fprintf(2, 'Invalid Cluster #: %s', vcArg2); end
    fPlot = numel(viClu)==1;
end

% Load data
S0 = load_cached_(P);
if isempty(S0), fprintf(2, 'Not clustered yet'); return; end
if ~isfield(S0, 'S_clu'), fprintf(2, 'Not clustered yet'); return; end
S_clu = S0.S_clu;

% Collect waveforms by clusters
ctrWav_clu = cell(1, S_clu.nClu);
miSite_clu = P.miSites(:,S_clu.viSite_clu);
fprintf('Collecting spikes from clusters\n\t'); t1=tic;
if isempty(viClu), viClu = 1:S_clu.nClu; end
for iClu = viClu
    tnWav_clu1 = tnWav_spk_sites_(S_clu.cviSpk_clu{iClu}, miSite_clu(:,iClu), S0);
    if fDiff
        ctrWav_clu{iClu} = tnWav_clu1;
    else
        ctrWav_clu{iClu} = tnWav2uV_(tnWav_clu1, P);
    end
%     ctrWav_clu{iClu} = (cumsum(bit2uV_(meanSubt_(tnWav_clu1))));
%     ctrWav_clu{iClu} = (bit2uV_(meanSubt_(tnWav_clu1)));
    fprintf('.');
end
fprintf('\n\ttook %0.1fs\n', toc(t1));

if fPlot
    iClu = viClu;
    nT_spk = (diff(P.spkLim)+1);
    nSpk1 = S_clu.vnSpk_clu(iClu);
    hFig = create_figure_(sprintf('Fig_clu%d', iClu), [0 0 .5 1], P.vcFile_prm, 1, 1);
    multiplot([], P.maxAmp, [], ctrWav_clu{iClu}, miSite_clu(:,iClu));
    xlabel('Spike #'); ylabel('Site #'); 
    set(gca, 'YTick', range_(miSite_clu(:,iClu)), ...
        'XTick', (1:nSpk1) * nT_spk - P.spkLim(2), 'XTickLabel', 1:nSpk1); 
    axis_([0, nSpk1*nT_spk+1, (limit_(miSite_clu(:,iClu)) + [-1,1])]);
    grid on;
    title(sprintf('Cluster%d (n=%d), Scale=%0.1f uV', iClu, nSpk1, P.maxAmp)); 
    mouse_figure(hFig);
    eval(sprintf('trWav_clu%d = ctrWav_clu{iClu};', iClu));
    eval(sprintf('viSites_clu%d = miSite_clu(:,iClu);', iClu));
    eval(sprintf('assignWorkspace_(trWav_clu%d, viSites_clu%d);', iClu, iClu));
%     if get_set_([], 'fDebug_ui', 0), close_(hFig); end
    if fDebug_ui==1, close_(hFig); end
else
    assignWorkspace_(ctrWav_clu, miSite_clu);
end
end %func


%--------------------------------------------------------------------------
function range1 = range_(vn)
vn = vn(:);
range1 = min(vn):max(vn);
end


%--------------------------------------------------------------------------
function limit1 = limit_(vn)
vn = vn(:);
limit1 = [min(vn), max(vn)];
end


%--------------------------------------------------------------------------
function try_eval_(vcEval1, fVerbose)
if nargin<2, fVerbose = 1; end
try 
    eval(vcEval1); 
    fprintf('\t%s\n', vcEval1);  
catch
    if fVerbose
        fprintf(2, '\tError evaluating ''%s''\n', vcEval1);  
    end
end
end %func


%--------------------------------------------------------------------------
function export_spkamp_(P, vcArg2)
% export spike amplitudes (Vpp, Vmin, Vmax) in uV to workspace, organize by clusters

if nargin<2, vcArg2 = ''; end
if isempty(vcArg2)
    viClu = [];
    fSingleUnit = 0;
else
    viClu = str2num(vcArg2);
    if isempty(viClu), fprintf(2, 'Invalid Cluster #: %s', vcArg2); end
    fSingleUnit = numel(viClu)==1;
end

% Load data
S0 = load_cached_(P);
if isempty(S0), fprintf(2, 'Not clustered yet'); return; end
if ~isfield(S0, 'S_clu'), fprintf(2, 'Not clustered yet'); return; end
S_clu = S0.S_clu;

% Collect waveforms by clusters
[cmrVpp_clu, cmrVmin_clu, cmrVmax_clu] = deal(cell(1, S_clu.nClu));
miSite_clu = P.miSites(:,S_clu.viSite_clu);
fprintf('Calculating spike amplitudes from clusters\n\t'); t1=tic;
if isempty(viClu), viClu = 1:S_clu.nClu; end
for iClu = viClu
    trWav_clu1 = tnWav2uV_(tnWav_spk_sites_(S_clu.cviSpk_clu{iClu}, miSite_clu(:,iClu), S0), P);
    cmrVmin_clu{iClu} = shiftdim(min(trWav_clu1));
    cmrVmax_clu{iClu} = shiftdim(max(trWav_clu1));
    cmrVpp_clu{iClu} = cmrVmax_clu{iClu} - cmrVmin_clu{iClu};
    fprintf('.');
end
fprintf('\n\ttook %0.1fs\n', toc(t1));

% export to workspace
if fSingleUnit
    iClu = viClu;
    eval(sprintf('mrVmax_clu%d = cmrVmax_clu{iClu};', iClu));
    eval(sprintf('mrVmin_clu%d = cmrVmin_clu{iClu};', iClu));
    eval(sprintf('mrVpp_clu%d = cmrVpp_clu{iClu};', iClu));
    eval(sprintf('viSites_clu%d = miSite_clu(:,iClu);', iClu));
    eval(sprintf('assignWorkspace_(mrVmax_clu%d, mrVmin_clu%d, mrVpp_clu%d, viSites_clu%d);', iClu, iClu, iClu, iClu)); 
else
    assignWorkspace_(cmrVpp_clu, cmrVmax_clu, cmrVmin_clu, miSite_clu);
end
end %func


%--------------------------------------------------------------------------
function csFiles_bin = dir_files_(csFile_merge, vcFile_txt, file_sort_merge)
% Display binary files
if nargin<2, vcFile_txt=''; end
if nargin<3, file_sort_merge = []; end
if isempty(file_sort_merge)
    file_sort_merge = 1; 
elseif ischar(file_sort_merge)
    file_sort_merge = str2double(file_sort_merge);
end

if isempty(csFile_merge)
    fprintf('No files to merge ("csFile_merge" is empty).\n');
    csFiles_bin = {}; return; 
end
% fprintf('Listing files to merge ("csFile_merge"):\n');
csFiles_bin = filter_files_(csFile_merge, file_sort_merge);
if nargout==0
%     arrayfun(@(i)fprintf('%d: %s\n', i, csFiles_bin{i}), 1:numel(csFiles_bin), 'UniformOutput', 0);
    arrayfun(@(i)fprintf('%s\n', csFiles_bin{i}), 1:numel(csFiles_bin), 'UniformOutput', 0);
end
if ~isempty(vcFile_txt)
    cellstr2file_(vcFile_txt, csFiles_bin);
    fprintf('%s is created.\n', vcFile_txt);
    edit_(vcFile_txt);
end
end %func


%--------------------------------------------------------------------------
function commit_irc_(S_cfg, vcDir_out, fZipFile)
global fDebug_ui

if nargin<1, S_cfg = []; end 
if nargin<2, vcDir_out = []; end
if nargin<3, fZipFile = 0; end

if isempty(S_cfg), S_cfg = read_cfg_(); end

fDebug_ui = 0;
set0_(fDebug_ui);

vcDir_out = fullfile(vcDir_out, filesep());
disp(['Commiting to ', vcDir_out]);

copyfile_(S_cfg.sync_list, vcDir_out); %destination root
copyfile_(S_cfg.csFiles_cuda, vcDir_out); %destination root
csFiles_ptx = strrep(S_cfg.csFiles_cuda, '.cu', '.ptx');
copyfile_(csFiles_ptx, vcDir_out); %destination root

% Zip 
if fZipFile
    hMsg = msgbox_(sprintf('Archiving to %s', [vcDir_out, 'irc.zip']));
    t1 = tic;
    [csFiles_irc_full, csFiles_irc] = dir_([vcDir_out, '*'], 'irc.zip');
    zip([vcDir_out, 'irc.zip'], csFiles_irc, vcDir_out);
    fprintf('Zip file creation took %0.1f\n', toc(t1));
    close_(hMsg);    
    msgbox_('Update the Dropbox link for www.ironclust.org');
end
end %func


%--------------------------------------------------------------------------
function fCreatedDir = mkdir_(vcDir)
% make only if it doesn't exist. provide full path for dir
fCreatedDir = exist_dir_(vcDir);
if ~fCreatedDir
    try
        mkdir(vcDir); 
    catch
        fCreatedDir = 0;
    end
end
end %func


%--------------------------------------------------------------------------
function [csFiles_full, csFiles] = dir_(vcFilter_dir, csExcl)
% return name of files full path, exclude files
if nargin>=2
    if ischar(csExcl), csExcl = {csExcl}; end
    csExcl = union(csExcl, {'.', '..'}); 
else
    csExcl = [];
end
S_dir = dir(vcFilter_dir);
csFiles  = {S_dir.('name')};
[csFiles, viKeep_file] = setdiff_(csFiles, csExcl);

% combine directory path
try
    csDir = {S_dir.('folder')}; % older matlab doesn't support this
    csDir = csDir(viKeep_file);
    csFiles_full = cellfun(@(vc1,vc2)[vc1, filesep(), vc2], csDir, csFiles, 'UniformOutput', 0);
catch
    [vcDir, ~, ~] = fileparts(vcFilter_dir);
    if isempty(vcDir), vcDir='.'; end
    csFiles_full = cellfun(@(vc)[vcDir, filesep(), vc], csFiles, 'UniformOutput', 0);
end
end %func


%--------------------------------------------------------------------------
% 8/9/2018 JJJ: 
function [vr, viKeep] = setdiff_(vr, vr_excl)
if ~isempty(vr_excl)    
    [vr, viKeep] = setdiff(vr, vr_excl);
else
    viKeep = 1:numel(vr);
end
end %func


%--------------------------------------------------------------------------
function delete_(csFiles)
if ischar(csFiles), csFiles = {csFiles}; end
for i=1:numel(csFiles)
    try
        if iscell(csFiles)
            delete(csFiles{i});
        else
            delete(csFiles(i));
        end
    catch
%         disperr_();
    end
end
end %func


%--------------------------------------------------------------------------
function export_fet_(P)
% export feature matrix to workspace
S0 = load(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
trFet = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet);
assignWorkspace_(trFet);
end %func


%--------------------------------------------------------------------------
function varargout = getfield_(S, varargin)
for iField = 1:numel(varargin)
    if isfield(S, varargin{iField})
        varargout{iField} = getfield(S, varargin{iField});
    else
        varargout{iField} = [];
    end
end
end %func


%--------------------------------------------------------------------------
function [mrFet, vrY_pre, vrY_post] = drift_correct_(mrFet, P) % drift correction
% Manually correct drift using {[t1,t2,d1,d2], ...} format in cvrDepth_drift
% mrFet last column contains the y coordinate
fPlot_drift = 1;
if isempty(getfield_(P, 'cvrDepth_drift')), return; end
S0 = get(0, 'UserData');
fprintf('Correcting drift\n\t'); t1=tic;
vrY_pre = mrFet(end,:);
vrY_post = vrY_pre;
for iDrift = 1:numel(P.cvrDepth_drift)
    tlim_dlim1 = P.cvrDepth_drift{iDrift};
    tlim1 = tlim_dlim1(1:2) * P.sRateHz;
    dlim1 = tlim_dlim1(3:4);
    viSpk1 = find(S0.viTime_spk >= tlim1(1) & S0.viTime_spk < tlim1(2));
    if isempty(viSpk1), continue; end
    viTime_spk1 = S0.viTime_spk(viSpk1);
    if diff(dlim1) == 0
        vrY_post(viSpk1) = vrY_pre(viSpk1) + dlim1(1); % use single depth correction factor 
    else        
        vrY_post(viSpk1) = vrY_pre(viSpk1) + interp1(tlim1, dlim1, viTime_spk1, 'linear', 'extrap');
    end    
    fprintf('.');
end 
mrFet(end,:) = vrY_post;
fprintf('\n\tDrift correction took %0.1fs\n', toc(t1));

if fPlot_drift
    [viTime_spk, vrAmp_spk] = get0_('viTime_spk', 'vrAmp_spk');
    viSpk = find(vrAmp_spk < median(vrAmp_spk)); %pick more negative
%     viSpk1 = viSpk1(1:2:end); %plot every other
    figure; hold on; set(gcf,'Color','w');
    ax(1)=subplot(121); 
    plot(viTime_spk(viSpk), vrY_pre(viSpk), 'go', 'MarkerSize', 2); title('before correction'); grid on;
    ax(2)=subplot(122); 
    plot(viTime_spk(viSpk), vrY_post(viSpk), 'bo', 'MarkerSize', 2); title('after correction'); grid on;
    linkaxes(ax,'xy');
end
end %func


%--------------------------------------------------------------------------
function mrDist_clu = S_clu_cov_(S_clu, P)
% merge clusters based on the spike waveforms
% nPc = 3;
% trCov = tr2cov_(S_clu.trWav_spk_clu);
% trWav_clu = meanSubt_(S_clu.trWav_spk_clu);
trWav_clu = meanSubt_(S_clu.trWav_raw_clu); %uses unfiltered waveform
% pairwise similarity computation
% maxSite = P.maxSite_merge;
maxSite = ceil(P.maxSite/2);
% maxSite = P.maxSite;
mrDist_clu = nan(S_clu.nClu);
vrVar_clu = zeros(S_clu.nClu, 1, 'single');
% miSites = P.miSites(1:P.maxSite_merge*2+1, :);
for iClu2 = 1:S_clu.nClu        
    iSite2 = S_clu.viSite_clu(iClu2);
%     viSite2 = miSites(:,iSite2);
    viClu1 = find(abs(S_clu.viSite_clu - iSite2) <= maxSite);
    viClu1(viClu1 == iClu2) = [];
    viClu1 = viClu1(:)';
%     mrCov2 = eigvec_(trCov(:,:,iClu2), nPc);    
    mrWav_clu2 = trWav_clu(:,:,iClu2);
    [~,~,var2] = pca(mrWav_clu2); var2 = var2(1)/sum(var2);
    vrVar_clu(iClu2) = var2;
    for iClu1 = viClu1           
%         mrCov1 = eigvec_(trCov(:,:,iClu1), nPc);
        mrWav_clu1 = trWav_clu(:,:,iClu1);
%         mrDist_clu(iClu1, iClu2) = mean(abs(mean(mrCov1 .* mrCov2))); %cov_eig_(mrCov1, mrCov2, nPc);
        mrDist_clu(iClu1, iClu2) = cluWav_dist_(mrWav_clu1, mrWav_clu2);
    end
end
end %func


%--------------------------------------------------------------------------
function trCov = tr2cov_(trWav)
[nT, nSites, nClu] = size(trWav);
trCov = zeros(nT, nT, nClu, 'like', trWav);
trWav = meanSubt_(trWav);
for iClu=1:nClu
    mrCov1 = trWav(:,:,iClu); %mean waveform covariance
    mrCov1 = mrCov1 * mrCov1';    
    trCov(:,:,iClu) = mrCov1;
end %for
end %func


%--------------------------------------------------------------------------
function dist12 = cov_eig_(mrCov1, mrCov2, nPc)
d1 = cov2var_(mrCov1, nPc); 
d2 = cov2var_(mrCov2, nPc);
d12 = cov2var_(mrCov1 + mrCov2, nPc);
dist12 = d12 / ((d1+d2)/2);
end %func


%--------------------------------------------------------------------------
function [vrD1, mrPv1] = cov2var_(mrCov1, nPc)
[mrPv1, vrD1] = eig(mrCov1); 
vrD1 = cumsum(flipud(diag(vrD1))); 
vrD1 = vrD1 / vrD1(end);
if nargin>=2
    vrD1 = vrD1(nPc);
end
end


%--------------------------------------------------------------------------
function mrCov2 = eigvec_(mrCov2, nPc)
[mrCov2,~] = eig(mrCov2); 
mrCov2 = mrCov2(:, end-nPc+1:end);
mrCov2 = bsxfun(@minus, mrCov2, mean(mrCov2));
mrCov2 = bsxfun(@rdivide, mrCov2, std(mrCov2));
end %func


%--------------------------------------------------------------------------
function corr12 = cluWav_dist_(mrWav_clu1, mrWav_clu2)
nPc = 3;
viDelay = 0;

[~, mrPv1, vrL1] = pca(mrWav_clu1, 'NumComponents', nPc);
[~, mrPv2, vrL2] = pca(mrWav_clu2, 'NumComponents', nPc);
% viDelay = -4:4; %account for time delay

if viDelay==0
    corr12 = mean(abs(diag(corr_(mrPv1, mrPv2))));
else
    vrDist12 = zeros(size(viDelay), 'single');
    for iDelay=1:numel(viDelay)
        mrPv2a = shift_mr_(mrPv2, viDelay(iDelay));
        vrDist12(iDelay) = mean(abs(diag(corr_(mrPv1, mrPv2a))));
    end
    corr12 = max(vrDist12);
end
% dist12 = abs(corr_(mrPv1, mrPv2));
% [~,~,vrL12] = pca([mrWav_clu1, mrWav_clu2]);
% nPc = 1;
% dist12 = sum(vrL12(1:nPc)) / sum(vrL12);
% 
% [~,~,vrL1] = pca(mrWav_clu1);
% dist1 = sum(vrL1(1:nPc)) / sum(vrL1);
% % dist1 = vrL(1) / sum(vrL);
% % 
% [~,~,vrL2] = pca(mrWav_clu2);
% dist2 = sum(vrL2(1:nPc)) / sum(vrL2);
% % dist2 = vrL(1) / sum(vrL);
% % 
% dist12 = dist12 / ((dist1 + dist2)/2);

% mrCov12 = [mrWav_clu1, mrWav_clu2]; 
% mrCov12 = mrCov12 * mrCov12';
% [~,vrD] = eig([mrWav_clu1, mrWav_clu2]);
% dist12 = vrD(end) / sum(vrD);

% nPc = 3;
% mrPc12 = eigvec_(mrCov12 * mrCov12', nPc);
% mrPc1 = eigvec_(mrWav_clu1 * mrWav_clu1', nPc);
% mrPc2 = eigvec_(mrWav_clu2 * mrWav_clu2', nPc);
% dist12 = mean(abs(mean(mrPc2 .* mrPc1)));
end %func


%--------------------------------------------------------------------------
function mrDist_clu = S_clu_spkcov_(S_clu, P)
% compute covariance from each spikes belonging to clusters
MAX_SAMPLE = 1000;
nPc = 3;
viSite_spk = get0_('viSite_spk');
maxSite = ceil(P.maxSite/2);
mrDist_clu = nan(S_clu.nClu);
tnWav_raw = get_spkwav_(P, 1);

% compute a cell of mrPv
[cmrPv_spk_clu, cmrPv_raw_clu] = deal(cell(S_clu.nClu, 1));
for iClu = 1:S_clu.nClu
    viSpk_clu1 = S_clu.cviSpk_clu{iClu};
    viSpk_clu1 = viSpk_clu1(viSite_spk(viSpk_clu1) == S_clu.viSite_clu(iClu));
    viSpk_clu1 = subsample_vr_(viSpk_clu1, MAX_SAMPLE);
%     cmrPv_spk_clu{iClu} = tn2pca_spk_(tnWav_spk(:,:,viSpk_clu1), nPc);
    cmrPv_raw_clu{iClu} = tn2pca_spk_(tnWav_raw(:,:,viSpk_clu1), nPc);
end %for

for iClu2 = 1:S_clu.nClu        
    iSite2 = S_clu.viSite_clu(iClu2);
    viClu1 = find(abs(S_clu.viSite_clu - iSite2) <= maxSite);
    viClu1(viClu1 == iClu2) = [];
    viClu1 = viClu1(:)';
%     mrPv_clu2 = cmrPv_clu_raw{iClu2};
    for iClu1 = viClu1           
        vrCorr_raw = diag(corr_(cmrPv_raw_clu{iClu2}, cmrPv_raw_clu{iClu1}));
%         vrCorr_spk = diag(corr_(cmrPv_spk_clu{iClu2}, cmrPv_spk_clu{iClu1}));
%         mrDist_clu(iClu1, iClu2) = mean(abs([vrCorr_raw; vrCorr_spk]));
%         mrDist_clu(iClu1, iClu2) = mean(abs([vrCorr_raw; vrCorr_spk]));
%         mrPv_clu1 = cmrPv_clu_raw{iClu1};        
        mrDist_clu(iClu1, iClu2) = mean(abs(vrCorr_raw));
    end
end %for
end %func


%--------------------------------------------------------------------------
function mrPv = tn2pca_cov_(tn, nPc)
% calc cov by averaging and compute pca
[nT, nC, nSpk] = size(tn);
mrCov1 = zeros(nT, nT, 'double');
tr = meanSubt_(single(tn));
for iSpk = 1:nSpk
    mr1 = tr(:,:,iSpk);
    mrCov1 = mrCov1 + double(mr1 * mr1');
end
[mrPv, vrL] = eig(mrCov1);
mrPv = mrPv(:, end:-1:end-nPc+1);
end %func


%--------------------------------------------------------------------------
function mrPv = tn2pca_spk_(tn, nPc)
% calc cov by averaging and compute pca
[nT, nC, nSpk] = size(tn);
% mrCov1 = zeros(nT, nT, 'single');
mr = single(reshape(tn, nT,[]));
mr = meanSubt_(mr);
[~, mrPv] = pca(mr, 'NumComponents', nPc);
% tr = meanSubt_(single(tn));
% for iSpk = 1:nSpk
%     mr1 = tr(:,:,iSpk);
%     mrCov1 = mrCov1 + mr1 * mr1';
% end
% [mrPv, vrL] = eig(mrCov1);
% mrPv = mrPv(:, end:-1:end-nPc+1);
end %func


%--------------------------------------------------------------------------
function mr = shift_vr_(vr, vn_shift)
n = numel(vr);
% mr = zeros(n, numel(vn_shift), 'like', vr);
mi = bsxfun(@plus, (1:n)', vn_shift(:)');
mi(mi<1) = 1;
mi(mi>n) = n;
mr = vr(mi);
end %func


%--------------------------------------------------------------------------
function [iClu, hPlot] = plot_tmrWav_clu_(S0, iClu, hPlot, vrColor)
[S_clu, P] = getfield_(S0, 'S_clu', 'P');
[hFig, S_fig] = get_fig_cache_('FigWav');
if ~isvalid_(hPlot)
    hPlot = plot(nan, nan, 'Color', vrColor, 'LineWidth', 2, 'Parent', S_fig.hAx);
end
if P.fWav_raw_show
    mrWav_clu1 = S_clu.tmrWav_raw_clu(:,:, iClu);
else
    mrWav_clu1 = S_clu.tmrWav_clu(:,:, iClu);
end
multiplot(hPlot, S_fig.maxAmp, wav_clu_x_(iClu, P), mrWav_clu1);
uistack_(hPlot, 'top');
end %func


%--------------------------------------------------------------------------
function mrWav = mean_tnWav_raw_(tnWav, P)
mrWav = meanSubt_(mean(single(tnWav),3)) * P.uV_per_bit;
end %func


%--------------------------------------------------------------------------
function tr = raw2uV_(tnWav_raw, P)
tr = meanSubt_(single(tnWav_raw) * P.uV_per_bit);
end %func


%--------------------------------------------------------------------------
function raw_waveform_(hMenu)
figure_wait_(1);
[P, S_clu] = get0_('P', 'S_clu');
if get_(P, 'fWav_raw_show')
    P.fWav_raw_show = 0;
else
    P.fWav_raw_show = 1;
end

if isempty(get_(S_clu, 'tmrWav_raw_clu'))    
    S_clu = S_clu_wav_(S_clu);
    S0 = set0_(P, S_clu);
else
    S0 = set0_(P);
end
set(hMenu, 'Checked', ifeq_(P.fWav_raw_show, 'on', 'off'));
% redraw windows
plot_FigWav_(S0);
button_CluWav_simulate_(S0.iCluCopy, S0.iCluPaste, S0);
figure_wait_(0);
end %func


%--------------------------------------------------------------------------
function [mrPv1, mrPv2] = pca_pv_spk_(viSpk1, viSites1, tnWav_spk1)
% if viSite not found just set to zero
nSites = numel(viSites1);  
S0 = get0_();
mrPv_global = get_(S0, 'mrPv_global'); 
if ~isempty(mrPv_global)
    % show global pca
    mrPv1 = repmat(mrPv_global(:,1), [1, nSites]);
    mrPv2 = repmat(mrPv_global(:,2), [1, nSites]);
else
    if nargin<3
        tnWav_spk1 = permute(tnWav_spk_sites_(viSpk1, viSites1, S0, 0), [1,3,2]);
    end
    nT = size(tnWav_spk1, 1);      
    % show site pca
    [mrPv1, mrPv2] = deal(zeros(nT, nSites, 'single'));
    for iSite1=1:nSites
        [mrPv1(:,iSite1), mrPv2(:,iSite1)] = pca_pv_(tnWav_spk1(:,:,iSite1));
    end %for
end
end %func


%--------------------------------------------------------------------------
function [mrPv1, mrPv2] = pca_pv_clu_(viSites, iClu1, iClu2)
% [mrPv1, mrPv2] = pca_pv_clu_(viSites, iClu1): return two prinvec per site from same clu
% [mrPv1, mrPv2] = pca_pv_clu_(viSites, iClu1, iClu2): return one prinvec per clu per site

if nargin<3, iClu2 = []; end
S0 = get0_();
S_clu = S0.S_clu;
% show site pca
MAX_SAMPLE = 10000; %for pca
viSpk1 = subsample_vr_(S_clu.cviSpk_clu{iClu1}, MAX_SAMPLE);
tnWav_spk1 = permute(tnWav_spk_sites_(viSpk1, viSites, S0, 0), [1,3,2]);
[nT, nSites] = deal(size(tnWav_spk1, 1), numel(viSites));
[mrPv1, mrPv2] = deal(zeros(nT, nSites, 'single'));

if isempty(iClu2)
    for iSite1=1:nSites
        [mrPv1(:,iSite1), mrPv2(:,iSite1)] = pca_pv_(tnWav_spk1(:,:,iSite1));
    end %for
else
    viSpk2 = subsample_vr_(S_clu.cviSpk_clu{iClu2}, MAX_SAMPLE);    
    tnWav_spk2 = permute(tnWav_spk_sites_(S_clu.cviSpk_clu{iClu2}, viSites, S0, 0), [1,3,2]);
    for iSite1=1:nSites
        mrPv1(:,iSite1) = pca_pv_(tnWav_spk1(:,:,iSite1));
        mrPv2(:,iSite1) = pca_pv_(tnWav_spk2(:,:,iSite1));
    end %for
end
end %func


%--------------------------------------------------------------------------
function [vrPv1, vrPv2] = pca_pv_(mr1)
MAX_SAMPLE = 10000; %for pca
mrCov = subsample_mr_(mr1, MAX_SAMPLE, 2);
mrCov = meanSubt_(single(mrCov));
mrCov = mrCov * mrCov';
[mrPv1, vrD1] = eig(mrCov); 
vrPv1 = mrPv1(:,end);
vrPv2 = mrPv1(:,end-1);
% iMid = 1-P.spkLim(1);
% vrPv1 = ifeq_(vrPv1(iMid)>0, -vrPv1, vrPv1);
% vrPv2 = ifeq_(vrPv2(iMid)>0, -vrPv2, vrPv2);
end %func


%--------------------------------------------------------------------------
function [mrPc1, mrPc2, mrPv1, mrPv2] = pca_pc_spk_(viSpk1, viSites1, mrPv1, mrPv2)
% varargin: mrPv
% varargout: mrPc
% project
%[mrPc1, mrPc2, mrPv1, mrPv2] = pca_pc_spk_(viSpk1, viSites1)
%[mrPc1, mrPc2] = pca_pc_spk_(viSpk1, viSites1, mrPv1, mrPv2)
nSites1 = numel(viSites1);
tnWav_spk1 = permute(tnWav_spk_sites_(viSpk1, viSites1, [], 0), [1,3,2]);
if nargin<3
    [mrPv1, mrPv2] = pca_pv_spk_(viSpk1, viSites1, tnWav_spk1);
end

dimm1 = size(tnWav_spk1); %nT x nSpk x nChan
[mrPc1, mrPc2] = deal(zeros(dimm1(2), nSites1, 'single'));
try
    for iSite1=1:nSites1
        mrWav_spk1 = meanSubt_(single(tnWav_spk1(:,:,iSite1)));
        mrPc1(:,iSite1) = (mrPv1(:,iSite1)' * mrWav_spk1)';
        mrPc2(:,iSite1) = (mrPv2(:,iSite1)' * mrWav_spk1)';
    end %for
catch
    disperr_();
end
mrPc1 = (mrPc1') / dimm1(1);
mrPc2 = (mrPc2') / dimm1(1);
end %func


%--------------------------------------------------------------------------
function vc = if_on_off_(vc, cs)
if ischar(cs), cs = {cs}; end
vc = ifeq_(ismember(vc, cs), 'on', 'off');
end %func


%--------------------------------------------------------------------------
function proj_view_(hMenu)
P = get0_('P');
vcFet_show = lower(get(hMenu, 'Label'));
P.vcFet_show = vcFet_show;
vhMenu = hMenu.Parent.Children;
for iMenu=1:numel(vhMenu)
    vhMenu(iMenu).Checked = if_on_off_(vhMenu(iMenu).Label, vcFet_show);
end
% auto-scale the view
S0 = set0_(P);
button_CluWav_simulate_(S0.iCluCopy, S0.iCluPaste, S0);
end %func


%--------------------------------------------------------------------------
function P = struct_default_(P, csName, def_val)
% Set to def_val if empty or field does not exist
% set the field(s) to default val

if ischar(csName), csName = {csName}; end
for iField = 1:numel(csName)
    vcName = csName{iField};
    if ~isfield(P, vcName)
        P.(vcName) = def_val;
    elseif isempty(P.(vcName))
        P.(vcName) = def_val;
    end
end
end %func


%--------------------------------------------------------------------------
function export_diff_(P)
% export to _diff.bin, _diff.prb, _diff.prm files
error('not implemented yet');
if ~P.fTranspose_bin
    mnWav1 = reshape(load_bin_(P.vcFile, P.vcDataType), [], P.nChans);
    mnWav1 = mnWav1(:,P.viSite2Chan);
else
    mnWav1 = reshape(load_bin_(P.vcFile, P.vcDataType), P.nChans, []);
    mnWav1 = mnWav1(P.viSite2Chan, :)';
end

% mnWav1: nT x nSites

% fields to update, copy and save
P1 = P;
P1.vcFile = strrep(P.vcFile, '.bin', '_diff.bin');
P1.vcFile_prm = strrep(P.vcFile_prm, '.prm', '_diff.prm');
P1.probe_file = strrep(P.vcFile_prm, '.prm', '_diff.prb');
P1.fTranspose_bin = 0;
P1.vcCommonRef = 'none';
P1.fDetectBipolar = 1;
P1.nSites_ref = 0;

% differentiate channels and write to bin file (two column type)
nSites = numel(P.viSite2Chan);
viChan_HP = 1:2:nSites;
viChan_HN = 2:2:nSites;
viChan_VP = 1:(nSites-4);
viChan_VN = viChan_VP + 4;
viChan_P = [viChan_HP(1), toRow_([viChan_VP(1:2:end); viChan_HP(2:end-1); viChan_VP(2:2:end)]), viChan_HP(end)];
viChan_N = [viChan_HN(1), toRow_([viChan_VN(1:2:end); viChan_HN(2:end-1); viChan_VN(2:2:end)]), viChan_HN(end)];
mnWav2 = mnWav1(:,viChan_P) - mnWav1(:,viChan_N);
P1.nChans = size(mnWav2, 2);

% Output files
copyfile(P.vcFile_prm, P1.vcFile_prm, 'f');
edit_prm_file_(P1, P1.vcFile_prm);
write_bin_(P1.vcFile, mnWav2);
% write to probe file
% P1.probe_file
% mnWav2 = load_bin_(strrep(P.vcFile, '.bin', '_diff.bin'), P.vcDataType); %read back test


end %func


% %--------------------------------------------------------------------------
% function vr = toRow_(mr)
% vr = mr(:)';
% end
% 
% 
% %--------------------------------------------------------------------------
% function vr = toCol_(mr)
% vr = mr(:);
% end


%--------------------------------------------------------------------------
function vnWav1_mean = mean_excl_(mnWav1, P)
% calculate mean after excluding viSiteZero
viSiteZero = get_(P, 'viSiteZero');
if isempty(viSiteZero)
    vnWav1_mean = int16(mean(mnWav1,2));
else
    nSites_all = size(mnWav1, 2);
    nSites_excl = numel(viSiteZero);
    nSites = nSites_all - nSites_excl;
    vnWav1_mean = int16((sum(mnWav1,2) - sum(mnWav1(:,nSites_excl),2)) / nSites);
end
end %func


%--------------------------------------------------------------------------
function vnWav1_med = median_excl_(mnWav1, P)
% calculate mean after excluding viSiteZero
viSiteZero = get_(P, 'viSiteZero');
fGpu = isGpu_(mnWav1);
if fGpu, mnWav1 = gather_(mnWav1); end
if isempty(viSiteZero)
    vnWav1_med = median(mnWav1,2);
else
    viSites = setdiff(1:size(mnWav1,2), viSiteZero);
    vnWav1_med = median(mnWav1(:,viSites),2);
end
vnWav1_med = gpuArray_(vnWav1_med, fGpu);
end %func


%--------------------------------------------------------------------------
function nCols = nColumns_probe_(P)
% Checkerboard four-column is considered as two column probe since
% two sites per vertical step
viShank_site = get_(P, 'viShank_site');
if ~isempty(viShank_site)
    viSites = find(P.viShank_site == P.viShank_site(1));    
    vrSiteY = P.mrSiteXY(viSites,2);
else
    vrSiteY = P.mrSiteXY(:,2);
end
vrSiteY_unique = unique(vrSiteY);
vnSites_group = hist(vrSiteY, vrSiteY_unique);
nCols = median(vnSites_group);
end %func


%--------------------------------------------------------------------------
function [mnWav2, cviSite_mean] = meanSite_drift_(mnWav1, P, viSite_repair)
% [mnWav1, cviSite_mean] = meanSite_drift_(mnWav1, P)
% [mnWav1, cviSite_mean] = meanSite_drift_(mnWav1, P, viSite_repair) %bad site repair

% mnWav1 = sites_repair_(mnWav1, P); % must repair site to perform vertical averaging
% this corrects for viSiteZero automatically
nSites = size(mnWav1,2);
nCols = nColumns_probe_(P);
viSiteZero = get_(P, 'viSiteZero');
cviSite_mean = cell(1, nSites);
viSites = 1:nSites;
fSingleShank = isSingleShank_(P);
if nargin<3
    viSite_repair = 1:nSites;
else
    viSite_repair = toRow_(viSite_repair);
end
mnWav2 = zeros(size(mnWav1), 'like', mnWav1);
for iSite = viSite_repair
    if fSingleShank
        viSite_shank1 = viSites; %faster        
    else
        viSite_shank1 = viSites(P.viShank_site == P.viShank_site(iSite));
    end
    for iNeigh=1:4
        viSite_mean1 = iSite + [-1,0,0,1] * nCols * iNeigh;
        viSite_mean1 = viSite_mean1(ismember(viSite_mean1, viSite_shank1));
        viSite_mean1(ismember(viSite_mean1, viSiteZero)) = [];
        if ~isempty(viSite_mean1), break; end
    end
    cviSite_mean{iSite} = viSite_mean1;
    mnWav2(:, iSite) = mean(mnWav1(:, viSite_mean1), 2);
end
end %func


%--------------------------------------------------------------------------
function flag = isSingleShank_(P)
viShank_site = get_(P, 'viShank_site');
if isempty(viShank_site)
    flag = 1;
else
    flag = numel(unique(viShank_site)) == 1;
end
end


%--------------------------------------------------------------------------
% 12/21/17 JJJ: Annotate on the x-axis intead of floating text box (faster)
% function vhText = text_nClu_(S_clu, hAx)
% % update x label
% 
% nClu = numel(S_clu.vnSpk_clu);
% viSite_clu = double(S_clu.viSite_clu);
% y_offset = .3;
% vhText = zeros(nClu+1,1);
% for iClu=1:nClu
%     n1 = S_clu.vnSpk_clu(iClu);
% %         vcText1 = sprintf('%d, %0.1f', n1, n1/t_dur);
%     vcText1 = sprintf('%d', n1); %show numbers
%     vhText(iClu) = text(iClu, viSite_clu(iClu) + y_offset, vcText1, ...
%         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'Parent', hAx);
% end
% vhText(end) = text(0,0,'#spk', 'VerticalAlignment', 'bottom', 'Parent', hAx);
% end %func


%--------------------------------------------------------------------------
function mnWav2 = sgfilt_old_(mnWav, nDiff_filt, fGpu)
% works for a vector, matrix and tensor

if nargin<3, fGpu = isGpu_(mnWav); end
n1 = size(mnWav,1);
if n1==1, n1 = size(mnWav,2);  end
[via1, via2, via3, via4, vib1, vib2, vib3, vib4] = sgfilt4_(n1, fGpu);

if isvector(mnWav)
    switch nDiff_filt
        case 1
            mnWav2 = mnWav(via1) - mnWav(vib1);
        case 2
            mnWav2 = 2*(mnWav(via2) - mnWav(vib2)) + mnWav(via1) - mnWav(vib1);
        case 3
            mnWav2 = 3*(mnWav(via3) - mnWav(vib3)) + 2*(mnWav(via2) - mnWav(vib2)) + mnWav(via1) - mnWav(vib1);
        otherwise
            mnWav2 = 4*(mnWav(via4) - mnWav(vib4)) + 3*(mnWav(via3) - mnWav(vib3)) + 2*(mnWav(via2) - mnWav(vib2)) + mnWav(via1) - mnWav(vib1);
    end %switch
elseif ismatrix(mnWav)
    switch nDiff_filt
        case 1
            mnWav2 = mnWav(via1,:) - mnWav(vib1,:);
        case 2
            mnWav2 = 2*(mnWav(via2,:) - mnWav(vib2,:)) + mnWav(via1,:) - mnWav(vib1,:);
        case 3
            mnWav2 = 3*(mnWav(via3,:) - mnWav(vib3,:)) + 2*(mnWav(via2,:) - mnWav(vib2,:)) + mnWav(via1,:) - mnWav(vib1,:);
        otherwise
            mnWav2 = 4*(mnWav(via4,:) - mnWav(vib4,:)) + 3*(mnWav(via3,:) - mnWav(vib3,:)) + 2*(mnWav(via2,:) - mnWav(vib2,:)) + mnWav(via1,:) - mnWav(vib1,:);
    end %switch
else
    switch nDiff_filt
        case 1
            mnWav2 = mnWav(via1,:,:) - mnWav(vib1,:,:);
        case 2
            mnWav2 = 2*(mnWav(via2,:,:) - mnWav(vib2,:,:)) + mnWav(via1,:,:) - mnWav(vib1,:,:);
        case 3
            mnWav2 = 3*(mnWav(via3,:,:) - mnWav(vib3,:,:)) + 2*(mnWav(via2,:,:) - mnWav(vib2,:,:)) + mnWav(via1,:,:) - mnWav(vib1,:,:);
        otherwise
            mnWav2 = 4*(mnWav(via4,:,:) - mnWav(vib4,:,:)) + 3*(mnWav(via3,:,:) - mnWav(vib3,:,:)) + 2*(mnWav(via2,:,:) - mnWav(vib2,:,:)) + mnWav(via1,:,:) - mnWav(vib1,:,:);
    end %switch
end
end %func


%--------------------------------------------------------------------------
function mnWav1 = sgfilt_(mnWav, nDiff_filt, fGpu)
% works for a vector, matrix and tensor
fInvert_filter = 0;
if nargin<3, fGpu = isGpu_(mnWav); end
n1 = size(mnWav,1);
if n1==1, n1 = size(mnWav,2);  end
if nDiff_filt==0, mnWav1 = mnWav; return; end
if fInvert_filter
    [miB, miA] = sgfilt_init_(n1, nDiff_filt, fGpu);
else
    [miA, miB] = sgfilt_init_(n1, nDiff_filt, fGpu);
end

if isvector(mnWav)
    mnWav1 = mnWav(miA(:,1)) - mnWav(miB(:,1));
    for i=2:nDiff_filt
        mnWav1 = mnWav1 + i * (mnWav(miA(:,i)) - mnWav(miB(:,i)));
    end
elseif ismatrix(mnWav)
    mnWav1 = mnWav(miA(:,1),:) - mnWav(miB(:,1),:);
    for i=2:nDiff_filt
        mnWav1 = mnWav1 + i * (mnWav(miA(:,i),:) - mnWav(miB(:,i),:));
    end
else
    mnWav1 = mnWav(miA(:,1),:,:) - mnWav(miB(:,1),:,:);
    for i=2:nDiff_filt
        mnWav1 = mnWav1 + i * (mnWav(miA(:,i),:,:) - mnWav(miB(:,i),:,:));
    end
end
end %func


%--------------------------------------------------------------------------
function flag = isGpu_(vr)
try
    flag = isa(vr, 'gpuArray');
catch
    flag = 0;
end
end


%--------------------------------------------------------------------------
function [tr, miRange] = mn2tn_gpu_(mr, spkLim, viTime, viSite)
% what to do if viTime goves out of the range?
% gpu memory efficient implementation
% it uses GPU if mr is in GPU

if nargin<4, viSite=[]; end %faster indexing
% if nargin<5, fMeanSubt=0; end

% JJJ 2015 Dec 24
% vr2mr2: quick version and doesn't kill index out of range
% assumes vi is within range and tolerates spkLim part of being outside
% works for any datatype
if isempty(viTime), tr=[]; return; end
[nT, nSites] = size(mr);
if ~isempty(viSite)
    mr = mr(:, viSite);
    nSites = numel(viSite); 
end
if iscolumn(viTime), viTime = viTime'; end

fGpu = isGpu_(mr);
viTime = gpuArray_(viTime, fGpu);
spkLim = gpuArray_(spkLim, fGpu);

viTime0 = [spkLim(1):spkLim(end)]'; %column
miRange = bsxfun(@plus, int32(viTime0), int32(viTime));
miRange = min(max(miRange, 1), nT);
% miRange = miRange(:);
tr = zeros([numel(viTime0), numel(viTime), nSites], 'int16');
dimm_tr = size(tr);
for iSite = 1:nSites
    if fGpu
%         vr1 = gpuArray_(mr(:,iSite));
%         tr(:,:,iSite) = gather_(vr1(miRange));
        tr(:,:,iSite) = gather_(reshape(mr(miRange, iSite), dimm_tr(1:2)));
    else
        tr(:,:,iSite) = reshape(mr(miRange, iSite), dimm_tr(1:2));
    end
end
end %func


%--------------------------------------------------------------------------
function [mr, fGpu] = gpuArray_(mr, fGpu)
if nargin<2, fGpu = 1; end
% fGpu = 0; %DEBUG disable GPU array
if ~fGpu, return; end
try
    if ~isa(mr, 'gpuArray'), mr = gpuArray(mr); end
    fGpu = 1;
catch        
    try % retry after resetting the GPU memory
        gpuDevice(1); 
        mr = gpuArray(mr);
        fGpu = 1;
    catch % no GPU device found            
        fGpu = 0;
    end
end
end


%--------------------------------------------------------------------------
function varargout = gpuArray_deal_(varargin)
if nargin > nargout
    fGpu = varargin{end}; 
else
    fGpu = 1;
end

for iArg = 1:nargout
    vr_ = varargin{iArg};
    if fGpu
        try
            if ~isa(vr_, 'gpuArray'), vr_ = gpuArray(vr_); end
        catch
            fGpu = 0;
        end
    else
        if isa(vr_, 'gpuArray'), vr_ = gather_(vr_); end
    end
    varargout{iArg} = vr_;
end %for
end %func


%--------------------------------------------------------------------------
% 12/18/17 JJJ: can handle header_offset
function nBytes_load = file_trim_(fid, nBytes_load, P)
header_offset = get_set_(P, 'header_offset', 0);
nBytes_load = nBytes_load - header_offset;
if isempty(P.tlim_load) || ~P.fTranspose_bin
    if header_offset > 0, fseek(fid, header_offset, 'bof'); end
    return; 
end

bytesPerSample = bytesPerSample_(P.vcDataType);
nSamples = floor(nBytes_load / bytesPerSample / P.nChans);

% Apply limit to the range of samples to load
nlim_load = min(max(round(P.tlim_load * P.sRateHz), 1), nSamples);
nSamples_load = diff(nlim_load) + 1;
nBytes_load = nSamples_load * bytesPerSample * P.nChans;
% if nlim_load(1)>1, 
fseek_(fid, nlim_load(1), P); 
% end
end %func


%--------------------------------------------------------------------------
function fseek_(fid_bin, iSample_bin, P)
% provide # of samples to skip for transpose multi-channel type
% Index starts with 1 unlike fseek() function

if ~P.fTranspose_bin, return; end
header_offset = get_set_(P, 'header_offset', 0);
iOffset = (iSample_bin-1) * P.nChans * bytesPerSample_(P.vcDataType) + header_offset;
if iOffset<0, iOffset = 0; end
fseek(fid_bin, iOffset, 'bof');
end %func


%--------------------------------------------------------------------------
function c = corr_vr_(vr1,vr2)
% Vectorize matrix and compute correlation
vr1 = vr1(:);
vr2 = vr2(:);
vr1 = vr1 - mean(vr1);
vr2 = vr2 - mean(vr2);
c = mean(vr1 .* vr2) / std(vr1,1) / std(vr2,1);
end %func


%--------------------------------------------------------------------------
% 10/18/17 JJJ: speed optimization. Todo: use shift matrix?  (https://en.wikipedia.org/wiki/Shift_matrix)
% 10/8/17 JJJ: find correlation
function vrDist12 = xcorr2_mr_(mrWav1, mrWav2, arg1, arg2)
% vrDist12 = xcorr_mr_(mrWav1, mrWav2, nShift)
% vrDist12 = xcorr_mr_(mrWav1, mrWav2, cvi1, cvi2)
% fMeanSubt_post = 1;
% fSquared = 0;
if nargin == 3
    nShift = arg1;    
    nT = size(mrWav1, 1);
    [cvi1, cvi2] = shift_range_(nT, nShift);
else
    cvi1 = arg1;
    cvi2 = arg2;
end
% if fSquared
%     mrWav1 = mrWav1 .^ 2;
%     mrWav2 = mrWav2 .^ 2;
% end
% vrDist12 = gpuArray_(zeros(size(cvi1)), isGpu_(mrWav1));
vrDist12 = zeros(size(cvi1));
for iDist = 1:numel(vrDist12)    
    vr1 = mrWav1(cvi1{iDist},:);
    vr2 = mrWav2(cvi2{iDist},:);
%     vrDist12(iDist) = corr_(vr1(:), vr2(:), 1);
    vr1 = vr1(:);
    vr2 = vr2(:);
%     n = numel(vr1);
    vr1 = vr1 - sum(vr1)/numel(vr1);
    vr2 = vr2 - sum(vr2)/numel(vr2);
    vrDist12(iDist) = vr1'*vr2 / sqrt(sum(vr1.^2)*sum(vr2.^2));
%     vrDist12(iDist) = vr1'*vr2 / sqrt(vr1'*vr1*vr2'*vr2);
end
end %func


%--------------------------------------------------------------------------
function [cvi1, cvi2] = shift_range_(nT, nShift, viShift)
% return ranges of two matrix to be time shifted
% [cvi1, cvi2] = shift_range_(nT, nShift): -nShift:nShift
% [cvi1, cvi2] = shift_range_(nT, vnShift)
if ~isempty(nShift)
    [cvi1, cvi2] = deal(cell(nShift*2+1, 1));
    viShift = -nShift:nShift;
else
    [cvi1, cvi2] = deal(cell(numel(viShift), 1));
end
viRange = 1:nT;
for iShift_ = 1:numel(viShift)
    iShift = viShift(iShift_);
    iShift1 = -round(iShift/2);
    iShift2 = iShift + iShift1;
    viRange1 = viRange + iShift1;
    viRange2 = viRange + iShift2;
    vl12 = (viRange1>=1 & viRange1<=nT) & (viRange2>=1 & viRange2<=nT);
    cvi1{iShift_} = viRange1(vl12);
    cvi2{iShift_} = viRange2(vl12);
end
end %func


%--------------------------------------------------------------------------
function S0 = save_log_(vcCmd, S0)

% save cluster info and save to file (append)
% check for crash
% todo: save differential increment from the beginning

if nargin<2, S0 = get(0, 'UserData'); end
[cS_log, P, S_clu, miClu_log] = get_(S0, 'cS_log', 'P', 'S_clu', 'miClu_log');

if ~isempty(strfind(vcCmd, 'annotate'))
    S_log = cS_log{end};
    S_log.csNote_clu = S_clu.csNote_clu;
    cS_log{end} = S_log;
else
    S_log = struct_('vcCmd', vcCmd, 'datenum', now(), 'csNote_clu', S_clu.csNote_clu);
    if isempty(cS_log) || ~iscell(cS_log)
        cS_log = {S_log};        
    else
        cS_log{end+1} = S_log;
    end
end

% Keep P.MAX_LOG history
if isempty(miClu_log)
    miClu_log = zeros([numel(S_clu.viClu), P.MAX_LOG], 'int16'); 
end
miClu_log(:, 2:end) = miClu_log(:, 1:end-1);
miClu_log(:, 1) = int16(S_clu.viClu);
%struct_save_(strrep(P.vcFile_prm, '.prm', '_log.mat'), 'cS_log', cS_log);
S_log.viClu = int16(S_clu.viClu);
struct_save_(S_log, strrep(P.vcFile_prm, '.prm', '_log.mat'), 0);
S0.cS_log = cS_log;
S0.miClu_log = miClu_log;

ui_update_log_(cS_log, S0); % update revert to list

if nargout<1, set(0, 'UserData', S0); end
end %func


%--------------------------------------------------------------------------
function S = struct_(varargin)
% smart about dealing with cell input
for iArg = 1:2:numel(varargin)
    try
        S.(varargin{iArg}) = varargin{iArg+1};
    catch
        disperr_('struct_');
    end
end
end


%--------------------------------------------------------------------------
function ui_update_log_(cS_log, S0)
% the last one is selected
% persistent mh_history

% List recent activities
% if nargin<2, S0 = get(0, 'UserData'); end
% set(hMenu_history, 'Label', sprintf('Undo %s', cS_log.csCmd{end}), 'Enable', 'on');
if nargin<2, S0=[]; end
if isempty(S0), S0 = get(0, 'UserData'); end
P = S0.P;
mh_history = get_tag_('mh_history', 'uimenu');

% Delete children and update
delete_(mh_history.Children); %kill all children
for iMenu = 1:numel(cS_log) % reverse order
    iLog = numel(cS_log) - iMenu + 1;
    S_log1 = cS_log{iLog};
    vcLabel1 = sprintf('%s: %s', datestr(S_log1.datenum), S_log1.vcCmd);
    fEnable = (iMenu <= P.MAX_LOG) && iMenu~=1; 
    uimenu(mh_history, 'Label', vcLabel1, 'Callback', @(h,e)restore_log_(iMenu), ...
        'Checked', ifeq_(iMenu==1, 'on', 'off'), ...
        'Enable', ifeq_(fEnable, 'on', 'off'));
end
% update undo/redo menu
end %func


%--------------------------------------------------------------------------
function restore_log_(iMenu1)
% persistent mh_history
figure_wait_(1);
[cS_log, miClu_log, P] = get0_('cS_log', 'miClu_log', 'P');
S_clu1 = cS_log{end - iMenu1 + 1}; % last ones shown first
S_clu1.viClu = int32(miClu_log(:,iMenu1));

hMsg = msgbox_(sprintf('Restoring to %s (%s)', S_clu1.vcCmd, datestr(S_clu1.datenum)), 0);
[S_clu, S0] = S_clu_new_(S_clu1);

% Update checkbox
mh_history = get_tag_('mh_history', 'uimenu');
vhMenu = mh_history.Children;
vhMenu = vhMenu(end:-1:1); %reverse order
for iMenu = 1:numel(vhMenu)
    fTargetItem = iMenu==iMenu1;
    fEnable = ~fTargetItem && iMenu <= P.MAX_LOG;
    set(vhMenu(iMenu), ...
        'Checked', ifeq_(fTargetItem, 'on', 'off'), ...
        'Enable', ifeq_(fEnable, 'on', 'off'));
end %for

% update GUI
S0 = gui_update_(S0, S_clu);
% plot_FigWav_(S0); %redraw plot
% S0.iCluCopy = min(S0.iCluCopy, S_clu.nClu);
% S0.iCluPaste = [];
% set(0, 'UserData', S0);
% update_plot_(S0.hPaste, nan, nan); %remove paste cursor
% S0 = update_FigCor_(S0);        
% S0 = button_CluWav_simulate_(S0.iCluCopy, [], S0);
% set(0, 'UserData', S0);
close_(hMsg);
figure_wait_(0);
end %func


%--------------------------------------------------------------------------
function S0 = gui_update_(S0, S_clu)
if nargin<1, S0 = get(0, 'UserData'); end
if nargin<2, S_clu = S0.S_clu; end
plot_FigWav_(S0); %redraw plot
S0.iCluCopy = min(S0.iCluCopy, S_clu.nClu);

% S0.iCluCopy = 1;
S0.iCluPaste = [];
set(0, 'UserData', S0);
update_plot_(S0.hPaste, nan, nan); %remove paste cursor
S0 = update_FigCor_(S0);        
S0 = button_CluWav_simulate_(S0.iCluCopy, [], S0);
keyPressFcn_cell_(get_fig_cache_('FigWav'), 'z');
set(0, 'UserData', S0);
end %func

    
%--------------------------------------------------------------------------
function vcFile_batch = makeprm_list_(vcFile_txt, vcFile_prb, vcFile_template)
% output prm file from a template file
% vcFile_prm is [vcFile_bin, vcFile_prb, '.prm'], after removing .bin and .prb extensions

csFiles_bin = load_batch_(vcFile_txt);
vcFile_batch = strrep(vcFile_txt, '.txt', '.batch');
csFiles_prm = cell(size(csFiles_bin));
for iFile = 1:numel(csFiles_bin)
    try
        csFiles_prm{iFile} = makeprm_template_(csFiles_bin{iFile}, vcFile_prb, vcFile_template);
    catch
        fprintf('\tError processing %s\n', csFiles_bin{iFile}); % error converting file
    end
end
cellstr2file_(vcFile_batch, csFiles_prm);
end %func


%--------------------------------------------------------------------------
function vcFile_prm = makeprm_template_(vcFile_bin, vcFile_prb, vcFile_template)
if isempty(vcFile_prb)
    vcFile_prb = get_(file2struct_(vcFile_template), 'probe_file');
end

S_prm = struct('vcFile', vcFile_bin, 'template_file', vcFile_template, ...
    'probe_file', vcFile_prb);
vcFile_gt_mat = '';

if matchFileExt_(vcFile_bin, '.raw')
    [vcFile_meta, S_meta, vcFile_gt_mat] = raw2meta_(vcFile_bin);
elseif matchFileExt_(vcFile_bin, '.h5')
    [vcFile_h5, vcFile_bin] = deal(vcFile_bin, strrep(vcFile_bin, '.h5', '.bin'));
    [mrWav, S_meta, S_gt] = load_h5_(vcFile_h5);
    write_bin_(vcFile_bin, int16(meanSubt_(mrWav) / S_meta.uV_per_bit)');
    vcFile_prb = S_meta.probe_file;
    vcFile_gt_mat = strrep(vcFile_h5, '.h5', '_gt.mat');
    struct2meta_(S_meta, strrep(vcFile_h5, '.h5', '.meta'));
    struct_save_(S_gt, vcFile_gt_mat);
end
S_prm = struct_merge_(S_prm, S_meta);
if exist_file_(vcFile_gt_mat), S_prm.vcFile_gt = vcFile_gt_mat; end
S_prm.vcFile = vcFile_bin;

% name prm file
[~,vcPostfix,~] = fileparts(vcFile_prb);
vcFile_prm = subsFileExt_(vcFile_bin, ['_', vcPostfix, '.prm']);

struct2file_(S_prm, vcFile_prm);
fprintf('Wrote to %s\n\n', vcFile_prm);
end


%--------------------------------------------------------------------------
% 10/30/17 JJJ: To be deprecated
% function batch_mat_(vcFile_batch_mat, vcCommand)
% % batch process binary file from a template file
% % batch_(myfile_batch.mat, vcCommand)
% %  file must contain: csFiles_bin, csFiles_template
% %    optional: vrDatenum, datenum_start, csFiles_prb
% 
% if ~contains(lower(vcFile_batch_mat), '_batch.mat')
%     fprintf(2, 'Must provide _batch.mat file format');
%     return;
% end
% if nargin<2, vcCommand = ''; end
% if isempty(vcCommand), vcCommand = 'spikesort'; end
% 
% % Input file format
% S_batch = load(vcFile_batch_mat);
% csFiles_bin = S_batch.csFiles_bin;
% if ischar(csFiles_bin), csFiles_bin = {csFiles_bin}; end
% nFiles = numel(csFiles_bin);
% csFiles_template = get_(S_batch, 'csFiles_template');
% if ischar(csFiles_template), csFiles_template = repmat({csFiles_template}, size(csFiles_bin)); end
% csFiles_prb = get_(S_batch, 'csFiles_prb');
% if isempty(csFiles_prb), csFiles_prb = ''; end
% if ischar(csFiles_prb), csFiles_prb = repmat({csFiles_prb}, size(csFiles_bin)); end
% csFiles_prm = cell(size(csFiles_bin));
% 
% for iFile = 1:nFiles
%     try
%         vcFile_prm_ = makeprm_template_(csFiles_bin{iFile}, csFiles_template{iFile}, csFiles_prb{iFile});
%         fprintf('Created %s\n', vcFile_prm_);
%         irc(vcCommand, vcFile_prm_);
%         csFiles_prm{iFile} = vcFile_prm_;
%     catch
%         disperr_(sprintf('Failed to process %s', csFiles_bin{iFile}));
%     end
% end %for
% S_batch.csFiles_prm = csFiles_prm;
% write_struct_(vcFile_batch_mat, S_batch);
% end %func


%--------------------------------------------------------------------------
function batch_plot_(vcFile_batch, vcCommand)
% vcFile_batch: .batch or _batch.mat file format (contains csFiles_prm)
% Collectively analyze multiple sessions
% error('not implemented yet');
if nargin<2, vcCommand=[]; end
if isempty(vcCommand), vcCommand='skip'; end %spikesort if doesn't exist

if ~exist_file_(vcFile_batch, 1), return; end
if matchFileExt_(vcFile_batch, '.batch')
    edit_(vcFile_batch); %show script
    csFiles_prm = importdata(vcFile_batch);
    % Removing comments that starts with "%"
    func_comment = @(vc)vc(1) == '%';
    viComment = cellfun(@(vc)func_comment(strtrim(vc)), csFiles_prm);
    csFiles_prm(viComment) = [];
end


% run the sorting and collect data. quantify the quality
cS_plot_file = cell(size(csFiles_prm));
for iFile=1:numel(csFiles_prm)
    try
        vcFile_prm1 = csFiles_prm{iFile};
        irc('clear');
        if ~strcmpi(vcCommand, 'skip')                        
            irc(vcCommand, vcFile_prm1);
            S0 = get(0, 'UserData');
        else
            S0 = load_cached_(vcFile_prm1);
        end
        cS_plot_file{iFile} = S_plot_new_(S0);
    catch
        disp(lasterr());
    end
end %for

% plot cS_plot_file
S_plot_show(cS_plot_file); % save to _batch.mat (?)

end %func


%--------------------------------------------------------------------------
function S_plot = S_plot_new_(S0)
% S_plot contains quantities to be plotted
% Copied from ironclust.m quality_metric_

if nargin<1, S0 = get(0, 'UserData'); end
P = S0.P;
tnWav_spk = get_spkwav_(P, 0);

vrVrms_site = single(S0.vrThresh_site(:)) / P.qqFactor;
vrSnr_evt = single(abs(S0.vrAmp_spk(:))) ./ vrVrms_site(S0.viSite_spk(:));
t_dur = double(max(S0.viTime_spk) - min(S0.viTime_spk)) / P.sRateHz;
vrRate_site = cellfun(@numel, S0.cviSpk_site)' / t_dur;
% nSites = numel(S0.cviSpk_site);

% calc # spikes exceeding detection threshold
vnSite_evt = zeros(size(S0.viTime_spk), 'int16');
for iSite = 1:numel(S0.cviSpk_site)
    viSpk_site1 = S0.cviSpk_site{iSite};
    mrMin_site1 = squeeze_(min(tnWav_spk(:,:,viSpk_site1)));
    vrThresh_site1 = -abs(S0.vrThresh_site(P.miSites(:, iSite)));
    vnSite_evt(viSpk_site1) = sum(bsxfun(@lt, mrMin_site1, vrThresh_site1(:)));
end

% cluster meta analysis (cluster of clusters)


% Compute cluster stats
mrMin_clu = uV2bit_(squeeze_(min(S0.S_clu.trWav_spk_clu)));
vrSnr_clu = abs(mrMin_clu(1,:))' ./ vrVrms_site(S0.S_clu.viSite_clu);
vrRate_clu = cellfun(@numel, S0.S_clu.cviSpk_clu)' / t_dur;
mrThresh_clu = -abs(S0.vrThresh_site(P.miSites(:,S0.S_clu.viSite_clu)));
vnSite_clu = sum(mrMin_clu < mrThresh_clu)';

S_plot = makeStruct_(vrVrms_site, vrRate_site, t_dur, P, ...
    vrSnr_evt, vnSite_evt, vrSnr_clu, vrRate_clu, vnSite_clu);
end %func


%--------------------------------------------------------------------------
function save_var_(vcFile, varargin)
% must pass 
struct_save_(struct_(varargin{:}), vcFile);
end


%--------------------------------------------------------------------------
function S_plot_show(cS_plot_file)
% plot clusters of clusters
% @TODO
end %func


%--------------------------------------------------------------------------
function [sd2, viRange1, viRange2] = mr_std2_(mr, nDelay)
if nDelay==0, sd2 = std(mr,1,2); return; end

% determine shift
nT = size(mr,1);
iShift1 = -round(nDelay/2);
iShift2 = nDelay + iShift1;
viRange1 = max((1:nT) + iShift1, 1);
viRange2 = min((1:nT) + iShift2, nT);

mr1 = mr(viRange1,:);
mr2 = mr(viRange2,:);

sd2 = sqrt(abs(mean(mr1.*mr2,2) - mean(mr1,2).*mean(mr2,2)));  
end %func


%--------------------------------------------------------------------------
function sd2 = mr_std3_(mr, viRange1, viRange2)
mr1 = mr(viRange1,:);
mr2 = mr(viRange2,:);
sd2 = sqrt(abs(mean(mr1.*mr2,2) - mean(mr1,2).*mean(mr2,2)));  
end %func


%--------------------------------------------------------------------------
function trCorr = xcorr_mr_(mrPv_clu, nShift)
% vrDist12 = xcorr_mr_(mrWav1, mrWav2, nShift)
% vrDist12 = xcorr_mr_(mrWav1, mrWav2, cvi1, cvi2)
if nShift==0
    trCorr = corr_(mrPv_clu);
    return;
end
nT = size(mrPv_clu,1);
[cvi1, cvi2] = shift_range_(nT, nShift);
nClu = size(mrPv_clu,2);
trCorr = zeros([nClu, nClu, numel(cvi1)], 'like', mrPv_clu);
for iShift = 1:numel(cvi1)    
    trCorr(:,:,iShift) = corr_(mrPv_clu(cvi1{iShift},:), mrPv_clu(cvi2{iShift},:));
end
end %func


%--------------------------------------------------------------------------
function mr = madscore_(mr)
% maximum absolute difference transformation

mr = bsxfun(@minus, mr, median(mr));
vr = median(abs(mr));
mr = bsxfun(@rdivide, mr, vr);
end %func


%--------------------------------------------------------------------------
function [mrPc1, mrPc2] = pca_tr_(tn)
% returns first principal component across sites
% persistent tn_
% global tnWav_spk
% 
% if nargin<1, tn = tn_; end
% if isempty(tn)
%     tn_ = tnWav_spk;
%     tn = tn_;
% end

% mrPv = zeros(size(tr,1), size(tr,3), 'single');
mrPc1 = zeros(size(tn,2), size(tn,3), 'single');
mrPc2 = ifeq_(nargout>1, mrPc1, []);
        
% tr = single(tr);
% n = size(tn,2);
tr = meanSubt_tr_(single(tn));
nSpk = size(tn,3);
% tic
if isempty(mrPc2)
    parfor iSpk = 1:nSpk
        mr1 = tr(:,:,iSpk);
        [V,D] = eig(mr1*mr1');
        D = sqrt(diag(D));
        mrPc1(:,iSpk) = V(:,end)' * mr1 / D(end); %V(:,end)' * mr1;
    end
else
    parfor iSpk = 1:nSpk
        mr1 = tr(:,:,iSpk);
        [V,D] = eig(mr1*mr1');
        D = sqrt(diag(D));
        mrPc1(:,iSpk) = V(:,end)' * mr1 / D(end); %V(:,end)' * mr1;
        mrPc2(:,iSpk) = V(:,end-1)' * mr1 / D(end-1); %V(:,end)' * mr1;
    end
end
% toc
end %func


%--------------------------------------------------------------------------
function mrPc1 = pc1_tr_(tn)
% returns first principal component across sites

mr0 = single(squeeze_(tn(:,1,:)));
vrPv0 = zscore_(pca(mr0', 'NumComponents', 1));
dimm_tn = size(tn);
mr = single(reshape(tn, dimm_tn(1), []));
mr = bsxfun(@minus, mr, mean(mr));
mrPc1 = reshape(vrPv0' * mr, dimm_tn(2:3));
end %func


%--------------------------------------------------------------------------
function tr = meanSubt_tr_(tr)
dimm = size(tr);
mr = reshape(tr,size(tr,1),[]);
mr = bsxfun(@minus, mr, mean(mr));
tr = reshape(mr, dimm);
end %func


%--------------------------------------------------------------------------
function export_(varargin)
% export_(): export S0 struct to the workspace
% export_(var1, var2): export fields in S0 struct to the workspace
nArgs = nargin();
% Directly import .prm file
if ~isempty(varargin)
    if matchFileEnd_(varargin{1}, '.prm')
        vcFile_mat = strrep(varargin{1}, '.prm', '_jrc.mat');
        if ~exist_file_(vcFile_mat, 1), return; end
        vcVar = 'S0';
        assignin('base', vcVar, load(vcFile_mat));
        fprintf('assigned ''%s'' to workspace\n', vcVar);
        return;
    end
end
csVars = varargin;
csVars = csVars(~isempty_(csVars));
if isempty(csVars), csVars = {'S0'}; end
S0 = get(0, 'UserData');
for iArg = 1:numel(csVars)
    vcVar = csVars{iArg};
    if isempty(vcVar), continue; end
    if ~strcmpi(vcVar, 'S0')
        var = get_(S0, vcVar);
    else
        var = S0;
    end
    if isempty(var)
        fprintf(2, '''%s'' does not exist\n', vcVar);
    else
        assignin('base', vcVar, var);
        fprintf('assigned ''%s'' to workspace\n', vcVar);
    end
end
end %func


%--------------------------------------------------------------------------
function vl = isempty_(cvr)
if iscell(cvr)
    vl = cellfun(@isempty, cvr);
else
    vl = isempty(cvr);
end
end %func


%--------------------------------------------------------------------------
function S0 = clear_log_(S0)
S0.cS_log = {};
S0.miClu_log = [];
set(0, 'UserData', S0);
delete_files_(strrep(S0.P.vcFile_prm, '.prm', '_log.mat'), 0);
end %func


%--------------------------------------------------------------------------
function S0 = auto_(P)
if get_set_(P, 'fRepeat_clu', 0) || ~is_sorted_(P) 
    S0 = sort_(P);
    return;
end

[S0, P] = load_cached_(P); % load cached data or from file if exists
S_clu = get_(S0, 'S_clu');
S_clu.P = P;
[S_clu, S0] = post_merge_(S_clu, P);
S0 = clear_log_(S0);
save0_(strrep(P.vcFile_prm, '.prm', '_jrc.mat'));
end %func


%--------------------------------------------------------------------------
function ydB = pow2db_(y)
ydB = (10.*log10(y)+300)-300;
end %func


%--------------------------------------------------------------------------
function mr12 = pdist2_(mr1, mr2)
% mr12 = pdist2_(mr1) % self distance
% mr12 = pdist2_(mr1, mr2)
% mr1: n1xd, mr2: n2xd, mr12: n1xn2

% mr12 = sqrt(eucl2_dist_(mr1', mr2'));
% 20% faster than pdist2 for 10000x10 x 100000x10 single
if nargin==2
    mr12 = sqrt(bsxfun(@plus, sum(mr2'.^2), bsxfun(@minus, sum(mr1'.^2)', 2*mr1*mr2')));
else
    vr1 = sum(mr1'.^2);
    mr12 = sqrt(bsxfun(@plus, vr1, bsxfun(@minus, vr1', 2*mr1*mr1')));
end
end %func


%--------------------------------------------------------------------------
function z = zscore_(x, flag, dim)
if isempty(x), z=[]; return; end
if nargin < 2, flag = 0; end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu = mean(x,dim);
sigma = std(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);
end %func


%--------------------------------------------------------------------------
function C = corr_(A, B, fMeanSubt)
% mr = corr_(A, B)
% mr = corr_(A) % n1 x n2 becomes n1 x 
% mr = corr_(vr1, vr2) % single coefficient
if nargin<3, fMeanSubt = 1; end
% https://stackoverflow.com/questions/9262933/what-is-a-fast-way-to-compute-column-by-column-correlation-in-matlab
if fMeanSubt, A = bsxfun(@minus,A,mean(A)); end %% zero-mean
A = bsxfun(@times,A,1./sqrt(sum(A.^2))); %% L2-normalization
if nargin == 1
    C = A' * A;
else
    if fMeanSubt, B = bsxfun(@minus,B,mean(B)); end %%% zero-mean
    B = bsxfun(@times,B,1./sqrt(sum(B.^2))); %% L2-normalization
    C = A' * B;
end
end %func


%--------------------------------------------------------------------------
% 6/23/JJJ

%--------------------------------------------------------------------------
function traces_(P, fDebug_ui_, vcFileId, fPlot_lfp)
% show raw traces
% If file format is nChans x nSamples, load subset of file (fTranspose=1)
% If file format is nSamples x nChans, load all and save to global (fTranspose=0)
% 2017/6/22 James Jun: Added multiview (nTime_traces )
global fDebug_ui mnWav mnWav1 % only use if P.fTranspose=0
if nargin<4, fPlot_lfp = 0; end
if nargin==0
    P = get0_('P'); 
else
    set0_(P);
end
if nargin<2, fDebug_ui_=0; end
if nargin<3, vcFileId=''; end
if isempty(P), disperr_('traces_: P is empty'); return; end
% S0 = load0_(P);
fDebug_ui = fDebug_ui_;
if ~fPlot_lfp
    S0 = load_cached_(P, 0);
    set(0, 'UserData', S0);
    set0_(fDebug_ui);
else
    S0 = struct('P', P);
    set(0, 'UserData', S0);
end
% S0 = load_cached_(P, 0); %don't load raw waveform

% get file to show
iFile_show = 1; %files to display for clustered together
if ~isempty(P.csFile_merge)
    csFiles_bin = filter_files_(P.csFile_merge);
    if numel(csFiles_bin)==1
        vcFile_bin = csFiles_bin{1}; 
    else %show multiple files        
        if isempty(vcFileId)
            arrayfun(@(i)fprintf('%d: %s\n', i, csFiles_bin{i}), 1:numel(csFiles_bin), 'UniformOutput', 0);
            fprintf('---------------------------------------------\n');
            vcFileId = input('Please specify Fild ID from the list above:', 's');
        end
        if isempty(vcFileId), return; end
        iFile_show = str2num(vcFileId);        
        try
            vcFile_bin = csFiles_bin{iFile_show};
        catch
            return;
        end
    end
else
    vcFile_bin = P.vcFile; % if multiple files exist, load first
end
set0_(iFile_show);
tlim_bin = P.tlim;

% Open file
fprintf('Opening %s\n', vcFile_bin);
[fid_bin, nBytes_bin, header_offset] = fopen_(vcFile_bin, 'r');
if P.header_offset ~= header_offset && header_offset > 0
    P.header_offset = header_offset;
    set0_(P); % update header_offset for .ns5 format
end
if isempty(fid_bin), fprintf(2, '.bin file does not exist: %s\n', vcFile_bin); return; end
nSamples_bin = floor(nBytes_bin / bytesPerSample_(P.vcDataType) / P.nChans);
nLoad_bin = min(round(diff(tlim_bin) * P.sRateHz), nSamples_bin);
if tlim_bin(1)>0
    iSample_bin = ceil(tlim_bin(1) * P.sRateHz) + 1; %offset sample number    
else
    iSample_bin = 1; %sample start location
end    
nlim_bin = [0,nLoad_bin-1] + iSample_bin;
if nlim_bin(1) < 1, nlim_bin = [1, nLoad_bin]; end
if nlim_bin(2) > nSamples_bin, nlim_bin = [-nLoad_bin+1, 0] + nSamples_bin; end

nTime_traces = get_(P, 'nTime_traces');
[cvn_lim_bin, viRange_bin] = sample_skip_(nlim_bin, nSamples_bin, nTime_traces);    
if P.fTranspose_bin   
    mnWav = [];
    fseek_(fid_bin, iSample_bin, P);
    if nTime_traces > 1            
        mnWav1 = load_bin_multi_(fid_bin, cvn_lim_bin, P)';        
    else        
        mnWav1 = load_bin_(fid_bin, P.vcDataType, [P.nChans, nLoad_bin])'; %next keypress: update tlim_show    
    end
%     @TODO: load from cvn_lim_bin specifiers. check for end or beginning when keyboard command
else %load whole thing
    mnWav = load_bin_(fid_bin, P.vcDataType, [nSamples_bin, P.nChans]); %next keypress: update tlim_show
    fclose(fid_bin);
    fid_bin = []; 
    %mnWav1 = mnWav((nlim_bin(1):nlim_bin(2)), :);
    mnWav1 = mnWav(viRange_bin, :);
    disp('Entire raw traces are cached to RAM since fTranspose=0.');
end %if
mnWav1 = uint2int_(mnWav1);

% full screen width
hFig_traces = create_figure_('Fig_traces', [0 0 .5 1], vcFile_bin, 0, 1); %remove all other figure traces
hAx = axes_new_(hFig_traces); % create axis
hPlot = line(hAx, nan, nan, 'Color', [1 1 1]*.5, 'Parent', hAx, 'LineWidth', .5);
hPlot_edges = plot(nan, nan, 'Color', [1 0 0]*.5, 'Parent', hAx, 'LineWidth', 1);
set(hAx, 'Position',[.05 .05 .9 .9], 'XLimMode', 'manual', 'YLimMode', 'manual');
S_fig = makeStruct_(hAx, hPlot, nlim_bin, fid_bin, nSamples_bin, nLoad_bin, hPlot_edges);
S_fig.maxAmp = P.maxAmp;
S_fig.vcTitle = '[H]elp; (Sft)[Up/Down]:Scale(%0.1f uV); (Sft)[Left/Right]:Time; [F]ilter; [J]ump T; [C]han. query; [R]eset view; [P]SD; [S]pike; [A]ux chan; [E]xport; [T]race; [G]rid';
S_fig.csHelp = { ...    
    'Left/Right: change time (Shift: x4)', ...
    '[J]ump T', ...
    '[Home/End]: go to beginning/end of file', ...
    '---------', ...
    'Up/Down: change scale (Shift: x4)', ...
    'Zoom: Mouse wheel', ...
    '[x/y/ESC]: zoom direction', ...
    'Pan: hold down the wheel and drag', ...
    '[R]eset view', ...
    '---------', ...
    '[F]ilter toggle', ...
    '[S]pike toggle', ...
    'Gri[D] toggle', ...
    '[T]races toggle', ... 
    '---------', ...    
    '[C]hannel query', ...
    '[A]ux channel display', ...
    '[P]ower spectrum', ...    
    '[E]xport to workspace', ...
    };
S_fig = struct_merge_(S_fig, ...
    struct('vcGrid', 'on', 'vcFilter', 'off', 'vcSpikes', 'on', 'vcTraces', 'on'));
set(hFig_traces, 'UserData', S_fig);
set(hFig_traces, 'color', 'w', 'KeyPressFcn', @keyPressFcn_Fig_traces_, 'BusyAction', 'cancel', 'CloseRequestFcn', @close_hFig_traces_);
mouse_figure(hFig_traces);

Fig_traces_plot_(1); % Plot spikes and color clusters 
end %func


%--------------------------------------------------------------------------
function mn = uint2int_(mn)
if isa(mn, 'uint16')
    mn = int16(single(mn)-2^15);
elseif isa(mn, 'uint32')
    mn = int32(double(mn)-2^31);
end
end


%--------------------------------------------------------------------------
% plot data
function Fig_traces_plot_(fAxis_reset)
% fAxis_reset: reset the axis limit
% [usage]
% Fig_traces_plot_()
% Fig_traces_plot_(fAxis_reset)
% 2017/06/22 James Jun
% 6/22 JJJ: added seperator lines, fixed the reset view and spike view

global mnWav1 mrWav1 % current timeslice to plot
if nargin<1, fAxis_reset = 0; end
fWait = msgbox_('Plotting...',0,1);
fShuttleOrder = 1; %shuffle cluster color
[S0, P, S_clu] = get0_();
[hFig, S_fig] = get_fig_cache_('Fig_traces'); 
figure_wait_(1, hFig);
sRateHz = P.sRateHz / P.nSkip_show;
viSamples1 = 1:P.nSkip_show:size(mnWav1,1);
spkLim = round(P.spkLim / P.nSkip_show); %show 2x of range
P.vcFilter = get_filter_(P);
if strcmpi(S_fig.vcFilter, 'on')
    P1=P; P1.sRateHz = sRateHz; P1.fGpu = 0;
    P1.vcFilter = get_set_(P, 'vcFilter_show', P.vcFilter);
    if P.fft_thresh>0, mnWav1 = fft_clean_(mnWav1, P); end
    mrWav1 = bit2uV_(filt_car_(mnWav1(viSamples1, P.viSite2Chan), P1), P1);
    vcFilter_show = P1.vcFilter;
else
    mrWav1 = meanSubt_(single(mnWav1(viSamples1, P.viSite2Chan))) * P.uV_per_bit;    
    vcFilter_show = 'off';
end
viSites = 1:numel(P.viSite2Chan);
% mrWav1 = meanSubt_(single(mnWav1(:, P.viSite2Chan))) * P.uV_per_bit;
% hide bad channels
nTime_traces = get_(P, 'nTime_traces');
if isempty(nTime_traces) || nTime_traces==1
    vrTime_bin = ((S_fig.nlim_bin(1):P.nSkip_show:S_fig.nlim_bin(end))-1) / P.sRateHz;    
    vcXLabel = 'Time (s)';
else    
    vrTime_bin = (0:(size(mrWav1,1)-1)) / (P.sRateHz / P.nSkip_show) + (S_fig.nlim_bin(1)-1) / P.sRateHz;
    [cvn_lim_bin, viRange_bin, viEdges] = sample_skip_(S_fig.nlim_bin, S_fig.nSamples_bin, nTime_traces);
    tlim_show = (cellfun(@(x)x(1), cvn_lim_bin([1,end]))) / P.sRateHz;
    vcXLabel = sprintf('Time (s), %d segments merged (%0.1f ~ %0.1f s, %0.2f s each)', nTime_traces, tlim_show, diff(P.tlim));
    mrX_edges = vrTime_bin(repmat(viEdges(:)', [3,1]));
    mrY_edges = repmat([0;numel(P.viSite2Chan)+1;nan],1,numel(viEdges));
    set(S_fig.hPlot_edges, 'XData', mrX_edges(:), 'YData', mrY_edges(:));
    csTime_bin = cellfun(@(x)sprintf('%0.1f', x(1)/P.sRateHz), cvn_lim_bin, 'UniformOutput', 0);
    set(S_fig.hAx, {'XTick', 'XTickLabel'}, {vrTime_bin(viEdges), csTime_bin});
end
multiplot(S_fig.hPlot, S_fig.maxAmp, vrTime_bin, mrWav1, viSites);
% axis(S_fig.hAx, [vrTime_bin(1), vrTime_bin(end), viSites(1)-1, viSites(end)+1]);
grid(S_fig.hAx, S_fig.vcGrid);
set(S_fig.hAx, 'YTick', viSites);
title_(S_fig.hAx, sprintf(S_fig.vcTitle, S_fig.maxAmp));
xlabel(S_fig.hAx, vcXLabel); 
ylabel(S_fig.hAx, 'Site #'); 
set(S_fig.hPlot, 'Visible', S_fig.vcTraces);

% Delete spikes from other threads
S_fig_ = get(hFig, 'UserData');
if isfield(S_fig_, 'chSpk'), delete_multi_(S_fig_.chSpk); end
if isfield(S_fig, 'chSpk'), delete_multi_(S_fig.chSpk); end

% plot spikes
if strcmpi(S_fig.vcSpikes, 'on') && isfield(S0, 'viTime_spk')
    viTime_spk = int32(S0.viTime_spk) - int32(S0.viT_offset_file(S0.iFile_show));
    if nTime_traces > 1
        viSpk1 = find(in_range_(viTime_spk, cvn_lim_bin));
        [viSite_spk1, viTime_spk1] = multifun_(@(vr)vr(viSpk1), S0.viSite_spk, viTime_spk);
        viTime_spk1 = round(reverse_lookup_(viTime_spk1, viRange_bin) / P.nSkip_show);
    else
        viSpk1 = find(viTime_spk >= S_fig.nlim_bin(1) & viTime_spk < S_fig.nlim_bin(end));
        [viSite_spk1, viTime_spk1] = multifun_(@(vr)vr(viSpk1), S0.viSite_spk, viTime_spk);
        viTime_spk1 = round((viTime_spk1 - S_fig.nlim_bin(1) + 1) / P.nSkip_show); %time offset
    end        
    t_start1 = single(S_fig.nlim_bin(1) - 1) / P.sRateHz;
    viSite_spk1 = single(viSite_spk1);
    % check if clustered
    if isempty(S_clu)
        nSites = size(mrWav1,2);
        chSpk = cell(nSites, 1);
        for iSite=1:nSites %deal with subsample factor
            viSpk11 = find(viSite_spk1 == iSite);
            if isempty(viSpk11), continue; end
            viTime_spk11 = viTime_spk1(viSpk11);
            [mrY11, mrX11] = vr2mr3_(mrWav1(:,iSite), viTime_spk11, spkLim); %display purpose x2
%             vr2mr_spk_(mrWav1(:,iSite), viTime_spk11, P);
            mrT11 = single(mrX11-1) / sRateHz + t_start1;
            chSpk{iSite} = line(nan, nan, 'Color', [1 0 0], 'LineWidth', 1.5, 'Parent', S_fig.hAx);
            multiplot(chSpk{iSite}, S_fig.maxAmp, mrT11, mrY11, iSite);
        end        
    else % different color for each clu
        viClu_spk1 = S_clu.viClu(viSpk1);        
        mrColor_clu = [jet(S_clu.nClu); 0 0 0];        
        vrLineWidth_clu = (mod((1:S_clu.nClu)-1, 3)+1)'/2 + .5;  %(randi(3, S_clu.nClu, 1)+1)/2;
        if fShuttleOrder
            mrColor_clu = shuffle_static_(mrColor_clu, 1);
            vrLineWidth_clu = shuffle_static_(vrLineWidth_clu, 1);
        end
        nSpk1 = numel(viTime_spk1);
        chSpk = cell(nSpk1, 1);
        for iSpk1 = 1:nSpk1
            iTime_spk11 = viTime_spk1(iSpk1);
            iSite11 = viSite_spk1(iSpk1);
            [mrY11, mrX11] = vr2mr3_(mrWav1(:,iSite11), iTime_spk11, spkLim); %display purpose x2
            mrT11 = double(mrX11-1) / sRateHz + t_start1;
            iClu11 = viClu_spk1(iSpk1);
            if iClu11<=0, continue; end
%                 vrColor1 = [0 0 0]; 
%                 lineWidth1 = .5;
%             else
            vrColor1 = mrColor_clu(iClu11,:);
            lineWidth1 = vrLineWidth_clu(iClu11);
%             end
            chSpk{iSpk1} = line(nan, nan, 'Color', vrColor1, 'LineWidth', lineWidth1, 'Parent', S_fig.hAx);
            multiplot(chSpk{iSpk1}, S_fig.maxAmp, mrT11, mrY11, iSite11);
        end
    end
    S_fig.chSpk = chSpk;
else
    % delete spikes    
    S_fig.chSpk = [];    
end
if fAxis_reset, fig_traces_reset_(S_fig); end
set(hFig, 'UserData', S_fig, 'Name', sprintf('%s: filter: %s', P.vcFile_prm, (vcFilter_show)));
figure_wait_(0, hFig);
close_(fWait);
end %func


%--------------------------------------------------------------------------
function fig_traces_reset_(S_fig)
global mnWav1

if nargin<1, [hFig, S_fig] = get_fig_cache_('Fig_traces');  end
% axis(S_fig.hAx, [S_fig.nlim_bin / P.sRateHz, 0, nSites+1]);
P = get0_('P');
nTime_traces = get_(P, 'nTime_traces');
if nTime_traces > 1
    tlim1 = ([0, size(mnWav1,1)] + S_fig.nlim_bin(1) - 1) / P.sRateHz;
    tlim1 = round(tlim1*1000)/1000;
    axis_(S_fig.hAx, [tlim1, 0, numel(P.viSite2Chan)+1]);
else
    axis_(S_fig.hAx, [S_fig.nlim_bin / P.sRateHz, 0, numel(P.viSite2Chan)+1]);
end 
end %func


%--------------------------------------------------------------------------
function [cvnlim_bin, viRange, viEdges] = sample_skip_(nlim_bin, nSamples_bin, nTime_traces)
% return a limit that 
% nlim_bin=[81 90]; nSamples_bin=100; nTime_traces=5;
% edges to set to nan
% 2017/6/22 James Jun: Added nTime_traces multiview
% 6/23 JJJ: edge samples to be set to nan (gap)

if nTime_traces==1 || isempty(nTime_traces)
    cvnlim_bin = {nlim_bin};
    viRange = nlim_bin(1):nlim_bin(end);
    viEdges = [];
    return;
end
nSkip = floor(nSamples_bin / nTime_traces);
cvnlim_bin = arrayfun(@(i)nlim_bin + (i-1)*nSkip, 1:nTime_traces, 'UniformOutput', 0);
% modulus algebra wrap around
for i=1:nTime_traces
    lim1 = mod(cvnlim_bin{i}-1, nSamples_bin)+1;
    if lim1(1) > lim1(2)
        lim1 = [1, diff(nlim_bin)+1];
    end
    cvnlim_bin{i} = lim1;
end
if nargout>=2
    viRange = cell2mat_(cellfun(@(x)x(1):x(2), cvnlim_bin, 'UniformOutput', 0));
end
if nargout>=3 %compute the number of samples
    viEdges = cumsum(cellfun(@(x)diff(x)+1, cvnlim_bin));
    viEdges = [1, viEdges(1:end-1)];
%     viEdges = sort([viEdges, viEdges+1], 'ascend'); %two sample gaps
end
end %func


%--------------------------------------------------------------------------
function vl = in_range_(vi, cvi)
vl = false(size(vi));
if ~iscell(cvi), cvi = {cvi}; end
for i=1:numel(cvi)
    lim1 = cvi{i};
    vl = vl | (vi >= lim1(1) & vi <= lim1(2));
end
end %func


%--------------------------------------------------------------------------
function [viA, vl] = reverse_lookup_(viB, viA2B)
% viB must belong to viA2B
% viB=[3 1 1 5 3 3 2]; viA2B=[1 3 5];
if nargin<2
    viA = zeros(size(viB), 'like', viB);
    viA(viB) = 1:numel(viB); 
    vl = [];
    return;
end

[vl, viA] = ismember(int32(viB), int32(viA2B));

% vl = ismember(viB, viA2B);
% assert_(all(vl), 'reverse_lookup_: all viB must belong to viA2B');
% viA = arrayfun(@(i)find(viA2B==i), viB(vl), 'UniformOutput', 1); 
end %func


%--------------------------------------------------------------------------
function [tnWav_spk_raw, tnWav_spk, trFet_spk, miSite_spk, viTime_spk, vnAmp_spk, vnThresh_site, fGpu] = ...
    wav2spk_(mnWav1, P, viTime_spk, viSite_spk, mnWav1_pre, mnWav1_post)
% tnWav_spk: spike waveform. nSamples x nSites x nSpikes
% trFet_spk: nSites x nSpk x nFet
% miSite_spk: nSpk x nFet
% spikes are ordered in time
% viSite_spk and viTime_spk is uint32 format, and tnWav_spk: single format
% mnWav1: raw waveform (unfiltered)
% wav2spk_(mnWav1, vrWav_mean1, P)
% wav2spk_(mnWav1, vrWav_mean1, P, viTime_spk, viSite_spk)
% 6/27/17 JJJ: accurate spike detection at the overlap region
% 6/29/17 JJJ: matched filter supported

if nargin<4, viTime_spk = []; end
if nargin<5, viSite_spk = []; end
if nargin<6, mnWav1_pre = []; end
if nargin<7, mnWav1_post = []; end
[tnWav_spk_raw, tnWav_spk, trFet_spk, miSite_spk] = deal([]);
nFet_use = get_set_(P, 'nFet_use', 2);
fMerge_spk = 1; %debug purpose
fShift_pos = 0; % shift center position based on center of mass
% fRecenter_spk = 0;
nSite_use = P.maxSite*2+1 - P.nSites_ref;
if nSite_use==1, nFet_use=1; end
vnThresh_site = get0_('vnThresh_site');
nPad_pre = size(mnWav1_pre,1);
fGpu = P.fGpu;

%-----
% Filter
fprintf('\tFiltering spikes...\n\t'); t_filter = tic;
if ~isempty(mnWav1_pre) || ~isempty(mnWav1_post)
    mnWav1 = [mnWav1_pre; mnWav1; mnWav1_post];
end
if get_set_(P, 'fSmooth_spatial', 0)
    mnWav1 = spatial_smooth_(mnWav1, P);
end
% [mnWav2, vnWav11, mnWav1, P.fGpu] = wav_preproces_(mnWav1, P);
mnWav1_ = mnWav1; % keep a copy in CPU
try        
    [mnWav1, P.fGpu] = gpuArray_(mnWav1, P.fGpu);
    if P.fft_thresh>0, mnWav1 = fft_clean_(mnWav1, P); end
    [mnWav2, vnWav11] = filt_car_(mnWav1, P);    
catch % GPU failure
    P.fGpu = 0;
    mnWav1 = mnWav1_;
    if P.fft_thresh>0, mnWav1 = fft_clean_(mnWav1, P); end
    [mnWav2, vnWav11] = filt_car_(mnWav1, P);
end
mnWav1_ = []; %remove from memory


%-----
% common mode rejection
if P.blank_thresh > 0
    if isempty(vnWav11)
        vnWav11 = mr2ref_(mnWav2, P.vcCommonRef, P.viSiteZero); %vrWav_mean1(:);    
    end
    vlKeep_ref = car_reject_(vnWav11(:), P);
    fprintf('Rejecting %0.3f %% of time due to motion\n', (1-mean(vlKeep_ref))*100 );
else
    vlKeep_ref = [];
end
% set0_(vlKeep_ref);
fprintf('\ttook %0.1fs\n', toc(t_filter));
vcFilter_detect = get_set_(P, 'vcFilter_detect', '');
switch lower(vcFilter_detect)
    case {'', 'none', 'xcov'}, mnWav3 = mnWav2;
    case {'ndist'}
        [mnWav3, nShift_post] = filter_detect_(mnWav1, P); % pass raw trace
    otherwise
        [mnWav3, nShift_post] = filter_detect_(mnWav2, P); % pass filtered trace
end

%-----
% detect spikes or use the one passed from the input (importing)
if isempty(vnThresh_site)
    try
        vnThresh_site = gather_(int16(mr2rms_(mnWav3, 1e5) * P.qqFactor));
    catch
        vnThresh_site = int16(mr2rms_(gather_(mnWav3), 1e5) * P.qqFactor);
        P.fGpu = 0;
    end
end
if isempty(viTime_spk) || isempty(viSite_spk)
    P_ = setfield(P, 'nPad_pre', nPad_pre);
    switch lower(vcFilter_detect)
        case 'xcov'
            [viTime_spk, vnAmp_spk, viSite_spk] = detect_spikes_xcov_(mnWav1, vlKeep_ref, P_);
        otherwise
            [viTime_spk, vnAmp_spk, viSite_spk] = detect_spikes_(mnWav3, vnThresh_site, vlKeep_ref, P_);
    end
else
    viTime_spk = viTime_spk + nPad_pre;
    vnAmp_spk = mnWav3(sub2ind(size(mnWav3), viTime_spk, viSite_spk)); % @TODO read spikes at the site and time
end
vnAmp_spk = gather_(vnAmp_spk);

% reject spikes within the overlap region
if ~isempty(mnWav1_pre) || ~isempty(mnWav1_post)    
    ilim_spk = [nPad_pre+1, size(mnWav3,1) - size(mnWav1_post,1)]; %inclusive
    viKeep_spk = find(viTime_spk >= ilim_spk(1) & viTime_spk <= ilim_spk(2));
    [viTime_spk, vnAmp_spk, viSite_spk] = multifun_(@(x)x(viKeep_spk), viTime_spk, vnAmp_spk, viSite_spk);    
end%if
if isempty(viTime_spk), return; end


%-----
% Extract spike waveforms and build a spike table
fprintf('\tExtracting features'); t_fet = tic;
if get_set_(P, 'fRaw_feature', 0), mnWav2 = mnWav1; end
vcFilter_feature = get_set_(P, 'vcFilter_feature', '');
if ~isempty(vcFilter_feature)
    [mnWav2, nShift_post] = filter_detect_(mnWav1, P, vcFilter_feature); % pass raw trace
end

viSite_spk_ = gpuArray_(viSite_spk, P.fGpu);
[tnWav_spk_raw, tnWav_spk, viTime_spk] = mn2tn_wav_(mnWav1, mnWav2, viSite_spk_, viTime_spk, P); fprintf('.');
if nFet_use >= 2
    viSite2_spk = find_site_spk23_(tnWav_spk, viSite_spk_, P);
    tnWav_spk2 = mn2tn_wav_spk2_(mnWav2, viSite2_spk, viTime_spk, P);
else
    [viSite2_spk, tnWav_spk2] = deal([]);
end
% clean waveforms by sites
if 0
    tnWav_spk = tr_denoise_site_(tnWav_spk, viSite_spk, P);
    tnWav_spk2 = tr_denoise_site_(tnWav_spk2, viSite2_spk, P);
end

%-----
if get_set_(P, 'fCancel_overlap', 0)
    try
        [tnWav_spk, tnWav_spk2] = cancel_overlap_spk_(tnWav_spk, tnWav_spk2, viTime_spk, viSite_spk, viSite2_spk, vnThresh_site, P); 
    catch
        fprintf(2, 'fCancel_overlap failed\n');
    end
end

tnWav_spk_raw = gather_(tnWav_spk_raw);
assert_(nSite_use >0, 'nSites_use = maxSite*2+1 - nSites_ref must be greater than 0');
switch nFet_use
    case 3
        [viSite2_spk, viSite3_spk] = find_site_spk23_(tnWav_spk, viSite_spk_, P); fprintf('.');
        mrFet1 = trWav2fet_(tnWav_spk, P); fprintf('.');
        mrFet2 = trWav2fet_(tnWav_spk2, P); fprintf('.');
        mrFet3 = trWav2fet_(mn2tn_wav_spk2_(mnWav2, viSite3_spk, viTime_spk, P), P); fprintf('.');
        trFet_spk = permute(cat(3, mrFet1, mrFet2, mrFet3), [1,3,2]); %nSite x nFet x nSpk
        miSite_spk = [viSite_spk_(:), viSite2_spk(:), viSite3_spk(:)]; %nSpk x nFet
    case 2        
        mrFet1 = trWav2fet_(tnWav_spk, P); fprintf('.');
        mrFet2 = trWav2fet_(tnWav_spk2, P); fprintf('.');
        trFet_spk = permute(cat(3, mrFet1, mrFet2), [1,3,2]); %nSite x nFet x nSpk
        miSite_spk = [viSite_spk_(:), viSite2_spk(:)]; %nSpk x nFet
    case 1
        mrFet1 = trWav2fet_(tnWav_spk, P); fprintf('.');
        trFet_spk = permute(mrFet1, [1,3,2]); %nSite x nFet x nSpk
        miSite_spk = [viSite_spk_(:)];
    otherwise
        error('wav2spk_: nFet_use must be 1, 2 or 3');
end

if get_set_(P, 'fClean_fet', 0) %clean feature using knn ( use it for nFet_use==2
    trFet_spk = clean_fet_knn_(trFet_spk, viSite_spk_, viSite2_spk, P);
end

if nPad_pre > 0, viTime_spk = viTime_spk - nPad_pre; end
[viTime_spk, trFet_spk, miSite_spk, tnWav_spk] = ...
    gather_(viTime_spk, trFet_spk, miSite_spk, tnWav_spk);
fGpu = P.fGpu;
fprintf('\ttook %0.1fs\n', toc(t_fet));
end %func


%--------------------------------------------------------------------------
% 9/29/2018 JJJ: use knn to clean up the feature fector
function trFet_spk = clean_fet_knn_(trFet_spk, viSite_spk, viSite2_spk, P)
nSites = numel(P.viSite2Chan);
fprintf('Cleaning feature using non-local averaging\n\t'); t1=tic;
P1 = setfield(P, 'knn', 8); % find four nearest neighbors to average
dimm0 = [size(trFet_spk,1), 1];
for iSite = 1:nSites
    viSpk1_ = find(viSite_spk==iSite);
    viSpk2_ = find(viSite2_spk==iSite);
    [n1_, n2_] = deal(numel(viSpk1_), numel(viSpk2_));  
    n12_ = n1_ + n2_;
    mrFet1_ = squeeze_(trFet_spk(:,1,viSpk1_));
    mrFet2_ = squeeze_(trFet_spk(:,2,viSpk2_));
    if n1_ > 0    
        viSpk12_ = [viSpk1_(:); viSpk2_(:)];
        mrFet12_ = [mrFet1_, mrFet2_];
        [~, ~, miKnn12_] = cuda_knn_(mrFet12_, 1:n12_, 1:n1_, P1);
        trFet_spk(:,1,viSpk1_) = reshape(average_fet_(mrFet12_, miKnn12_), [dimm0, n1_]);
    end
    if n2_ > 0
        viSpk21_ = [viSpk2_(:); viSpk1_(:)];
        mrFet21_ = [mrFet2_, mrFet1_];
        [~, ~, miKnn21_] = cuda_knn_(mrFet21_, 1:n12_, 1:n2_, P1);    
        trFet_spk(:,2,viSpk2_) = reshape(average_fet_(mrFet21_, miKnn21_), [dimm0, n2_]);
    end
    fprintf('.');    
end
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 9/29/2018 JJJ: 
function mrFet1 = average_fet_(mrFet, miKnn1)
% average features using knn
[~, n] = size(miKnn1);
mrFet = gather_(mrFet);
mrFet1 = zeros([size(mrFet,1), n], 'like', mrFet);
for i=1:n
    mrFet1(:,i) = mean(mrFet(:, miKnn1(:,i)), 2);
end
end %func


%--------------------------------------------------------------------------
% 9/28/2018 JJJ: High pass filter
function mr = highpass_(mn, nAve);
mr = zeros(size(mn), 'single');
vrFilt = ones(nAve,1,'single') / nAve;
if isGpu_(mn), vrFilt = gpuArray_(vrFilt); end
fprintf('\nhighpass filtering\n\t'); t1=tic;
for i=1:size(mr,2)
    vr_ = single(gpuArray_(mn(:,i)));
    mr(:,i) = gather_(vr_ - conv(vr_, vrFilt, 'same'));
    fprintf('.');
end
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 12/16/17 JJJ: Find overlapping spikes and set superthreshold sample points to zero in the overlapping region 
function [tnWav_spk_out, tnWav_spk2_out] = cancel_overlap_spk_(tnWav_spk, tnWav_spk2, viTime_spk, viSite_spk, viSite2_spk, vnThresh_site, P)
% Overlap detection. only return one stronger than other
fGpu = isGpu_(tnWav_spk);
[viTime_spk, tnWav_spk, tnWav_spk2] = gather_(viTime_spk, tnWav_spk, tnWav_spk2);
[viSpk_ol_spk, vnDelay_ol_spk, vnCount_ol_spk] = detect_overlap_spk_(viTime_spk, viSite_spk, P);
[tnWav_spk_out, tnWav_spk2_out] = deal(tnWav_spk, tnWav_spk2);
% find spike index that are larger and fit and deploy
viSpk_ol_a = find(viSpk_ol_spk>0); % later occuring
[viSpk_ol_b, vnDelay_ol_b] = deal(viSpk_ol_spk(viSpk_ol_a), vnDelay_ol_spk(viSpk_ol_a)); % first occuring
viTime_spk0 = int32(P.spkLim(1):P.spkLim(2));
vnThresh_site = gather_(-abs(vnThresh_site(:))');
% for each pair identify time range where threshold crossing occurs and set to zero
% correct only first occuring (b)
miSites = P.miSites;
nSpk_ol = numel(viSpk_ol_a);
nSpk = size(tnWav_spk,2);
for iSpk_ol = 1:nSpk_ol    
    [iSpk_b, nDelay_b] = deal(viSpk_ol_b(iSpk_ol), vnDelay_ol_b(iSpk_ol));
    viSite_b = miSites(:,viSite_spk(iSpk_b));
    mnWav_b = tnWav_spk_out(nDelay_b+1:end,:,iSpk_b);
    mlWav_b = bsxfun(@le, mnWav_b, vnThresh_site(viSite_b));
    mnWav_b(mlWav_b) = 0;
    tnWav_spk_out(nDelay_b+1:end,:,iSpk_b) = mnWav_b;
    
%     vnWav_b = median(tnWav_spk(nDelay_b+1:end,:,iSpk_b), 2);
%     tnWav_spk_out(nDelay_b+1:end,:,iSpk_b) = repmat(vnWav_b, 1, nSpk);
%     mnWav_b(nDelay_b+1:end,:) = repmat(vnWav_b, 1, nSpk);
%     mlWav_b(1:nDelay_b,:) = 0; % safe time zone. remainders get cancelled
%     mnWav_b(mlWav_b) = 0; % spike cancelled
    
    if ~isempty(tnWav_spk2)
        viSite_b = miSites(:,viSite2_spk(iSpk_b));
        mnWav_b = tnWav_spk2_out(nDelay_b+1:end,:,iSpk_b);
        mlWav_b = bsxfun(@le, mnWav_b, vnThresh_site(viSite_b));
        mnWav_b(mlWav_b) = 0;
        tnWav_spk2_out(nDelay_b+1:end,:,iSpk_b) = mnWav_b;
    end
end %for
% tnWav_spk = gpuArray_(tnWav_spk, fGpu);
%     [iSite_a, iSite_b] = deal(viSite_spk(iSpk_a), viSite_spk(iSpk_b));
%     [viSite_a, viSite_b] = deal(miSites(:,iSite_a), miSites(:,iSite_b));
%     [viSite_ab, via_, vib_] = intersect(viSite_a, viSite_b);    
    
    
%     if isempty(viSite_ab), continue; end    
    
    % find points under threshold
%     [mnWav_a, mnWav_b] = deal(tnWav_spk(:,via_,iSpk_a), tnWav_spk(:,vib_,iSpk_b));
%     vnThresh_ab = -vnThresh_site(viSite_ab);
%     [mlWav_a, mlWav_b] = deal(bsxfun(@lt, mnWav_a, vnThresh_ab), bsxfun(@lt, mnWav_b, vnThresh_ab));
%     
    
%     
    % correct both A and B by removing super-threshold points
%     [mnWav_a, mnWav_b] = deal(tnWav_spk(:,:,iSpk_a), tnWav_spk(:,:,iSpk_b));
%     [mlWav_a, mlWav_b] = deal(bsxfun(@lt, mnWav_a, -vnThresh_site(viSite_a)), bsxfun(@lt, mnWav_b, -vnThresh_site(viSite_b)));
%     nDelay_b = vnDelay_ol_b(iSpk_ol);
    
    % set no overthreshold zone based on the delay, set it to half. only set superthreshold spikes to zero    
end %func


%--------------------------------------------------------------------------
% 12/16/17 JJJ: find overlapping spikes. only return spikes more negative than others
function [viSpk_ol_spk, vnDelay_ol_spk, vnCount_ol_spk] = detect_overlap_spk_(viTime_spk, viSite_spk, P);

mrDist_site = squareform(pdist(P.mrSiteXY));
nlimit = int32(diff(P.spkLim));
maxDist_site_um = P.maxDist_site_um;
nSpk = numel(viTime_spk);
nSites = max(viSite_spk);
cviSpk_site = arrayfun(@(iSite)int32(find(viSite_spk==iSite)), (1:nSites)', 'UniformOutput', 0);
viTime_spk = gather_(viTime_spk);
[viSpk_ol_spk, vnDelay_ol_spk, vnCount_ol_spk] = deal(zeros(size(viSite_spk), 'int32'));
for iSite = 1:nSites
    viSpk1 = cviSpk_site{iSite};    
    if isempty(viSpk1), continue; end
    viSite2 = find(mrDist_site(:,iSite) <= maxDist_site_um & mrDist_site(:,iSite) > 0);
    viSpk2 = cell2mat_(cviSpk_site(viSite2));    
    [n1, n2] = deal(numel(viSpk1), numel(viSpk2));
    viSpk12 = [viSpk1(:); viSpk2(:)];
    [viTime1, viTime12] = deal(viTime_spk(viSpk1), viTime_spk(viSpk12));
        
    % find overlapping spikes that has smaller amplitudes and within site limit
%     [viOverlap1, viDelay1] = deal(zeros(size(viTime12), 'like', viTime12));
%     vlOverlap1 = false(size(viTime1));    
    for iDelay = 0:nlimit
        [vl12_, vi1_] = ismember(viTime12, viTime1 + iDelay);
        if iDelay == 0 , vl12_(1:n1) = 0; end % exclude same site comparison
        vi12_ = find(vl12_);
        if isempty(vi12_), continue; end
        [viSpk1_, viSpk12_] = deal(viSpk1(vi1_(vi12_)), viSpk12(vi12_));
%         viiSpk_ = find(viTime_spk(viSpk12_) < viTime_spk(viSpk1_)); % pick earlier time only
%         if isempty(viiSpk_), continue; end;
%         [viSpk1_, viSpk12_] = deal(viSpk1_(viiSpk_), viSpk12_(viiSpk_));
        viSpk_ol_spk(viSpk12_) = viSpk1_;
        vnDelay_ol_spk(viSpk12_) = iDelay;
        vnCount_ol_spk(viSpk12_) = vnCount_ol_spk(viSpk12_) + 1; % 13% spikes collide
    end
end
end %func


%--------------------------------------------------------------------------
% 11/15/17 JJJ: Cast the threshold like the vrWav1
function [viSpk1, vrSpk1, thresh1] = spikeDetectSingle_fast_(vrWav1, P, thresh1)
% P: spkThresh, qqSample, qqFactor, fGpu, uV_per_bit
% vrWav1 can be either single or int16
% 6/27/17 JJJ: bugfix: hard set threshold is applied

% Determine threshold
MAX_SAMPLE_QQ = 300000; 
% fSpikeRefrac_site = 0;
if nargin < 3, thresh1 = []; end
if nargin < 2, P = struct('spkThresh', [], 'qqFactor', 5); end
if ~isempty(get_(P, 'spkThresh')), thresh1 = P.spkThresh; end

if thresh1==0, [viSpk1, vrSpk1] = deal([]); return; end % bad site
if isempty(thresh1)
    thresh1 = median(abs(subsample_vr_(vrWav1, MAX_SAMPLE_QQ)));
    thresh1 = single(thresh1)* P.qqFactor / 0.6745;
end
thresh1 = cast(thresh1, 'like', vrWav1); % JJJ 11/5/17

% detect valley turning point. cannot detect bipolar
% pick spikes crossing at least three samples
nneigh_min = get_set_(P, 'nneigh_min_detect', 0);
viSpk1 = find_peak_(vrWav1, thresh1, nneigh_min);
if get_set_(P, 'fDetectBipolar', 0)
   viSpk1 = [viSpk1; find_peak_(-vrWav1, thresh1, nneigh_min)]; 
   viSpk1 = sort(viSpk1);
end
if isempty(viSpk1)
    viSpk1 = double([]);
    vrSpk1 = int16([]);
else
    vrSpk1 = vrWav1(viSpk1);
    % Remove spikes too large
    spkThresh_max_uV = get_set_(P, 'spkThresh_max_uV', []);
    if ~isempty(spkThresh_max_uV)
        thresh_max1 = abs(spkThresh_max_uV) / get_set_(P, 'uV_per_bit', 1);
        thresh_max1 = cast(thresh_max1, 'like', vrSpk1);
        viA1 = find(abs(vrSpk1) < abs(thresh_max1));
        viSpk1 = viSpk1(viA1);
        vrSpk1 = vrSpk1(viA1); 
    end        
end

% apply spike merging on the same site
% nRefrac = int32(abs(P.spkRefrac));
% if P.refrac_factor > 1
%     nRefrac = int32(round(double(nRefrac) * P.refrac_factor));
% end
if isGpu_(viSpk1)
    [viSpk1, vrSpk1, thresh1] = multifun_(@gather, viSpk1, vrSpk1, thresh1);
end
% if fSpikeRefrac_site %perform spike refractive period per site (affects exact mode)
%     [viSpk1, vrSpk1] = spike_refrac_(viSpk1, vrSpk1, [], nRefrac); %same site spikes
% end
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_position_(S_clu, viClu_update)
% determine cluster position from spike position
% 6/27/17 JJJ: multiple features supported (single dimension such as energy and Vpp)
global trFet_spk
if nargin<2, viClu_update = []; end
P = get0_('P'); %P = S_clu.P;
if ~isfield(S_clu, 'vrPosX_clu'), S_clu.vrPosX_clu = []; end
if ~isfield(S_clu, 'vrPosY_clu'), S_clu.vrPosY_clu = []; end

if isempty(S_clu.vrPosX_clu) || ~isempty(S_clu.vrPosY_clu)
    viClu_update = [];
end
if isempty(viClu_update)
    [vrPosX_clu, vrPosY_clu] = deal(zeros(S_clu.nClu, 1));
    viClu1 = 1:S_clu.nClu;
else % selective update
    vrPosX_clu = S_clu.vrPosX_clu;
    vrPosY_clu = S_clu.vrPosY_clu;
    viClu1 = viClu_update(:)';
end
viSites_fet = 1:(1+P.maxSite*2-P.nSites_ref);
for iClu = viClu1
%     viSpk_clu1 = S_clu.cviSpk_clu{iClu};
    [viSpk_clu1, viSites_clu1] = S_clu_subsample_spk_(S_clu, iClu);
    if isempty(viSpk_clu1), continue; end
    
    viSites_clu1 = viSites_clu1(1:end-P.nSites_ref);
    mrVp1 = squeeze_(trFet_spk(viSites_fet,1,viSpk_clu1));
    mrSiteXY1 = single(P.mrSiteXY(viSites_clu1,:)); %electrode
    
    vrPosX_clu(iClu) = median(centroid_mr_(mrVp1, mrSiteXY1(:,1), 2));
    vrPosY_clu(iClu) = median(centroid_mr_(mrVp1, mrSiteXY1(:,2), 2));
end
S_clu.vrPosX_clu = vrPosX_clu;
S_clu.vrPosY_clu = vrPosY_clu;
end %func


%--------------------------------------------------------------------------
function [mn1, nShift_post] = filter_detect_(mn, P, vcMode)
% returns spatial sd
% mn0 = single(mn);
% mn0 = bsxfun(@minus, mn0, mean(mn0, 2)) .^ 2;
% 6/29/17 JJJ: filter detection

if nargin<3, vcMode = get_(P, 'vcFilter_detect'); end

viSites_use = 1:(1+2*P.maxSite - P.nSites_ref);
viSites_ref = (1+2*P.maxSite - P.nSites_ref+1):(1+2*P.maxSite);
fprintf('filter_detect\n\t'); t1= tic;
miSites = gpuArray_(P.miSites(viSites_use, :));
miSites_ref = gpuArray_(P.miSites(viSites_ref, :));
nShift_post = 0;
switch lower(vcMode)
%     case 'xcov'
%         % use nearest neighbors to compute local xcov
%         mn1 = xcov_filt_local_(mn, P);
    case 'bandpass'
        mn1 = ms_bandpass_filter_(mn, P);
%         try
%             mn = gather_(mn);
%             mn1 = filtfilt_chain(single(mn), P);
%         catch
%             fprintf('GPU filtering failed. Trying CPU filtering.\n');
%             mn1 = filtfilt_chain(single(mn), setfield(P, 'fGpu', 0));
%         end
%         mn1 = int16(mn1);  
    case 'fir1'
        n5ms = round(P.sRateHz / 1000 * 5);
        vrFilter = single(fir1_(n5ms, P.freqLim/P.sRateHz*2));
        for i=1:size(mn,2)
            mn(:,i) = conv(mn(:,i), vrFilter, 'same'); 
        end   
        mn1 = mn;
    case 'ndiff', mn1 = ndiff_(mn, P.nDiff_filt);        
    case 'ndist'
        mn1 = ndist_filt_(mn, get_set_(P, 'ndist_filt', 5));
    case 'chancor'
        mn1 = chancor_(mn, P);        
    case 'matched'
        vrFilt_spk = get0_('vrFilt_spk');
        if isempty(vrFilt_spk)
            lim_ = round([3,5]/8 * size(mn,1));
            mn_ = mn(lim_(1):lim_(2),:);
            [vrFilt_spk, vrVaf, nShift_post] = calc_matched_filt_(mn_, P); %detect primary 
            set0_(vrFilt_spk, nShift_post);
        else
            nShift_post = get0_('nShift_post');
        end
%         nShift_post = nShift_post_;
        mn1 = int16(conv2(single(gather_(mn)), vrFilt_spk(:), 'same'));
%         mn1 = shift_mr_(mn1, nShift_post); % or do it later in the spike detection phase
%         figure; plot(xcorr(mn(:,41), mn1(:,41), 10));
%         nShift_post = P.spkLim(1)-1;
    case 'autocov'
        mn1 = -int16(filt_corr(single(mn), 2));
    case 'std-chan'
        mn1 = zeros(size(mn), 'like', mn);
        for iSite=1:size(mn,2)
            %mn_ = mn(:, P.miSites(viSites_use, iSite));
            %vn_ref = mean(mn_(:,viSites_ref),2);
            %mn_ = bsxfun(@minus, mn_(:,viSites_use), vn_ref);
           % mn1(:, iSite) = -int16(std(single(mn(:, P.miSites(:, iSite))), 0, 2));
            mn1(:, iSite) = -int16(std(single(mn(:, miSites(:,iSite))), 1, 2));
            %mn1(:,iSite) = mean(mn_.^2,2) - mean(mn_,2).^2;
            fprintf('.');
        end
        
    case 'std-time'
        % envelop filter. this affects the threshold. 
        
    case 'nmean'
        mn1 = filter_nmean_local_(mn, P);
        
end %switch
fprintf('\n\ttook %0.1fs\n', toc(t1));
% mn1 = -int16(sqrt(mn1 / size(P.miSites,1)));
end %func


%--------------------------------------------------------------------------
% 9/27/2018 JJJ: compute local spatial mean using nearby channels
function mn1 = filter_nmean_local_(mn, P)

viSites_use = 1:(1+2*P.maxSite - P.nSites_ref);
miSites = P.miSites(viSites_use, :);

mn1 = zeros(size(mn), 'like', mn);
mr_ = zeros(size(mn), 'single');
nAve = round(.01*P.sRateHz);
vhFilt = gpuArray_(ones(nAve,1,'single') / nAve);
fprintf('\n\t');
switch 2
    case 2
        mr_ = single(gather_(mn));
    case 1
        for iSite = 1:size(mn,2)
            vr_ = single(gpuArray_(mn(:,iSite)));    
            mr_(:,iSite) = gather_(vr_ - conv(vr_, vhFilt, 'same'));
            fprintf('.');
        end
end
fprintf('\n\t');
for iSite=1:size(mn,2)
    mn1(:, iSite) = int16(mean(mr_(:,miSites(:,iSite)), 2));
    fprintf('.');
end

end %func


%--------------------------------------------------------------------------
function S0 = file2spk_(P, viTime_spk0, viSite_spk0)
% function [tnWav_raw, tnWav_spk, trFet_spk, S0] = file2spk_(P, viTime_spk0, viSite_spk0)
% file loading routine. keep spike waveform (tnWav_spk) in memory
% assume that the file is chan x time format
% usage:
% [tnWav_raw, tnWav_spk, S0] = file2spk_(P)
%   
% [tnWav_raw, tnWav_spk, S0] = file2spk_(P, viTime_spk, viSite_spk)
%   construct spike waveforms from previous time markers
% 6/29/17 JJJ: Added support for the matched filter

if nargin<2, viTime_spk0 = []; end
if nargin<3, viSite_spk0 = []; end
S0 = [];
% [tnWav_raw, tnWav_spk, trFet_spk, S0] = deal([]);

viTime_spk0 = viTime_spk0(:);
viSite_spk0 = viSite_spk0(:);

if isempty(P.csFile_merge)
    if ~exist_file_(P.vcFile), P.vcFile = subsDir_(P.vcFile, P.vcFile_prm); end
    csFile = {P.vcFile};    
else
    csFile = filter_files_(P.csFile_merge);
    if isempty(csFile)
        P.csFile_merge = subsDir_(P.csFile_merge, P.vcFile_prm);
        csFile = filter_files_(P.csFile_merge);
    end
end
if ~isempty(get_(P, 'vcFile_thresh'))
    try
        S_thresh = load(P.vcFile_thresh);
        vnThresh_site = S_thresh.vnThresh_site;
        set0_(vnThresh_site);
        fprintf('Loaded %s\n', P.vcFile_thresh);
    catch
        disperr_('vcFile_thresh load error');
    end
end
if isempty(csFile), error('No binary files found.'); end
% [tnWav_raw, tnWav_spk, trFet_spk, miSite_spk, viTime_spk, vrAmp_spk, vnThresh_site] = deal({});    
[miSite_spk, viTime_spk, vrAmp_spk, vnThresh_site] = deal({});    
viT_offset_file = zeros(size(csFile));
nFiles = numel(csFile);    
[nSamples1, nLoads] = deal(0); % initialize the counter
[vrFilt_spk, mrPv_global] = deal([]); % reset the template
set0_(mrPv_global, vrFilt_spk); % reeset mrPv_global and force it to recompute
write_spk_(P.vcFile_prm);
for iFile=1:nFiles
    fprintf('File %d/%d: detecting spikes from %s\n', iFile, nFiles, csFile{iFile});
    t1 = tic;
    [fid1, nBytes_file1] = fopen_(csFile{iFile}, 'r');
    nBytes_file1 = file_trim_(fid1, nBytes_file1, P);
    [nLoad1, nSamples_load1, nSamples_last1] = plan_load_(nBytes_file1, P);
%         nSamples1 = 0; %accumulated sample offset        
    viT_offset_file(iFile) = nSamples1;
    mnWav11_pre = [];
    for iLoad1 = 1:nLoad1
        fprintf('Processing %d/%d of file %d/%d...\n', iLoad1, nLoad1, iFile, nFiles);
        nSamples11 = ifeq_(iLoad1 == nLoad1, nSamples_last1, nSamples_load1);
        fprintf('\tLoading from file...'); t_load_ = tic;
        mnWav11 = load_file_(fid1, nSamples11, P);
        fprintf('took %0.1fs\n', toc(t_load_));
        if iLoad1 < nLoad1
            mnWav11_post = load_file_preview_(fid1, P);
        else
            mnWav11_post = [];
        end
        [viTime_spk11, viSite_spk11] = filter_spikes_(viTime_spk0, viSite_spk0, nSamples1 + [1, nSamples11]);
        [tnWav_raw_, tnWav_spk_, trFet_spk_, miSite_spk{end+1}, viTime_spk{end+1}, vrAmp_spk{end+1}, vnThresh_site{end+1}, P.fGpu] ...
                = wav2spk_(mnWav11, P, viTime_spk11, viSite_spk11, mnWav11_pre, mnWav11_post);
        write_spk_(tnWav_raw_, tnWav_spk_, trFet_spk_);
        viTime_spk{end} = viTime_spk{end} + nSamples1;
        nSamples1 = nSamples1 + nSamples11;
        if iLoad1 < nLoad1, mnWav11_pre = mnWav11(end-P.nPad_filt+1:end, :); end
        clear mnWav11 vrWav_mean11;
        nLoads = nLoads + 1;
    end %for
    fclose(fid1);   
    t_dur1 = toc(t1);
    t_rec1 = (nBytes_file1 / bytesPerSample_(P.vcDataType) / P.nChans) / P.sRateHz;
    fprintf('File %d/%d took %0.1fs (%0.1f MB, %0.1f MB/s, x%0.1f realtime)\n', ...
        iFile, nFiles, ...
        t_dur1, nBytes_file1/1e6, nBytes_file1/t_dur1/1e6, t_rec1/t_dur1);
end %for
write_spk_();

[miSite_spk, viTime_spk, vrAmp_spk, vnThresh_site] = ...
    multifun_(@(x)cat(1, x{:}), miSite_spk, viTime_spk, vrAmp_spk, vnThresh_site);
vrThresh_site = mean(single(vnThresh_site),1);
viSite_spk = miSite_spk(:,1);
if size(miSite_spk,2) >= 2
    viSite2_spk = miSite_spk(:,2);
else
    viSite2_spk = [];
end

% set S0
[dimm_raw, dimm_spk, dimm_fet] = deal(size(tnWav_raw_), size(tnWav_spk_), size(trFet_spk_));
[dimm_raw(3), dimm_spk(3), dimm_fet(3)] = deal(numel(viTime_spk));
nSites = numel(P.viSite2Chan);
cviSpk_site = arrayfun(@(iSite)find(miSite_spk(:,1) == iSite), 1:nSites, 'UniformOutput', 0);
if size(miSite_spk,2) >= 2
    cviSpk2_site = arrayfun(@(iSite)find(miSite_spk(:,2) == iSite), 1:nSites, 'UniformOutput', 0);
else
    cviSpk2_site = cell(1, nSites);
end
if size(miSite_spk,2) >= 3
    cviSpk3_site = arrayfun(@(iSite)find(miSite_spk(:,3) == iSite), 1:nSites, 'UniformOutput', 0);
else
    cviSpk3_site = [];
end
[mrPv_global, vrD_global] = get0_('mrPv_global', 'vrD_global');
S0 = makeStruct_(P, viSite_spk, viSite2_spk, viTime_spk, vrAmp_spk, vrThresh_site, dimm_spk, ...
    cviSpk_site, cviSpk2_site, cviSpk3_site, dimm_raw, viT_offset_file, dimm_fet, nLoads, ...
    mrPv_global, vrFilt_spk, vrD_global);
end %func


%--------------------------------------------------------------------------
% 6/29/17 JJJ: distance-based neighboring unit selection
function mrWavCor = S_clu_wavcor_(S_clu, P, viClu_update)
% symmetric matrix and common basis comparison only

nInterp_merge = get_set_(P, 'nInterp_merge', 1); % set to 1 to disable
fDrift_merge = get_set_(P, 'fDrift_merge', 0);
P.fGpu = 0;

if nargin<3, viClu_update = []; end
if ~isfield(S_clu, 'mrWavCor'), viClu_update = []; end
fprintf('Computing waveform correlation...'); t1 = tic;

fWavRaw_merge = get_set_(P, 'fWavRaw_merge', 1);
if fWavRaw_merge
    tmrWav_clu = S_clu.tmrWav_raw_clu;
else
    tmrWav_clu = S_clu.tmrWav_spk_clu;
end
if fDrift_merge
    if fWavRaw_merge % only works on raw
        ctmrWav_clu = {tmrWav_clu, S_clu.tmrWav_raw_lo_clu, S_clu.tmrWav_raw_hi_clu};
    else
        ctmrWav_clu = {tmrWav_clu, S_clu.tmrWav_spk_lo_clu, S_clu.tmrWav_spk_hi_clu};
    end
else
    ctmrWav_clu = {tmrWav_clu};
end
if nInterp_merge>1
    ctmrWav_clu = cellfun(@(x)interpft_(x, nInterp_merge), ctmrWav_clu, 'UniformOutput', 0);
end
nClu = S_clu.nClu;
% mrWavCor = gpuArray_(zeros(nClu), P.fGpu);
mrWavCor = zeros(nClu);
nSites_spk = P.maxSite*2+1-P.nSites_ref;
if isempty(viClu_update)
    vlClu_update = true(nClu, 1);
    mrWavCor0 = [];
    fParfor = 1;
else    
    vlClu_update = false(nClu, 1);
    vlClu_update(viClu_update) = 1;
    mrWavCor0 = S_clu.mrWavCor;
    nClu_pre = size(mrWavCor0, 1);
    vlClu_update((1:nClu) > nClu_pre) = 1;
    fParfor = sum(vlClu_update) > 8;
end
if size(mrWavCor0,1) < size(mrWavCor,1)
    mrWavCor0(nClu,nClu) = 0; %expand the matrix
end

fParfor = fParfor && get_set_(P, 'fParfor', 1);
cctrWav_lag_clu = clu_wav_cache_(ctmrWav_clu, P);
% fParfor = 0; %debug
if fParfor
    try
        parfor iClu2 = 1:nClu  %parfor speedup: 4x
            vrWavCor2 = clu_wavcor_(cctrWav_lag_clu, S_clu.viSite_clu, P, vlClu_update, mrWavCor0, iClu2);    
            if ~isempty(vrWavCor2), mrWavCor(:, iClu2) = vrWavCor2; end
        end
    catch
        fprintf('S_clu_wavcor_: parfor failed. retrying for loop\n');
        fParfor = 0;
    end
end
if ~fParfor   
    for iClu2 = 1:nClu  %parfor speedup: 4x
        vrWavCor2 = clu_wavcor_(cctrWav_lag_clu, S_clu.viSite_clu, P, vlClu_update, mrWavCor0, iClu2);    
        if ~isempty(vrWavCor2), mrWavCor(:, iClu2) = vrWavCor2; end
    end
end
mrWavCor = max(mrWavCor, mrWavCor'); %make it symmetric
mrWavCor(mrWavCor==0) = nan;
% mrWavCor = gather_(mrWavCor);
fprintf('\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function maxcorr = corr_lag_(mr1, mr2, nShift)
[vrCorr1, vrCorr2] = deal(zeros(nShift, 1));
for iShift=1:nShift
    v1 = mr1(1:end-iShift+1,:);
    v2 = mr2(iShift:end,:);    
    vrCorr1(iShift) = corr_(v1(:), v2(:));
    
    v2 = mr2(1:end-iShift+1,:);
    v1 = mr1(iShift:end,:);    
    vrCorr2(iShift) = corr_(v1(:), v2(:));    
end
maxcorr = max(max(vrCorr1), max(vrCorr2));
end %func


%--------------------------------------------------------------------------
function [mrWav1, mrWav2] = S_clu_wav_pair_(S_clu, S0, tnWav_raw, iClu1, iClu2)
persistent viT
if nargin==0, viT=[]; return; end

[mrWav1, mrWav2] = deal([]);
[xy1, xy2] = deal(S_clu.mrPos_clu(:,iClu1), S_clu.mrPos_clu(:,iClu2));
xy12 = (xy1+xy2)/2;
[viSpk1, viSpk2] = deal(S_clu.cviSpk_clu{iClu1}, S_clu.cviSpk_clu{iClu2});
if isempty(viSpk2), return; end
% find spikes near each others centroid
mrPos_spk = S0.mrPos_spk;
nTime_clu = get_set_(S0.P, 'nTime_clu', 4);
nSamples_max = 1000;
miSites = S0.P.miSites;

if isempty(viT)
    spkLim_raw = get_(S0.P, 'spkLim_raw');
    nSamples_raw = diff(spkLim_raw) + 1;
%     viT = 1:nSamples_raw;
    spkLim_factor_merge = get_set_(S0.P, 'spkLim_factor_merge', 1);
    spkLim_merge = round(S0.P.spkLim * spkLim_factor_merge);
    viT = (spkLim_merge(1) - spkLim_raw(1) + 1):(nSamples_raw - spkLim_raw(2) + spkLim_merge(2));
end
[mrPos_spk1, mrPos_spk2] = deal(S0.mrPos_spk(viSpk1,:), S0.mrPos_spk(viSpk2,:));
if 0
    mrDist12 = eucl2_dist_(mrPos_spk1', mrPos_spk2');
%     mrDist12 = pdist2(mrPos_spk1, mrPos_spk2);
    vrD1 = min(mrDist12,[],2);
    vrD2 = min(mrDist12,[],1);
else
    % find spikes nearest to the center
%     [vrD1, vrD2] = deal(pdist2(xy2', mrPos_spk1), pdist2(xy1', mrPos_spk2));
    vrD1 = sum(bsxfun(@minus, mrPos_spk1, xy2').^2,2);
    vrD2 = sum(bsxfun(@minus, mrPos_spk2, xy1').^2,2);
%     [vrD1, vrD2] = deal(pdist2(xy2', mrPos_spk1), pdist2(xy1', mrPos_spk2));
    % [vl1, vl2] = multifun_(@(x)select_ascend_frac_(x, 1/nTime_clu), vrD1, vrD2);
end
vl1 = select_ascend_frac_(vrD1, 1/nTime_clu);
vl2 = select_ascend_frac_(vrD2, 1/nTime_clu);
    
% find centered spikes and average their waveforms
[viSpk1, viSpk2] = deal(viSpk1(vl1), viSpk2(vl2)); % select nearby units
%[viSite1, viSite2] = multifun_(@(x)S0.viSite_spk(x), viSpk1, viSpk2);
viSite1 = S0.viSite_spk(viSpk1);
viSite2 = S0.viSite_spk(viSpk2);
if isempty(viSpk2) || isempty(viSite1), return; end
[iSite1, iSite2] = deal(mode(viSite1), mode(viSite2)); % center site for clu1, 2
[viSpk1, viSpk2] = deal(viSpk1(viSite1==iSite1), viSpk2(viSite2==iSite2)); % pick centered sites
%[viSpk1, viSpk2] = multifun_(@(x)subsample_vr_(x, nSamples_max), viSpk1, viSpk2); % spike selection
viSpk1 = subsample_vr_(viSpk1, nSamples_max);
viSpk2 = subsample_vr_(viSpk2, nSamples_max);
if iSite1 == iSite2
    mrWav1 = meanSubt_(single(mean(tnWav_raw(viT, :, viSpk1),3)));
    mrWav2 = meanSubt_(single(mean(tnWav_raw(viT, :, viSpk2),3)));
else
    try
        [~, vi1_, vi2_] = intersect(miSites(:,iSite1), miSites(:,iSite2));
    catch
        disperr_();
    end
    if isempty(vi1_) || isempty(vi2_)
        return;
    else
    %     [mrWav1, mrWav2] = deal(tnWav_raw(viT, vi1_, viSpk1), tnWav_raw(viT, vi2_, viSpk2));
        %[mrWav1, mrWav2] = multifun_(@(x)meanSubt_(single(mean(x,3))), mrWav1, mrWav2);
        mrWav1 = meanSubt_(single(mean(tnWav_raw(viT, vi1_, viSpk1),3)));
        mrWav2 = meanSubt_(single(mean(tnWav_raw(viT, vi2_, viSpk2),3)));
    end
end
end %func


%--------------------------------------------------------------------------
function vl = select_ascend_frac_(vr, frac)
% return logical that matches the dimension of vr, return the lowest fraction
if frac==1
    vl = true(size(vr));
elseif frac == 0
    vl = false(size(vr));
else
    vl = false(size(vr));
    [~, vi] = sort(vr, 'ascend');
    n = numel(vr);
    n1 = min(max(round(n * frac), 1), n);
    vl(vi(1:n1)) = true;
end
end %func


%--------------------------------------------------------------------------
function tmrWav = trim_spkraw_(tmrWav, P)
spkLim_raw = get_(P, 'spkLim_raw');
nSamples_raw = diff(spkLim_raw) + 1;
spkLim_factor_merge = get_set_(P, 'spkLim_factor_merge', 1);
spkLim_merge = round(P.spkLim * spkLim_factor_merge);
nSamples_raw_merge = diff(spkLim_merge) + 1;
if size(tmrWav,1) <= nSamples_raw_merge, return ;end

lim_merge = [spkLim_merge(1) - spkLim_raw(1) + 1,  nSamples_raw - spkLim_raw(2) + spkLim_merge(2)];
tmrWav = tmrWav(lim_merge(1):lim_merge(2), :, :);
tmrWav = meanSubt_(tmrWav);
end %func


%--------------------------------------------------------------------------
% 10/27/17 JJJ: distance-based neighboring unit selection
function vrWavCor2 = clu_wavcor__(ctmrWav_clu, cviSite_clu, P, cell_5args, iClu2)

[vlClu_update, cviShift1, cviShift2, mrWavCor0, fMode_cor] = deal(cell_5args{:});
if numel(cviSite_clu) == 1
    viSite_clu = cviSite_clu{1};
    fUsePeak2 = 0;    
else
    [viSite_clu, viSite2_clu, viSite3_clu] = deal(cviSite_clu{:});
    fUsePeak2 = 1;
end
nClu = numel(viSite_clu);
iSite_clu2 = viSite_clu(iClu2);    
if iSite_clu2==0 || isnan(iSite_clu2), vrWavCor2 = []; return; end
viSite2 = P.miSites(:,iSite_clu2); 
% if fMaxSite_excl, viSite2 = viSite2(2:end); end
if fUsePeak2
    viClu1 = find(viSite_clu == iSite_clu2 | viSite2_clu == iSite_clu2 | viSite3_clu == iSite_clu2 | ...
            viSite_clu == viSite2_clu(iClu2) | viSite_clu == viSite3_clu(iClu2)); %viSite2_clu == viSite2_clu(iClu2) 
else
    maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
    viClu1 = find(ismember(viSite_clu, findNearSite_(P.mrSiteXY, iSite_clu2, maxDist_site_um)));
end

vrWavCor2 = zeros(nClu, 1, 'single');
viClu1(viClu1 >= iClu2) = []; % symmetric matrix comparison
if isempty(viClu1), return; end
cmrWav_clu2 = cellfun(@(x)x(:,viSite2,iClu2), ctmrWav_clu, 'UniformOutput', 0);
ctmrWav_clu1 = cellfun(@(x)x(:,viSite2,viClu1), ctmrWav_clu, 'UniformOutput', 0);
for iClu11 = 1:numel(viClu1)
    iClu1 = viClu1(iClu11);
    if ~vlClu_update(iClu1) && ~vlClu_update(iClu2)
        vrWavCor2(iClu1) = mrWavCor0(iClu1, iClu2);
    else            
        iSite_clu1 = viSite_clu(iClu1);
        if iSite_clu1==0 || isnan(iSite_clu1), continue; end                
        if iSite_clu1 == iSite_clu2
            cmrWav_clu2_ = cmrWav_clu2;
            cmrWav_clu1_ = cellfun(@(x)x(:,:,iClu11), ctmrWav_clu1, 'UniformOutput', 0);
        else
            viSite1 = P.miSites(:,iSite_clu1);
            viSite12 = find(ismember(viSite2, viSite1));
            if isempty(viSite12), continue; end
            cmrWav_clu2_ = cellfun(@(x)x(:,viSite12), cmrWav_clu2, 'UniformOutput', 0);
            cmrWav_clu1_ = cellfun(@(x)x(:,viSite12,iClu11), ctmrWav_clu1, 'UniformOutput', 0);
        end                
        vrWavCor2(iClu1) = maxCor_drift__(cmrWav_clu2_, cmrWav_clu1_, cviShift1, cviShift2, fMode_cor);
    end        
end %iClu2 loop
end %func


%--------------------------------------------------------------------------
% 8/27/2018 JJJ: Cache waveform delays
function cctrWav_lag_clu = clu_wav_cache_(ctmrWav_clu, P)
frac_shift_merge = get_set_(P, 'frac_shift_merge', .1); % allow 10% shift if set to .1

% identify other clusters to update

if get_set_(P, 'fWavRaw_merge', 1)
    vi0 = (P.spkLim(1):P.spkLim(2)) - P.spkLim_raw(1) + 1;
else
    nShift_max = round((diff(P.spkLim)+1) * frac_shift_merge); % allow 
    vi0 = (P.spkLim(1)+nShift_max:P.spkLim(2)-nShift_max) - P.spkLim(1) + 1;
end
[nT, nSites, nClu] = size(ctmrWav_clu{1});
nPos = numel(ctmrWav_clu);
cctrWav_lag_clu = cell(nPos, nClu);
for iClu = 1:nClu
    cmr_ = cellfun(@(x)x(:,:,iClu), ctmrWav_clu, 'UniformOutput', 0);
    for iPos = 1:nPos
        tr_ = mr2tr_shift_(cmr_{iPos}, vi0);
        cctrWav_lag_clu{iPos, iClu} = tr_; %nT x nSites x nDelays   
    end
end
end %func


%--------------------------------------------------------------------------
function tr = mr2tr_shift_(mr, vi0)
% vi0 = (P.spkLim(1):P.spkLim(2)) - P.spkLim_raw(1) + 1;
nInterp = 1;
viShift = (1-vi0(1)):(1/nInterp):(size(mr,1)-vi0(end)); 

% fix tr1 and move tr2
tr = zeros([numel(vi0), size(mr,2), numel(viShift)], 'like', mr);
for iShift = 1:numel(viShift)
    vi_ = vi0 + viShift(iShift);
    if nInterp==1
        mr_ = mr(vi_,:);
    else
        mr_ = interp1(1:size(mr,1), mr, vi_);
    end
    tr(:,:,iShift) = bsxfun(@minus, mr_, mean(mr_)); % normalize after trimming the channels
end
end %func


%--------------------------------------------------------------------------
% 8/27/18 JJJ: distance-based neighboring unit selection
function vrWavCor2 = clu_wavcor_(cctrWav_lag_clu, viSite_clu, P, vlClu_update, mrWavCor0, iClu2)
frac_shift_merge = get_set_(P, 'frac_shift_merge', .1); % allow 10% shift if set to .1

% identify other clusters to update
nClu = numel(viSite_clu);
iSite_clu2 = viSite_clu(iClu2);    
if iSite_clu2==0 || isnan(iSite_clu2), vrWavCor2 = []; return; end
viSite2 = P.miSites(:,iSite_clu2); 
maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
viClu1 = find(ismember(viSite_clu, findNearSite_(P.mrSiteXY, iSite_clu2, maxDist_site_um)));
[nPos, nLags] = deal(size(cctrWav_lag_clu,1), size(cctrWav_lag_clu{1,1},3));

vrWavCor2 = zeros(nClu, 1, 'single');
viClu1(viClu1 >= iClu2) = []; % symmetric matrix comparison
if isempty(viClu1), return; end

ctrWav_lag_clu2 = cellfun(@(x)x(:,viSite2,:), cctrWav_lag_clu(:,iClu2), 'UniformOutput', 0);
cctrWav_lag_clu1 = cellfun(@(x)x(:,viSite2,:), cctrWav_lag_clu(:,viClu1), 'UniformOutput', 0);
if isempty(mrWavCor0)
    vrWavCor2 = zeros(nClu, 1, 'single');
else
    vrWavCor2 = mrWavCor0(:, iClu2);
end
cmr2_0 = cellfun(@(x)tr2mr_norm_(x, 0), ctrWav_lag_clu2, 'UniformOutput', 0); % cell: nPos x 1
mr2_0 = cat(2, cmr2_0{:});
for iClu11 = 1:numel(viClu1)
    iClu1 = viClu1(iClu11);
    if ~vlClu_update(iClu1) && ~vlClu_update(iClu2), continue; end    
    iSite_clu1 = viSite_clu(iClu1);
    if iSite_clu1==0 || isnan(iSite_clu1), continue; end
    ctrWav_lag_clu1 = cctrWav_lag_clu1(:,iClu11);
    
    if iSite_clu1 == iSite_clu2
        mr2_ = mr2_0;
        cmr2_ = cmr2_0;
        cmr1_ = cellfun(@(x)tr2mr_norm_(x, 0), ctrWav_lag_clu1, 'UniformOutput', 0); % cell: nPos x 1
    else
        viSite1 = P.miSites(:,iSite_clu1);
        viSite12 = find(ismember(viSite2, viSite1));
        if isempty(viSite12), continue; end
        cmr2_ = cellfun(@(x)tr2mr_norm_(x(:,viSite12,:), 0), ctrWav_lag_clu2, 'UniformOutput', 0); % cell: nPos x 1
        mr2_ = cat(2, cmr2_{:});
        cmr1_ = cellfun(@(x)tr2mr_norm_(x(:,viSite12,:), 0), ctrWav_lag_clu1, 'UniformOutput', 0); % cell: nPos x 1        
    end                
    vrWavCor2(iClu1) = max(cellfun(@(x)max(max(x'*mr2_)), cmr1_)); %exhaustive matching
%     vrWavCor2(iClu1) = max(cellfun(@(x,y)max(max(x'*y)), cmr1_, cmr2_)); % pairwise matching
end %iClu2 loop
end %func


%--------------------------------------------------------------------------
% 10/27/17 JJJ: distance-based neighboring unit selection
function vrWavCor2 = clu_wavcor1_(ctmrWav_clu, viSite_clu, P, vlClu_update, mrWavCor0, iClu2)
frac_shift_merge = get_set_(P, 'frac_shift_merge', .1); % allow 10% shift if set to .1

% identify other clusters to update
nClu = numel(viSite_clu);
iSite_clu2 = viSite_clu(iClu2);    
if iSite_clu2==0 || isnan(iSite_clu2), vrWavCor2 = []; return; end
viSite2 = P.miSites(:,iSite_clu2); 
maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
viClu1 = find(ismember(viSite_clu, findNearSite_(P.mrSiteXY, iSite_clu2, maxDist_site_um)));

vrWavCor2 = zeros(nClu, 1, 'single');
viClu1(viClu1 >= iClu2) = []; % symmetric matrix comparison

if isempty(viClu1), return; end
cmrWav_clu2 = cellfun(@(x)x(:,viSite2,iClu2), ctmrWav_clu, 'UniformOutput', 0);
trWav_clu2 = cat(3, cmrWav_clu2{:});
ctmrWav_clu1 = cellfun(@(x)x(:,viSite2,viClu1), ctmrWav_clu, 'UniformOutput', 0);

if get_set_(P, 'fWavRaw_merge', 1)
    vi0 = (P.spkLim(1):P.spkLim(2)) - P.spkLim_raw(1) + 1;
else
    nShift_max = round((diff(P.spkLim)+1) * frac_shift_merge); % allow 
    vi0 = (P.spkLim(1)+nShift_max:P.spkLim(2)-nShift_max) - P.spkLim(1) + 1;
end
% [trWav_clu2, vi0, vrWavCor2] = multifun_(@gpuArray_, trWav_clu2, vi0, vrWavCor2);
for iClu11 = 1:numel(viClu1)
    iClu1 = viClu1(iClu11);
    if ~vlClu_update(iClu1) && ~vlClu_update(iClu2)
        vrWavCor2(iClu1) = mrWavCor0(iClu1, iClu2);
    else            
        iSite_clu1 = viSite_clu(iClu1);
        if iSite_clu1==0 || isnan(iSite_clu1), continue; end                
        if iSite_clu1 == iSite_clu2
            trWav_clu2_ = trWav_clu2;
            ctrWav_clu1_ = cellfun(@(x)x(:,:,iClu11), ctmrWav_clu1, 'UniformOutput', 0);
        else
            viSite1 = P.miSites(:,iSite_clu1);
            viSite12 = find(ismember(viSite2, viSite1));
            if isempty(viSite12), continue; end
            trWav_clu2_ = trWav_clu2(:,viSite12,:);
            ctrWav_clu1_ = cellfun(@(x)x(:,viSite12,iClu11), ctmrWav_clu1, 'UniformOutput', 0);
        end                
        trWav_clu1_ = cat(3, ctrWav_clu1_{:});
        vrWavCor2(iClu1) = maxCor_drift_(trWav_clu2_, trWav_clu1_, vi0);
    end        
end %iClu2 loop
% vrWavCor2 = gather_(vrWavCor2);
end %func


%--------------------------------------------------------------------------
% 11/1/17 JJJ: Created 
function tr1 = zero_start_(tr1)
% subtract the first 
dimm1 = size(tr1);
if numel(dimm1) ~= 2, tr1 = reshape(tr1, dimm1(1), []); end

tr1 = bsxfun(@minus, tr1, tr1(1,:));

if numel(dimm1) ~= 2, tr1 = reshape(tr1, dimm1); end
end %func


%--------------------------------------------------------------------------
% 10/23/17 JJJ: find max correlation pair (combining drift and temporal shift)
function maxCor = maxCor_drift__(cmr1, cmr2, cviShift1, cviShift2, fMode_cor)
if nargin<5, fMode_cor=0; end %pearson corr
assert_(numel(cmr1) == numel(cmr2), 'maxCor_drift_: numel must be the same');
if numel(cmr1)==1
    maxCor = max(xcorr2_mr_(cmr1{1}, cmr2{1}, cviShift1, cviShift2));
else
    tr1 = cat(3, cmr1{:}); %nT x nC x nDrifts
    tr2 = cat(3, cmr2{:});
    nDrift = numel(cmr1);
    nShift = numel(cviShift1);
    vrCor = zeros(1, nShift);
    for iShift = 1:nShift 
        mr1_ = reshape(tr1(cviShift1{iShift},:,:), [], nDrift);
        mr2_ = reshape(tr2(cviShift2{iShift},:,:), [], nDrift);          
        if fMode_cor == 0          
            mr1_ = bsxfun(@minus, mr1_, sum(mr1_)/size(mr1_,1));
            mr2_ = bsxfun(@minus, mr2_, sum(mr2_)/size(mr2_,1));
            mr1_ = bsxfun(@rdivide, mr1_, sqrt(sum(mr1_.^2)));
            mr2_ = bsxfun(@rdivide, mr2_, sqrt(sum(mr2_.^2)));
            vrCor(iShift) = max(max(mr1_' * mr2_));
        else
            mr12_ = (mr1_' * mr2_) ./ sqrt(sum(mr1_.^2)' * sum(mr2_.^2));
            vrCor(iShift) = max(mr12_(:));
        end
    end
    maxCor = max(vrCor);
end
end


%--------------------------------------------------------------------------
% 10/23/17 JJJ: find max correlation pair (combining drift and temporal shift)
function [maxCor] = maxCor_drift_(tr1, tr2, vi0)
% tr1,2: nSamples x nC x nDrift
% assert_(numel(cmr1) == numel(cmr2), 'maxCor_drift_: numel must be the same');
% if numel(cmr1)==1
%     maxCor = max(xcorr2_mr_(cmr1{1}, cmr2{1}, cviShift1, cviShift2));
% else
% nDrift = size(tr1,3);
% vi0 = (P.spkLim(1):P.spkLim(2)) - P.spkLim_raw(1) + 1;
% nSamples = diff(P.spkLim_raw)+1;
% viShift = (1-vi0(1)):(nSamples-vi0(end));
viShift = (1-vi0(1)):(vi0(1)-1);
% viShift = -1:1;
nShift = numel(viShift);

% fix tr1 and move tr2
[vrCor1, vrCor2] = deal(zeros(1, nShift, 'like', tr1));
mr1 = tr2mr_norm_(tr1(vi0,:,:))';
mr2 = tr2mr_norm_(tr2(vi0,:,:))';
for iShift = 1:nShift
    vi_ = vi0 + viShift(iShift);
    vrCor1(iShift) = max(max(mr1 * tr2mr_norm_(tr2(vi_,:,:))));
    vrCor2(iShift) = max(max(mr2 * tr2mr_norm_(tr1(vi_,:,:))));
end
maxCor = max(max(vrCor1), max(vrCor2));
end %func


%--------------------------------------------------------------------------
function mr = tr2mr_norm_(tr, fMeanSubt)
if nargin<2, fMeanSubt = 1; end
if fMeanSubt
    mr = reshape(tr, size(tr,1), []);
    mr = bsxfun(@minus, mr, mean(mr)); 
    mr = reshape(mr, [], size(tr,3));
else
    mr = reshape(tr, [], size(tr,3));
end
mr = bsxfun(@rdivide, mr, sqrt(sum(mr.^2))); % normalize
end %func


%--------------------------------------------------------------------------
function [vrFilt_spk, vrVaf, nShift_post] = calc_matched_filt_(mnWav1, P) %detect primary 
% generate a matched filter Kernel
% determine the treshold
% 6/29/17 JJJ: Spike waveform matched fitler determination
% 6/30/17 JJJ: Range optimization

vnThresh_site = gather_(int16(mr2rms_(mnWav1, 1e5) * P.qqFactor));
[viTime_spk, vnAmp_spk, viSite_spk] = detect_spikes_(mnWav1, vnThresh_site, [], P);

% extract wave forms
nSpks = numel(viSite_spk);
nSites = numel(P.viSite2Chan);
%spkLim = [-1, 1] * round(mean(abs(P.spkLim))); %balanced
% spkLim = [-1, 1] * round(max(abs(P.spkLim))); %balanced
% spkLim = [-1, 1] * round(min(abs(P.spkLim))); %balanced
% spkLim = spkLim + [1,0]; 
spkLim = [-1,1] * round(mean(abs(P.spkLim)));

mnWav_spk = zeros(diff(spkLim) + 1, nSpks, 'int16');
for iSite = 1:nSites
    viiSpk11 = find(viSite_spk == iSite);
    if isempty(viiSpk11), continue; end
    viTime_spk11 = viTime_spk(viiSpk11); %already sorted by time
    mnWav_spk(:,viiSpk11) = gather_(vr2mr3_(mnWav1(:,iSite), viTime_spk11, spkLim));
end

[vrFilt_spk, ~, vrVaf] = pca(single(mnWav_spk'), 'NumComponents', 1, 'Centered', 0);
vrFilt_spk = flipud(vrFilt_spk(:));
if abs(min(vrFilt_spk)) > abs(max(vrFilt_spk)), vrFilt_spk = -vrFilt_spk; end
% vrFilt_spk(1) = []; % start from 1 correction
% vrFilt_spk = vrFilt_spk - mean(vrFilt_spk);

% vrFilt_spk = vrFilt_spk / (vrFilt_spk.'*vrFilt_spk);
vrVaf = cumsum(vrVaf);
vrVaf = vrVaf / vrVaf(end);
[~,nShift_post] = max(vrFilt_spk);
nShift_post = round(numel(vrFilt_spk)/2 - nShift_post);
% if nShift_post < 0
%     vrFilt_spk = vrFilt_spk(1-nShift_post:end);
% else
%     vrFilt_spk = vrFilt_spk(1:end-nShift_post);
% end
% nShift_post = 0;
end %func


%--------------------------------------------------------------------------
function [viSite, viSite2, viSite3] = S_clu_peak2_(S_clu)
mrMin_clu = squeeze_(min(S_clu.tmrWav_spk_clu) - S_clu.tmrWav_spk_clu(1,:,:));
% mrMin_clu = squeeze_(min(S_clu.tmrWav_spk_clu) - max(S_clu.tmrWav_spk_clu));
% mrMin_clu = squeeze_(min(S_clu.tmrWav_spk_clu));
% mrMin_clu = squeeze_(min(S_clu.tmrWav_raw_clu));

[~, viSite] = min(mrMin_clu);
if nargout>=2
    mrMin_clu(sub2ind(size(mrMin_clu), viSite, 1:numel(viSite))) = 0;
    [~, viSite2] = min(mrMin_clu);
end
if nargout>=3
    mrMin_clu(sub2ind(size(mrMin_clu), viSite2, 1:numel(viSite2))) = 0;
    [~, viSite3] = min(mrMin_clu);
end
end %func


%--------------------------------------------------------------------------
function [mrFet1_clu1, iSite_clu1] = S_clu_getFet_(S_clu, iClu, viSite2_spk)
global trFet_spk
if nargin<3, viSite2_spk = get0_('viSite2_spk'); end
iSite_clu1 = S_clu.viSite_clu(iClu);
viSpk_clu1 = S_clu.cviSpk_clu{iClu};
if isempty(viSpk_clu1), mrFet1_clu1=[]; return; end
mrFet1_clu1 = squeeze_(trFet_spk(:,1,viSpk_clu1));
if size(trFet_spk,2) >= 2
    mrFet2_clu1 = squeeze_(trFet_spk(:,2,viSpk_clu1));
    viSpk_clu1_site2 = find(viSite2_spk(viSpk_clu1) == iSite_clu1);
    mrFet1_clu1(:,viSpk_clu1_site2) = mrFet2_clu1(:,viSpk_clu1_site2);
end
end %func
        

%--------------------------------------------------------------------------
function S_clu = S_clu_cleanup_(S_clu, P)
% 17/7/3: Cluster cleanup routine, Mahal distance based outlier removal

viSite2_spk = get0_('viSite2_spk');
thresh_mad_clu = get_set_(P, 'thresh_mad_clu', 7.5);
if isempty(thresh_mad_clu), thresh_mad_clu = 0; end
if thresh_mad_clu == 0, return; end % aborted

fprintf('Cleaning up clusters\n\t'); t1=tic;
warning off;
for iClu = 1:S_clu.nClu
    mrFet1_clu1 = S_clu_getFet_(S_clu, iClu, viSite2_spk)';
    viSpk_clu1 = S_clu.cviSpk_clu{iClu};
    try
        vrDist_clu1 = madscore_(log(mahal(mrFet1_clu1, mrFet1_clu1)));
    catch
        continue; 
    end
    vlExcl_clu1 = (vrDist_clu1 > thresh_mad_clu);
    if any(vlExcl_clu1)        
        S_clu.cviSpk_clu{iClu} = viSpk_clu1(~vlExcl_clu1);
        S_clu.viClu(viSpk_clu1(vlExcl_clu1)) = 0; %classify as noise cluster
        S_clu.vnSpk_clu(iClu) = numel(S_clu.cviSpk_clu{iClu});
    end
    fprintf('.');
end %for
fprintf('\n\ttook %0.1fs.\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function [tnWav_spk, vrVrms_site] = file2spk_gt_(P, viTime_spk0)
% file loading routine. keep spike waveform (tnWav_spk) in memory
% assume that the file is chan x time format
% usage:
% [tnWav_raw, tnWav_spk, S0] = file2spk_(P)
%   
% [tnWav_raw, tnWav_spk, S0] = file2spk_(P, viTime_spk, viSite_spk)
%   construct spike waveforms from previous time markers
% 6/29/17 JJJ: Added support for the matched filter
P.fft_thresh = 0; %disable for GT
[tnWav_spk, vnThresh_site] = deal({});    
nSamples1 = 0;  
[fid1, nBytes_file1] = fopen_(P.vcFile, 'r');
nBytes_file1 = file_trim_(fid1, nBytes_file1, P);
[nLoad1, nSamples_load1, nSamples_last1] = plan_load_(nBytes_file1, P);
t_dur1 = tic;
mnWav11_pre = [];
for iLoad1 = 1:nLoad1
    fprintf('\tProcessing %d/%d...\n', iLoad1, nLoad1);
    nSamples11 = ifeq_(iLoad1 == nLoad1, nSamples_last1, nSamples_load1);
    mnWav11 = load_file_(fid1, nSamples11, P);
    if iLoad1 < nLoad1
        mnWav11_post = load_file_preview_(fid1, P);
    else
        mnWav11_post = [];
    end    
    [viTime_spk11] = filter_spikes_(viTime_spk0, [], nSamples1 + [1, nSamples11]);
    [tnWav_spk{end+1}, vnThresh_site{end+1}] = wav2spk_gt_(mnWav11, P, viTime_spk11, mnWav11_pre, mnWav11_post);
%     [tnWav_spk{end+1}, vnThresh_site{end+1}] = wav2spk_gt_(mnWav11, P, viTime_spk11, mnWav11_pre, []);
    if iLoad1 < nLoad1, mnWav11_pre = mnWav11(end-P.nPad_filt+1:end, :); end
    nSamples1 = nSamples1 + nSamples11;
    clear mnWav11 vrWav_mean11;
end %for
fclose(fid1);   
t_dur1 = toc(t_dur1);
t_rec1 = (nBytes_file1 / bytesPerSample_(P.vcDataType) / P.nChans) / P.sRateHz;
fprintf('took %0.1fs (%0.1f MB, %0.1f MB/s, x%0.1f realtime)\n', ...
    t_dur1, nBytes_file1/1e6, nBytes_file1/t_dur1/1e6, t_rec1/t_dur1);

% tnWav_raw = cat(3, tnWav_raw{:});
tnWav_spk = cat(3, tnWav_spk{:});
[vnThresh_site] = multifun_(@(x)cat(1, x{:}), vnThresh_site);
vrVrms_site = mean(single(vnThresh_site),1) / P.qqFactor;

end %func


%--------------------------------------------------------------------------
function [tnWav_spk, vnThresh_site] = wav2spk_gt_(mnWav1, P, viTime_spk, mnWav1_pre, mnWav1_post)
% tnWav_spk: spike waveform. nSamples x nSites x nSpikes
% trFet_spk: nSites x nSpk x nFet
% miSite_spk: nSpk x nFet
% spikes are ordered in time
% viSite_spk and viTime_spk is uint32 format, and tnWav_spk: single format
% mnWav1: raw waveform (unfiltered)
% wav2spk_(mnWav1, vrWav_mean1, P)
% wav2spk_(mnWav1, vrWav_mean1, P, viTime_spk, viSite_spk)
% 7/5/17 JJJ: accurate spike detection at the overlap region

if nargin<4, mnWav1_pre = []; end
if nargin<5, mnWav1_post = []; end

% Filter
if ~isempty(mnWav1_pre) || ~isempty(mnWav1_post)
    mnWav1 = [mnWav1_pre; mnWav1; mnWav1_post];
end
if P.fft_thresh>0, mnWav1 = fft_clean_(mnWav1, P); end
[mnWav2, vnWav11] = filt_car_(mnWav1, P); % filter and car

% detect spikes or use the one passed from the input (importing)
vnThresh_site = gather_(int16(mr2rms_(mnWav2, 1e5) * P.qqFactor));
nPad_pre = size(mnWav1_pre,1);
viTime_spk = viTime_spk + nPad_pre;

% reject spikes within the overlap region: problem if viTime prespecified.
% if ~isempty(mnWav1_pre) || ~isempty(mnWav1_post)        
%     ilim_spk = [nPad_pre+1, size(mnWav2,1) - size(mnWav1_post,1)]; %inclusive
%     viTime_spk = viTime_spk(viTime_spk >= ilim_spk(1) & viTime_spk <= ilim_spk(2));
% end%if
% [tnWav_spk_raw, tnWav_spk] = mn2tn_wav_(mnWav1, mnWav2, [], viTime_spk, P);
tnWav_spk = permute(gather_(mr2tr3_(mnWav2, P.spkLim, viTime_spk)), [1,3,2]);
    
% if nPad_pre > 0, viTime_spk = viTime_spk - nPad_pre; end
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_quality_(S_clu, P, viClu_update)
% 7/5/17 JJJ: Added isolation distance, L-ratio, 
% TODO: update when deleting, splitting, or merging
if nargin<3, viClu_update = []; end
t1 = tic;
fprintf('Calculating cluster quality...\n');
% [vrVmin_clu, vrVmax_clu, vrVpp_clu] = clu_amp_(S_clu.tmrWav_clu, S_clu.viSite_clu);
% [vrVmin_uV_clu, vrVmax_uV_clu, vrVpp_uV_clu] = clu_amp_(S_clu.tmrWav_raw_clu, S_clu.viSite_clu);
mrVmin_clu = squeeze_(min(S_clu.tmrWav_clu));
mrVmax_clu = squeeze_(max(S_clu.tmrWav_clu));
mrVmin_uv_clu = squeeze_(min(S_clu.tmrWav_raw_clu));
mrVmax_uv_clu = squeeze_(max(S_clu.tmrWav_raw_clu));
% tmrWav_clu = S_clu.tmrWav_clu;
% mrVmin_clu = shiftdim(min(tmrWav_clu,[],1));
% mrVmax_clu = shiftdim(max(tmrWav_clu,[],1));
vrVpp_clu = mr2vr_sub2ind_(mrVmax_clu-mrVmin_clu, S_clu.viSite_clu, 1:S_clu.nClu);
vrVmin_clu = mr2vr_sub2ind_(mrVmin_clu, S_clu.viSite_clu, 1:S_clu.nClu);
vrVpp_uv_clu = mr2vr_sub2ind_(mrVmax_uv_clu-mrVmin_uv_clu, S_clu.viSite_clu, 1:S_clu.nClu);
vrVmin_uv_clu = mr2vr_sub2ind_(mrVmin_uv_clu, S_clu.viSite_clu, 1:S_clu.nClu);
% [vrVpp_clu, ~] = max(mrVmax_clu - mrVmin_clu,[],1);
% [vrVmin_clu, viSite_min_clu] = min(mrVmin_clu,[],1);
% if ~isfield(S_clu, 'viSite_clu')
%     viSite_clu = viSite_min_clu;
% else
%     viSite_clu = S_clu.viSite_clu;
% end
% vrVpp_clu=vrVpp_clu(:);  viSite_clu=viSite_clu(:);
% [vrVpp_clu, viSite_clu, vrVmin_clu] = multifun_(@(x)x(:), vrVpp_clu, viSite_clu, vrVmin_clu);

try
    S0 = get(0, 'UserData');
    if isempty(S0), S0 = load0_(subsFileExt_(P.vcFile_prm, '_jrc.mat')); end
    vrVrms_site = bit2uV_(single(S0.vrThresh_site(:)) / S0.P.qqFactor, P);
%     vrSnr_clu = vrVpp_clu ./ vrVrms_site(viSite_clu);
    vrSnr_clu = abs(vrVmin_clu) ./ vrVrms_site(S_clu.viSite_clu);
    vnSite_clu = sum(bsxfun(@lt, mrVmin_clu, -vrVrms_site * S0.P.qqFactor),1)';
catch
    [vrVrms_site, vrSnr_clu, vnSite_clu] = deal([]);
    disp('no Sevt in memory.');
end
[vrIsoDist_clu, vrLRatio_clu, vrIsiRatio_clu] = S_clu_quality2_(S_clu, P, viClu_update);

S_clu = struct_add_(S_clu, vrVpp_clu, vrSnr_clu, vrVrms_site, vnSite_clu, ...
    vrIsoDist_clu, vrLRatio_clu, vrIsiRatio_clu, vrVpp_uv_clu, vrVmin_uv_clu);
fprintf('\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function [vrIsoDist_clu, vrLRatio_clu, vrIsiRatio_clu] = S_clu_quality2_(S_clu, P, viClu_update)
% 7/5/17 JJJ: Berenyi2013 based

global trFet_spk;
if nargin<3, viClu_update = []; end
warning off;

nSamples_2ms = round(P.sRateHz * .002);
nSamples_20ms = round(P.sRateHz * .02);
[viTime_spk, viSite_spk, viSite2_spk, cviSpk_site, cviSpk2_site] = ...
    get0_('viTime_spk', 'viSite_spk', 'viSite2_spk', 'cviSpk_site', 'cviSpk2_site');
if isempty(viClu_update)
    [vrIsoDist_clu, vrLRatio_clu, vrIsiRatio_clu] = deal(nan(S_clu.nClu, 1));
    viClu_update = 1:S_clu.nClu;
else
    [vrIsoDist_clu, vrLRatio_clu, vrIsiRatio_clu] = get_(S_clu, 'vrIsoDist_clu', 'vrLRatio_clu', 'vrIsiRatio_clu');
    viClu_update = viClu_update(:)';
end
for iClu = viClu_update
    viSpk_clu1 = S_clu.cviSpk_clu{iClu};    
    % Compute ISI ratio
    viTime_clu1 = viTime_spk(viSpk_clu1);
    viDTime_clu1 = diff(viTime_clu1);
    vrIsiRatio_clu(iClu) = sum(viDTime_clu1<=nSamples_2ms) ./ sum(viDTime_clu1<=nSamples_20ms);

    % Compute L-ratio an disodist (use neighboring features
    iSite_clu1 = S_clu.viSite_clu(iClu);
    % find spikes whose primary or secondary spikes reside there
    viSpk1_local = cviSpk_site{iSite_clu1}; %find(viSite_spk == iSite_clu1);
    viSpk2_local = cviSpk2_site{iSite_clu1}; %find(viSite2_spk == iSite_clu1);
    if isempty(viSpk2_local)
        mrFet12_spk = squeeze_(trFet_spk(:,1,viSpk1_local));
        viSpk12_local = viSpk1_local(:);
    else        
        mrFet12_spk = [squeeze_(trFet_spk(:,1,viSpk1_local)), squeeze_(trFet_spk(:,2,viSpk2_local))]; %squeeze_(cat(3, trFet_spk(:,1,viSpk1_local), trFet_spk(:,2,viSpk2_local)))';
        viSpk12_local = [viSpk1_local(:); viSpk2_local(:)];  
    end
    vlClu12_local = S_clu.viClu(viSpk12_local) == iClu;    
    nSpk_clu1 = sum(vlClu12_local);
    [vrLRatio_clu(iClu), vrIsoDist_clu(iClu)] = deal(nan);
    try
        vrMahal12 = mahal(mrFet12_spk', mrFet12_spk(:,vlClu12_local)');
    catch
        continue;
    end
    vrMahal12_out = vrMahal12(~vlClu12_local);
    if isempty(vrMahal12_out), continue; end
    vrLRatio_clu(iClu) = sum(1-chi2cdf(vrMahal12_out, size(mrFet12_spk,2))) / nSpk_clu1;

    % compute isolation distance
    if mean(vlClu12_local) > .5, continue; end
    sorted12 = sort(vrMahal12_out);
    vrIsoDist_clu(iClu) = sorted12(nSpk_clu1);
end %for
end %func


%--------------------------------------------------------------------------
function auto_scale_proj_time_(S0, fPlot)
% auto-scale and refgresh
if nargin<1, S0 = get(0, 'UserData'); end
if nargin<2, fPlot = 0; end

autoscale_pct = get_set_(S0.P, 'autoscale_pct', 99.5);
[hFig_proj, S_fig_proj] = get_fig_cache_('FigProj');
[mrMin0, mrMax0, mrMin1, mrMax1, mrMin2, mrMax2] = fet2proj_(S0, S_fig_proj.viSites_show);
if isempty(mrMin2) || isempty(mrMax2)
    cmrAmp = {mrMin1, mrMax1};
else
    cmrAmp = {mrMin1, mrMax1, mrMin2, mrMax2};
end
S_fig_proj.maxAmp = max(cellfun(@(x)quantile(x(:), autoscale_pct/100), cmrAmp));
set(hFig_proj, 'UserData', S_fig_proj);


% Update time
[hFig_time, S_fig_time] = get_fig_cache_('FigTime');
iSite = S0.S_clu.viSite_clu(S0.iCluCopy);
% [vrFet0, vrTime0] = getFet_site_(iSite, [], S0);    % plot background    
[vrFet1, vrTime1, vcYlabel, viSpk1] = getFet_site_(iSite, S0.iCluCopy, S0); % plot iCluCopy
if isempty(S0.iCluPaste)
%     vrFet = [vrFet0(:); vrFet1(:)];
    cvrFet = {vrFet1};
else
    [vrFet2, vrTime2, vcYlabel, viSpk2] = getFet_site_(iSite, S0.iCluPaste, S0); % plot iCluCopy
%     vrFet = [vrFet0(:); vrFet1(:); vrFet2(:)];
    cvrFet = {vrFet1, vrFet2};
end
% S_fig_time.maxAmp = quantile(vrFet, autoscale_pct/100);
S_fig_time.maxAmp = max(cellfun(@(x)quantile(x(:), autoscale_pct/100), cvrFet));
set(hFig_time, 'UserData', S_fig_time);

% plot
if fPlot
    keyPressFcn_cell_(get_fig_cache_('FigWav'), {'j', 't'}, S0); 
else
    rescale_FigProj_(S_fig_proj.maxAmp, hFig_proj, S_fig_proj, S0);    
    rescale_FigTime_(S_fig_time.maxAmp, S0, S0.P);
end
end %func


%--------------------------------------------------------------------------
function plot_drift_(P)

iShank_show = get_set_(P, 'iShank_show', 1);
vcMode_drift = get_set_(P, 'vcMode_drift', 'y'); % {'tay', 'xy', 'xya', 'x', 'y', 'gt'}
vcMode_com = get_set_(P, 'vcMode_com', 'fet'); % {'fet', 'filt', 'raw', 'std'}
% Compute spike position and plot drift profile
S0 = load_cached_(P); % load cached data or from file if exists
[S_clu, viSite2_spk, vrTime_spk, viSite_spk] = get0_('S_clu', 'viSite2_spk', 'viTime_spk', 'viSite_spk');
vrTime_spk = double(vrTime_spk) / P.sRateHz;
nSites_spk = 1 + P.maxSite*2 - P.nSites_ref;
miSites_spk = P.miSites(:,viSite_spk);

switch lower(vcMode_com)
    case 'filt'
        tnWav_spk = get_spkwav_(P, 0);
        %mrVp = squeeze_(single(min(tnWav_spk))) .^ 2;
%         tnWav_spk1 = meanSubt_(single(tnWav_spk),2);
        mrVp = single(squeeze_(max(tnWav_spk) - min(tnWav_spk))) .^ 2;
    case 'filtstd'
        mrVp = squeeze_(var(single(get_spkwav_(P, 0))));
    case 'rawstd', mrVp = squeeze_(var(single(get_spkwav_(P, 1))));
    case 'raw'
        tnWav_raw = get_spkwav_(P, 1);
        mrVp = single(squeeze_(max(tnWav_raw) - min(tnWav_raw))) .^ 2;
    case 'fet'
        trFet_spk = get_spkfet_(P); 
        mrVp = squeeze_(trFet_spk(1:nSites_spk,1,:)) .^ 2;
%         mrVp = abs(squeeze_(trFet_spk(1:nSites_spk,1,:)));
        miSites_spk = miSites_spk(1:nSites_spk,:);
end

mrX_spk = reshape(P.mrSiteXY(miSites_spk,1), size(miSites_spk));
mrY_spk = reshape(P.mrSiteXY(miSites_spk,2), size(miSites_spk));
vrPosX_spk = sum(mrVp .* mrX_spk) ./ sum(mrVp);
vrPosY_spk = sum(mrVp .* mrY_spk) ./ sum(mrVp);
vrA_spk = sum(mrVp);
assignWorkspace_(vrTime_spk, vrPosX_spk, vrPosY_spk, vrA_spk);

vlSpk_shank = ismember(P.viShank_site(viSite_spk), iShank_show); %show first shank only
% vrAmp_spk = 1 ./ sqrt(single(abs(S0.vrAmp_spk)));
% vrAmp_spk = 1 ./ sqrt(sum(mrVp));
vrAmp_spk = sqrt(mean(mrVp) ./ std(mrVp)); %spatial icv
hFig_drift = create_figure_('', [0 0 .5 1], P.vcFile_prm, 1, 1);
% hFig_drift = gcf;
figure(hFig_drift); 
ax = gca(); 
hold on; 
nSpk_thresh_clu = median(S_clu.vnSpk_clu);
snr_thresh_clu = get_set_(P, 'snr_thresh_gt', quantile(S_clu.vrSnr_clu, .5)) - 2;
% posX_thresh = median(S_clu.vrPosX_clu);
% [vrTime_drift, vrDepth_drift] = drift_track_(S_clu, vrPosY_spk, P);
if strcmpi(vcMode_drift, 'gt')
    vcFile_score = strrep(P.vcFile_prm, '.prm', '_score.mat');
    assert(exist_file_(vcFile_score), 'ground truth file does not exist');
    S_score = load(vcFile_score);
    vrSnr_gt = S_score.Sgt.vrSnr_clu;
    viClu_gt = reverse_lookup_(1:S_clu.nClu, S_score.S_score_clu.viCluMatch);
    nClu_gt = numel(S_score.S_score_clu.viCluMatch);
%     mrColor_gt = shuffle_static_(jet(nClu_gt), 1);
    rng(0);
    mrColor_gt = rand(nClu_gt, 3);
    ylim_gt = [40 240];
end
if ~isempty(S_clu) 
    posX_lim = quantile(S_clu.vrPosX_clu, [.25, .75]);
    posY_lim = quantile(S_clu.vrPosY_clu, [.1, .9]);       
    for iClu = 1:S_clu.nClu
        viSpk1 = S_clu.cviSpk_clu{iClu};
        viSpk1 = viSpk1(vlSpk_shank(viSpk1));        
        vrColor1 = rand(1,3);
        posX_clu1 = S_clu.vrPosX_clu(iClu);
        posY_clu1 = S_clu.vrPosY_clu(iClu);
        switch vcMode_drift
            case 'tay'
                plot3(ax, vrTime_spk(viSpk1), vrAmp_spk(viSpk1), vrPosY_spk(viSpk1), '.', 'Color', vrColor1, 'MarkerSize', 5); 
            case 'x'
                plot(ax, vrTime_spk(viSpk1), vrPosX_spk(viSpk1), '.', 'Color', vrColor1, 'MarkerSize', 5); 
            case 'y'
                plot(ax, vrTime_spk(viSpk1), vrPosY_spk(viSpk1), '.', 'Color', vrColor1, 'MarkerSize', 5); 
            case 'xy'
                plot(ax, vrPosX_spk(viSpk1), vrPosY_spk(viSpk1), '.', 'Color', vrColor1, 'MarkerSize', 5);      
            case 'xya'
                if S_clu.vrSnr_clu(iClu) < snr_thresh_clu, continue; end
                plot3(ax, vrPosX_spk(viSpk1), vrPosY_spk(viSpk1), vrAmp_spk(viSpk1), '.', 'Color', vrColor1, 'MarkerSize', 5);                    
            case 'gt'
                iClu_gt = viClu_gt(iClu);
                if iClu_gt==0, continue; end
                if vrSnr_gt(iClu_gt) < snr_thresh_clu, continue; end  
                viSpk1 = viSpk1(1:2:end); %reduce by half
%                 viSpk1 = subsample_vr_(viSpk1, 4000);
                vl_ = vrPosY_spk(viSpk1) >= ylim_gt(1) & vrPosY_spk(viSpk1) < ylim_gt(2);
                vrColor1 = mrColor_gt(iClu_gt,:);                
                plot(ax, vrTime_spk(viSpk1(vl_)), vrPosY_spk(viSpk1(vl_)), '.', 'Color', vrColor1, 'MarkerSize', 5);
            case 'z'
%                 if S_clu.vnSpk_clu(iClu) < nSpk_thresh_clu, continue; end
                if S_clu.vrSnr_clu(iClu) < snr_thresh_clu, continue; end                
%                 if vrA_spk(S_clu.cviSpk_clu{iClu})
%                 if S_clu.vrPosX_clu(iClu) < posX_thresh, continue; end
                if posX_clu1 < posX_lim(1) || posX_clu1 > posX_lim(2) || posY_clu1 < posY_lim(1) || posY_clu1 > posY_lim(2), continue; end
                plot(ax, vrTime_spk(viSpk1), vrPosY_spk(viSpk1), '.', 'Color', vrColor1, 'MarkerSize', 5);  % - median(vrPosY_spk(viSpk1))
        end %switch
    end
else
    switch vcMode_drift
        case 'tay', plot3(ax, vrTime_spk, vrAmp_spk, vrPosY_spk, 'o', 'MarkerSize', 5); 
        case 'x', plot(ax, vrTime_spk, vrPosX_spk, '.', 'MarkerSize', 5); 
        case 'y', plot(ax, vrTime_spk, vrPosY_spk, '.', 'MarkerSize', 5); 
        case 'xy', plot(ax, vrPosX_spk, vrPosY_spk, '.', 'MarkerSize', 5); 
        case 'xya', plot3(ax, vrPosX_spk, vrPosY_spk, vrAmp_spk, '.', 'MarkerSize', 5); 
        case 'z'
            posX_lim = quantile(vrPosX_spk, [.25, .75]);
            posY_lim = quantile(vrPosY_spk, [.35, .65]);
            viSpk_plot = find(vrPosX_spk(:) > posX_lim(1) & vrPosX_spk(:) < posX_lim(2) & vrPosY_spk(:) > posY_lim(1) & vrPosY_spk(:) < posY_lim(2)); % & vrAmp_spk(:) < median(vrAmp_spk));
            plot(ax, vrTime_spk(viSpk_plot), vrPosY_spk(viSpk_plot), '.', 'MarkerSize', 5); 
    end %switch        
end

drawnow;
title_(ax, sprintf('Spike positions from shank %d (change using "iShank_show" paremter)', iShank_show));
xlabel(ax, 'Time (s)');
grid(ax, 'on');
axis(ax, 'tight');
switch vcMode_drift
    case 'x', ylabel(ax, 'X position (um)');
    case 'y', ylabel(ax, 'Y position (um)');
    case 'tay'
        ylabel(ax, '1/a (au)'); 
        zlabel(ax, 'z position (um)');
    case 'xya'
        xlabel(ax, 'x (um)'); 
        ylabel(ax, 'y (um)'); 
        zlabel(ax, '1/a (au)');
    case 'gt'
        set(ax, 'YLim', ylim_gt);
end %switch
mouse_figure(hFig_drift);
% linkaxes([ax_x, ax_y], 'x');
end %func


%--------------------------------------------------------------------------
% 17/9/13 JJJ: Behavior changed, if S==[], S0 is loaded
function val = get_set_(S, vcName, def_val)
% set a value if field does not exist (empty)

if isempty(S), S = get(0, 'UserData'); end
if isempty(S), val = def_val; return; end
if ~isstruct(S)
    val = []; 
    fprintf(2, 'get_set_: %s must be a struct\n', inputname(1));
    return;
end
val = get_(S, vcName);
if isempty(val), val = def_val; end
end %func


%--------------------------------------------------------------------------
function S_clu = post_recenter_(S_clu, P) % recenters the features and 
% trFet_spk, viSite_spk, viSite2_spk, cviSpk_site, cviSpk2_site
global trFet_spk %nFet/site x nFet x nSpk
[viSite_spk, viSite2_spk] = get0_('viSite_spk', 'viSite2_spk');
nSites = numel(P.viSite2Chan);
% vpCentered_clu = arrayfun(@(iClu)mean(viSite_spk(S_clu.cviSpk_clu{iClu}) == S_clu.viSite_clu(iClu) | viSite2_spk(S_clu.cviSpk_clu{iClu}) == S_clu.viSite_clu(iClu)), 1:S_clu.nClu);
% find spikes not centered
for iClu = 1:S_clu.nClu
    viSpk_clu1 = S_clu.cviSpk_clu{iClu};
    vlSpk_swap_clu1 = viSite2_spk(viSpk_clu1) == S_clu.viSite_clu(iClu);
    vi_swap_ = viSpk_clu1(vlSpk_swap_clu1);
    % swap indices
%     [viSite1_spk, viSite2_spk] = swap_vr_(viSite_spk, viSite2_spk, viSpk_swap_clu1);
    [viSite_spk(vi_swap_), viSite2_spk(vi_swap_)] = deal(viSite2_spk(vi_swap_), viSite_spk(vi_swap_));
    trFet_spk_clu1 = trFet_spk(:,:,vi_swap_);
    trFet_spk(:,1,vi_swap_) = trFet_spk_clu1(:,2,:);
    trFet_spk(:,2,vi_swap_) = trFet_spk_clu1(:,1,:);
end %for
cviSpk_site = arrayfun(@(iSite)find(viSite_spk == iSite), 1:nSites, 'UniformOutput', 0);
cviSpk2_site = arrayfun(@(iSite)find(viSite2_spk == iSite), 1:nSites, 'UniformOutput', 0);
S0 = set0_(viSite_spk, viSite2_spk, cviSpk_site, cviSpk2_site);
end %func


%--------------------------------------------------------------------------
function [vr1, vr2] = swap_vr_(vr1, vr2, vi_swap)
% assert: vr1 and vr2 must have the same dimensions
[vr1(vi_swap), vr2(vi_swap)] = deal(vr2(vi_swap), vr1(vi_swap));
end


%--------------------------------------------------------------------------
% 2017/12/1 JJJ: auto-cast and memory division
function [mnWav1, fGpu] = fft_clean_(mnWav, P)
if ~isstruct(P), P = struct('fft_thresh', P); end
fGpu = get_set_(P, 'fGpu', isGpu_(mnWav));
% fGpu = 1;
if isempty(P.fft_thresh) || P.fft_thresh==0 || isempty(mnWav), mnWav1=mnWav; return; end
[vcClass, fGpu_mnWav] = class_(mnWav);
fprintf('Applying FFT cleanup\n'); t1=tic;
if 1
    if fGpu
        mnWav1 = fft_clean__(mnWav, P.fft_thresh);
    else
        mnWav1 = fft_clean__(gather_(mnWav), P.fft_thresh);
    end
else
    nLoads_gpu = get_set_(P, 'nLoads_gpu', 8);  % GPU load limit        
    nSamples = size(mnWav,1);
    [nLoad1, nSamples_load1, nSamples_last1] = partition_load_(nSamples, round(nSamples/nLoads_gpu));
    mnWav1 = zeros(size(mnWav), 'like', mnWav);    
    for iLoad = 1:nLoad1
        iOffset = (iLoad-1) * nSamples_load1;
        if iLoad<nLoad1
            vi1 = (1:nSamples_load1) + iOffset;
        else
            vi1 = (1:nSamples_last1) + iOffset;
        end
        mnWav1_ = mnWav(vi1,:);
        if fGpu % use GPU
            try 
                if ~fGpu_mnWav, mnWav1_ = gpuArray_(mnWav1_); end
                mnWav1(vi1,:) = fft_clean__(mnWav1_, P.fft_thresh);
            catch
                fGpu = 0;
            end
        end
        if ~fGpu % use CPU 
            mnWav1(vi1,:) = fft_clean__(gather_(mnWav1_), P.fft_thresh);
        end
        fprintf('.');
    end %for
end
fprintf('\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function mr1 = fft_clean__(mr, thresh, nbins)
% mr must be single

if nargin<2, thresh = 6; end
if nargin<3, nbins = 20; end
nSkip_med = 4;
nw = 3; %frequency neighbors to set to zero

if thresh==0, thresh = []; end
if isempty(thresh), mr1=mr; return ;end
n = size(mr,1);
n_pow2 = 2^nextpow2(n);
vcClass = class_(mr);    
for iRetry = 1:2
    try
        mr1 = single(mr);
        vrMu = mean(mr1, 1);
        mr1 = bsxfun(@minus, mr1, vrMu);
        if n < n_pow2
            mr1 = fft(mr1, n_pow2);
        else
            mr1 = fft(mr1);
        end
        break;
    catch
        fprintf('GPU processing failed, retrying on CPU\n');
        mr = gather_(mr);
    end
end %for

% Find frequency outliers    
n1 = floor(n_pow2/2);
viFreq = (1:n1)';
% vrFft1 = abs(mean(bsxfun(@times, mr1(1+viFreq,:), viFreq), 2));
vrFft1 = (mean(bsxfun(@times, abs(mr1(1+viFreq,:)), viFreq), 2));
n2 = round(n1/nbins); 
for ibin=1:nbins
    vi1 = (n2*(ibin-1) : n2*ibin) + 1;
    if ibin==nbins, vi1(vi1>n1)=[]; end
    vrFft2 = vrFft1(vi1);
    vrFft2 = vrFft2 - median(vrFft2(1:nSkip_med:end)); %mad transform
    vrFft1(vi1) = vrFft2 / median(abs(vrFft2(1:nSkip_med:end)));
end

% broaden spectrum
vl_noise = vrFft1>thresh;
vi_noise = find(vl_noise);
for i_nw=1:nw
    viA = vi_noise-i_nw;    viA(viA<1)=[];
    viB = vi_noise+i_nw;    viB(viB>n1)=[];
    vl_noise(viA)=1;
    vl_noise(viB)=1;
end
vi_noise = find(vl_noise);
mr1(1+vi_noise,:) = 0;
mr1(end-vi_noise+1,:) = 0;

% inverse transform back to the time domain
mr1 = real(ifft(mr1, n_pow2, 'symmetric')); %~30% faster than below
if n < n_pow2, mr1 = mr1(1:n,:); end
mr1 = bsxfun(@plus, mr1, vrMu); %add mean back
mr1 = cast(mr1, vcClass); % cast back to the original type
end %func


%--------------------------------------------------------------------------
function [vc, fGpu] = class_(vr)
% Return the class for GPU or CPU arrays 
if isempty(vr)
    vc = class(gather_(vr));
else
    vc = class(gather_(vr(1)));
end
if nargout>=2, fGpu = isGpu_(vr); end
end %func


%--------------------------------------------------------------------------
function reset_path_()
% Reset to the Matlab default path in case user overrided the system default functions
persistent fPathSet
if fPathSet, return; end

restoredefaultpath;
disp('Matlab path is temporarily reset to the factory default for this session.');

[vcPath_jrc, ~, ~] = fileparts(mfilename('fullpath')); % get current directory
addpath_(vcPath_jrc);
fPathSet = 1;
end


%--------------------------------------------------------------------------
%Program for calculating the Adjusted Mutual Information (AMI) between
%two clusterings, tested on Matlab 7.0 (R14)
%(C) Nguyen Xuan Vinh 2008-2010
%Contact: n.x.vinh@unsw.edu.au 
%         vthesniper@yahoo.com
%--------------------------------------------------------------------------
%**Input: a contingency table T
%   OR
%        cluster label of the two clusterings in two vectors
%        eg: true_mem=[1 2 4 1 3 5]
%                 mem=[2 1 3 1 4 5]
%        Cluster labels are coded using positive integer. 
%**Output: AMI: adjusted mutual information  (AMI_max)
%
%**Note: In a prevous published version, if you observed strange AMI results, eg. AMI>>1, 
%then it's likely that in these cases the expected MI was incorrectly calculated (the EMI is the sum
%of many tiny elements, each falling out the precision range of the computer).
%However, you'll likely see that in those cases, the upper bound for the EMI will be very
%tiny, and hence the AMI -> NMI (see [3]). It is recommended setting AMI=NMI in
%these cases, which is implemented in this version.
%--------------------------------------------------------------------------
%References: 
% [1] 'A Novel Approach for Automatic Number of Clusters Detection based on Consensus Clustering', 
%       N.X. Vinh, and Epps, J., in Procs. IEEE Int. Conf. on 
%       Bioinformatics and Bioengineering (Taipei, Taiwan), 2009.
% [2] 'Information Theoretic Measures for Clusterings Comparison: Is a
%	    Correction for Chance Necessary?', N.X. Vinh, Epps, J. and Bailey, J.,
%	    in Procs. the 26th International Conference on Machine Learning (ICML'09)
% [3] 'Information Theoretic Measures for Clusterings Comparison: Variants, Properties, 
%       Normalization and Correction for Chance', N.X. Vinh, Epps, J. and
%       Bailey, J., Journal of Machine Learning Research, 11(Oct), pages
%       2837-2854, 2010

function [AMI_] = ami_(true_mem,mem)
if nargin==1
    true_mem=double(true_mem);
    T=true_mem; %contingency table pre-supplied
elseif nargin==2
    true_mem=double(true_mem);
    mem=double(mem);
    %build the contingency table from membership arrays
    R=max(true_mem);
    C=max(mem);
    n=length(mem);N=n;

    %identify & removing the missing labels
    list_t=ismember(1:R,true_mem);
    list_m=ismember(1:C,mem);
%     T=Contingency_(true_mem,mem);
    T = full(sparse(true_mem(:), mem(:), 1, max(true_mem(:)), max(mem(:))));
    T=T(list_t,list_m);
end


%-----------------------calculate Rand index and others----------
n=sum(sum(T));N=n;
C=T;
nis=sum(sum(C,2).^2);		%sum of squares of sums of rows
njs=sum(sum(C,1).^2);		%sum of squares of sums of columns

t1=nchoosek(n,2);		%total number of pairs of entities
t2=sum(sum(C.^2));      %sum over rows & columnns of nij^2
t3=.5*(nis+njs);

%Expected index (for adjustment)
nc=(n*(n^2+1)-(n+1)*nis-(n+1)*njs+2*(nis*njs)/n)/(2*(n-1));

A=t1+t2-t3;		%no. agreements
D=  -t2+t3;		%no. disagreements

if t1==nc
   AR=0;			%avoid division by zero; if k=1, define Rand = 0
else
   AR=(A-nc)/(t1-nc);		%adjusted Rand - Hubert & Arabie 1985
end

RI=A/t1;			%Rand 1971		%Probability of agreement
MIRKIN=D/t1;	    %Mirkin 1970	%p(disagreement)
HI=(A-D)/t1;      	%Hubert 1977	%p(agree)-p(disagree)
Dri=1-RI;           %distance version of the RI
Dari=1-AR;          %distance version of the ARI
%-----------------------%calculate Rand index and others%----------

%update the true dimensions
[R C]=size(T);
if C>1 a=sum(T');else a=T';end;
if R>1 b=sum(T);else b=T;end;

%calculating the Entropies
Ha=-(a/n)*log(a/n)'; 
Hb=-(b/n)*log(b/n)';

%calculate the MI (unadjusted)
MI=0;
for i=1:R
    for j=1:C
        if T(i,j)>0, MI=MI+T(i,j)*log(T(i,j)*n/(a(i)*b(j)));end;
    end
end
MI=MI/n;

%-------------correcting for agreement by chance---------------------------
AB=a'*b;
bound=zeros(R,C);
sumPnij=0;

E3=(AB/n^2).*log(AB/n^2);

EPLNP=zeros(R,C);
LogNij=log([1:min(max(a),max(b))]/N);
for i=1:R
    for j=1:C
        sumPnij=0;
        nij=max(1,a(i)+b(j)-N);
        X=sort([nij N-a(i)-b(j)+nij]);
        if N-b(j)>X(2)
            nom=[[a(i)-nij+1:a(i)] [b(j)-nij+1:b(j)] [X(2)+1:N-b(j)]];
            dem=[[N-a(i)+1:N] [1:X(1)]];
        else
            nom=[[a(i)-nij+1:a(i)] [b(j)-nij+1:b(j)]];       
            dem=[[N-a(i)+1:N] [N-b(j)+1:X(2)] [1:X(1)]];
        end
%         p0=prod(nom./dem)/N;
        p0 = exp(sum(log(nom)) - sum(log(dem)))/N;
        
        sumPnij=p0;
        
        EPLNP(i,j)=nij*LogNij(nij)*p0;
        p1=p0*(a(i)-nij)*(b(j)-nij)/(nij+1)/(N-a(i)-b(j)+nij+1);  
        
        for nij=max(1,a(i)+b(j)-N)+1:1:min(a(i), b(j))
            sumPnij=sumPnij+p1;
            EPLNP(i,j)=EPLNP(i,j)+nij*LogNij(nij)*p1;
            p1=p1*(a(i)-nij)*(b(j)-nij)/(nij+1)/(N-a(i)-b(j)+nij+1);            
            
        end
         CC=N*(a(i)-1)*(b(j)-1)/a(i)/b(j)/(N-1)+N/a(i)/b(j);
         bound(i,j)=a(i)*b(j)/N^2*log(CC);         
    end
end

EMI_bound=sum(sum(bound));
EMI_bound_2=log(R*C/N+(N-R)*(N-C)/(N*(N-1)));
EMI=sum(sum(EPLNP-E3));

AMI_=(MI-EMI)/(max(Ha,Hb)-EMI);
NMI=MI/sqrt(Ha*Hb);


%If expected mutual information negligible, use NMI.
if abs(EMI)>EMI_bound
    fprintf('The EMI is small: EMI < %f, setting AMI=NMI',EMI_bound);
    AMI_=NMI;
end
end %func


%--------------------------------------------------------------------------
% 9/27/17 Validate parameters
function flag = validate_param_(P)
% validate P

NDIM_SORT_MAX = get_set_(P, 'nC_max', 48);

csError = {};

nSites_spk = P.maxSite * 2 + 1 - P.nSites_ref;
nFet_sort = nSites_spk * P.nPcPerChan;

if nSites_spk <= 0
    csError{end+1} = sprintf('Negative # Sites/spk. Use this formula to adjust maxSite and nSites_ref (nSites_spk = 1+maxSite*2-nSites_ref)');
end
if nFet_sort > NDIM_SORT_MAX
    csError{end+1} = sprintf('# dimensions (%d) exceeds the maximum limit for CUDA code (%d), decrease maxSite', nFet_sort, NDIM_SORT_MAX);
end

% nFet = P.
% Validate format
% if isempty(P.vcFile) && isempty(P.csFile_merge)
%     csError{end+1} = '''vcFile'' or ''csFile_merge'' must be set.';
% elseif ~isempty(P.vcFile)
%     if ~exist(P.vcFile, 'file')
%         csError{end+1} = sprintf('vcFile=''%s'' does not exist', P.vcFile);
%     end
% end
% if ~exist(P.probe_file, 'file')
%     csError{end+1} = sprintf('probe_file=''%s'' does not exist', P.probe_file);
% end
% if isempty(P.nChans), csError{end+1} = sprintf('''nChans'' must be specified.', P.probe_file); end


% Validate display


% Validate preprocess


% Validate feature


% Validate cluster


% Validate post-cluster


if isempty(csError)
    flag = true;
else
    cellfun(@(vc_)fprintf(2, '%s\n', vc_), csError);
    flag = false;
end
end %func


%--------------------------------------------------------------------------
function hFig = plot_rd_(P, S0)
fLog_delta = 0;
max_delta = 5;
if nargin<2, S0 = []; end
if isempty(S0), S0 = load0_(P); end
S_clu = S0.S_clu;
% S_clu = get0_('S_clu');
if fLog_delta
    vrY_plot = log10(S_clu.delta);
    vcY_label = 'log10 Delta';
    vrY_plot(vrY_plot>log10(max_delta)) = nan;
else
    vrY_plot = (S_clu.delta);
    vcY_label = 'Delta';
    vrY_plot(vrY_plot>max_delta) = nan;
end
vrX_plot = S_clu.rho;
vrX_plot1 = log10(S_clu.rho);
[~, ~, vrY_plot1] = detrend_local_(S_clu, P, 0);
vrY_plot1 = log10(vrY_plot1);

% Plot
vhAx = [];
hFig = create_figure_('Fig_RD1', [0 0 .5 1], P.vcFile_prm, 1, 1);
vhAx(1) = subplot(211); hold on; 
plot(vrX_plot1, vrY_plot, '.', 'Color', repmat(.5,1,3));
plot(vrX_plot1(S_clu.icl), vrY_plot(S_clu.icl), 'ro');
plot(P.rho_cut*[1,1], [0, max_delta], 'r-');
xylabel_(gca, 'log10 Rho', vcY_label, sprintf('lin-log plot, nClu: %d', S_clu.nClu)); 
axis_([-4, -.5, 0, max_delta]); grid on;

vhAx(2) = subplot(212); hold on;
plot(vrX_plot1, vrY_plot1, '.', 'Color', repmat(.5,1,3));
plot(vrX_plot1(S_clu.icl), vrY_plot1(S_clu.icl), 'ro');
plot(P.rho_cut*[1,1], [-.5, 2], 'r-', [-4, -.5], P.delta1_cut*[1,1], 'r-');
xylabel_(gca, 'log10 Rho', 'log10 Delta (detrended)', ...
    sprintf('detrended log-log plot (P.rho_cut=%0.3f; P.delta1_cut=%0.3f; nClu:%d)', ...
        P.rho_cut, P.delta1_cut, S_clu.nClu));
axis_([-4, -.5, -.5, 2]); grid on;

linkaxes(vhAx, 'x');
end %func


%--------------------------------------------------------------------------
function save_fig_(vcFile_png, hFig, fClose)
% Save a figure to a figure file
if nargin<2, hFig = []; end
if nargin<3, fClose = 0; end
if isempty(hFig), hFig = gcf; end

% vcFile_png = strrep(P.vcFile_prm, '.prm', '.png');
try
    hMsg = msgbox_('Saving figure... (this closes automaticall)');
    drawnow;
    saveas(hFig, vcFile_png);
    fprintf('Saved figure to %s\n', vcFile_png);
    if fClose, close_(hFig); end
    close_(hMsg);
catch
    fprintf(2, 'Failed to save a figure to %s.\n', vcFile_png);
end
end %func


%--------------------------------------------------------------------------
function vrSnr_clu = S_clu_snr_(S_clu)
S0 = get(0, 'UserData');
S_clu = S_clu_wav_(S_clu, [], 1);
mrVmin_clu = shiftdim(min(S_clu.tmrWav_clu,[],1));
[vrVmin_clu, viSite_clu] = min(mrVmin_clu,[],1);
vrVrms_site = single(S0.vrThresh_site(:)) / S0.P.qqFactor;
vrSnr_clu = abs(vrVmin_clu(:)) ./ bit2uV_(vrVrms_site(viSite_clu), S0.P);
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_combine_(S_clu, S_clu_redo, vlRedo_clu, vlRedo_spk)
viSpk_cluA = find(~vlRedo_spk);
[~, viCluA] = ismember(S_clu.viClu(viSpk_cluA), find(~vlRedo_clu));
S_clu.viClu(viSpk_cluA) = viCluA;
S_clu.viClu(vlRedo_spk) = S_clu_redo.viClu + max(viCluA);
end %func


%--------------------------------------------------------------------------
function delete_auto_()
% SNR based delete functionality
% Ask SNR
S0 = get(0, 'UserData');
[S_clu, P] = get0_('S_clu', 'P');
hFig = create_figure_('', [.5 .7 .35 .3], ['Delete Auto: ', P.vcFile]);

% Ask user which clusters to delete
plot(S_clu.vrSnr_clu(:), S_clu.vnSpk_clu(:), '.'); % show cluster SNR and spike count
xlabel('Unit SNR'); ylabel('# spikes/unit'); grid on;
set(gca,'YScale','log');
% snr_thresh = inputdlg_num_('SNR threshold: ', 'Auto-deletion based on SNR', 10); % also ask about # spikes/unit (or firing rate) @TODO
csAns = inputdlg_({'Min Unit SNR:', 'Max Unit SNR:', 'Minimum # spikes/unit'}, 'Auto-deletion based on SNR', 1, {'7', 'inf', '0'}); % also ask about # spikes/unit (or firing rate) @TODO
close(hFig);

% parse user input
if isempty(csAns), return; end
snr_min_thresh = str2double(csAns{1}); 
snr_max_thresh = str2double(csAns{2}); 
count_thresh = round(str2double(csAns{3})); 
if any(isnan([snr_min_thresh, snr_max_thresh, count_thresh]))
    msgbox_('Invalid criteria.'); return; 
end
viClu_delete = find(S_clu.vrSnr_clu(:) < snr_min_thresh | S_clu.vnSpk_clu(:) < count_thresh | S_clu.vrSnr_clu(:) > snr_max_thresh);
if isempty(viClu_delete), msgbox_('No clusters deleted.'); return; end
if numel(viClu_delete) >= S_clu.nClu, msgbox_('Cannot delete all clusters.'); return; end

% Auto delete
figure_wait_(1);
S_clu = delete_clu_(S_clu, viClu_delete);
set0_(S_clu);
S0 = gui_update_();
figure_wait_(0);

msgbox_(sprintf('Deleted %d clusters <%0.1f SNR or <%d spikes/unit.', numel(viClu_delete), snr_min_thresh, count_thresh));
save_log_(sprintf('delete-auto <%0.1f SNR or <%d spikes/unit', snr_min_thresh, count_thresh), S0);
end %func


%--------------------------------------------------------------------------
function merge_auto_(S0)
% SNR based delete functionality
% Ask SNR
if nargin<1, S0 = []; end
if isempty(S0), S0 = get(0, 'UserData'); end
[S_clu, P] = deal(S0.S_clu, S0.P);

% snr_thresh = inputdlg_num_('SNR threshold: ', 'Auto-deletion based on SNR', 10); % also ask about # spikes/unit (or firing rate) @TODO
csAns = inputdlg_('Waveform correlation threshold (0-1):', 'Auto-merge based on waveform threshold', 1, {num2str(P.maxWavCor)});

% parse user input
if isempty(csAns), return; end
maxWavCor = str2double(csAns{1}); 
if isnan(maxWavCor), msgbox_('Invalid criteria.'); return; end

% Auto delete
figure_wait_(1);
nClu_prev = S_clu.nClu;
S_clu = post_merge_wav_(S_clu, P.nRepeat_merge, setfield(P, 'maxWavCor', maxWavCor));
% [S_clu, S0] = S_clu_commit_(S_clu, 'post_merge_');
S_clu.mrWavCor = set_diag_(S_clu.mrWavCor, S_clu_self_corr_(S_clu, [], S0));
set0_(S_clu);
S0 = gui_update_();
figure_wait_(0);

assert_(S_clu_valid_(S_clu), 'Cluster number is inconsistent after deleting');
nClu_merge = nClu_prev - S_clu.nClu;
msgbox_(sprintf('Merged %d clusters >%0.2f maxWavCor.', nClu_merge, maxWavCor));
save_log_(sprintf('merge-auto <%0.2f maxWavCor', maxWavCor), S0);
end %func


%--------------------------------------------------------------------------
function S = struct_select_(S, csNames, viKeep, iDimm)
if isempty(csNames), return; end
if nargin<4, iDimm = 1; end

% function test
% if nargin==0, S.a=rand(10,1);S.b=rand(10,3);S.c=rand(10,3,5); csNames={'a','b','c'}; viKeep=[1,2,3,5]; iDimm=1; end
if ischar(csNames), csNames = {csNames}; end
for i=1:numel(csNames)
    vcName_ = csNames{i};
    if ~isfield(S, vcName_), continue; end
    try
        val = S.(vcName_);
        if isempty(val), continue; end
        ndims_ = ndims(val);
        if ndims_==2 %find a column or row vectors
            if size(val,1)==1 || size(val,2)==1, ndims_=1; end %iscol or isrow
        end
        switch ndims_
            case 1, val = val(viKeep);
            case 2
                switch iDimm
                    case 1, val = val(viKeep,:);
                    case 2, val = val(:,viKeep);
                    otherwise
                        disperr_('struct_select_: invalid iDimm');
                end
            case 3
                switch iDimm
                    case 1, val = val(viKeep,:,:);
                    case 2, val = val(:,viKeep,:);
                    case 3, val = val(:,:,viKeep);
                    otherwise, disperr_('struct_select_: invalid iDimm');
                end
            otherwise, disperr_('struct_select_: invalid # of dimensions (1-3 supported)');
        end %switch
        S.(vcName_) = val;
    catch
%         S = rmfield(S, vcName_);
        disperr_(sprintf('struct_select_: %s field error', vcName_));
    end
end %for
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_select_(S_clu, viKeep_clu)
% automatically trim clusters
% 7/20/17 JJJ: auto selecting vectors and matrics
% excl vnSpk_clu, viSite_clu, vrPosX_clu, vrPosY_clu

% Quality
csNames = fieldnames(S_clu);
if isempty(csNames), return; end
viMatch_v = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^v\w*_clu$'), csNames, 'UniformOutput', false));
S_clu = struct_select_(S_clu, csNames(viMatch_v), viKeep_clu);

viMatch_t = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^t\w*_clu$'), csNames, 'UniformOutput', false));
S_clu = struct_select_(S_clu, csNames(viMatch_t), viKeep_clu, 3); 

viMatch_c = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^c\w*_clu$'), csNames, 'UniformOutput', false));
S_clu = struct_select_(S_clu, csNames(viMatch_c), viKeep_clu);

% remap mrWavCor
if isfield(S_clu, 'mrWavCor')
    S_clu.mrWavCor = S_clu_wavcor_remap_(S_clu, viKeep_clu);
end
if isfield(S_clu, 'mrPos_clu')
    S_clu.mrPos_clu = S_clu.mrPos_clu(:,viKeep_clu);
end
% viMatch_m = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^m\w*_clu$'), csNames, 'UniformOutput', false));
% S_clu = struct_select_(S_clu, csNames(viMatch_m), viKeep_clu);

end %func



%--------------------------------------------------------------------------
% 10/24/17 JJJ: remap mrWavCor
function mrWavCor_new = S_clu_wavcor_remap_(S_clu, viKeep_clu)
if islogical(viKeep_clu), viKeep_clu = find(viKeep_clu); end
nClu_old = size(S_clu.mrWavCor, 1);
viOld = find(~isnan(S_clu.mrWavCor));
[viCol, viRow] = ind2sub([nClu_old,nClu_old], viOld);
vlKeep = find(ismember(viCol, viKeep_clu) & ismember(viRow, viKeep_clu));
[viCol, viRow, viOld] = deal(viCol(vlKeep), viRow(vlKeep), viOld(vlKeep));

nClu_new = numel(viKeep_clu);
mrWavCor_new = zeros(nClu_new);
viOld2New = zeros(nClu_old, 1);
viOld2New(viKeep_clu) = 1:nClu_new;
viNew = sub2ind([nClu_new, nClu_new], viOld2New(viCol), viOld2New(viRow));
mrWavCor_new(viNew) = S_clu.mrWavCor(viOld);
end %func


%--------------------------------------------------------------------------
% 10/27/17: Detailed error report
function flag = S_clu_valid_(S_clu)
% check the validity of the cluster by making sure the number of clusters is self-consistent.

flag = 0; %assumne invalid by default
csNames = fieldnames(S_clu);
if isempty(csNames), return; end
viMatch_v = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^v\w*_clu$'), csNames, 'UniformOutput', false));
viMatch_t = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^t\w*_clu$'), csNames, 'UniformOutput', false));
viMatch_c = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^c\w*_clu$'), csNames, 'UniformOutput', false));
viMatch_m = cellfun(@(vi)~isempty(vi), cellfun(@(cs)regexp(cs, '^m\w*_clu$'), csNames, 'UniformOutput', false));
[viMatch_v, viMatch_t, viMatch_c, viMatch_m] = multifun_(@find, viMatch_v, viMatch_t, viMatch_c, viMatch_m);
csNames_m = csNames(viMatch_m);
csNames_m{end+1} = 'mrWavCor';
nClu = S_clu.nClu;

vlError_v = cellfun(@(vc)numel(S_clu.(vc)) ~= nClu, csNames(viMatch_v)); 
vlError_t = cellfun(@(vc)size(S_clu.(vc),3) ~= nClu, csNames(viMatch_t)); 
vlError_c = cellfun(@(vc)numel(S_clu.(vc)) ~= nClu, csNames(viMatch_c));
vlError_m = cellfun(@(vc)all(size(S_clu.(vc)) ~= [nClu, nClu]), csNames_m);
[flag_v, flag_t, flag_c, flag_m] = multifun_(@(x)~any(x), vlError_v, vlError_t, vlError_c, vlError_m);
flag = flag_v && flag_t && flag_c && flag_m;
cell2vc__ = @(x)sprintf('%s, ', x{:});
if ~flag
    fprintf(2, 'S_clu_valid_: flag_v:%d, flag_t:%d, flag_c:%d, flag_m:%d\n', flag_v, flag_t, flag_c, flag_m);
    if ~flag_v, fprintf(2, '\t%s\n', cell2vc__(csNames(viMatch_v(vlError_v)))); end
    if ~flag_t, fprintf(2, '\t%s\n', cell2vc__(csNames(viMatch_t(vlError_t)))); end
    if ~flag_c, fprintf(2, '\t%s\n', cell2vc__(csNames(viMatch_c(vlError_c)))); end
    if ~flag_m, fprintf(2, '\t%s\n', cell2vc__(csNames(viMatch_m(vlError_m)))); end
end
end %func


%--------------------------------------------------------------------------
function [S_clu, S0] = S_clu_commit_(S_clu, vcMsg)
if nargin<2, vcMsg = ''; end
if ~S_clu_valid_(S_clu)
    fprintf(2, '%s: Cluster number is inconsistent.', vcMsg);
    S0 = get(0, 'UserData');
    S_clu = get_(S0, 'S_clu');
else
    S0 = set0_(S_clu);
end
end %func


%--------------------------------------------------------------------------
function [vrTime_drift, vrPos_drift] = drift_track_(S_clu, vrPosY_spk, P)
viTime_spk = double(get0_('viTime_spk'));
vrAmp_spk = get0_('vrAmp_spk');
nStep = round(get_set_(P, 'tbin_drift', 2) * P.sRateHz);
nBins = ceil(max(viTime_spk) / nStep);
vrTime_drift = ((1:nBins) * nStep - round(nStep/2)) / P.sRateHz;
viiTime_spk_drift = ceil(viTime_spk / nStep); % replaces discritize function
viClu_use = find(S_clu.vrSnr_clu(:) > quantile(S_clu.vrSnr_clu, .5)); % & S_clu.vnSpk_clu(:) > quantile(S_clu.vnSpk_clu, .5));
nClu_use = numel(viClu_use);

% spike based drift estimation
% pos_lim = quantile(vrPosY_spk, [.25, .75]);
% viSpk_use = find(vrAmp_spk < median(vrAmp_spk) & vrPosY_spk(:) > pos_lim(1) & vrPosY_spk(:) < pos_lim(2));
% vrPos_drift = accumarray(viiTime_spk_drift(viSpk_use), double(vrPosY_spk(viSpk_use)),[nBins,1],@mean,nan); %viiTime_clu1, vrPosY_spk(viSpk_clu1);

% cluster based drift estimation
mrPos_clu_drift = nan(nBins, nClu_use, 'single');
for iClu1=1:nClu_use
    iClu = viClu_use(iClu1);
    viSpk_clu1 = S_clu.cviSpk_clu{iClu};
    viiTime_clu1 = viiTime_spk_drift(viSpk_clu1);
    vrPos_clu1 = double(vrPosY_spk(viSpk_clu1));
    mrPos_clu_drift(:,iClu1) = accumarray(viiTime_clu1,vrPos_clu1,[nBins,1],@median,nan); %viiTime_clu1, vrPosY_spk(viSpk_clu1);
end
% mrPos_clu_drift = medfilt1(mrPos_clu_drift, 8);
vrActivity_clu = mean(~isnan(mrPos_clu_drift));
vrPos_drift = nanmean(mrPos_clu_drift(:,vrActivity_clu>quantile(vrActivity_clu, .9)),2);

figure; plot(vrTime_drift, vrPos_drift)
end %func


%--------------------------------------------------------------------------
function uistack_(h, vc)
try
    uistack(h, vc);
catch
end
end %func


%--------------------------------------------------------------------------
function S_fig = figWav_clu_count_(S_fig, S_clu, fText)
if nargin==0, [hFig, S_fig] = get_fig_cache_('FigWav'); end
if nargin<2, S_clu = []; end
if nargin<3, fText = 1; end
if isempty(S_clu), S_clu = get0_('S_clu'); end

if fText
    csText_clu = arrayfun(@(i)sprintf('%d(%d)', i, S_clu.vnSpk_clu(i)), 1:S_clu.nClu, 'UniformOutput', 0);
else
    csText_clu = arrayfun(@(i)sprintf('%d', i), 1:S_clu.nClu, 'UniformOutput', 0);
end
set(S_fig.hAx, 'Xtick', 1:S_clu.nClu, 'XTickLabel', csText_clu, 'FontSize', 8);
try
    if fText
        xtickangle(S_fig.hAx, -20); 
    else
        xtickangle(S_fig.hAx, 0); 
    end
catch; 
end

S_fig.fText = fText;
if nargout==0
    hFig = get_fig_cache_('FigWav');
    set(hFig, 'UserData', S_fig);
end
end %func


%--------------------------------------------------------------------------
% 10/8/17 JJJ: Opens the doc file from the current JRC folder
% 7/24/17 JJJ: open the latest manual from Dropbox if the link is valid
function doc_(vcFile_doc)
% Open IronClust PDF documentation 
if nargin<1, vcFile_doc = 'IronClust manual.pdf'; end
vcFile_doc = ircpath_(vcFile_doc);
if exist_file_(vcFile_doc)
    disp(vcFile_doc);
    open(vcFile_doc);
else
    fprintf(2, 'File does not exist: %s\n', vcFile_doc); 
end
end %func


%--------------------------------------------------------------------------
% 17/12/5 JJJ: Error info is saved
% Display error message and the error stack
function disperr_(vcMsg, hErr)
% disperr_(vcMsg): error message for user
% disperr_(vcMsg, hErr): hErr: MException class
% disperr_(vcMsg, vcErr): vcErr: error string
try
    dbstack('-completenames'); % display an error stack
    if nargin<1, vcMsg = ''; end
    if nargin<2, hErr = lasterror('reset');  end
    if ischar(hErr) % properly formatted error
        vcErr = hErr;
    else
        save_err_(hErr, vcMsg); % save hErr object?   
        vcErr = hErr.message;        
    end
catch
    vcErr = '';
end
if nargin==0
    fprintf(2, '%s\n', vcErr);
elseif ~isempty(vcErr)
    fprintf(2, '%s:\n\t%s\n', vcMsg, vcErr);
else
    fprintf(2, '%s:\n', vcMsg);
end
try gpuDevice(1); disp('GPU device reset'); catch, end
end %func


%--------------------------------------------------------------------------
% 17/12/5 JJJ: created
function save_err_(hErr, vcMsg)
% save error object
if nargin<2, vcMsg = ''; end

vcDatestr = datestr(now, 'yyyy_mmdd_HHMMSS');
S_err = struct('message', hErr.message(), 'error', vcMsg, ...
    'P', get0_('P'), 'time', vcDatestr, 'MException', hErr);
        
vcVar_err = sprintf('err_%s', vcDatestr);
eval(sprintf('%s = S_err;', vcVar_err));

% save to a file
vcFile_err = fullfile(ircpath_(), 'error_log.mat');
if ~exist_file_(vcFile_err)
    save(vcFile_err, vcVar_err, '-v7.3');
else
    try
        save(vcFile_err, vcVar_err ,'-append');
    catch
        save(vcFile_err, vcVar_err, '-v7.3'); % file might get too full, start over
    end
end
fprintf('Error log updated: %s\n', vcFile_err);
end %func


%--------------------------------------------------------------------------
function P = file2struct_(vcFile_file2struct)
% James Jun 2017 May 23
% Run a text file as .m script and result saved to a struct P
% _prm and _prb can now be called .prm and .prb files
P = []; 
if ~exist_file_(vcFile_file2struct), return; end
    
% load text file. trim and line break. remove comments.  replace 
csLines_file2struct = file2lines_(vcFile_file2struct);
csLines_file2struct = strip_comments_(csLines_file2struct);
if isempty(csLines_file2struct), return; end

P = struct();
try
    eval(cell2mat(csLines_file2struct'));

    S_ws = whos(); 
    csVars = {S_ws.name};
    csVars = setdiff(csVars, {'csLines_file2struct', 'vcFile_file2struct', 'P'});
    for i=1:numel(csVars)
        eval(sprintf('a = %s;', csVars{i}));
        P.(csVars{i}) = a;
    end
catch
    fprintf(2, 'Error in %s:\n\t', vcFile_file2struct);
    fprintf(2, '%s\n', lasterr());
    P=[];
end
end %func



%--------------------------------------------------------------------------
% Read a text file and output cell strings separated by new lines
% 7/24/17 JJJ: Code cleanup
function csLines = file2lines_(vcFile_file2struct)
csLines = {};
if ~exist_file_(vcFile_file2struct, 1), return; end

fid = fopen(vcFile_file2struct, 'r');
csLines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

csLines = csLines{1};
end %func


%--------------------------------------------------------------------------
% Strip comments from cell string
% 7/24/17 JJJ: Code cleanup
function csLines = strip_comments_(csLines)
csLines = csLines(cellfun(@(x)~isempty(x), csLines));
csLines = cellfun(@(x)strtrim(x), csLines, 'UniformOutput', 0);
csLines = csLines(cellfun(@(x)x(1)~='%', csLines));

% remove comments in the middle
for i=1:numel(csLines)
    vcLine1 = csLines{i};
    iComment = find(vcLine1=='%', 1, 'first');
    if ~isempty(iComment)
        vcLine1 = vcLine1(1:iComment-1);
    end
    vcLine1 = strrep(vcLine1, '...', '');
    if ismember(strsplit(vcLine1), {'for', 'end', 'if'})
        csLines{i} = [strtrim(vcLine1), ', ']; %add blank at the end
    else
        csLines{i} = [strtrim(vcLine1), ' ']; %add blank at the end
    end
end
% csLines = cellfun(@(x)strtrim(x), csLines, 'UniformOutput', 0);
csLines = csLines(cellfun(@(x)~isempty(x), csLines));
end %func


%--------------------------------------------------------------------------
% Strip comments from cell string
% 7/24/17 JJJ: Code cleanup
function S_bp = snr_bandpass_(P)
% compute SNR after bandpass
% read IMEC meta file and calibrate the file. Load the first bit of the file
% and bnad pass and estimate the SNR. 
% vrRmsQ_bp_site
% vrRmsQ_bp_site
% Compute SNR and apply gain correction
% show site 
% vrRmsQ_site
% vrSnr_clu
% apply a correction factor

vcFile_gain = get_set_(P, 'vcFile_gain');
nSites = numel(P.viSite2Chan);
if isempty(vcFile_gain)
    vr_Scale_uv_site = repmat(P.uV_per_bit, [nSites, 1]);
else
    try
        vrGainCorr = csvread(vcFile_gain, 1, 1);
    catch
        vrGainCorr = csvread(vcFile_gain, 0, 0);
    end
end

end %func


%--------------------------------------------------------------------------
% 7/26/17: Now accept csv file format
function vrTime_trial = loadTrial_(vcFile_trial)
% import  trial time (in seconds)
vrTime_trial = [];
try
    if ~exist_file_(vcFile_trial), return; end

    if matchFileExt_(vcFile_trial, '.mat')
        Strial = load(vcFile_trial);
        csFields = fieldnames(Strial);
        vrTime_trial = Strial.(csFields{1});
        if isstruct(vrTime_trial)
            vrTime_trial = vrTime_trial.times;
        end
    elseif matchFileExt_(vcFile_trial, '.csv')
        vrTime_trial = csvread(vcFile_trial);
        if isrow(vrTime_trial), vrTime_trial = vrTime_trial(:); end
    end
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
% convert a cell string to a character array separated by '\n'.
% 17/7/26 code cleanup and testing
function vc = toString_(cs)
if isempty(cs)
    vc = '';
elseif ischar(cs)
    vc = cs(:)';
elseif iscell(cs)
    vc = sprintf('%s\n', cs{:});
elseif isnumeric(cs)
    vc = sprintf('%f, ', cs(:));
end
end %func


%--------------------------------------------------------------------------
% Remove leading singular dimension
% 12/15/17 JJJ: squeeze out specific dimension
% 7/26/17 JJJ: code cleanup and testing
function val = squeeze_(val, idimm)
% val = squeeze_(val) : when squeezeing matrix, transpose if leading dimm is 1
% val = squeeze_(val, idimm): permute specified dimension out
size_ = size(val);
if nargin>=2
    dimm_ = [setdiff(1:ndims(val), idimm), idimm];
    val = permute(val, dimm_);
elseif numel(size_)==2 && size_(1) == 1
    val = val';
else
    val = squeeze(val);
end
end


%--------------------------------------------------------------------------
% Return sign-preserving square root
% 7/26/17 JJJ: Code cleanup and test
function x = signsqrt_(x)
x = sign(x) .* sqrt(abs(x));
end %func


%--------------------------------------------------------------------------
% Return sign-preserving log
% 7/26/17 JJJ: Code cleanup and test
function x = signlog_(x, e)
if nargin<2, e = .0001; end
x = sign(x) .* log(abs(x + e));
end %func


%--------------------------------------------------------------------------
% Install IronClust 1) create user.cfg 2) compile cuda 3) compile kilosort
% 7/26/17 Code cleanup and test
function install_()
fprintf('Installing ironclust (irc.m)\n');
% create user.cfg
% if exist_file_('user.cfg')
%     fid = fopen('user.cfg', 'w');
%     fprintf(fid, 'path_dropbox = ''C:\\Dropbox\\jrclust\\'';\n');
%     fprintf(fid, 'path_backup = ''c:\\backup\\'';\n');
%     fclose(fid);
%     edit_('user.cfg');
%     msgbox_('Set path to ''path_dropbox'' and ''path_backup'' in user.cfg.');
% end
compile_cuda_();
% compile_ksort_();
end %func


%--------------------------------------------------------------------------
% Compile CUDA codes for IronClust
% 10/5/17 JJJ: Error messages converted to warning
% 7/26/17 JJJ: Code cleanup and testing
function fSuccess = compile_cuda_(csFiles_cu, vcDeploy)
S_cfg = read_cfg_();
if nargin<1 || isempty(csFiles_cu)     
    csFiles_cu = S_cfg.csFiles_cuda; %version 3 cuda
elseif ischar(csFiles_cu)
    csFiles_cu = {csFiles_cu};
end
fDeploy = ifeq_(isempty(vcDeploy), 1, str2num(vcDeploy));

t1 = tic;
disp('Compiling CUDA codes...');
fSuccess = 1;
S_gpu = gpuDevice(1);
vcPath_nvcc = get_set_(S_cfg, 'vcPath_nvcc', get_nvcc_path_(S_gpu));
if isempty(vcPath_nvcc), fSuccess = 0; return ;end
if fSuccess
    try % determine compute capability version
        sm_ver = str2double(S_gpu.ComputeCapability);
        fprintf('GPU compute capability: %s\n', S_gpu.ComputeCapability);
        if fDeploy
            if sm_ver >=3.5
                vc_sm_ver = '35'; % supports over 4GB GPU memory
            else
                vc_sm_ver = '30'; % supports under 4GB GPU memory
            end
        else
           vc_sm_ver = sprintf('%d', round(sm_ver*10));
        end
    catch
        fSuccess = 0;
    end
    for i=1:numel(csFiles_cu)
        vcFile_ = ircpath_(csFiles_cu{i});
        vcCmd1 = sprintf('%s -ptx -m 64 -arch sm_%s "%s"', vcPath_nvcc, vc_sm_ver, vcFile_);
        fprintf('\t%s\n\t', vcCmd1);
        try          
            status = system(vcCmd1);
            fSuccess = fSuccess && (status==0);        
        catch
            fprintf('\tWarning: CUDA could not be compiled: %s\n', vcFile_); 
        end
    end
end
if ~fSuccess
    disp_cs_({'    Warning: CUDA could not be compiled but IronClust may work fine.', 
    sprintf('    If not, install CUDA toolkit v%0.1f and run "irc install".', S_gpu.ToolkitVersion),
    '    or try manually setting ''vcPath_nvcc'' in ''default.cfg'''});
end
fprintf('\tFinished compiling, took %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function vcPath_nvcc = get_nvcc_path_(S_gpu)
if ispc()    
    csDir = sub_dir_('C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*');
    if isempty(csDir), vcPath_nvcc=[]; return; end
    vrVer = cellfun(@(x)str2num(x(2:end)), csDir);
    [~,imin] = min(abs(vrVer-S_gpu.ToolkitVersion));    
    vcPath_nvcc = sprintf('"C:\\Program Files\\NVIDIA GPU Computing Toolkit\\CUDA\\v%0.1f\\bin\\nvcc"', vrVer(imin));
else
    vcPath_nvcc = '/usr/local/cuda/bin/nvcc';
end
if ~exist_file_(vcPath_nvcc)
    vcPath_nvcc = read_cfg_('nvcc_path');
end
end %func


%--------------------------------------------------------------------------
function csDir = sub_dir_(vc)
S_dir = dir(vc);
csDir = {S_dir.name};
csDir = csDir([S_dir.isdir]);
end %func


%--------------------------------------------------------------------------
% Compile Kilosort code
% 10/5/17 JJJ: Error messages converted to warning
% 7/26/17 JJJ: Code cleanup and test
function fSuccess = compile_ksort_()
fSuccess = 1;
nTry = 3;
csFiles_cu = {'./kilosort/mexMPmuFEAT.cu', './kilosort/mexWtW2.cu', './kilosort/mexMPregMU.cu'};
delete ./kilosort/*.mex*;
delete ./kilosort/*.lib;
for iFile = 1:numel(csFiles_cu)
    for iTry = 1:nTry
        try
            drawnow;
            eval(sprintf('mexcuda -largeArrayDims -v %s;', csFiles_cu{iFile}));
            fprintf('Kilosort compile success for %s.\n', csFiles_cu{iFile});
            break;
        catch
            if iTry == nTry
                fprintf('\tKilosort could not be compiled: %s\n', csFiles_cu{iFile});
                fSuccess = 0;
            end
        end
    end
end
if ~fSuccess
    fprintf('\tWarning: Kilosort could not be compiled but it may work fine. If not, install Visual Studio 2013 and run "irc install".\n');
end
end %func


%--------------------------------------------------------------------------
% Display list of toolbox and files needed
% 7/26/17 JJJ: Code cleanup and test
function [fList, pList] = disp_dependencies_()
[fList,pList] = matlab.codetools.requiredFilesAndProducts(mfilename());
if nargout==0
    disp('Required toolbox:');
    disp({pList.Name}');
    disp('Required files:');
    disp(fList');
end
end % func


%--------------------------------------------------------------------------
% @TODO: Limit the search es to .m files only
function flag = check_requirements_()
csToolbox_req = {'distrib_computing_toolbox', 'image_toolbox', 'signal_toolbox', 'statistics_toolbox'};
[fList, pList] = disp_dependencies_();

vlToolboxes = cellfun(@(vc)license('test', vc), csToolbox_req);
vlFiles = cellfun(@(vc)exist_file_(vc), fList);
flag = all([vlToolboxes(:); vlFiles(:)]); 
end %func


%--------------------------------------------------------------------------
function tr1 = fft_lowpass_(tr, fc, sRateHz)
if isempty(fc), tr1 = tr; return; end
dimm = size(tr);

mr = fft(reshape(tr, dimm(1), []));
vrFreq = fftshift((1:size(mr,1))/size(mr,1)) - .5;
vlUse = abs(vrFreq) <= fc/sRateHz/2;
mr(~vlUse,:) = 0;
tr1 = real(reshape(ifft(mr), dimm));
end %func


%--------------------------------------------------------------------------
function [cs,index] = sort_nat_(c,mode)
%sort_nat: Natural order sort of cell array of strings.
% usage:  [S,INDEX] = sort_nat(C)
%
% where,
%    C is a cell array (vector) of strings to be sorted.
%    S is C, sorted in natural order.
%    INDEX is the sort order such that S = C(INDEX);
%
% Natural order sorting sorts strings containing digits in a way such that
% the numerical value of the digits is taken into account.  It is
% especially useful for sorting file names containing index numbers with
% different numbers of digits.  Often, people will use leading zeros to get
% the right sort order, but with this function you don't have to do that.
% For example, if C = {'file1.txt','file2.txt','file10.txt'}, a normal sort
% will give you
%
%       {'file1.txt'  'file10.txt'  'file2.txt'}
%
% whereas, sort_nat will give you
%
%       {'file1.txt'  'file2.txt'  'file10.txt'}
%
% See also: sort

% Version: 1.4, 22 January 2011
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Set default value for mode if necessary.
if nargin < 2
	mode = 'ascend';
end

% Make sure mode is either 'ascend' or 'descend'.
modes = strcmpi(mode,{'ascend','descend'});
is_descend = modes(2);
if ~any(modes)
	error('sort_nat:sortDirection',...
		'sorting direction must be ''ascend'' or ''descend''.')
end

% Replace runs of digits with '0'.
c2 = regexprep(c,'\d+','0');

% Compute char version of c2 and locations of zeros.
s1 = char(c2);
z = s1 == '0';

% Extract the runs of digits and their start and end indices.
[digruns,first,last] = regexp(c,'\d+','match','start','end');

% Create matrix of numerical values of runs of digits and a matrix of the
% number of digits in each run.
num_str = length(c);
max_len = size(s1,2);
num_val = NaN(num_str,max_len);
num_dig = NaN(num_str,max_len);
for i = 1:num_str
	num_val(i,z(i,:)) = sscanf(sprintf('%s ',digruns{i}{:}),'%f');
	num_dig(i,z(i,:)) = last{i} - first{i} + 1;
end

% Find columns that have at least one non-NaN.  Make sure activecols is a
% 1-by-n vector even if n = 0.
activecols = reshape(find(~all(isnan(num_val))),1,[]);
n = length(activecols);

% Compute which columns in the composite matrix get the numbers.
numcols = activecols + (1:2:2*n);

% Compute which columns in the composite matrix get the number of digits.
ndigcols = numcols + 1;

% Compute which columns in the composite matrix get chars.
charcols = true(1,max_len + 2*n);
charcols(numcols) = false;
charcols(ndigcols) = false;

% Create and fill composite matrix, comp.
comp = zeros(num_str,max_len + 2*n);
comp(:,charcols) = double(s1);
comp(:,numcols) = num_val(:,activecols);
comp(:,ndigcols) = num_dig(:,activecols);

% Sort rows of composite matrix and use index to sort c in ascending or
% descending order, depending on mode.
[unused,index] = sortrows(comp);
if is_descend
	index = index(end:-1:1);
end
index = reshape(index,size(c));
cs = c(index);
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: Expand cellstring and wild card to list of files
function csFiles = list_files_(csFiles, fSortMode)
if nargin<2
    P = get0_('P');
    fSortMode = get_set_(P, 'sort_file_merge', 1);
end
if ischar(csFiles)
    if any(csFiles=='*')
        csFiles = dir_file_(csFiles, fSortMode); %sort by dates
    else
        csFiles = {csFiles}; %make it a cell
    end
elseif iscell(csFiles)
    csFiles = cellfun(@(vc)dir_file_(vc, fSortMode), csFiles, 'UniformOutput', 0);
    csFiles = [csFiles{:}];
end
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: Handle wild-card in makeprm case
% 7/25/17 Create a parameter file from a meta file
% Probe file can be interpreted from SpikeGLX meta file.
function [P, vcPrompt] = create_prm_file_(vcFile_bin, vcFile_prb, vcFile_template, fAsk, vcDir_prm)
% vcDir_prm: location of .prm file to be created
if nargin<2, vcFile_prb = ''; end
if nargin<3, vcFile_template = ''; end
if nargin<4, fAsk = 1; end
if nargin<5, vcDir_prm = ''; end % use vcFile_bin file location
vcDir_prm = format_dir_(vcDir_prm);

[P, vcPrompt] = deal([]); 
P0 = file2struct_(ircpath_(read_cfg_('default_prm')));  %P = defaultParam();
if exist_file_(vcFile_template)
    P0 = struct_merge_(P0, file2struct_(vcFile_template));
end
if ~exist_file_(vcFile_bin)
    vcPrompt = sprintf('%s does not exist.\n', vcFile_bin);    
    fprintf(2, '%s\n', vcPrompt); 
    return;
end    

if any(vcFile_bin=='*') %wild card provided
    P.csFile_merge = vcFile_bin;
    vcFile_bin = strrep(vcFile_bin, '*', '');
elseif isTextFile_(vcFile_bin)
    P.csFile_merge = vcFile_bin;
%     vcFile_bin = subsFileExt_(vcFile_bin, '.bin');
else
    if ~exist_file_(vcFile_bin)
        vcFile_bin_ = ircpath_(vcFile_bin);
        if exist_file_(vcFile_bin_), vcFile_bin = vcFile_bin_; end
    end
    if exist_file_(vcFile_bin)
        P.vcFile = vcFile_bin;
        P.csFile_merge = {};
    else
        vcPrompt = sprintf('%s does not exist.\n', vcFile_bin);    
        fprintf(2, '%s\n', vcPrompt); 
        return;
    end
end

% Load meta file
if isempty(P.csFile_merge)
    vcFile_meta = subsFileExt_(vcFile_bin, '.meta');
else
    csFiles_bin = filter_files_(P.csFile_merge);
    if isempty(csFiles_bin)
        vcFile_meta = '';
    else
        vcFile_meta = subsFileExt_(csFiles_bin{1}, '.meta');
    end
end
vcFile_meta = ircpath_(vcFile_meta, 1);
P_meta = read_meta_file_(vcFile_meta);
if isempty(P_meta), P=[]; return; end

% Get the probe file if missing
if isempty(vcFile_prb)
    if isfield(P_meta.Smeta, 'imProbeOpt')
        if P_meta.Smeta.imProbeOpt > 0
            vcFile_prb = sprintf('imec3_opt%d.prb', round(P_meta.Smeta.imProbeOpt));
        end
    end
end
if isempty(vcFile_prb) % ask user
    vcFile_prb = inputdlg({'Probe file'}, 'Please specify a probe file', 1, {''});
    if isempty(vcFile_prb), P=[]; return; end
    vcFile_prb = vcFile_prb{1};
    if isempty(vcFile_prb)
        P = [];
        fprintf(2, 'You must specify a probe file (.prb)\n'); 
        return; 
    end
end

% Assign prm file name
[~,vcPostfix,~] = fileparts(vcFile_prb);
P.vcFile_prm = subsDir_(subsFileExt_(vcFile_bin, ['_', vcPostfix, '.prm']), vcDir_prm);
P.probe_file = vcFile_prb;
try
    S_prb = file2struct_(find_prb_(vcFile_prb));
%     P = struct_merge_(P, S_prb);
    if isfield(S_prb, 'maxSite'), P.maxSite = S_prb.maxSite; end
    if isfield(S_prb, 'nSites_ref'), P.nSites_ref = S_prb.nSites_ref; end
catch
    disperr_(sprintf('Error loading the probe file: %s\n', vcFile_prb));
end

if exist_file_(P.vcFile_prm) && fAsk
    vcAns = questdlg_('File already exists. Overwrite prm file?', 'Warning', 'Yes', 'No', 'No');
    if ~strcmpi(vcAns, 'Yes')
        P = [];
        vcPrompt = 'Cancelled by user.';
        return;
    end
end

% Load prb file
if isfield(P, 'template_file')
    P = struct_merge_(file2struct_(P.template_file), P);
end
P = struct_merge_(P0, P);    
P = struct_merge_(P, P_meta);    
P = struct_merge_(P, file_info_(vcFile_bin));
P.duration_file = P.nBytes_file / bytesPerSample_(P.vcDataType) / P.nChans / P.sRateHz; %assuming int16
P.version = version_();

% Write to prm file
try
    copyfile(ircpath_(read_cfg_('default_prm')), P.vcFile_prm, 'f');
catch
    fprintf(2, 'Invalid path: %s\n', P.vcFile_prm);
    return;
end
edit_prm_file_(P, P.vcFile_prm);

vcPrompt = sprintf('Created a new parameter file\n\t%s', P.vcFile_prm);
disp(vcPrompt);
if fAsk, edit_(P.vcFile_prm); end % Show settings file
end %func


%--------------------------------------------------------------------------
function vcDir = format_dir_(vcDir, fCreate_dir)
% Append the filesep at the end of the directory
% create a directory if it doesn't exist (default)

if nargin<2, fCreate_dir = 1; end

% apple vs PC directory format
if isempty(vcDir), return; end
if vcDir(end) ~= '\' && vcDir(end) ~= '/'
    vcDir(end+1) = filesep();
end
if fCreate_dir, mkdir_(vcDir); end
end %func


%--------------------------------------------------------------------------
% 12/28/17 JJJ: P can be empty (v3.2.1)
% 8/4/17 JJJ: selective struct merge
% 7/31/17 JJJ: documentation and testing
function P = struct_merge_(P, P1, csNames)
% Merge second struct to first one
% P = struct_merge_(P, P_append)
% P = struct_merge_(P, P_append, var_list) : only update list of variable names
if isempty(P), P=P1; return; end % P can be empty
if isempty(P1), return; end
if nargin<3, csNames = fieldnames(P1); end
if ischar(csNames), csNames = {csNames}; end

for iField = 1:numel(csNames)
    vcName_ = csNames{iField};
    if isfield(P1, vcName_), P.(vcName_) = P1.(vcName_); end
end
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: Documentation and added test ouput
function S_out = test_(vcFunc, cell_Input, nOutput, fVerbose, fDeleteEmpty)
% S_out = test_(vcFunc, {input1, input2, ...}, nOutput)

if nargin<2, cell_Input = {}; end
if nargin<3, nOutput = []; end
if nargin<4, fVerbose = ''; end
if nargin<5, fDeleteEmpty = ''; end

if isempty(fDeleteEmpty), fDeleteEmpty = 1; end
if isempty(nOutput), nOutput = 1; end
if ~iscell(cell_Input), cell_Input = {cell_Input}; end
if isempty(fVerbose), fVerbose = 1; end
if fDeleteEmpty, delete_empty_files_(); end

try
    switch nOutput
        case 0
            feval(vcFunc, cell_Input{:});
            S_out = [];
        case 1
            [out1] = feval(vcFunc, cell_Input{:});
            S_out = makeStruct_(out1);
        case 2
            [out1, out2] = feval(vcFunc, cell_Input{:});
            S_out = makeStruct_(out1, out2);
        case 3
            [out1, out2, out3] = feval(vcFunc, cell_Input{:});
            S_out = makeStruct_(out1, out2, out3);
        case 4
            [out1, out2, out3, out4] = feval(vcFunc, cell_Input{:});
            S_out = makeStruct_(out1, out2, out3, out4);
    end %switch
    if fVerbose
        if nOutput>=1, fprintf('[%s: out1]\n', vcFunc); disp(S_out.out1); end
        if nOutput>=2, fprintf('[%s: out2]\n', vcFunc); disp(S_out.out2); end
        if nOutput>=3, fprintf('[%s: out3]\n', vcFunc); disp(S_out.out3); end
        if nOutput>=4, fprintf('[%s: out4]\n', vcFunc); disp(S_out.out4); end
    end
catch
    disperr_();
    S_out = [];
end
end %func


%--------------------------------------------------------------------------
% 4/17/18 JJJ: documentation and testing
function varargout = call_(vcFunc, cell_Input, nOutput)
% S_out = call_(vcFunc, cell_Input, nOutput)
% varargout = call_(vcFunc, cell_Input)

if vcFunc(end) ~= '_', vcFunc = [vcFunc, '_']; end
if nargin<3, nOutput = []; end
if ~isempty(nOutput)
    varargout{1} = test_(vcFunc, cell_Input, nOutput, 0, 0);
else
    nOutput = nargout();
    S_out = test_(vcFunc, cell_Input, nOutput, 0, 0);
    if isempty(S_out), varargout{1} = []; return; end % error occured
    switch nOutput
        case 1, varargout{1} = S_out.out1;
        case 2, [varargout{1}, varargout{2}] = deal(S_out.out1, S_out.out2);
        case 3, [varargout{1}, varargout{2}, varargout{3}] = deal(S_out.out1, S_out.out2, S_out.out3);
        case 4, [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = deal(S_out.out1, S_out.out2, S_out.out3, S_out.out4);
    end %switch
end
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: documentation and testing
function P = file_info_(vcFile)
% Returns empty if file not found or multiple ones found

S_dir = dir(vcFile);
if numel(S_dir)==1
    P = struct('vcDate_file', S_dir.date, 'nBytes_file', S_dir.bytes);
else
    P = []; 
end
end %func


%--------------------------------------------------------------------------
% 12/21/17 JJJ: clearing a batch file (v3.2.0)
% 10/15/17 JJJ: clear function memory
% 7/31/17 JJJ: Documentation and test
function clear_(vcFile_prm)
% Clear IronClust global variables
if nargin<1, vcFile_prm = ''; end
global fDebug_ui;

% clear irc
clear(mfilename()); % clear persistent variables in the current file. Same as clear irc
clear global tnWav_spk tnWav_raw trFet_spk mnWav1 mrWav1 mnWav S_gt vcFile_prm_
clear functions % clear function memory 10/15/17 JJJ

set(0, 'UserData', []);   
try gpuDevice(1); catch, fprintf(2, 'GPU reset error.\n'); end
fprintf('Memory cleared on CPU and GPU\n');
fDebug_ui = [];

if isempty(vcFile_prm), return; end

% clear specific parameter file. erase prm file related files
if matchFileExt_(vcFile_prm, '.batch')
    csFile_prm = load_batch_(vcFile_prm);
elseif matchFileExt_(vcFile_prm, '.prm')
    csFile_prm = {vcFile_prm};
else
    return;
end
for iFile = 1:numel(csFile_prm)
    csFiles_del = strrep(csFile_prm{iFile}, '.prm', {'_jrc.mat', '_spkraw.jrc', '_spkwav.jrc', '_spkfet.jrc', '_log.mat', '_gt1.mat'});
    delete_files_(csFiles_del);    
end
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: Documentation and test
function delete_empty_files_(vcDir)
if nargin<1, vcDir=[]; end
delete_files_(find_empty_files_(vcDir));
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: Documentation and testing
function csFiles = find_empty_files_(vcDir)
% find files with 0 bytes

if nargin==0, vcDir = []; end
if isempty(vcDir), vcDir = pwd(); end
vS_dir = dir(vcDir);
viFile = find([vS_dir.bytes] == 0 & ~[vS_dir.isdir]);
csFiles = {vS_dir(viFile).name};
csFiles = cellfun(@(vc)[vcDir, filesep(), vc], csFiles, 'UniformOutput', 0);
end %func


%--------------------------------------------------------------------------
% 7/31/17 JJJ: Documentation and test
function delete_files_(csFiles, fVerbose)
% Delete list of files
% delete_files_(vcFile)
% delete_files_(csFiles)
% delete_files_(csFiles, fVerbose)

if nargin<2, fVerbose = 1; end
if ischar(csFiles), csFiles = {csFiles}; end
for iFile = 1:numel(csFiles)
    fDeleted = delete_file_(csFiles{iFile});
    if fVerbose && fDeleted
        fprintf('\tdeleted %s.\n', csFiles{iFile});
    end
end
end %func


%--------------------------------------------------------------------------
function flag = delete_file_(vcFile)
flag = 0;
if ~exist_file_(vcFile), return; end
try
    delete(vcFile);
catch
    disperr_();
    return;
end
% vcCmd = ifeq_(ispc(), 'del', 'rm');
% eval(sprintf('system(''%s "%s"'');', vcCmd, vcFile));
flag = 1;
end %func


%--------------------------------------------------------------------------
% 9/14/17 JJJ: supports custom template.prm file
% 8/2/17 JJJ: Testing and documentation
function [vcFile_prm, vcPrompt] = makeprm_(vcFile_bin, vcFile_prb, fAsk, vcFile_template, vcDir_prm)
% Make a paramter file
% Usage
% -----
% vcFile_prm = makeprm_(vcFile_bin, vcFile_prb, fAsk, vcFile_template)
% vcFile_prm = makeprm_(vcFile_bin, vcFile_template, fAsk)
% vcFile_prm = makeprm_(vcFile_txt, vcFile_template)
%
% Input
% -----
% vcDir_prm: directory to write prm file. All the output files will be
% placed there.

global fDebug_ui
if isempty(vcFile_prb), vcFile_prb = ''; end
if nargin<3, fAsk = 1; end
if nargin<4, vcFile_template = ''; end
if nargin<5, vcDir_prm = ''; end
fOverwrite = 0;
if fDebug_ui==1, fAsk = 0; end
[vcFile_prm, vcPrompt] = deal([]);
if ~exist_file_(vcFile_bin, 1), return; end

if matchFileExt_(vcFile_prb, '.prm')
    vcFile_template = vcFile_prb;
    vcFile_prb = get_(file2struct_(vcFile_template), 'probe_file');
end

% import binary files
vcFile_gt_mat = '';
if matchFileEnd_(vcFile_bin, '.rhs') % INTAN RHS format
    vcFile_rhs = vcFile_bin;    
    vcFile_bin = strrep(vcFile_rhs, '.rhs', '.bin');
    if ~exist_file_(vcFile_bin) || fOverwrite
        [vcFile_bin, vcFile_meta] = rhs2bin_(vcFile_rhs); % also write vcFile_meta
        if isempty(vcFile_bin), fprintf(2, '%s: invalid format\n', vcFile_rhs); return; end
    end
elseif matchFileEnd_(vcFile_bin, '.mda') % MDA format (mountainlab)
    fprintf(2, 'Use "makeprm-mda" command for .mda files.\n');
    fprintf(2, '\tUsage: "irc makeprm-mda myrecording.mda myprobe.csv myarg.txt tempdir myparam.prm"\n');
    return;
elseif matchFileEnd_(vcFile_bin, '.raw') % Pierre Yger format (.raw)
    [vcFile_meta, ~, vcFile_gt_mat] = raw2meta_(vcFile_bin);
    fprintf('Converted from .raw (Pirre Yger) to .bin format\n');
elseif matchFileEnd_(vcFile_bin, '.txt')
    % generate and export to .batch file by replacing .txt file
    vcFile_batch = makeprm_list_(vcFile_bin, vcFile_prb, vcFile_template);
    fprintf('Wote to %s\n', vcFile_batch);
    edit_(vcFile_batch);
    return;
elseif matchFileEnd_(vcFile_bin, '.h5')
    makeprm_template_(vcFile_bin, vcFile_prb, vcFile_template);
    return;
end
set(0, 'UserData', []); %clear memory

[P, vcPrompt] = create_prm_file_(vcFile_bin, vcFile_prb, vcFile_template, fAsk, vcDir_prm);   
if isempty(P)
    [vcFile_prm, vcPrompt] = deal('');
    return;
end
set0_(P);
vcFile_prm = P.vcFile_prm;

if exist_file_(vcFile_gt_mat)
    edit_prm_file_(struct('vcFile_gt', vcFile_gt_mat), vcFile_prm); % update groundtruth file field
end
end


%--------------------------------------------------------------------------
% JJJ 2018/03/19
function [vcFile_meta, S_meta, vcFile_gt_mat] = raw2meta_(vcFile_raw)
% vcFile_raw = 'K:\PierreYger\20160415_patch2\patch_2_MEA.raw';
% .raw file header info
%    'MC_DataTool binary conversion
%     Version 2.6.15
%     MC_REC file = "E:\MC_Rack Data\20160415\patch_2_MEA.mcd"
%     Sample rate = 20000
%     ADC zero = 32768
%     El = 0.1042�V/AD
%     Streams = El_01;El_02;El_03;El_04;El_05;El_06;El_07;El_08;El_09;El_10;El_11;El_12;El_13;El_14;El_15;El_16;El_17;El_18;El_19;El_20;El_21;El_22;El_23;El_24;El_25;El_26;El_27;El_28;El_29;El_30;El_31;El_32;El_33;El_34;El_35;El_36;El_37;El_38;El_39;El_40;El_41;El_42;El_43;El_44;El_45;El_46;El_47;El_48;El_49;El_50;El_51;El_52;El_53;El_54;El_55;El_56;El_57;El_58;El_59;El_60;El_61;El_62;El_63;El_64;El_65;El_66;El_67;El_68;El_69;El_70;El_71;El_72;El_73;El_74;El_75;El_76;El_77;El_78;El_79;El_80;El_81;El_82;El_83;El_84;El_85;El_86;El_87;El_88;El_89;El_90;El_91;El_92;El_93;El_94;El_95;El_96;El_97;El_98;El_99;El_100;El_101;El_102;El_103;El_104;El_105;El_106;El_107;El_108;El_109;El_110;El_111;El_112;El_113;El_114;El_115;El_116;El_117;El_118;El_119;El_120;El_121;El_122;El_123;El_124;El_125;El_126;El_127;El_128;El_129;El_130;El_131;El_132;El_133;El_134;El_135;El_136;El_137;El_138;El_139;El_140;El_141;El_142;El_143;El_144;El_145;El_146;El_147;El_148;El_149;El_150;El_151;El_152;El_153;El_154;El_155;El_156;El_157;El_158;El_159;El_160;El_161;El_162;El_163;El_164;El_165;El_166;El_167;El_168;El_169;El_170;El_171;El_172;El_173;El_174;El_175;El_176;El_177;El_178;El_179;El_180;El_181;El_182;El_183;El_184;El_185;El_186;El_187;El_188;El_189;El_190;El_191;El_192;El_193;El_194;El_195;El_196;El_197;El_198;El_199;El_200;El_201;El_202;El_203;El_204;El_205;El_206;El_207;El_208;El_209;El_210;El_211;El_212;El_213;El_214;El_215;El_216;El_217;El_218;El_219;El_220;El_221;El_222;El_223;El_224;El_225;El_226;El_227;El_228;El_229;El_230;El_231;El_232;El_233;El_234;El_235;El_236;El_237;El_238;El_239;El_240;El_241;El_242;El_243;El_244;El_245;El_246;El_247;El_248;El_249;El_250;El_251;El_252;El_253;El_254;El_255;El_256
%     EOH
%     '

if ~matchFileExt_(vcFile_raw, '.raw') % incorrect format
    [vcFile_meta, S_meta, vcFile_gt_mat] = deal([]); return;
end

MAX_HEADER = 10000; % load 10KB
vcFile_meta = strrep(vcFile_raw, '.raw', '.meta');

% look for "EOH\r\n" header ending
fid = fopen(vcFile_raw);
try
    nBytes_file = filesize_(vcFile_raw);
catch
    nBytes_file = inf;
end
vcHeader = fread(fid, min(MAX_HEADER, nBytes_file), '*char')';
header_offset = regexpi(vcHeader, 'EOH\r\n', 'end');
header_offset = header_offset(1);
fclose(fid);
vcHeader = vcHeader(1:header_offset);

% Parse header info
uV_per_bit = cs2num_rhs_(regexp(vcHeader, 'El = (\d+).(\d+)', 'match'), ' = ');
sRateHz = cs2num_rhs_(regexp(vcHeader, 'Sample rate = (\d+)', 'match'), ' = ');
cs_ = regexp(vcHeader, 'Streams = (\S+)', 'match');
nChans = sum(cs_{1} == ';') + 1;
vcDataType = 'uint16';

% write
S_meta = makeStruct_(uV_per_bit, sRateHz, nChans, vcDataType, header_offset);
struct2meta_(S_meta, vcFile_meta);

% Search for the ground truth
csFile_gt_npy = dir_(subs_file_(vcFile_raw, '*.npy'));    
if ~isempty(csFile_gt_npy)
    vcFile_gt_mat = import_gt_(csFile_gt_npy{1}); 
else
    vcFile_gt_mat = '';
end
end %func


%--------------------------------------------------------------------------
% JJJ 2018/08/15
function num = cs2num_rhs_(cs, delim)
if nargin<2, delim = ' = '; end
cs_ = strsplit(cs{1}, ' = ');
num = str2num(cs_{2});
end %func
    

%--------------------------------------------------------------------------
% JJJ 2018/03/19
function [vcFile_bin, vcFile_meta] = rhs2bin_(vcFile_rhs) % also write vcFile_meta
try
    S_rhs = import_rhs(vcFile_rhs);
    
    % Write .bin file
    vcFile_bin = strrep(vcFile_rhs, '.rhs', '.bin');
    write_bin_(vcFile_bin, single(S_rhs.amplifier_data));
    
    % Write _stim.bin file
    write_bin_(strrep(vcFile_rhs, '.rhs', '_stim.bin'), single(S_rhs.stim_data));
    
    % Write .meta file
    % http://intantech.com/files/Intan_RHS2116_datasheet.pdf
%     csLines = {};
%     csLines{end+1} = sprintf('sRateHz=%0.0f', S_rhs.frequency_parameters.amplifier_sample_rate);
%     csLines{end+1} = sprintf('nChans=%d', size(S_rhs.amplifier_data,1));
%     csLines{end+1} = 'scale=0.195';
%     csLines{end+1} = 'vcDataType=single';
    vcFile_meta = strrep(vcFile_rhs, '.rhs', '.meta');
%     cellstr2file_(vcFile_meta, csLines);

    S_meta = struct('uV_per_bit', .195, ...
        'sRateHz', S_rhs.frequency_parameters.amplifier_sample_rate, ...
        'nChans', size(S_rhs.amplifier_data,1), ...
        'vcDataType', 'single');
    struct2meta_(S_meta, vcFile_meta);    
catch
    vcFile_bin = [];
end
end %func


%--------------------------------------------------------------------------
function [S_mda, fid_r] = readmda_header_(fname)
fid_r = fopen(fname,'rb');

try
    code=fread(fid_r,1,'int32');
catch
    error('Problem reading file: %s',fname);
end
if (code>0) 
    num_dims=code;
    code=-1;
    nBytes_sample = 4;
else
    nBytes_sample = fread(fid_r,1,'int32');
    num_dims=fread(fid_r,1,'int32');    
end
dim_type_str='int32';
if (num_dims<0)
    num_dims=-num_dims;
    dim_type_str='int64';
end

dimm=zeros(1,num_dims);
for j=1:num_dims
    dimm(j)=fread(fid_r,1,dim_type_str);
end

if (code==-1)
    vcDataType = 'single';
elseif (code==-2)
    vcDataType = 'uchar';
elseif (code==-3)
    vcDataType = 'single';
elseif (code==-4)
    vcDataType = 'int16';
elseif (code==-5)
    vcDataType = 'int32';
elseif (code==-6)
    vcDataType = 'uint16';
elseif (code==-7)
    vcDataType = 'double';
elseif (code==-8)
    vcDataType = 'uint32';
else
    vcDataType = ''; % unknown
end %if

S_mda = struct('dimm', dimm, 'vcDataType', vcDataType, ...
    'nBytes_header', ftell(fid_r), 'nBytes_sample', nBytes_sample);

if nargout<2, fclose(fid_r); end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: added '.' if dir is empty
% 7/31/17 JJJ: Substitute file extension
function varargout = subsFileExt_(vcFile, varargin)
% Substitute the extension part of the file
% [out1, out2, ..] = subsFileExt_(filename, ext1, ext2, ...)

[vcDir_, vcFile_, ~] = fileparts(vcFile);
if isempty(vcDir_), vcDir_ = '.'; end
for i=1:numel(varargin)
    vcExt_ = varargin{i};    
    varargout{i} = [vcDir_, filesep(), vcFile_, vcExt_];
end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Created and tested
function vcFile_new = subs_dir_(vcFile, vcDir_new)
% Substitute dir
[vcDir_new,~,~] = fileparts(vcDir_new);
[~, vcFile, vcExt] = fileparts(vcFile);
vcFile_new = fullfile(vcDir_new, [vcFile, vcExt]);
end % func


%--------------------------------------------------------------------------
% 8/14/18 JJJ: Created and tested
function vcFile_full = subs_file_(vcFile, vcFile_new)
% Substitute dir
[vcDir_new,~,~] = fileparts(vcFile);
[~, vcFile_new1, vcFile_new2] = fileparts(vcFile_new);
vcFile_full = fullfile(vcDir_new, [vcFile_new1, vcFile_new2]);
end % func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function P = read_meta_file_(vcFile_meta)
% Parse meta file, ask user if meta file doesn't exist
P = [];
try
    if exist_file_(vcFile_meta)
        S_meta = read_whisper_meta_(vcFile_meta);
        if ~isfield(S_meta, 'uV_per_bit') && isfield(S_meta, 'scale')
            S_meta.uV_per_bit = S_meta.scale;
        end
        P = struct('sRateHz', S_meta.sRateHz, 'uV_per_bit', S_meta.uV_per_bit, 'nChans', S_meta.nChans, 'vcDataType', S_meta.vcDataType);
        if isfield(S_meta, 'header_offset'), P.header_offset = S_meta.header_offset; end
        P.Smeta = S_meta;    
    else
        fprintf('%s is not found. Asking users to fill out the missing info\n', vcFile_meta);
        csAns = inputdlg_({...
            'sampling rate (Hz)', '# channels in file', ...
            'uV/bit', 'Header offset (bytes)', ...
            'Data Type (int16, uint16, single, double)', 'Neuropixels option (0 if N/A)'}, ...
                'Recording format', 1, {'30000', '385', '1','0','int16','0'});
        if isempty(csAns), return; end
        P = struct('sRateHz', str2double(csAns{1}), 'nChans', str2double(csAns{2}), ...
            'uV_per_bit', str2double(csAns{3}), 'header_offset', str2double(csAns{4}), ...
            'vcDataType', csAns{5}, 'imProbeOpt', str2double(csAns{6}));
        P.Smeta = P;
    end
catch
    disperr_('read_meta_file_');
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function S = read_whisper_meta_(vcFname)
% Import SpikeGLX meta file format

S = [];
viRef_imec3 = [37 76 113 152 189 228 265 304 341 380];

% Ask user if file is missing
if nargin < 1
    [FileName,PathName,FilterIndex] = uigetfile();
    vcFname = fullfile(PathName, FileName);
    if ~FilterIndex, return; end
end

try
    %Read Meta
    S = meta2struct_(vcFname);
    S.vcDataType = get_set_(S, 'vcDataType', 'int16');
    S.ADC_bits = bytesPerSample_(S.vcDataType) * 8;    
    if ~isfield(S, 'vcProbe'), S.vcProbe = ''; end
    
    %convert new fields to old fields   
    if isfield(S, 'uV_per_bit')
        return; % directly written by irc conversion utility
    elseif isfield(S, 'scale')  % rhs format intan (cinverted)   
        if ~isfield(S, 'nChans'), S.nChans = get_(S, 'nSavedChans'); end
        S.uV_per_bit = S.scale;
        % sRateHz, nChans, scale, vcDataType, header_offset (opt) exists
        return;
    elseif isfield(S, 'niSampRate')        
        % SpikeGLX
        S.nChans = S.nSavedChans;
        S.sRateHz = S.niSampRate;
        S.rangeMax = S.niAiRangeMax;
        S.rangeMin = S.niAiRangeMin;
        S.auxGain = S.niMNGain;
        try
            S.outputFile = S.fileName;
            S.sha1 = S.fileSHA1;      
            S.vcProbe = 'imec2';
        catch
            S.outputFile = '';
            S.sha1 = [];      
        end
    elseif isfield(S, 'imSampRate')
        % IMECIII
        S.nChans = S.nSavedChans;
        S.sRateHz = S.imSampRate;
        S.rangeMax = S.imAiRangeMax;
        S.rangeMin = S.imAiRangeMin;
        S.ADC_bits = 10;  %10 bit adc but 16 bit saved
        vnIMRO = textscan(S.imroTbl, '%d', 'Delimiter', '( ),');
        vnIMRO = vnIMRO{1};
        S.auxGain = double(vnIMRO(9)); %hard code for now;
        S.auxGain_lfp = double(vnIMRO(10)); %hard code for now;
        S.vcProbe = sprintf('imec3_opt%d', vnIMRO(3));
        S.nSites = vnIMRO(4);
        S.viSites = setdiff(1:S.nSites, viRef_imec3); %sites saved
        try
            S.S_imec3 = imec3_imroTbl_(S);
        catch
            S.S_imec3 = [];
        end
    elseif isfield(S, 'sample_rate') %nick steinmetz
        S.nChans = S.n_channels_dat;
        S.sRateHz = S.sample_rate;
    end
    
     %number of bits of ADC [was 16 in Chongxi original]
    try
        S.scale = ((S.rangeMax-S.rangeMin)/(2^S.ADC_bits))/S.auxGain * 1e6;  %uVolts
    catch
        S.scale = 1;
    end    
    S.uV_per_bit = S.scale;
    if isfield(S, 'auxGain_lfp')
        S.uV_per_bit_lfp = S.scale * S.auxGain / S.auxGain_lfp;
    end
catch
    disp(lasterr);
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function S = meta2struct_(vcFile)
% Convert text file to struct
S = struct();
if ~exist_file_(vcFile, 1), return; end

fid = fopen(vcFile, 'r');
mcFileMeta = textscan(fid, '%s%s', 'Delimiter', '=',  'ReturnOnError', false);
fclose(fid);
csName = mcFileMeta{1};
csValue = mcFileMeta{2};
for i=1:numel(csName)
    vcName1 = csName{i};
    if vcName1(1) == '~', vcName1(1) = []; end
    try         
        eval(sprintf('%s = ''%s'';', vcName1, csValue{i}));
        eval(sprintf('num = str2double(%s);', vcName1));
        if ~isnan(num)
            eval(sprintf('%s = num;', vcName1));
        end
        eval(sprintf('S = setfield(S, ''%s'', %s);', vcName1, vcName1));
    catch
        fprintf('%s = %s error\n', csName{i}, csValue{i});
    end
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function vcAns = questdlg_(varargin)
% Display a question dialog box
global fDebug_ui
% if get_set_([], 'fDebug_ui', 0)
if fDebug_ui == 1
    vcAns = 'Yes';
else    
    vcAns = questdlg(varargin{:});
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function varargout = get0_(varargin)
% returns get(0, 'UserData') to the workspace
% [S0, P] = get0_();
% [S0, P, S_clu] = get0_();
% [var1, var2] = get0_('var1', 'var2'); %sets [] if doesn't exist
S0 = get(0, 'UserData'); 
if ~isfield(S0, 'S_clu'), S0.S_clu = []; end
if nargin==0
    varargout{1} = S0; 
    if nargout==0, assignWorkspace_(S0); return; end
    if nargout>=1, varargout{1} = S0; end
    if nargout>=2, varargout{2} = S0.P; end
    if nargout>=3, varargout{3} = S0.S_clu; end
    return;
end
for i=1:nargin
    try                
        eval(sprintf('%s = S0.%s;', varargin{i}, varargin{i}));
        varargout{i} = S0.(varargin{i});
    catch
        varargout{i} = [];
    end
end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Output message is added
% 8/2/17 JJJ: Test and documentation
function vcMsg = assignWorkspace_(varargin)
% Assign variables to the Workspace
vcMsg = {};
for i=1:numel(varargin)
    if ~isempty(varargin{i})
        assignin('base', inputname(i), varargin{i});
        vcMsg{end+1} = sprintf('assigned ''%s'' to workspace\n', inputname(i));        
    end
end
vcMsg = cell2mat(vcMsg);
if nargout==0, fprintf(vcMsg); end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function n = bytesPerSample_(vcDataType)
% Return number of bytes per data type

switch lower(vcDataType)
    case {'char', 'byte', 'int8', 'uint8'}
        n = 1;    
    case {'int16', 'uint16'}
        n = 2;
    case {'single', 'float', 'int32', 'uint32'}
        n = 4;
    case {'double', 'int64', 'uint64'}
        n = 8;
    otherwise
        n = [];
        fprintf(2, 'Unsupported data type: %s\n', vcDataType);
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function edit_prm_file_(P, vcFile_prm)
% Modify the parameter file using the variables in the P struct

csLines = file2cellstr_(vcFile_prm); %read to cell string
csLines_var = first_string_(csLines);

csName = fieldnames(P);
csValue = cellfun(@(vcField)P.(vcField), csName, 'UniformOutput',0);
for i=1:numel(csName)
    vcName = csName{i}; %find field name with 
    if isstruct(csValue{i}), continue; end %do not write struct
    vcValue = field2str_(csValue{i});
    iLine = find(strcmpi(csLines_var, vcName));
    if numel(iLine)>1 % more than one variable found
        error(['edit_prm_file_: Multiple copies of variables found: ' vcName]); 
    elseif isempty(iLine) %did not find, append
        csLines{end+1} = sprintf('%s = %s;', vcName, vcValue);
    else    
        vcComment = getCommentExpr_(csLines{iLine});        
        csLines{iLine} = sprintf('%s = %s;\t\t\t%s', vcName, vcValue, vcComment);    
    end
end
cellstr2file_(vcFile_prm, csLines);
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function csLines = file2cellstr_(vcFile)
% read text file to a cell string
try
    fid = fopen(vcFile, 'r');
    csLines = {};
    while ~feof(fid), csLines{end+1} = fgetl(fid); end
    fclose(fid);
    csLines = csLines';
catch
    csLines = {};
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Test and documentation. Added strtrim
function cs = first_string_(cs)
% Return the first string, which is typically a variable name

if ischar(cs), cs = {cs}; end

for i=1:numel(cs)
    cs{i} = strtrim(cs{i});
    if isempty(cs{i}), continue; end
    cs1 = textscan(cs{i}, '%s', 'Delimiter', {' ','='});
    cs1 = cs1{1};
    cs{i} = cs1{1};
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test
function vcComment = getCommentExpr_(vcExpr)
% Return the comment part of the Matlab code

iStart = strfind(vcExpr, '%');
if isempty(iStart), vcComment = ''; return; end
vcComment = vcExpr(iStart(1):end);
end %func


%---------------------------------------------------------------------------
% 8/2/17 JJJ: Test and documentation
function vcStr = field2str_(val)
% convert a value to a strong

switch class(val)
    case {'int', 'int16', 'int32', 'uint16', 'uint32'}
        vcFormat = '%d';
    case {'double', 'single'}
        vcFormat = '%g';
        if numel(val)==1
            if mod(val(1),1)==0, vcFormat = '%d'; end
        end
    case 'char'
        vcStr = sprintf('''%s''', val); 
        return;
    case 'cell'
        vcStr = '{';
        for i=1:numel(val)
            vcStr = [vcStr, field2str_(val{i})];
            if i<numel(val), vcStr = [vcStr, ', ']; end
        end
        vcStr = [vcStr, '}'];
        return;
    otherwise
        vcStr = '';
        fprintf(2, 'field2str_: unsupported format: %s\n', class(val));
        return;
end

if numel(val) == 1
    vcStr = sprintf(vcFormat, val);
else % Handle a matrix or array
    vcStr = '[';
    for iRow=1:size(val,1)
        for iCol=1:size(val,2)
            vcStr = [vcStr, field2str_(val(iRow, iCol))];
            if iCol < size(val,2), vcStr = [vcStr, ', ']; end
        end
        if iRow<size(val,1), vcStr = [vcStr, '; ']; end
    end
    vcStr = [vcStr, ']'];
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Test and documentation
function cellstr2file_(vcFile, csLines, fVerbose)
% Write a cellstring to a text file
if nargin<3, fVerbose = 0; end
fid = fopen(vcFile, 'w');
for i=1:numel(csLines)
    fprintf(fid, '%s\n', csLines{i});
end
fclose(fid);
if fVerbose
    fprintf('Wrote to %s\n', vcFile);
end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Test and documentation
function S0 = set0_(varargin)
% Set(0, 'UserData')

S0 = get(0, 'UserData'); 
% set(0, 'UserData', []); %prevent memory copy operation
for i=1:nargin
    try
        S0.(inputname(i)) = varargin{i};
    catch
        disperr_();
    end
end
set(0, 'UserData', S0);
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Test and documentation
function import_tsf_(vcFile_tsf)
% import tsf format (test spike file)
% create a .bin file (fTranspose = 0)
fprintf('Converting to WHISPER format (.bin and .meta)\n\t'); t1=tic;
[mnWav, Sfile] = importTSF_(vcFile_tsf);
% nChans = size(mnWav,2);
vcFile_bin = strrep(vcFile_tsf, '.tsf', '.bin');
write_bin_(vcFile_bin, mnWav);
fprintf('\n\ttook %0.1fs.\n', toc(t1));

% write .meta file
vcFile_meta = subsFileExt_(vcFile_tsf, '.meta');
fid = fopen(vcFile_meta, 'W');
fprintf(fid, 'niMNGain=200\n');
fprintf(fid, 'niSampRate=%d\n', Sfile.sRateHz); %intan hardware default. in Smeta.header
fprintf(fid, 'niAiRangeMax=0.6554\n'); %intan hardware default. in Smeta.header
fprintf(fid, 'niAiRangeMin=-0.6554\n'); %intan hardware default. in Smeta.header
fprintf(fid, 'nSavedChans=%d\n', Sfile.nChans); %intan hardware default. in Smeta.header
fprintf(fid, 'fileTimeSecs=%f\n', Sfile.n_vd_samples/Sfile.sRateHz); %intan hardware default. in Smeta.header
fprintf(fid, 'fileSizeBytes=%d\n', round(Sfile.n_vd_samples*2*Sfile.nChans)); %intan hardware default. in Smeta.header
fclose(fid);

% write meta file and bin file
assignWorkspace_(Sfile);
assignWorkspace_(mnWav);
fprintf('Exported to %s, %s\n', vcFile_bin, vcFile_meta);
end %func


%--------------------------------------------------------------------------
% 8/4/17 JJJ: Accepts a text file containing a list of bin files
% 7/31/17 JJJ: handles wild card combined with cells
function [csFiles_valid, viValid] = filter_files_(csFiles, fSortMode)
% Files must exist and non-zero byte
if isTextFile_(csFiles)
    csFiles = load_batch_(csFiles);
else
    if nargin<2
        P = get0_('P');
        fSortMode = get_set_(P, 'sort_file_merge', 1);
    end
    csFiles = list_files_(csFiles, fSortMode);
end

% filter based on file presence and bytes
vlValid = false(size(csFiles));
for iFile=1:numel(csFiles)    
    S_dir1 = dir(csFiles{iFile});
    if isempty(S_dir1), continue; end
    if S_dir1.bytes == 0, continue; end
    vlValid(iFile) = 1;
end
viValid = find(vlValid);
csFiles_valid = csFiles(viValid);
if ~all(vlValid)
    fprintf('Files not found:\n');
    cellfun(@(vc)fprintf('\t%s\n', vc), csFiles(~vlValid));
end
end %func


%--------------------------------------------------------------------------
% 8/4/17 JJJ: Function created, tested and documented
function flag = isTextFile_(vcFile_txt, csExt_txt)
% Return true if a file is a text file
% Accept list of text files (csExt_txt}, provided by extensions

if nargin<2, csExt_txt = {'.txt', '.batch'}; end

if ischar(vcFile_txt)
    flag = matchFileExt_(vcFile_txt, csExt_txt);
%     flag = ~isempty(regexp(lower(vcFile_txt), '.txt$'));
else
    flag = 0;
end
end %func


%--------------------------------------------------------------------------
% 8/4/17 JJJ: Function created, tested and documented
function csLines = load_batch_(vcFile_batch)
% Load list of files in the text file, strip comments and empty lines
% Remove empty lines, comment lines starting with '%' character
if matchFileExt_(vcFile_batch, '.prm')
    csLines = {vcFile_batch}; return;
end
csLines = {};
if ~exist_file_(vcFile_batch, 1), return; end
csLines = file2cellstr_(vcFile_batch);
% csFiles_prm = importdata(vcFile_batch);

csLines = csLines(cellfun(@(x)~isempty(x), csLines)); % remove empty lines
csLines = cellfun(@(x)strtrim(x), csLines, 'UniformOutput', 0); % remove empty space
csLines = csLines(cellfun(@(x)~isempty(x), csLines)); %remove empty lines
csLines = csLines(cellfun(@(x)x(1)~='%', csLines)); % remove comment lines
end %func


%--------------------------------------------------------------------------
function [vr1, vi] = subsample_(vr, nSubsample)
vi = subsample_vr_(1:numel(vr), nSubsample);
vr1 = vr(vi);
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Initial implementation, documented and tested
function [mnWav_raw, S_preview] = load_preview_(P)
% Load the subsampled dataset
% Useful for inspecting threshold and so on. filter and 
% S_preview: which file and where it came from
if ischar(P), P = loadParam_(P); end

nLoads_max_preview = get_set_(P, 'nLoads_max_preview', 30);
sec_per_load_preview = get_set_(P, 'sec_per_load_preview', 1);

% determine files to load
if isempty(P.csFile_merge)
    csFile_bin = {P.vcFile};
else
    csFile_bin = filter_files_(P.csFile_merge);
end
csFile_bin = subsample_(csFile_bin, nLoads_max_preview);

% load files
nLoads_per_file = floor(nLoads_max_preview / numel(csFile_bin));
nSamples_per_load = round(sec_per_load_preview * P.sRateHz);

% file loading loop
[mnWav_raw, cviLim_load, csFile_load] = deal({});
% [mnWav_raw, mnWav_filt] = deal({});
P.fGpu = 0;
for iFile = 1:numel(csFile_bin)
    try
        vcFile_bin_ = csFile_bin{iFile};        
        [fid_bin_, nBytes_bin_, P.header_offset] = fopen_(vcFile_bin_, 'r');
        set0_(P);
        if isempty(fid_bin_)
            fprintf(2, '.bin file does not exist: %s\n', vcFile_bin_); 
            continue; 
        end    
        fprintf('File %d/%d: %s\n\t', iFile, numel(csFile_bin), vcFile_bin_);
        nSamples_bin_ = floor(nBytes_bin_ / bytesPerSample_(P.vcDataType) / P.nChans);
        if nSamples_bin_ < nSamples_per_load % load the whole thing            
            nLoads_per_file_ = 1;
            nSamples_per_load_ = nSamples_bin_;
        else
            nLoads_per_file_ = min(nLoads_per_file, floor(nSamples_bin_ / nSamples_per_load));
            nSamples_per_load_ = nSamples_per_load;
        end
        [cvi_lim_bin, viRange_bin] = sample_skip_([1, nSamples_per_load_], nSamples_bin_, nLoads_per_file_);   
        for iLoad_ = 1:nLoads_per_file_        
            fprintf('.');
            ilim_bin_ = cvi_lim_bin{iLoad_};
            fseek_(fid_bin_, ilim_bin_(1), P);
            mnWav_raw{end+1} = load_file_(fid_bin_, diff(ilim_bin_) + 1, P);
            cviLim_load{end+1} = ilim_bin_;
            csFile_load{end+1} = vcFile_bin_;
        end   
        fprintf('\n');        
    catch
        fprintf(2, 'Loading error: %s\n', vcFile_bin_); 
    end
    fclose_(fid_bin_, 0);
end 
nLoads = numel(mnWav_raw);
mnWav_raw = cell2mat(mnWav_raw');
% if nargout>=2, mnWav_raw = cell2mat(mnWav_raw'); end
if nargout>=2
    S_preview = makeStruct_(nLoads_per_file, nLoads_max_preview, ...
        sec_per_load_preview, nSamples_per_load, nLoads, csFile_load, cviLim_load); 
end
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Tested and documented
function trWav1 = meanSubt_(trWav1, iDimm, hFunc)
% subtract mean for mr or tr
if nargin<2, iDimm = 1; end
if nargin<3, hFunc = @mean; end
if ~isa_(trWav1, 'single') && ~isa_(trWav1, 'double')
    trWav1 = single(trWav1);
end
trWav1_dim = size(trWav1);
if numel(trWav1_dim)>2, trWav1 = reshape(trWav1, trWav1_dim(1), []); end
trWav1 = bsxfun(@minus, trWav1, hFunc(trWav1, iDimm));
if numel(trWav1_dim)>2, trWav1 = reshape(trWav1, trWav1_dim); end
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Tested and documented
function flag = isa_(vr, vcClass)
% subtract mean for mr or tr
try
    if isa(vr, 'gpuArray')
        flag = strcmpi(vcClass, classUnderlying(vr));
    else
        flag = isa(vr, vcClass);
    end
catch
    disperr_();
    flag = 0;
end
end %func


%--------------------------------------------------------------------------
function xylabel_(hAx, vcXLabel, vcYLabel, vcTitle)
if isempty(hAx), hAx = gca; end
xlabel(hAx, vcXLabel, 'Interpreter', 'none');
ylabel(hAx, vcYLabel, 'Interpreter', 'none');
if nargin>=4, title_(hAx, vcTitle); end
end %func


%--------------------------------------------------------------------------
% 8/7/17 JJJ: Created, tested and documented
function vrDatenum = file_created_(csFiles, vcDateMode)
% Return the file creation time. Matlab "dir" command returns last modified time
% vcDateMode: {'lastModifiedTime', 'creationTime', 'lastAccessTime'};
if nargin<2, vcDateMode = 'creationTime'; end

if ischar(csFiles), csFiles = {csFiles}; end
vrDatenum = nan(size(csFiles));
for iFile=1:numel(csFiles)
    vcFile_ = csFiles{iFile};
    try
        vcDate = char(java.nio.file.Files.readAttributes(java.io.File(vcFile_).toPath(), vcDateMode, javaArray('java.nio.file.LinkOption', 0)));
        iStart = find(vcDate=='=', 1, 'first');
        iEnd = find(vcDate=='Z', 1, 'last');
        vcDate = vcDate(iStart+1:iEnd-1);
        vcDate(vcDate=='T') = ' '; % replace with blank
        vrDatenum(iFile) = datenum(vcDate, 'yyyy-mm-dd HH:MM:SS.FFF');
    catch
        fprintf(2, 'File not found: %d\n', vcFile_);
    end
end
% datestr(datenum1, 'yyyy-mm-dd HH:MM:SS.FFF')
end %func


%--------------------------------------------------------------------------
% 8/7/17 JJJ: Created, tested and documented
function vrDatenum = file_created_meta_(csFiles, vcDateMode)
% Read the SpikeGLX meta file for the file cration time if available
if nargin<2, vcDateMode = 'creationTime'; end
if ischar(csFiles), csFiles = {csFiles}; end
vrDatenum = nan(size(csFiles));
for iFile=1:numel(csFiles)
    vcFile_ = csFiles{iFile};
    try
        vcFile_meta_ = subsFileExt_(vcFile_, '.meta');
        if exist_file_(vcFile_meta_)            
            S_meta_ = meta2struct_(vcFile_meta_);
            vcDatenum_ = S_meta_.fileCreateTime;
            vcDatenum_(vcDatenum_=='T') = ' ';
            vrDatenum(iFile) = datenum(vcDatenum_, 'yyyy-mm-dd HH:MM:SS');
        end
    catch
        ;
    end
    if isnan(vrDatenum(iFile))
        vrDatenum(iFile) = file_created_(vcFile_, vcDateMode);
    end
end %for
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Initial implementation, documented and tested
function S0 = keyPressFcn_Fig_preview_(hFig, event, S0)
if nargin<3, S0 = get(0, 'UserData'); end
P = get_(S0, 'P');
S_fig = get(hFig, 'UserData');
factor = 1 + 3 * key_modifier_(event, 'shift');
nSites = numel(P.viSite2Chan);

switch lower(event.Key)
    case {'uparrow', 'downarrow'}
        S_fig.maxAmp = change_amp_(event, S_fig.maxAmp, ...
            S_fig.hPlot_traces, S_fig.hPlot_traces_bad, S_fig.hPlot_traces_thresh, ...
            S_fig.hPlot_traces_spk, S_fig.hPlot_traces_spk1);
        title_(S_fig.hAx_traces, sprintf('Scale: %0.1f uV', S_fig.maxAmp));
        set(hFig, 'UserData', S_fig);     
        
    case {'leftarrow', 'rightarrow', 'home', 'end'} %navigation
        switch lower(event.Key)
            case 'leftarrow'
                nlim_bin = S_fig.nlim_bin - (S_fig.nLoad_bin) * factor; %no overlap
                if nlim_bin(1)<1
                    msgbox_('Beginning of file', 1); 
                    nlim_bin = [1, S_fig.nLoad_bin]; 
                end
            case 'rightarrow'
                nlim_bin = S_fig.nlim_bin + (S_fig.nLoad_bin + 1) * factor; %no overlap
                if nlim_bin(2) > S_fig.nSamples_bin
                    msgbox_('End of file', 1); 
                    nlim_bin = [-S_fig.nLoad_bin+1, 0] + S_fig.nSamples_bin;
                end
            case 'home', nlim_bin = [1, S_fig.nLoad_bin]; %begging of file
            case 'end', nlim_bin = [-S_fig.nLoad_bin+1, 0] + S_fig.nSamples_bin; %end of file
        end %switch
        S_fig.nlim_bin = nlim_bin;
        set(hFig, 'UserData', S_fig);
        Fig_preview_plot_(P);
        
    case 'f' %apply filter
        set(hFig, 'UserData', setfield(S_fig, 'fFilter', ~S_fig.fFilter));
        Fig_preview_plot_(P, 1);
        
     case 't' %toggle spike threshold
        set(hFig, 'UserData', setfield(S_fig, 'fThresh_spk', ~S_fig.fThresh_spk));
        Fig_preview_plot_(P, 1);
                
    case 's' %show/hide spikes
        set(hFig, 'UserData', setfield(S_fig, 'fShow_spk', ~S_fig.fShow_spk));
        Fig_preview_plot_(P, 1);          
        
    case 'g' %grid toggle on/off
        S_fig.fGrid = ~S_fig.fGrid;
        grid_([S_fig.hAx_traces, S_fig.hAx_mean, S_fig.hAx_psd, S_fig.hAx_sites], S_fig.fGrid);
        set(hFig, 'UserData', S_fig);
        menu_label_('menu_preview_view_grid', ifeq_(S_fig.fGrid, 'Hide [G]rid', 'Show [G]rid'));
        
    case 'h', msgbox_(S_fig.csHelp, 1); %help
        
    case 'r' %reset view
        P = get0_('P');
        axis_(S_fig.hAx_traces, [S_fig.nlim_bin / P.sRateHz, S_fig.siteLim+[-1,1]]);
    
    case 'e' % export to workspace
        Fig_preview_export_(hFig);
        
end %switch        
end %func


%--------------------------------------------------------------------------
function Fig_preview_trange_(hFig, vc_trange, mh)
% Sets a display time range

if nargin<1, hFig = []; end
if nargin<2, vc_trange = 'custom'; end
if isempty(hFig), hFig = get_fig_cache_('Fig_preview'); end

if strcmpi(vc_trange, 'custom') % ask user input box    
    vcAns = inputdlg_('Display time range (s)', 'Time range in seconds', 1, {'.2'});
    if isempty(vcAns), return; end
    trange = str2double(vcAns{1});
else
    trange = str2double(vc_trange);
end
if isnan(trange), return; end
menu_checkbox_(mh, vc_trange);

S_fig = get(hFig, 'UserData');
P = get0_('P');
S_fig.nLoad_bin = round(trange * P.sRateHz);
nlim_bin = S_fig.nlim_bin(1) + [0, S_fig.nLoad_bin-1];
if nlim_bin(1)<1
    nlim_bin = [1, S_fig.nLoad_bin]; 
elseif nlim_bin(2) > S_fig.nSamples_bin
    nlim_bin = [-S_fig.nLoad_bin+1, 0] + S_fig.nSamples_bin;
end
S_fig.nlim_bin = nlim_bin;
set(hFig, 'UserData', S_fig);
Fig_preview_plot_(P);
end %func


%--------------------------------------------------------------------------
function Fig_preview_site_range_(hFig)
S_fig = get(hFig, 'UserData');

% Ask user and update
vcSiteFrom = num2str(S_fig.siteLim(1));
vcSiteTo = num2str(S_fig.siteLim(end));
P = get0_('P');
nSites = numel(P.viSite2Chan);
csAns = inputdlg_({'Show site from (>=1)', sprintf('Show site to (<=%d)', nSites)}, ...
    'Display site range', 1, {vcSiteFrom, vcSiteTo});
if isempty(csAns), return; end
% if isnan(site_start) || isnan(site_end), return; end;
site_start = max(str2num(csAns{1}), 1);
site_end = min(str2num(csAns{2}), nSites);
S_fig = set_(S_fig, 'siteLim', [site_start, site_end]);
set(S_fig.hAx_traces, 'YLim', S_fig.siteLim + [-1, 1]);
set(S_fig.hAx_sites, 'YLim', S_fig.siteLim + [-1, 1]);
set(hFig, 'UserData', S_fig);
end %func


%--------------------------------------------------------------------------
function menu_parent = uimenu_options_(menu_parent, csLabels, hFunc, hFig);
% create options branch in the uimenu
if nargin<4, hFig = []; end
for i=1:numel(csLabels)
    uimenu(menu_parent, 'Label', csLabels{i}, 'Callback', @(h,e)hFunc(hFig, csLabels{i}, menu_parent));
end
end %func


%--------------------------------------------------------------------------
function Fig_preview_site_thresh_(hFig)
% Site preview threshold
S_fig = get(hFig, 'UserData');
P = get0_('P');

% ask user
if isempty(S_fig.thresh_corr_bad_site)
    vc_thresh_site = '0';
else
    vc_thresh_site = num2str(S_fig.thresh_corr_bad_site);    
end
csAns = inputdlg_('Set a correlation threshold [0-1) for detecting bad sites (0 to disable)', 'thresh_corr_bad_site (set to 0 to disable)', 1, {vc_thresh_site});
if isempty(csAns), return; end
thresh_corr_bad_site = str2num(csAns{1});
if thresh_corr_bad_site>=1 || thresh_corr_bad_site<0 || isnan(thresh_corr_bad_site)
    msgbox_('Invalid range');
    return; 
end

S_fig.thresh_corr_bad_site = thresh_corr_bad_site;
set(hFig, 'UserData', S_fig);
Fig_preview_update_(hFig, S_fig, 1);

end %func


%--------------------------------------------------------------------------
function mouse_figure_(hFig, vhAx)
for iAx = 1:numel(vhAx)
    mouse_figure(hFig, vhAx(iAx));
end
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Initial implementation, documented and tested
function S_fig = preview_(P, fDebug_ui_)
% Data summary figure, interactive

global fDebug_ui
if nargin<2, fDebug_ui_ = 0; end
fDebug_ui = fDebug_ui_;
set0_(fDebug_ui);
if ischar(P), P = loadParam_(P); end
[mnWav_raw, S_preview] = load_preview_(P);
set0_(P);
nSites = size(mnWav_raw,2);

% process signal, how about common mean? 

% Bad channel metrics, do it once
mrCorr_site = corr(single(mnWav_raw));
mrCorr_site(logical(eye(size(mrCorr_site)))) = 0;
vrCorr_max_site = max(mrCorr_site);

% Create a Figure
gap = .05;
hFig = create_figure_('Fig_preview', [0 0 .5 1], P.vcFile_prm, 1, 1); %plot a summary pannel
hAx_mean = axes('Parent', hFig, 'Position',      [gap        gap         3/4-gap         1/4-gap], 'NextPlot', 'add'); 
hAx_traces = axes('Parent', hFig, 'Position',    [gap        1/4+gap     3/4-gap         3/4-gap*2], 'NextPlot', 'add'); 
hAx_sites = axes('Parent', hFig, 'Position',     [3/4+gap,   0+gap       1/4-gap*1.5     2/3-gap*2], 'NextPlot', 'add'); 
hAx_psd = axes('Parent', hFig, 'Position',       [3/4+gap,   2/3+gap     1/4-gap*1.5     1/3-gap*2], 'NextPlot', 'add'); 
linkaxes([hAx_mean, hAx_traces], 'x');

% Callback functions
Fig_preview_menu_(hFig);
set(hFig, 'KeyPressFcn', @keyPressFcn_Fig_preview_, 'BusyAction', 'cancel');
mouse_figure(hFig, hAx_traces);

csHelp = { ...    
    'Left/Right: change time (Shift: x4)', ...
    '[Home/End]: go to beginning/end of file', ...
    '---------', ...
    'Up/Down: change scale (Shift: x4)', ...
    'Right/Left: change time (Shift: x4)', ...
    'Zoom: Mouse wheel', ...
    '[x/y/ESC]: zoom direction', ...
    'Pan: hold down the wheel and drag', ...
    '---------', ...
    '[F]ilter toggle', ...
    'Gri[D] toggle'};

% Build S_fig
nLoad_bin = round(0.1 * P.sRateHz);
S_fig = struct('fGrid', 1, 'fFilter', 1, 'fThresh_spk', 0, 'fShow_spk', 1, ...
    'vcSite_view', 'Site correlation', 'vcRef_view', 'binned', 'vcPsd_view', 'original', ...
    'nlim_bin', [1, nLoad_bin], 'siteLim', [1, nSites], ...
    'maxAmp', P.maxAmp, 'nLoads', S_preview.nLoads, 'nSamples_bin', size(mnWav_raw,1));
S_fig = struct_merge_(S_fig, ...
    struct_copy_(P, 'vcCommonRef', 'thresh_corr_bad_site', 'fft_thresh', ...
        'qqFactor', 'blank_thresh', 'blank_period_ms', 'viSiteZero', ...
        'vcFilter', 'nDiff_filt', 'freqLim', 'vnFilter_user'));
S_fig = struct_merge_(S_fig, ...
    makeStruct_(mnWav_raw, vrCorr_max_site, S_preview, csHelp, ...
        hAx_mean, hAx_traces, hAx_sites, hAx_psd, nLoad_bin));

% Exit
set(hFig, 'UserData', S_fig);
drawnow;
S_fig = Fig_preview_update_(hFig, S_fig, 0);
end %func


%--------------------------------------------------------------------------
% 8/11/17 JJJ: Initial implementation
function S_fig = Fig_preview_update_(hFig, S_fig, fKeepView)
% Handle parameter update requests
% S_fig = Fig_preview_update_(hFig, S_fig, P)
% S_fig = Fig_preview_update_(hFig, S_fig, fUpdate)

if nargin<1, hFig = get_fig_cache_('Fig_preview'); end
if nargin<2, S_fig = get(hFig, 'UserData'); end
if nargin<3, fKeepView = 0; end

P = get0_('P');
nSites = numel(P.viSite2Chan);
figure_wait_(1, hFig);
fft_thresh = S_fig.fft_thresh;
if fft_thresh > 0
    S_fig.mnWav_clean = fft_clean_(S_fig.mnWav_raw, struct_add_(P, fft_thresh)); % fft filter
else
    S_fig.mnWav_clean = S_fig.mnWav_raw;
end

% Find bad sites
if S_fig.thresh_corr_bad_site > 0
    S_fig.vlSite_bad = S_fig.vrCorr_max_site < S_fig.thresh_corr_bad_site;
    S_fig.viSite_bad = find(S_fig.vlSite_bad);
elseif ~isempty(S_fig.viSiteZero)
    S_fig.viSite_bad = S_fig.viSiteZero;    
    S_fig.vlSite_bad = false(size(S_fig.vrCorr_max_site));
    S_fig.vlSite_bad(S_fig.viSiteZero) = 1;
    S_fig.viSiteZero = [];
else
    S_fig.vlSite_bad = false(size(S_fig.vrCorr_max_site));
    S_fig.viSite_bad = [];
end

% Perform filter fft_thresh
P_ = set_(P, 'vcCommonRef', 'none', 'fGpu', 0, 'vcFilter', S_fig.vcFilter, ...
    'nDiff_filt', S_fig.nDiff_filt, 'freqLim', S_fig.freqLim, 'vnFilter_user', S_fig.vnFilter_user, ...
    'blank_period_ms', S_fig.blank_period_ms, 'blank_thresh', S_fig.blank_thresh, 'fParfor', 0);
mnWav_filt = filt_car_(S_fig.mnWav_clean, P_);
vrWav_filt_mean = mr2ref_(mnWav_filt, S_fig.vcCommonRef, S_fig.viSite_bad);
if ~strcmpi(S_fig.vcCommonRef, 'none')
    mnWav_filt = bsxfun(@minus, mnWav_filt, int16(vrWav_filt_mean));
end
S_fig.vrWav_filt_mean = madscore_(mean(vrWav_filt_mean, 2)); % Save in MAD unit
S_fig.mnWav_filt = mnWav_filt;
% reference threshold. determine 
% vrWav_filt_mean = mean(mnWav_filt, 2) * P.uV_per_bit; % @TODO: save in MAD unit

% vrPower_psd = abs(mean(fft(S_fig.mnWav_raw(:,~S_fig.vlSite_bad)), 2));
[mrPower_psd, S_fig.vrFreq_psd] = psd_(S_fig.mnWav_raw(:,~S_fig.vlSite_bad), P.sRateHz, 4);
[mrPower_clean_psd] = psd_(S_fig.mnWav_clean(:,~S_fig.vlSite_bad), P.sRateHz, 4);
[S_fig.vrPower_psd, S_fig.vrPower_clean_psd] = multifun_(@(x)mean(x,2), mrPower_psd, mrPower_clean_psd);

% Apply threshold and perform spike detection
vrRmsQ_site = mr2rms_(mnWav_filt, 1e5);
vnThresh_site = int16(vrRmsQ_site * S_fig.qqFactor);
vnThresh_site(S_fig.vlSite_bad) = nan; % shows up as 0 for int16
S_fig.mlWav_thresh = bsxfun(@lt, mnWav_filt, -abs(vnThresh_site)); %negative threshold crossing
S_fig.mlWav_thresh(:, S_fig.vlSite_bad) = 0;
S_fig.vnThresh_site = vnThresh_site;

% Spike detection
% P_.fMerge_spk = 0;
[vlKeep_ref, S_fig.vrMad_ref] = car_reject_(vrWav_filt_mean, P_);
[S_fig.viTime_spk, S_fig.vnAmp_spk, viSite_spk] = detect_spikes_(mnWav_filt, vnThresh_site, vlKeep_ref, P_);
t_dur = size(mnWav_filt,1) / P.sRateHz;
S_fig.vrEventRate_site = hist(viSite_spk, 1:nSites) / t_dur; % event count
S_fig.vrEventSnr_site = abs(single(arrayfun(@(i)median(S_fig.vnAmp_spk(viSite_spk==i)), 1:nSites))) ./ vrRmsQ_site;
S_fig.vlKeep_ref = vlKeep_ref;
S_fig.viSite_spk = viSite_spk;
% Spike stats: such as # sites/event over threshold

% Exit
set(hFig, 'UserData', S_fig);
[hFig, S_fig] = Fig_preview_plot_(P, fKeepView);
end %func


%--------------------------------------------------------------------------
function [mrPower, vrFreq] = psd_(mr, Fs, nSkip)
% power spectrum
if nargin<3, nSkip = 1; end
if nSkip>1
    mr = mr(1:nSkip:end,:);
%     Fs = Fs / nSkip;
end
n = size(mr,1);
n1 = round(n/2);
mrPower = fft(meanSubt_(single(mr)));
mrPower = pow2db_(abs(mrPower(2:n1+1, :))) / n;

if nargout>=2, vrFreq = Fs*(1:n1)'/n; end
end %func


%--------------------------------------------------------------------------
% 8/6/17 JJJ: Initial implementation, documented and tested
% @TODO: run spike detection and show detected spikes, or below threshold values
function [hFig, S_fig] = Fig_preview_plot_(P, fKeepView)

if nargin<1, P = []; end
if nargin<2, fKeepView = 0; end
hWait = msgbox_('Plotting...', 0, 1);
if isempty(P), P = get0_('P'); end
[hFig, S_fig] = get_fig_cache_('Fig_preview');

figure_wait_(1, hFig);
nSites = size(S_fig.mnWav_filt,2);
viPlot = S_fig.nlim_bin(1):S_fig.nlim_bin(2);
vrTime_sec = viPlot / P.sRateHz;
tlim_sec = (S_fig.nlim_bin + [-1 1]) / P.sRateHz;


%-----
% Mean plot
if isempty(get_(S_fig, 'hPlot_mean'))
    S_fig.hPlot_mean = plot(S_fig.hAx_mean, nan, nan, 'k');
    S_fig.hPlot_mean_thresh = plot(S_fig.hAx_mean, nan, nan, 'r');
end
switch S_fig.vcRef_view
    case 'original'
        vrY_ = S_fig.vrWav_filt_mean(viPlot);        
    case 'binned'
        vrY_ = S_fig.vrMad_ref(viPlot);
    otherwise, disperr_();
end
set(S_fig.hPlot_mean, 'XData', vrTime_sec, 'YData', vrY_);
set(S_fig.hAx_mean, 'YLim', [-50, 50]);
xylabel_(S_fig.hAx_mean, 'Time (sec)', sprintf('Common ref. (MAD, %s)', S_fig.vcRef_view));
fThresh_ref = strcmpi(S_fig.vcRef_view, 'binned') && ~isempty(S_fig.blank_thresh) && S_fig.blank_thresh ~= 0;
if fThresh_ref
    set(S_fig.hPlot_mean_thresh, 'XData', vrTime_sec([1,end]), 'YData', repmat(S_fig.blank_thresh, [1,2]));
else
    hide_plot_(S_fig.hPlot_mean_thresh);
end

%-----
% Traces plot
if isempty(get_(S_fig, 'hPlot_traces'))
    S_fig.hPlot_traces = plot(S_fig.hAx_traces, nan, nan, 'Color', [1 1 1]*.5);
    S_fig.hPlot_traces_spk = plot(S_fig.hAx_traces, nan, nan, 'm.-', 'LineWidth', 1.5);
    S_fig.hPlot_traces_spk1 = plot(S_fig.hAx_traces, nan, nan, 'ro');
    S_fig.hPlot_traces_thresh = plot(S_fig.hAx_traces, nan, nan, 'm:');
    S_fig.hPlot_traces_bad = plot(S_fig.hAx_traces, nan, nan, 'r');
end
if S_fig.fFilter    
    vcFilter = S_fig.vcFilter;
    mrWav_ = bit2uV_(S_fig.mnWav_filt(viPlot,:), struct_add_(P, vcFilter));
else
    mrWav_ = meanSubt_(single(S_fig.mnWav_clean(viPlot,:)) * P.uV_per_bit);
end
multiplot(S_fig.hPlot_traces, S_fig.maxAmp, vrTime_sec, mrWav_, 1:nSites);
if ~isempty(S_fig.viSite_bad)
    multiplot(S_fig.hPlot_traces_bad, S_fig.maxAmp, vrTime_sec, mrWav_(:,S_fig.viSite_bad), S_fig.viSite_bad);
else
    hide_plot_(S_fig.hPlot_traces_bad);
end
if S_fig.fShow_spk
    vlSpk_ = S_fig.viTime_spk >= S_fig.nlim_bin(1) & S_fig.viTime_spk <= S_fig.nlim_bin(end);
    viTime_spk_ = single(S_fig.viTime_spk(vlSpk_)-S_fig.nlim_bin(1)+1);
    vrTime_spk_ = single(S_fig.viTime_spk(vlSpk_)) / P.sRateHz;
    viSite_spk_ = single(S_fig.viSite_spk(vlSpk_));
else
    viTime_spk_ = [];
end
if isempty(viTime_spk_)
    hide_plot_(S_fig.hPlot_traces_spk1);
    menu_label_('menu_preview_view_spike', 'Show [S]pikes');
else
    multiplot(S_fig.hPlot_traces_spk1, S_fig.maxAmp, vrTime_spk_, mr2vr_sub2ind_(mrWav_, viTime_spk_, viSite_spk_), viSite_spk_, 1);
    menu_label_('menu_preview_view_spike', 'Hide [S]pikes');
end
vrThresh_site_uV = bit2uV_(-S_fig.vnThresh_site(:), setfield(P, 'vcFilter', S_fig.vcFilter));
vrThresh_site_uV(S_fig.viSite_bad) = nan;
if S_fig.fThresh_spk && S_fig.fFilter
    multiplot(S_fig.hPlot_traces_thresh, S_fig.maxAmp, vrTime_sec([1,end,end])', repmat(vrThresh_site_uV, [1,3])');
    multiplot(S_fig.hPlot_traces_spk, S_fig.maxAmp, vrTime_sec, ...
        mr_set_(mrWav_, ~S_fig.mlWav_thresh(viPlot,:), nan)); %show spikes
    menu_label_('menu_preview_view_threshold', 'Hide spike [T]threshold');
else
    hide_plot_([S_fig.hPlot_traces_thresh, S_fig.hPlot_traces_spk]);
    menu_label_('menu_preview_view_threshold', 'Show spike [T]hreshold');
end
xylabel_(S_fig.hAx_traces, '', 'Site #');
vcFilter_ = ifeq_(S_fig.fFilter, sprintf('Filter=%s(%s)', S_fig.vcFilter, getFilterOption_(S_fig, 1)), 'Filter off');
set(hFig, 'Name', sprintf('%s; %s; CommonRef=%s', P.vcFile_prm, vcFilter_, S_fig.vcCommonRef));

title_(S_fig.hAx_traces, sprintf('Scale: %0.1f uV', S_fig.maxAmp));
menu_label_('menu_preview_view_filter', ifeq_(S_fig.fFilter, 'Show raw traces [F]', 'Show [F]iltered traces'));
menu_label_('menu_preview_view_grid', ifeq_(S_fig.fGrid, 'Hide [G]rid', 'Show [G]rid'));
if ~fKeepView
    set(S_fig.hAx_traces, 'YTick', 1:nSites, 'YLim', S_fig.siteLim + [-1,1], 'XLim', tlim_sec);
end


%-----
% Site plot
if isempty(get_(S_fig, 'hPlot_site'))
    S_fig.hPlot_site = barh(S_fig.hAx_sites, nan, nan, 1); 
    S_fig.hPlot_site_bad = barh(S_fig.hAx_sites, nan, nan, 1, 'r'); 
    S_fig.hPlot_site_thresh = plot(S_fig.hAx_sites, nan, nan, 'r'); 
end
switch S_fig.vcSite_view
    case 'Site correlation', vrPlot_site = S_fig.vrCorr_max_site;
    case 'Spike threshold', vrPlot_site = single(S_fig.vnThresh_site);
    case 'Event rate (Hz)', vrPlot_site = S_fig.vrEventRate_site;
    case 'Event SNR (median)', vrPlot_site = S_fig.vrEventSnr_site;
end
set(S_fig.hPlot_site, 'XData', 1:nSites, 'YData', vrPlot_site); %switch statement
xylabel_(S_fig.hAx_sites, S_fig.vcSite_view, 'Site #');
set(S_fig.hAx_sites, 'YLim', S_fig.siteLim + [-1,1]);
if isempty(S_fig.thresh_corr_bad_site) || ~strcmpi(S_fig.vcSite_view, 'Site correlation')
    hide_plot_(S_fig.hPlot_site_thresh);
else
    set(S_fig.hPlot_site_thresh, 'XData', S_fig.thresh_corr_bad_site *[1,1], 'YData', [0, nSites+1]);
end
if ~isempty(S_fig.viSite_bad);
    vrPlot_site_bad = vrPlot_site;
    vrPlot_site_bad(~S_fig.vlSite_bad) = 0;    
    set(S_fig.hPlot_site_bad, 'XData', 1:nSites, 'YData', vrPlot_site_bad); %switch statement
else
    hide_plot_(S_fig.hPlot_site_bad);
end
title_(S_fig.hAx_sites, sprintf('thresh_corr_bad_site=%0.4f', S_fig.thresh_corr_bad_site));


%-----
% PSD plot
if isempty(get_(S_fig, 'hPlot_psd'))
    S_fig.hPlot_psd = plot(S_fig.hAx_psd, nan, nan, 'k');
    S_fig.hPlot_clean_psd = plot(S_fig.hAx_psd, nan, nan, 'g');
    S_fig.hPlot_psd_thresh = plot(S_fig.hAx_psd, nan, nan, 'r');
end
set(S_fig.hPlot_psd, 'XData', S_fig.vrFreq_psd, 'YData', S_fig.vrPower_psd);
set(S_fig.hPlot_clean_psd, 'XData', S_fig.vrFreq_psd, 'YData', S_fig.vrPower_clean_psd);
xylabel_(S_fig.hAx_psd, 'Frequency (Hz)', 'Power [dB]', 'TODO: before and after cleaning');
set(S_fig.hAx_psd, 'XLim', [0, P.sRateHz/2]);
title_(S_fig.hAx_psd, sprintf('fft_thresh=%s', num2str(S_fig.fft_thresh)));

grid_([S_fig.hAx_traces, S_fig.hAx_mean, S_fig.hAx_sites, S_fig.hAx_psd], S_fig.fGrid);

% Exit
set(hFig, 'UserData', S_fig);
figure_wait_(0, hFig);
close_(hWait);
end %func


%--------------------------------------------------------------------------
function mr = mr_set_(mr, ml, val)
mr(ml)=val;
end %func


%--------------------------------------------------------------------------
function hide_plot_(vhPlot)
for i=1:numel(vhPlot), set(vhPlot(i), 'XData', nan, 'YData', nan); end
end %func


%--------------------------------------------------------------------------
function Fig_preview_ref_(hFig, vcMode, hMenu)
% Set reference types
S_fig = get(hFig, 'UserData');
S_fig.vcCommonRef = vcMode;
S_fig = Fig_preview_update_(hFig, S_fig, 1);
menu_checkbox_(hMenu, vcMode);
end %func


%--------------------------------------------------------------------------
function Fig_preview_filter_(hFig, vcMode, hMenu)
% Set reference types
S_fig = get(hFig, 'UserData');
menu_checkbox_(hMenu, vcMode);
switch lower(vcMode)
    case 'ndiff'
        vcName = 'nDiff_filt';
    case {'bandpass', 'fir1'}
        vcName = 'freqLim';
    case 'user'
        vcName = 'vnFilter_user';
end %switch
val = inputdlg_({vcName}, 'Filter option', 1, {num2str(S_fig.(vcName))});
if isempty(val), return; end 
val = val{1};
if isempty(val), return; end 
val = str2num(val);
if any(isnan(val)), return; end
S_fig = set_(S_fig, 'vcFilter', vcMode, 'fFilter', 1);
S_fig.(vcName) = val;
S_fig = Fig_preview_update_(hFig, S_fig, 1);
end %func


%--------------------------------------------------------------------------
function val = getFilterOption_(S, fString)
if nargin<2, fString = 0; end
switch lower(S.vcFilter)
    case 'ndiff'
        vcName = 'nDiff_filt';
    case {'bandpass', 'fir1'}
        vcName = 'freqLim';
    case 'user'
        vcName = 'vnFilter_user';
    otherwise
        error('invalid option');
end %switch
val = S.(vcName);
if fString, val = num2str(val); end
end %func


%--------------------------------------------------------------------------
function Fig_preview_fft_thresh_(hFig)
S_fig = get(hFig, 'UserData');
P = get0_('P');

% ask user
if isempty(S_fig.fft_thresh)
    vc_ = '0';
else
    vc_ = num2str(S_fig.fft_thresh);    
end
vcAns = inputdlg_('Set a threshold for FFT cleanup (0 to disable)', 'fft_thresh (20 recommended)', 1, {vc_});
if isempty(vcAns), return; end
fft_thresh = str2double(vcAns{1});
if isnan(fft_thresh), return; end

S_fig.fft_thresh = fft_thresh;
S_fig = Fig_preview_update_(hFig, S_fig, 1);
end %func


%--------------------------------------------------------------------------
function grid_(vhAx, fGrid)
if isempty(vhAx), vhAx = gca; end
for iAx = 1:numel(vhAx)
    if ischar(fGrid)
        grid(vhAx(iAx), fGrid);
    else
        grid(vhAx(iAx), ifeq_(fGrid, 'on', 'off'));
    end
end
end %func


%--------------------------------------------------------------------------
function Fig_preview_site_plot_(hFig, vcMode, hMenu)
S_fig = get(hFig, 'UserData');
S_fig.vcSite_view = vcMode;
menu_checkbox_(hMenu, vcMode);
set(hFig, 'UserData', S_fig);
Fig_preview_plot_([], 1);
end %func


%--------------------------------------------------------------------------
% 8/12/17 JJJ: Created
function Fig_preview_psd_plot_(hFig, vcMode, hMenu)
S_fig = get(hFig, 'UserData');
switch vcMode
%     case 'Power'
%     case 'Detrended'
    case 'Linear', set(S_fig.hAx_psd, 'XScale', 'linear');
    case 'Log', set(S_fig.hAx_psd, 'XScale', 'log');
    otherwise, disperr_(vcMode);
end %switch
menu_checkbox_(hMenu, vcMode);
end %func


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Created
function Fig_preview_export_(hFig)
% Export raw and filtered traces

S_fig = get(hFig, 'UserData');
[mnWav_filt, mnWav_raw, S_preview] = deal(S_fig.mnWav_filt, S_fig.mnWav_raw, S_fig.S_preview);
assignWorkspace_(mnWav_filt, mnWav_raw, S_preview);
msgbox_('Exported to workspace: Raw traces (mnWav_raw), filtered traces (mnWav_filt), Preview info (S_preview)');
end %func


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Created
function Fig_preview_save_prm_(hFig)
% Update to a parameter file, show a preview window
% List of parameters to update. Set threshold: save to a known location and load 
P = get0_('P');
S_fig = get(hFig, 'UserData');

P_update = struct_copy_(S_fig, ...
    'fft_thresh', 'qqFactor', 'vcFilter', 'vcCommonRef', 'blank_thresh', 'blank_period_ms', 'freqLim', 'nDiff_filt', 'vnFilter_user');
P_update.viSiteZero = find(S_fig.vlSite_bad);

% Preview variables in the edit box
vcUpdate = struct2str_(P_update);
csAns = inputdlg_(P.vcFile_prm, 'Update confirmation', 16, {vcUpdate}, struct('Resize', 'on'));
if isempty(csAns), return; end
[P_update, vcErr] = str2struct_(csAns{1});
if isempty(P_update)
    msgbox_(vcErr);
    return; 
end
P = get0_('P');
edit_prm_file_(P_update, P.vcFile_prm);
% P = struct_merge_(P, P_update);
% set0_(P);
edit_(P.vcFile_prm);
end %func


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Created
function vc = struct2str_(S)
if ~isstruct(S), vc = ''; return; end

csVars = fieldnames(S);
vc = '';
for iVar = 1:numel(csVars)
    vc = sprintf('%s%s = %s;', vc, csVars{iVar}, field2str_(S.(csVars{iVar})));
    if iVar<numel(csVars), vc = sprintf('%s\n', vc); end
end %for
end %func


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Created
function [S, vcErr] = str2struct_(vc)
% Numerical expressions only for now

vc = vc';
vc = vc(:)';
vcErr = '';
cc_ = textscan(strtrim(vc), '%s%s', 'Delimiter', '=;',  'ReturnOnError', false);
csName = cc_{1};
csValue = cc_{2};

S = struct();
for i=1:numel(csName)
    vcName_ = strtrim(csName{i});
    if vcName_(1) == '~', vcName_(1) = []; end
    try         
        eval(sprintf('%s = %s;', vcName_, csValue{i}));
        eval(sprintf('num = str2double(%s);', vcName_));
        if ~isnan(num)
            eval(sprintf('%s = num;', vcName_));
        end
        eval(sprintf('S = setfield(S, ''%s'', %s);', vcName_, vcName_));
    catch
        vcErr = lasterr();
        S = []; 
        return;
%         fprintf('%s = %s error\n', csName{i}, csValue{i});
    end
end

end %func


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Created
function hMenu = menu_label_(vcTag, vcLabel)
hMenu = [];
try
    if ischar(vcTag)
        hMenu = findobj('Tag', vcTag, 'Type', 'uimenu');
    else
        hMenu = vcTag;
    end
    set(hMenu, 'Label', vcLabel); %figure property
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
% 8/14/17 JJJ: Created
function hMenu = menu_checkbox_(vcTag, vcLabel, fUncheckRest)
% Check the label selected and uncheck the rest
if nargin<3, fUncheckRest = 1; end
hMenu = [];
try
    if ischar(vcTag)
        hMenu = findobj('Tag', vcTag, 'Type', 'uimenu');
    else
        hMenu = vcTag;
    end
    % Find children
    vhMenu_child = hMenu.Children;
    for iMenu = 1:numel(vhMenu_child)
        hMenu_child_ = vhMenu_child(iMenu);
        vcLabel_ = get(hMenu_child_, 'Label');
        if strcmpi(vcLabel_, vcLabel)
            set(hMenu_child_, 'Checked', 'on');
        elseif fUncheckRest
            set(hMenu_child_, 'Checked', 'off');
        end
    end %for
catch
    disperr_();
end
end %func


%--------------------------------------------------------------------------
function Fig_preview_spk_thresh_(hFig)
% update spike threshold qqFactor
S_fig = get(hFig, 'UserData');
P = get0_('P');

% ask user
vcAns = inputdlg_('Set a spike detection threshold (qqFactor)', 'Spike detection threshold', 1, {num2str(S_fig.qqFactor)});
if isempty(vcAns), return; end
qqFactor = str2num(vcAns{1});
if isnan(qqFactor) || isempty(qqFactor), return; end

S_fig = Fig_preview_update_(hFig, setfield(S_fig, 'qqFactor', qqFactor), 1);
end %func


%--------------------------------------------------------------------------
% 8/16/17 JJJ: Updated
function Fig_preview_menu_(hFig)
P = get0_('P');

set(hFig, 'MenuBar','None');
mh_file = uimenu(hFig, 'Label','File'); 
uimenu(mh_file, 'Label', sprintf('Save to %s', P.vcFile_prm), 'Callback', @(h,e)Fig_preview_save_prm_(hFig));
uimenu(mh_file, 'Label', '[E]xport to workspace', 'Callback', @(h,e)Fig_preview_export_(hFig));
uimenu(mh_file, 'Label', 'Save spike detection threshold', 'Callback', @(h,e)Fig_preview_save_threshold_(hFig));

% Edit menu
mh_edit = uimenu(hFig, 'Label','Edit'); 

uimenu(mh_edit, 'Label', 'Bad site threshold', 'Callback', @(h,e)Fig_preview_site_thresh_(hFig));
uimenu(mh_edit, 'Label', 'Spike detection threshold', 'Callback', @(h,e)Fig_preview_spk_thresh_(hFig));

mh_edit_filter = uimenu(mh_edit, 'Label', 'Filter mode');
uimenu_options_(mh_edit_filter, {'ndiff', 'bandpass', 'sgdiff', 'fir1', 'user'}, @Fig_preview_filter_, hFig);
menu_checkbox_(mh_edit_filter, get_filter_(P));

mh_edit_ref = uimenu(mh_edit, 'Label', 'Reference mode');
uimenu_options_(mh_edit_ref, {'none', 'mean', 'median'}, @Fig_preview_ref_, hFig); % @TODO: local mean
menu_checkbox_(mh_edit_ref, P.vcCommonRef);

uimenu(mh_edit, 'Label', 'Common reference threshold', 'Callback', @(h,e)Fig_preview_ref_thresh_(hFig));

uimenu(mh_edit, 'Label', 'FFT cleanup threshold', 'Callback', @(h,e)Fig_preview_fft_thresh_(hFig));


% View menu
mh_view = uimenu(hFig, 'Label','View'); 

mh_view_trange = uimenu(mh_view, 'Label', 'Display time range (s)');
uimenu_options_(mh_view_trange, {'0.05', '0.1', '0.2', '0.5', '1', '2', '5', 'Custom'}, @Fig_preview_trange_, hFig);
menu_checkbox_(mh_view_trange, '0.1');
uimenu(mh_view, 'Label', 'Display site range', 'Callback', @(h,e)Fig_preview_site_range_(hFig));

uimenu(mh_view, 'Label', 'Show raw traces [F]', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'f'), 'Tag', 'menu_preview_view_filter');
uimenu(mh_view, 'Label', 'Show spike [T]hreshold', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 't'), 'Tag', 'menu_preview_view_threshold');
uimenu(mh_view, 'Label', 'Hide [S]pikes', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 's'), 'Tag', 'menu_preview_view_spike');
uimenu(mh_view, 'Label', 'Hide [G]rid', 'Callback', @(h,e)keyPressFcn_cell_(hFig, 'g'), 'Tag', 'menu_preview_view_grid');

mh_view_site = uimenu(mh_view, 'Label', 'Site view');
uimenu_options_(mh_view_site, {'Site correlation', 'Spike threshold', 'Event rate (Hz)', 'Event SNR (median)'}, @Fig_preview_site_plot_, hFig);
menu_checkbox_(mh_view_site, 'Site correlation');

mh_view_ref = uimenu(mh_view, 'Label', 'Reference view');
uimenu_options_(mh_view_ref, {'original', 'binned'}, @Fig_preview_view_ref_, hFig);
menu_checkbox_(mh_view_ref, 'original');

mh_view_freq = uimenu(mh_view, 'Label', 'Frequency scale');
uimenu_options_(mh_view_freq, {'Linear', 'Log'}, @Fig_preview_psd_plot_, hFig);
menu_checkbox_(mh_view_freq, 'Linear');

% mh_view_psd = uimenu(mh_view, 'Label', 'PSD view');
% uimenu_options_(mh_view_psd, {'original', 'detrended'}, @Fig_preview_view_psd_, hFig);
% menu_checkbox_(mh_view_psd, 'original');

% 'Power', 'Detrended', 
end %func


%--------------------------------------------------------------------------
% 8/16/17 JJJ: created
function Fig_preview_save_threshold_(hFig)
% export S_fig.vnThresh and sets vcFile_thresh
P = get0_('P');
S_fig = get(hFig, 'UserData');
vnThresh_site = S_fig.vnThresh_site;
vcFile_thresh = strrep(P.vcFile_prm, '.prm', '_thresh.mat');
save(vcFile_thresh, 'vnThresh_site'); % also need to store filter values?
P.vcFile_thresh = vcFile_thresh;
set0_(P);
edit_prm_file_(P, P.vcFile_prm);

msgbox_(sprintf('Saved to %s and updated %s (vcFile_thresh)', ...
    vcFile_thresh, P.vcFile_prm));
end %func


%--------------------------------------------------------------------------
% 8/16/17 JJJ: created
function Fig_preview_view_psd_(hFig, vcMode, hMenu)
% export S_fig.vnThresh and sets vcFile_thresh
S_fig = get(hFig, 'UserData');
S_fig.vcPsd_view = vcMode;
menu_checkbox_(hMenu, vcMode);
set(hFig, 'UserData', S_fig);
Fig_preview_plot_([], 1);
end %func


%--------------------------------------------------------------------------
% 8/16/17 JJJ: created
function Fig_preview_view_ref_(hFig, vcMode, hMenu)
S_fig = get(hFig, 'UserData');
S_fig.vcRef_view = vcMode;
menu_checkbox_(hMenu, vcMode);
set(hFig, 'UserData', S_fig);
Fig_preview_plot_([], 1);
end %func


%--------------------------------------------------------------------------
% 8/17/17 JJJ: created
function Fig_preview_ref_thresh_(hFig)
S_fig = get(hFig, 'UserData');

% Ask user and update
vc_blank_thresh = num2str(S_fig.blank_thresh);
vc_blank_period_ms = num2str(S_fig.blank_period_ms);
% P = get0_('P');
% nSites = numel(P.viSite2Chan);
csAns = inputdlg_({'blank_thresh (MAD)', 'blank_period_ms (millisecond)'}, ...
    'Common reference threshold', 1, {vc_blank_thresh, vc_blank_period_ms});
if isempty(csAns), return; end
% if isnan(site_start) || isnan(site_end), return; end;
blank_thresh = str2num(csAns{1});
blank_period_ms = str2num(csAns{2});
if isempty(blank_thresh), blank_thresh = 0; end
if isnan(blank_thresh) || isnan(blank_period_ms), return; end

S_fig = set_(S_fig, 'blank_thresh', blank_thresh, 'blank_period_ms', blank_period_ms);
set(hFig, 'UserData', S_fig);
S_fig = Fig_preview_update_(hFig, S_fig, 1);
end %func


%--------------------------------------------------------------------------
% 8/17/17 JJJ: created
function vrRef = mr2ref_(mnWav_filt, vcCommonRef, viSite_bad)
if nargin<2, vcCommonRef = 'mean'; end
if nargin<3, viSite_bad = []; end
if ~isempty(viSite_bad)
    mnWav_filt(:,viSite_bad) = [];
end
if strcmpi(vcCommonRef, 'median')
    vrRef = median(mnWav_filt, 2);
else
    vrRef = mean(mnWav_filt, 2);
end
end %func



%--------------------------------------------------------------------------
% 9/29/17 JJJ: delta==0 (found other spike that has exactly same PCA score) is set to nan
% 9/5/17 JJJ: Created
function [icl, x, z] = detrend_local_(S_clu, P, fLocal)
if nargin<3, fLocal = 1; end
maxCluPerSite = get_set_(P, 'maxCluPerSite', 20); % get 10 clu per site max
S0 = get0();
% cvi_rho_rank_site = cellfun(@(vi)rankorder_(S_clu.rho(vi), 'ascend'), S0.cviSpk_site, 'UniformOutput', 0);
% cvi_delta_rank_site = cellfun(@(vi)rankorder_(S_clu.delta(vi), 'ascend'), S0.cviSpk_site, 'UniformOutput', 0);

% detrend for each site and apply
if fLocal
    cvi_rho_site = cellfun(@(vi)S_clu.rho(vi), S0.cviSpk_site, 'UniformOutput', 0);
    cvi_delta_site = cellfun(@(vi)S_clu.delta(vi), S0.cviSpk_site, 'UniformOutput', 0);
%     [x0, y0] = deal(S_clu.rho, S_clu.delta);
    cvi_cl = cell(size(S0.cviSpk_site));
    x = log10(S_clu.rho);
    z = zeros(size(S_clu.delta), 'like', S_clu.delta);
    for iSite = 1:numel(S0.cviSpk_site)
        [rho_, delta_] = deal(cvi_rho_site{iSite}, cvi_delta_site{iSite});
        x_ = log10(rho_);
%         y_ = log10(rho_) + log10(delta_);
        y_ = (delta_);
        viDetrend = find(delta_ < 1 & delta_ > 0 & rho_ > 10^P.rho_cut & rho_ < .1 & isfinite(x_) & isfinite(y_));            
        [y_det_, z_] = detrend_(x_, y_, viDetrend, 1);
        viSpk_ = S0.cviSpk_site{iSite};        
        if isempty(viSpk_), continue; end
        vl_zero_ = find(delta_==0);
        [y_det_(vl_zero_), z_(vl_zero_)] = nan;
        [icl_, vrZ_] = find_topn_(y_det_, maxCluPerSite, ...
            find(rho_ > 10^P.rho_cut & ~isnan(y_det_)));
        if isempty(icl_), continue; end
        cvi_cl{iSite} = viSpk_(icl_); 
        z(viSpk_) = z_;
%         figure; plot(x_, y_det_, 'k.', x_(icl_), y_det_(icl_), 'ro'); axis([-5 0 -1 1]); grid on;
    end
    icl = cell2vec_(cvi_cl);
else
    x = log10(S_clu.rho);
    y = S_clu.delta;
    viDetrend = find(S_clu.delta < 1 & S_clu.delta > 0 & S_clu.rho > 10^P.rho_cut & S_clu.rho < .1 & isfinite(x) & isfinite(y));    
    [~, z] = detrend_(x, y, viDetrend, 1);
    z(S_clu.delta==0) = nan;
    [icl, vrZ_] = find_topn_(z, maxCluPerSite * numel(S0.cviSpk_site), ...
        find(S_clu.rho > 10^P.rho_cut & ~isnan(z)));
    icl(vrZ_ < 10^P.delta1_cut) = [];    
%     icl = find(x>=P.rho_cut & z>=10^P.delta1_cut);
end


if nargout==0
    figure; plot(x,z,'.', x(icl),z(icl),'ro'); grid on; 
    axis_([-5 0 -20 100]);
    title(sprintf('%d clu', numel(icl)));
end
end %func


%--------------------------------------------------------------------------
function [y_, z] = detrend_(x, y, vi, fQuadratic)
% perform quadratic detrend and return z score
if nargin<4, fQuadratic = 1; end
if nargin<3, vi = 1:numel(x); end
x=x(:);
y=y(:);
% y = log10(y);
eps_ = eps(class(x));
if fQuadratic
    xx = [x.^2+eps_, x + eps_, ones(numel(x),1)];
else %linear detrending
    xx = [x + eps_, ones(numel(x),1)];
end
m = xx(vi,:) \ y(vi);
y_ = y - xx * m;
if nargout>=2
    z = (y_ - nanmean(y_(vi))) / nanstd(y_(vi));
end
end %func


%--------------------------------------------------------------------------
function  [viTop, vrTop] = find_topn_(vr, nMax, vi)
if nargin<3, vi = 1:numel(vr); end
nMax = min(nMax, numel(vi));
[~, viSrt] = sort(vr(vi), 'descend');
viTop = vi(viSrt(1:nMax));
vrTop= vr(viTop);
end %func


%--------------------------------------------------------------------------
function vr = cell2vec_(cvr)
% remove empty
cvr = cvr(:);
cvr = cvr(cellfun(@(x)~isempty(x), cvr));
vr = cell2mat(cellfun(@(x)x(:), cvr, 'UniformOutput', 0));
% for i=1:numel(cvr)
%     vr_ = cvr{i};
%     cvr{i} = vr_(:);
% end
% vr = cell2mat(cvr);
end %func


%--------------------------------------------------------------------------
% 09/14/17 JJJ: Export settings to a prm file 
function export_prm_(vcFile_prm, vcFile_out_prm, fShow)
% export current P structure to a parameter file
% export_prm_(vcFile_prm): read and write to the vcFile_prm (append default.prm)
% export_prm_(vcFile_prm, vcFile_out_prm): read from vcFile_prm and output to vcFile_out_prm
if nargin<3, fShow = 1; end

if isempty(vcFile_out_prm), vcFile_out_prm = vcFile_prm; end
copyfile(ircpath_(read_cfg_('default_prm')), vcFile_out_prm, 'f');
P = get0_('P');
if isempty(P), P = file2struct_(vcFile_prm); end
edit_prm_file_(P, vcFile_out_prm);
vcMsg = sprintf('Full parameter settings are exported to %s', vcFile_out_prm);
fprintf('%s\n', vcMsg);
if fShow
    msgbox_(vcMsg);
    edit_(vcFile_out_prm);
end
end %func


%--------------------------------------------------------------------------
% 9/17/17 JJJ: sample size is determined by the smallest file in the chan recording set
% 9/15/17 JJJ: Created
function vcFile_prm = import_intan_(vcFile_dat, vcFile_prb, vcArg3)

% vcFile_dat = 'E:\ZGao\Exp_20170710_1302_run000\amp-A-000.dat';
% vcFile_dat(end-7:end-5) = '000'; % replace to 000 index
csFiles_dat = sort(dir_file_(vcFile_dat, 1)); % sort by the channel name
[vcDir, vcFile] = fileparts(csFiles_dat{1});
vcFile_bin = [vcDir, '.bin'];
vcFile_prb = find_prb_(vcFile_prb);
[~, vcFile_prb_] = fileparts(vcFile_prb);
vcFile_prm = strrep(vcFile_bin, '.bin', sprintf('_%s.prm', vcFile_prb_));
nChans = numel(csFiles_dat);
nBytes_file = min(cellfun(@(vc)getBytes_(vc), csFiles_dat));
P = struct('vcDataType', 'int16', 'probe_file', vcFile_prb, 'nChans', nChans, ...
    'uV_per_bit', .195, 'sRateHz', 30000, 'nBytes_file', nBytes_file);

nSamples = P.nBytes_file / bytesPerSample_(P.vcDataType); 

% Read file and output
mnWav  = zeros([nSamples, nChans], P.vcDataType);
for iFile = 1:numel(csFiles_dat)
    try
        fid_ = fopen(csFiles_dat{iFile}, 'r');
        mnWav(iFile:nChans:end) = fread(fid_, inf, ['*', P.vcDataType]);
        fclose(fid_);
        fprintf('Loaded %s\n', csFiles_dat{iFile});
    catch
        fprintf(2, 'error %s\n', csFiles_dat{iFile});
    end
end
write_bin_(vcFile_bin, mnWav);
clear mnWav;

% Write to a .prm file
try
    S_prb = file2struct_(vcFile_prb);
    if isfield(S_prb, 'maxSite'), P.maxSite = S_prb.maxSite; end
    if isfield(S_prb, 'nSites_ref'), P.nSites_ref = S_prb.nSites_ref; end
catch
    disperr_(sprintf('Error loading the probe file: %s\n', vcFile_prb));
end
P.duration_file = nSamples / P.sRateHz; %assuming int16
P.version = version_();
P.vcFile_prm = vcFile_prm;
P.vcFile = vcFile_bin;
copyfile(ircpath_(read_cfg_('default_prm')), P.vcFile_prm, 'f');
edit_prm_file_(P, P.vcFile_prm);
vcPrompt = sprintf('Created a new parameter file\n\t%s', P.vcFile_prm);
disp(vcPrompt);
edit_(P.vcFile_prm);
end


%--------------------------------------------------------------------------
% 9/17/17 JJJ: Created for SPAARC
function vcFile_prm = import_nsx_(vcFile_nsx, vcFile_prb, vcTemplate_prm)
% Import neuroshare format
% sample size is determined by the smallest file in the chan recording set
% vcFile_nsx = 'E:\TimBruns\Ichabod Trial 14\exp_9_ichabod0014.ns5';

if nargin<3, vcTemplate_prm = ''; end
if matchFileExt_(vcFile_prb, '.prm')
    vcTemplate_prm = vcFile_prb;
    S_ = file2struct_(vcTemplate_prm);
    vcFile_prb = S_.probe_file;
end
vcFile_prm = '';
if ~exist_file_(vcFile_nsx, 1), return; end
P = load_nsx_header_(vcFile_nsx);
P.probe_file = vcFile_prb;
P.vcFile = vcFile_nsx;
[~, vcFile_prb_] = fileparts(vcFile_prb);
vcFile_prm = subsFileExt_(P.vcFile, sprintf('_%s.prm', vcFile_prb_));
if isempty(vcTemplate_prm)
    vcTemplate_prm = ircpath_(read_cfg_('default_prm'));
end
assert_(exist_file_(vcTemplate_prm), sprintf('Template file does not exist: %s', vcTemplate_prm));

% Write to a .prm file
try
    S_prb = file2struct_(find_prb_(vcFile_prb));
    if isfield(S_prb, 'maxSite'), P.maxSite = S_prb.maxSite; end
    if isfield(S_prb, 'nSites_ref'), P.nSites_ref = S_prb.nSites_ref; end
catch
    disperr_(sprintf('Error loading the probe file: %s\n', vcFile_prb));
end
P.duration_file = P.nSamples / P.sRateHz; %assuming int16
P.version = version_();
P.vcFile_prm = vcFile_prm;
% P.vcFile = vcFile_bin;
copyfile(vcTemplate_prm, P.vcFile_prm, 'f');
edit_prm_file_(P, P.vcFile_prm);
vcPrompt = sprintf('Created a new parameter file\n\t%s', P.vcFile_prm);
disp(vcPrompt);
edit_(P.vcFile_prm);
end


%--------------------------------------------------------------------------
% 4/10/18 JJJ: Using openNSx_jjj.m (Blackrock library)
function [mnWav, P, S_nsx] = load_nsx_(vcFile_nsx)

[S_nsx, fid] = openNSx_jjj(vcFile_nsx); % nChans, nSamples, header_offset

nSamples = S_nsx.nSamples;
nChans = S_nsx.nChans;
uV_per_bit = double(S_nsx.ElectrodesInfo(1).MaxAnalogValue) / ...
    double(S_nsx.ElectrodesInfo(1).MaxDigiValue);
P = struct('vcDataType', 'int16', 'nChans', nChans, ...
    'uV_per_bit', uV_per_bit, 'sRateHz', S_nsx.MetaTags.SamplingFreq);

fprintf('Loading %s...', vcFile_nsx); t_load = tic;
mnWav = fread(fid, [nChans, nSamples], '*int16');  
fclose(fid);
fprintf('took %0.1fs\n', toc(t_load));

if nargout==0, assignWorkspace_(mnWav, P, S_nsx); end
end % func


%--------------------------------------------------------------------------
% 9/19/17 JJJ: Created for SPARC
function [mnWav, hFile, P] = load_nsx__(vcFile_nsx)
addpath_('neuroshare/');
[ns_RESULT, hFile] = ns_OpenFile(vcFile_nsx);
% [ns_RESULT, nsFileInfo] = ns_GetFileInfo(hFile);
vlAnalog_chan= strcmpi({hFile.Entity.EntityType}, 'Analog');
nSamples = hFile.TimeSpan / hFile.FileInfo.Period;
nChans = sum(vlAnalog_chan);
% viElecID = double([hFile.Entity.ElectrodeID]);
P = struct('vcDataType', 'int16', 'nChans', nChans, ...
    'uV_per_bit', hFile.Entity(1).Scale, 'sRateHz', 30000 / hFile.FileInfo.Period);

fprintf('Loading %s...', vcFile_nsx); t_load = tic;
fid = hFile.FileInfo.FileID;
if ismember(hFile.FileInfo.FileTypeID, {'NEURALCD', 'NEUCDFLT'})
    fseek(fid, hFile.FileInfo.BytesHeaders + 9, -1);
else
    fseek(fid, hFile.FileInfo.BytesHeaders, -1);
end
mnWav = fread(fid, [nChans, nSamples], '*int16');  
fclose(fid);
fprintf('took %0.1fs\n', toc(t_load));

if nargout==0, assignWorkspace_(mnWav, hFile); end
end % func


%--------------------------------------------------------------------------
% 9/19/17 JJJ: Created for SPARC
function mrRate_clu = clu_rate_(S_clu, viClu, nSamples)
S0 = get(0, 'UserData');
P = S0.P;
if nargin<2, viClu = []; end 
if nargin<3, nSamples = []; end

if isempty(viClu), viClu = 1:S_clu.nClu; end
sRateHz_rate = get_set_(P, 'sRateHz_rate', 1000);
filter_sec_rate = get_set_(P, 'filter_sec_rate', 1);
nFilt = round(sRateHz_rate * filter_sec_rate / 2);   
filter_shape_rate = lower(get_set_(P, 'filter_shape_rate', 'triangle'));
switch filter_shape_rate
    case 'triangle'
        vrFilt = ([1:nFilt, nFilt-1:-1:1]'/nFilt*2/filter_sec_rate);
    case 'rectangle'
        vrFilt = (ones(nFilt*2, 1) / filter_sec_rate);
%     case 'interval3'
%         1/2 1/3 1/6. interval history
end %switch
vrFilt = single(vrFilt);

if isempty(nSamples), nSamples = round(P.duration_file * sRateHz_rate); end
mrRate_clu = zeros([nSamples, numel(viClu)], 'single');
for iClu1 = 1:numel(viClu)
    iClu = viClu(iClu1);
    viSpk_clu = S_clu.cviSpk_clu{iClu};
    viTime_clu = S0.viTime_spk(viSpk_clu);           
    viTime_ = round(double(viTime_clu) / P.sRateHz * sRateHz_rate);
    viTime_ = max(min(viTime_, nSamples), 1);
    mrRate_clu(viTime_, iClu1) = 1;        
    mrRate_clu(:,iClu1) = conv(mrRate_clu(:,iClu1), vrFilt, 'same');
end
end %func


%--------------------------------------------------------------------------
% 9/19/17 JJJ: Created for SPARC
function plot_aux_corr_(mrRate_clu, vrWav_aux, vrCorr_aux_clu, vrTime_aux, iCluPlot, vcLabel_aux)
if nargin<5, iCluPlot = []; end
if nargin<6, vcLabel_aux = ''; end

% show the firing rate and plot the 
[vrCorr_srt, viSrt] = sort(vrCorr_aux_clu, 'descend');
nClu = numel(vrCorr_aux_clu);
[P, S_clu] = get0_('P', 'S_clu');
P = loadParam_(P.vcFile_prm);
nClu_show = min(get_set_(P, 'nClu_show_trial', 10), nClu);
% vcLabel_aux = get_set_(P, 'vcLabel_aux', 'aux');
nSubsample_aux = get_set_(P, 'nSubsample_aux', 100);
if ~isempty(iCluPlot)
   nClu_show = 1;
   viSrt = iCluPlot;
end
    
hFig = create_figure_('FigAux', [.5 0 .5 1], P.vcFile_prm,1,1);
hTabGroup = uitabgroup(hFig);
for iClu1 = 1:nClu_show
    iClu = viSrt(iClu1);
    htab1 = uitab(hTabGroup, 'Title', sprintf('Clu %d', iClu), 'BackgroundColor', 'w');    
    ax_ = axes('Parent', htab1);
    subplot(2, 1, 1);    
    ax_ = plotyy(vrTime_aux, mrRate_clu(:,iClu), vrTime_aux, vrWav_aux);
    xlabel('Time (s)');
    ylabel(ax_(1),'Firing Rate (Hz)');
    ylabel(ax_(2), vcLabel_aux);    
    iSite_ = S_clu.viSite_clu(iClu);
    vcTitle_ = sprintf('Clu %d (Site %d, Chan %d): Corr=%0.3f', ...
        iClu, iSite_, P.viSite2Chan(iSite_), vrCorr_aux_clu(iClu));
    title(vcTitle_);
    set(ax_, 'XLim', vrTime_aux([1,end]));
    grid on;
    
    subplot(2, 1, 2);
    plot(vrWav_aux(1:nSubsample_aux:end), mrRate_clu(1:nSubsample_aux:end,iClu), 'k.');
    xlabel(vcLabel_aux); 
    ylabel('Firing Rate (Hz)');
    grid on;
end %for
end %func


%--------------------------------------------------------------------------
% 9/19/17 JJJ: Created for SPARC
function plot_aux_rate_(fSelectedUnit)
% Aux channel vs. rate
if nargin<1, fSelectedUnit = 0; end %plot all
[P, S_clu, iCluCopy] = get0_('P', 'S_clu', 'iCluCopy');
P = loadParam_(P.vcFile_prm);

% [vrWav_aux, vrTime_aux] = load_aux_(P);
[vrWav_aux, vrTime_aux, vcLabel_aux] = load_trial_(P);

if isempty(vrWav_aux), msgbox_('Aux input is not found'); return; end
mrRate_clu = clu_rate_(S_clu, [], numel(vrWav_aux));
vrCorr_aux_clu = arrayfun(@(i)corr(vrWav_aux, mrRate_clu(:,i), 'type', 'Pearson'), 1:size(mrRate_clu,2));
if ~fSelectedUnit, iCluCopy = []; end
plot_aux_corr_(mrRate_clu, vrWav_aux, vrCorr_aux_clu, vrTime_aux, iCluCopy, vcLabel_aux);
vcMsg = assignWorkspace_(mrRate_clu, vrWav_aux, vrCorr_aux_clu, vrTime_aux);    
% msgbox_(vcMsg);
end %func


%--------------------------------------------------------------------------
% 11/13/18 JJJ: load auxiliary channel or vcFile_trial 
function [vrWav_trial, vrTime_trial, vcLabel_aux] = load_trial_(P, S_trial)
[vrWav_trial, vrTime_trial, vcUnit] = deal([]);
if nargin<2, S_trial = []; end

if isempty(S_trial)
    S_trials = get_trials_();
    S_trial = S_trials.cTrials{S_trials.iTrial};
end % if 

switch S_trial.type
    case 'analog'
        [vcFile, iChan, sRateHz_trial, vcUnit, scale] = ...
            struct_get_(S_trial.value, 'vcFile', 'iChan', 'sRateHz', 'vcUnit', 'scale');        
        if ~exist_file_(vcFile), return; end
        if isempty(iChan), return; end        
        [~,~,vcExt] = fileparts(vcFile);
        switch lower(vcExt)
            case {'.ns2', '.ns5'}
                mnWav_trial = load_nsx_(vcFile);
                vrWav_trial = single(mnWav_trial(iChan,:)') * scale; 
            case {'.dat', '.bin'}
                mnWav_trial = load_bin_(vcFile, P.vcDataType); % it might be other bin channel
                vrWav_trial = single(mnWav_trial(iChan:P.nChans:end)') * P.uV_per_bit * scale;
            otherwise
                fprintf(2, 'vcFile_aux: unsupported file format: %s\n', vcExt);
                return;
        end %switch

    case 'event'
        mrTable1 = mr_trim_nan_(S_trial.value);        
        sRateHz_trial = get_set_(P, 'sRateHz_rate', 1000);
        t_dur = recording_duration_(P);
        nSamples = round(t_dur * sRateHz_trial);
        vrWav_trial = zeros(nSamples, 1, 'single');
        for iRow = 1:size(mrTable1,1)
            iStart1 = max(1, round(mrTable1(iRow,1) * sRateHz_trial));
            iEnd1 = min(round(mrTable1(iRow,2) * sRateHz_trial), nSamples);
            vrWav_trial(iStart1:iEnd1) = 1;
        end %for
        vcUnit = 'on/off';
        
    otherwise
        fprintf(2, 'load_trial_: unsupported trial type: %s\n', S_trial.type);
        return;
end %switch
if nargout>=2
    vrTime_trial = single(1:numel(vrWav_trial))' / sRateHz_trial; 
end
if nargout>=3
    vcLabel_aux = [S_trial.name, ' (', vcUnit, ')'];
end
end %func


%--------------------------------------------------------------------------
% 11/13/18 JJJ: load auxiliary channel or vcFile_trial 
function [vrWav_aux, vrTime_aux] = load_aux_(P)

[vrWav_aux, vrTime_aux] = deal([]);
if isempty(P.vcFile), msgbox_('Multi-file mode is currently not supported'); return; end
[~,~,vcExt] = fileparts(P.vcFile);
vcFile_aux = get_set_(P, 'vcFile_aux', '');

if isempty(vcFile_aux)
    switch lower(vcExt)
        case '.ns5', vcFile_aux = subsFileExt_(P.vcFile, '.ns2');
        case {'.bin', '.dat'}, vcFile_aux = P.vcFile;
        otherwise
            fprintf(2, 'Unable to determine the aux file. You must manually specify "vcFile_aux".\n');
            return;
    end
end
if ~exist_file_(vcFile_aux), return; end

[~,~,vcExt_aux] = fileparts(vcFile_aux);
switch lower(vcExt_aux)
    case '.ns2'
        iChan_aux = get_set_(P, 'iChan_aux', 1);
        [mnWav_aux, P_] = load_nsx_(vcFile_aux);
%         scale_aux = hFile_aux.Entity(iChan_aux).Scale * P.vrScale_aux;
        vrWav_aux = single(mnWav_aux(iChan_aux,:)') * P_.uV_per_bit;        
        sRateHz_aux = P_.sRateHz;
    case '.mat'
        S_aux = load(vcFile_aux);
        csField_aux = fieldnames(S_aux);
        vrWav_aux = S_aux.(csField_aux{1});
        sRateHz_aux = get_set_(P, 'sRateHz_aux', P.sRateHz_rate);
    case {'.dat', '.bin'}
        iChan_aux = get_set_(P, 'iChan_aux', []);
        if isempty(iChan_aux), return; end
        mnWav_aux = load_bin_(vcFile_aux, P.vcDataType);
        vrWav_aux = single(mnWav_aux(iChan_aux:P.nChans:end)') * P.uV_per_bit * P.vrScale_aux;  
        sRateHz_aux = get_set_(P, 'sRateHz_aux', P.sRateHz);
    otherwise
        fprintf(2, 'vcFile_aux: unsupported file format: %s\n', vcExt_aux);
        return;
end %switch
if nargout>=2, vrTime_aux = single(1:numel(vrWav_aux))' / sRateHz_aux; end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Merged to Master. This function is not used, instead IronClust deals with the offset
% 9/22/17 JJJ: Created for SPARC. 
function [P, nSamples, vcFile_bin] = nsx2bin_(vcFile_nsx, fInvert)
if nargin<2, fInvert = 0; end

nBuffer = 1e8; % in bytes
addpath_('neuroshare/');
vcFile_bin = subsFileExt_(vcFile_nsx, '.bin');
[ns_RESULT, hFile] = ns_OpenFile(vcFile_nsx);
% [ns_RESULT, nsFileInfo] = ns_GetFileInfo(hFile);
vlAnalog_chan= strcmpi({hFile.Entity.EntityType}, 'Analog');
nSamples = hFile.TimeSpan / hFile.FileInfo.Period;
nChans = sum(vlAnalog_chan);
% viElecID = double([hFile.Entity.ElectrodeID]);
P = struct('vcDataType', 'int16', 'nChans', nChans, ...
    'uV_per_bit', hFile.Entity(1).Scale, 'sRateHz', 30000 / hFile.FileInfo.Period);
fprintf('Loading %s...', vcFile_nsx); t_load = tic;

fid = hFile.FileInfo.FileID;
fidw = fopen(vcFile_bin, 'w');

if ismember(hFile.FileInfo.FileTypeID, {'NEURALCD', 'NEUCDFLT'})
    fseek(fid, hFile.FileInfo.BytesHeaders + 9, -1);
else
    fseek(fid, hFile.FileInfo.BytesHeaders, -1);
end
nLoad = ceil(nSamples*nChans / nBuffer);
for iLoad = 1:nLoad
    if iLoad==nLoad
        nBuffer_ = nSamples*nChans - (nLoad-1) * nBuffer;
    else
        nBuffer_ = nBuffer;
    end
    vnBuffer = fread(fid, nBuffer_, '*int16');
    if fInvert, vnBuffer = -vnBuffer; end
    fwrite(fidw, vnBuffer, 'int16');
end
fclose(fid);
fclose(fidw);
fprintf('took %0.1fs\n', toc(t_load));
end %func


%--------------------------------------------------------------------------
% 4/10/18 JJJ: Handle the new ns5 format
function [fid, nBytes, header_offset] = fopen_nsx_(vcFile_nsx)
% addpath_('./neuroshare/');
try
    [S_nsx, fid] = openNSx_jjj(vcFile_nsx); % nChans, nSamples, header_offset
catch
    disperr_();
end
% [ns_RESULT, nsFileInfo] = ns_GetFileInfo(hFile);
% vlAnalog_chan= strcmpi({hFile.Entity.EntityType}, 'Analog');
% nSamples = hFile.TimeSpan / hFile.FileInfo.Period;
% nChans = sum(vlAnalog_chan);
nBytes = S_nsx.nSamples * S_nsx.nChans * 2;
header_offset = ftell(fid);
% fid = hFile.FileInfo.FileID;

% if ismember(hFile.FileInfo.FileTypeID, {'NEURALCD', 'NEUCDFLT'})
%     header_offset = hFile.FileInfo.BytesHeaders + 9;
% else
%     header_offset = hFile.FileInfo.BytesHeaders;
% end
% fseek(fid, header_offset, -1);
end %func


%--------------------------------------------------------------------------
% 9/22/17 JJJ: Created for SPARC
function [fid, nBytes, header_offset] = fopen_nsx__(vcFile_nsx)
addpath_('neuroshare/');
try
    [ns_RESULT, hFile] = ns_OpenFile(vcFile_nsx);
catch
    disperr_();
end
% [ns_RESULT, nsFileInfo] = ns_GetFileInfo(hFile);
vlAnalog_chan= strcmpi({hFile.Entity.EntityType}, 'Analog');
nSamples = hFile.TimeSpan / hFile.FileInfo.Period;
nChans = sum(vlAnalog_chan);
nBytes = nSamples * nChans * 2;
fid = hFile.FileInfo.FileID;

if ismember(hFile.FileInfo.FileTypeID, {'NEURALCD', 'NEUCDFLT'})
    header_offset = hFile.FileInfo.BytesHeaders + 9;
else
    header_offset = hFile.FileInfo.BytesHeaders;
end
fseek(fid, header_offset, -1);
end %func


%--------------------------------------------------------------------------
% 9/22/17 JJJ: Created for SPARC
function [P, nSamples, hFile] = nsx_info_(vcFile_nsx)
addpath_('neuroshare/');
[ns_RESULT, hFile] = ns_OpenFile(vcFile_nsx);
vlAnalog_chan= strcmpi({hFile.Entity.EntityType}, 'Analog');
nSamples = hFile.TimeSpan / hFile.FileInfo.Period;
% viElecID = double([hFile.Entity.ElectrodeID]);
P = struct('vcDataType', 'int16', 'nChans', sum(vlAnalog_chan), ...
    'uV_per_bit', hFile.Entity(1).Scale, 'sRateHz', 30000 / hFile.FileInfo.Period);
end %func


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: loads .ns2
function S_header = load_nsx_header_(vcFile_nsx)
S_header = [];
if ~exist_file_(vcFile_nsx), return; end
[S_nsx, fid] = openNSx_jjj(vcFile_nsx);
fclose(fid);
if isempty(S_nsx), return; end

uV_per_bit = double(S_nsx.ElectrodesInfo(1).MaxAnalogValue) / ...
    double(S_nsx.ElectrodesInfo(1).MaxDigiValue);
S_header = struct('vcDataType', 'int16', 'nChans', S_nsx.nChans, ...
    'uV_per_bit', uV_per_bit, 'sRateHz', S_nsx.MetaTags.SamplingFreq, 'nSamples', S_nsx.nSamples);

end %func


%--------------------------------------------------------------------------
% 9/22/17 JJJ: Created for SPARC
function mrCor = chancor_(mn, P)
% mr = single(mn);
mrCor = zeros(size(mn), 'single');
nSites = numel(P.viSite2Chan);
nSites_spk = P.maxSite*2+1-P.nSites_ref;
miSites = P.miSites(2:nSites_spk,:);
for iSite = 1:nSites
    viSites_ = miSites(:,iSite);
    vrDist_ = pdist2(P.mrSiteXY(iSite,:), P.mrSiteXY(viSites_,:));
    vrDist_ = 1 ./ (vrDist_ / min(vrDist_));
    vrCor_ = bsxfun(@times, single(mn(:,iSite)), single(mn(:,viSites_))) * vrDist_(:);
    mrCor(:,iSite) = conv(vrCor_, [1,2,3,2,1]/3, 'same');
%     mrCor(:,iSrite) = vrCor_;
end
mrCor(mrCor<0)=0;
mrCor = int16(-sqrt(mrCor));
% figure; 
% subplot 121; imagesc(mrWav1(1:2000,:));
% subplot 122; imagesc(((mrCor1(1:2000,:))));
end %func


%--------------------------------------------------------------------------
% 11/6/18 JJJ: Displaying the version number of the program and what's used. #Tested
function [vcVer, vcDate, vcHash] = version_(vcFile_prm)
if nargin<1, vcFile_prm = ''; end
vcVer = 'v4.2.8';
vcDate = '11/13/2018';
vcHash = file2hash_();

if nargout==0
    fprintf('%s (%s) installed, MD5: %s\n', vcVer, vcDate, vcHash);
    return;
end
try 
    if isempty(vcFile_prm)
        P = get0_('P');
        if ~isempty(P)
            vcVer = P.version;
        end
    elseif exist_file_(vcFile_prm)
        P = loadParam_(vcFile_prm);
        vcVer = P.version;
    end
catch
    ;
end
end %func


%--------------------------------------------------------------------------
% 9/26/17 JJJ: Created and tested
function git_pull_(vcVersion, fOverwrite)
if nargin<1, vcVersion = ''; end
if nargin<2, fOverwrite = 1; end % remove changes done by user

repoURL = read_cfg_('repoURL');

try
    if isempty(vcVersion)
        if fOverwrite
            code = system('git fetch --all'); 
            code = system('git reset --hard origin/master'); 
        else
            code = system('git pull'); % do not overwrite existing changes
        end
    else
        code = system(sprintf('git reset --hard "%s"', vcVersion));
    end
catch
	code = -1;
end
if code ~= 0
    fprintf(2, 'Not a git repository. Please run the following command to clone from GitHub.\n');    
    fprintf(2, '\tsystem(''git clone %s.git myDest''\n', repoURL);
    fprintf(2, '\tReplace "myDest" with the desired installation location or omit to install in ./ironclust.\n', repoURL);
    fprintf(2, '\tYou may need to install git from https://git-scm.com/downloads.\n');  
else
    edit_('changelog.md');
end
end %func


%--------------------------------------------------------------------------
% 9/28/17 JJJ: Created and tested
function wiki_download_()

repoURL = read_cfg_('repoURL');

repoName = 'wiki';
if isempty(dir(repoName))
    vcEval = sprintf('git clone %s %s', repoURL, repoName);
else
    vcEval = sprintf('git pull %s', repoName);
end
try
	code = system(vcEval);
catch
	code = -1;
end
if code == 0
    fprintf('Wiki on GitHub is downloaded to ./%s/\n', repoName);
else
    fprintf(2, 'Please install git from https://git-scm.com/downloads.\n');        
end
end %func


%--------------------------------------------------------------------------
% 7/21/2018 JJJ: rejecting directories, strictly search for flies
% 9/26/17 JJJ: Created and tested
function flag = exist_file_(vcFile, fVerbose)
if nargin<2, fVerbose = 0; end
if isempty(vcFile)
    flag = false; 
elseif iscell(vcFile)
    flag = cellfun(@(x)exist_file_(x, fVerbose), vcFile);
    return;
else
    S_dir = dir(vcFile);
    if numel(S_dir) == 1
        flag = ~S_dir.isdir;
    else
        flag = false;
    end
end
if fVerbose && ~flag
    fprintf(2, 'File does not exist: %s\n', vcFile);
end
end %func


%--------------------------------------------------------------------------
% 8/7/2018 JJJ
function flag = exist_dir_(vcDir)
if isempty(vcDir)
    flag = 0;
else
    S_dir = dir(vcDir);
    if isempty(S_dir)
        flag = 0;
    else
        flag = sum([S_dir.isdir]) > 0;
    end
%     flag = exist(vcDir, 'dir') == 7;
end
end %func


%--------------------------------------------------------------------------
% 9/27/17 JJJ: Created
function gui_(vcArg1, vcFile_prm_)
% IronClust GUI interface

if ~isempty(vcArg1)
    vcFile_prm = vcArg1;
elseif ~isempty(vcFile_prm_)
    vcFile_prm = vcFile_prm_;
else
    vcFile_prm = '';
end
S_gui.vcFile_prm = vcFile_prm;
set0_(S_gui);
if isempty(vcFile_prm)
    irc_gui();
else
    irc_gui(vcFile_prm);
end
end %func


%--------------------------------------------------------------------------
% 9/27/17 JJJ: Created
function wiki_(vcPage)
if nargin<1, vcPage = ''; end

repoURL = read_cfg_('repoURL');

if isempty(vcPage)
    web_([repoURL, '/wiki/']); 
else
    web_([repoURL, '/wiki/', vcPage]); 
end
end


%--------------------------------------------------------------------------
% 9/27/17 JJJ: Created
function issue_(vcMode)
repoURL = read_cfg_('repoURL');
switch lower(vcMode)
    case 'post', web_([repoURL, '/issues/new'])
    case 'search', web_([repoURL, '/issues'])
end %switch
end %func


%--------------------------------------------------------------------------
% 10/8/17 JJJ: Created
% 3/20/18 JJJ: captures edit failure (when running "matlab -nodesktop")
function edit_(vcFile)
% vcFile0 = vcFile;
if ~exist_file_(vcFile)
    if matchFileExt_(vcFile, '.prb')
        vcFile = find_prb_(vcFile);
    else
        vcFile = ircpath_(vcFile, 1);
    end
end
fprintf('Editing %s\n', vcFile);
if ~isUsingBuiltinEditor_(), return ;end
try edit(vcFile); catch, end
end %func



%--------------------------------------------------------------------------
function S_clu = S_clu_reclust_(S_clu, S0, P)
global trFet_spk
vcMode_divide = 'amp';  % {'amp', 'density', 'fet'}

trFet_spk0 = trFet_spk;
nSites_fet = P.maxSite*2+1-P.nSites_ref;
nFetPerSite = size(trFet_spk,1) / nSites_fet;
switch vcMode_divide
%     case 'nneigh'
% %         % nearest neighbor averaging per same ecluster for feature enhancement
%         trFet_spk = nneigh_ave_(S_clu, P, trFet_spk);
%         P1 = setfield(P, 'nRepeat_fet', 1);
%         S_clu = postCluster_(cluster_spacetime_(S0, P1), P);
%         trFet_spk = trFet_spk0; % undo fet change (undo fet cleanup)

%     case 'fet'
% %         % recompute pca and 
%         vrSnr_clu = S_clu_snr_(S_clu);
%         vlRedo_clu = vrSnr_clu < quantile(vrSnr_clu, 1/nFetPerSite);
%         vlRedo_spk = ismember(S_clu.viClu, find(vlRedo_clu));    
%         tnWav_spk = get_spkwav_(P, 0);
%         trWav2_spk = single(permute(tnWav_spk(:,:,vlRedo_spk), [1,3,2]));        
%         trWav2_spk = spkwav_car_(trWav2_spk, P);       
%         [mrPv, vrD1] = tnWav2pv_(trWav2_spk, P);
%         dimm1 = size(trWav2_spk);
%         mrWav_spk1 = reshape(trWav2_spk, dimm1(1), []);
%         trFet_spk_ = reshape(mrPv(:,1)' * mrWav_spk1, dimm1(2:3))';        
        
    case 'amp'
        vrSnr_clu = S_clu_snr_(S_clu);
        try
%         for iRepeat = (nFetPerSite-1):-1:1
            vlRedo_clu = vrSnr_clu < quantile(vrSnr_clu, 1/2);
            vlRedo_spk = ismember(S_clu.viClu, find(vlRedo_clu));    

            % reproject the feature
    %         nSpk_ = sum(vlRedo_spk);
    %         nFets_spk_ = ceil(size(trFet_spk,1)/2);
    %         trFet_spk_ = pca(reshape(trFet_spk(:,:,vlRedo_spk), size(trFet_spk,1), []), 'NumComponents', nFets_spk_);
    %         trFet_spk_ = permute(reshape(trFet_spk_, [size(trFet_spk,2), nSpk_, nFets_spk_]), [3,1,2]);
    %         trFet_spk = trFet_spk(1:nFets_spk_,:,:);
    %         trFet_spk(:,:,vlRedo_spk) = trFet_spk_;
    
            mlFet_ = false(nSites_fet, nFetPerSite);
            nSites_fet = ceil(nSites_fet*.5) %*.75
            mlFet_(1:nSites_fet, 1) = 1;
%             mlFet_(1,:) = 1;
%             mlFet_(:, 1) = 1;
            trFet_spk = trFet_spk0(find(mlFet_),:,:); 
            
%             trFet_spk = trFet_spk0(1:1*nSites_fet,:,:); 
            S_clu_B = postCluster_(cluster_spacetime_(S0, P, vlRedo_spk), P);        
            S_clu = S_clu_combine_(S_clu, S_clu_B, vlRedo_clu, vlRedo_spk);
        catch
            disperr_();
        end        
        trFet_spk = trFet_spk0; %restore
        
    case 'density'
        vlRedo_clu = S_clu.vnSpk_clu > quantile(S_clu.vnSpk_clu, 1/2); %ilnear selection %2^(-iRepeat_clu+1)         
        vlRedo_spk = ismember(S_clu.viClu, find(vlRedo_clu));    
        S_clu_A = postCluster_(cluster_spacetime_(S0, P, ~vlRedo_spk), P);
        S_clu_B = postCluster_(cluster_spacetime_(S0, P, vlRedo_spk), P);        
         S_clu.viClu(~vlRedo_spk) = S_clu_A.viClu;
        S_clu.viClu(vlRedo_spk) = S_clu_B.viClu + max(S_clu_A.viClu);
        
    otherwise
        return;
end
end %func


%--------------------------------------------------------------------------
% 10/10/17 JJJ: load tnWav_raw from disk
function tnWav_raw = load_spkraw_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
tnWav_raw = load_bin_(strrep(S0.P.vcFile_prm, '.prm', '_spkraw.jrc'), 'int16', S0.dimm_raw);
end %func


%--------------------------------------------------------------------------
% 10/10/17 JJJ: load tnWav_spk from disk
function tnWav_spk = load_spkwav_(S0)
if nargin<1, S0 = get(0, 'UserData'); end
tnWav_spk = load_bin_(strrep(S0.P.vcFile_prm, '.prm', '_spkwav.jrc'), 'int16', S0.dimm_spk);
end %func


%--------------------------------------------------------------------------
% 10/10/17 JJJ: created and tested. 
function tnWav_spk1 = fread_spkwav_(viSpk1, fRamCache)
% Read spikes from file
persistent fid_ dimm_
if nargin<2, P = get0_('P'); fRamCache = get_set_(P, 'fRamCache', 1); end

% reset file
if nargin==0
    if ~isempty(fid_), fclose_(fid_, 1); end
    [fid_, tnWav_spk1] = deal([]);
    return;
end

if fRamCache
    global tnWav_spk
    if isempty(tnWav_spk), tnWav_spk = load_spkwav_(); end
    tnWav_spk1 = tnWav_spk(:,:,viSpk1);
    return;
end

% open file
if isempty(fid_)
    [P, dimm_] = get0_('P', 'dimm_spk');
    vcFile_ = strrep(P.vcFile_prm, '.prm', '_spkwav.jrc');
    assert_(exist_file_(vcFile_), sprintf('File must exist: %s\n', vcFile_));
    fid_ = fopen(vcFile_, 'r');
end

tnWav_spk1 = fread_spk_(fid_, dimm_, viSpk1);
end %func


%--------------------------------------------------------------------------
% 10/10/17 JJJ: created and tested
function tnWav_spk1 = fread_spkraw_(viSpk1, fRamCache)
% Read spikes from file
persistent fid_ dimm_
if nargin<2, P = get0_('P'); fRamCache = get_set_(P, 'fRamCache'); end

% reset file
if nargin==0
    if ~isempty(fid_), fclose_(fid_, 1); end
    [fid_, tnWav_spk1] = deal([]);
    return;
end

if fRamCache
    global tnWav_raw
    if isempty(tnWav_raw), tnWav_raw = load_spkraw_(); end
    tnWav_spk1 = tnWav_raw(:,:,viSpk1);
    return;
end

% open file
if isempty(fid_)
    [P, dimm_] = get0_('P', 'dimm_raw');
    vcFile_ = strrep(P.vcFile_prm, '.prm', '_spkraw.jrc');
    assert_(exist_file_(vcFile_), sprintf('File must exist: %s\n', vcFile_));
    fid_ = fopen(vcFile_, 'r');
end

tnWav_spk1 = fread_spk_(fid_, dimm_, viSpk1);
end %func


%--------------------------------------------------------------------------
% 10/10/17 JJJ: created and tested
function tnWav_spk1 = fread_spk_(fid_, dimm_, viSpk1);
% ~35x slower than RAM indexing

tnWav_spk1 = zeros([dimm_(1), dimm_(2), numel(viSpk1)], 'int16');
fseek(fid_, 0, 'bof');
vnOffset = (diff(viSpk1) - 1) * dimm_(1) * dimm_(2) * 2;
for iSpk = 1:numel(viSpk1)
    if iSpk>1, fseek(fid_, vnOffset(iSpk-1), 'cof'); end
    tnWav_spk1(:,:,iSpk) = fread(fid_, dimm_(1:2), '*int16');
end
end %func


%--------------------------------------------------------------------------
% 10/11/17 JJJ: created and tested
function write_spk_(varargin)
% [Usage]
% write_spk_(vcFile_prm) %open file
% write_spk_(tnWav_raw, tnWav_spk, trFet_spk)
% write_spk_() % close and clear

persistent fid_raw fid_spk fid_fet

switch nargin
    case 0
        fid_raw = fclose_(fid_raw); 
        fid_spk = fclose_(fid_spk); 
        fid_fet = fclose_(fid_fet); 
    case 1
        vcFile_prm = varargin{1};
        fid_raw = fopen(strrep(vcFile_prm, '.prm', '_spkraw.jrc'), 'W'); 
        fid_spk = fopen(strrep(vcFile_prm, '.prm', '_spkwav.jrc'), 'W'); 
        fid_fet = fopen(strrep(vcFile_prm, '.prm', '_spkfet.jrc'), 'W'); 
    case 3
        fwrite_(fid_raw, varargin{1});
        fwrite_(fid_spk, varargin{2});
        fwrite_(fid_fet, varargin{3});
    otherwise
        disperr_('write_spk_:invalid nargin');
end %switch
end %func


%--------------------------------------------------------------------------
% 10/11/17 JJJ: created 
function fSuccess = fwrite_(fid, vr)
try
    fwrite(fid, vr, class(vr));
    fSucces = 1;
catch
    fSucces = 0;
end
end %func


%--------------------------------------------------------------------------
% 10/11/17 JJJ: created 
function tnWav_ = get_spkwav_(P, fRaw)
% if ~fRamCache, only keep one of the tnWav_raw or tnWav_spk in memory
global tnWav_spk tnWav_raw
if nargin<1, P = []; end
if isempty(P), P = get0_('P'); end
if nargin<2, fRaw = P.fWav_raw_show; end

fRamCache = get_set_(P, 'fRamCache', 1);
if fRaw
    if ~fRamCache, tnWav_spk = []; end % clear spk
    if isempty(tnWav_raw), tnWav_raw = load_spkraw_(); end
    tnWav_ = tnWav_raw;
else
    if ~fRamCache, tnWav_raw = []; end % clear raw
    if isempty(tnWav_spk), tnWav_spk = load_spkwav_(); end
    tnWav_ = tnWav_spk;
end
end %func


%--------------------------------------------------------------------------
% 10/11/17 JJJ: created 
function trWav_fet = get_spkfet_(P)
persistent trWav_fet_ vcFile_prm_
if ~strcmpi(P.vcFile_prm, vcFile_prm_) || isempty(trWav_fet_)
    fLoad = 1;
elseif ~all(size(trWav_fet_) == get0_('dimm_fet'))
    fLoad = 1;
else
    fLoad = 0;
end
if fLoad
    vcFile_prm_ = P.vcFile_prm;
    trWav_fet_ = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', get0_('dimm_fet'));
end
trWav_fet = trWav_fet_;
end %func


%--------------------------------------------------------------------------
function trFet_spk_ = nneigh_ave_(S_clu, P, trFet_spk)
% cluster based averaging fet cleanup
error('not done');
nClu = S_clu.nClu;
S0 = get(0, 'UserData');
trFet_spk = gpuArray_(trFet_spk);
trFet_spk_ = zeros(size(trFet_spk), 'like', trFet_spk);
for iClu = 1:nClu
    viSpk1 = S_clu.cviSpk_clu{iClu};
    trFet1 = permute(trFet_spk(:,:,viSpk1), [1,3,2]);
    viSite1 = S0.viSite_spk(viSpk1);
    viSite2 = S0.viSite2_spk(viSpk1);
    viSite_unique1 = unique(viSite1);
    for iSite1 = 1:numel(viSite_unique1)
        iSite11 = viSite_unique1(iSite1);
        viSpk11 = find(viSite1 == iSite11);
        viSpk12 = find(viSite2 == iSite11);
        mrFet11 = trFet1(:,viSpk11,1);
        mrFet12 = [mrFet11, trFet1(:,viSpk12,2)];
        [vr11, vi_nneigh12] = min(set_diag_(eucl2_dist_(mrFet12, mrFet11), nan));
%         trFet_spk_(:,:,
    end
end
end %func


%--------------------------------------------------------------------------
% 10/12/17 JJJ: site by site denoising
function trFet_spk_ = denoise_fet_(trFet_spk, P, vlRedo_spk)
% denoise_fet_() to reset
% cluster based averaging fet cleanup
% set repeat parameter?
nRepeat_fet = get_set_(P, 'nRepeat_fet', 0);
if nRepeat_fet==0, trFet_spk_ = trFet_spk; return ;end

S0 = get(0, 'UserData');
fprintf('Denoising features using nneigh\n\t'); t1=tic;
nSites = numel(P.viSite2Chan);
nC = size(trFet_spk,1);
try        
    nC_max = get_set_(P, 'nC_max', 45);
    CK = parallel.gpu.CUDAKernel('irc_cuda_nneigh.ptx','irc_cuda_nneigh.cu');
    CK.ThreadBlockSize = [P.nThreads, 1];          
    CK.SharedMemorySize = 4 * P.CHUNK * (1 + nC_max + 2 * P.nThreads); % @TODO: update the size    
catch        
    disperr_('denoise_fet_: Cuda init error');
end
try
    for iSite = 1:nSites
        viSpk1 = S0.cviSpk_site{iSite};
        if isempty(viSpk1), continue; end
        if ~isempty(vlRedo_spk)
            viSpk1 = viSpk1(vlRedo_spk(viSpk1)); 
            if isempty(viSpk1), continue; end
        end        
        trFet12 = permute(trFet_spk(:,:,viSpk1), [1,3,2]);
        mrFet1 = gpuArray_(trFet12(:,:,1));
        mrFet2 = gpuArray_(trFet12(:,:,2));
        viiSpk1_ord = gpuArray_(rankorder_(viSpk1, 'ascend'));
        n1 = numel(viSpk1);
        dn_max = int32(round(n1 / P.nTime_clu));
        vrDelta1 = zeros([1, n1], 'single', 'gpuArray'); 
        viNneigh1 = zeros([1, n1], 'uint32', 'gpuArray');
        vnConst = int32([n1, nC, dn_max]);
        CK.GridSize = [ceil(n1 / P.CHUNK / P.CHUNK), P.CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
        
        for iRepeat = 1:nRepeat_fet
            [vrDelta1, viNneigh1] = feval(CK, vrDelta1, viNneigh1, mrFet1, viiSpk1_ord, vnConst);
            mrFet1 = (mrFet1 + mrFet1(:,viNneigh1)) / 2;
            mrFet2 = (mrFet2 + mrFet2(:,viNneigh1)) / 2;
%             mrD11 = set_diag_(eucl2_dist_(mrFet1, mrFet1), nan);
%               [vrDelta2, viNneigh2] = min(mrD11);
        end
        
        trFet_spk_(:,1,viSpk1) = gather_(mrFet1);
        trFet_spk_(:,2,viSpk1) = gather_(mrFet2);
        [mrFet1, mrFet2, vrDelta1, viNneigh1] = deal([]);
        fprintf('.');    
    end
catch
    disperr_('denoise_fet_: CUDA init error');
end
% [vrRho, vrDc2_site] = gather_(vrRho, vrDc2_site);
fprintf('\n\ttook %0.1fs\n', toc(t1));
end


%--------------------------------------------------------------------------
% 10/11/17 JJJ: mean_align_spkwav
function mrWav_mean = mean_align_spkwav_(tnWav_spk, P)
tnWav_spk = meanSubt_(tnWav_spk);

for iRepeat = 1:2
    mrWav_spk = single(reshape(tnWav_spk(:,1,:), [], size(tnWav_spk,3))); % use max chan only for selection
    % vrWav_mean = zscore(median(mrWav_spk,2), 1);
    vrCorr = zscore(mean(mrWav_spk,2))' * zscore(mrWav_spk); % / numel(vrWav_mean);
%     viSpk_mean = find(vrCorr > quantile(vrCorr, 1/4));
    tnWav_spk = tnWav_spk(:,:, vrCorr > quantile(vrCorr, 1/4));
end

mrWav_mean = mean(tnWav_spk, 3);
end %func


%--------------------------------------------------------------------------
% 10/11/17 JJJ: Created
function [vrCorr_spk, vrCorr_spk2] = spkwav_maxcor_(tnWav_spk, tnWav_spk2)
% subselect spikes that matches the mean well
% dimm1 = size(tnWav_spk);
% tnWav_spk0 = tnWav_spk;
if nargin<2, tnWav_spk2 = []; end
tnWav_spk = meanSubt_(single(gpuArray_(tnWav_spk)));
mrWav_spk = zscore(reshape(tnWav_spk, [], size(tnWav_spk,3)), 1); % use max chan only for selection
if isempty(tnWav_spk2)
    mrCorr_spk = set_diag_(mrWav_spk' * mrWav_spk, nan);
else
    tnWav_spk2 = meanSubt_(single(gpuArray_(tnWav_spk2)));
    mrWav_spk2 = zscore(reshape(tnWav_spk2, [], size(tnWav_spk2,3)), 1); % use max chan only for selection
    mrCorr_spk = mrWav_spk2' * mrWav_spk;
end
vrCorr_spk = gather_(max(mrCorr_spk) / size(mrWav_spk,1));
if nargout>1
    vrCorr_spk2 = gather_(max(mrCorr_spk,[],2) / size(mrWav_spk2,1));    
end

% vrWav_mean = zscore(median(mrWav_spk,2), 1);
%     vrCorr = zscore(mean(mrWav_spk,2))' * zscore(mrWav_spk); % / numel(vrWav_mean);
% %     viSpk_mean = find(vrCorr > quantile(vrCorr, 1/4));
%     tnWav_spk = tnWav_spk(:,:, vrCorr > quantile(vrCorr, 1/4));
% end
% 
% mrWav_mean = mean(tnWav_spk, 3);

% [a,b,c] = pca(single(reshape(tnWav_spk(:,1,:), dimm1(1), [])), 'NumComponents', 1);
% rankorder_(a);
% 
% tnWav_spk0 = tnWav_spk;
% 
% mrWav_spk = single(permute(tnWav_spk(:,1,:), [1,3,2]));
% vrWav0 = median(mrWav_spk, 2);
% nShift = numel(cviShift1);
% nSpk = size(tnWav_spk,3);
% mrCorr = zeros(nSpk, nShift);
% % viShift = (1:nShift) - round(nShift/2);
% for iShift = 1:nShift
%     vrWav_ = zscore(vrWav0(cviShift1{iShift}), 1);
%     mrWav_ = mrWav_spk(cviShift2{iShift}, :);
%     mrCorr(:,iShift) = vrWav_' * mrWav_;
% end
% [~, viShift] = max(mrCorr, [], 2);
% viShift = round(nShift/2) - viShift;
% for iSpk = 1:nSpk
%     iShift_ = viShift(iSpk);
%     if iShift_ == 0, continue; end
%     tnWav_spk(:,:,iSpk) = shift_mr_(tnWav_spk(:,:,iSpk), iShift_);
% end
% mrWav_mean = single(mean(tnWav_spk, 3));
end %func


%--------------------------------------------------------------------------
% 10/13/17 JJJ: Created
function [tnWav_spk, viSpk] = spkwav_filter_(tnWav_spk, qThresh)
% vrCorr_spk = spkwav_maxcor_(tnWav_spk);
vrCorr_spk = spkwav_maxcor_(tnWav_spk(:,1,:));
viSpk = find(vrCorr_spk > quantile(vrCorr_spk, qThresh));
tnWav_spk = tnWav_spk(:,:,viSpk);
end %func


%--------------------------------------------------------------------------
% 10/13/17 JJJ: Created. Realign the spikes at the min
function [viSpk_shift, viShift] = spkwav_shift_(trWav, shift_max, P)
% trWav: nT x nSpk x nChans
imid = 1 - P.spkLim(1);
if P.fDetectBipolar
    [~, viMin] = max(abs(trWav(:,:,1)));
else
    [~, viMin] = min(trWav(:,:,1));
end
viSpk_shift = find(viMin ~= imid);
viShift = imid - viMin(viSpk_shift);
vlKeep = abs(viShift) <= shift_max;
viSpk_shift = viSpk_shift(vlKeep);
viShift = viShift(vlKeep);
% for iShift = -shift_max:shift_max
%     if iShift==0, continue; end
%     viSpk1 = viSpk_shift(viShift == iShift);
%     if iShift<0
%         trWav(1:end+iShift,viSpk1,:) = trWav(1-iShift:end,viSpk1,:);
%     else
%         trWav(iShift+1:end,viSpk1,:) = trWav(1:end-iShift,viSpk1,:);
%     end
% end
end %func


%--------------------------------------------------------------------------
% 10/13/17 JJJ: Created. Realign the spikes at the min
function [tnWav_spk1, viTime_spk1] = spkwav_realign_(tnWav_spk1, mnWav_spk, spkLim_wav, viTime_spk1, viSite1, P)
% subtract car and temporal shift
% tnWav_spk1: nSamples x nSpk x nSites_spk
if ~strcmpi(get_set_(P, 'vcSpkRef', 'nmean'), 'nmean'), return; end

% fprintf('\n\tRealigning spikes after LCAR (vcSpkRef=nmean)...'); t1=tic;
dimm1 = size(tnWav_spk1);
trWav_spk2 = spkwav_car_(single(tnWav_spk1), P); % apply car
[viSpk_shift, viShift] = spkwav_shift_(trWav_spk2, 1, P);
if isempty(viSpk_shift), return; end

viTime_shift = viTime_spk1(viSpk_shift) - int32(viShift(:)); % spike time to shift
viTime_spk1(viSpk_shift) = viTime_shift;
tnWav_spk1(:,viSpk_shift,:) = mr2tr3_(mnWav_spk, spkLim_wav, viTime_shift, viSite1);
% fprintf('\n\t\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 9/3/2018 JJJ: nDiff filter generalized to any order (previously up to 4)
%   and uses less memory
function mn1 = ndiff_(mn, nDiff_filt)

if nDiff_filt==0, return; end
mn1 = zeros(size(mn), 'like', mn);
mn1(1:end-1,:) = diff(mn);
for i = 2:nDiff_filt
    mn1(i:end-i,:) = 2*mn1(i:end-i,:) + (mn(i*2:end,:)-mn(1:end-i*2+1,:));
end
end %func


%--------------------------------------------------------------------------
% 10/16/17 JJJ: Created
function [tr, vi] = interpft_(tr, nInterp)
if nInterp==1, return; end
vi = 1:(1/nInterp):size(tr,1);
tr = interpft(tr, size(tr,1)*nInterp);
if ndims(tr)==3
    tr = tr(1:numel(vi),:,:);
else
    tr = tr(1:numel(vi),:);
end
end %func


%--------------------------------------------------------------------------
% 10/18/17 JJJ: Created
function flag = assert_(flag, vcMsg)
if ~flag
    errordlg(vcMsg);
    disperr_(vcMsg, ''); 
end
end


%--------------------------------------------------------------------------
% 08/20/18 JJJ: Import Boyden Format (Brian Allen Groundtruth)
% Don't write to file
function [mrWav, S_meta, S_gt] = load_h5_(vcFile_h5, fRead_bin)
if nargin<2, fRead_bin = 1; end
max_bursting_index = 2;

[vcDir_, vcFile_, vcExt] = fileparts(vcFile_h5);
vcFile_raw = fullfile(vcDir_, 'Recordings', [vcFile_, '_raw.h5']);
vcFile_filtered = fullfile(vcDir_, 'Recordings', [vcFile_, '_filtered.h5']);
vcFile_spikes = fullfile(vcDir_, 'Analyses', [vcFile_, '_spikes.h5']);
uV_per_bit = .195;

% create .bin file
if ~exist_file_(vcFile_raw) || ~fRead_bin
    mrWav=[]; 
else
    mrWav = h5read(vcFile_raw, '/rawMEA');
end

% meta file
[probelayout, sRateHz, padpitch, sRateHz_gt] = h5readatt_(vcFile_h5, 'probelayout', 'MEAsamplerate', 'padpitch', 'abfsamplerate');
nChans = prod(probelayout);
probe_file = sprintf('boyden%d.prb', prod(probelayout));
try viSiteZero = h5readatt(vcFile_h5, '/','badchannels'); catch, viSiteZero = []; end
viSiteZero = viSiteZero(:)';
S_meta = makeStruct_(uV_per_bit, probe_file, viSiteZero, nChans, probelayout, sRateHz, padpitch);

% Write _gt.mat file
try
    viTime_gt = ceil(h5read(vcFile_spikes, '/derivspiketimes') * sRateHz_gt); 
    viBurst_gt = h5read(vcFile_spikes, '/burstindex');
    if ~isempty(max_bursting_index)
        S_gt.viTime = viTime_gt(viBurst_gt <= max_bursting_index); % non-bursting only        
    else
        S_gt.viTime = viTime_gt;
    end
    S_gt.viClu = ones(size(S_gt.viTime));
    
    iChan_gt = h5readatt_(vcFile_spikes, 'max_channel'); % index one
    S_gt.viSite = repmat(iChan_gt, size(S_gt.viTime));
catch
    S_gt = [];
end
end %func


%--------------------------------------------------------------------------
function varargout = h5readatt_(varargin)
% Usage
% -----
% [var1, var2, var3, ...] = h5readatt_(vcFile_h5, var_name1, var_name2, var_name3, ...)

vcFile_h5 = varargin{1};
nArgs = nargin() - 1;
for iArg = 1:nArgs
    try
        varargout{iArg} = h5readatt(vcFile_h5, '/', varargin{iArg+1});
    catch
        varargout{i} = [];
    end
end
end %func


%--------------------------------------------------------------------------
% 10/26/17 JJJ: Created
function [vcFile_bin, vcFile_meta, vcFile_gt] = import_h5_(vcFile_h5)
% Brian Allen h5 data

if nargin<1, vcFile_h5 = ''; end
if isempty(vcFile_h5), vcFile_h5 = 'E:\BrianAllen\915_18\915_18_1\915_18_1.h5'; end
[vcDir_, vcFile_, vcExt_] = fileparts(vcFile_h5);
if isempty(vcExt_)    
    vcFile_h5 = fullfile(vcFile_h5, [vcFile_, '.h5']);
end

vcFile_bin = strrep(vcFile_h5, '.h5', '.bin');
vcFile_meta = strrep(vcFile_h5, '.h5', '.meta');
P = struct('vcFile', vcFile_bin, 'qqFactor', 5, ...
    'maxDist_site_um', 50, 'maxDist_site_spk_um', 70, 'uV_per_bit', .195, ...
    'max_bursting_index', 3, 'nTime_clu', 4, 'fft_thresh', 0); % set to [] to disable
S_gt = struct();
S_gt.probe_layout = h5readatt(vcFile_h5, '/','probelayout');
try P.viChanZero = h5readatt(vcFile_h5, '/','badchannels'); catch, end
S_gt.sRateHz_gt = h5readatt(vcFile_h5, '/', 'abfsamplerate');
S_gt.patchtype = h5readatt(vcFile_h5, '/', 'patchtype');
try  S_gt.padmaptextname = h5readatt(vcFile_h5, '/', 'padmaptextname'); catch, end
try S_gt.padpitch = h5readatt(vcFile_h5, '/', 'padpitch'); catch, end

P.sRateHz = h5readatt(vcFile_h5, '/', 'MEAsamplerate');
P.nChans = S_gt.probe_layout(1) * S_gt.probe_layout(2);
% P = h5readatt_(vcFile_h5, {'patchtype', 'padmaptextname', 'patchtype', 'badchannels'});

[vcDir, vcFile, vcExt] = fileparts(vcFile_h5);
vcFile_raw = fullfile(vcDir, 'Recordings', [vcFile, '_raw.h5']);
vcFile_filtered = fullfile(vcDir, 'Recordings', [vcFile, '_filtered.h5']);
vcFile_spikes = fullfile(vcDir, 'Analyses', [vcFile, '_spikes.h5']);

% photodiode = h5read(vcFile_raw, '/photodiode');
% syncMEA = h5read(vcFile_raw, '/syncMEA');
% filteredMEA = h5read(vcFile_filtered, '/filteredMEA');
if ~exist_file_(P.vcFile)
    if exist_file_(vcFile_raw)
        mrWav = h5read(vcFile_raw, '/rawMEA');
    elseif exist_file_(vcFile_filtered)
        mrWav = h5read(vcFile_filtered, '/filteredMEA');            
    else
        error('no traces found');
    end
    % P.uV_per_bit = min_step_(rawMEA(:,1));
    write_bin_(P.vcFile, int16(meanSubt_(mrWav) / P.uV_per_bit)');
end

% Exclude bad channels


% Create GT
if exist_file_(vcFile_spikes)
    S_gt.viTime_all = ceil(h5read(vcFile_spikes, '/derivspiketimes') * S_gt.sRateHz_gt); 
    S_gt.vrBI_all = h5read(vcFile_spikes, '/burstindex');
    if ~isempty(get_(P, 'max_bursting_index'))
        viTime_gt = S_gt.viTime_all(S_gt.vrBI_all < P.max_bursting_index); % non-bursting only        
    else
        viTime_gt = S_gt.viTime_all;
    end
%     rawPipette = h5read(vcFile_filtered, '/rawPipette');
elseif exist_file_(vcFile_raw)
    rawPipette = h5read(vcFile_raw, '/rawPipette');
    rawPipette1 = ndiff_(rawPipette, 2);
    [viTime_gt, vrAmp_gt, thresh_gt] = spikeDetectSingle_fast_(-rawPipette1, struct('qqFactor', 10));    
%     figure; hold on; plot(rawPipette1); plot(S_gt.viTime_all, rawPipette1(S_gt.viTime_all), 'ro');
else
    error('no spike time info');
end

S_gt.viTime = viTime_gt;
S_gt.viClu = ones(size(viTime_gt));
vcFile_gt = strrep(P.vcFile, '.bin', '_gt.mat');
struct_save_(S_gt, vcFile_gt);

% Create prm file
P.probe_file = sprintf('boyden%d.prb', P.nChans);
P.vcFile_prm = [strrep(P.vcFile, '.bin', '_'), strrep(P.probe_file, '.prb', '.prm')];
copyfile(ircpath_(read_cfg_('default_prm')), P.vcFile_prm, 'f');
edit_prm_file_(P, P.vcFile_prm);
assignWorkspace_(P, S_gt);
fprintf('Created .prm file: %s\n', P.vcFile_prm);
edit_(P.vcFile_prm);
irc('setprm', P.vcFile_prm); % set the currently working prm file
end %func


%--------------------------------------------------------------------------
function min_ = min_step_(vr)
min_ = diff(sort(vr));
min_ = min(min_(min_>0));
end %func


%--------------------------------------------------------------------------
% Convert existing format to mda format and put in the directory
function convert_mda_(vcFile_in)
% Usage
% -----
% export_mda_(myfile.prm)
% export_mda_(myfile.batch)
% mda file exported to where .prm files exist

fOverwrite_raw_mda = 1;
% if nargin<2, vcDir_out = ''; end

vcFile_template = '';
if matchFileEnd_(vcFile_in, '.batch')
    csFile_prm = load_batch_(vcFile_in);
%     vcFile_template = vcArg2;
elseif matchFileEnd_(vcFile_in, '.prm')
    csFile_prm = {vcFile_in};
else
    fprintf(2, 'Incorrect format\n');
    return;
end

for iFile = 1:numel(csFile_prm)
    vcFile_prm_ = csFile_prm{iFile};
    if ~matchFileExt_(vcFile_prm_, '.prm')
        fprintf(2, '\tInvalid format: %s\n', vcFile_prm_); 
        continue;
    end
    P_ = loadParam_(vcFile_prm_, 0);
    
    % create a folder by the prm name
    vcDir1 = strrep(vcFile_prm_, '.prm', ''); % full path location
    mkdir_(vcDir1);
    
    % Exclude sites if viSiteZero not empty
    
    % export .bin to .mda
    vcFile_raw_mda = fullfile(vcDir1, 'raw.mda');
    if fOverwrite_raw_mda
        fWrite_mda_ = 1;
    else
        fWrite_mda_ = ~exist_file_(vcFile_raw_mda);
    end
    if fWrite_mda_
        mnWav = load_bin_(P_.vcFile, P_.vcDataType, file_dimm_(P_), P_.header_offset);
        if P_.fTranspose_bin
            mnWav = mnWav(P_.viSite2Chan,:);
        else
            mnWav = mnWav(:, P_.viSite2Chan)';
        end
        writemda_(mnWav, vcFile_raw_mda, fOverwrite_raw_mda);
    end
    
    % export .prm to geom.csv
    prb2geom_(P_.mrSiteXY, fullfile(vcDir1, 'geom.csv'), 0);
    
    % export ground truth
    S_gt_ = load_(get_(P_, 'vcFile_gt'));
    if ~isempty(S_gt_)
        if ~isfield(S_gt_, 'viSite')
            iSite_gt = [];
            if isfield(P_, 'iSite_gt'), iSite_gt = get_(P_, 'iSite_gt'); end
            if isfield(P_, 'iChan_gt'), iSite_gt = chan2site_prb_(P_.iChan_gt, P_.probe_file); end   
            if ~isempty(iSite_gt)
                S_gt_.viSite = repmat(int32(iSite_gt), size(S_gt_.viTime));
            end
        end
        gt2mda_(S_gt_, fullfile(vcDir1, 'firings_true.mda'));        
    end
    
    % Write to params.json
    S_json_ = struct('samplerate', P_.sRateHz, ...
        'spike_sign', ifeq_(P_.fInverse_file==0, -1, 1), ...
        'scale_factor', P_.uV_per_bit);
    juxta_channel = unique(get_(S_gt_, 'viSite'));
    if numel(juxta_channel)==1, S_json_.juxta_channel = juxta_channel; end
    struct2json_(S_json_, fullfile(vcDir1, 'params.json'));
    
    fprintf('\n');
end %for
end %func


%--------------------------------------------------------------------------
% Export sorting result to .mda file (firings.mda)
function export_mda_(vcFile_in, vcFile_out)
% Usage
% -----
% export_mda_(myfile.prm)
% export_mda_(myfile.batch)
% export_mda_(myfile.prm, firings.mda)
% mda file exported to where .prm files exist

fOverwrite_raw_mda = 1;
% if nargin<2, vcDir_out = ''; end
if nargin<2, vcFile_out = ''; end

vcFile_template = '';
if matchFileEnd_(vcFile_in, '.batch')
    csFile_prm = load_batch_(vcFile_in);
elseif matchFileEnd_(vcFile_in, '.prm')
    csFile_prm = {vcFile_in};
else
    fprintf(2, 'Incorrect format\n');
    return;
end

for iFile = 1:numel(csFile_prm)
    vcFile_prm1 = csFile_prm{iFile};
    if ~matchFileExt_(vcFile_prm1, '.prm')
        fprintf(2, '\tInvalid format: %s\n', vcFile_prm1); 
        continue;
    end    
    try
        S1 = load(strrep(vcFile_prm1, '.prm', '_jrc.mat'));        
        S_gt1 = struct('viTime', S1.viTime_spk, 'viSite', S1.viSite_spk, 'viClu', S1.S_clu.viClu);
        [vcDir1, ~] = fileparts(vcFile_prm1);
        if isempty(vcFile_out)
            gt2mda_(S_gt1, fullfile(vcDir1, 'firings.mda'));
        else
            gt2mda_(S_gt1, vcFile_out);
        end
    catch
        disperr_(['export_mda_: error exporting: ', vcFile_prm1]);
    end
end %for
end %func


%--------------------------------------------------------------------------
% 2018/6/26 JJJ
function vcStr = struct2json_(S, vcFile_json)
if nargin<2, vcFile_json = ''; end

csName = fieldnames(S);
vcStr = '{';
for iField = 1:numel(csName)
    vcStr_ = sprintf('\t"%s": %s', csName{iField}, field2str_(S.(csName{iField})));
    if iField < numel(csName)
        vcStr = sprintf('%s\n%s,', vcStr, vcStr_);
    else
        vcStr = sprintf('%s\n%s\n}', vcStr, vcStr_);
    end
end

if ~isempty(vcFile_json)
    fid = fopen(vcFile_json, 'w');
    fprintf(fid, '%s', vcStr);
    fclose(fid);
    fprintf('Wrote to %s\n', vcFile_json);
end
end


%--------------------------------------------------------------------------
% 2018/6/26 JJJ
function writemda_(mnWav, vcFile_mda, fOverwrite)
if nargin<3, fOverwrite = 1; end
if isempty(mnWav), return; end
if ~fOverwrite
    if exist_file_(vcFile_mda), return; end
end
t1=tic;
addpath_('mdaio/');
writemda(mnWav, vcFile_mda, cDataType_(class(mnWav)));
fprintf('Writing to %s took %0.1fs\n', vcFile_mda, toc(t1));
end %func


%--------------------------------------------------------------------------
% 2018/6/26 JJJ
function vc = cDataType_(vcDataType)
switch lower(vcDataType)
    case 'single', vc = 'float32';
    case 'double', vc = 'float64';
    otherwise vc = vcDataType;
end
end %func

%--------------------------------------------------------------------------
function dimm = file_dimm_(P_)
nChans = get_set_(P_, 'nChans', numel(P_.viSite2Chan));
fTranspose_bin = get_set_(P_, 'fTranspose_bin', 1);
nSamples = filesize_(P_.vcFile) / nChans / bytesPerSample_(P_.vcDataType);
if fTranspose_bin
    dimm = [nChans, nSamples];
else
    dimm = [nSamples, nChans];
end
end %func


%--------------------------------------------------------------------------
function S_gt = gt2mda_(vcFile_gt, vcFile_firings)
% Usages
% -----
% gt2mda_(vcFile_gt, vcFile_firings)
% gt2mda_(S_gt, vcFile_firings)

if nargin<2, vcFile_firings = ''; end
if isstruct(vcFile_gt)
    [vcFile_gt, S_gt] = deal('', vcFile_gt);
else
    if ~exist_file_(vcFile_gt, 1), return; end
    S_gt = load(vcFile_gt);
    if isfield(S_gt, 'Sgt'), S_gt = S_gt.Sgt; end % old format
end
mr = zeros(numel(S_gt.viClu), 3, 'double'); 
if isfield(S_gt, 'viSite'), mr(:,1) = S_gt.viSite; end
mr(:,2)=S_gt.viTime(:); mr(:,3)=S_gt.viClu(:);
if isempty(vcFile_firings)
    vcFile_firings = strrep(vcFile_gt, '.mat', '_firings.mda');
end

writemda_(double(mr'), vcFile_firings); % must be transposed
fprintf('Output to %s\n', vcFile_firings);
end %func


%--------------------------------------------------------------------------
% 10/27/17 JJJ: distance-based neighboring unit selection
function vrWavCor2 = clu_wavcor_2_(ctmrWav_clu, viSite_clu, iClu2, cell_5args)
[P, vlClu_update, mrWavCor0, cviShift1, cviShift2] = deal(cell_5args{:});
nClu = numel(viSite_clu);
iSite_clu2 = viSite_clu(iClu2);    
if iSite_clu2==0 || isnan(iSite_clu2), vrWavCor2 = []; return; end
viSite2 = P.miSites(:,iSite_clu2); 
maxDist_site_um = get_set_(P, 'maxDist_site_um', 50);
viClu1 = find(ismember(viSite_clu, findNearSite_(P.mrSiteXY, iSite_clu2, maxDist_site_um)));

vrWavCor2 = zeros(nClu, 1, 'single');
viClu1(viClu1 >= iClu2) = []; % symmetric matrix comparison
if isempty(viClu1), return; end
cmrWav_clu2 = cellfun(@(x)x(:,viSite2,iClu2), ctmrWav_clu, 'UniformOutput', 0);
ctmrWav_clu1 = cellfun(@(x)x(:,viSite2,viClu1), ctmrWav_clu, 'UniformOutput', 0);
for iClu11 = 1:numel(viClu1)
    iClu1 = viClu1(iClu11);
    if ~vlClu_update(iClu1) && ~vlClu_update(iClu2)
        vrWavCor2(iClu1) = mrWavCor0(iClu1, iClu2);
    else            
        iSite_clu1 = viSite_clu(iClu1);
        if iSite_clu1==0 || isnan(iSite_clu1), continue; end                
        if iSite_clu1 == iSite_clu2
            cmrWav_clu2_ = cmrWav_clu2;
            cmrWav_clu1_ = cellfun(@(x)x(:,:,iClu11), ctmrWav_clu1, 'UniformOutput', 0);
        else
            viSite1 = P.miSites(:,iSite_clu1);
            viSite12 = find(ismember(viSite2, viSite1));
            if isempty(viSite12), continue; end
            cmrWav_clu2_ = cellfun(@(x)x(:,viSite12), cmrWav_clu2, 'UniformOutput', 0);
            cmrWav_clu1_ = cellfun(@(x)x(:,viSite12,iClu11), ctmrWav_clu1, 'UniformOutput', 0);
        end                
        vrWavCor2(iClu1) = maxCor_drift_2_(cmrWav_clu2_, cmrWav_clu1_, cviShift1, cviShift2);
    end        
end %iClu2 loop
end %func


%--------------------------------------------------------------------------
% 10/27/17 JJJ: distance-based neighboring unit selection
function [cvi1, cvi2] = calc_shift_range_(P)

% compute center range for the raw spike waveform
spkLim_raw = get_(P, 'spkLim_raw');
nSamples_raw = diff(spkLim_raw) + 1;
spkLim_factor_merge = get_set_(P, 'spkLim_factor_merge', 1);
spkLim_merge = round(P.spkLim * spkLim_factor_merge);
viRange = (spkLim_merge(1) - spkLim_raw(1) + 1):(nSamples_raw - spkLim_raw(2) + spkLim_merge(2));

% compute shift
nShift = ceil(P.spkRefrac_ms / 1000 * P.sRateHz); % +/-n number of samples to compare time shift
[cvi1, cvi2] = deal(cell(nShift*2+1, 1));
viShift = -nShift:nShift;
for iShift_ = 1:numel(viShift)
    iShift = viShift(iShift_);
    iShift1 = -round(iShift/2);
    iShift2 = iShift + iShift1;
    viRange1 = viRange + iShift1;
    viRange2 = viRange + iShift2;
    vl12 = (viRange1>=1 & viRange1<=nSamples_raw) & (viRange2>=1 & viRange2<=nSamples_raw);
    cvi1{iShift_} = viRange1(vl12);
    cvi2{iShift_} = viRange2(vl12);
end
end %func


%--------------------------------------------------------------------------
% 10/23/17 JJJ: find max correlation pair (combining drift and temporal shift)
function maxCor = maxCor_drift_2_(cmr1, cmr2, cviShift1, cviShift2)
% assert(numel(cmr1) == numel(cmr2), 'maxCor_drift_: numel must be the same');
nDrift = numel(cmr1);
if nDrift == 1
    maxCor = max(xcorr2_mr_(cmr1{1}, cmr2{1}, cviShift1, cviShift2));
else
    tr1 = cat(3, cmr1{:}); %nT x nC x nDrifts
    tr2 = cat(3, cmr2{:});    
    nShift = numel(cviShift1);
    vrCor = zeros(1, nShift);
    for iShift = 1:nShift 
        mr1_ = reshape(meanSubt_(tr1(cviShift1{iShift},:,:)), [], nDrift);
        mr2_ = reshape(meanSubt_(tr2(cviShift2{iShift},:,:)), [], nDrift);
        
        mr12_ = (mr1_' * mr2_) ./ sqrt(sum(mr1_.^2)' * sum(mr2_.^2));
        vrCor(iShift) = max(mr12_(:));
    end
    maxCor = max(vrCor);
end
end


%--------------------------------------------------------------------------
% Make trial function migrated from irc v1 (jrclust.m)
function make_trial_(vcFile_prm, fImec)
% fImec: code-based event detection
% make a _trial.mat file. stores real time
if nargin<2, fImec = 0; end

P = loadParam_(vcFile_prm);

% ask which channel and which output file
csAns = inputdlg('Which channel to load', 'Channel', 1, {num2str(P.nChans)});
iChan = str2double(csAns{1});

% get output file
vcFile_trial = subsFileExt(P.vcFile_prm,  sprintf('_ch%d_trial.mat', iChan));
try
    [FileName,PathName,FilterIndex] = uiputfile(vcFile_trial, 'Save file name');
    if ~FilterIndex, return; end %cancelled
    vcFile_trial = [PathName, FileName];
catch
    fprintf('uiputfile error (old Matlab version). Accepting default');
end

vcAns = questdlg_('TTL Edge', 'Select rising or falling edge for the TTL pulses', 'Rising edge', 'Falling edge', 'Rising edge');
if isempty(vcAns), return; end

hMsg = msgbox_('Loading... (this closes automatically)');
vrWav = load_bin_chan_(P, iChan);
if isempty(vrWav), fprintf(2, 'File loading error: %s\n', P.vcFile_prm); return; end
% fid = memmapfile(P.vcFile, 'Offset', 0, 'Format', P.vcDataType, 'Repeat', inf);
% vrWav = fid.Data(iChan:P.nChans:end);
% clear fid;

if fImec % convert to TTL signal
    dinput_imec = get_set_(P, 'dinput_imec_trial', 1);
    fprintf('Digital input %d selected (P.dinput_imec_trial: 1-16)\n', dinput_imec);
    codeval = int16(bitshift(1,dinput_imec-1));
    vrWav = single(vrWav == codeval);
end

[maxV, minV] = deal(max(vrWav), min(vrWav));
if isempty(get_(P, 'thresh_trial'))
    thresh = (maxV + minV)/2;
else
    thresh = P.thresh_trial;  % load a specific threshold only    
end
nRefrac_trial = round(P.tRefrac_trial * P.sRateHz);
viT_rising = remove_refrac(find(vrWav(1:end-1) < thresh & vrWav(2:end) >= thresh) + 1, nRefrac_trial);
viT_falling = remove_refrac(find(vrWav(1:end-1) > thresh & vrWav(2:end) <= thresh), nRefrac_trial);
viT = ifeq_(strcmpi(vcAns, 'Rising edge'), viT_rising, viT_falling);
vrT = viT / P.sRateHz;

% save
save(vcFile_trial, 'vrT');
disp(['Saved to ', vcFile_trial]);
vcTitle = sprintf('%d events detected (%s)\n', numel(vrT), lower(vcAns));

% edit .prm file
P_trial.vcFile_trial = vcFile_trial;
edit_prm_file_(P_trial, vcFile_prm);
fprintf('Parameter file updated: %s\n\tvcFile_trial = ''%s''\n', vcFile_prm, vcFile_trial);

% plot
hFig = create_figure_('Trial timing', [0 0 .5 1], vcFile_trial, 1, 1); hold on;
% vlOver = vr_set_(vrWav >= thresh, [viT_rising(:) - 1; viT_falling(:) + 1], 1);
vlOver = vrWav >= thresh;
plot(find(vlOver)/P.sRateHz, vrWav(vlOver), 'b.');
stem(vrT, vrWav(viT), 'r'); hold on;
plot(get(gca, 'XLim'), double(thresh) * [1 1], 'm-');
xylabel_(gca, 'Time (s)', sprintf('Chan %d', iChan), vcTitle); 
ylim([minV, maxV]); grid on;
close_(hMsg);
end


%--------------------------------------------------------------------------
function vr = vr_set_(vr, vi, val);
 vi(vi<1 | vi>numel(vr)) = [];
 vr(vi) = val;
end %func


%--------------------------------------------------------------------------
% 12/20/17 JJJ: support combined recordings and header containing files
% 12/15/17 JJJ: Load a single channel in memory efficient way
function vrWav = load_bin_chan_(P, iChan)
% vrWav = load_bin_chan_(P, 0): return average of all valid channels
% vrWav = load_bin_chan_(P, iChan): return specific channel
if nargin<2, iChan = 0; end
vrWav = [];

% Join multiple recordings if P.csFile_merge is set
if isempty(P.vcFile) && ~isempty(P.csFile_merge)
    csFile_bin = filter_files_(P.csFile_merge);   
    cvrWav = cell(numel(csFile_bin), 1);
    P_ = setfield(P, 'csFile_merge', {}); 
    for iFile=1:numel(csFile_bin)
        P_ = setfield(P, 'vcFile', csFile_bin{iFile});
        cvrWav{iFile} = load_bin_chan_(P_, iChan);
        fprintf('.');
    end
    vrWav = cell2mat_(cvrWav);
    return;
end

try       
    vrWav = load_bin_paged_(P, iChan);    
catch
    disperr_();
    return;
end
end %func


%--------------------------------------------------------------------------
% 01/08/18: read and reduce
function mn = load_bin_paged_(P, viChan, nBytes_page)
% ~35x slower than RAM indexing
% mn = load_bin_reduce_(P, 0)
% mn = load_bin_reduce_(P, viChans)
% mn = load_bin_reduce_(P, viChans)
LOAD_FACTOR = 5;
if nargin<3, nBytes_page = []; end
if isempty(nBytes_page)
    S = memory_();
    nBytes_page = floor(S.MaxPossibleArrayBytes() / LOAD_FACTOR);
end
bytesPerSample = bytesPerSample_(P.vcDataType);
nSamples_page = floor(nBytes_page / P.nChans / bytesPerSample);
mn = []; 

% Determine number of samples
if ~exist_file_(P.vcFile) || isempty(viChan), return; end    
nBytes = getBytes_(P.vcFile);
if isempty(nBytes), return; end
header_offset = get_(P, 'header_offset', 0);
nSamples = floor((nBytes-header_offset) / bytesPerSample / P.nChans);

% Loading loop
fid = fopen(P.vcFile, 'r');
try
    if header_offset>0, fseek(fid, header_offset, 'bof'); end
    nPages = ceil(nSamples / nSamples_page);
    if viChan(1) == 0
        fMean = 1;
        viChan = P.viSite2Chan;
        viChan(P.viSiteZero) = [];    
    else
        fMean = 0;
    end
    if nPages == 1
        mn = fread(fid, [P.nChans, nSamples], ['*', lower(P.vcDataType)]);
        mn = mn(viChan,:);
        if fMean, mn = cast(mean(mn), P.vcDataType); end
        mn = mn';
    else
        if fMean
            mn = zeros([nSamples, 1], P.vcDataType);
        else
            mn = zeros([nSamples, numel(viChan)], P.vcDataType);
        end
        for iPage = 1:nPages
            if iPage < nPages
                nSamples_ = nSamples_page;        
            else
                nSamples_ = nSamples - nSamples_page * (iPage-1);
            end
            vi_ = (1:nSamples_) + (iPage-1) * nSamples_page;    
            mn_ = fread(fid, [P.nChans, nSamples_], ['*', lower(P.vcDataType)]);
            mn_ = mn_(viChan,:);
            if fMean, mn_ = cast(mean(mn_), P.vcDataType); end
            mn(vi_,:) = mn_';
        end
    end
catch
    disperr_();
end
fclose_(fid);
end %func


%--------------------------------------------------------------------------
% 12/20/17 JJJ: Export to LFP file
function import_lfp_(P)
% % Merge LFP file for IMEC3 probe
% try
%     if ~isempty(strfind(lower(vcFile), '.imec.ap.bin'))    
%         func_ap2lf = @(x)strrep(lower(x), '.imec.ap.bin', '.imec.lf.bin');
%         vcFile_lf = func_ap2lf(vcFile);
%         csFile_merge_lf = cellfun(@(x)func_ap2lf(x), csFile_merge1, 'UniformOutput', 0);
%         merge_binfile_(vcFile_lf, csFile_merge_lf);
%     end
% catch
%     disp('Merge LFP file error for IMEC3.');
% end
P.vcFile_lfp = strrep(P.vcFile_prm, '.prm', '.lfp.jrc');
t1 = tic;
if isempty(P.csFile_merge)
    % single file
    if is_new_imec_(P.vcFile) % don't do anything, just set the file name
        P.vcFile_lfp = strrep(P.vcFile, '.imec.ap.bin', '.imec.lf.bin');
        P.nSkip_lfp = 12;
        P.sRateHz_lfp = 2500;      
    else
        bin_file_copy_(P.vcFile, P.vcFile_lfp, P);
    end 
else % craete a merged output file
    csFiles_bin = filter_files_(P.csFile_merge);
    fid_lfp = fopen(P.vcFile_lfp, 'w');
    % multiple files merging
    P_ = P;
    for iFile = 1:numel(csFiles_bin)
        vcFile_ = csFiles_bin{iFile};
        if is_new_imec_(vcFile_)        
            vcFile_ = strrep(vcFile_, '.imec.ap.bin', '.imec.lf.bin');
            P_.nSkip_lfp = 1;
        end
        bin_file_copy_(vcFile_, fid_lfp, P_);        
    end
    fclose(fid_lfp);
end
% update the lfp file name in the parameter file
edit_prm_file_(P, P.vcFile_prm);
fprintf('\tLFP file (vcFile_lfp) updated: %s\n\ttook %0.1fs\n', P.vcFile_lfp, toc(t1));
end %func


%--------------------------------------------------------------------------
function export_lfp_(P)
% export LFP waveform to workspace (ordered by the site numbers)

P.vcFile_lfp = strrep(P.vcFile_prm, '.prm', '.lfp.jrc');
if ~exist_file_(P.vcFile_lfp)
    import_lfp_(P)
end
mnLfp = load_bin_(P.vcFile_lfp, P.vcDataType);
nSamples = floor(size(mnLfp,1) / P.nChans);
mnLfp = reshape(mnLfp(1:P.nChans*nSamples), P.nChans, nSamples)';

mnLfp = mnLfp(:, P.viSite2Chan);
mrSiteXY = P.mrSiteXY;
assignWorkspace_(mnLfp, mrSiteXY);
fprintf('\tmnLfp has nSamples x nSites dimension, sites are ordered from the bottom to top, left to right\n');
fprintf('\tmrSiteXY (site positions) has nSites x 2 dimension; col.1: x-coord, col.2: y-coord (um)\n');
end %func


%--------------------------------------------------------------------------
function flag = is_new_imec_(vcFile)
flag = matchFileEnd_(vcFile, '.imec.ap.bin');
end %func


%--------------------------------------------------------------------------
function bin_file_copy_(vcFile_r, vcFile_w, P)
% bin_file_copy_(vcFile_r, fid_w, P): provide file handle to write
% bin_file_copy_(vcFile_r, vcFile_w, P): provide file name to write

if ischar(vcFile_w)
    fid_w = fopen(vcFile_w, 'w');
else
    fid_w = vcFile_w;
end
try
    vn = load_bin_(vcFile_r, P.vcDataType, [], P.header_offset);
    if P.nSkip_lfp > 1
        nSkip_lfp = round(P.nSkip_lfp);        
        vn = reshape_(vn, P.nChans)'; % return nTime x nChans
        dimm_ = size(vn); % [nTime x nChans]
        nSamples_lfp = floor(dimm_(1) / nSkip_lfp);
        if dimm_(1) ~= (nSamples_lfp * nSkip_lfp)
            vn = vn(1:nSamples_lfp * nSkip_lfp, :); % trim extra time
        end
        vn = mean(reshape(vn, nSkip_lfp, []), 1);
        vn = reshape(cast(vn, P.vcDataType), nSamples_lfp, [])';
    end
    write_bin_(fid_w, vn); %write all straight
catch E
    disperr_('bin_file_copy_', E);
end
if ischar(vcFile_w)
    fclose(fid_w);
end
end %func


%--------------------------------------------------------------------------
function mr = reshape_(vr, n1)
% n1: leading dimension
n = numel(vr);
n2 = floor(n / n1);
if n == (n1*n2)
    mr = reshape(vr, n1, n2);
else
    mr = reshape(vr(1:(n1*n2)), n1, n2);
end
end %func


%--------------------------------------------------------------------------
% Show LFP traces
function traces_lfp_(P)
P.sRateHz = P.sRateHz_lfp;
P.vcFile = P.vcFile_lfp;
P.csFile_merge = {};
P.tlim(2) = P.tlim(1) + diff(P.tlim) * P.nSkip_lfp;
P.header_offset = 0;
traces_(P, 0, [], 1); % don't show spikes, don't set P to S0
end %func


%--------------------------------------------------------------------------
function A = readmda_(fname)
% Author: Jeremy Magland, modified by JJJ
% Jan 2015; Last revision: 15-Feb-2106

if (strcmp(fname(end-4:end),'.csv')==1)
    A=textread(fname,'','delimiter',',');
    return;
end

F=fopen(fname,'r','l');

% read the first header sample: data type
try
    code=fread(F,1,'int32');
catch
    error('Problem reading file: %s',fname);
end

% read the second header sample: number of dimensions
if (code>0) 
    num_dims=code;
    code=-1;
else
    fread(F,1,'int32');
    num_dims=fread(F,1,'int32');    
end;

% read the length per dimension
dim_type_str='int32';
if (num_dims<0)
    num_dims=-num_dims;
    dim_type_str='int64';
end;

% read length per dimension
S = fread(F, num_dims, dim_type_str)';
N = prod(S);

switch code
    case -1
        A = fread(F,N*2,'*float');
        A = A(1:2:end) + sqrt(-1) * A(2:2:end);
    case -2, A = fread(F,N,'*uchar');
    case -3, A = fread(F,N,'*float');
    case -4, A = fread(F,N,'*int16');
    case -5, A = fread(F,N,'*int32');
    case -6, A = fread(F,N,'*uint16');
    case -7, A = fread(F,N,'*double');
    case -8, A = fread(F,N,'*uint32');
    otherwise, error('Unsupported data type code: %d',code);
end
A = reshape(A, S);
fclose(F);
end %func


%--------------------------------------------------------------------------
function export_quality_(varargin)
% export_csv_(hObject, event)
if nargin==1
    P = varargin{1};
    fGui = 0;
else
    P = get0_('P');
    fGui = 1;
end

[S0, P] = load_cached_(P); 
if ~isfield(S0, 'S_clu'), fprintf(2, 'File must be sorted first.\n'); return; end
S = S0.S_clu;
[unit_id, SNR, center_site, nSpikes, xpos, ypos, uV_min, uV_pp, IsoDist, LRatio, IsiRat, note] = ...
    deal((1:S.nClu)', S.vrSnr_clu(:), S.viSite_clu(:), S.vnSpk_clu(:), ...
    S.vrPosX_clu(:), S.vrPosX_clu(:), S.vrVmin_uv_clu, S.vrVpp_uv_clu, ...
    S.vrIsoDist_clu(:), S.vrLRatio_clu(:), S.vrIsiRatio_clu(:), S.csNote_clu(:));
%note(cellfun(@isempty, note)) = '';
table_ = table(unit_id, SNR, center_site, nSpikes, xpos, ypos, uV_min, uV_pp, IsoDist, LRatio, IsiRat, note);
disp(table_);

vcFile_csv = subsFileExt_(P.vcFile_prm, '_quality.csv');
writetable(table_, vcFile_csv);
csMsg = { ...
    sprintf('Wrote to %s. Columns:', vcFile_csv), ...
    sprintf('\tColumn 1: unit_id: Unit ID'), ...
    sprintf('\tColumn 2: SNR: |Vp/Vrms|; Vp: negative peak amplitude of the peak site; Vrms: SD of the Gaussian noise (estimated from MAD)'), ...
    sprintf('\tColumn 3: center_site: Peak site number which contains the most negative peak amplitude'), ...
    sprintf('\tColumn 4: nSpikes: Number of spikes'), ...
    sprintf('\tColumn 5: xpos: x position (width dimension) center-of-mass'), ...
    sprintf('\tColumn 6: ypos: y position (depth dimension) center-of-mass, referenced from the tip'), ...
    sprintf('\tColumn 7: uV_min: negative peak voltage (microvolts)'), ...
    sprintf('\tColumn 8: uV_pp: peak-to-peak voltage (microvolts)'), ...
    sprintf('\tColumn 9: IsoDist: Isolation distance quality metric'), ...
    sprintf('\tColumn 10: LRatio: L-ratio quality metric'), ...
    sprintf('\tColumn 11: IsiRat: ISI-ratio quality metric'), ...
    sprintf('\tColumn 12: note: user comments')};

cellfun(@(x)fprintf('%s\n',x), csMsg);
if fGui, msgbox_(csMsg); end
end %func


%--------------------------------------------------------------------------
function mnWav2 = ndist_filt_(mnWav2, ndist_filt)

vnFilt_ = gpuArray_(ones(ndist_filt,1,'single'), isGpu_(mnWav2));
mnWav_ = mnWav2(1+ndist_filt:end,:) - mnWav2(1:end-ndist_filt,:);        
[n1, nChans] = deal(round((ndist_filt-1)/2) , size(mnWav_,2));
n2 = ndist_filt - n1;
mnWav_ = [zeros([n1, nChans], 'like', mnWav_); mnWav_; zeros([n2, nChans], 'like', mnWav_)];                
vcDataType_ = class_(mnWav2);
for iChan = 1:nChans
    vn_ = cast(sqrt(conv(single(mnWav_(:,iChan)).^2, vnFilt_, 'same')), vcDataType_); 
    vn_ = median(vn_(1:10:end)) - vn_;
    mnWav2(:,iChan) = vn_;
end
end %func


%--------------------------------------------------------------------------
function export_chan_(P, vcArg1)
% export list of channels to a bin file, use fskip?
if isempty(vcArg1)
    vcArg1 = inputdlg('Which channel(s) to export (separate by commas or space)', 'Channel', 1, {num2str(P.nChans)});
    if isempty(vcArg1), return; end
    vcArg1 = vcArg1{1};
end
viChan = str2num(vcArg1);
if isnan(viChan), fprintf(2, 'Must provide a channel number\n'); return; end
if any(viChan > P.nChans | viChan < 0)
    fprintf(2, 'Exceeding nChans (=%d).\n', P.nChans);
    return; 
end
try    
    vcChan_ = sprintf('%d-', viChan);
    vcFile_out = strrep(P.vcFile_prm, '.prm', sprintf('_ch%s.jrc', vcChan_(1:end-1)));
    mn = load_bin_chan_(P, viChan);
    write_bin_(vcFile_out, mn);    
    if numel(viChan) == 1
        eval(sprintf('ch%d = mn;', viChan));
        eval(sprintf('assignWorkspace_(ch%d);', viChan));
    else
        assignWorkspace_(mn);        
    end
catch
    fprintf('Out of memory, exporting individual channels\n'); 
    for iChan1 = 1:numel(viChan)
        iChan = viChan(iChan1);
        vcFile_out = strrep(P.vcFile_prm, '.prm', sprintf('_ch%d.jrc', iChan));
        fprintf('Loading chan %d(%d/%d) from %s\n\t', iChan, iChan1, numel(viChan), P.vcFile_prm);
        t1 = tic;
        vn_ = load_bin_chan_(P, iChan);
        fprintf('\n\ttook %0.1fs\n', toc(t1));
        write_bin_(vcFile_out, vn_);
    end %for
end
end %func


%--------------------------------------------------------------------------
% 11/9/2018 JJJ: Added a case for mac
function S = memory_()
%Usage: [mem, unit] =get_free_mem()
mem_default = 1e9; % in bytes
if ispc()
    S = memory();
elseif isunix()
    if ismac()
        [~,out] = system('vm_stat | grep "Pages free" | grep -o -E ''[0-9]+''');    
        mem_bytes = str2double(strtrim(out)) * 4096;
    else
        [~,out] = system('vmstat -s -S M | grep "free memory"');    
        mem_bytes = sscanf(out,'%f  free memory') * 1048576;
    end
    S = struct();
    S.MemAvailableAllArrays = mem_bytes; % convert to Bytes (from -S M flag)
    S.MaxPossibleArrayBytes = mem_bytes;
    S.MemUsedMATLAB = []; 
else
    S = struct('MemAvailableAllArrays', mem_default, ...
        'MaxPossibleArrayBytes', mem_default, 'MemUsedMATLAB', []);
end
end



%--------------------------------------------------------------------------
function vcFile_prb = csv2prb_(vcFile_csv)
% convert .csv file to .prb file

vcFile_prb = strrep(vcFile_csv, '.csv', '.prb');
geometry = csvread(vcFile_csv); % check dimensions
nChans = size(geometry, 1);
S_prb = struct('channels', 1:nChans, ...
    'geometry', geometry); % geometry should be the only requirement
struct2file_(S_prb, vcFile_prb);
end %func


%--------------------------------------------------------------------------
function vcFile_geom = prb2geom_(vcFile_prb, vcFile_geom, fShowPrb)
% vcFile_geom = prb2geom_(vcFile_prb, vcFile_geom)
% vcFile_geom = prb2geom_(mrSiteXY, vcFile_geom)

if nargin < 2, vcFile_geom = ''; end
if nargin < 3, fShowPrb = 1; end

if ischar(vcFile_prb)
    if ~exist_file_(vcFile_prb, 1), vcFile_geom = ''; return; end
    if isempty(vcFile_geom), vcFile_geom = strrep(vcFile_prb, '.prb', '_geom.csv'); end
    S_prb = load_prb_(vcFile_prb);
    mrSiteXY = zeros(size(S_prb.mrSiteXY));
    mrSiteXY(S_prb.viSite2Chan,:) = S_prb.mrSiteXY;
else
    mrSiteXY = vcFile_prb;
    vcFile_prb = '';   
    fShowPrb = 0;
end
csvwrite(vcFile_geom, mrSiteXY);
fprintf('Created %s from %s\n', vcFile_geom, vcFile_prb);
if fShowPrb, edit_(vcFile_geom); end
end %func


%--------------------------------------------------------------------------
% 8/2/17 JJJ: Documentation and test (.m format)
function struct2file_(S, vcFile)
% Modify the parameter file using the variables in the P struct

csName = fieldnames(S);
% csValue = cellfun(@(vcField)S.(vcField), csName, 'UniformOutput',0);
csLines = cell(size(csName));
for iLine=1:numel(csName)
    vcName_ = csName{iLine}; %find field name with 
    val_ = S.(vcName_);
    if isstruct(val_), continue; end %do not write struct
    csLines{iLine} = sprintf('%s = %s;', vcName_, field2str_(val_));
end
cellstr2file_(vcFile, csLines);
end %func


%--------------------------------------------------------------------------
% 8/16/2018 JJJ: .txt format (.meta)
function struct2meta_(S, vcFile_meta)
% Modify the parameter file using the variables in the P struct

csName = fieldnames(S);
csLines = cell(size(csName));
for iLine=1:numel(csName)
    vcName_ = csName{iLine}; %find field name with 
    val_ = S.(vcName_);
    if isstruct(val_), continue; end %do not write struct
    if ischar(val_)
        val_str = val_;
    else
        val_str = field2str_(val_);
    end
    csLines{iLine} = sprintf('%s=%s', vcName_, val_str);
end
cellstr2file_(vcFile_meta, csLines);
end %func


%--------------------------------------------------------------------------
function caim_(vcFile_prm, vcArg2, vcArg3)
% calcium imaging
% if isempty(vcFile_tif)
%     vcFile_tif='D:\Dropbox\shepardlab\BISC\VGlut1Cre_Ai148_prism_goldDevice_20180305_008.tif';
% end
if matchFileEnd_(vcFile_prm, '.prm')
    P = file2struct_(vcFile_prm);
    P.P_jrc = file2struct_(P.vcFile_prm);
elseif matchFileEnd_(vcFile_prm, '.tif')
    P = struct();
    P.vcFile_tif = vcFile_prm;
end
P.nSpatialBin = get_set_(P, 'nSpatialBin', 2);
P.nTemporalBin = get_set_(P, 'nTemporalBin', 1);
P.thresh_mad = get_set_(P, 'thresh_mad', 6);
P.thresh_quantile = get_set_(P, 'thresh_quantile', .9);
P.iChan_sync_rhs = get_set_(P, 'iChan_sync_rhs', 1);

% movie processing
trImg = read_tif(P.vcFile_tif);
[trImg_21, mrImg_21] = mov_norm(trImg, P.nSpatialBin, P.nTemporalBin, 1, 1);
mrImg_roi = mean(trImg_21 > P.thresh_mad, 3);
thresh_roi = quantile(mrImg_roi(:), P.thresh_quantile);
mlMask = mrImg_roi > thresh_roi;
mlMask = imopen(mlMask, strel('disk',1));

% ROI analysis
[~, mrImg_20] = mov_norm(trImg, P.nSpatialBin, 0, 1, 1);
[img_label, nClu] = bwlabel(mlMask, 4); % 4-connected components
vS_region_clu = regionprops(img_label, 'Centroid');
mrCentroid_clu = arrayfun(@(x)x.Centroid, vS_region_clu, 'UniformOutput', 0);
nT = size(mrImg_20,1);
mrV_clu = zeros(nT, nClu, 'like', mrImg_20);
for iClu = 1:nClu
    ml_ = img_label == iClu;
    mrV_clu(:,iClu) = mean(mrImg_20(:,ml_(:)),2);
end
mrV_clu = gather_(mrV_clu);

try
    % Load rhs file
    vcFile_rhs = strrep(P.P_jrc.vcFile, '.bin', '.rhs');
    if ~exist_file_(vcFile_rhs)
        vcFile_rhs = subsDir_(vcFile_rhs, vcFile_prm);
    end
    S_rhs = import_rhs(vcFile_rhs);

    % Extract sync timing
    vrSync_rhs = S_rhs.board_adc_data(P.iChan_sync_rhs,:);
    thresh_sync = max(vrSync_rhs)/2 + min(vrSync_rhs)/2;
    viSync_rhs = find(diff(vrSync_rhs > thresh_sync)>0); % rising edge

    % Extract stim info from the file and save the stimulus time series
    mrStim_rhs = S_rhs.stim_data;
    vpp_stim_rhs = max(max(mrStim_rhs)) - min(min(mrStim_rhs));
    vrVpp_time_stim_rhs = max(mrStim_rhs) - min(mrStim_rhs);
    vrVpp_chan_stim_rhs = max(mrStim_rhs,[],2) - min(mrStim_rhs,[],2);
    vcFile_stim_rhs = strrep(vcFile_rhs, '.rhs', '_stim.bin');
    write_bin_(vcFile_stim_rhs, mrStim_rhs);
    dimm_stim_rhs = size(mrStim_rhs);
    S_rhs = rmfield(S_rhs, ...
        {'amplifier_data', 'stim_data', 'board_dac_data', 't', 'board_adc_data'});
catch
    disperr_('.rhs process error');
    [viSync_rhs, vcFile_stim_rhs, S_rhs] = deal([]);
end

% export image analysis to S_caim functional imaging (fim)
S_caim = makeStruct_(mrV_clu, mrCentroid_clu, vS_region_clu, img_label, ...
    viSync_rhs, vcFile_stim_rhs, dimm_stim_rhs, ...
    vpp_stim_rhs, vrVpp_chan_stim_rhs, vrVpp_time_stim_rhs, S_rhs, P, vcFile_prm);
write_struct_(strrep(vcFile_prm, '.prm', '_caim.mat'), S_caim);

% show image and traces
% plot_caim_(S_caim);

end %func


%--------------------------------------------------------------------------
function plot_caim_(vcArg1)
if isstruct(vcArg1)
    S_caim = vcArg1;
    vcFile_prm = S_caim.vcFile_prm;
else
    vcFile_prm = vcArg1;
    vcFile_caim = strrep(vcFile_prm, '.prm', '_caim.mat');
    S_caim = load_(vcFile_caim);
end

nClu = size(S_caim.mrV_clu,2);
% sRateHz = S_caim.S_
% fps = diff(S_caim.viSync_rhs([1,end])) / (numel(S_caim.viSync_rhs)-1) / sRateHz;
figure; set(gcf, 'Name', vcFile_prm, 'Color','w');
subplot(121); 
imagesc(S_caim.img_label);

axis square;
for iClu = 1:nClu
    ml_ = mi11 == iClu;
    mrV_clu(:,iClu) = sum(S_caim.img_label(:,ml_(:)),2);
    try
        xy_ = S_region(iClu).Centroid;
        text(xy_(1), xy_(2), sprintf('%d',iClu), 'Color', [1 0 1]);
    end
end

subplot(122);
multiplot([],10,[], S_caim.mrV_clu, 1:nClu);
xlabel('Frame # (FPS=4.08)'); ylabel('Cell #'); grid on;
ylim([0 nClu+1]);
set(gca,'YTick', 1:nClu);
axis square;
% set(gcf,'Name',vcFile_tif);

end %func


%--------------------------------------------------------------------------
function [mrRate_clu, sRateHz_rate] = firingrate_clu_(S0, viClu, nSamples, filter_sec_rate)
if nargin<2, viClu = []; end
if nargin<3, nSamples = []; end
if nargin<4, filter_sec_rate = []; end
[P, S_clu] = deal(S0.P, S0.S_clu);

if isempty(viClu), viClu = 1:S_clu.nClu; end
sRateHz_rate = get_set_(P, 'sRateHz_rate', 1000);
filter_sec_rate = get_set_(P, 'filter_sec_rate', 1);
nFilt = round(sRateHz_rate * filter_sec_rate / 2);   
filter_shape_rate = lower(get_set_(P, 'filter_shape_rate', 'triangle'));
switch filter_shape_rate
    case 'triangle'
        vrFilt = ([1:nFilt, nFilt-1:-1:1]'/nFilt*2/filter_sec_rate);
    case 'rectangle'
        vrFilt = (ones(nFilt*2, 1) / filter_sec_rate);
%     case 'interval3'
%         1/2 1/3 1/6. interval history
end %switch
vrFilt = single(vrFilt);

if isempty(nSamples), nSamples = round(P.duration_file * sRateHz_rate); end
mrRate_clu = zeros([nSamples, numel(viClu)], 'single');
for iClu1 = 1:numel(viClu)
    iClu = viClu(iClu1);
    viSpk_clu = S_clu.cviSpk_clu{iClu};
    viTime_clu = S0.viTime_spk(viSpk_clu);           
    viTime_ = round(double(viTime_clu) / P.sRateHz * sRateHz_rate);
    viTime_ = max(min(viTime_, nSamples), 1);
    mrRate_clu(viTime_, iClu1) = 1;        
    mrRate_clu(:,iClu1) = conv(mrRate_clu(:,iClu1), vrFilt, 'same');
end
end %func


%--------------------------------------------------------------------------
% 2018/05/03: Restored prm_template_name
function vcFile_prm = makeprm_mda_(vcFile_mda, vcFile_prb, vcArg_txt, vcDir_prm, vcFile_template)
% Usage
% -----
% vcFile_prm = makeprm_mda_() % test mode
% vcFile_prm = makeprm_mda_(vcFile_mda, vcFile_prb)
% vcFile_prm = makeprm_mda_(vcFile_txt, vcFile_template): batch mode
% vcFile_prm = makeprm_mda_(vcFile_mda, vcFile_prb, vcArg_txt, vcDir_prm, vcFile_template)
%
% Input
% -----
% vcArg_txt: .txt file or .json file
%
% Example
% -----
% myrecording.mda myprobe.csv myarg.txt tempdir myparam.prm
vcFile_prm = '';

if strcmpi(vcFile_mda, 'test')
    csTest = {...
        'irc makeprm-mda D:\mountainsort\K15\raw.mda tetrode.prb', ...
        'irc makeprm-mda D:\mountainsort\K15\raw.mda tetrode.prb D:\mountainsort\K15\params.txt', ...
        'irc makeprm-mda D:\mountainsort\K15\raw.mda tetrode.prb D:\mountainsort\K15\params.txt c:\temp\', ...
        'irc makeprm-mda D:\mountainsort\K15\raw.mda tetrode.prb D:\mountainsort\K15\params.txt c:\temp\ tetrode_template.prm'};
    for iTest = 1:numel(csTest)
        try
            fprintf('\n----------------\nRunning test %d: %s\n', iTest, csTest{iTest});
            eval(csTest{iTest});
        catch
            fprintf(2, '\ttest %d failed: %s\n', iTest, csTest{iTest});
            disperr_(lasterr());
        end
    end
    return;
elseif matchFileExt_(vcFile_mda, '.txt')
    vcFile_template = vcFile_prb;
    vcFile_txt = vcFile_mda;
    csFiles_mda = load_batch_(vcFile_txt);
    csFiles_prm = cell(size(csFiles_mda));
    for iFile = 1:numel(csFiles_mda)
        vcFile_mda1 = csFiles_mda{iFile};
        [vcDir1, ~, ~] = fileparts(vcFile_mda1);
        vcFile_prb1 = fullfile(vcDir1, 'geom.csv'); % see if it exists
        vcArg_txt1 = fullfile(vcDir1, 'params.json'); % see if it exists
        vcFile_gt_mda1 = fullfile(vcDir1, 'firings_true.mda');
        try
            csFiles_prm{iFile} = makeprm_mda_(vcFile_mda1, vcFile_prb1, vcArg_txt1, vcDir1, vcFile_template);
            if exist_file_(vcFile_gt_mda1)
                import_gt_(vcFile_gt_mda1, csFiles_prm{iFile});
            end
        catch
            fprintf('\tError processing %s\n', vcFile_mda1); % error converting file
        end
    end
    % create a batch file
    vcFile_batch = subsFileExt_(vcFile_txt, '.batch');
    cellstr2file_(vcFile_batch, csFiles_prm);
    fprintf('Created %s\n', vcFile_batch);
    edit_(vcFile_batch);    
    return;
end

if nargin<3, vcArg_txt = ''; end
if nargin<4, vcDir_prm = ''; end
if nargin<5, vcFile_template = ''; end

% create .meta file
assert(exist_file_(vcFile_mda), sprintf('File does not exist: %s', vcFile_mda));
S_mda = readmda_header_(vcFile_mda);
P = struct('nChans', S_mda.dimm(1), 'vcDataType', S_mda.vcDataType, ...
    'header_offset', S_mda.nBytes_header, 'vcFile', vcFile_mda);

if exist_file_(vcArg_txt)    
    switch lower(getFileExt_(vcArg_txt))
        case '.txt'
            S_txt = meta2struct_(vcArg_txt);
        case '.json'
            addpath_('jsonlab-1.5/');
            S_txt = loadjson(vcArg_txt);
    end % switch
else
    S_txt = [];
end
prm_template_name = get_set_(S_txt, 'prm_template_name', []);
if isempty(vcFile_template)
    if ~isempty(prm_template_name)    
        vcFile_template = ircpath_(prm_template_name);
        assert_(exist_file_(vcFile_template), 'template file does not exist.');
    end
else
%     vcFile_template = ircpath_(vcFile_template);
    assert_(exist_file_(vcFile_template), 'prm file does not exist.');
end
P.sRateHz = get_set_(S_txt, 'samplerate', 30000);
if isfield(S_txt, 'detect_sign')
    P.fInverse_file = ifeq_(S_txt.detect_sign>0, 1, 0);
elseif isfield(S_txt, 'spike_sign')
    P.fInverse_file = ifeq_(S_txt.spike_sign>0, 1, 0);
end

mask_out_artifacts = get_set_(S_txt, 'mask_out_artifacts', []);
if strcmpi(mask_out_artifacts, 'true')
    P.blank_thresh = 10; 
else
    P.blank_thresh = []; 
end    
P.maxDist_site_spk_um = get_set_(S_txt, 'adjacency_radius', 75);
if P.maxDist_site_spk_um<=0, P.maxDist_site_spk_um = inf; end
P.maxDist_site_um = P.maxDist_site_spk_um * 2/3;
P.maxDist_site_merge_um = P.maxDist_site_spk_um * 0.4667;    
freq_min = get_set_(S_txt, 'freq_min', []);
freq_max = get_set_(S_txt, 'freq_max', []);
if ~isempty(freq_min) && ~isempty(freq_max)
    P.freqLim = [freq_min, freq_max]; 
end
qqFactor = get_(S_txt, 'detect_threshold');
if ~isempty(qqFactor), P.qqFactor = qqFactor; end

nPcPerChan = get_(S_txt, 'pc_per_chan');
if ~isempty(nPcPerChan), P.nPcPerChan = nPcPerChan; end

maxWavCor = get_(S_txt, 'merge_thresh');
if ~isempty(maxWavCor), P.maxWavCor = maxWavCor; end

% create prb file from geom.csv file
if matchFileEnd_(vcFile_prb, '.csv'), vcFile_prb = csv2prb_(vcFile_prb); end
P.probe_file = vcFile_prb;

% create a parameter file name
[~,vcPostfix,~] = fileparts(vcFile_prb);
vcFile_prm = subsFileExt_(vcFile_mda, ['_', vcPostfix, '.prm']);
vcFile_prm = subsDir_(vcFile_prm, format_dir_(vcDir_prm)); % write meta file based on .mda
P.vcFile_prm = vcFile_prm;

% Make it work with cluster environment (slurm srun)
P.fSavePlot_RD = get_set_(P, 'fSavePlot_RD', 0); % disable plot output
P.fParfor = get_set_(P, 'fParfor', 0); % disable parallel 

% Overload with template and default
P0 = file2struct_(ircpath_(read_cfg_('default_prm')));  %P = defaultParam();
P0 = struct_merge_(P0, file2struct_(vcFile_template)); 
P = struct_merge_(P0, P);
P.duration_file = S_mda.dimm(2) / P.sRateHz; %assuming int16
P.version = version_();

% Force .mda format
P.fTranspose_bin = 1;


% Write to prm file
try
    copyfile(ircpath_(read_cfg_('default_prm')), P.vcFile_prm, 'f');
catch
    fprintf(2, 'Invalid path: %s\n', P.vcFile_prm);
    return;
end
edit_prm_file_(P, P.vcFile_prm);
disp(sprintf('Created %s', P.vcFile_prm));
% edit_(P.vcFile_prm);
set0_(P);
end %func


%--------------------------------------------------------------------------
function vcExt = getFileExt_(vcFile)
if isempty(vcFile)
    vcExt = ''; 
else
    [~,~,vcExt] = fileparts(vcFile);
end
end %func


%--------------------------------------------------------------------------
% 2018/05/08: Drift time-bin similarity
function [miSort_drift, cviSpk_drift, nTime_drift, viDrift_spk] = drift_similarity_(S0, P)
% Usages:
%   drift_similarity_(S0)
%   drift_similarity_()
% return the spikes that are correlated


if nargin==0
    S0 = get(0, 'UserData'); 
    if isempty(S0), S0 = load('sample_sample_jrc.mat'); end % debug
end
if nargin<2, P = S0.P; end

% [P, S_clu] = deal(S0.P, S0.S_clu);
nTime_clu = get_set_(P, 'nTime_clu', 4);
nTime_drift = get_set_(P, 'nTime_drift', nTime_clu * 4);
if nTime_clu == 1 || nTime_drift == 1 % no drift correlation analysis
    [miSort_drift, cviSpk_drift, nTime_drift] = deal(1, {1:numel(S0.viSite_spk)}, 1);
    viDrift_spk = ones(1, numel(S0.viSite_spk), 'int32');
    return;
end

fprintf('Calculating drift similarity...'); t1 = tic;
nQuantile_drift = get_set_(P, 'nQuantile_drift', 10);
vrAmp_quantile = quantile(single(S0.vrAmp_spk), (0:nQuantile_drift)/nQuantile_drift);
viSite_unique = unique(S0.viSite_spk);
nSites = numel(viSite_unique);
nSpikes = numel(S0.viSite_spk);
viSpk_bin = [0, ceil((1:nTime_drift)/nTime_drift*nSpikes)];
cviSpk_drift = arrayfun(@(i)(viSpk_bin(i)+1:viSpk_bin(i+1))', (1:nTime_drift)', 'UniformOutput', 0);
vnSpk_bin = viSpk_bin(2:end) - viSpk_bin(1:end-1);
viDrift_spk = cell2mat(arrayfun(@(i)repmat(int32(i), 1, vnSpk_bin(i)), 1:nTime_drift, 'UniformOutput', 0));

% collect stats
mrCount_drift = zeros(nQuantile_drift, nSites, nTime_drift, 'single');
for iTime_drift = 1:nTime_drift
    viSpk1 = cviSpk_drift{iTime_drift};
    [vrAmp1, viSite1] = deal(S0.vrAmp_spk(viSpk1), S0.viSite_spk(viSpk1));
    for iSite1 = 1:nSites
        iSite = viSite_unique(iSite1);   
        mrCount_drift(:,iSite1,iTime_drift) = histcounts(vrAmp1(viSite1==iSite), vrAmp_quantile);
    end    
end
mrCount_drift = reshape(mrCount_drift, [], nTime_drift);
mrDist_drift = squareform(pdist(mrCount_drift'));

[mrSort_drift, miSort_drift] = sort(mrDist_drift, 'ascend');
nSort_drift = ceil(nTime_drift / P.nTime_clu);
miSort_drift = miSort_drift(1:nSort_drift,:);

% if nargout>=4, viSort_drift = hclust_reorder_(mrDist_drift); end

if nargout==0
    figure; imagesc(mrDist_drift); set(gcf,'Name', P.vcFile_prm);
    figure; imagesc(mrSort_drift); set(gcf,'Name', P.vcFile_prm);
    figure; imagesc(mrSort_drift(1:nSort_drift,:)); set(gcf,'Name', P.vcFile_prm);
end
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 2018/05/09: sort drift dataset using spike amplitude distribution
% similarity. local sort.
function S_clu = cluster_drift_(S0, P)
% Usages:
%   drift_similarity_(S0)
%   drift_similarity_()
% return the spikes that are correlated
global trFet_spk
% fTimeReorder_drift = 0;
fGpu_drift = 1;
P.fGpu = fGpu_drift;

if nargin==0
    S0 = get(0, 'UserData'); 
    if isempty(S0), S0 = load('sample_sample_jrc.mat'); end % debug
end
if nargin<2, P = S0.P; end
if isempty(trFet_spk)
    trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet); 
end

t_func = tic;
nSites = numel(P.viSite2Chan);
nSpk = numel(S0.viTime_spk);
[vrRho, vrDelta] = deal(zeros(nSpk, 1, 'single'));
viNneigh = zeros(nSpk, 1, 'uint32');
vrDc2_site = zeros(nSites, 1, 'single');
nTime_clu = get_set_(P, 'nTime_clu', 1);
P.nTime_clu = nTime_clu;
P.dc_subsample = 1000; 
SINGLE_INF = 3.402E+38;
nSites = numel(P.viSite2Chan);

% drift similarity score

% reorder spikes and call spacetime function
% if fTimeReorder_drift
%     [miSort_drift, cviSpk_drift, nTime_drift, viSort_drift] = drift_similarity_(S0, P);
%     viSpk_drift = reverse_lookup_(cell2mat(cviSpk_drift(viSort_drift)));
%     S_clu = cluster_spacetime_(S0, P, [], viSpk_drift);
%     return;
% else
[miSort_drift, cviSpk_drift, nTime_drift] = drift_similarity_(S0, P);
% end

dc2 = [];
    
% compute Rho
cuda_rho_drift_();
fprintf('Calculating Rho (Local density)...\n\t'); t1=tic;
for iTime_drift = 1:nTime_drift
    viSpk1_ = cviSpk_drift{iTime_drift};
    viSpk_ = cell2mat(cviSpk_drift(miSort_drift(:,iTime_drift)));
    n1_ = numel(viSpk1_);
    % assert(all(viSpk1_ == viSpk_(1:n1_));
    [viSite1_, viSite2_, trFet_spk_] = deal(S0.viSite_spk(viSpk_), S0.viSite2_spk(viSpk_), trFet_spk(:,:,viSpk_));
    if isempty(dc2)
        dc2 = calc_dc2_drift_(n1_, viSite1_, viSite2_, trFet_spk_, P);
    end    
    if fGpu_drift
        try
            vrRho(viSpk1_) = cuda_rho_drift_(n1_, viSite1_, viSite2_, trFet_spk_, dc2, P);
            fprintf('.');            
            continue;
        catch
            fprintf('Cluster_drift: GPU failed. Retrying CPU...\n');
            fGpu_drift = 0;
        end
    end
    for iSite = 1:nSites
        viSpk11_ = find(viSite1_(1:n1_) == iSite);
        n11_ = numel(viSpk11_);
        if n11_ == 0, continue; end
        [viSpk_site1_, viSpk_site2_] = deal(find(viSite1_ == iSite), find(viSite2_ == iSite));
        n12_ = numel(viSpk_site1_) + numel(viSpk_site2_);
        mrFet_site12_ = [squeeze_(trFet_spk_(:,1,viSpk_site1_),2), squeeze_(trFet_spk_(:,2,viSpk_site2_),2)];
        mrFet11_ = squeeze_(trFet_spk_(:,1,viSpk11_),2);
        mrDist12_ = eucl2_dist_(gpuArray_(mrFet_site12_, P.fGpu), gpuArray_(mrFet11_, P.fGpu));
        vrRho11_ = sum(mrDist12_ < dc2) / n12_;
        vrRho(viSpk_(viSpk11_)) = gather_(vrRho11_);
    end
    fprintf('.');
end
fprintf('\n\ttook %0.1fs\n', toc(t1));

% compute Delta
cuda_delta_drift_();
fprintf('Calculating Delta (Distance separation)...\n\t'); t2=tic;
for iTime_drift = 1:nTime_drift
    viSpk1_ = cviSpk_drift{iTime_drift};
    viSpk_ = cell2mat(cviSpk_drift(miSort_drift(:,iTime_drift)));
    n1_ = numel(viSpk1_);
    [viSite1_, viSite2_, trFet_spk_] = deal(S0.viSite_spk(viSpk_), S0.viSite2_spk(viSpk_), trFet_spk(:,:,viSpk_));
    if fGpu_drift
        try
            [vrDelta(viSpk1_), viNneigh1_] = cuda_delta_drift_(n1_, viSite1_, viSite2_, trFet_spk_, vrRho(viSpk_), dc2, P); 
            viNneigh(viSpk1_) = gather_(viSpk_(viNneigh1_));
            fprintf('.');
            continue;
        catch
            fprintf('Cluster_drift: GPU failed. Retrying CPU...\n');
            fGpu_drift = 0;
        end
    end    
    for iSite = 1:nSites
        % same as rho step
        viSpk11_ = find(viSite1_(1:n1_) == iSite);
        n11_ = numel(viSpk11_);
        if n11_ == 0, continue; end
        [viSpk_site1_, viSpk_site2_] = deal(find(viSite1_ == iSite), find(viSite2_ == iSite));
        n12_ = numel(viSpk_site1_) + numel(viSpk_site2_);
        mrFet_site12_ = [squeeze_(trFet_spk_(:,1,viSpk_site1_),2), squeeze_(trFet_spk_(:,2,viSpk_site2_),2)];
        mrFet11_ = squeeze_(trFet_spk_(:,1,viSpk11_),2);        
        viSpk12_ = [viSpk_site1_(:); viSpk_site2_(:)];
        viiRho12_ord_ = gpuArray_(rankorder_(vrRho(viSpk_(viSpk12_)), 'descend'), P.fGpu);    
        mrDist12_ = eucl2_dist_(gpuArray_(mrFet_site12_, P.fGpu), gpuArray_(mrFet11_, P.fGpu));  %not sqrt
        mlRemove12_ = bsxfun(@ge, viiRho12_ord_, viiRho12_ord_(1:n11_)');
        mrDist12_(mlRemove12_) = nan;
        [vrDelta11_, viNneigh11_] = min(mrDist12_);
        vrDelta11_ = sqrt(abs(vrDelta11_) / dc2_);
        viNan = find(isnan(vrDelta11_));
        viNneigh11_(viNan) = viNan;
        vrDelta11_(viNan) = sqrt(SINGLE_INF/dc2_);   
        vi_ = viSpk_(viSpk11_);
        [vrDelta(vi_), viNneigh(vi_)] = deal(gather_(vrDelta11_), gather_(viSpk_(viSpk12_(viNneigh11_))));
    end
    fprintf('.');
end %for
viNan_delta = find(isnan(vrDelta));
if ~isempty(viNan_delta), vrDelta(viNan_delta) = max(vrDelta); end
fprintf('\n\ttook %0.1fs\n', toc(t2));

t_runtime = toc(t_func);
trFet_dim = size(trFet_spk); %[1, size(mrFet1,1), size(mrFet1,2)]; %for postCluster
[~, ordrho] = sort(vrRho, 'descend');
S_clu = struct('rho', vrRho, 'delta', vrDelta, 'ordrho', ordrho, 'nneigh', viNneigh, ...
    'P', P, 't_runtime', t_runtime, 'halo', [], 'viiSpk', [], 'trFet_dim', trFet_dim, 'vrDc2_site', vrDc2_site);
end %func


%--------------------------------------------------------------------------
% 2018/07/02: Use knn and drift algorithm
% similarity. local sort. doesn't require dc, delta_cut, rho_cut
function S_clu = cluster_drift_knn_(S0, P)
% Usages:
%   drift_similarity_(S0)
%   drift_similarity_()
% return the spikes that are correlated
global trFet_spk
fTimeReorder_drift = 0;
% P.fGpu = fGpu_drift;

if nargin==0
    S0 = get(0, 'UserData'); 
    if isempty(S0), S0 = load('sample_sample_jrc.mat'); end % debug
end
if nargin<2, P = S0.P; end
if isempty(trFet_spk)
    trFet_spk = load_bin_(strrep(P.vcFile_prm, '.prm', '_spkfet.jrc'), 'single', S0.dimm_fet); 
end

t_func = tic;
nSites = numel(P.viSite2Chan);
nSpk = numel(S0.viTime_spk);
[vrRho, vrDelta] = deal(zeros(nSpk, 1, 'single'));
miKnn = zeros(get_(P, 'knn'), nSpk, 'int32');
viNneigh = zeros(nSpk, 1, 'uint32');
vrDc2_site = ones(nSites, 1, 'single');
nTime_clu = get_set_(P, 'nTime_clu', 1);
P.nTime_clu = nTime_clu;
P.dc_subsample = 1000; 
SINGLE_INF = 3.402E+38;
nSites = numel(P.viSite2Chan);

[miSort_drift, cviSpk_drift, nTime_drift, viDrift_spk] = drift_similarity_(S0, P);
mlDrift = mi2ml_drift_(miSort_drift); %gpuArray_(mi2ml_drift_(miSort_drift), P.fGpu);

%-----
% Calculate Rho
% rho_drift_knn_();
fprintf('Calculating Rho\n\t'); t1=tic;
fDisp = 1;
% [cvrRho, cviSpk] = deal(cell(nSites, 1));
for iSite = 1:nSites
    [mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_, viDrift_spk12_] = fet12_site_(trFet_spk, S0, P, iSite, [], viDrift_spk); % trFet_spk gets replicated. big
    if isempty(viSpk12_), continue; end    
    if isempty(mrFet12_), continue; end    
    vi1_ = viSpk12_(1:n1_);
    [vrRho(vi1_), fGpu_, miKnn_] = rho_drift_knn_(mrFet12_, viDrift_spk12_, mlDrift, n1_, P);  
    miKnn(:,vi1_) = viSpk12_(miKnn_);
    if fDisp
        fprintf('using %s.\n\t', ifeq_(fGpu_, 'GPU', 'CPU')); 
        fDisp = 0;
    end
    [mrFet12_, viDrift_spk12_] = deal([]);
    fprintf('.');    
end
fprintf('\n\ttook %0.1fs\n', toc(t1));

%-----
% Calculate Delta
fprintf('Calculating Delta\n\t'); t2=tic;
fDisp = 1;
for iSite = 1:nSites
    [mrFet12_, viSpk12_, n1_, n2_, viiSpk12_ord_, viDrift_spk12_] = fet12_site_(trFet_spk, S0, P, iSite, [], viDrift_spk);
    if isempty(viSpk12_), continue; end     
    vrRho12_ = vrRho(viSpk12_);
    [vrDelta_, viNneigh_, fGpu_] = delta_drift_knn_(mrFet12_, viDrift_spk12_, mlDrift, vrRho12_, n1_, P);
    if fDisp
        fprintf('using %s.\n\t', ifeq_(fGpu_, 'GPU', 'CPU')); 
        fDisp = 0;
    end
    viSpk_site_ = S0.cviSpk_site{iSite};    
    vrDelta(viSpk_site_) = vrDelta_;
    viNneigh(viSpk_site_) = viSpk12_(viNneigh_);
    [mrFet12_, vrRho12_, viDrift_spk12_] = deal([]);
    fprintf('.');
end
% Deal with nan delta
viNan_delta = find(isnan(vrDelta));
if ~isempty(viNan_delta)
    vrDelta(viNan_delta) = max(vrDelta);
end
fprintf('\n\ttook %0.1fs\n', toc(t2));
vrRho = vrRho / max(vrRho) / 10;     % divide by 10 to be compatible with previous version displays

t_runtime = toc(t_func);
trFet_dim = size(trFet_spk); %[1, size(mrFet1,1), size(mrFet1,2)]; %for postCluster
[~, ordrho] = sort(vrRho, 'descend');
S_clu = struct('rho', vrRho, 'delta', vrDelta, 'ordrho', ordrho, 'nneigh', viNneigh, ...
    'P', P, 't_runtime', t_runtime, 'halo', [], 'viiSpk', [], ...
    'trFet_dim', trFet_dim, 'vrDc2_site', vrDc2_site, 'miKnn', miKnn);
end %func


%--------------------------------------------------------------------------
% 9/14/2018 JJJ: Map index
function mi2 = map_(mi, viMap)
% Same as mi2 = viMap(mi) except for zero-index addressing
% zero values map to zero values
% deal with zero index
mi2 = zeros(size(mi), 'like', mi);
for iCol = 1:size(mi,2)
    vi_ = mi(:,iCol);
    vl_ = vi_ > 0;
    if all(vl_)
        mi2(:,iCol) = vi_;
    else
        mi2(vl_,iCol) = viMap(vi_(vl_));
    end
end
end %func


%--------------------------------------------------------------------------
% 2019/7/2 JJJ: compute rho using knn
function [vrRho1, fGpu, miKnn1] = rho_drift_knn_(mrFet12, viDrift_spk12, mlDrift, n1, P)

[nC, n12] = size(mrFet12); %nc is constant with the loop
nT_drift = size(mlDrift,1);
% fGpu = isGpu_(mrFet12);
% [gmrFet12, gviDrift_spk12] = gpuArray_deal_(mrFet12, viDrift_spk12, fGpu);     
viDrift_spk1 = viDrift_spk12(1:n1);
vrRho1 = zeros(n1, 1, 'single');
knn = get_(P,'knn');
miKnn1 = zeros(knn, n1, 'int32');
for iDrift = 1:nT_drift
    vi1 = find(viDrift_spk1==iDrift);
    if isempty(vi1), continue; end
    vi2 = find(mlDrift(viDrift_spk12, iDrift));
    [vi1, vi2] = deal(int32(vi1), int32(vi2));
    [vrRho1_, fGpu, miKnn_] = cuda_knn_(mrFet12, vi2, vi1, P);
    vrRho1(vi1) = gather_(1./vrRho1_);
    n2 = size(miKnn_,1);
    if n2 == knn
        miKnn1(:,vi1) = gather_(miKnn_);
    else        
        miKnn1(1:n2,vi1) = gather_(miKnn_);
        miKnn1(n2+1:end,vi1) = repmat(gather_(miKnn_(end,:)), [knn-n2, 1]);
    end
end
end %func


%--------------------------------------------------------------------------
function [vrKnn, fGpu, miKnn] = cuda_knn_(mrFet, vi2, vi1, P)
% it computes the index of KNN

persistent CK
knn = get_set_(P, 'knn', 30);
[CHUNK, nC_max, nThreads] = deal(8, 36, 256); % tied to cuda_knn_index.cu
[n2, n1, nC, n12] = deal(numel(vi2), numel(vi1), size(mrFet,1), size(mrFet,2));
fGpu = P.fGpu;
knn = min(knn, n2);
if fGpu
    [gmrFet2, gmrFet1] = gpuArray_deal_(mrFet(:,vi2), mrFet(:,vi1), P.fGpu);
    for iRetry = 1:2
        try
            if isempty(CK)
                %CK = parallel.gpu.CUDAKernel('cuda_knn_index.ptx','cuda_knn_index.cu'); % auto-compile if ptx doesn't exist
                CK = parallel.gpu.CUDAKernel('cuda_knn_index.ptx','cuda_knn_index.cu'); % auto-compile if ptx doesn't exist
                CK.ThreadBlockSize = [nThreads, 1];          
                CK.SharedMemorySize = 4 * CHUNK * (nC_max + nThreads*2); % @TODO: update the size
            end
            CK.GridSize = [ceil(n1 / CHUNK / CHUNK), CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
            vrKnn = zeros([n1, 1], 'single', 'gpuArray');
            vnConst = int32([n2, n1, nC, knn]);            
            miKnn = zeros([knn, n1], 'int32', 'gpuArray'); 
            [vrKnn, miKnn] = feval(CK, vrKnn, miKnn, gmrFet2, gmrFet1, vnConst);
            miKnn = vi2(miKnn);
            return;
        catch % use CPU, fail-safe
            CK = [];
            fGpu = 0; % using CPU
        end
    end
end
if ~fGpu    
%     [mr12_, miKnn] = sort(eucl2_dist_(mrFet(:, vi2), mrFet(:, vi1)));
%     vrKnn = sqrt(abs(mr12_(knn,:)));
%     miKnn = vi2(miKnn(1:knn,:)); % keep knn  
    [vrKnn, miKnn] = knn_cpu_(mrFet, vi1, vi2, knn);
end
end %func


%--------------------------------------------------------------------------
% 10/16/2018 JJJ: Using native function in matlab (pdist2 function)
% 9/20/2018 JJJ: Memory-optimized knn
function [vrKnn, miKnn] = knn_cpu_(mrFet, vi1, vi2, knn)
% if isempty(vi1), vi1 = 1:size(mrFet,2); end
% if isempty(vi2), vi2 = 1:size(mrFet,2); end
switch 2
    case 2
        if isempty(vi1) && isempty(vi2)
            mrFet_T = mrFet';
            [mrKnn, miKnn] = pdist2(mrFet_T, mrFet_T, 'euclidean', 'smallest', knn);
        else
            [mrKnn, miKnn] = pdist2(mrFet(:,vi2)', mrFet(:,vi1)', 'euclidean', 'smallest', knn);             
            miKnn = vi2(miKnn);
        end
        miKnn = int32(miKnn);
        vrKnn = mrKnn(end,:)';
    case 1
        nStep_knn = 1000;
        n1 = numel(vi1);
        miKnn = zeros([knn, n1], 'int32'); 
        vrKnn = zeros([n1, 1], 'single');
        mrFet2 = mrFet(:,vi2);
        mrFet1 = mrFet(:,vi1);

        fh_dist_ = @(y)bsxfun(@plus, sum(y.^2), bsxfun(@minus, sum(mrFet2.^2)', 2*mrFet2'*y));
        for i1 = 1:nStep_knn:n1
            vi1_ = i1:min(i1+nStep_knn-1, n1);
            mrD_ = fh_dist_(mrFet1(:,vi1_));
            [mrSrt_, miSrt_] = sort(mrD_);
            miKnn(:,vi1_) = miSrt_(1:knn,:);
            vrKnn(vi1_) = mrSrt_(knn,:);
        end %for
        miKnn = vi2(miKnn);
        vrKnn = sqrt(abs(vrKnn));
end
end %func


%--------------------------------------------------------------------------
function [vrKnn, fGpu, miKnn] = cuda_knn__(mrFet, vi2, vi1, P)

persistent CK
knn = get_set_(P, 'knn', 30);
CHUNK = get_set_(P, 'CHUNK', 16);
nC_max = get_set_(P, 'nC_max', 36);
nThreads = get_set_(P, 'nThreads', 128) * 2;
[n2, n1, nC, n12] = deal(numel(vi2), numel(vi1), size(mrFet,1), size(mrFet,2));
fGpu = P.fGpu;
knn = min(knn, n2);
% miKnn = [];
if nargout==3, fGpu = 0; end
if fGpu
    [gmrFet2, gmrFet1] = gpuArray_deal_(mrFet(:,vi2), mrFet(:,vi1), P.fGpu);
    for iRetry = 1:2
        try
            if isempty(CK)
                CK = parallel.gpu.CUDAKernel('cuda_knn.ptx','cuda_knn.cu'); % auto-compile if ptx doesn't exist
                CK.ThreadBlockSize = [nThreads, 1];          
                CK.SharedMemorySize = 4 * CHUNK * (nC_max + nThreads); % @TODO: update the size
            end
            CK.GridSize = [ceil(n1 / CHUNK / CHUNK), CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
            vrKnn = zeros([n1, 1], 'single', 'gpuArray');
            vnConst = int32([n2, n1, nC, knn]);            
            vrKnn = feval(CK, vrKnn, gmrFet2, gmrFet1, vnConst);
%             miKnn = zeros([knn, n1], 'int32', 'gpuArray'); 
            %[vrKnn, miKnn] = feval(CK, vrKnn, miKnn, gmrFet2, gmrFet1, vnConst);
%             [vrKnn_, miKnn_] = deal(vrKnn, miKnn);
            return;
        catch % use CPU, fail-safe
            CK = [];
            fGpu = 0; % using CPU
        end
    end
end
if ~fGpu
    [mr12_, miKnn] = sort(eucl2_dist_(mrFet(:, vi2), mrFet(:, vi1)));
    vrKnn = sqrt(abs(mr12_(knn,:)));
    miKnn = miKnn(1:knn,:); % keep knn
end
end %func


%--------------------------------------------------------------------------
% 2019/7/2 JJJ: compute delta using knn
function [vrDelta1, viNneigh1, fGpu] = delta_drift_knn_(mrFet12, viDrift_spk12, mlDrift, vrRho12, n1, P)  

% fGpu = isGpu_(mrFet12); 
knn = get_set_(P, 'knn', 30);
SINGLE_INF = 3.402E+38;
fGpu = P.fGpu;
[nC, n12] = size(mrFet12); %nc is constant with the loop
nT_drift = size(mlDrift,1);
vrRho12 = vrRho12(:);
% [gmrFet12, gviDrift_spk12, gvrRho12] = gpuArray_deal_(mrFet12, viDrift_spk12, vrRho12(:), fGpu);   
% [gviDrift_spk1, gvrRho1] = deal(gviDrift_spk12(1:n1)', gvrRho12(1:n1)');
% [gmrFet12, gviDrift_spk12, gvrRho12] = gpuArray_deal_(mrFet12, viDrift_spk12, vrRho12(:), fGpu);   
[viDrift_spk1, vrRho1] = deal(viDrift_spk12(1:n1)', vrRho12(1:n1)');
[vrDelta1, viNneigh1] = deal([]);

for iDrift = 1:nT_drift
    vi1_ = find(viDrift_spk1==iDrift);
    if isempty(vi1_), continue; end
    vi2_ = find(mlDrift(viDrift_spk12, iDrift));

    % do cuda
    [vrDelta1_, viNneigh1_, fGpu] = cuda_delta_knn_(mrFet12, vrRho12, vi2_, vi1_, P);
    if isempty(vrDelta1)
        vrDelta1 = zeros([1, n1], 'like', vrDelta1_);
        viNneigh1 = zeros([1, n1], 'like', viNneigh1_);
    end
    vrDelta1(vi1_) = vrDelta1_;
    viNneigh1(vi1_) = viNneigh1_;
end

vrDelta1 = gather_(vrDelta1) .* vrRho1;
viNneigh1 = gather_(viNneigh1);
viNan = find(isnan(vrDelta1));
viNneigh1(viNan) = viNan;
vrDelta1(viNan) = sqrt(SINGLE_INF);
end %func


%--------------------------------------------------------------------------
function [vrDelta1, viNneigh1, fGpu] = cuda_delta_knn_(mrFet, vrRho, vi2, vi1, P)

persistent CK
CHUNK = get_set_(P, 'CHUNK', 16);
nC_max = get_set_(P, 'nC_max', 45);
nThreads = get_set_(P, 'nThreads', 128);
[n2, n1, nC, n12] = deal(numel(vi2), numel(vi1), size(mrFet,1), size(mrFet,2));
fGpu = P.fGpu;

if fGpu
    [gmrFet2, gmrFet1, gvrRho2, gvrRho1] = gpuArray_deal_(mrFet(:,vi2), mrFet(:,vi1), vrRho(vi2), vrRho(vi1));
    for iRetry = 1:2
        try
            if isempty(CK)
                CK = parallel.gpu.CUDAKernel('cuda_delta_knn.ptx','cuda_delta_knn.cu'); % auto-compile if ptx doesn't exist
                CK.ThreadBlockSize = [nThreads, 1];          
                CK.SharedMemorySize = 4 * CHUNK * (nC_max + nThreads*2 + 1); % @TODO: update the size
            end
            CK.GridSize = [ceil(n1 / CHUNK / CHUNK), CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
            vrDelta1 = zeros([n1, 1], 'single', 'gpuArray'); 
            viNneigh1 = zeros([n1, 1], 'uint32', 'gpuArray'); 
            vnConst = int32([n2, n1, nC]);
            [vrDelta1, viNneigh1] = feval(CK, vrDelta1, viNneigh1, gmrFet2, gmrFet1, gvrRho2, gvrRho1, vnConst);
            viNneigh1 = uint32(vi2(viNneigh1));
            return;
        catch % use CPU, fail-safe
            CK = [];
            fGpu = 0;
        end
    end
end
if ~fGpu
    [vrDelta1, viNneigh1] = delta_knn_cpu_(mrFet, vrRho, vi1, vi2);    
%     mr12_ = eucl2_dist_(mrFet(:,vi2), mrFet(:,vi1));
%     [vrRho2, vrRho1] = deal(vrRho(vi2), vrRho(vi1));
%     mr12_(bsxfun(@le, vrRho2(:), vrRho1(:)')) = nan;  % ignore smaller density
%     [vrDelta1_, viNneigh1_] = min(mr12_);    
%     vrDelta1 = sqrt(abs(vrDelta1_));
%     viNneigh1 = uint32(vi2(viNneigh1_));
end
end %func


%--------------------------------------------------------------------------
% 9/20/2018 JJJ: Memory-optimized knn for computing delta (dpclus)
function [vrDelta1, viNneigh1] = delta_knn_cpu_(mrFet, vrRho, vi1, vi2)
nStep_knn = 1000;
n1 = numel(vi1);
vrDelta1 = zeros([n1, 1], 'single');
viNneigh1 = zeros([n1, 1], 'uint32');
[mrFet2, mrFet1] = deal(mrFet(:,vi2), mrFet(:,vi1));
[vrRho2, vrRho1] = deal(vrRho(vi2), vrRho(vi1));
fh_dist_ = @(y)bsxfun(@plus, sum(y.^2), bsxfun(@minus, sum(mrFet2.^2)', 2*mrFet2'*y));

for i1 = 1:nStep_knn:n1
    vi1_ = i1:min(i1+nStep_knn-1, n1);
    mrD_ = fh_dist_(mrFet1(:,vi1_));
    mrD_(bsxfun(@le, vrRho2, vrRho1(vi1_)')) = inf;
    [vrDelta1(vi1_), viNneigh1(vi1_)] = min(mrD_);
end
vrDelta1 = sqrt(abs(vrDelta1));
viNneigh1 = uint32(vi2(viNneigh1));
end %func


%--------------------------------------------------------------------------
function dc2 = calc_dc2_drift_(n1, viSite1, viSite2, trFet_spk, P)
fprintf('Computing dc'); t1 = tic; 
% fprintf('Calculating Dc (=distance cut-off)...\n\t'); t1=tic;

n2 = size(trFet_spk, 3);
nSites = numel(P.viSite2Chan);
[n1_, n2_] = deal(P.dc_subsample, P.dc_subsample * 4);
viSite11 = viSite1(1:n1);
fh_trFet2mr = @(vi,i)squeeze_(trFet_spk(:,i,vi),2);

vrDc2_site = zeros(nSites, 1, 'single');
for iSite = 1:nSites
    vi11_ = subsample_vr_(find(viSite11 == iSite), n1_);
    vi21_ = subsample_vr_(find(viSite1 == iSite), n2_);
    vi22_ = subsample_vr_(find(viSite2 == iSite), n2_);
    mrD12_ = sort(eucl2_dist_([fh_trFet2mr(vi21_,1), fh_trFet2mr(vi22_,2)], fh_trFet2mr(vi11_,1)), 'ascend');
    iCut_ = ceil(size(mrD12_, 1) * P.dc_percent/100);
    vrDc2_site(iSite) = median(mrD12_(iCut_,:));
end
dc2 = nanmedian(vrDc2_site);
fprintf('\n\ttook %0.1fs\n', toc(t1));

% vrD11 = eucl2_dist_(mrFet11_, fh_trFet2mr(vi2_,1)); vrD11 = vrD11(bsxfun(@eq, viSite11_(:), viSite21_(:)'));
% vrD12 = eucl2_dist_(mrFet11_, fh_trFet2mr(vi2_,2)); vrD12 = vrD12(bsxfun(@eq, viSite11_(:), viSite22_(:)'));
% dc2 = quantile([vrD11; vrD12], P.dc_percent/100);
% fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
function vrRho1 = cuda_rho_drift_(n1, viSite1, viSite2, trFet_spk, dc2, P)  

persistent CK nC_
if nargin==0, nC_ = 0; return; end
if isempty(nC_), nC_ = 0; end
[nC, ~, n12] = size(trFet_spk);
nC_max = get_set_(P, 'nC_max', 45);
CHUNK = get_set_(P, 'CHUNK', 16);
nThreads = get_set_(P, 'nThreads', 128);
dc2 = single(dc2); 
mrFet1 = gpuArray_(squeeze_(trFet_spk(:,1,:),2));
mrFet2 = gpuArray_(squeeze_(trFet_spk(:,2,:),2));
miSite12 = gpuArray_([viSite1(:), viSite2(:)]);
if (nC_ ~= nC) % create cuda kernel
    nC_ = nC;
    CK = parallel.gpu.CUDAKernel('irc_cuda_rho_drift.ptx','irc_cuda_rho_drift.cu');
    CK.ThreadBlockSize = [nThreads, 1];          
    CK.SharedMemorySize = 4 * CHUNK * (nC_max + 1 + 2 * nThreads); % @TODO: update the size
end
CK.GridSize = [ceil(n1 / CHUNK / CHUNK), CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
vrRho1 = zeros([1, n1], 'single', 'gpuArray'); 
vnConst = int32([n1, n12, nC]);
%vrRho1 = feval(CK, vrRho1, miSite12, mrFet1, mrFet2, vnConst, dc2);
vrRho1 = feval(CK, vrRho1, miSite12, mrFet1, mrFet2, vnConst, dc2);
vrRho1 = gather_(vrRho1);
end %func


%--------------------------------------------------------------------------
function [vrDelta1, viNneigh1] = cuda_delta_drift_(n1, viSite1, viSite2, trFet_spk, vrRho1, dc2, P)            
persistent CK nC_
if nargin==0, nC_ = 0; return; end
if isempty(nC_), nC_ = 0; end
[nC, ~, n12] = size(trFet_spk);
nC_max = get_set_(P, 'nC_max', 45);
CHUNK = get_set_(P, 'CHUNK', 16);
nThreads = get_set_(P, 'nThreads', 128);
dc2 = single(dc2);    
mrFet1 = gpuArray_(squeeze_(trFet_spk(:,1,:),2));
mrFet2 = gpuArray_(squeeze_(trFet_spk(:,2,:),2));
miSite12 = gpuArray_([viSite1(:), viSite2(:)]);
if (nC_ ~= nC) % create cuda kernel
    nC_ = nC;
    CK = parallel.gpu.CUDAKernel('irc_cuda_delta_drift.ptx', 'irc_cuda_delta_drift.cu');
    CK.ThreadBlockSize = [nThreads, 1];          
    CK.SharedMemorySize = 4 * CHUNK * (nC_max + 2 + 2 * nThreads); % @TODO: update the size
end
CK.GridSize = [ceil(n1 / CHUNK / CHUNK), CHUNK]; %MaxGridSize: [2.1475e+09 65535 65535]    
vrDelta1 = zeros([1, n1], 'single', 'gpuArray'); 
viNneigh1 = zeros([1, n1], 'uint32', 'gpuArray'); 
vnConst = int32([n1, n12, nC]);
[vrDelta1, viNneigh1] = feval(CK, vrDelta1, viNneigh1, miSite12, mrFet1, mrFet2, gpuArray(vrRho1), vnConst, dc2);
vrDelta1 = gather_(vrDelta1);
viNneigh1 = gather_(viNneigh1);
end %func


%--------------------------------------------------------------------------
% 180629 JJJ: compare two vectors and see if the 
function ml = compare_drift_(viA, viB, mlDrift, fInverse)
% miMember: nMembers x nDrift
if nargin<4, fInverse = 0; end

% [vmax, vmin] = deal(max(max(viA), max(viB)), min(min(viA), min(viB)));
% assert(vmax <= 255 && vmin >= 0, 'values supported 0-255');

if ~islogical(mlDrift), mlDrift = mi2ml_drift_(mlDrift); end
nDrift = size(mlDrift, 2);
if fInverse, mlDrift = ~mlDrift; end

% determine membership
ml = false(numel(viA), numel(viB));
viA = viA(:);
for iDrift = 1:nDrift
    viB_ = find(viB==iDrift);
    ml(:, viB_) = repmat(mlDrift(viA,iDrift), 1, numel(viB_));
end
end %func


%--------------------------------------------------------------------------
% change the encoding scheme
function mlDrift = mi2ml_drift_(miMember)

[nMembers, nDrift] = size(miMember);
mlDrift = false(nDrift);
[viCol, viRow] = deal(miMember, repmat(1:nDrift, nMembers, 1));
mlDrift(sub2ind(size(mlDrift), viCol(:), viRow(:))) = true;
end %func

    
%--------------------------------------------------------------------------
% 180628 JJJ: ismember operating vec on mat
function ml = ismember_mr_(vi, mi, fInverse)
if nargin<3, fInverse = 0; end

[vmax, vmin] = deal(max(max(vi), max(max(mi))), min(min(vi), min(min(mi))));
assert(vmax <= 255 && vmin >= 0, 'values supported 0-255');
% ml = false(numel(vi), size(mi,2));
% for i=1:size(mi,2)
%     ml(:,i) = ismember(vi, mi(:,i));
% end
[vi, mi] = deal(gather_(uint8(vi(:))), gather_(uint8(mi)));
if ~fInverse
    ml = cell2mat(arrayfun(@(i)ismember(vi, mi(:,i)), 1:size(mi,2), 'UniformOutput', 0));
else
    ml = cell2mat(arrayfun(@(i)~ismember(vi, mi(:,i)), 1:size(mi,2), 'UniformOutput', 0));
end
end %func


%--------------------------------------------------------------------------
function vcFile_out = transpose_bin_(vcArg1, vcArg2, vcArg3, vcArg4)
% transpose_bin_(vcFile_prm)
% transpose_bin_(vcFile_bin) % will be prompted with the format
% transpose_bin_(vcFile_bin, dimm1, dimm2, dataType)

vcFile = vcArg1;
if ~exist_file_(vcFile, 1), return; end

% Get the raw file in the memory and output as transposed
if matchFileEnd_(vcFile_prm, '.prm')
    P = loadParam_(vcFile_prm);
    fTranspose_bin = get_set_(P, 'fTranspose_bin', 1);
    mnWav = load_bin_(P.vcFile);
%     P.nChans
else
%     P = 
end


end %func


%--------------------------------------------------------------------------
function flag = matchFileEnd_(vcFile, vcSuffix)
% see also: matchFileExt_
func_ = @(x)~isempty(regexpi(x, [vcSuffix, '$']));
if ischar(vcFile)
    flag = func_(vcFile);
elseif iscell(vcFile)   
    flag = cellfun(@(x)func_(x), vcFile);
else
    error('Invalid type: %s', class(vcFile));
end
end %func        


%--------------------------------------------------------------------------
function [vrK_site, vrE_site, mrA2B] = search_kernel_sites_(mrSiteXY_A, mrSiteXY_B)

nSites = size(mrSiteXY_A,1);


objfun_ = @(x,vr) abs(1 - sum(exp(-(vr/x).^2))/2);
mrDist = squareform(pdist(double(mrSiteXY_A)));
kernel0 = min(mrDist(mrDist>0));
t1=tic;
vrK_site = zeros(nSites, 1);
fprintf('searching optimal kernel size per site\n\t');
% try
%     parfor iSite = 1:nSites
%         [vrK_site(iSite), vrE_site(iSite)] = fminsearch(@(x)objfun_(x,mrDist(:,iSite)), kernel0, struct('Display', 'none'));
%         fprintf('.');
%     end
% catch
    for iSite = 1:nSites
        [vrK_site(iSite), vrE_site(iSite)] = fminsearch(@(x)objfun_(x,mrDist(:,iSite)), kernel0, struct('Display', 'none'));
        fprintf('.');        
    end
% end
fprintf('\n\ttook %0.1fs\n', toc(t1));

if nargout>=3
    if nargin<2, mrSiteXY_B = mrSiteXY_A; end
    mrA2B = bsxfun(@rdivide, pdist2(mrSiteXY_A, mrSiteXY_B), vrK_site(:)); 
    mrA2B = exp(-mrA2B.^2) / 2;
end
end %func


%--------------------------------------------------------------------------
function mr = spatial_smooth_(mr, P)
[vrK_site, vrE_site, mrA2B] = search_kernel_sites_(P.mrSiteXY);
mr = cast(single(mr) * single(mrA2B), class(mr));
end %func


%--------------------------------------------------------------------------
function [viLeafOrder, mrDist_reorder] = hclust_reorder_(mrDist, vcMethod)
if nargin==0
    fprintf(2, 'test dataset generated:\n');
    mrDist = squareform(pdist([1 1; 9 9; 11 11; 2 2]));
    disp(mrDist);
end
if nargin<2, vcMethod = 'median'; end

get_triu = @(mr)mr(triu(true(size(mr)),1))';
vrDist = get_triu(mrDist);
viLeafOrder = optimalleaforder(linkage(vrDist, vcMethod), vrDist);

if nargout>=2 || nargout == 0
    [viXX, viYY] = meshgrid(1:size(mrDist));
    [viXX, viYY] = deal(viLeafOrder(viXX), viLeafOrder(viYY));
    dimm = size(mrDist);
    mrDist_reorder = reshape(mrDist(sub2ind(dimm, viXX(:), viYY(:))), dimm);
    
    if nargout==0
        figure;
        subplot 121; imagesc(mrDist); label_axes_(1:dimm(1)); title('before'); 
        subplot 122; imagesc(mrDist_reorder); label_axes_(viLeafOrder); title('after'); 
        fprintf('reorder: %s\n', sprintf('%d ', viLeafOrder));
%         disp(viLeafOrder);
%         disp(mrDist_reorder);
    end
end
end


%--------------------------------------------------------------------------
% 7/11/2018 JJJ: Use system-default browser to open a web link
function web_(vcPage)
if isempty(vcPage), return; end
if ~ischar(vcPage), return; end
try
    % use system browser
    if ispc()
        system(['start ', vcPage]);
    elseif ismac()
        system(['open ', vcPage]);
    elseif isunix()
        system(['sensible-browser ', vcPage]);
    else
        web(vcPage);
    end
catch
    web(vcPage); % use matlab default web browser
end
end %func


%--------------------------------------------------------------------------
% 8/2/2018 JJJ: copied from C:\Program Files\MATLAB\R2018a\toolbox\matlab\codetools\edit.m
function result = isUsingBuiltinEditor_()
% g1609199 - Retrieve the preference value using the Settings API. 
try
    vcEditor = getenv('EDITOR');
    if ~isempty(vcEditor), result = false; return; end
    s = matlab.settings.internal.settings;
    result = s.matlab.editor.UseMATLABEditor.ActiveValue;
catch
    result = true;
end
end %func


%--------------------------------------------------------------------------
% 8/15/2018 JJJ: Copyed from npy-matlab
% https://github.com/kwikteam/npy-matlab
function [arrayShape, dataType, fortranOrder, littleEndian, totalHeaderLength, npyVersion] = readNPYheader_(filename)
% function [arrayShape, dataType, fortranOrder, littleEndian, ...
%       totalHeaderLength, npyVersion] = readNPYheader(filename)
%
% parse the header of a .npy file and return all the info contained
% therein.
%
% Based on spec at http://docs.scipy.org/doc/numpy-dev/neps/npy-format.html

fid = fopen(filename);

% verify that the file exists
if (fid == -1)
    if ~isempty(dir(filename))
        error('Permission denied: %s', filename);
    else
        error('File not found: %s', filename);
    end
end

try
    
    dtypesMatlab = {'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double', 'logical'};
    dtypesNPY = {'u1', 'u2', 'u4', 'u8', 'i1', 'i2', 'i4', 'i8', 'f4', 'f8', 'b1'};
    
    
    magicString = fread(fid, [1 6], 'uint8=>uint8');
    
    if ~all(magicString == [147,78,85,77,80,89])
        error('readNPY:NotNUMPYFile', 'Error: This file does not appear to be NUMPY format based on the header.');
    end
    
    majorVersion = fread(fid, [1 1], 'uint8=>uint8');
    minorVersion = fread(fid, [1 1], 'uint8=>uint8');
    
    npyVersion = [majorVersion minorVersion];
    
    headerLength = fread(fid, [1 1], 'uint16=>uint16');
    
    totalHeaderLength = 10+headerLength;
    
    arrayFormat = fread(fid, [1 headerLength], 'char=>char');
    
    % to interpret the array format info, we make some fairly strict
    % assumptions about its format...
    
    r = regexp(arrayFormat, '''descr''\s*:\s*''(.*?)''', 'tokens');
    dtNPY = r{1}{1};    
    
    littleEndian = ~strcmp(dtNPY(1), '>');
    
    dataType = dtypesMatlab{strcmp(dtNPY(2:3), dtypesNPY)};
        
    r = regexp(arrayFormat, '''fortran_order''\s*:\s*(\w+)', 'tokens');
    fortranOrder = strcmp(r{1}{1}, 'True');
    
    r = regexp(arrayFormat, '''shape''\s*:\s*\((.*?)\)', 'tokens');
    shapeStr = r{1}{1}; 
    arrayShape = str2num(shapeStr(shapeStr~='L'));

    
    fclose(fid);
    
catch me
    fclose(fid);
    rethrow(me);
end
end %func


%--------------------------------------------------------------------------
% 8/15/2018 JJJ: Copyed from npy-matlab
% https://github.com/kwikteam/npy-matlab
function data = readNPY_(filename)
% Function to read NPY files into matlab. 
% *** Only reads a subset of all possible NPY files, specifically N-D arrays of certain data types. 
% See https://github.com/kwikteam/npy-matlab/blob/master/npy.ipynb for
% more. 
%

[shape, dataType, fortranOrder, littleEndian, totalHeaderLength, ~] = readNPYheader_(filename);

if littleEndian
    fid = fopen(filename, 'r', 'l');
else
    fid = fopen(filename, 'r', 'b');
end

try
    
    [~] = fread(fid, totalHeaderLength, 'uint8');

    % read the data
    data = fread(fid, prod(shape), [dataType '=>' dataType]);
    
    if length(shape)>1 && ~fortranOrder
        data = reshape(data, shape(end:-1:1));
        data = permute(data, [length(shape):-1:1]);
    elseif length(shape)>1
        data = reshape(data, shape);
    end
    
    fclose(fid);
    
catch me
    fclose(fid);
    rethrow(me);
end
end %func


%--------------------------------------------------------------------------
% 8/15/2018 JJJ: Copyed from npy-matlab
% https://github.com/kwikteam/npy-matlab
function writeNPY_(var, filename)
% function writeNPY(var, filename)
%
% Only writes little endian, fortran (column-major) ordering; only writes
% with NPY version number 1.0.
%
% Always outputs a shape according to matlab's convention, e.g. (10, 1)
% rather than (10,).

shape = size(var);
dataType = class(var);

header = constructNPYheader_(dataType, shape);

fid = fopen(filename, 'w');
fwrite(fid, header, 'uint8');
fwrite(fid, var, dataType);
fclose(fid);
end %func


%--------------------------------------------------------------------------
% 8/15/2018 JJJ: Copyed from npy-matlab
% https://github.com/kwikteam/npy-matlab
function header = constructNPYheader_(dataType, shape, varargin)

if ~isempty(varargin)
    fortranOrder = varargin{1}; % must be true/false
    littleEndian = varargin{2}; % must be true/false
else
    fortranOrder = true;
    littleEndian = true;
end

dtypesMatlab = {'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double', 'logical'};
dtypesNPY = {'u1', 'u2', 'u4', 'u8', 'i1', 'i2', 'i4', 'i8', 'f4', 'f8', 'b1'};

magicString = uint8([147 78 85 77 80 89]); %x93NUMPY

majorVersion = uint8(1);
minorVersion = uint8(0);

% build the dict specifying data type, array order, endianness, and
% shape
dictString = '{''descr'': ''';

if littleEndian
    dictString = [dictString '<'];
else
    dictString = [dictString '>'];
end

dictString = [dictString dtypesNPY{strcmp(dtypesMatlab,dataType)} ''', '];

dictString = [dictString '''fortran_order'': '];

if fortranOrder
    dictString = [dictString 'True, '];
else
    dictString = [dictString 'False, '];
end

dictString = [dictString '''shape'': ('];

for s = 1:length(shape)
    dictString = [dictString num2str(shape(s))];
    if s<length(shape)
        dictString = [dictString ', '];
    end
end

dictString = [dictString '), '];

dictString = [dictString '}'];

totalHeaderLength = length(dictString)+10; % 10 is length of magicString, version, and headerLength

headerLengthPadded = ceil(double(totalHeaderLength+1)/16)*16; % the whole thing should be a multiple of 16
                                                              % I add 1 to the length in order to allow for the newline character

% format specification is that headerlen is little endian. I believe it comes out so using this command...
headerLength = typecast(int16(headerLengthPadded-10), 'uint8');

zeroPad = zeros(1,headerLengthPadded-totalHeaderLength, 'uint8')+uint8(32); % +32 so they are spaces
zeroPad(end) = uint8(10); % newline character

header = uint8([magicString majorVersion minorVersion headerLength dictString zeroPad]);
end %func


%--------------------------------------------------------------------------
function convert_h5_mda_(vcFile_in, vcDir_out)
% Usage
% -----
% convert-h5-mda mylist.txt output_dir
fOverwrite = 0;
fExclBadSites = 1;

if matchFileEnd_(vcFile_in, '.txt')
    csFiles_h5 = load_batch_(vcFile_in);
elseif matchFileEnd_(vcFile_in, '.h5')
    csFiles_h5 = {vcFile_in};
else
    fprintf(2, 'Invalid file format: %s\n', vcFile_in);
    return;
end

for iFile = 1:numel(csFiles_h5)
    vcFile_h5_ = csFiles_h5{iFile};
    % determine output dir
    [vcDir_, vcFile_, ~] = fileparts(vcFile_h5_);
    if isempty(vcDir_out)
        vcDir_out_ = fullfile(vcDir_, vcFile_);
    else
        vcDir_out_ = fullfile(vcDir_out, vcFile_);
    end    
    mkdir_(vcDir_out_);    
    vcFile_mda_ = fullfile(vcDir_out_, 'raw.mda');
    
    fRead_ = ~exist_file_(vcFile_mda_);
    [mrWav_, S_meta_, S_gt_] = load_h5_(vcFile_h5_, fRead_);    
    mrSiteXY_ = meta2geom_(S_meta_);

    % Exclude sites if viSiteZero not empty    
    viSiteZero = get_(S_meta_, 'viSiteZero');
    if ~isempty(viSiteZero) && fExclBadSites
        if ~isempty(mrWav_), mrWav_(:,viSiteZero) = []; end
        mrSiteXY_(viSiteZero,:) = [];
        nChans = S_meta_.nChans - numel(viSiteZero);
        viMap_chan(setdiff(1:S_meta_.nChans, viSiteZero)) = 1:nChans;        
        S_gt_.viChan = viMap_chan(S_gt_.viChan); % it gets zero if max chan is excluded.        
    end
    
    % Export
    writemda_(mrWav_', vcFile_mda_, fOverwrite);  
    prb2geom_(mrSiteXY_, fullfile(vcDir_out_, 'geom.csv'), 0);
    gt2mda_(S_gt_, fullfile(vcDir_out_, 'firings_true.mda'));
    
    % Write to params.json
    S_json_ = struct('samplerate', S_meta_.sRateHz, 'spike_sign', -1);
    juxta_channel = unique(get_(S_gt_, 'viSite'));
    if numel(juxta_channel)==1, S_json_.juxta_channel = juxta_channel; end
    struct2json_(S_json_, fullfile(vcDir_out_, 'params.json'));
    
    fprintf('Converted %s to %s\n\n', vcFile_h5_, vcDir_out_);    
end
end %func


%--------------------------------------------------------------------------
function mrSiteXY = meta2geom_(S_meta)
% Convert meta struct to siteXY coordinates
nChans = prod(S_meta.probelayout);
[ny, nx] = deal(S_meta.probelayout(1), S_meta.probelayout(2));
[dy, dx] = deal(S_meta.padpitch(1), S_meta.padpitch(2));
mrSiteXY = zeros(nChans, 2);
mrSiteXY(:,1) = repmat((0:nx-1)'*dx, [ny,1]);
mrSiteXY(:,2) = reshape(repmat((0:ny-1)*dy, [nx,1]), nChans,1);
end %func


%--------------------------------------------------------------------------
function export_gt_(vcFile_prm, vcArg2)
P = loadParam_(vcFile_prm);
S_gt = load_(get_(P, 'vcFile_gt'));
if isempty(S_gt)
    fprintf(2, 'No groundtruth found for %s\n', vcFile_prm); 
    return;
end

S_gt = gt2spk_(S_gt, P, [], 1);
disp(S_gt);
assignWorkspace_(S_gt);
end %func


%--------------------------------------------------------------------------
function trWav_full = tnWav_full_(tnWav_spk, S0, viSpk1)
if isempty(S0), S0 = get0_(); end
if nargin<3, viSpk1 = 1:size(tnWav_spk,3); end
    
[viSite_spk, P] = struct_get_(S0, 'viSite_spk', 'P');
viSite_spk1 = viSite_spk(viSpk1);
tnWav_spk1 = tnWav_spk(:,:,viSpk1);
[viSite1_uniq, ~, cviSpk1_uniq] = unique_count_(viSite_spk1);

dimm_full = [size(tnWav_spk,1), size(P.miSites,2), numel(viSpk1)];
trWav_full = nan(dimm_full, 'single');
for iUniq=1:numel(cviSpk1_uniq)
    vi_ = cviSpk1_uniq{iUniq};
    viSite_ = P.miSites(:, viSite1_uniq(iUniq));
    trWav_full(:,viSite_,vi_) = tnWav_spk1(:,:,vi_);
end
end %func


%--------------------------------------------------------------------------
function flag = isaxes_(hAx)
flag = strcmpi(get_(hAx,'Type'), 'axes');
end %func


%--------------------------------------------------------------------------
function update_marker_FigGt_(vhAx, iClu_gt)
for iAx = 1:numel(vhAx);
    hAx_ = vhAx(iAx);
    if ~isaxes_(hAx_), continue; end
    % put a marker
    hLine_ = get_userdata_(hAx_, 'hLine');
    if isempty(hLine_), continue; end
    S_ax_ = hAx_.UserData;
    [x_gt, y_gt] = deal(hLine_.XData(iClu_gt), hLine_.YData(iClu_gt));
    if isempty(get_(S_ax_, 'hMarker'))
        hold(hAx_,'on');
        hMarker = plot(hAx_,x_gt,y_gt,'ro');
        add_userdata_(hAx_, 'hMarker', hMarker);        
    else
       hMarker = S_ax_.hMarker;
       set(hMarker, 'XData', x_gt, 'YData', y_gt);
    end
    uistack(hLine_, 'top');
end %for
end %func


%--------------------------------------------------------------------------
function S_userdata = add_userdata_(h, vcName, val)
try
    S_userdata = h.UserData;
    S_userdata.(vcName)=val;
    set(h, 'UserData', S_userdata);
catch
    S_userdata = [];
end
end %func


%--------------------------------------------------------------------------
function val = get_userdata_(h, vcName, fDelete)
% fDelete: delete the field after retrieving
val = [];
if nargin<3, fDelete = 0; end
try
    S_userdata = get(h, 'UserData');
    if ~isfield(S_userdata, vcName), return; end
    val = S_userdata.(vcName);
    if fDelete
        set(h, 'UserData', rmfield(S_userdata, vcName));
    end
catch
    val = [];
end
end %func


%--------------------------------------------------------------------------
function S_userdata = set_userdata_(h, vcName, val)
% Usage
% -----
% S_userdata = set_userdata_(h, val)
% S_userdata = set_userdata_(h, vcName, val)

if nargin==2
    val = vcName;
    vcName = inputname(2);
end
try
    h.UserData.(vcName) = val;
    S_userdata = get(h, 'UserData');
catch
    S_userdata = [];
end
end %func


%--------------------------------------------------------------------------
function [accuracy, false_pos, false_neg] = clu_score_gt_(viTime_gt, viTime_clu, njitter)
[vl_gt, vl_clu] = time_match2_(viTime_gt, viTime_clu, njitter);
[n1,n2,n3] = deal(sum(~vl_gt), sum(vl_gt), sum(~vl_clu));
[accuracy, false_pos, false_neg] = deal(n2/(n1+n2+n3), n3/(n1+n2), n1/(n1+n2));

[vi1, vi2] = deal(int32(double(viTime_gt)/njitter), int32(double(viTime_clu)/njitter));
% n2_ = count_overlap_(vi1, vi2);
end %func
        

%--------------------------------------------------------------------------
% 9/5/2018 JJJ: Copied from clusterVerify.m
function nOverlap = count_overlap_(viGt, viTest)
viGt_diff = setdiff(setdiff(setdiff(viGt, viTest), viTest+1), viTest-1);
nOverlap = numel(viGt) - numel(viGt_diff);
end %func


%--------------------------------------------------------------------------
% 9/5/2018 JJJ: Copied from clusterVerify.m
function [vlA, vlB, viA1, viB1] = time_match2_(viA, viB, jitter)
% A: ground truth, B: matching unit
if nargin<3, jitter=25; end

if jitter>0
    viA = (double(viA)/jitter);
    viB = (double(viB)/jitter);
end
viA = int32(viA);
viB = int32(viB);
vlA = false(size(viA));
vlB = false(size(viB));
for i1=-1:1
    for i2=-1:1
        vlA = vlA | ismember(viA+i1, viB+i2);
    end
end
if nargout==1, return; end

%viA_match = find(vlA);
viA1 = find(vlA);
viB1 = zeros(size(viA1));
viA11 = viA(viA1);
for iA=1:numel(viA1)
    [~, viB1(iA)] = min(abs(viB - viA11(iA)));
end
vlB(viB1) = 1;
end %func


%--------------------------------------------------------------------------
function [imin, vmin] = find_xy_(vx,vy,x,y)
vx=vx(:); vy=vy(:);
[vx,vy,x,y]=deal(single(vx),single(vy),single(x),single(y));

% xy mixing ration
try
    dx = diff(sort(vx));
    xs = median(dx(dx>0));
    dy = diff(sort(vy));
    ys = median(dy(dy>0));
    r = xs/ys;
catch
    r = [];
end
if isempty(r), r=1; end
[vmin,imin] = min((vx-x).^2+(vy*r-y*r).^2);
end %func


% %--------------------------------------------------------------------------
% function contextmenu_gt_(hLine)
% if numel(hLine)>1
%     for i=1:numel(hLine), contextmenu_gt_(hLine(i)); end
%     return;
% end
% hLine = hLine(1);
% c = uicontextmenu();
% hLine.UIContextMenu = c;
% uimenu(c, 'Label', 'Show Clusters', 'Callback',@(h,e)callback_gt_(h,e,hLine));
% uimenu(c, 'Label', 'Show Waveforms', 'Callback',@(h,e)callback_gt_(h,e,hLine));
% uimenu(c, 'Label', 'Show Features', 'Callback',@(h,e)callback_gt_(h,e,hLine));
% end %func


%--------------------------------------------------------------------------
function plot_gt_(S_score, P)

hFig = figure_new_('Fig_Gt', [.5,0,.5,1]); 
S_fig = makeStruct_(S_score);

set(gcf,'Name',P.vcFile_prm);
% subplot 221; plot_cdf_(S_score.S_score_clu.vrFp); hold on; plot_cdf_(S_score.S_score_clu.vrMiss); 
% legend({'False Positives', 'False Negatives'}); ylabel('CDF'); grid on; xlabel('Cluster count');

S_fig.hAx1 = subplot(3,3,1);
S_fig.hAx2 = subplot(3,3,2);
S_fig.hAx3 = subplot(3,3,3);
S_fig.hAx4 = subplot(3,3,4);
S_fig.hAx5 = subplot(3,3,5);
S_fig.hAx6 = subplot(3,3,6);
S_fig.hAx7 = subplot(3,3,7);
S_fig.hAx8 = subplot(3,3,8);
S_fig.hAx9 = subplot(3,3,9);

hAx_ = S_fig.hAx1;
hold(hAx_,'on'); grid(hAx_,'on'); 
hPlot1 = plot(hAx_, S_score.vrSnr_gt, S_score.S_score_clu.vrFp*100, 'k+');
add_userdata_(hAx_, 'hLine', hPlot1);
vcSnr = sprintf('SNR(%s)', read_cfg_('vcSnr_gt'));
xylabel_(hAx_, vcSnr, 'False Positive (%)', 'Left-click: show best matching cluster only');
hPlot1.ButtonDownFcn = @callback_gt_;

hAx_ = S_fig.hAx2;
hold(hAx_,'on'); grid(hAx_,'on');
hPlot2 = plot(hAx_, S_score.vrSnr_gt, S_score.S_score_clu.vrMiss*100, 'kx');
add_userdata_(S_fig.hAx2, 'hLine', hPlot2);
xylabel_(S_fig.hAx2, vcSnr, 'False Negative (%)', 'Right-click: show best & second-best');
hPlot2.ButtonDownFcn = @callback_gt_;
linkaxes([S_fig.hAx1, S_fig.hAx2], 'x');

hAx_ = S_fig.hAx3;
hold(hAx_,'on'); grid(hAx_,'on');
hPlot3 = plot(hAx_, S_score.S_score_clu.vrMiss*100, S_score.S_score_clu.vrFp*100, 'k.');
add_userdata_(hAx_, 'hLine', hPlot3);
xylabel_(hAx_, 'False Negative (%)', 'False Positive (%)');
hPlot3.ButtonDownFcn = @callback_gt_;
linkaxes([S_fig.hAx1, S_fig.hAx3], 'y');

set(hFig, 'UserData', S_fig);
plot_gt_pair_(S_score.Sgt, S_score.S_overlap, P);
end %func


%--------------------------------------------------------------------------
% 9/6/2018 JJJ: Ground-truth plot case by case inspection
function callback_gt_(hLine, callbackdata)   
hAx = hLine.Parent;
hFig = hAx.Parent;
S_fig = hFig.UserData;

S_score = S_fig.S_score;
[vrXp, vrYp] = deal(hLine.XData, hLine.YData);
xy = get(hAx, 'CurrentPoint');
[xp,yp] = deal(xy(1,1), xy(1,2));
iClu_gt = find_xy_(vrXp, vrYp, xp, yp);
S_ = S_score.S_score_clu;
[snr_gt, snr_sd_gt] = deal(S_score.vrSnr_min_gt(iClu_gt), S_score.vrSnr_sd_gt(iClu_gt));
fShow_clu2 = callbackdata.Button == 3;


% global trFet_spk tnWav_spk
S0 = get0_();
[S_clu, viSite_spk, viSite2_spk, mrPos_spk, viTime_spk, vrAmp_spk, P] = ...
    get_(S0, 'S_clu', 'viSite_spk', 'viSite2_spk', 'mrPos_spk', ...
    'viTime_spk', 'vrAmp_spk', 'P');
trFet_spk = get_spkfet_(P);
tnWav_spk = get_spkwav_(P);
vrAmp_spk = single(abs(vrAmp_spk));
njitter = round(P.sRateHz/1000); % 1 msec
[viSpk_hit_gt, viSpk_miss_gt, viSpk_hit, viSpk_miss, viTime_hit, viTime_miss] = ...
    deal(S_.cviSpk_gt_hit{iClu_gt}, S_.cviSpk_gt_miss{iClu_gt}, ...
        S_.cviSpk_clu_hit{iClu_gt}, S_.cviSpk_clu_miss{iClu_gt}, ...
        S_.cviHit_gt{iClu_gt}, S_.cviMiss_gt{iClu_gt});
[viSite_hit, viSite2_hit] = deal(viSite_spk(viSpk_hit), viSite2_spk(viSpk_hit));
[viSite_miss, viSite2_miss] = deal(viSite_spk(viSpk_miss), viSite2_spk(viSpk_miss));

% Find two best matching clusters
[iClu1, iClu2] = deal(S_score.miCluMatch(1,iClu_gt), S_score.miCluMatch(2,iClu_gt));
[n_clu1, n_clu2] = deal(S_clu.vnSpk_clu(iClu1), S_clu.vnSpk_clu(iClu2));
[viSpk_clu1, viSpk_clu2] = deal(S_clu.cviSpk_clu{iClu1}, S_clu.cviSpk_clu{iClu2});
[iSite_clu1, iSite_clu2] = deal(S_clu.viSite_clu(iClu1), S_clu.viSite_clu(iClu2));
viSpk_clu12 = [viSpk_clu1(:); viSpk_clu2(:)];
viTime_gt = [viTime_hit(:); viTime_miss(:)];
[accu_clu1, fpos_clu1, fneg_clu1] = deal(S_.vrScore(iClu_gt), S_.vrFp(iClu_gt), S_.vrMiss(iClu_gt));
% [accu_clu1, fpos_clu1, fneg_clu1] = clu_score_gt_(viTime_gt, viTime_spk(viSpk_clu1), njitter);
[accu_clu12, fpos_clu12, fneg_clu12] = clu_score_gt_(viTime_gt, viTime_spk(viSpk_clu12), njitter);

f1_ = @(x)round(x*100);
vcTitle = sprintf('GT-clu:#%d(%0.1f/%0.1f)SNR, Clu1:#%d(%d+/%d-)%%, Clu2:#%d(%d+/%d-)%%', ...
    iClu_gt, snr_gt, snr_sd_gt, ...
    iClu1, f1_(fpos_clu1), f1_(fneg_clu1), ...
    iClu2, f1_(fpos_clu12), f1_(fneg_clu12));
update_marker_FigGt_([S_fig.hAx1, S_fig.hAx2, S_fig.hAx3], iClu_gt);
[S_fig.viSpk_hit, S_fig.viSpk_miss, S_fig.viSpk_clu2] = deal(viSpk_hit, viSpk_miss, viSpk_clu2);
hFig.UserData = S_fig;

%----
%# xpos vs ypos
fh_btn_ = @(vx)arrayfun(@(x)set(x, 'ButtonDownFcn', @button_event_gt_), vx);
hAx_ = S_fig.hAx4;
if fShow_clu2
    hPlot_ = plot(hAx_, mrPos_spk(viSpk_clu2,1), mrPos_spk(viSpk_clu2,2), 'k.', ...
        mrPos_spk(viSpk_hit,1), mrPos_spk(viSpk_hit,2), 'b.', ...
        mrPos_spk(viSpk_miss,1), mrPos_spk(viSpk_miss,2), 'r.');
else
    hPlot_ = plot(hAx_, mrPos_spk(viSpk_hit,1), mrPos_spk(viSpk_hit,2), 'b.', ...
        mrPos_spk(viSpk_miss,1), mrPos_spk(viSpk_miss,2), 'r.');
end
grid(hAx_, 'on'); 
xylabel_(hAx_, 'X pos (um)', 'Y pos (um)');
fh_btn_(hPlot_);

%# Time vs ypos
hAx_ = S_fig.hAx5;
if fShow_clu2
    hPlot_ = plot(hAx_, viTime_spk(viSpk_clu2), mrPos_spk(viSpk_clu2,2), 'k.', ...
        viTime_spk(viSpk_hit), mrPos_spk(viSpk_hit,2), 'b.', ...
        viTime_spk(viSpk_miss), mrPos_spk(viSpk_miss,2), 'r.');
else
    hPlot_ = plot(hAx_, viTime_spk(viSpk_hit), mrPos_spk(viSpk_hit,2), 'b.', ...
        viTime_spk(viSpk_miss), mrPos_spk(viSpk_miss,2), 'r.');
end
grid(hAx_, 'on'); 
xylabel_(hAx_, 'Time (adc)', 'Y pos (um)', vcTitle);
fh_btn_(hPlot_);

%# Time vs ampl
hAx_ = S_fig.hAx6;
if fShow_clu2
    hPlot_ = plot(hAx_, viTime_spk(viSpk_clu2), vrAmp_spk(viSpk_clu2), 'k.', ...
        viTime_spk(viSpk_hit), vrAmp_spk(viSpk_hit), 'b.', ...
        viTime_spk(viSpk_miss), vrAmp_spk(viSpk_miss), 'r.');
    legend(hAx_,{'Clu2', 'correct','FP'});
else
    hPlot_ = plot(hAx_, viTime_spk(viSpk_hit), vrAmp_spk(viSpk_hit), 'b.', ...
        viTime_spk(viSpk_miss), vrAmp_spk(viSpk_miss), 'r.');
    legend(hAx_,{'correct','FP'});
end
grid(hAx_, 'on'); 
xylabel_(hAx_, 'Time (adc)', 'Amplitude');
fh_btn_(hPlot_);

%# Ampl vs pos
hAx_ = S_fig.hAx7;
if fShow_clu2
    hPlot_ = plot(hAx_, vrAmp_spk(viSpk_clu2), mrPos_spk(viSpk_clu2,2), 'k.', ...
        vrAmp_spk(viSpk_hit), mrPos_spk(viSpk_hit,2), 'b.', ...
        vrAmp_spk(viSpk_miss), mrPos_spk(viSpk_miss,2), 'r.');
else
    hPlot_ = plot(hAx_, vrAmp_spk(viSpk_hit), mrPos_spk(viSpk_hit,2), 'b.', ...
        vrAmp_spk(viSpk_miss), mrPos_spk(viSpk_miss,2), 'r.');
end
grid(hAx_, 'on'); 
xylabel_(hAx_, 'Amplitude', 'Y pos (um)');
fh_btn_(hPlot_);

%# Waveforms
hAx_ = S_fig.hAx8;
tmrWav_clu1_hit = tnWav_full_(tnWav_spk, S0, viSpk_hit); %randomSelect_(viSpk_hit,100));
tmrWav_clu1_miss = tnWav_full_(tnWav_spk, S0, viSpk_miss); %randomSelect_(viSpk_miss,100));
tmrWav_clu2 = tnWav_full_(tnWav_spk, S0, viSpk_clu2); %randomSelect_(viSpk_clu2,100));
iSite_mode = mode(viSite_spk(viSpk_hit));
viSites_ = P.miSites(:, iSite_mode);
fh_ = @(x)zscore(nanmean(reshape(x(:,viSites_,:),[],size(x,3)),2));
[mrWav_clu1_hit, mrWav_clu1_miss, mrWav_clu2] = ...
deal(fh_(tmrWav_clu1_hit), fh_(tmrWav_clu1_miss), fh_(tmrWav_clu2));
vrT_ = (1:size(mrWav_clu2,1))/P.sRateHz*1000;
fh_nan_ = @(x)ifeq_(isempty(x), nan(size(vrT_)), x);
if fShow_clu2
    hPlot_ = plot(hAx_, vrT_, fh_nan_(mrWav_clu1_hit), 'b-', ...
        vrT_, fh_nan_(mrWav_clu2), 'k--', ...            
        vrT_, fh_nan_(mrWav_clu1_miss), 'r-');
else
    hPlot_ = plot(hAx_, vrT_, fh_nan_(mrWav_clu1_hit), 'b-', ...
        vrT_, fh_nan_(mrWav_clu1_miss), 'r-');
end
grid(hAx_, 'on'); 
xylabel_(hAx_, 'Time (ms)', 'Ampl (norm)');
fh_btn_(hPlot_);

%# Features
hAx_ = S_fig.hAx9;
mrFet_clu1_hit = trFet_full_(trFet_spk, S0, viSpk_hit)'; %randomSelect_(viSpk_hit,100));
mrFet_clu1_miss = trFet_full_(trFet_spk, S0, viSpk_miss)'; %randomSelect_(viSpk_miss,100));
mrFet_clu2 = trFet_full_(trFet_spk, S0, viSpk_clu2)'; %randomSelect_(viSpk_clu2,100));
[~,viSite_sort] = sort(nanmean(abs(mrFet_clu1_hit)),'descend');
[iSite1,iSite2,iSite3]=deal(viSite_sort(1), viSite_sort(2), viSite_sort(3));
if fShow_clu2
    hPlot_ = plot3(hAx_, mrFet_clu2(:,iSite1), mrFet_clu2(:,iSite2), mrFet_clu2(:,iSite3), 'k.', ...
        mrFet_clu1_hit(:,iSite1), mrFet_clu1_hit(:,iSite2), mrFet_clu1_hit(:,iSite3), 'b.', ...
        mrFet_clu1_miss(:,iSite1), mrFet_clu1_miss(:,iSite2), mrFet_clu1_miss(:,iSite3), 'r.');
else
    hPlot_ = plot3(hAx_, mrFet_clu1_hit(:,iSite1), mrFet_clu1_hit(:,iSite2), mrFet_clu1_hit(:,iSite3), 'b.', ...
        mrFet_clu1_miss(:,iSite1), mrFet_clu1_miss(:,iSite2), mrFet_clu1_miss(:,iSite3), 'r.');
end
grid(hAx_, 'on');
xylabel_(hAx_, 'feature-site1', 'feature-site2');                
fh_btn_(hPlot_);

if callbackdata.Button == 2 %wheel pressed
    vi1 = (S_clu.viClu_premerge(viSpk_clu1));
    vi2 = (S_clu.viClu_premerge(viSpk_clu2));
    myfig; plot(sort(vi1),'b.');plot(sort(vi2),'r.')
end
end %func


%--------------------------------------------------------------------------
function plot_gt_pair_(S_gt, S_overlap, P)
% for now works for static case
hMsg = msgbox('Wait...', 'modal');
if nargin<3, P = get0_('P'); end
S_cfg = read_cfg_();
[vpOverlap_gt, vnSpk_gt, mnSpk_gt, cmnDTime_gt, cmiTime_gt, mrDist_gt, cviTime_gt] = ...
    struct_get_(S_overlap, 'vpOverlap_gt', 'vnSpk_gt' ,'mnSpk_gt', 'cmnDTime_gt', 'cmiTime_gt', 'mrDist_gt', 'cviTime_gt');
mnWav_raw = load_file_(P.vcFile, [], P);
[mnWav_filt, ~] = filt_car_(mnWav_raw, P);

S_fig = makeStruct_(cmiTime_gt, S_gt, mrDist_gt, cmnDTime_gt, ...
    vpOverlap_gt, vnSpk_gt, mnSpk_gt, mnWav_filt, mnWav_raw, cviTime_gt);

% Show image square
hFig = figure_new_('Fig_Gt_Pair', [.5 0 .5 1]);
set(hFig,'Name',P.vcFile_prm);
S_fig.hAx1 = subplot(331);
S_fig.hAx2 = subplot(332);
S_fig.hAx3 = subplot(333);
S_fig.hAx4 = subplot(3,3,4);
S_fig.hAx5 = subplot(3,3,5);
S_fig.hAx6 = subplot(3,3,6);
S_fig.hAx7 = subplot(3,3,7);
S_fig.hAx8 = subplot(3,3,8);
S_fig.hAx9 = subplot(3,3,9);
linkaxes([S_fig.hAx3,S_fig.hAx5],'y');
linkaxes([S_fig.hAx5,S_fig.hAx6,S_fig.hAx8,S_fig.hAx9],'xy');

hAx1 = S_fig.hAx1;
hImg = imagesc(hAx1,mnSpk_gt); 
xylabel_(hAx1,'GT-Clu#', 'GT-Clu#', ['Colliding spikes (click to show waveforms)']);
grid(hAx1, 'on');
hold(hAx1, 'on');
hImg.ButtonDownFcn = @(h,e)button_FigGtPair_(h,e);
S_fig.hImg = hImg;

hAx2 = S_fig.hAx2;
axes(hAx2);
cdfplot(vpOverlap_gt);
xylabel_(hAx2,'Fraction of overlapping spikes (0..1)', 'CDF', ...
    sprintf('[%0.1f:%0.1f]ms, %0.1fum', S_cfg.maxTime_ms_gt, S_cfg.maxDist_um_gt));

set(hFig, 'UserData', S_fig);
close_(hMsg);
msgbox('Click on the image matrix to view the collided waveforms. You may use left,mid,right buttons)', 'modal');
end %func


%--------------------------------------------------------------------------
function S_overlap = analyze_overlap_(S_gt, S_cfg, P)
if nargin<2, S_cfg = []; end
if nargin<3, P = []; end
if isempty(S_cfg), S_cfg = read_cfg_(); end
if isempty(P), P = get0_('P'); end

maxTime_ms_gt = get_set_(S_cfg, 'maxTime_ms_gt', 1);
maxDist_um_gt = get_set_(S_cfg, 'maxDist_um_gt', 50);
sRateHz = get_(P, 'sRateHz');
thresh_tlim = round(sRateHz / 1000 * maxTime_ms_gt);
if numel(thresh_tlim)==1, thresh_tlim = [0,thresh_tlim]; end

nClu_gt = max(S_gt.viClu);
cviSpk_gt = arrayfun(@(iClu)int32(find(S_gt.viClu == iClu)), 1:nClu_gt, 'UniformOutput', 0);
cviTime_gt = cellfun(@(x)S_gt.viTime(x), cviSpk_gt, 'UniformOutput', 0); % don't do if same as S_gt.cviTime_gt

% Find time collision between cluster pairs
[cmiTime_gt, cmnDTime_gt] = deal(cell(nClu_gt, nClu_gt));
cvnOverlap_gt = cell(1, nClu_gt);
mrDist_gt = squareform(pdist(P.mrSiteXY(S_gt.viSite_clu,:)));
fh_lim_ = @(x,lim)x>=lim(1) & x<=lim(2);
for iGt1 = 1:nClu_gt
    viTime1_ = cviTime_gt{iGt1};
    iSite1 = S_gt.viSite_clu(iGt1);
    viGt2_ = find(mrDist_gt(1:iGt1-1,iGt1) <= maxDist_um_gt);
    % Find the closest spike that is colliding
    vn_ = zeros(size(viTime1_)); % keep track of colliding spikes
    for iGt2 = viGt2_(:)'
        viTime2_ = cviTime_gt{iGt2};
        mnD12_ = abs(bsxfun(@minus,viTime2_(:), viTime1_(:)'));
        [~, viMin21_] = min(mnD12_,[],1);
        [~, viMin12_] = min(mnD12_,[],2);
        vnDTime1_ = viTime2_(viMin21_) - viTime1_;
        vnDTime2_ = viTime1_(viMin12_) - viTime2_;
        vl21_ = fh_lim_(vnDTime1_, thresh_tlim);
        vl12_ = fh_lim_(vnDTime2_, thresh_tlim);
        cmiTime_gt{iGt2, iGt1} = viTime1_(vl21_);
        cmiTime_gt{iGt1, iGt2} = viTime2_(vl12_);
        cmnDTime_gt{iGt2, iGt1} = vnDTime1_(vl21_);
        cmnDTime_gt{iGt1, iGt2} = vnDTime2_(vl12_);
        vn_(vl21_) = vn_(vl21_) + 1; % count overlapping spikes. isi dist?
    end
    cvnOverlap_gt{iGt1} = vn_;
end %for
mnSpk_gt = cellfun(@numel,cmiTime_gt);
vnSpk_gt = arrayfun(@(x)sum(S_gt.viClu==x), 1:max(S_gt.viClu));
vpOverlap_gt = sum(mnSpk_gt) ./ vnSpk_gt;

S_overlap = makeStruct_(vpOverlap_gt, vnSpk_gt, mnSpk_gt, mrDist_gt, ...
    cmnDTime_gt, cmiTime_gt, cviTime_gt, cvnOverlap_gt, ...
    maxTime_ms_gt, maxDist_um_gt, sRateHz);
end %func


%--------------------------------------------------------------------------
% 9/9/2018 JJJ: FigGtPair click update func. Not differentiating left/right
% clicks
function button_FigGtPair_(h,e)
P = get0_('P');
[nInterp, fNormalize, fAlign, fSubtract] = deal(2, 0, 1, 1);
% [nInterp, fNormalize, fAlign, fSubtract] = deal(0, 0, 0, 1);
spkLim = round(P.sRateHz/1000 * [-1,1]);

xy = round(e.IntersectionPoint(1:2));
hAx1 = h.Parent;
hFig = hAx1.Parent;
S_fig = hFig.UserData;
[iClu1,iClu2]=deal(xy(1),xy(2));
[viTime12, viTime21] = deal(S_fig.cmiTime_gt{iClu1,iClu2}, S_fig.cmiTime_gt{iClu2,iClu1});
[vnDTime12, vnDTime21] = deal(S_fig.cmnDTime_gt{iClu1,iClu2}, S_fig.cmnDTime_gt{iClu2,iClu1});
title(hAx1, sprintf('Clu1:%d, Clu2:%d, n12=%d, d12=%0.1f(um)', ...
    iClu1, iClu2, numel(viTime12), S_fig.mrDist_gt(iClu1, iClu2)));
nClu = size(S_fig.cmiTime_gt,1);
plot_line_(hAx1, 'hLine1', iClu1+[-.5,-.5,nan,.5,.5], [1,nClu,nan,1,nClu], 'k-');
plot_line_(hAx1, 'hLine2', [1,nClu,nan,1,nClu], iClu2+[-.5,-.5,nan,.5,.5], 'r-');
axis(hAx1, [iClu1-10, iClu1+10, iClu2-10, iClu2+10]);
arrayfun(@cla, [S_fig.hAx3, S_fig.hAx4, S_fig.hAx5, S_fig.hAx6, S_fig.hAx7, S_fig.hAx8, S_fig.hAx9]);
S_gt = S_fig.S_gt;

hAx_ = S_fig.hAx3;
[iSite1, iSite2] = deal(S_gt.viSite_clu(iClu1), S_gt.viSite_clu(iClu2));
vhPlot = plot(hAx_,nan,nan,'k-',nan,nan,'r-');
scale_ = P.maxAmp * 2^(P.nDiff_filt-1);
% [mrWav_gt1, mrWav_gt2] = deal(S_gt.trWav_clu(:,:,iClu1), S_gt.trWav_clu(:,:,iClu2));
fh_ = @(x)single(permute(mn2tn_gpu_(S_fig.mnWav_filt, spkLim, x), [1,3,2])) * P.uV_per_bit;
[trWav_gt1, trWav_gt2] = deal(fh_(S_fig.cviTime_gt{iClu1}), fh_(S_fig.cviTime_gt{iClu2}));
% [trWav_gt1, trWav_gt2] = deal(align_tr_(trWav_gt1, iSite1), align_tr_(trWav_gt2, iSite2));
% [mrWav_gt1, mrWav_gt2] = deal(mean(trWav_gt1,3), mean(trWav_gt2,3));
[mrWav_gt1, mrWav_gt2] = deal(tr2mr_template_(trWav_gt1), tr2mr_template_(trWav_gt2));
vrT_ = (1:size(mrWav_gt1,1)) / P.sRateHz * 1000;
multiplot(vhPlot(1), scale_, vrT_, mrWav_gt1);
multiplot(vhPlot(2), scale_, vrT_, mrWav_gt2);
grid(hAx_,'on');
set(hAx_, 'XLim', [.5, 1.5]);
xylabel_(hAx_, 'Time (ms)', 'Site#', sprintf('Cluster waveform template, GT-Clu#: (black:%d/red:%d)', iClu1, iClu2));

if isempty(viTime12) || isempty(viTime21), return; end

hWait = msgbox('wait...', 'modal');
[trWav_spk12, trWav_spk21] = multifun_(fh_, viTime12, viTime21);

if nInterp>1
    [trWav_spk12, trWav_spk21] = multifun_(@(x)interpft_(x, nInterp), trWav_spk12, trWav_spk21);
    [mrWav_gt1, mrWav_gt2] = multifun_(@(x)interpft_(x, nInterp), mrWav_gt1, mrWav_gt2);
    sRateHz = P.sRateHz * nInterp;
else
    sRateHz = P.sRateHz;
end
if fNormalize
    [trWav_spk12, trWav_spk21] = multifun_(@(x)norm_min_tr_(x, iSite2), trWav_spk12, trWav_spk21);
    scale_ = 1;
end
if fAlign
    [trWav_spk12, trWav_spk21] = multifun_(@(x)align_tr_(x, iSite2), trWav_spk12, trWav_spk21);
end

for fSubtract=0:1    
    if fSubtract
        switch e.Button
            case 1
                [trWav_spk21, trWav_spk12] = deal(subt_template_(trWav_spk21, mrWav_gt1), subt_template_(trWav_spk12, mrWav_gt2));
                vcSubt = 'subtract single';
            case 2
                P_ = struct_add_(P, vnDTime12, vnDTime21);
                [trWav_spk21, trWav_spk12] = subt_overlap_(trWav_spk21, trWav_spk12, mrWav_gt1, mrWav_gt2, P_);
                vcSubt = 'subtract overlap-1amp';
            case 3
                P_ = struct_add_(P, vnDTime12, vnDTime21);
                [trWav_spk21, trWav_spk12] = subt_overlap2_(trWav_spk21, trWav_spk12, mrWav_gt1, mrWav_gt2, P_);                
                vcSubt = 'subtract overlap-2amp'; %provide dt and let it search optimal ampl ratio
        end            
    else
        vcSubt = 'subtract none';
    end
    
    hAx_ = ifeq_(~fSubtract, S_fig.hAx4, S_fig.hAx7);
    cvr_proj = cellfun(@(x,y)project_tr_mr_(x,y), ...
        {trWav_spk21, trWav_spk21, trWav_spk12, trWav_spk12}, ... 
        {mrWav_gt1, mrWav_gt2, mrWav_gt1, mrWav_gt2}, 'UniformOutput', 0);
    [vr11,vr12,vr21,vr22] = deal(cvr_proj{:});
    plot(hAx_, vr11, vr12, 'k.', vr21, vr22, 'r.');
    grid(hAx_, 'on');
    xylabel_(hAx_, 'GT-Clu1','GT-Clu2', vcSubt);

    hAx_ = ifeq_(~fSubtract, S_fig.hAx5, S_fig.hAx8);
    nSites = size(trWav_spk21,2);
    vrT_ = (1:size(trWav_spk21,1)) / sRateHz * 1000;
    hPlot_ = plot(hAx_,nan,nan,'k-');
    multiplot(hPlot_, scale_, vrT_, trWav_spk21);
    xylabel_(hAx_, 'Time (ms)', 'Site#', sprintf('Clu#:%d, %s', iClu1, vcSubt));
    grid(hAx_,'on');
    set(hAx_, 'YLim', [-3.5,3.5]+(iSite1+iSite2)/2, 'XLim', [.5,1.5]);

    hAx_ = ifeq_(~fSubtract, S_fig.hAx6, S_fig.hAx9);
    hPlot_ = plot(hAx_,nan,nan,'r-');
    multiplot(hPlot_, scale_, vrT_, trWav_spk12);
    xylabel_(hAx_, 'Time (ms)', 'Site#', sprintf('Clu#:%d, %s', iClu2, vcSubt));
    grid(hAx_,'on');
    set(hAx_, 'YLim', [-3.5,3.5]+(iSite1+iSite2)/2, 'XLim', [.5,1.5]);
end
close_(hWait);
end %func


%--------------------------------------------------------------------------
% 9/13/2018 JJJ: Analyze bursting spikes, assign burst number for each
% ground-truth cluster
function cvnBurst_clu = analyze_burst_(viTime, viClu, S_cfg)
% Usage
% ------
% viTime: spike time index for each spikes, dimm:[1, nSpikes]
% viClu: Cluster number for each spike, dimm:[1,nSpikes]
% cvnBurst_clu: cell of vector of integers (cvn) containing burst indices
%   Burst index: 0: first spike, 1: second spike in the burst group, 2:
%   third spike in the burst group, ...
%
% parameters
% -----
% max_n_burst: max. number of burst index to track in the burst group
% interval_ms_burst: max. inter-spike interval in ms to be considered as a
% burst
if nargin<3, S_cfg = []; end
if isempty(S_cfg), S_cfg = read_cfg_(); end
[max_n_burst, interval_ms_burst]  = struct_get_(S_cfg, 'max_n_burst', 'interval_ms_burst');
% [max_n_burst, interval_ms_burst] = deal(9, 20); % nBurst: max burst group, burst_ms: isi limit

nClu = max(viClu);
cviTime_clu = arrayfun(@(x)viTime(viClu==x), 1:max(viClu), 'UniformOutput',0);
try
    P = get0_(P);
    sRateHz = P.sRateHz;
catch
    sRateHz = 20000;
end
dn_burst = round(sRateHz * interval_ms_burst / 1000);

vnBurst_clu = zeros(nClu,1);
cvnBurst_clu = cell(nClu,1);
for iClu=1:nClu
    viTime_ = cviTime_clu{iClu};
    nSpk_ = numel(viTime_);
    vnBurst_ = [0; diff(viTime_(:)) <= dn_burst];
    vnBurst_clu(iClu) = sum(vnBurst_);
    for iBurst=1:max_n_burst
        vi_ = find(vnBurst_(1:end-1) == iBurst & vnBurst_(2:end) > 0) + 1;
        vnBurst_(vi_) = vnBurst_(vi_) + 1;
    end
    cvnBurst_clu{iClu} = vnBurst_;
end %for
end %func


%--------------------------------------------------------------------------
function mr_template = tr2mr_template_(tr)
% build template from tr by taking half the self-consistent populations
% use normdist to subselect population
mr_mean = mean(tr,3);
[~,iSite1] = min(min(mr_mean),[],2);
mr1_ = squeeze_(tr(:,iSite1,:));
vrA1 = -min(mr1_);
mr1_ = bsxfun(@rdivide, mr1_, vrA1);
% mr_ = bsxfun(@rdivide, reshape(tr,[],size(tr,3)), vrA1); % normalized, all sites

% selection based on shape matching
vr1_med = median(mr1_,2); % simplest approach but time delays can cause problem
vrDist_med = std(bsxfun(@minus, mr1_, vr1_med));
vlKeep = vrDist_med < median(vrDist_med);

mr_template = mean(tr(:,:,vlKeep),3);

% trFft = fft(tr(:,:,vlKeep));
% mrPow = mean(abs(trFft),3);
% mrAngle = median(angle(trFft),3);
% mrFft = mrPow .* cos(mrAngle) + sqrt(-1) .* mrPow .* sin(mrAngle);
% mr_template = real(ifft(mrFft));

% plot to confirm
if nargout==0
    mr1_ = bsxfun(@rdivide, squeeze_(tr(:,iSite1,:)), vrA1);
    figure; plot(mr1_, 'k');
    figure; plot(mr1_(:,vlKeep),'r');
end
end %func 

%--------------------------------------------------------------------------
function plot_line_(hAx1, vcName, vrX, vrY, vcLine)
if nargin<5, vcLine=[]; end
[vrX, vrY] = deal(vrX(:), vrY(:));
if isempty(get_userdata_(hAx1, vcName))
    if isempty(vcLine)
        hLine1 = plot(hAx1, vrX, vrY);
    else
        hLine1 = plot(hAx1, vrX, vrY, vcLine);
    end
    add_userdata_(hAx1, vcName, hLine1);
else
    hLine1 = get_userdata_(hAx1, vcName);
    set(hLine1, 'XData',vrX,'YData',vrY);
end
end %func


%--------------------------------------------------------------------------
function [trWav1, trWav2] = subt_overlap_(trWav1, trWav2, mrWav_gt1, mrWav_gt2, P)
if nargin<5, P = get0_('P'); end

nShift = round(size(mrWav_gt1,1) * .2);
[fIntercept, fUseDTime] = deal(0, 0);

[iSite1, viSite1] = wav2sites_(mrWav_gt1, P);
[iSite2, viSite2] = wav2sites_(mrWav_gt2, P);

mrWav_spk21 = reshape(trWav1(:,viSite1,:), [], size(trWav1,3));
mrWav_spk12 = reshape(trWav2(:,viSite2,:), [], size(trWav2,3));
dimm_ = [size(trWav1,1), numel(viSite1)];

if fUseDTime
    [vnDTime12, vnDTime21] = struct_get_(P, 'vnDTime12', 'vnDTime21');
    for iSpk1 = 1:size(trWav1,3)
        nShift1 = vnDTime21(iSpk1);
        vr_ = toCol_(mrWav_gt1(:,viSite1) + shift_mr_(mrWav_gt2(:,viSite1), nShift1));
        mr_ = reshape(vr_ * (vr_ \ mrWav_spk21(:,iSpk1)), dimm_);
        trWav1(:,viSite1,iSpk1) = trWav1(:,viSite1,iSpk1) - mr_;
    end
    for iSpk2 = 1:size(trWav2,3)
        nShift2 = vnDTime12(iSpk2);
        vr_ = toCol_(mrWav_gt2(:,viSite2) + shift_mr_(mrWav_gt1(:,viSite2), nShift2));
        mr_ = reshape(vr_ * (vr_ \ mrWav_spk12(:,iSpk2)), dimm_);
        trWav2(:,viSite2,iSpk2) = trWav2(:,viSite2,iSpk2) - mr_;
    end
else    
    [ccmrWav_overlap, mnShift1, mnShift2] = makeOverlap_(mrWav_gt1, mrWav_gt2, nShift);
    mrWav_overlap1 = cell2mat(cellfun(@(x)toVec(x(:,viSite1)), ccmrWav_overlap(:)', 'UniformOutput', 0));
    mrWav_overlap2 = cell2mat(cellfun(@(x)toVec(x(:,viSite2)), ccmrWav_overlap(:)', 'UniformOutput', 0));
    [xx,yy] = meshgrid(1:size(mrWav_spk21,2), 1:size(mrWav_overlap1,2));
    [vrMin1_, viMin1_] = min(arrayfun(@(x,y) vr_fit_rms_(mrWav_spk21(:,x), mrWav_overlap1(:,y), fIntercept), xx, yy));
    [vrMin2_, viMin2_] = min(arrayfun(@(x,y) vr_fit_rms_(mrWav_spk12(:,x), mrWav_overlap2(:,y), fIntercept), xx, yy));

    % subtract scaled version of the overlap template
    for iSpk1 = 1:size(trWav1,3)
        vr_ = mrWav_overlap1(:,viMin1_(iSpk1));
        mr_ = reshape(vr_ * (vr_ \ mrWav_spk21(:,iSpk1)), dimm_);
        trWav1(:,viSite1,iSpk1) = trWav1(:,viSite1,iSpk1) - mr_;
    end
    for iSpk2 = 1:size(trWav2,3)
        vr_ = mrWav_overlap2(:,viMin2_(iSpk2));
        mr_ = reshape(vr_ * (vr_ \ mrWav_spk12(:,iSpk2)), dimm_);
        trWav2(:,viSite2,iSpk2) = trWav2(:,viSite2,iSpk2) - mr_;
    end
end
end %func


%--------------------------------------------------------------------------
% 9/11/2018 JJJ: find adjacent sites to the negative peak site
function [iSite1, viSite1] = wav2sites_(mrWav_gt1, P)
% mrWav_gt1: nSamples x nSites

if nargin<2, P=[]; end
[~, iSite1] = min(min(mrWav_gt1),[],2);
if nargout>=2
    if isempty(P), P = get0_('P'); end
    viSite1 = P.miSites(:,iSite1);
end
end %func


%--------------------------------------------------------------------------
function [trWav1, trWav2] = subt_overlap2_(trWav1, trWav2, mrWav_gt1, mrWav_gt2, P)
nShift = round(size(trWav1,1) * .2);
[fIntercept, fUseDTime, fTrim] = deal(0,0,1);

[~, iSite1] = min(min(mrWav_gt1),[],2);
[~, iSite2] = min(min(mrWav_gt2),[],2);
[viSite1, viSite2] = deal(P.miSites(:,iSite1), P.miSites(:,iSite2));

if fTrim
    viT = round(size(trWav1,1)*.25):round(size(trWav1,1)*.75);
    mrWav_gt21_ = makeShift_(mrWav_gt2(:,viSite1), nShift);
    mrWav_gt12_ = makeShift_(mrWav_gt1(:,viSite2), nShift);   
    
    tr_ = reshape(mrWav_gt21_, [], numel(viSite1), 2*nShift+1);
    mrWav_gt21_ = reshape(tr_(viT,:,:), [], size(tr_,3));
    
    tr_ = reshape(mrWav_gt12_, [], numel(viSite2), 2*nShift+1);
    mrWav_gt12_ = reshape(tr_(viT,:,:), [], size(tr_,3));    
else
    viT = 1:size(trWav1,1);
    mrWav_gt21_ = makeShift_(mrWav_gt2(viT,viSite1), nShift);
    mrWav_gt12_ = makeShift_(mrWav_gt1(viT,viSite2), nShift);    
end
mrWav_spk21 = reshape(trWav1(viT,viSite1,:), [], size(trWav1,3));
mrWav_spk12 = reshape(trWav2(viT,viSite2,:), [], size(trWav2,3));
[vrWav_gt1_, vrWav_gt2_] = deal(toCol_(mrWav_gt1(viT,viSite1)), toCol_(mrWav_gt2(viT,viSite2)));

[xx1,yy1] = meshgrid(1:size(mrWav_spk21,2), 1:size(mrWav_gt21_,2));
[vrMin1_, viMin1_] = min(arrayfun(@(x,y) mr_fit_rms_(mrWav_spk21(:,x), [vrWav_gt1_, mrWav_gt21_(:,y)], fIntercept), xx1, yy1));

[xx2,yy2] = meshgrid(1:size(mrWav_spk12,2), 1:size(mrWav_gt12_,2));
[vrMin2_, viMin2_] = min(arrayfun(@(x,y) mr_fit_rms_(mrWav_spk12(:,x), [vrWav_gt2_, mrWav_gt12_(:,y)], fIntercept), xx2, yy2));

% subtract scaled version of the overlap template
dimm_ = [numel(viT), numel(viSite1)];
for iSpk1 = 1:size(trWav1,3)
    mr0_ = [vrWav_gt1_, mrWav_gt21_(:,viMin1_(iSpk1))];
    mr_fit_ = reshape(mr0_ * (mr0_ \ mrWav_spk21(:,iSpk1)), dimm_);
    trWav1(viT,viSite1,iSpk1) = trWav1(viT,viSite1,iSpk1) - mr_fit_;
end
for iSpk2 = 1:size(trWav2,3)
    mr0_ = [vrWav_gt2_, mrWav_gt12_(:,viMin2_(iSpk2))];
    mr_fit_ = reshape(mr0_ * (mr0_ \ mrWav_spk12(:,iSpk2)), dimm_);
    trWav2(viT,viSite2,iSpk2) = trWav2(viT,viSite2,iSpk2) - mr_fit_;
end
end %func


%--------------------------------------------------------------------------
function [ccmrWav_overlap, mnShift1, mnShift2] = makeOverlap_(mr1, mr2, nShift)
dimm1 = size(mr1);
n = numel(mr1);
mi = bsxfun(@plus, (1:n)', -nShift:nShift);
mi(mi<1) = 1;
mi(mi>n) = n;

[mr1_shift, mr2_shift] = deal(mr1(mi), mr2(mi));
ccmrWav_overlap = cell(nShift*2+1);
[mnShift1, mnShift2] = meshgrid(-nShift:nShift);

for i1=1:size(ccmrWav_overlap,2)
    mr12_ = bsxfun(@plus, mr2_shift, mr1_shift(:,i1));
    for i2=1:size(ccmrWav_overlap,1)
        ccmrWav_overlap{i2,i1} = reshape(mr12_(:,i2), dimm1);
    end
end
end %func


%--------------------------------------------------------------------------
function [mr_shift, vnShift] = makeShift_(vr, nShift)
n = numel(vr);
vnShift = -nShift:nShift;
mi = bsxfun(@plus, (1:n)', vnShift);
mi(mi<1) = 1;
mi(mi>n) = n;

mr_shift = vr(mi);
vnShift = -nShift:nShift;
end %func


%--------------------------------------------------------------------------
function tr = subt_template_(tr, mr0)
% subtract template, pick lowest RMS
% mr0: reference template
% fScale_fit = 1;
% fAllSites = 0;
% fShift = 1;
fTrim = 1;

nShift = round(size(mr0,1) * .2);
P = get0_('P');
[~,iSite1] = min(min(mr0),[],2);
viSite1 = P.miSites(:,iSite1);

[mr0_shift, vnShift] = makeShift_(toCol_(mr0(:,viSite1)), nShift);
if fTrim
    viT = round(size(tr,1)*.25):round(size(tr,1)*.75);
    tr_ = reshape(mr0_shift, [], numel(viSite1), numel(vnShift));
    mr0_shift = reshape(tr_(viT,:,:), [], size(tr_,3));
else
    viT = 1:size(tr,1);    
end
mr_ = reshape(tr(viT,viSite1,:), [], size(tr,3));
[xx,yy] = meshgrid(1:size(mr_,2), 1:size(mr0_shift,2));
[vrMin, viMin] = min(arrayfun(@(x,y)vr_fit_rms_(mr_(:,x), mr0_shift(:,y)), xx, yy));
dimm1 = [numel(viT), numel(viSite1)];

for iSpk = 1:size(tr,3)
    vr0_ = mr0_shift(:,viMin(iSpk));
    mr_fit_ = reshape(vr0_ * (vr0_ \ mr_(:,iSpk)), dimm1);
    tr(viT,viSite1,iSpk) = tr(viT,viSite1,iSpk) - mr_fit_;
end
% fit slope and intersect
% if fScale_fit
%     mr_ = reshape(tr,[],size(tr,3));
%     if ~fAllSites
%         [~,iSite] = min(min(mr0),[],2);            
%         mr1 = squeeze_(tr(:,iSite,:));    
%         [vrA, vrB, mrFit_] = linfit_(mr1, mr0(:,iSite));
%         mr_fit = bsxfun(@times, mr0(:), vrA(:)'); % subtract offset as well
%     else
%         [~,~,mr_fit] = linfit_(mr_, mr0(:));
%     end
%     tr = reshape(mr_ - mr_fit, size(tr));
% else
%     tr = reshape(bsxfun(@minus, mr_, mr0(:)), size(tr));
end %func


%--------------------------------------------------------------------------
function [vrA, vrB, mrY_fit] = linfit_(mrY, vrX)
% fit mrY using a * vrX + b model
% m = size(mr,2); % # obs
% n = size(mr,1); % # param
% Y = XX * ab
% XX \ Y = XX \ XX * ab
% XX \ Y = ab
% Y: [n, m]
% ab: [2, m]
% X: [n, 2]
X = vrX(:);
XX = [X, ones(size(X))];
vrAB = (XX \ mrY)';
vrA = vrAB(:,1);
vrB = vrAB(:,2);
if nargout>=3
    mrY_fit = XX * vrAB';
end
end %func


%--------------------------------------------------------------------------
function [rms, vrFit] = vr_fit_rms_(vr, vr_fit, fIntercept)
if nargin<3, fIntercept = 0; end

X = [vr_fit(:)];
if fIntercept, X = [X, ones(size(X))]; end
vrFit = X * (X \ vr(:));

vrDiff = vr - vrFit;
% rms = median(abs(vrDiff-median(vrDiff)));
rms = std(vr-vrFit);
end %func


%--------------------------------------------------------------------------
function [rms, vrFit] = mr_fit_rms_(vr, mr_fit, fIntercept)
if nargin<3, fIntercept = 0; end

X = mr_fit;
if fIntercept, X = [X, ones(size(X))]; end
vrFit = X * (X \ vr(:));

vrDiff = vr - vrFit;
% rms = median(abs(vrDiff-median(vrDiff)));
rms = std(vr-vrFit);
end %func


%--------------------------------------------------------------------------
function vr = project_tr_mr_(tr,mr,fMeanSubt)
if nargin<3, fMeanSubt = 0; end
if fMeanSubt
    tr = meanSubt_(tr);
    mr = meanSubt_(mr);
end
mr_ = reshape(tr, [], size(tr,3));
vr_ = mr(:);
vr_ = vr_(:) / std(vr_(:),1);
vr = mean(bsxfun(@times, mr_, vr_));
end %func


%--------------------------------------------------------------------------
function trWav_spk = align_tr_(trWav_spk, iSite)
% trWav: nSamples x nChan x nSpk
mrWav = squeeze_(trWav_spk(:,iSite,:));
[~,viMin] = min(mrWav);
iMin0 = mode(viMin);
vnShift_spk = iMin0 - viMin;
for iSpk1 = 1:numel(vnShift_spk)
    nShift_ = vnShift_spk(iSpk1);
    if nShift_ == 0, continue; end
    trWav_spk(:,:,iSpk1) = shift_mr_(trWav_spk(:,:,iSpk1), nShift_);
end %for
end %func


%--------------------------------------------------------------------------
function trWav = norm_min_tr_(trWav, iSite_min)
dimm = size(trWav);
vrA = -squeeze_(min(trWav(:,iSite_min,:)));
trWav = reshape(bsxfun(@rdivide, reshape(trWav, [], dimm(3)), vrA(:)'), dimm);
end %func
    

%--------------------------------------------------------------------------
% only works for dimension of 1 for now
function mrFet_full = trFet_full_(trFet_spk, S0, viSpk1)
% trFet_spk: (nSite x nF_chan) x 2 x nSpk
% return the first component

if isempty(S0), S0 = get0_(); end
[viSite_spk, viSite2_spk, P] = struct_get_(S0, 'viSite_spk', 'viSite2_spk', 'P');
mrFet_spk1 = squeeze_(trFet_spk(:,1,viSpk1));
mrFet2_spk1 = squeeze_(trFet_spk(:,2,viSpk1));
nF_chan = P.nPcPerChan;
nSites_fet = size(trFet_spk,1) / nF_chan;
dimm_full = [size(P.miSites,2), numel(viSpk1)];
mrFet_full = zeros(dimm_full, 'single');
% nSites = size(P.miSites,2);

[viSite2_uniq, ~, cviSpk1_uniq] = unique_count_(viSite2_spk(viSpk1));
for iUniq=1:numel(cviSpk1_uniq)
    vi_ = cviSpk1_uniq{iUniq};
    viSite_ = P.miSites(1:nSites_fet, viSite2_uniq(iUniq));
%     if nF_chan>1
%         viSite_ = bsxfun(@plus, viSite_(:), (0:nF_chan-1)*nSites);
%         viSite_ = viSite_(:);
%     end
    mrFet_full(viSite_,vi_) = mrFet2_spk1(1:nSites_fet,vi_);
end

[viSite1_uniq, ~, cviSpk1_uniq] = unique_count_(viSite_spk(viSpk1));
for iUniq=1:numel(cviSpk1_uniq)
    vi_ = cviSpk1_uniq{iUniq};
    viSite_ = P.miSites(1:nSites_fet, viSite1_uniq(iUniq));
%     if nF_chan>1
%         viSite_ = bsxfun(@plus, viSite_(:), (0:nF_chan-1)*nSites);
%         viSite_ = viSite_(:);
%     end    
    mrFet_full(viSite_,vi_) = mrFet_spk1(1:nSites_fet,vi_);
end
end %func


%--------------------------------------------------------------------------
function button_event_gt_(hLine, callback)   
hMsg = msgbox_('wait...'); drawnow;

hAx = hLine.Parent;
hFig = hAx.Parent;
S_fig = hFig.UserData;
hold(hAx,'on');
[vrXp,vrYp] = deal(hLine.XData, hLine.YData);
xy = get(hAx, 'CurrentPoint');
[xp,yp] = deal(xy(1,1), xy(1,2));
iEvent = find_xy_(vrXp, vrYp, xp, yp);
[xp,yp] = deal(vrXp(iEvent), vrYp(iEvent));
hMarker = get_userdata_(hAx, 'hMarker');
try
    set(hMarker,'XData',xp,'YData',yp);
catch
    hMarker = [];
end
if isempty(hMarker)
    hMarker = plot(hAx,xp,yp,'mo');
    add_userdata_(hAx, 'hMarker', hMarker);
end
% uistack_(hMarker, 'top');
hold(hAx,'off');

% track down the waveform of interest
[viSpk_clu2, viSpk_hit, viSpk_miss] = struct_get_(S_fig, 'viSpk_clu2', 'viSpk_hit', 'viSpk_miss');
if all(hLine.Color == [1,0,0])
    viSpk1 = viSpk_miss;
elseif all(hLine.Color == [0,0,1])
    viSpk1 = viSpk_hit;
else
    viSpk1 = viSpk_clu2;
end
    
global tnWav_spk
fh_ = @(x)nanmean(tnWav_full_(tnWav_spk, [], x), 3);
tnWav_spk1 = tnWav_full_(tnWav_spk, [], viSpk1);
[mnWav_clu2, mnWav_hit, mnWav_miss] = deal(fh_(viSpk_clu2), fh_(viSpk_hit), fh_(viSpk_miss));
P = get0_('P');
mnWav_spk1 = tnWav_spk1(:,:,iEvent);
vrTime_ = (1:numel(mnWav_clu2))/P.sRateHz*1000;
figure_new_('Fig_gt_spk', [0,0,.5,1]); 
if callback.Button==3
    vhPlot = plot(nan,nan,'k--',nan,nan,'b--',nan,nan,'r--',nan,nan,'m');
    scale = P.maxAmp * 2^(P.nDiff_filt-2);
    multiplot(vhPlot(1), scale, [], mnWav_clu2);
    multiplot(vhPlot(2), scale, [], mnWav_hit);
    multiplot(vhPlot(3), scale, [], mnWav_miss);
    multiplot(vhPlot(4), scale, [], mnWav_spk1);
    legend('clu2(mean)','match(mean)','added(mean)','selected');
else
    legend('match(mean)','added(mean)','selected');
    vhPlot = plot(nan,nan,'b--',nan,nan,'r--',nan,nan,'m');
    scale = P.maxAmp * 2^(P.nDiff_filt-1);
    multiplot(vhPlot(1), scale, [], mnWav_hit);
    multiplot(vhPlot(2), scale, [], mnWav_miss);
    multiplot(vhPlot(3), scale, [], mnWav_spk1);    
end
grid on;
close_(hMsg);
end %func


%--------------------------------------------------------------------------
% 9/19/2018 JJJ: turn spike waveforms to cluster using dpclus. 
% use global features, all channels such as tetrodes or low channel count
% silicon probe
% for tetrodes. not doing feature extraction but using all waveforms
% in fact it is a cross covariance (xcov)
function S_clu = cluster_xcov_(S0, P)

tnWav_spk = get_spkwav_(P, 0);
tnWav_spk = tnWav_full_(tnWav_spk, S0);
dimm_ = size(tnWav_spk);

% if 1
%     tnWav_spk = tr_denoise_site_(tnWav_spk);
% end

t_fet = tic;
nDelays = get_set_(P, 'nDelays_xcov', 4);
switch 6 % 6: 84%, integrator %86%
    case 8
        mrFet_spk = trWav2fet_(tnWav_spk, P);
    case 7 % cross power
        mrFet_spk = crossPower_(meanSubt_(tnWav_spk));
    case 6
        mrFet_spk = xcov_fet_(tnWav_spk, nDelays);
    case 5
        mrFet_spk = reshape(meanSubt_(sort(cumtrapz(single(tnWav_spk)))), [], size(tnWav_spk,3));
    case 4
        mrFet_spk = reshape(cumsum(meanSubt_(single(tnWav_spk))), [], size(tnWav_spk,3));
    case 3
        mrFet_spk = reshape(meanSubt_(cumtrapz(single(tnWav_spk))), [], size(tnWav_spk,3));
    case 2
        mrFet_spk = single(reshape(meanSubt_(tnWav_spk),[],size(tnWav_spk,3)));
    case 1
        mrFet_spk = xcov_fet_(tnWav_spk, nDelays);
end
fprintf('\tFeature extraction took %0.1fs\n', toc(t_fet));

S_clu = S_clu_from_fet_(mrFet_spk, P);
set0_(mrFet_spk); 
S_clu.P = P;
S_clu.trFet_dim = get_set_(S0, 'dimm_fet', size(mrFet_spk));
end %func


%--------------------------------------------------------------------------
function mrFet_spk = crossPower_(tnWav_spk)
mrFet_spk = zeros(size(tnWav_spk,2).^2, size(tnWav_spk,3), 'single');
for iSpk = 1:size(tnWav_spk,3)
    mr_ = single(tnWav_spk(:,:,iSpk)); 
    mr_ = fft(mr_);
    mrX_ = abs(mr_' * mr_);
    mrFet_spk(:,iSpk) = mrX_(:);
end
end


%--------------------------------------------------------------------------
function mrFet_pca = trWav2pca_(tnWav_spk, nPcPerChan)
nChans = size(tnWav_spk,2);
nSpk = size(tnWav_spk,3);
trFet_pca = zeros(nPcPerChan, nSpk, nChans, 'single');
switch 3
    case 1
        tnWav_spk1 = permute(tnWav_spk, [1,3,2]);
        for iChan = 1:nChans
            mr_ = tnWav_spk1(:,:,iChan);
            mr_ = abs(fft(meanSubt_(mr_)));
            [a, mr_, c] = pca(mr_', 'NumComponents', nPcPerChan);
            trFet_pca(:,:,iChan) = mr_';
        end %for
        mrFet_pca = reshape(permute(trFet_pca, [3,1,2]), [], nSpk);
    
    case 2
        mrWav_ = reshape((single(tnWav_spk)),[],nSpk);
        [a, mr_, c] = pca(mrWav_', 'NumComponents', nPcPerChan*nChans);
        mrFet_pca = mr_';
    case 1
        tnWav_spk1 = permute(tnWav_spk, [1,3,2]);
        for iChan = 1:nChans
            [a, mr_, c] = pca(tnWav_spk1(:,:,iChan)', 'NumComponents', nPcPerChan);
            trFet_pca(:,:,iChan) = mr_';
        end %for
        mrFet_pca = reshape(permute(trFet_pca, [3,1,2]), [], nSpk);
end %switch
end %func


%--------------------------------------------------------------------------
function S_clu = S_clu_from_fet_(mrFet_spk, P)
nStep_knn = 1000; % affects memory usage
[knn, fGpu] = struct_get_(P, 'knn', 'fGpu');

t_func = tic;

nSpk = size(mrFet_spk,2);
miKnn = zeros(knn,nSpk, 'int32');
[vrRho, vrDelta] = deal(zeros(nSpk, 1, 'single'));
viNneigh = zeros(nSpk, 1, 'int32');
% try skipping every 10 or 100 for speed enhancement
switch 1  
    case 3 % inverse distance
        fh_dist_ = @(x)dist_matinv_(x, mrFet_spk);
    case 2 %cosine distance
        mrFet_spk = bsxfun(@rdivide, mrFet_spk, sqrt(sum(mrFet_spk.^2))); % normalize fectors
        fh_dist_ = @(y)1 - mrFet_spk' * y;
    case 1 %eucl dist         
        fh_dist_ = @(y)bsxfun(@plus, sum(y.^2), bsxfun(@minus, sum(mrFet_spk.^2)', 2*mrFet_spk'*y));
end
% fh_dist_ = @(vi_)bsxfun(@plus, sum(mrFet_spk(:,vi_).^2), bsxfun(@minus, sum(mrFet_spk.^2)', 2*mrFet_spk'*mrFet_spk(:,vi_)));

% find rho
if fGpu
    [mrFet_spk, miKnn, vrRho, vrDelta, viNneigh] = ...
        gpuArray_deal_(mrFet_spk, miKnn, vrRho, vrDelta, viNneigh);
end
fGpu = isGpu_(mrFet_spk);
fprintf('Computing Rho\n');
t_rho = tic;
switch 2
    case 2
        [vrRho, miKnn] = knn_cpu_(mrFet_spk, [], [], knn);
    case 1
        for iSpk = 1:nStep_knn:nSpk
            viSpk_ = iSpk:min(iSpk+nStep_knn-1, nSpk);
            mrD_ = fh_dist_(mrFet_spk(:,viSpk_));
            [mrSrt_, miSrt_] = sort(mrD_);
            miKnn(:,viSpk_) = miSrt_(1:knn,:);
            vrRho(viSpk_) = mrSrt_(knn,:);
            fprintf('.');
        end
        vrRho = sqrt(abs(vrRho));
end %switch
vrRho = 1 ./ vrRho;
fprintf('\tDensity calculation (rho) took %0.1fs (fGpu=%d)\n', toc(t_rho), fGpu);

% find delta
fprintf('Computing Delta\n\t');
t_delta = tic;
for iSpk = 1:nStep_knn:nSpk
    viSpk_ = iSpk:min(iSpk+nStep_knn-1, nSpk);
    mrD_ = fh_dist_(mrFet_spk(:,viSpk_));
    mrD_(bsxfun(@le, vrRho, vrRho(viSpk_)')) = inf;
    [vrDelta(viSpk_), viNneigh(viSpk_)] = min(mrD_);
    fprintf('.');
end
vrDelta = sqrt(abs(vrDelta));
vrDelta = vrDelta .* vrRho;
[vrRho, vrDelta, miKnn, viNneigh] = gather_(vrRho, vrDelta, miKnn, viNneigh);
fprintf('\n\tMin. distance calculation (delta) took %0.1fs (fGpu=%d)\n', toc(t_delta), fGpu);

t_runtime = toc(t_func);
trFet_dim = size(mrFet_spk);
[~, ordrho] = sort(vrRho, 'descend');
P = struct('knn', knn);
S_clu = struct('rho', vrRho, 'delta', vrDelta, 'ordrho', ordrho, 'nneigh', viNneigh, ...
    'P', P, 't_runtime', t_runtime, 'halo', [], 'viiSpk', [], ...
    'trFet_dim', trFet_dim, 'vrDc2_site', [], 'miKnn', miKnn);

end %func


%--------------------------------------------------------------------------
function mrD = dist_matinv_(x, mr)
nx = size(x,2);
mrD = zeros(size(mr,2), nx, 'like', x);
try
    parfor ix=1:nx
        mrD(:,ix) = x(:,ix) \ mr;   
    end
catch
    for ix=1:nx
        mrD(:,ix) = x(:,ix) \ mr;   
    end
end
mrD = abs(1 - mrD);
end %func


%--------------------------------------------------------------------------
function [mrFet1, mrFet2, mrFet3] = trWav2xcov_(trWav2_spk, P)
nDelay = 2;

[nSamples, nSpk, nChans] = size(trWav2_spk);
trWav = gather_(trWav2_spk);
[mrWav1, mrWav2, mrWav3] = deal(trWav(:,:,1), trWav(:,:,2), trWav(:,:,3));
vi0 = (nDelay+1):(nSamples - nDelay);
trWav = permute(trWav(vi0,:,:), [1,3,2]);
[mrFet1, mrFet2, mrFet3] = deal(zeros(nChans, nSpk, 'single'));
[mr1, mr2, mr3] = deal(zeros(numel(vi0), nSpk, 'single'));
       
        
switch 3
    case 3
        for iSpk=1:nSpk
            [mrA_,mrB_] = deal(trWav(:,:,iSpk));
            for iDelay = 0:2
                mrFet1(:,iSpk) = mrFet1(:,iSpk) + mean(mrA_ .* mrB_)';
                mrFet2(:,iSpk) = mrFet2(:,iSpk) + mean(mrA_ .* mrB_(:,[2:end,1]))';
                mrFet3(:,iSpk) = mrFet3(:,iSpk) + mean(mrA_ .* mrB_(:,[3:end,1,2]))';       
                mrA_ = mrA_(2:end,:);
                mrB_ = mrB_(1:end-1,:);
            end
        end
        
    case 2
        for iSpk=1:nSpk
            mr_ = trWav(:,:,iSpk);
            mrFet1(:,iSpk) = mean(mr_ .* mr_);
            mrFet2(:,iSpk) = mean(mr_(1:end-2,:) .* mr_(3:end,:));
            mrFet3(:,iSpk) = mean(mr_(1:end-4,:) .* mr_(5:end,:));
%             vr_ = mean(mr_ .* mr_);
%             for iDelay = 1:2
%                 vr_ = vr_ + mean(mr_(iDelay+1:end,:) .* mr_(1:end-iDelay,:));
%             end
%             mrFet1(:,iSpk) = vr_;
        end
        
    case 1
        for iDelay = [-nDelay:nDelay]
            mr1 = mr1 + mrWav1(vi0+iDelay,:);
            mr2 = mr2 + mrWav2(vi0+iDelay,:);
            mr3 = mr3 + mrWav3(vi0+iDelay,:);
        end %for
        fh = @(x)x / (nDelay*2+1);
        [mr1,mr2,mr3] = deal(fh(mr1),fh(mr2),fh(mr3));

        for iSpk=1:nSpk
            mr_ = trWav(:,:,iSpk);
            mrFet1(:,iSpk) = mr1(:,iSpk)' * mr_;
            mrFet2(:,iSpk) = mr2(:,iSpk)' * mr_;
            mrFet3(:,iSpk) = mr3(:,iSpk)' * mr_;
        end
end
end %func

        
%--------------------------------------------------------------------------
function mrFet_spk = xcov_fet_(tnWav_spk, nDelays)
dimm_ = size(tnWav_spk);
nChans = dimm_(2);
nSpk = dimm_(3);

switch 12 %12(86.1%) 11 7
    case 20
        mrFet_spk = zeros(nChans.^2, nSpk, 'single');
        vi_ = (nDelays+1:(dimm_(1) - nDelays))';
        miA = bsxfun(@plus, vi_, 1:nDelays);
        miB = bsxfun(@minus, vi_, 1:nDelays);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            mrX_ = zeros(nChans, nChans, 'single');            
            for iDelay = 1:nAve
                mrX_ = mrX_ + mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
            end
            mrFet_spk(:,iSpk) = mrX_(:) / nAve;            
        end    
    case 19
        mrFet_spk = zeros(nChans.^2*2, nSpk, 'single');
        viA = 1:2:dimm_(1)-1;
        viB = viA + 1;
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            mrX_ = mr_(viA,:)' * mr_(viB,:);
            mrFet_spk(:,iSpk) = mrX_(:);            
        end    
    
    case 18
        mrFet_spk = zeros(nChans.^2, nSpk, 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            mrX_ = zeros(nChans, nChans, 'single');            
            for iDelay = 1:nAve
                mrX_ = mrX_ + mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
            end
            mrFet_spk(:,iSpk) = mrX_(:) / nAve;            
        end    
    case 17
        mrFet_spk = zeros(nChans*nDelays, nSpk, 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            mrX_ = zeros(nChans, 'single');            
            for iDelay = 1:nAve
                mrX_(:,iDelay) = mean(mr_(miA(:,iDelay),:) .* mr_(miB(:,iDelay),:))';
            end
            mrFet_spk(:,iSpk) = mrX_(:) / nAve;            
        end
    case 16 %time resersal feature
        mrFet_spk = zeros(nChans.^2*2, nSpk, 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        miC = bsxfun(@plus, flipud(vi_), 0:nDelays-1);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            [mrX_, mrY_] = deal(zeros(nChans, nChans, 'single'));
            mr0_ = mr_(vi_,:);
            for iDelay = 1:nAve
                mrX_ = mrX_ + mr_(miA(:,iDelay),:)' * mr0_;
                mrY_ = mrY_ + mr_(miB(:,iDelay),:)' * mr0_;                
            end
            mrFet_spk(:,iSpk) = [mrX_(:); mrY_(:)] / nAve;        
        end     
    case 15 %time resersal feature
        mrFet_spk = zeros(nChans.^2 * 3, nSpk, 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        miC = bsxfun(@plus, flipud(vi_), 0:nDelays-1);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            [mrX_, mrY_, mrZ_] = deal(zeros(nChans, nChans, 'single'));
            mr0_ = mr_(flip(vi_),:);
            for iDelay = 1:nAve
                mrAT_= mr_(miA(:,iDelay),:)';
                mrB_ = mr_(miB(:,iDelay),:);
                mrX_ = mrX_ + mrAT_ * mrB_;
                mrY_ = mrY_ + mrAT_ * mr0_;
                mrZ_ = mrZ_ + mrB_' * mr0_;
            end
            mrFet_spk(:,iSpk) = [mrX_(:); mrY_(:); mrZ_(:)] / nAve;            
        end    
    case 14 % tempral average
        mrFet_spk = zeros(nDelays*2-1, nSpk, 'single');
        tr_ = zeros(nChans, nChans, (nDelays-2), 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, [0:nDelays-1, 0:nDelays-2]);
        miB = bsxfun(@minus, vi_, [0:nDelays-1, 1:nDelays]);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
%             mr_ = bsxfun(@minus, mr_, mean(mr_)); %  don't do mean subtraction     
            for iDelay = 1:nAve
                mrX_ = mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
                mrFet_spk(iDelay,iSpk) = mean(mrX_(:));
            end
        end    
    case 13
        mrFet_spk = zeros(nChans.^2, nSpk, 'single');
        tr_ = zeros(nChans, nChans, (nDelays-2), 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, [0:nDelays-1, 0:nDelays-2]);
        miB = bsxfun(@minus, vi_, [0:nDelays-1, 1:nDelays]);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
%             mr_ = bsxfun(@minus, mr_, mean(mr_)); %  don't do mean subtraction     
            mrX_ = zeros(nChans, nChans, 'single');            
            for iDelay = 1:nAve
                mrX_ = mrX_ + mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
            end
            mrFet_spk(:,iSpk) = mrX_(:) / nAve;            
        end    
    case 12
        mrFet_spk = zeros(nChans.^2, nSpk, 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        nAve = size(miA,2);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
%             mr_ = meanSubt_(mr_); %subtract mean, already done
            mrX_ = zeros(nChans, nChans, 'single');            
            for iDelay = 1:nAve
                mrX_ = mrX_ + mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
            end
            mrFet_spk(:,iSpk) = mrX_(:) / nAve;            
        end
    case 11        
        mrFet_spk = zeros(nChans.^2 * (nDelays-2), nSpk, 'single');
        tr_ = zeros(nChans, nChans, (nDelays-2) ,'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 2:nDelays-1);
        miB = bsxfun(@minus, vi_, 2:nDelays-1);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            for iDelay = 1:size(miA,2)
                tr_(:,:,iDelay) = mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
            end
            mrFet_spk(:,iSpk) = tr_(:);            
        end
        
    case 10        
        mrFet_spk = zeros(nChans*(nDelays-2), nSpk, 'single');
        mrX_ = zeros(nChans, nDelays-2, 'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 2:nDelays-1);
        miB = bsxfun(@minus, vi_, 2:nDelays-1);        
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
%             mr_ = bsxfun(@minus, mr_, mean(mr_)); %  don't do mean subtraction            
            for iDelay = 1:size(miA,2)
                mrX_(:,iDelay) = mean(mr_(miA(:,iDelay),:) .* mr_(miB(:,iDelay),:));
            end
            mrFet_spk(:,iSpk) = mrX_(:);                        
        end
        
    case 9        
        nDelays = 2; % override
        mrFet_spk = zeros(nChans.^2, nSpk, 'single');
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
%             mr_ = bsxfun(@minus, mr_, mean(mr_)); %  don't do mean subtraction
            mrX_ = mr_(nDelays+1:end,:)' * mr_(1:end-nDelays,:);
            mrFet_spk(:,iSpk) = mrX_(:);            
        end
        
    case 8        
        mrFet_spk = zeros(nChans.^2 * nDelays, nSpk, 'single');
        tr_ = zeros(nChans, nChans, nDelays ,'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
            for iDelay = 1:nDelays
                mrA_ = mr_(miA(:,iDelay),:);
                mrB_ = mr_(miB(:,iDelay),:);
                mrA_ = bsxfun(@minus, mrA_, mean(mrA_));
                mrB_ = bsxfun(@minus, mrB_, mean(mrB_));
                tr_(:,:,iDelay) = mrA_' * mrB_;
            end
            mrFet_spk(:,iSpk) = tr_(:);            
        end
        
    case 7        
        mrFet_spk = zeros(nChans.^2 * nDelays, nSpk, 'single');
        tr_ = zeros(nChans, nChans, nDelays ,'single');
        vi_ = (nDelays:(dimm_(1) - nDelays + 1))';
        miA = bsxfun(@plus, vi_, 0:nDelays-1);
        miB = bsxfun(@minus, vi_, 0:nDelays-1);
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));    
%             mr_ = bsxfun(@minus, mr_, mean(mr_)); %  don't do mean subtraction
            for iDelay = 1:nDelays
%                 mrA_ = mr_(miA(:,iDelay),:);
%                 mrB_ = mr_(miB(:,iDelay),:);
%                 mrA_ = bsxfun(@minus, mrA_, mean(mrA_));
%                 mrB_ = bsxfun(@minus, mrB_, mean(mrB_));
%                 tr_(:,:,iDelay) = mrA_' * mrB_;
                tr_(:,:,iDelay) = mr_(miA(:,iDelay),:)' * mr_(miB(:,iDelay),:);
            end
            mrFet_spk(:,iSpk) = tr_(:);            
        end
        
    case 1
        mrFet_spk = reshape(single(tnWav_spk), [], nSpk);
        
    case 2
        mrFet_spk = zeros(size(tnWav_spk,2).^2, nSpk, 'single');
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));
            mr_ = mr_' * mr_;
            mrFet_spk(:,iSpk) = mr_(:);
        end
        
        % sqrt and pca
%         [~,mnWav_spk,~]=pca(mnWav_spk', 'NumComponents', round(size(mnWav_spk,1)/4));
%         mnWav_spk = mnWav_spk';

    case 3
        mrFet_spk = reshape(single(tnWav_spk), [], nSpk);
        vrWeight = (std(mrFet_spk,1,2));
        vrWeight = vrWeight - min(vrWeight);
        mrFet_spk = bsxfun(@times, mrFet_spk, vrWeight);
        
    case 4
        mrFet_spk = reshape(single(tnWav_spk), size(tnWav_spk,1), []);
        vrWeight = std(mrFet_spk,1,2);
        vrWeight = vrWeight - min(vrWeight);
        mrFet_spk = bsxfun(@times, mrFet_spk, vrWeight);
        mrFet_spk = reshape(mrFet_spk, [], nSpk);
        
    case 5
        mrFet_spk = reshape(single(tnWav_spk), size(tnWav_spk,1), []);
        mrFet_spk = bsxfun(@times, mrFet_spk, std(mrFet_spk,1,2));
        tnWav_spk = reshape(mrFet_spk, dimm_);
        mrFet_spk = zeros(size(tnWav_spk,2).^2, nSpk, 'single');        
        for iSpk = 1:nSpk
            mr_ = single(tnWav_spk(:,:,iSpk));
            mr_ = mr_' * mr_;
            mrFet_spk(:,iSpk) = mr_(:);
        end    
        
    case 6
        mrFet_spk = reshape(single(tnWav_spk), [], nSpk);        
end
end %func


%--------------------------------------------------------------------------
% 9/22/2018 JJJ: compute short time covariance, average across all channel pairs
function vrCov = cov_filt_(mr, nAve, fParfor)
% mr: nT x nC
if nargin<3, fParfor = 1; end
[nT, nC] = size(mr);
t1=tic;fprintf('cov_filt_ ...');
% mean subtract
% mr = single(mr);
% hFilt = single(ones(nAve*2+1,1)/(nAve*2+1));
% mr = cell2mat(arrayfun(@(i)mr(:,i) - conv(mr(:,i), hFilt, 'same'), 1:size(mr,2), 'UniformOutput', 0));

mr_T = mr'; %nC x nT
% mr_T = bsxfun(@minus, mr_T, mean(mr_T)); % subtract channel ave
vrCov = zeros(nT, 1, 'single');
if fParfor
    try
        parfor iT = 1:nT
            mr_ = single(mr_T(:, max(iT-nAve,1):min(iT+nAve,nT)));
            mr_ = bsxfun(@minus, mr_, mean(mr_,2)); 
            vrCov(iT) = mean(mr_ * mean(mr_)');
        end       
    catch
        fParfor = 0;
    end
end
if ~fParfor
    for iT = 1:nT
        mr_ = single(mr_T(:, max(iT-nAve,1):min(iT+nAve,nT)));
        mr_ = bsxfun(@minus, mr_, mean(mr_,2)); 
        vrCov(iT) = mean(mr_ * mean(mr_)');
    end  
end
fprintf('\n\ttook %0.1fs\n', toc(t1));
return;

% middle
switch 7
    case 8
        parfor iT = 1:nT
            viT_ = min(max(iT + viT0,1), nT);
            mr_ = mr_T(:, viT_);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            vrCov(iT) = mean(mr_ * mean(mr_)');
        end       
    case 7
        for iT = nAve+1:nT-nAve
            mr_ = mr_T(:, viT0 + iT);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            vrCov(iT) = mean(mr_ * mean(mr_)');
        end
        for iT = [1:nAve, nT-nAve+1:nT]
            viT_ = min(max(iT + viT0,1), nT);
            mr_ = mr_T(:, viT_);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            vrCov(iT) = mean(mr_ * mean(mr_)');
        end    
    case 6
        for iT=1:nT
            viT_ = min(max(iT + (-nAve:nAve),1), nT);
            mr_ = mr_T(:, viT_);            
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
%             mrCov(:,iT) = mr_ * mean(mr_)';
            vrCov(:,iT) = mean(mr_ * mean(mr_)');
        end  
    case 5
        vr_mean = mean(mr_T)'; %nT x 1
        parfor iT=1:nT
            viT_ = min(max(iT + (-nAve:nAve),1), nT);
            mr_ = mr_T(:, viT_);            
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            vr_ = vr_mean(viT_);
            vrCov(iT) = mean(mr_ * (vr_ - mean(vr_)));
        end               
    case 4 %same as 2
        parfor iT=1:nT
            viT_ = min(max(iT + (-nAve:nAve),1), nT);
            mr_ = mr_T(:, viT_);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            vrCov(iT) = mean(mean(mr_) * mr_');
        end    
    case 1
        for iT = nAve+1:nT-nAve
            mr_ = mr_T(:, viT0 + iT);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            vrCov(iT) = mean(mean(mr_) * mr_');
%             mrC_ = mr_ * mr_';
%             vrCov(iT) = mean(mrC_(:));
        end
        % edge case
        for iT = [1:nAve, nT-nAve+1:nT]
            viT_ = min(max(iT + viT0,1), nT);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));            
            mr_ = mr_T(:, viT_);
            vrCov(iT) = mean(mean(mr_) * mr_');
%             mrC_ = mr_ * mr_';
%             vrCov(iT) = mean(mrC_(:));
        end
    case 2
        parfor iT=1:nT
            viT_ = min(max(iT + (-nAve:nAve),1), nT);
            mr_ = mr_T(:, viT_);
            mr_ = bsxfun(@minus, mr_, mean(mr_,2));
            mrC_ = mr_ * mr_';
            vrCov(iT) = mean(mrC_(:));
        end        
    case 3
        fh_ = @(x)mean(mean(x*x'));
        vrCov(nAve+1:nT-nAve) = arrayfun(@(iT)fh_(mr_T(:,viT0+iT)), nAve+1:nT-nAve);
end %switch
end %func


%--------------------------------------------------------------------------
function vi = detect_clean_(vr, vi, nRefrac)
% keep more negative peaks
% [viiL,vii0,viiR] = deal(1:nSpk-2, 2:nSpk-1, 3:nSpk);
nRepeat = 10;
nT = numel(vr);
for iRepeat = 1:nRepeat
    nSpk = numel(vi);
    if min(vi) == 1, vi(vi==1) = []; end
    if max(vi) == nT, vi(vi==nT) = []; end
    [viiL,vii0,viiR] = deal([1,1:nSpk-1], 1:nSpk, [2:nSpk,nSpk]);
    [viL,vi0,viR] = deal(vi(viiL), vi(vii0), vi(viiR));
    vl_remove = (vi0 - viL <= nRefrac & vr(vi0) > vr(viL)) | (viR - vi0 <= nRefrac & vr(vi0) > vr(viR));
    if any(vl_remove)
        vi(vl_remove) = [];
    else
        return;
    end
%     fprintf('.');
end
end %func


%--------------------------------------------------------------------------
function S0 = xcov_sort_(P)
[thresh_mad, nPc_xcov, knn, fPlot] = deal(6, 4, 30, 1);

% run detection
if ~is_detected_(P)
    [S0, mrFet_spk] = detect_xcov_(P);
else
    [S0, P] = load_cached_(P); 
    mrFet_spk = get_spkfet_(P);
    mrFet_spk = squeeze_(mrFet_spk(:,1,:));
end

% cluster
P.vcCluster = 'xcov';
% S_clu = S_clu_from_fet_(mrFet_spk, P.knn);
% S_clu = postCluster_(S_clu, P);
% S_clu = post_merge_wav_(S_clu, 1, P);

S0 = sort_(P);

end %func


%--------------------------------------------------------------------------
% 9/23/2018 JJJ: spike detection using local xcov
function [S0, mrFet_spk] = detect_xcov_(P, viTime_spk0, viSite_spk0)
if nargin<2, viTime_spk0 = []; end
if nargin<3, viSite_spk0 = []; end

global tnWav_raw tnWav_spk trFet_spk;
% runtime_detect = tic;
set(0, 'UserData', []);
[tnWav_raw, tnWav_spk, trFet_spk] = deal([]);

% Load waveform
mnWav_raw = load_file_(P.vcFile, [], P);
if get_(P, 'fft_thresh')>0, mnWav_raw = fft_clean_(mnWav_raw, P); end
mnWav_filt = ms_bandpass_filter_(mnWav_raw, P);
nSites = size(P.mrSiteXY,1);
nShanks = max(P.viShank_site);
switch 1
    case 2, mnWav_detect = mnWav_raw;
    case 1, mnWav_detect = mnWav_filt;
end
% Detect
if 0
    [viTime_spk0, ~, ~] = detect_spikes_(mnWav_detect, [], [], P);
    viSite_spk0 = repmat(int32(1), size(viTime_spk0));
end
if isempty(viTime_spk0) && isempty(viSite_spk0)
    if nShanks == 1
        [viTime_spk, vrAmp_spk, thresh_detect] = detect_xcov_local_(mnWav_detect, P);
        vrThresh_site = repmat(thresh_detect, [nSites, 1]);
        viSite_spk = repmat(int32(1), size(viTime_spk));
    else
        [cviTime_spk, cvrAmp_spk, cviSite_spk] = deal(cell(nShanks, 1));
        for iShank = 1:nShanks
            viSite1 = find(P.viShank_site == iShank);
            mnWav_filt1 = mnWav_detect(:,viSite1);
            [viTime_spk1, cvrAmp_spk{iShank}, thresh_detect1] = detect_xcov_local_(mnWav_filt1, P);
            nSpk1 = numel(viTime_spk1);
            vrThresh_site(viSite1) = thresh_detect1;
            cviTime_spk{iShank} = int32(viTime_spk1);
            cviSite_spk{iShank} = repmat(int32(min(viSite1)), nSpk1, 1);
        end
        % combine time from differnt shank groups
        [viTime_spk, vrAmp_spk, viSite_spk] = ...
            deal(cell2mat_(cviTime_spk), cell2mat_(cvrAmp_spk), cell2mat_(cviSite_spk));
        [viTime_spk, vi_srt_] = sort(viTime_spk);
        [vrAmp_spk, viSite_spk] = deal(vrAmp_spk(vi_srt_), viSite_spk(vi_srt_));
    end
else
    viTime_spk = viTime_spk0;
    viSite_spk = viSite_spk0;
    vrAmp_spk = [];
    vrThresh_site = mr2rms_(mnWav_filt, 1e6) * P.qqFactor;
end
switch 2
    case 3
        P_ = setfield(P, 'freqLim', [P.freqLim(1), nan]);
        mnWav_fet = ms_bandpass_filter_(mnWav_raw, P_);
    case 2, mnWav_fet = mnWav_raw;            
    case 1, mnWav_fet = mnWav_filt;
end
tnWav_spk = permute(mr2tr3_(mnWav_fet, P.spkLim, viTime_spk), [1,3,2]); % danger of offset
tnWav_raw = permute(mr2tr3_(mnWav_raw, P.spkLim_raw, viTime_spk), [1,3,2]);
[tnWav_spk, tnWav_raw] = deal(meanSubt_spk_(tnWav_spk), meanSubt_spk_(tnWav_raw));

if isempty(vrAmp_spk)
    vrAmp_spk = min(reshape(tnWav_spk, [], size(tnWav_spk,3)));
    vrAmp_spk = vrAmp_spk(:);
end

switch 0
    case 2 % softthresh tnWav_spk
        thresh_sd = int16(std(single(mnWav_filt(1:10:end))));
        vlPos_ = tnWav_spk>thresh_sd;
        vlNeg_ = tnWav_spk<-thresh_sd;
        tnWav_spk(vlPos_) = tnWav_spk(vlPos_) - (thresh_sd);
        tnWav_spk(vlNeg_) = tnWav_spk(vlNeg_) + (thresh_sd);
    case 1
        tnWav_spk = int16(meanSubt_(cumtrapz(tnWav_spk)));
    case 0
        ; 
end

% Feature extraction: compare single-chan vs multi-chan pca
nPc_xcov = nSites * P.nPcPerChan;
mrFet_spk = reshape(meanSubt_(single(tnWav_spk)), [], numel(viTime_spk));
[~, mrFet_spk, vrLat_pca] = pca(mrFet_spk', 'NumComponents', nPc_xcov);
mrFet_spk = mrFet_spk';

% Export and save features
trFet_spk = permute(repmat(mrFet_spk, [1,1,2]), [1,3,2]); % create two centers
[dimm_spk, dimm_raw, dimm_fet] = deal(size(tnWav_spk), size(tnWav_raw), size(trFet_spk));
viSite2_spk = viSite_spk;
[cviSpk_site, cviSpk2_site] = deal({viSite_spk});
[cviSpk3_site, mrPv_global, vrFilt_spk, vrD_global] = deal([]);
[nLoads, viT_offset_file] = deal(1, 0);
S0 = makeStruct_(viTime_spk, vrAmp_spk, P, ...
    dimm_spk, dimm_raw, dimm_fet, vrThresh_site, ...
    viSite_spk, viSite2_spk, cviSpk_site, cviSpk2_site, cviSpk3_site, ...
    mrPv_global, vrFilt_spk, vrD_global, nLoads, viT_offset_file);

% File output
write_spk_(P.vcFile_prm); %open file
write_spk_(tnWav_raw, tnWav_spk, trFet_spk);
write_spk_(); % close and clear
end %func


%--------------------------------------------------------------------------
% subtract spike mean (different from channel mean)
function tnWav_spk = meanSubt_spk_(tnWav_spk)
dimm = size(tnWav_spk);
tnWav_spk = reshape(tnWav_spk,[],dimm(3));
vnMean_spk = cast(mean(tnWav_spk), 'like', tnWav_spk);
tnWav_spk = bsxfun(@minus, tnWav_spk, vnMean_spk);
tnWav_spk = reshape(tnWav_spk, dimm);
end %func


%--------------------------------------------------------------------------
% 10/17/2018 JJJ: todo: multishank extension
function [viTime_spk, vrAmp_spk, thresh_detect] = detect_xcov_local_(mnWav_filt, P)
[thresh_mad, nAve_wav] = deal(P.qqFactor/.6745, round(P.sRateHz*.0005));

switch 3 % best: 3
    case 4
        vrWav_detect = sum(mnWav_filt');
    case 3
        [vrWav_detect, mrWav_detect] = xcov_filt_(mnWav_filt, nAve_wav, 2, P.fParfor);
        vrWav_detect = median(vrWav_detect) - vrWav_detect;  % negative polarity detection
    case 2
        vrWav_detect = -xcov_filt_(mnWav_filt, nAve_wav, 2, P.fParfor);        
    case 1
        vrCov = cov_filt_(mnWav_filt, nAve_wav, P.fParfor); % TODO: use GPU
        vrWav_detect = -sqrt(abs(vrCov)) + sqrt(abs(median(vrCov)));
end %switch

switch 1
    case 2
        vrWav_mean = -conv(mean(mnWav_filt.^2,2), ones(nAve_wav,1,'single'), 'same');
    case 1
        vrWav_mean = conv(mean(mnWav_filt,2), ones(nAve_wav,1,'single'), 'same');
end
switch 1
    case 2
        thresh_detect = median(abs(vrWav_mean))*thresh_mad;
        viTime_spk = find_peak_(vrWav_mean, thresh_detect, 0);        
    case 1
        thresh_detect = median(abs(vrWav_detect))*thresh_mad;
        viTime_spk = find_peak_(vrWav_detect, thresh_detect, 0);
        viTime_spk(vrWav_mean(viTime_spk)>0) = []; % remove spikes that are positives
end

% apply refractory period
viTime_spk = detect_clean_(vrWav_detect, viTime_spk, nAve_wav); 

% time centering at the local min
nT = size(mnWav_filt,1);
switch 1 %best: 1
    case 5        
        trWav_spk = mr2tr3_(mrWav_detect, [-nAve_wav,nAve_wav], viTime_spk);
        viT_min_spk = tr_find_peak_(trWav_spk, 1);
        viTime_spk = viTime_spk + (viT_min_spk - nAve_wav - 1);
        viTime_spk(viTime_spk<1 | viTime_spk>nT) = [];
    case 4
        trWav_spk = mr2tr3_(mnWav_filt, [-nAve_wav,nAve_wav], viTime_spk);
        viT_min_spk = tr_find_peak_(trWav_spk, -1);
        viTime_spk = viTime_spk + (viT_min_spk - nAve_wav - 1);
        viTime_spk(viTime_spk<1 | viTime_spk>nT) = [];
        
    case 3 % seek minimum across all channels
        for iRepeat = 1:nAve_wav % find local min
            if min(viTime_spk) == 1, viTime_spk(viTime_spk==1) = []; end
            if max(viTime_spk) == nT, viTime_spk(viTime_spk==nT) = []; end   
            vrC_ = min(mnWav_filt(viTime_spk,:),[],2);
            vrL_ = min(mnWav_filt(viTime_spk-1,:),[],2);
            vrR_ = min(mnWav_filt(viTime_spk+1,:),[],2);
            viL_ = find(vrL_ < vrC_);
            viR_ = find(vrR_ < vrC_);
            viTime_spk(viR_) = viTime_spk(viR_) + 1;
            viTime_spk(viL_) = viTime_spk(viL_) - 1;    
        end
    case 2 % seek minmum of the channel average (vrWav_mean)
        for iRepeat = 1:nAve_wav % find local min
            if min(viTime_spk) == 1, viTime_spk(viTime_spk==1) = []; end
            if max(viTime_spk) == nT, viTime_spk(viTime_spk==nT) = []; end
            viR_ = find(vrWav_mean(viTime_spk+1) < vrWav_mean(viTime_spk));
            viL_ = find(vrWav_mean(viTime_spk-1) < vrWav_mean(viTime_spk));
            viTime_spk(viR_) = viTime_spk(viR_) + 1;
            viTime_spk(viL_) = viTime_spk(viL_) - 1;    
        end
    case 1 % no resettling using vrWav_mean
        ;
end
vrAmp_spk = vrWav_detect(viTime_spk);
[viTime_spk, vrAmp_spk] = deal(viTime_spk(:), vrAmp_spk(:));
end %func


%--------------------------------------------------------------------------
% 10/18/2018 JJJ: Find minimum time and channel
function [viT_min_spk, viC_min_spk, vrV_min_spk] = tr_find_peak_(trWav_spk, fSign)
% trWav_spk: nT x nSpk x nC
if fSign<0
    [mrWav_min, miT_min_] = min(trWav_spk);
else
    [mrWav_min, miT_min_] = max(trWav_spk);
end
miT_min_ = squeeze_(miT_min_)';
if fSign<0
    [vrV_min_spk, viC_min_spk] = min(mrWav_min,[],3);
else
    [vrV_min_spk, viC_min_spk] = max(mrWav_min,[],3);
end
viT_min_spk = miT_min_(sub2ind(size(miT_min_), viC_min_spk, 1:size(miT_min_,2)));
[viT_min_spk, viC_min_spk, vrV_min_spk] = toRow_(viT_min_spk, viC_min_spk, vrV_min_spk);
end %func


%--------------------------------------------------------------------------
% 10/18/2018 JJJ: allow toCol_ to accept multiple input/output
function varargout = toCol_(varargin)
for iArg = 1:nargin
    try
        v_ = varargin{iArg};
        varargout{iArg} = v_(:);
    catch
        ;
    end
end
end %func


%--------------------------------------------------------------------------
% 10/18/2018 JJJ: allow toRow_ to accept multiple input/output
function varargout = toRow_(varargin)
for iArg = 1:nargin
    try
        v_ = varargin{iArg};
        varargout{iArg} = v_(:)';
    catch
        ;
    end
end
end %func


%--------------------------------------------------------------------------
% 9/22/2018 JJJ: compute short time covariance, average across all channel pairs
function [vrXcov, mrXcov] = xcov_filt_(mr, nAve, nDelays, fParfor)
% mr: nT x nC
if nargin<3, nDelays = 2; end
if nargin<4, fParfor = 1; end
[nT, nC] = size(mr);
mrXcov = [];

fprintf('xcov_filt_ ...'); t1=tic;
% mr_T = bsxfun(@minus, mr_T, mean(mr_T)); % subtract channel ave
vrXcov = zeros(nT,1,'single');
switch 7 %best: 7
    case 7
        mr = single(mr);
        mr1 = conv2_(mr, ones(nAve,1,'single') / nAve);
        mrXcov = (mr .* mr1)';
        vrXcov = mean(mrXcov);
        vrXcov = conv(vrXcov, ones(nAve,1,'single')/nAve, 'same');

    case 6
        mr_T = single(mr');
        mrXcov = acov_mr_(mr_T, 2) + acov_mr_(mr_T, 4);
        vrXcov = mean(mrXcov);
        vrXcov = conv(vrXcov, ones(nAve,1,'single')/nAve, 'same');

    case 5 % high pass version
        mr_T = single(mr');
        nA = round(nDelays/2);
        nB = nDelays-nA;
        vrXcov(nA+1:end-nB) = mean(mr_T(:,nDelays+1:end) .* mr_T(:,1:end-nDelays));
        
        nDelays1 = nDelays * 100;
        nA = round(nDelays1/2);
        nB = nDelays1-nA;
        vrXcov(nA+1:end-nB) = vrXcov(nA+1:end-nB) - (mean(mr_T(:,nDelays1+1:end) .* mr_T(:,1:end-nDelays1)))';
        
        vrXcov = conv(vrXcov, ones(nAve,1,'single'), 'same'); 
    case 4
        mr_T = single(mr');
        nA = round(nDelays/2);
        nB = nDelays-nA;
        mrXcov = zeros(nC, nT, 'single');
        mrXcov(:,nA+1:end-nB) = mr_T(:,nDelays+1:end) .* mr_T(:,1:end-nDelays);
        vrXcov = mean(mrXcov);
        vrXcov = conv(vrXcov, ones(nAve,1,'single')/nAve, 'same');
        mrXcov = mrXcov';
    case 3 % lower detection performance
        mr_T = mr'; %nC x nT
        nT_ = 2*nAve+1;
        viA = [nDelays+1:nT_, nDelays+2:nT_];
        viB = [1:nT_-nDelays, 1:nT_-nDelays-1];
        parfor iT = (nAve+1):(nT-nAve)
            mr_ = single(mr_T(:, (iT-nAve):(iT+nAve)));
            mrX_ = mr_(:,viA) .* mr_(:,viB);
            vrXcov(iT) = mean(mrX_(:));
        end     
    case 2 % lower detection performance
        mr_T = mr'; %nC x nT
        parfor iT = (nAve+1):(nT-nAve)
            mr_ = single(mr_T(:, (iT-nAve):(iT+nAve)));
            mrX_ = mr_(:,nDelays+1:end) .* mr_(:,1:end-nDelays);
            vrXcov(iT) = mean(mrX_(:));
        end 
    case 1
        mr_T = mr'; %nC x nT
        if fParfor
            try
                parfor iT = (nAve+1):(nT-nAve)
                    mr_ = single(mr_T(:, (iT-nAve):(iT+nAve)));
                    mrX_ = mr_(:,nDelays+1:end) * mr_(:,1:end-nDelays)';
                    vrXcov(iT) = mean(mrX_(:));
                end 
            catch
                fParfor = 0;
            end
        end
        if ~fParfor
            for iT = (nAve+1):(nT-nAve)
                mr_ = single(mr_T(:, (iT-nAve):(iT+nAve)));
                mrX_ = mr_(:,nDelays+1:end) * mr_(:,1:end-nDelays)';
                vrXcov(iT) = mean(mrX_(:));
            end   
        end
end
fprintf('\n\ttook %0.1fs\n', toc(t1));
end %func


%--------------------------------------------------------------------------
% 10/21/2018 JJJ: autocovariance
function mrXcov = acov_mr_(mr_T, nDelays)
nA = round(nDelays/2);
nB = nDelays-nA;
[nC, nT] = size(mr_T);
mrXcov = zeros(nC, nT, 'single');
mrXcov(:,nA+1:end-nB) = mr_T(:,nDelays+1:end) .* mr_T(:,1:end-nDelays);
end %func


%--------------------------------------------------------------------------
% 9/27/2018 JJJ: compute local xcov and mean
function [mrXcov, mrAve] = xcov_filt_local_(mn, P)
% Ouput
% -----
% mrXcov: local cross covariance
% mrAve: local average

fprintf('xcov_filt_local_ ...\n'); t1 = tic();
[nDelay, nAve1, nAve] = deal(2, 200, ceil(P.sRateHz * .0005));
nSites = numel(P.viSite2Chan);
vhFilt = ones(nAve,1,'single') / nAve;
vhFilt1 = ones(nAve1,1,'single') / nAve1;
mn = gather_(mn);
mrX_ = zeros(size(mn), 'single');
if nargout>=2
    mrF_ = zeros(size(mn), 'single');
    mrAve = zeros(size(mn), 'like', mn);
else
    [mrF_, mrAve] = deal([]);
end
mrXcov = zeros(size(mn), 'like', mn);
[a0, b0, nDelay] = deal(int32(nAve1+1), int32(size(mn,1)-nAve1), int32(nDelay));

for iSite=1:nSites
    vr_ = single(gpuArray_(mn(:,iSite)));
    vr_ = vr_ - conv(vr_, vhFilt1, 'same');
    if ~isempty(mrF_), mrF_(:, iSite) = gather_(vr_); end
    mrX_(a0:b0, iSite) = gather_(vr_(a0-nDelay:b0-nDelay) .* vr_(a0+nDelay:b0+nDelay));
end

% compute xcov across local neighbor channels
nSites_fet = P.maxSite*2 - P.nSites_ref;
miSites = P.miSites(1:nSites_fet,:);
for iSite = 1:nSites
    viSites1 = miSites(:,iSite);
    if iSite > 1 
        if isempty(setdiff(miSites(:,iSite), miSites(:,iSite-1)))
            mrXcov(:,iSite) = mrXcov(:,iSite-1);
            continue;
        end
    end
    vr_ = conv(mean(mrX_(:,viSites1),2), vhFilt, 'same');
    vr_ = median(vr_(1:10:end)) - vr_;
    mrXcov(:,iSite) = vr_ / (median(abs(vr_(1:10:end))) * .1);
end %for

% compute local average
if ~isempty(mrAve)
    mrAve = zeros(size(mn), 'like', mn);
    for iSite = 1:nSites
        viSites1 = miSites(:,iSite);
        if iSite > 1 
            if isempty(setdiff(miSites(:,iSite), miSites(:,iSite-1)))
                mrAve(:,iSite) = mrAve(:,iSite-1);
                continue;
            end
        end
        mrAve(:,iSite) = conv(mean(mrF_(:,viSites1), 2), vhFilt, 'same');
    end
end
fprintf('\ttook %0.1fs\n', toc(t1));            
end %func


%--------------------------------------------------------------------------
% 10/21/2018 JJJ: TODO
function [viTime_spk, vrAmp_spk, viSite_spk] = detect_spikes_xcov_(mnWav1, vlKeep_ref, P)
% fMerge_spk = 1;
fMerge_spk = get_set_(P, 'fMerge_spk', 1);

[n1, nSites, ~] = size(mnWav1);
% [mnXcov, mnAve] = xcov_filt_local_(mnWav1, P); % filter using xcov
[cviSpk_site, cvrSpk_site] = deal(cell(nSites,1));
% vnThresh_site = zeros(nSites, 1, 'int16'); 

fprintf('\tDetecting spikes from each channel.\n\t\t'); t1=tic;
% parfor iSite = 1:nSites   
for iSite = 1:nSites   
    [viSpk11, vrSpk11] = detect_xcov_local_(mnWav1(:,iSite), P)    
%     [viSpk11, vrSpk11] = spikeDetectSingle_xcov_(mnWav3(:,iSite), mnWav1(:,iSite), P);
%     [viSpk11, vrSpk11] = spikeDetectSingle_fast_(mnWav1(:,iSite), P, vnThresh_site(iSite));
    fprintf('.');
    
    % Reject global mean
    if isempty(vlKeep_ref)
        cviSpk_site{iSite} = viSpk11;
        cvrSpk_site{iSite} = vrSpk11;        
    else
        [cviSpk_site{iSite}, cvrSpk_site{iSite}] = select_vr_(viSpk11, vrSpk11, find(vlKeep_ref(viSpk11)));
    end
end
% vnThresh_site = gather_(vnThresh_site);
nSpks1 = sum(cellfun(@numel, cviSpk_site));
fprintf('\n\t\tDetected %d spikes from %d sites; took %0.1fs.\n', nSpks1, nSites, toc(t1));

% Group spiking events using vrWav_mean1. already sorted by time
if fMerge_spk
    fprintf('\tMerging spikes...'); t2=tic;
    [viTime_spk, vrAmp_spk, viSite_spk] = spikeMerge_(cviSpk_site, cvrSpk_site, P);
    fprintf('\t%d spiking events found; took %0.1fs\n', numel(viSite_spk), toc(t2));
else
    viTime_spk = cell2mat_(cviSpk_site);
    vrAmp_spk = cell2mat_(cvrSpk_site);
    viSite_spk = cell2vi_(cviSpk_site);
    %sort by time
    [viTime_spk, viSrt] = sort(viTime_spk, 'ascend');
    [vrAmp_spk, viSite_spk] = multifun_(@(x)x(viSrt), vrAmp_spk, viSite_spk);
end
vrAmp_spk = gather_(vrAmp_spk);

% Group all sites in the same shank
if get_set_(P, 'fGroup_shank', 0)
    [viSite_spk] = group_shank_(viSite_spk, P); % change the site location to the shank center
end
end %func


%--------------------------------------------------------------------------
% 9/27/2018 JJJ: 2D convoluion using 1D vec
function mr = conv2_(mr, vh)
vh = single(vh(:));
mr = single(mr);
for i=1:size(mr,2)
    mr(:,i) = conv(mr(:,i), vh, 'same');
end
end %func


%--------------------------------------------------------------------------
% visualize cluster pairs sorted by the feature space distance (centorid)
function plot_clu_pairs_(P)
if ~is_sorted_(P), fprintf(2,'must be sorted\n'); end
vcFile_prm = P.vcFile_prm;
S0 = get0_();
[S_clu, viTime_spk] = struct_get_(S0, 'S_clu', 'viTime_spk');
trWav_spk = tnWav_full_(get_spkwav_(P, 0), S0);
% mrFet_spk = get_spkfet_(P); % assume sites are sorted

if 0 % clean waveforms    
    nPc = 3;
    [mrPv, mrPc, c] = pca(reshape(trWav_spk, size(trWav_spk,1), [])', 'NumComponents', nPc);
    trWav_spk = reshape(mrPv * mrPc', size(trWav_spk));
end
cmrWav_clu = cellfun(@(vi)meanSubt(mean(trWav_spk(:,:,vi),3)), S_clu.cviSpk_clu, 'UniformOutput', 0);


% calculate cluster centroids and sort by cluster proximities
nPc = 3;
mrFet_spk = reshape(trWav_spk, [], numel(viTime_spk));
[a,mrFet_spk,c] = pca(mrFet_spk', 'NumComponents', nPc);
mrFet_spk = mrFet_spk';

mrFet_clu = cell2mat(cellfun(@(x)median(mrFet_spk(:,x),2), S_clu.cviSpk_clu, 'UniformOutput', 0));
mrDist_fet_clu = squareform(pdist(mrFet_clu'));
mrDist_fet_clu(mrDist_fet_clu==0) = nan;
[~,miDist] = sort(mrDist_fet_clu);
[~,viClu1_sort] = sort(min(mrDist_fet_clu));

[nPlot1, nPlot2] = deal(min(S_clu.nClu, 8), min(S_clu.nClu,6));
figure; set(gcf, 'Name', vcFile_prm);
for iPlot1=1:nPlot1
    iClu1 = viClu1_sort(iPlot1);
    viSpk1 = S_clu.cviSpk_clu{iClu1};
    vh_ = [];    
    for iPlot2=1:nPlot2
        iPair = (iPlot1-1)*nPlot2+iPlot2;        
        iClu2 = miDist(iPlot2+1, iClu1);
        viSpk2 = S_clu.cviSpk_clu{iClu2};
        
        vh_(end+1) = subplot(nPlot1, nPlot2,iPair); grid on; hold on;       
        plot3(mrFet_spk(1,viSpk1), mrFet_spk(2,viSpk1), mrFet_spk(3,viSpk1), '.k');
        plot3(mrFet_spk(1,viSpk2), mrFet_spk(2,viSpk2), mrFet_spk(3,viSpk2), '.r');
%         xlabel('Fet1'); ylabel('Fet2'); zlabel('Fet3');
        title(sprintf('Clu%d(b) vs %d(k)', iClu1, iClu2));
    end
    linkaxes(vh_, 'xy');    
end

figure; set(gcf, 'Name', vcFile_prm);
for iPlot1=1:nPlot1
    iClu1 = viClu1_sort(iPlot1);
    viSpk1 = S_clu.cviSpk_clu{iClu1};
    mrWav_clu1 = cmrWav_clu{iClu1};
    vh_ = [];
    for iPlot2=1:nPlot2
        iPair = (iPlot1-1)*nPlot2+iPlot2;                
        iClu2 = miDist(iPlot2+1, iClu1);
        viSpk2 = S_clu.cviSpk_clu{iClu2};
        mrWav_clu2 = cmrWav_clu{iClu2};
        
        vh_(end+1) = subplot(nPlot1, nPlot2,iPair); grid on; hold on;
        plot(toCol_(mrWav_clu1(:,1:4)), 'k');
        plot(toCol_(mrWav_clu2(:,1:4)), 'r');
%         xlabel('Fet1'); ylabel('Fet2'); zlabel('Fet3');
        title(sprintf('Clu%d(b) vs %d(k)', iClu1, iClu2));
    end
    linkaxes(vh_, 'xy');
end % for
end %func


%--------------------------------------------------------------------------
% 10/15/2018 JJJ: Modified from ms_bandpass_filter (MountainLab) for
% memory-access efficiency
% https://github.com/magland/mountainlab
function mrWav_filt = ms_bandpass_filter_(mrWav, P)
NSKIP_MAX = 2^19; % fft work length
nPad = 300;
[nT, nC] = size(mrWav);
nSkip = min(nT, NSKIP_MAX);
[sRateHz, freqLim, freqLim_width, fGpu] = ...
    struct_get_(P, 'sRateHz', 'freqLim', 'freqLim_width', 'fGpu');
if isempty(freqLim), mrWav_filt = mrWav; return; end

if fGpu
    try mrWav_filt = zeros(size(mrWav), class_(mrWav), 'gpuArray');
    catch, fGpu = 0;
    end
end
if ~fGpu, mrWav_filt = zeros(size(mrWav), 'like', mrWav); end
fh_filt = @(x,f)real(ifft(bsxfun(@times, fft(single(x)), f)));
n_prev = nan;
fprintf('Running ms_bandpass_filter\n\t'); t1=tic;
for iStart = 1:nSkip:nT
    iEnd = min(iStart+nSkip-1, nT);
    iStart1 = iStart - nPad;
    iEnd1 = iEnd + nPad;
    vi1 = iStart1:iEnd1;
    if iStart1 < 1 % wrap the filter (reflect boundary)
        vl_ = vi1 < 1;
        vi1(vl_) = 2 - vi1(vl_);
    end
    if iEnd1 > nT % wrap the filter (reflect boundary)
        vl_ = vi1 > nT;
        vi1(vl_) = 2*nT - vi1(vl_);
    end
    [mrWav1, fGpu] = gpuArray_(mrWav(vi1,:), fGpu);
    n1 = size(mrWav1,1);
    if n1 ~= n_prev
        vrFilt1 = bandpass_fft_(n1, freqLim, freqLim_width, sRateHz);
        vrFilt1 = gpuArray_(vrFilt1, fGpu);
        n_prev = n1;
    end    
    mrWav1 = fh_filt(mrWav1, vrFilt1);
    mrWav_filt(iStart:iEnd,:) = mrWav1(nPad+1:end-nPad,:);
    fprintf('.');
end
mrWav_filt = gather_(mrWav_filt);
fprintf('\n\ttook %0.1fs (fGpu=%d)\n', toc(t1), fGpu);
end %func


%--------------------------------------------------------------------------
% 10/15/2018 JJJ: Modified from ms_bandpass_filter (MountainLab) 
function filt = bandpass_fft_(N, freqLim, freqLim_width, sRateHz)
% Usage
% [Y, filt] = bandpass_fft_(X, freqLim, freqLim_width, sRateHz)
% [filt] = 
% sRateHz: sampling rate
% freqLim: frequency limit, [f_lo, f_hi]
% freqLim_width: frequency transition width, [f_width_lo, f_width_hi]
[flo, fhi] = deal(freqLim(1), freqLim(2));
[fwid_lo, fwid_hi] = deal(freqLim_width(1), freqLim_width(2));

df = sRateHz/N;
if mod(N,2)==0
    f = df * [0:N/2, -N/2+1:-1]';
else
    f = df * [0:(N-1)/2, -(N-1)/2:-1]'; 
end
% if isa_(X, 'single'), f = single(f); end
% if isGpu_(X), f = gpuArray_(f); end

if ~isnan(flo) && ~isnan(fhi)
    filt = sqrt((1+erf((abs(f)-flo)/fwid_lo)) .* (1-erf((abs(f)-fhi)/fwid_hi)))/2;
elseif ~isnan(flo)
    filt = sqrt((1+erf((abs(f)-flo)/fwid_lo))/2);
elseif ~isnan(fhi)
    filt = sqrt((1-erf((abs(f)-fhi)/fwid_hi))/2);
else
    filt = [];
end
end %func


%--------------------------------------------------------------------------
function S0 = gt2S0_(P)
% show manual interface based on GT
S_gt = load_gt_(P.vcFile_gt, P);
S0 = detect_(P, S_gt.viTime, S_gt.viSite);
S0.S_clu = S_clu_new_(S_gt.viClu, S0);

end %func


%--------------------------------------------------------------------------
function show_gt_(P)
% plot gt waveforms ordered by cluster number
S_gt0 = load_gt_(P.vcFile_gt, P);
if isempty(S_gt0), fprintf(2, 'Groundtruth does not exist. Run "irc import" to create a groundtruth file.\n'); return; end
[S_gt, tnWav_spk, tnWav_raw] = gt2spk_(S_gt0, P, 0);
figure; set(gcf,'Color','w','Name',P.vcFile_prm);
multiplot([], P.maxAmp, [], S_gt.trWav_clu);
grid on;
end %func


%--------------------------------------------------------------------------
% 10/21/2018 JJJ: cut mda file in half and save to the output dir
function mda_cut_(vcFile_txt)
keep_frac = .5; % keep half
fOverwrite = 0;
csFiles_copy = {'raw.mda', 'geom.csv', 'firings_true.mda', 'params.json'};

if ~exist_file_(vcFile_txt, 1), return; end
csFiles_mda = load_batch_(vcFile_txt);
csFiles_mda_out = cell(size(csFiles_mda));
for iFile = 1:numel(csFiles_mda)
    vcFile_mda1 = csFiles_mda{iFile};
    try    
        [vcDir_in1,~,~] = fileparts(vcFile_mda1);
        vcDir_out1 = strrep(vcDir_in1, '_synth', '_synth_half');
        mkdir_(vcDir_out1);

        % cut raw file
        mr_ = readmda_(vcFile_mda1);
        nT_keep = round(size(mr_,2) * keep_frac);
        mr_ = mr_(:, 1:nT_keep);    
        vcFile_mda_out1 = fullfile(vcDir_out1, 'raw.mda');
        writemda_(mr_, vcFile_mda_out1, fOverwrite);
        csFiles_mda_out{iFile} = vcFile_mda_out1;
        
        % cut gt file
        mr_ = readmda_(fullfile(vcDir_in1, 'firings_true.mda'));
        mr_ = mr_(:, mr_(2,:) < nT_keep);
        writemda_(mr_, fullfile(vcDir_out1, 'firings_true.mda'), fOverwrite);
        
        % copy geom.csv and params.json
        copyfile_(fullfile(vcDir_in1, 'params.json'), vcDir_out1);
        copyfile_(fullfile(vcDir_in1, 'geom.csv'), vcDir_out1);
    catch
        fprintf(2, '\tError cutting %s\n', vcFile_mda1);
    end
end %for
cellstr2file_(strrep(vcFile_txt, '.txt', '_half.txt'), csFiles_mda_out, 1);
end %func


%--------------------------------------------------------------------------
% 11/1/2018 JJJ: mcc-safe addpath, compatible without mcc
function addpath_(vcPath)
if nargin<1, vcPath=''; end
ircpath = fileparts(mfilename('fullpath'));
if isempty(vcPath)
    % add self to path
    vcPath = genpath(ircpath);
elseif ~exist_dir_(vcPath)
    vcPath = fullfile(ircpath, vcPath);
end
try
    if ~isdeployed() && ~ismcc()
        addpath(vcPath);
    else
        return;
    end
catch
    addpath(vcPath);
end
fprintf('Added path to %s\n', vcPath);
end %func


%--------------------------------------------------------------------------
function vcDir_abs = path_abs_(vc)
vcDir_abs = '';
S_dir = dir(vc);
if isempty(S_dir), return; end
try
    vcDir_abs = S_dir(1).folder;
catch
    ;
end
end %func


%--------------------------------------------------------------------------
% 11/5/2018 JJJ: Return the version of compiled run_irc
function vcVersion = mcc_version_()
[status, cmdout] = system('run_irc version'); % must be found in the system path
vcVersion = strtrim(cmdout);
end %func


%--------------------------------------------------------------------------
% 11/2/2018 JJJ: batch-mda
function vcFile_batch = batch_mda_(vcDir_in, vcDir_out, vcFile_template)
if nargin<3, vcFile_template = ''; end

fprintf('Running batch on %s\n', vcDir_in); t1=tic;

% Find inputdir and outputdir
vcDir_in = path_abs_(vcDir_in);
mkdir_(vcDir_out);
vcDir_out = path_abs_(vcDir_out);
[csFile_raw, csDir_in] = find_files_(vcDir_in, 'raw.mda');
csDir_out = cellfun(@(x)strrep(x, vcDir_in, vcDir_out), csDir_in, 'UniformOutput', 0);
csFile_prm = cell(size(csDir_in));

for iFile = 1:numel(csDir_in)
    vcFile_raw1 = csFile_raw{iFile};
    try
        [vcDir_in1, vcDir_out1] = deal(csDir_in{iFile}, csDir_out{iFile});        
        [geom_csv1, params_json1] = deal(fullfile(vcDir_in1, 'geom.csv'), fullfile(vcDir_in1, 'params.json'));
        firings_out_fname1 = fullfile(vcDir_out1, 'firings_out.mda');
        vcFile_prm1 = irc('makeprm-mda', vcFile_raw1, geom_csv1, params_json1, vcDir_out1, vcFile_template);
        irc('clear', vcFile_prm1); %init 
        irc('run', vcFile_prm1);
        irc('export-mda', vcFile_prm1, firings_out_fname1);
        
        vcFile_gt_mda1 = fullfile(vcDir_in1, 'firings_true.mda');
        if exist_file_(vcFile_gt_mda1) && read_cfg_('fSkip_gt') ~= 1
            irc('import-gt', vcFile_gt_mda1, vcFile_prm1); % assume that groundtruth file exists
            irc('validate', vcFile_prm1, 0);
        end
        
        csFile_prm{iFile} = vcFile_prm1;
        fprintf('\n\n');
    catch
        fprintf(2, 'Error processing %s\n', vcFile_raw1);
    end
end

% create a batch file and run the batch-verify skip script
vcFile_batch = fullfile(vcDir_out, sprintf('irc_%s.batch', version_()));
cellstr2file_(vcFile_batch, csFile_prm, 1);
batch_verify_(vcFile_batch, 'skip');
fprintf('\n\tRunning %s took %0.1fs\n\n', vcFile_batch, toc(t1));
end %func


%--------------------------------------------------------------------------
% 11/2/2018 JJJ: matlab compiler, generates run_irc
% @TODO: get the dependency list from sync_list
function mcc_()
fprintf('Compiling run_irc.m\n'); t1=tic;
vcEval = ["mcc -m -v -a '*.ptx' -a '*.cu' -a './mdaio/*' -a './jsonlab-1.5/*' -a './npy-matlab/*' -a 'default.*' -a './prb/*' -a '*_template.prm' -R '-nodesktop, -nosplash -singleCompThread -nojvm' run_irc.m"];
disp(vcEval);
eval(vcEval);
fprintf('\n\trun_irc.m is compiled by mcc, took %0.1fs\n', toc(t1));
end %fucn


%--------------------------------------------------------------------------
% 11/2/2018 JJJ: copy the source code to the destination directory
function copyto_(vcDir_out)
commit_irc_([], vcDir_out);
end %fucn


%--------------------------------------------------------------------------
% 11/3/2018 JJJ: use disbatch.py on cluster
function [vcFile_batch, vcFile_end] = sbatch_mda_(vcDir_in, vcDir_out, vcFile_template, fWait)
if nargin<3, vcFile_template = ''; end
if nargin<4, fWait = 1; end

if ischar(fWait), fWait = str2num(fWait); end
% compile if the version mismatches
if ~strcmpi(version_(), mcc_version_()), mcc_(); end 
fprintf('Running batch on %s\n', vcDir_in); t1=tic;
S_cfg = read_cfg_();

% Find inputdir and outputdir
vcDir_in = path_abs_(vcDir_in);
mkdir_(vcDir_out);
vcDir_out = path_abs_(vcDir_out);
[csFile_raw, csDir_in] = find_files_(vcDir_in, 'raw.mda');
csDir_out = cellfun(@(x)strrep(x, vcDir_in, vcDir_out), csDir_in, 'UniformOutput', 0);

% create task.disbatch
vcFile_disbatch = fullfile(vcDir_out, sprintf('irc_%s.disbatch', version_()));
csLine_disbatch = cellfun(@(x,y)sprintf('run_irc %s %s %s', x, y, vcFile_template), csDir_in, csDir_out, 'UniformOutput', 0);

% Add start and stop
[vcFile_start, vcFile_end] = deal(fullfile(vcDir_out, 'disbatch_start.out'), fullfile(vcDir_out, 'disbatch_end.out'));
delete_(vcFile_start);
delete_(vcFile_end);    
% vcCmd_cd = ['cd ', vcDir_out]; % switch to the output directory to write log files there
addpath_(); % add current irc to the path
cd(vcDir_out); % move to the output directory
vcCmd_start = ['date ''+%Y-%m-%d %H:%M:%S'' > ', vcFile_start];
vcCmd_end = ['date ''+%Y-%m-%d %H:%M:%S'' > ', vcFile_end];
vcCmd_barrier = '#DISBATCH BARRIER';
csLine_disbatch = {vcCmd_start, vcCmd_barrier, csLine_disbatch{:}, vcCmd_barrier, vcCmd_end};

% Write to file and launch 
cellstr2file_(vcFile_disbatch, csLine_disbatch, 1);
%vcCmd = strrep_(S_cfg.sbatch, '$taskfile', vcFile_disbatch, '$n', S_cfg.sbatch_nnodes, '$t', S_cfg.sbatch_ntasks_per_node, '$c', S_cfg.sbatch_ncpu_per_task);     
vcCmd = strrep_(S_cfg.sbatch, '$taskfile', vcFile_disbatch, '$n', S_cfg.sbatch_nnodes, '$c', S_cfg.sbatch_ncpu_per_task);     
fprintf('Running %s\n', vcCmd);
system(vcCmd);

vcFile_batch = fullfile(vcDir_out, sprintf('irc_%s.batch', version_()));
csFile_prm = cellfun(@(x)fullfile(x, 'raw_geom.prm'), csDir_out, 'UniformOutput', 0);
cellstr2file_(vcFile_batch, csFile_prm, 1);
if ~fWait
    fprintf('Job scheduled: \n\t%s\n\n', vcFile_batch);
    return;     
end

fDone = waitfor_file_(vcFile_end, 3600, 1); %wait for a file writing up to an hour, throw an error if file not written
if ~fDone
    fprintf(2, 'Task timeout\n');
    return;
end
batch_verify_(vcFile_batch, 'skip');
fprintf('\n\tRunning %s took %0.1fs\n\n', vcFile_batch, toc(t1));
end %func


%--------------------------------------------------------------------------
% 11/2/2018 JJJ: wait for a file to be written
function vcStr = strrep_(varargin)
vcStr = varargin{1};
for iArg = 2:2:nargin()
    val = varargin{iArg+1};
    if isnumeric(val), val = num2str(val); end
    vcStr = strrep(vcStr, varargin{iArg}, val);
end
end %func


%--------------------------------------------------------------------------
% 11/2/2018 JJJ: wait for a file to be written
% modified from http://www.radiativetransfer.org/misc/atmlabdoc/atmlab/handy/wait_for_existence.m
function fExist = waitfor_file_(vcFile, timeout, timestep)
% Usage: 
% timestep: in sec
% fExist = waitfor_file_(vcFile, timeout, timestep) : wait for some files
% fExist = waitfor_file_(csFiles, timeout, timestep) : wait for all files

if nargin<3, timestep = 1; end
t_start = tic();
fExist = true;
% t=0;

fprintf('Waiting for file(s):\n');
if iscell(vcFile)
    disp(toCol_(vcFile));
else
    disp(vcFile);
end

while ~all(exist_file_(vcFile))
% while ~exist(vcFile, 'file')
%     t = t + timestep;
    if toc(t_start) >=timeout
        fExist = false;
        fprintf('\n\tNot finished: waited for %0.1fs\n', toc(t_start));
        break;
    end
    pause(timestep);
end
fprintf('\n\tFinished: waited for %0.1fs\n', toc(t_start));
end %func


%--------------------------------------------------------------------------
% Find file in a folder recursively
function [csFile, csDir, vS_dir] = find_files_(vcDir, vcFile)
vS_dir = dir([vcDir, filesep(), '**', filesep(), vcFile]);
csFile = arrayfun(@(x)fullfile(x.folder, x.name), vS_dir, 'UniformOutput', 0);
csDir = {vS_dir.folder};
end %func


%--------------------------------------------------------------------------
% 11/5/2018 JJJ: copy from alpha to voms
function copyto_voms_(vcDir_voms)
% Usages
% -----
% copyto_voms_()
% copyto_voms_(vcDir_voms)
S_cfg = read_cfg_();

if nargin<1, vcDir_voms = ''; end
if isempty(vcDir_voms), vcDir_voms = get_(S_cfg, 'path_voms'); end

if ~strcmpi(pwd(), S_cfg.path_alpha), disp('must commit from alpha'); return; end
copyto_(vcDir_voms);
end %func


%--------------------------------------------------------------------------
% 11/5/2018 JJJ: copy from voms to alpha
function copyfrom_voms_(vcDir_voms)
% Usages
% -----
% copyfrom_voms_()
% copyfrom_voms_(vcDir_voms)
if nargin<1, vcDir_voms = ''; end
if isempty(vcDir_voms), vcDir_voms = read_cfg_('path_voms'); end
vcDir_this = fileparts(mfilename('fullpath'));
if ~exist_dir_(vcDir_voms), fprintf(2, 'Directory does not exist: %s\n', vcDir_voms); return; end
copyfile_(read_cfg_('copyfrom_voms'), vcDir_this, vcDir_voms);
end %func


%--------------------------------------------------------------------------
% 11/6/2018 JJJ: compute hash
% uses DataHash.m
% https://www.mathworks.com/matlabcentral/fileexchange/31272-datahash
function [vcHash, csHash] = file2hash_(csFiles)
% Usage
% ----
% file2hash_(vcFile)
% file2hash_(csFiles)
if nargin<1, csFiles = []; end
if isempty(csFiles)
    csFiles = [mfilename('fullpath'), '.m'];
end
if ischar(csFiles), csFiles = {csFiles}; end
csHash = cell(size(csFiles));
for iFile = 1:numel(csFiles)
    csHash{iFile} = DataHash(csFiles{iFile}, struct('Method', 'MD5', 'Input', 'file', 'Format', 'hex'));
    if iFile == 1
        vcHash = csHash{iFile};
    else
        vcHash = bitxor(vcHash, csHash{iFile});
    end
end
end %func


%--------------------------------------------------------------------------
% 11/7/2018 JJJ: run multiple algorithms
function run_algorithm_(P)
vcAlgorithm = get_set_(P, 'vcAlgorithm', 'ironclust');
switch vcAlgorithm
    case 'ironclust', run_irc_(P);
    case 'mountainsort', run_ms4_(P);
    case 'kilosort', run_ksort_(P);
    case 'yass', run_yass_(P);
    case 'spykingcircus', run_circus_(P);
    otherwise, disperr_(['Unsupported option: vcAlgorithm: ', vcAlgorithm]);
end %switch 
end %func


%--------------------------------------------------------------------------
function run_irc_(P)
fprintf('Performing "irc detect", "irc sort" operations.\n');
detect_(P); sort_(P, 0); describe_(P.vcFile_prm);
end %func



%--------------------------------------------------------------------------
function update_menu_trials_(mh_trials)
% Usages
% -----
% update_menu_trials_()
% update_menu_trials_(mh_trials)

if nargin<1, mh_trials = []; end
if isempty(mh_trials), mh_trials = get_tag_('mh_trials', 'uimenu'); end

% load menu
S_trials = get_trials_(mh_trials);
% populate menu

delete_(mh_trials.Children);
% add menu
cTrials = get_(S_trials, 'cTrials'); % contains name, value, type
for iTrial = 1:numel(cTrials) % add menu items
    trial1 = cTrials{iTrial};
    %vcChecked = ifeq_(iTrial == S_trials.iTrial, 'on', 'off');
    vcLabel1 = [trial1.name, ' (', trial1.type ')'];
    if S_trials.iTrial == iTrial
        vcLabel1 = ['[x] ', vcLabel1];
    end
    uimenu1 = uimenu(mh_trials, 'Text', vcLabel1); %, 'Checked', vcChecked);
    add_actions_trial_(uimenu1, iTrial);
end %for

%add actions
mh_add_event = uimenu(mh_trials,'Text','Add event channel', 'Callback', @(h,e)trial_add_event_(h,e));
mh_add_event.Separator = 'on';
uimenu(mh_trials,'Text','Add analog channel', 'Callback', @(h,e)trial_add_analog_(h,e));
try
    trial0 = cTrials{S_trials.iTrial};
catch
    return;
end
% uimenu(mh_trials, 'Text', sprintf('[%d] selected: %s (%s)', S_trials.iTrial, trial0.name, trial0.type));

%-----
uimenu(mh_trials, 'Label', 'All unit firing rate vs. aux. input', 'Callback', ...
    @(h,e)plot_aux_rate_, 'Separator', 'on');
uimenu(mh_trials, 'Label', 'Selected unit firing rate vs. aux. input', 'Callback', @(h,e)plot_aux_rate_(1));
% uimenu(mh_plot, 'Label', 'All unit firing rate vs. aux. input (zsperry)', 'Callback', @(h,e)plot_aux_rate_zsperry_());

% save S_trials struct
P = get_userdata_(mh_trials, 'P');
vcFile_trials = strrep_(P.vcFile_prm, '.prm', '_trials.mat');
struct_save_(S_trials, vcFile_trials);
end %func


%--------------------------------------------------------------------------
function S_trials = get_trials_(mh_trials)
% usages
% S_trials = get_trials_()
% S_trials = get_trials_(mh_trials)

if nargin<1, mh_trials = []; end
if isempty(mh_trials), mh_trials = get_tag_('mh_trials', 'uimenu'); end
S_trials = get_userdata_(mh_trials, 'S_trials');
if ~isempty(S_trials), return ;end

P = get_userdata_(mh_trials, 'P');
vcFile_trials = strrep_(P.vcFile_prm, '.prm', '_trials.mat');
if isempty(S_trials)
    if exist_file_(vcFile_trials)
        S_trials = load_(vcFile_trials);
    end
end
if isempty(S_trials)
    % create a new trials file
    S_trials = struct();
    S_trials.cTrials = {};
    S_trials.iTrial = 0;
end
set_userdata_(mh_trials, S_trials);
end %func


%--------------------------------------------------------------------------
function add_actions_trial_(mh_trial1, iTrial)
uimenu(mh_trial1, 'Text', 'select', 'Callback', @(h,e)trial_select_(h,e,iTrial));
uimenu(mh_trial1, 'Text', 'remove', 'Callback', @(h,e)trial_remove_(h,e,iTrial));
uimenu(mh_trial1, 'Text', 'edit', 'Callback', @(h,e)trial_edit_(h,e,iTrial));
uimenu(mh_trial1, 'Text', 'preview', 'Callback', @(h,e)trial_preview_(h,e,iTrial));
end %func


%--------------------------------------------------------------------------
function trial_select_(h,e,iTrial)
mh_trials = get_tag_('mh_trials', 'uimenu');
S_trials = get_userdata_(mh_trials, 'S_trials');
S_trials.iTrial = iTrial;
set_userdata_(mh_trials, S_trials);
update_menu_trials_(mh_trials);
end %func


%--------------------------------------------------------------------------
function trial_remove_(h,e,iTrial)
mh_trials = get_tag_('mh_trials', 'uimenu');
S_trials = get_userdata_(mh_trials, 'S_trials');
S_trials.cTrials(iTrial) = [];
if S_trials.iTrial == iTrial
    S_trials.iTrial = numel(S_trials.cTrials);
end
set_userdata_(mh_trials, S_trials);
update_menu_trials_(mh_trials);
end %func


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: Edit trial input
function trial_edit_(h,e,iTrial)
mh_trials = get_tag_('mh_trials', 'uimenu');
S_trials = get_userdata_(mh_trials, 'S_trials');
trial1 = S_trials.cTrials{iTrial};
switch lower(trial1.type)
    case 'event', trial_add_event_(h,e, iTrial);
    case 'analog', trial_add_analog_(h,e, iTrial);
    otherwise, error(['trial_edit_: unsupported mode: ', trial1.type]);
end %switch
end %func


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: Preview trial input
function trial_preview_(h,e,iTrial)

mh_trials = get_tag_('mh_trials', 'uimenu');
P = get_userdata_(mh_trials, 'P');
S_trials = get_userdata_(mh_trials, 'S_trials');
S_trial = S_trials.cTrials{iTrial};
[vrWav_aux, vrTime_aux, vcLabel_aux] = load_trial_(P, S_trial);

hFig = create_figure_('FigAux', [.5 0 .5 1], P.vcFile_prm, 1, 1);
hAx = axes('Parent', hFig);
plot(hAx, vrTime_aux, vrWav_aux);
xylabel_(hAx, 'Time (s)', vcLabel_aux, P.vcFile_prm);
grid(hAx, 'on');
set(hAx, 'XLim', vrTime_aux([1, end]));
end %func


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: Add an event-type trial
function trial_add_event_(h,e, iTrial)
if nargin<3, iTrial=[]; end
mh_trials = get_tag_('mh_trials', 'uimenu');
if isempty(iTrial)
    csAns = inputdlg('Channel name','Add event channel',1,{''});
    if isempty(csAns), return; end
    name1 = csAns{1};
    value1 = [];
else
    S_trials = get_userdata_(mh_trials, 'S_trials');
    trial1 = S_trials.cTrials{iTrial};
    [name1, value1] = deal(trial1.name, trial1.value);
end

f = figure;
max_events_trial = get_set_(get0_('P'), 'max_events_trial', 100);
if isempty(value1), value1 = nan(max_events_trial,2); end
uiTable1 = uitable(f,'Data',value1, 'ColumnName', {'on (sec)','off (sec)'}, ...
    'ColumnEditable', true);
f.CloseRequestFcn = @(f1,e)uitable_save_close_(f1, h);
f.InnerPosition = uiTable1.OuterPosition * 1.1;
f.UserData = uiTable1;
[f.MenuBar, f.ToolBar, f.Name, f.NumberTitle, f.WindowStyle] = ...
    deal('none', 'none', [name1, ' (close to save)'], 'off', 'modal');
uiwait(f); % wait until figure closure

S_trials = get_userdata_(mh_trials, 'S_trials');
mrTable1 = get_userdata_(h, 'mrTable1', 1);
if isempty(mr_trim_nan_(mrTable1))
    msgbox('Aborted, table is empty'); return;
end
if isempty(iTrial)
    trial1 = struct('name', name1, 'value', mrTable1, 'type', 'event');
    if isempty(S_trials.cTrials), S_trials.iTrial = 1; end
    S_trials.cTrials{end+1} = trial1;
else
    trial1 = struct('name', name1, 'value', mrTable1, 'type', 'event');
    S_trials.cTrials{iTrial} = trial1;
end
set_userdata_(mh_trials, S_trials);
update_menu_trials_(mh_trials);
end %func


%--------------------------------------------------------------------------
function uitable_save_close_(f, h)
% save the table as mrTable1
uiTable1 = get(f, 'UserData');
set_userdata_(h, 'mrTable1', uiTable1.Data);
delete_(f);
end %func


%--------------------------------------------------------------------------
function [mr1, viKeep1] = mr_trim_nan_(mr)
viKeep1 = any(~isnan(mr),2);
mr1 = mr(viKeep1, :);
end %fucn


%--------------------------------------------------------------------------
% 11/13/2018 JJJ: Add an analog-type trial
function trial_add_analog_(h,e, iTrial)
if nargin<3, iTrial=[]; end
mh_trials = get_tag_('mh_trials', 'uimenu');
P = get_userdata_(mh_trials, 'P');
S_trials = get_userdata_(mh_trials, 'S_trials');

if isempty(iTrial)
    [name1, vcFile, iChan, sRateHz, vcUnit, scale] = deal('', P.vcFile, [], P.sRateHz, '', 1);
    if matchFileExt_(vcFile, '.ns5')
        vcFile_ns2 = strrep(vcFile, '.ns5', '.ns2');
        if exist_file_(vcFile_ns2), vcFile = vcFile_ns2; end
        S_header = load_nsx_header_(vcFile);
        [sRateHz, scale] = struct_get_(S_header, 'sRateHz', 'uV_per_bit');
    end
else
    trial1 = S_trials.cTrials{iTrial};
    [name1, S_value1] = deal(trial1.name, trial1.value); % name, value, type
    [vcFile, iChan, sRateHz, vcUnit, scale] = ...
        struct_get_(S_value1, 'vcFile', 'iChan', 'sRateHz', 'vcUnit', 'scale');
end
csAns = inputdlg_(...
    {'Channel name', 'File name', 'Channel number', 'Sampling rate', 'Unit', 'Scale'}, ...
    'Recording format', 1, ...
    num2str_({name1, vcFile, iChan, sRateHz, vcUnit, scale}));
if isempty(csAns), return; end
[name1, vcFile, iChan, sRateHz, vcUnit, scale] = deal(csAns{:});
if isempty(name1), msgbox('Aborted, channel name is not specified'); return; end
if ~exist_file_(vcFile), msgbox('Aborted, file does not exist'); return; end
try
    [iChan, sRateHz, scale] = multifun_(@str2num, iChan, sRateHz, scale);
    if isempty(scale), msgbox('Aborted, invalid scale'); return; end
catch
    msgbox('Aborted, invalid format'); return;
end
S_value1 = makeStruct(vcFile, iChan, sRateHz, vcUnit, scale);
trial1 = struct('name', name1, 'value', S_value1, 'type', 'analog');

if isempty(iTrial)
    if isempty(S_trials.cTrials), S_trials.iTrial = 1; end
    S_trials.cTrials{end+1} = trial1;
else
    S_trials.cTrials{iTrial} = trial1;
end
set_userdata_(mh_trials, S_trials);
update_menu_trials_(mh_trials);
end %func


%--------------------------------------------------------------------------
function out = num2str_(val)
if iscell(val)
    out = cellfun(@(x)num2str_(x), val, 'UniformOutput', 0);
else
    if ischar(val)
        out = val;
    else
        out = num2str(val);
    end
end
end %func