%% nisslmask.m
% This script generates a mask of Nissl stained cells
% input:
%   - org: original Nissl stained section
% output:
%   - nisslimg: a binary mask of Nissl stained cells only
function mask=nisslmask(org)
mask = true([size(org,1), size(org,2)]);

for i = 1:size(org,1)
    for j = 1: size(org,2)
        if org(i,j,1)>150 || org(i,j,2)>150
            mask(i,j) = false;
        end
    end
end
% maskB = imbinarize(mask);
% nisslimg = bwfill(maskB, 'holes');
