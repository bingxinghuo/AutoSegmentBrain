%% flatstack.m
% This script generates aligned sections
% Currently aligning by middle point
% Inputs:
%   - sections: Nx1 cell structure where each cell contains the image of a
%   section (flattend profile)
%   - centind: Nx2 matrix. Each row contains the [column, row] of the
%   center of the section to be aligned. (midpoint of medial axis)
%   - outputfile: tif file to save the stack in 16-bit images
% Output:
%   - padimgstack: aligned sections saved in a common volumn
function padimgstack=flatstack(sections,centind,outputfile)
padimgstack=stack_align_landmark(sections,centind); % align sections
M=max(max(max(padimgstack))); % check the intensity scale of the images
L=length(sections);
secm=zeros(L,1);
% get mean values of individual sections
for i=1:L
    secm(i,1)=mean(nonzeros(sections{i}));
end
% adjust intensity and save
secM=nanmean(nonzeros(secm));
for i=1:L
    padimg=padimgstack(:,:,i);
    if M<=2^16
        padimg1=padimg/secM; % normalize across the stack
        padimgstack(:,:,i)=padimg1; % update after normalization
        sc=floor(2^8/max(max(padimg1))); % scale up for visualization
        padimg=uint16(padimg*sc);
    else
        padimg=uint16(padimg);
    end
end
if nargin>2
    saveimgstack(padimgstack,outputfile);
end