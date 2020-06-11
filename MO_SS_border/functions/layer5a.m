%% layer5a.m
% This script detects the layer 5a of SS from the flattened profiles
% Need previous results from profile_align.m
% ftstack=flatstack(ftall,centind); % generate the profile stack
% outputfile='layer5aflat.tif';
% Inputs:
%   - ftstack: a 3D stack of flattened profiles
%   - outputfile: optional. a file to save the images of layer 5a patches
% Outputs:
%   - L5ft: a 3D stack of layer 5a patches
%   - flatpos: optional. a Nx2 matrix containing column positions of left and right
%   borders for all sections
%   - cortexpos: optional. a 3D stack of layer 5a patches cortical layer position of left and right borders
function [L5smooth,flatpos,cortexpos]=layer5a(ftstack,outputfile)
L=size(ftstack,3);
L5ftstack=zeros(size(ftstack));
flatpos=zeros(L,2);
cortexpos=zeros(L,2);
%%
% figure
for f=1:L
    padft=ftstack(:,:,f);
    %     imshow(padft), hold on;
    if sum(sum(padft))>0
        [L5ft,peakimg]=layer5a_profile_det(padft); % detect layer 5a patches
        L5ftstack(:,:,f)=L5ft;
        if nargin>1
            saveimgstack(L5ft,outputfile); % save the patches in an image stack
        end
        if nargout>1
            %% detect the border according to medial end of layer 5a
            [flatpos(f,:),cortexpos(f,:)]=layer5a_profile_tip(peakimg);
        end
        %     scatter(flatpos(f,:),cortexpos(f,:),'r','MarkerFaceColor','y')
        %     hold off
        %     pause
    end
end

% smooth in 3D
bw1=imfill(L5ftstack,'holes');
se=strel('sphere',1);
bw2=imopen(bw1,se);
bw3=imgaussfilt3(double(bw2)*255,5);
L5smooth= findbigobjects(bw3>100,2);