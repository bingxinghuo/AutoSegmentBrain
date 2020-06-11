%% layer5a_inner_bound.m
% This script finds the medial/inner bounds of the "layer 5a" objects
function [bndpos, layerpos]=layer5a_inner_bound(ftstack,L5smooth,win,step)
L = size(L5smooth,3);
bndpos=zeros(size(L5smooth,3),2);
if nargin>2
    %% Attempt 1: detect boundaries in the most densely detected transverse plane
    transversesum=zeros(size(L5smooth,1),1);
    for i=1:size(L5smooth,1)
        transversesum(i)=sum(sum(squeeze(L5smooth(i,:,:))));
    end
    [~,layerpos]=max(transversesum);
    L5plane=squeeze(L5smooth(layerpos,:,:));
    % find the medial boundary positions for all coronal sections    
    for i=1:L
        if sum(L5plane(:,i))>0
            [bndpos(i,:),~]=layer5a_profile_tip(L5plane(:,i)');
        end
    end
    bndpos(bndpos==0)=NaN;
    % smooth the lines
    bndpos1(:,1)=runline1(bndpos(:,1),win,step);
    bndpos1(:,2)=runline1(bndpos(:,2),win,step);
    bndpos(win+step+1:end,:)=bndpos1(win+step+1:end,:);
    % hold on, plot([1:L],bndpos(:,1),'linewidth',3)
    % hold on, plot([1:L],bndpos(:,2),'linewidth',3)
else
    %% Attempt 2: directly use the smoothed Layer 5a objects
    bndpos=zeros(size(L5smooth,3),2);
    layerpos=zeros(size(L5smooth,3),2);
    for i=1:L
        L5plane=L5smooth(:,:,i);
        profileplane=ftstack(:,:,i);
        if sum(sum(L5plane))>0
            [bndpos(i,:),layerpos(i,:)]=layer5a_profile_tip(L5plane,profileplane);
        end
    end
end
