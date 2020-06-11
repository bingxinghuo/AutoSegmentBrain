%% atlas_region_borders.m
% This script finds the borders between regions
% inputs:
%   - segmask0: a 2D matrix containing masks of regions of interest. Each
%   matrix entry is the region ID on the atlas.
%   - Nthick: optional. for thickening the edge to enhance visualization of
%   the boundary.
% output:
%   - atlasbnd: a 2D matrixk containing the mask of the edge of regions of
%   interest.
function atlasbnd=atlas_region_borders(segmask0,Nthick)
regions=unique(nonzeros(segmask0));
atlasbnd=false(size(segmask0));
if length(regions)>1
    segmask0(segmask0==0)=NaN;
    %     atlasbnd=edge(segmask0,'Canny'); % detect the edge
    % attempt a different method to detect all borders and save in the same
    % image
    se=strel('disk',Nthick);
    for r=1:length(regions)
        regionmask{r}=segmask0==regions(r);
        regionmask{r}=imdilate(regionmask{r},se);
    end
    v=nchoosek(regions,2);
    for i=1:size(v,1)
        regionedge=(regionmask{v(i,1)}+regionmask{v(i,2)})==2;
        atlasbnd=atlasbnd+regionedge*(regions(v(i,1))+regions(v(i,2)));
        
    end
    if nargin<2
        Nthick=0;
    end
    % if needed, thicken the line
%     if Nthick>0
%         se=strel('disk',Nthick);
%         atlasbnd=imdilate(atlasbnd,se);
%     end
end