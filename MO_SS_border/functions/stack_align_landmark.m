%% align sections with respect to a common landmark
function padimgstack=stack_align_landmark(sections,centind)
centind_common=max(centind(:,1)); % take the largest index as the common center
%% 1. identify padding
L=length(sections);
% get sizes of individual sections
x=zeros(L,1);
y=zeros(L,1);
for i=1:L
    [x(i),y(i)]=size(sections{i});
end
% get the max size of all dimensions
X=max(x);
yshift=centind_common*ones(size(centind,1),1)-centind(:,1); % column shift
[Y,~]=max(y+yshift);
% align by padding
padimgstack=zeros(X,Y,L); % initialize volume
%% 2. shift individual sections to align middle points
for i=1:L
    padimg=zeros(X,Y);
    padimg(:,yshift(i)+1:yshift(i)+size(sections{i},2))=sections{i};
    padimgstack(:,:,i)=padimg;
end