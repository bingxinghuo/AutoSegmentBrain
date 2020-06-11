%% median_line.m
% This script finds the median line of binary masks of detected borders, on both hemispheres
% Inputs:
%   - borderi: a binary mask of the border
%   - zrange: optional. specifies the range of extension. Nx1.
% Output:
%   - bline: an Nx2 matrix specifies the location of the median points at
%   every z level on both hemispheres.
function bline=median_line(borderi,zrange)
borderi=bwskel(borderi);
[LRi,APi]=find(borderi);
if nargin<2
    zrange=1:size(borderi,2);
end
bline=zeros(length(zrange),2);
midpt=size(borderi,1)/2;
for z=zrange
    k=find(APi==z);
    ks{1}=k(LRi(k)<midpt);
    ks{2}=k(LRi(k)>midpt);
    for s=1:2
        if ~isempty(ks{s})
            if length(ks{s})>1
                bline(z-zrange(1)+1,s)=median(LRi(ks{s}));
            else
                bline(z-zrange(1)+1,s)=LRi(ks{s});
            end
        end
    end
end