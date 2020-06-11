%% atlas_region_segment.m
% This script creates masks for only regions of interest
% inputs:
%   - atlasseg: a 2D matrix containing whole-section mapped atlas
%   segmentation, the value of each matrix entry is the region ID on the
%   atlas
%   - regionids: a list of region IDs of interest.
%   - dsrate: optional. If smoothing of the mask is needed, dsrate is the
%   downsample rate such that the image size is reduced by dsrate times.
%   Note dsrate will always be converted to a rate that is smaller than 1.
%   - sigma: optional. If smoothing of the mask is needed, sigma is the
%   gaussian filter's standard deviation. Default to 1.
% output:
%   - segmask: a binary 2D matrix (the same size as atlasseg) where
%   only regions of interest are true.
function segmask=atlas_region_segment(atlasseg,regionids,dsrate,sigma)
segmask=ismember(atlasseg,regionids);
% segmask=zeros(size(atlasseg));
% for j=1:length(regionids)
%     segmask=segmask+(atlasseg==regionids(j));
% end
% segmask=segmask>0;

if nargin<3
    dsrate=0;
end
% smooth out the mask
if dsrate>0
    if dsrate>=1
        dsrate=1/dsrate;
    end
    segmask1=imresize(segmask,dsrate); % downsize only
    if nargin<4
        sigma=1; % set default sigma to 1
    end
    segmask_smooth=imgaussfilt(double(segmask1),sigma);
    % convert back to a binary mask
    segmask=imresize(segmask_smooth,1/dsrate);
    segmask=segmask>0;
end

