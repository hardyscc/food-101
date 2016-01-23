function [features, badSegments] = extractImageFeatures2(I, L, params, ignoreSmallSegments)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

if ~exist('ignoreSmallSegments', 'var')
    ignoreSmallSegments = true;
end

% Preallocate space for result
spIndices = unique(L); % Superpixel indices are not always sequential
numSuperpixels = length(spIndices);
features = zeros(numSuperpixels, params.encodingLength);
badSegments = [];

% Get image dimensions
% Height is first ;( ;( ;(
[height, width, channels] = size(I);

% Create grayscale version of input image
if channels > 1
    Igray = rgb2gray(I);
else
    Igray = I;
end

gridStep = params.gridStep;
gridStep = 8;
% SIFT
if strcmp(params.featureType, 'sift')
    binSize = 8;
    [frames, descriptors] = vl_dsift(single(Igray), 'size', binSize, 'fast', 'step', gridStep, 'FloatDescriptors');

    frames = transpose(frames);
    descriptors = transpose(descriptors);
    features = zeros(numSuperpixels, size(params.B, 2));
    
elseif strcmp(params.featureType, 'surf')
    % Create grid on which the SURFs will be calculated
    gridX = 1:gridStep:width;
    gridY = 1:gridStep:height;
    [x, y] = meshgrid(gridX, gridY);
    gridLocations = [x(:), y(:)];

    gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
    [descriptors, validPoints] = extractFeatures(Igray, gridPoints);

    frames = validPoints.Location;
    features = zeros(numSuperpixels, 64);
    
end


% Compute the sparse codes
% parameter of the optimization procedure are chosen
X = descriptors';
ompParam.L=10; % not more than 10 non-zeros coefficients
ompParam.eps=0.1; % squared norm of the residual should be less than 0.1
ompParam.numThreads=-1; % number of processors/cores to use; the default choice is -1 and uses all the cores of the machine
S = full(mexOMP(X, params.B, ompParam));

% Xhat = params.B * S;
% for i = 1:size(X, 2)
%    plot(1:size(X,1), X(:,i), 'r', 1:size(X,1), Xhat(:,i), 'b');
%    sum(S(:,i)~=0)
%    title(sprintf('%d non zero activations', ompParam.L));
%    legend('X', 'Xhat');
%    pause;
% end

nFrames = size(frames, 1);

% For every superpixel
for i = 1:numSuperpixels
    
    try
        % Superpixel index
        s = spIndices(i);

        % Find spixel points
        spPoints = uint32(zeros(nFrames, 1));
        k = 1;

        for j = 1:nFrames
            if L(frames(j,2), frames(j,1)) == s
                spPoints(k) = j;
                k = k + 1;
            end
        end
        spPoints(spPoints == 0) = [];

        if isempty(spPoints)
            badSegments = [badSegments; s];
            continue;
        end
        
        spActivations = S(:, spPoints);

        % Mean pooling
    %     features(i, :) = mean(spActivations, 2);

        % Max pooling
        features(i, :) = max(spActivations, [], 2);
    catch
        Iseg = vl_imseg(im2double(I), L);
        markerInserter = vision.MarkerInserter('Shape','Circle','BorderColor','black');
        J = step(markerInserter, label2rgb(L==s), int32(frames(spPoints,:)));
        subplot(1,2,1); subimage(J);
        subplot(1,2,2); subimage(Iseg);
        pause
    end
   
end

if ignoreSmallSegments == true
    features( ~any(features,2), : ) = [];
end
    
end
