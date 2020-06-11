%% layer5a_profile_det.m
% This function takes the padded flattened profile and calculate the layer
% 5a position
% Input:
%   - padft: an image containing the padded flattened profile. Rows
%   correspond to cortical layers; columns correspond to cortical columns
% Output:
%   - L5ft: a binary image containing patches of layer 5a
%   - peakimg: a binary image containing the dips in the image intensity
function [L5ft,peakimg]=layer5a_profile_det(padft)
[rows,cols]=size(padft);
flatsec=diff(padft)./padft(1:end-1,:); % take fractional change of image
h=fspecial('gaussian',[1,50],5);
flatsec2=imfilter(flatsec,h); % smooth on the horizontal direction
cc1=bwconncomp(flatsec2<-1e-3);
L=labelmatrix(cc1);
%% 1. find dips (inverse peaks) in the profile
% find dips along each cortical column
pkloc=cell(cols,1);
for i=1:cols
    [~,pkloc{i,1}]=findpeaks(-flatsec2(:,i),'SortStr','descend','MinPeakHeight',.005,'MinPeakWidth',5);
end
% convert into image
peakimg=zeros(size(flatsec));
for i=1:size(flatsec,2)
    pkloci=pkloc{i};
    pkloci=pkloci.*(pkloci<=(rows*.7)).*(pkloci>=(rows*.3)); % layer 5a should appear around middle of the cortex/profile
    pkloci=nonzeros(pkloci);
    peakimg(pkloci,i*ones(length(pkloci),1))=1;
end
%% 2. find the connected objects containing most of the dips
peaklabels=uint16(L).*uint16(peakimg); % get the labels of all dips
% count occurence of each label in dips
Lpeak=unique(nonzeros(peaklabels));
Lcount=zeros(length(Lpeak),1);
for i=1:length(Lpeak)
    Lcount(i)=sum(nonzeros(peaklabels)==Lpeak(i));
end
[~,idx]=sort(Lcount,'descend');
%% 3. Extract the largest 2 areas
L5ft=zeros(size(L));
L5ft=L5ft+(L==Lpeak(idx(1)));
if length(idx)>1
    L5ft=L5ft+(L==Lpeak(idx(2)));
end
% pad a row of zeros
L5ft=[L5ft;zeros(1,cols)];
peakimg=[peakimg;zeros(1,cols)];
peakimg=peakimg.*L5ft; % keep only the dips within "layer 5a"
%% legacy: find layers by stretching dips
%     se=strel('disk',10);
%     A=imdilate(peakimg,se);
%     cc=bwconncomp(A);
%     numPixels = cellfun(@numel,cc.PixelIdxList);
%     [biggest,idx] = sort(numPixels,'descend');
%     A1=zeros(size(A));
%     if ~isempty(idx)
%         A1(cc.PixelIdxList{idx(1)})=true;
%         A1(cc.PixelIdxList{idx(2)})=true;
%     end