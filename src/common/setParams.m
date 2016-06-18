function params = setParams()

if ~exist(fullfile(cd,'classes.mat'), 'file')    
    fid = fopen('data/meta/classes.txt');
    tmpclasses = textscan(fid, '%s', 'Delimiter', '\n');
    classes = tmpclasses{1};
    fclose(fid);
    save('classes.mat','classes');
else
    load('classes.mat', 'classes');
end

params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 5;
params.treeSamples = 40000;
params.nComponents = 20;
params.nClasses = 21;
params.gridStep = 4;
params.pyramidLevels = 3;
params.datasetPath = 'data/images';
params.descriptorLength = 64;
params.modes = 64;
params.encodingLength = 2 * params.modes * params.descriptorLength + 2 * params.modes * 3;
params = load('params.mat');

if ~isfield(params, 'featureGmm')
    encParams = calcGlobalParams(params);
    save('params.mat', '-append', '-struct', 'encParams');
    params = load('params.mat');
end

% Seed generator
rng('shuffle');

disp(params);

end
