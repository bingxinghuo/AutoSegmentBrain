function atlasbnd=mo_ss_atlas_border(segmask,motorids,senseids,linethick)
% mask for MO
segmask0=atlas_region_segment(segmask,motorids);
% mask for SS
segmask1=atlas_region_segment(segmask,senseids);
if (sum(sum(segmask1))*sum(sum(segmask0)))>0
    atlasbnd=segmask0+segmask1*2;
    if nargin<4
        linethick=0;
    end
    if linethick>0
        % find border and thicken it
        atlasbnd=atlas_region_borders(atlasbnd,linethick);
    end
else
    atlasbnd=cast(zeros(size(segmask)),'like',segmask);
end