function volsurf=boundsurfacegen(volFR)
% load('volume_1200_det.mat')
[X,Y,Z]=size(volFR);
volsurf=uint8(zeros(size(volFR)));
%%
secinfo=zeros(Z,1);
for i=1:Z
    if sum(sum(volFR(:,:,i)))>0
        secinfo(i)=1;
    end
end
seci=find(secinfo);
%% hemispheres
mid=X/2;
for i=1:2
    %%
    bound1=volFR(:,(mid*(i-1)+1):mid*i,seci);
    ind=find(bound1);
    [x,y,z]=ind2sub(size(bound1),ind);    
    % Attempt 1: going through all scattered points
%     v=80*ones(length(x),1); % homogenous value
    %     [Xq,Yq,Zq]=meshgrid(1:size(bound1,1),1:size(bound1,2),1:size(bound1,3));
    %     vq=griddata(x,y,z,v,Xq,Yq,Zq,'natural');
    %     vq=permute(vq,[2,1,3]);
    % Attempt 2: fitting the best polynomial surface
    % center 
    x1=x-mid;
    y1=y-300;
    z1=z-14;
    vq=zeros(size(bound1));
%     f1=fit([x1,z1],y1,'poly22');
    [f1, ~] = splinesurface(x1, z1, y1,1); % Attempt 3: thin-plate smoothing spline
    y2=feval(f1,[x1,z1]);
    yind=round(y2+300);
    yind(yind<=0)=NaN;
    yind(yind>size(bound1,2))=size(bound1,2);
    for j=1:length(x)
        if ~isnan(yind(j))
        vq(x(j),yind(j),z(j))=1;
        end
    end
    volsurf(:,(mid*(i-1)+1):mid*i,seci)=vq;
end
