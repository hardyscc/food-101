function L = segmentImage(I, computeColorOutput)
%segmentImage Perform segmentation on an image using the Graph-Based
%Segmentation algorithm by Felzenszwalb
%   I: The image to be segmented
%   L: The produced segments

if nargin < 2
    computeColorOutput = false;
end

[height, width, ~] = size(I);
sigma = 0.1;
kappa = 300;
minSize = height * width * 0.01;

L = segmentFelzenszwalb(I, sigma, kappa, minSize, computeColorOutput) + 1;

end

