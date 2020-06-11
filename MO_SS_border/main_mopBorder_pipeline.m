% This script saves intermediate step results of MOp-SSp border detection
% from Nissl images of consecutive sections.
%% 0. initialize
bnddet_init; % initialize
regionids=load('regionids.mat');
% manually identify the section range to be 50-130
if strcmpi(brainID(1),'D') % DK brain
    seci(1)=jp2ind(filelist,'0190');
    seci(2)=jp2ind(filelist,'0290');
    zspace=20;
elseif strcmpi(brainID(1),'P') % MBA brain
    seci(1)=jp2ind(filelist,'0050');
    seci(2)=jp2ind(filelist,'0130');
    zspace=40;
end
seci=seci(1):seci(2);
L=length(seci);
ds=20; % 20X downsample
imgsize=imfinfo([imgdir,'/',filelist{1}]);
imgsize=[imgsize.Height,imgsize.Width]; % universal image size
%% 1. run through all sections and save intermediate results
fid=fopen([savedir,'/',brainID,'_drop.txt'],'w+');
formatspec='%s\n';
for f = seci
    tic;
    disp(['Processing ',filelist{f},'...']);
    clear jp2img nisslimg ctxmask atlasbnd mop_border
    [~,filename,~]=fileparts(filelist{f}); % get file name
    savefile=fullfile(savedir,[filename,'.mat']);
    seg=cell(length(segmaskdir),1);
    try
                if exist(savefile,'file')
                    load(savefile)
                     disp('Previous results loaded.')
                else
        %% 1.1 load image
        jp2img=imread(fullfile(imgdir,filelist{f})); % load JP2 image
        disp('Image loaded.')
        %% 1.2 Create Cortex Mask using CCF3
        seg{1}=load_mapped_atlas(segmaskdir{1},filename); % load mapped atlas for the section
        ctxmask0=atlas_region_segment(seg{1},regionids.cortexids);
        %     ctxmask=atlas_region_segment(seg,regionids.cortexids,20,5);
        cc=bwconncomp(ctxmask0);
        numPixels = cellfun(@numel,cc.PixelIdxList);
        [biggest,idx] = sort(numPixels,'descend');
        ctxmask=false(size(ctxmask0));
        ctxmask(cc.PixelIdxList{idx(1)})=true;
        save(savefile,'ctxmask')
        disp('Cortex mask generated.')
        %% 1.3 Create Nisll segmentation
        nisslimg=nisslmask(jp2img);
        save(savefile,'nisslimg','-append')
        disp('Nissl mask generated.')
                end
        %% 1.4 Generate MO-SS border lines from atlases
        atlasbnd=cell(length(segmaskdir),1);
        for r=1:length(segmaskdir)
            seg{r}=load_mapped_atlas(segmaskdir{r},filename);
            atlasbnd{r}=mo_ss_atlas_border(seg{r},regionids.motorids,regionids.senseids,5);
        end
        save(savefile,'atlasbnd','-append')
        disp('MO-SS border generated for atlases.')
        %% 1.5 Flatten cortical profiles
        mop_border = profile_calc(ctxmask, nisslimg);
        save(savefile,'mop_border','-append')
        disp('Cortical profiles created.')
        %% 1.6 flatten atlas segmentation
        segft=cell(length(segmaskdir),1);
        for r=1:length(segmaskdir)
            [segft{r},~]=flattencortex(seg{r},mop_border.m_smooth, mop_border.smooth_shiftedX, mop_border.smooth_shiftedY,ctxmask);
        end
        save(savefile,'segft','-append')
        disp('Atlas segmentation of the profiles created.')
        %% save
        %             if exist(savefile,'file')
        %                 save(savefile,'mop_border','-append')
        %             else
%         save(savefile,'nisslimg','ctxmask','atlasbnd','mop_border','segft')
        %             end

        disp([filelist{f},' completed.'])
        %         end
    catch
        fprintf(fid,formatspec,filename);
        disp([filelist{f},' dropped.'])
    end
    toc;
end
fclose(fid);
%% 2. Detect MO-SS border
%% 2.1 align profiles and atlas segmentations
profile_align;
disp('Flat maps of cortical profile and atlas segmentations aligned.')
%% 2.2 SS layer 5a detection
[L5smooth]=layer5a(ftstack,[savedir,'/layer5aflat.tif']);
% L5ftstack=L5smooth; % Samik
% win=5;
% step=1;
% [bndpos, maxi]=layer5a_inner_bound(ftstack,L5smooth,win,step);
ftstack1=stackinterp(ftstack);
[bndpos, layerpos]=layer5a_inner_bound(ftstack1,L5smooth);
%% 2.3 project back to the original position
% project back to profiles for each section
bndpos_r=zeros(size(bndpos));
for k=1:size(bndpos,2)
    [bndpos_r(:,k),~]=reverse_profile_align(bndpos(:,k),0,centind);
end
% for i=1:L
%     bndpos_profile.left(i,:)=[bndpos_r(i,1),size(L5ftstack,1)-maxi];
%     bndpos_profile.right(i,:)=[bndpos_r(i,2),size(L5ftstack,1)-maxi];
% end
for i=1:L
    bndpos_profile.left(i,:)=[bndpos_r(i,1),layerpos(i,1)];
    bndpos_profile.right(i,:)=[bndpos_r(i,2),layerpos(i,2)];
end
save(volsavefile,'bndpos_profile','-v7.3')
disp('Layer 5a border detected in the flat maps.')
%% 2.4 project back to cortical normals
tic;
cortical_normals=find_bnd_nrml_pts(bndpos_profile,filelist(seci),savedir);
save(volsavefile,'cortical_normals','-append')
disp('Layer 5a border detected in the registered space.')
toc;
%% 3. Construct visualizations in 3D
%% 3.1 generate downsampled volume
volFR=uint8(zeros(imgsize(1)/ds,imgsize(2)/ds,length(filelist)));
for i=1:L
    f = seci(i);
    [~,filename,~]=fileparts(filelist{f}); % get file name
    borderfile=[savedir,'/',filename,'.mat'];
    
    se=strel('disk',7);
    if exist(borderfile,'file')
        load(borderfile,'BL')
        if sum(sum(BL))>0
            disp(['Processing ',filename])
            BL=imdilate(BL,se);
            BL=imresize(BL,1/ds);
            volFR(:,:,f)=BL;
        end
    else
        disp(['Not found ',filename]);
    end
end
save(volsavefile,'volFR','-append')
disp([num2str(ds),'X downsampled 3D volume saved.'])
%% 3.2 generate boundary surface in 3D
se=strel('sphere',3);
volFR1=imdilate(volFR,se);
volsurf=boundsurfacegen(volFR1);
% volsurf=volsurf(:,:,1:621); % we chose the first 621 sections for DK5 registration
% save in registered space
saveimgstack(uint8(volsurf)*255,[savedir,'MOpsboundary_reg.tif']);
save(volsavefile,'volsurf','-append')
disp('Smooth surface of the border generated.')
%% 3.3 transform into atlas space
se=strel('sphere',1);
volsurf1=imdilate(volsurf,se);
atlas_vtk = [atlasdir,'average_template_25.vtk'];
deformation_file=[imgdir0,brainID,'/Registration_OUTPUT/atlas_to_registered_displacement.vtk'];
geometry_file=[imgdir0,brainID,'/INPUT_DATA/geometry.csv'];
volsurfatlas=transform_reg_to_atlas_n(volsurf1,[.92*ds,.92*ds,zspace],geometry_file,deformation_file,atlas_vtk);
% limit to cortex
atlas_anno_vtk=[atlasannodir,'annotation_25.vtk'];
[~,~,~,atlasanno,~] = read_vtk_image(atlas_anno_vtk);
atlasctx=ismember(atlasanno,regionids.cortexids);
volsurfatlas=volsurfatlas.*atlasctx;
saveimgstack(uint8(volsurfatlas*255),[savedir,'MOpsboundary_atlas.tif']); % save in atlas space
save(volsavefile,'volsurfatlas','-append')
disp('Transformed into atlas space.')
%% 4. 2D overlay with atlases (this part is time consuming)
% jp2dir=[imgdir0,brainID,'/Transformation_OUTPUT/',brainID,'_img/'];
% for i=1:length(seci)
%     tic;
%     % parfor i=1:length(seci)
%     fileid=filelist{seci(i)};
%     [~,filename,~]=fileparts(fileid);
%     atlasbnd=load([savedir,filename,'.mat'],'atlasbnd');
%     fields=fieldnames(atlasbnd);
%     if ~isempty(fields)
%         atlasbnd=atlasbnd.atlasbnd;
%         border_atlas_vis(filename,regionids,jp2dir,savedir,atlasbnd,savedir,'line');
%     else
%         atlasbnd=border_atlas_vis(filename,regionids,jp2dir,savedir,segmaskdir,savedir,'line');
%         save([savedir,filename,'.mat'],'atlasbnd','-append');
%     end
%     close;
%     toc;
% end