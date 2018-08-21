


% srun matlab -nosplash -nodisplay -r "addpath('/mnt/home/magland/src/ironclust/'); 
addpath('./matlab'); 
addpath('./mdaio'); 
p_ironclust('~/tetrode_30min', ...
    '~/tetrode_30min/raw.mda', ...
    '~/tetrode_30min/geom.csv', ...
    'tetrode_template.prm', ...
    '~/tetrode_30min/firings_out.mda', ...
    '~/tetrode_30min/argfile.txt'); 
