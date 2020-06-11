%% This script generates Figure 2 for the supplementary material on MOp border detection
% Bing-Xing Huo, June 2020
%% init 1: saving directory to save outputs
savedir0='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/Joint_Analysis/MOborder/';
keepdir=input(['Accept the saving dir at ',savedir0,'? (y/n) '],'s');
if strcmpi(keepdir,'n')
    savedir0='';
    while ~exist(savedir0,'dir')
        savedir0=input('Please enter the path to parent directory where the output should be saved: ','s');
    end
end
%% init 2: load all brain IDs
brainlistfile=[savedir0,'/testIDs.txt'];
keepdir=input(['Accept the brain ID list at ',brainlistfile,'? (y/n) '],'s');
if strcmpi(keepdir,'n')
    brainlistfile='';
    while ~exist(brainlistfile,'file')
        savedir0=input('Please enter the file name where the list of brain IDs are saved: ','s');
    end
end
fid=fopen(brainlistfile);
brainIDlist=textscan(fid,'%q');
fclose(fid);
brainIDlist=brainIDlist{1};
D=length(brainIDlist);
%% init 3: load atlas
C=100;
CCF3dir='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/MouseBrainAtlases/AllenMouseBrainAtlas/Standardized/Annotation/CCF3_2017/';
atlas_anno_vtk=[CCF3dir,'annotation_25.vtk'];
[xA,yA,zA,atlas3,title_,names,spacing] = read_vtk_image(atlas_anno_vtk);
[X,Y,Z]=size(atlas3);
%% 1. Dorsal surface projection of CCFs
% CCF3 mask

CCF3trans=volsurfproj(atlas3,2);
CCF3surf=volsurfproj_vis(CCF3trans);
saveas(gcf,[savedir0,'Figures/CCF3dorsalview.eps'],'epsc')
% CCF2 mask
CCF2dir='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/MouseBrainAtlases/AllenMouseBrainAtlas/Standardized/Annotation/CCF2_2011/';
atlas_anno_vtk=[CCF2dir,'annotation_25.vtk'];
[xA,yA,zA,atlas2,title_,names,spacing] = read_vtk_image(atlas_anno_vtk);
[CCF2trans,CCF2transimg]=volsurfproj(atlas2,2);
CCF2surf=volsurfproj_vis(CCF2trans);
saveas(gcf,[savedir0,'Figures/CCF2dorsalview.eps'],'epsc')
%% 2. load all atlas mapped borders
for d=1:D
    brainID=brainIDlist{d};
    savedir=[savedir0,'/',brainID,'/'];
    volsavefile=[savedir,brainID,'_MO_SS_border.mat'];
    volsurfatlas_all(d)=load(volsavefile,'volsurfatlas');
end
%% 3. Dorsal surface projection of individual borders
atlasmask=(atlas3>0)*C; % use CCF3 annotation as a mask to position the borders
bregmaz=320;
dv=.025; % voxel size is 25um
frontmask=ones(size(atlas3));
frontmask(:,:,1:(bregmaz-1.5/dv))=0; % truncate up to AP -1.5mm
regionpoly1=cell(D,1);
regionsurf=cell(D,1);
for d=1:D
    volcomposite=(volsurfatlas_all(d).volsurfatlas>0)+atlasmask;
    [regionpoly,regionsurf{d}]=volsurfproj(volcomposite.*frontmask,2);
    regionpoly1{d}=regionpoly{2}; % the first cell is the atlas
end
atlasmask1=squeeze(sum(atlasmask,2))>0;
% %%%%%%%%%%%%%%%%% Figure 2A legacy %%%%%%%%%%%%%%%%%%
% figure, imshow(atlasmask1')
% volsurfproj_vis(regionpoly1,gca); % all borders
% legend(brainIDlist)
% saveas(gcf,[savedir0,'Figures/allborders.eps'],'epsc')
%% 4. median lines in dorsal view
zrange=(bregmaz-1.5/dv)+1:Z;
midpt=X/2;
borderlines=cell(D,1);
%%%%%%%%%%%%%%%%% Figure 2A %%%%%%%%%%%%%%%%%%
figure
imshow(atlasmask1)
colors=hsv(D);
hold on
for d=1:D
    borderi=regionsurf{d}>C;
    borderlines{d}=median_line(borderi,zrange);
    borderlines{d}(borderlines{d}==0)=NaN;
    plot(zrange,borderlines{d},'color',colors(d,:),'linewidth',3)
end
legend(brainIDlist)
% saveas(gcf,[savedir0,'Figures/allborderlines.eps'],'epsc')
%% 5. Error bars
for d=1:D
blinesL{d}=borderlines{d}(:,1);
blinesR{d}=borderlines{d}(:,2);
end
borderlineall{1}=cat(2,blinesL{:});
borderlineall{2}=cat(2,blinesR{:});
% midline and 75-25 range
mlines=zeros(length(zrange),2);
errlines=cell(2,1);
for z=1:length(zrange)
    for s=1:2
        linepos=nonzeros(borderlineall{s}(z,:));
        mlines(z,s)=nanmedian(linepos);
        errlines{s}(z,:)=prctile(linepos,[25 75]);
    end
end
% %%%%%%%%%%%%%%%%% Figure 2C legacy %%%%%%%%%%%%%%%%%%
% figure, hold on
% for s=1:2
%     errspread=errlines{s}(:,2)-errlines{s}(:,1);
%     errspread(errspread==0)=NaN;
% plot((zrange-bregmaz)*dv,(errspread)*dv)
% end
% ylabel('25-75 percentile spread (mm) ')
% xlabel('AP distance to Bregma (mm) ')
% legend('Left ','Right ')
% set(gca,'fontsize',18)
% saveas(gcf,[savedir0,'Figures/errorspread.eps'],'epsc') % 
%% 6. show median line and CCF MO-SS borders
MOborderfile{1}=[savedir0,'CCF3_mo_ss_bnd.tif'];
MOborderfile{2}=[savedir0,'CCF2_mo_ss_bnd.tif'];
MOborder=cell(2,1);
CCFline=cell(2,1);
for r=1:2
    MOborder{r}=zeros(size(atlasmask));
    for z=1:Z
        MOborder{r}(:,:,z)=imread(MOborderfile{r},z);
    end
    [CCFborderpoly{r},CCFbordersurf{r}]=volsurfproj(MOborder{r}+atlasmask,2);
    CCFborderpoly{r}=volsurfproj_vis(CCFborderpoly{r});
    CCFlinetemp=median_line(CCFbordersurf{r}>C,zrange);
    CCFlinetemp(CCFlinetemp==0)=NaN;
    % interpolate if necessary
    for s=1:2
        zi=find(~isnan(CCFlinetemp(:,s)));
        CCFlinetemp(:,s)=interp1(zrange(zi),CCFlinetemp(zi,s),zrange);
    end
    CCFline{r}=CCFlinetemp;
end
%%
%%%%%%%%%%%%%%%%% Figure 2B %%%%%%%%%%%%%%%%%%
figure, imshow(atlasmask1)
for s=1:2
    shadedErrorBar(zrange,mlines(:,s),abs(errlines{s}-mlines(:,s)));
end
hold on
for r=1:2
    plot(zrange,CCFline{r})
end
saveas(gcf,[savedir0,'Figures/median_CCFs_borders.eps'],'epsc') % Figure
%%
% %%%%%%%%%%%%%%%%% Figure 2C Legacy %%%%%%%%%%%%%%%%%%
% figure, hold on
% for s=1:2
%     errspread=errlines{s}(:,2)-errlines{s}(:,1);
%     errspread(errspread==0)=NaN;
% plot((zrange-bregmaz)*dv,(errspread)*dv)
% CCFspread(:,s)=abs(CCFline{2}(:,s)-CCFline{1}(:,s));
% plot((zrange-bregmaz)*dv,(CCFspread(:,s))*dv)
% end
% xlim([-1.5,1.5])
% ylabel('25-75 percentile spread (mm) ')
% xlabel('AP distance to Bregma (mm) ')
% legend('Detected Left ','CCF Left ','Detected Right ','CCF Right ')
% set(gca,'fontsize',18)
% saveas(gcf,[savedir0,'Figures/errorCCFspread.eps'],'epsc') % 
%%%%%%%%%%%%%%%%% Figure 2C %%%%%%%%%%%%%%%%%%
figure
for s=1:2
    subplot(2,1,s), hold on
    errspread=errlines{s}(:,2)-errlines{s}(:,1);
    errspread(errspread==0)=NaN;
    plot((zrange-bregmaz)*dv,(errspread)*dv,'k','linewidth',2)
    CCF3spread(:,s)=abs(mlines(:,s)-CCFline{1}(:,s));
    CCF2spread(:,s)=abs(mlines(:,s)-CCFline{2}(:,s));
    plot((zrange-bregmaz)*dv,(CCF3spread(:,s))*dv,'r','linewidth',1)
    plot((zrange-bregmaz)*dv,(CCF2spread(:,s))*dv,'b','linewidth',1)
    legend('Detected 25-75 percentile ','CCF3-median ','CCF2-median ','location','northwest')
    axis([-1.5,1.3 0 1.5])
    ylabel('Spread (mm) ')
    set(gca,'fontsize',12)
end
xlabel('AP distance to Bregma (mm) ')
saveas(gcf,[savedir0,'Figures/errorCCFspread_v2.eps'],'epsc') % 
%% X. combine all borders in green channel (R - CCF3, B - CCF2)
volsurfatlas_comb=uint8(zeros(size(volsurfatlas_all(1).volsurfatlas)));
for d=1:D
    volsurfatlas_comb=volsurfatlas_comb+uint8(volsurfatlas_all(d).volsurfatlas>0);
end
% border projection of summary
[regionpolyall,regionsurfall]=volsurfproj(volsurfatlas_comb,2);
volcomb=cat(4,double(MOborder{1})/255,double(volsurfatlas_comb)/D,double(MOborder{2})/255);

%% 