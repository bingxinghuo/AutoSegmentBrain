%% This script generates Figure 3H for the supplementary material on MOp border detection
% Bing-Xing Huo, June 2020
[xA,yA,zA,atlas3,title_,names,spacing] = read_vtk_image(atlas_anno_vtk);
%%
[X,Y,Z]=size(atlas3);
[XX,YY,ZZ]=meshgrid(1:Y,1:X,1:Z);
% brain outline
V=atlas3>0;
% fv=isosurface(XX,YY,ZZ,V*2,1);
fv=isosurface(V*2,1);
figure, p=patch(fv);
p.EdgeColor='none';
p.FaceColor=[.8 .8 .8];
p.FaceVertexAlphaData=.3;
p.FaceAlpha='flat';
% border surface
V=double(volsurfatlas>0);
fv1=isosurface(V*2,1);
hold on, p1=patch(fv1);
p1.EdgeColor='none';
p1.FaceColor='r';
camlight
lighting gouraud
axis tight
daspect([1 1 1])
view(3)
% alpha(gco,.5)
%% borderlines on surface
bline=borderlines{1};
dvline=zeros(size(bline));
for i=1:size(bline,1)
    for s=1:2
        if ~isnan(bline(i,s))
            a=find(squeeze(atlas3(round(bline(i,s)),:,zrange(i))));
            dvline(i,s)=a(1);
        end
    end
end
dvline(dvline==0)=NaN;
hold on, scatter3(dvline(:,1),bline(:,1),zrange,'bo','filled')
%% slice through (this is used in Figure 3E-G)
% Figure 3E
% L5a surface in flat map
[X1,Y1,Z1]=size(L5smooth);
[XX1,YY1,ZZ1]=meshgrid([1:Y1]*.01,(1:X1)*.01,(0:Z1)*.02); % 20um spacing, 0.92*101 in-plane smoothing
fv=isosurface(XX,YY,ZZ,L5smooth*2,1);
figure, p=patch(fv);
p.EdgeColor='none';
p.FaceColor='y';
view([-60 -27])
lighting gouraud
% sample slices
hold on, slice(XX,YY,ZZ,ftstack,[],[],62*.02)
colormap gray
alpha(gco,.5)
caxis([0 2])
hold on, slice(XX,YY,ZZ,ftstack,[],[],52*.02)
alpha(gco,.5)
caxis([0 2])
camlight('headlight')
% border lines
hold on, h=plot3([bndpos_profile.left(63,1),bndpos_profile.left(63,1)]*.01,[0 1000]*.01,[62 62]*.02,'r');
daspect([.5 1 .5])