addpath(fullfile(cd,'src'));
addpath(fullfile(cd,'src','common'));
addpath(fullfile(cd,'src','componentMining'));
addpath(fullfile(cd,'src','finalClassifier'));
addpath(fullfile(cd,'src','forest'));
addpath(fullfile(cd,'src','seg-enc'));
addpath(fullfile(cd,'lib','matlab-tree'));
addpath(fullfile(cd,'lib','graphSeg'));
addpath(fullfile(cd,'lib','liblinear-multicore-2.1-2','matlab'));
run('/opt/vlfeat/toolbox/vl_setup');

if ~exist(fullfile(cd,'classes.mat'), 'file')    
    fid = fopen('data/meta/classes.txt')
    tmpclasses = textscan(fid, '%s', 'Delimiter', '\n');
    classes = tmpclasses{1};
    fclose(fid);
    save('classes.mat','classes');
    clear;
end
