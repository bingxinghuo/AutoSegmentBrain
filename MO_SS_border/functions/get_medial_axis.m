%% get_medial_axis.m
% This script finds the medial axis of the cortical mask
% Credit: Samik Banerjee, Cold Spring Harbor Laboratory 2020
function [shiftedX, shiftedY, shiftedTheta,centroid,theta] = get_medial_axis(ctxmaskL)

%% Smooth boundaries and create a medial axis
ctxmaskL1 = ctxmaskL(1:8:end,1:8:end);
b2 = imfill(ctxmaskL1,'holes');
ctxmask_smooth = imgaussfilt(uint8(b2)*255,50);
d2 = bwmorph(ctxmask_smooth, 'thin', inf);

d2 = imresize(d2, size(ctxmaskL));
windowSize = 51;
kernel = ones(windowSize) / windowSize ^2;
blurryImage = conv2(single(d2), kernel, 'same');
d1 = blurryImage > 0.1;
d = bwmorph(d1, 'thin', inf);

%% Get the centroid to para,eterize the curve
stats = regionprops(d);
centroid = stats.Centroid;

%% sort with phase shift for ordered line coordinates
[x, y] = find(d);
nx = length(x);
theta = zeros(nx,1);

for i = 1 : nx
    vec = [y(i) - centroid(1), x(i) - centroid(2)];
    theta(i) = atan2(vec(2),vec(1));
end

[sortedTheta, idxTheta] = sort(theta);
sortedX = x(idxTheta);
sortedY = y(idxTheta);

dtheta = diff(sortedTheta);
[idxJ, val] = find(abs(dtheta)>0.1);
shiftedTheta = unwrap(circshift(sortedTheta, -idxJ));

shiftedX = circshift(sortedX, -idxJ);
shiftedY = circshift(sortedY, -idxJ);

end