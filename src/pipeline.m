% Full pipeline of the Random Forest Discriminative Components Algorithm
% with reference to the sections of the original paper "Food-101: Mining
% Discriminative components with Random Forests"
vl_threads(8);
%% Set params %%
params = setParams();

%% Segment and encode dataset %%
if ~exist(fullfile(cd,'data.mat'), 'file')
   segmentDataset(params);
end

%% Grow forest (Section 4.1) %%
if ~exist(fullfile(cd,'trees.mat'), 'file')
   trees = randomForest(params);
else
   load('trees.mat');
end

params.nTrees = length(trees);
disp(params);
if ~exist('vset', 'var')
    load('vset', 'vset');
end

leaves = cell2mat(extractfield(trees, 'leaves'));
clear trees;

%% Mining components (Section 4.2) %%
metrics = leafMetrics( leaves, params );
 
%% Model training (Section 4.3) %%
models = mineComponents(leaves, metrics, vset, params);
models = models';
models = cell2mat(extractfield(models(:), 'svm'));
params.W = reshape(extractfield(models, 'w'), [params.encodingLength length(models)]);
params.models = models;
save('params.mat', '-struct', 'params');

%% Training of the final classifier %%
trainFinalClassifier(params);
