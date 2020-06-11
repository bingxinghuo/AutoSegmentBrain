%% This script generates Figure 1 for the supplementary material on MOp border detection
% Bing-Xing Huo, June 2020
% clear all
% close all
%%
savedir0='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/Joint_Analysis/MOborder/';
workdir=[savedir0,'DK5_630/'];
cd(workdir)
filelist=jp2lsread;
N=input('Please specify the section number: ','s');
[f,fileid]=jp2ind(filelist,N);
overlayfile=[workdir,fileid(1:end-4),'_overlay.tif'];
overlayimg=imread(overlayfile);
[X,Y,C]=size(overlayimg);
L=9000;
dv=.92;
load([filelist{f}(1:end-4),'.mat'],'BL')
%% original resolution
figure, imagesc(overlayimg(X/2-L/2:X/2+L/2,Y/2-L/2:Y/2+L/2,1:3))
axis image
axis off
hold on, line([100,100+round(1000/dv)],[100,100]) % 1mm scale bar
% zoom on each side
M=5;
L1=L/M;
for s=1:2
    Smask=true(size(BL));
    Smask(:,X/2*(s-1)+1:X/2*s)=false;
    BL1=BL.*Smask;
    [x,y]=find(BL1);
    xm(s)=median(x);
    ym(s)=y((x==round(xm(s))));
    rectangle('Position',[ym(s)-Y/2+L/2-L1/2,xm(s)-X/2+L/2-L1/2,L1,L1])
end
saveas(gca,[savedir0,'Figures/',fileid(1:end-4),'_full.eps'],'epsc')
%%
for s=1:2
    figure, imagesc(overlayimg(xm(s)-L1/2:xm(s)+L1/2,ym(s)-L1/2:ym(s)+L1/2,1:3))
    hold on, line([100,100+round(1000/dv)],[100,100]) % 1mm scale bar
    axis image
    axis off
    saveas(gca,[savedir0,'Figures/',fileid(1:end-4),'_zoom',num2str(s),'.eps'],'epsc')
end