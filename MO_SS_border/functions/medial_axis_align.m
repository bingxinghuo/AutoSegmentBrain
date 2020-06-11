%% medial_axis_align.m
% This script align medial axes calculated with profile_calc.m
% Input:
%   - profiles: a Nx1 structures, each containing mop_border, which is a
%   structure by itself coming from profile_calc.m
% Outputs:
%   - medaxX_a: Nx1 cell, each cell contains the X (dorsal-ventral) coordinates of the aligned medial axes
%   - medaxY_a: Y (left-right) coordinates of all aligned medial axes
%   - midx: midpoints of the x coordinates (DV) of all medial axes
%   - midy: midpoints of the y coordinates (LR) of all medial axes
function [medaxX_a,medaxY_a,midx,midy]=medial_axis_align(profiles)
L=length(profiles);
medaxX=cell(L,1);
medaxY=cell(L,1);
midx=zeros(L,1);
midy=zeros(L,1);
lenx=zeros(L,1);
leny=zeros(L,1);
% figure, axis([-4000 4000 -500 3000]); hold on
for i=1:L
    mop_border=profiles(i).mop_border;
    if ~isempty(mop_border)
        % coordinates of all medial axes
        medaxX{i,1}=mop_border.shiftedX;
        medaxY{i,1}=mop_border.shiftedY;
        % length of each medial axis coordinates
        lenx(i)=length(medaxX{i});
        leny(i)=length(medaxY{i});
        % mid points of individual medial axes
        midx(i)=medaxX{i}(round(lenx(i)/2));
        midy(i)=medaxY{i}(round(leny(i)/2));
    end
end
%% midpoints of medial axis
% pad with the max length
medaxX_a=zeros(max(lenx),L);
medaxY_a=zeros(max(leny),L);
% identify middle point
centx_a=round(max(lenx)/2);
centy_a=round(max(leny)/2);
%% assign new coordinates to all medial axes
for i=1:L
    if lenx(i)>0
        %     medaxX_a(1:length(medaxX{i}),i)=medaxX{i}-midx(i);
        %     medaxY_a(1:length(medaxY{i}),i)=medaxY{i}-midy(i);
        medaxX_a(centx_a-round(lenx(i)/2)+1:centx_a+floor(lenx(i)/2),i)=medaxX{i}-midx(i);
        medaxY_a(centy_a-round(leny(i)/2)+1:centy_a+floor(leny(i)/2),i)=medaxY{i}-midy(i);
        %     plot(medaxY,medaxX)
        %     drawnow
    end
end
