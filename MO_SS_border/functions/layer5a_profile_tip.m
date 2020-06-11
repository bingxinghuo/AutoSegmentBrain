%% layer5a_profile_tip.m 
% This script detect the border according to medial end of layer 5a
% medial end only according to the dips
% Inputs:
%   - L5peaks: MxN matrix where rows correspond to flat cortex and
%   columns correspond to cortical depth (e.g. dips detected within layer 5a;
%   output from layer5a_profile_det.m)
% Outputs:
%   - flatpos: column positions of left and right borders 
%   - cortexpos: cortical layer position of left and right borders
function [flatpos,cortexpos]=layer5a_profile_tip(L5peaks,profileplane)
[x,y]=find(L5peaks); % get all the dips
if nargin>1
    if max(x)>1 % image rather than a line
        cortline=sum(profileplane); % collapse all cortical layers
        cortlinei=find(cortline); % get the real width of the profile
        midpt=cortlinei(1)+(cortlinei(end)-cortlinei(1))/2; % find middle point as tentative brain midline
    else
        midpt=size(L5peaks,2)/2;
    end
else
    midpt=size(L5peaks,2)/2;
end
[ysort,id]=sort(y-midpt); % sort with their column positions
% on the left: find the closest to 0
[yleft,idleft]=unique(ysort.*(ysort<0),'sorted');
if length(yleft)>1
    yleft=yleft(end-1)+midpt;
    xleft=x(id(idleft(end-1)));
else
    yleft=NaN;
    xleft=NaN;
end
% on the right: find the closest to 0
[yright,idright]=unique(ysort.*(ysort>0),'sorted');
if length(yright)>1
    yright=yright(2)+midpt;
    xright=x(id(idright(2)));
else
    yright=NaN;
    xright=NaN;
end
flatpos=[yleft,yright];
cortexpos=[xleft,xright];