function trainFinalClassifier(params)
%trainFinalClassifier_mem Faster version of trainFinalClassifier for
%systems with huge memory
% This version of the function is much faster than the original because it
% avoids recomputing the image encodings since they have already been
% computed once during the segmentation phase. In order to produce the same
% results as the original it is imperative that no bad superpixels exist.

components = params.models;
data = load('data');
encodeImageSet('train', components, params, data);
encodeImageSet('test', components, params, data);
clear data

load('train.mat');
fprintf('Loaded training set\n');
model = train(double(y), sparse(double(X)), '-s 2 -n 32 -q');
%model = train(double(y), sparse(double(X)), '-s 2 -q');
save('model', 'model');

clear X y
load('test.mat');
load('model');
fprintf('Loaded test set\n');
[pred, acc, prob] = predict(double(y), sparse(double(X)), model);

end

function encodeImageSet(type, components, params, data)

if strcmp(type,'train')
  fid = fopen('data/meta/train.txt');
%  start = 1;
%  nImages = 15750;
elseif strcmp(type,'test');
  fid = fopen('data/meta/test.txt');
%  start = 15750+1;
%  nImages = 5250;
end

images = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
imgSet = images{1};

fid = fopen('data/meta/all.txt');
images = textscan(fid, '%s', 'Delimiter', '\n');
allSet = images{1};
fclose(fid);

%imgSet = allSet;

pyramidLevels = params.pyramidLevels;
classes = params.classes;
nImages = length(imgSet);
[nClasses, nComponents] = size(components);
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = nClasses * nComponents * numCells; % Dimensionality of feature vec

load('index.mat');
%load('segments');

step = 1;
X = single(zeros(nImages/step, d));
y = uint8(zeros(nImages/step, 1));
s = 1;

for i = 1:step:nImages
    try
        tic  
        fprintf('%s %d/%d ', type, i, nImages);
        str = num2str(cell2mat(imgSet(i)));
        split = strsplit(str, '/');
        class = num2str(cell2mat(split(1)));
        imgPath = ['data/images/' str '.jpg'];
        I = imread(imgPath);
              
        [~, indexC] = ismember(allSet, imgSet(i));
        index = find(indexC ~= 0);
        
%        index = i;
        istart = find(map(:,1)==index, 1 );
        iend = find(map(:,1)==index, 1, 'last' );
        F = data.features(istart:iend, :);
        
        L = segmentImage(I);
        
        X(s,:) = extractImageFeatureVector(I, L, F, params);
        y(s) = uint8(find(strcmp(classes, class)));
        s = s + 1;
        toc
    catch ME
        disp(getReport(ME,'extended'));
    end

end

if strcmp(type,'train')
    save('train.mat', 'X', 'y', '-v7.3');
elseif strcmp(type,'test');
    save('test.mat', 'X', 'y', '-v7.3');
end

end
