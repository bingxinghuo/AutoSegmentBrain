%% border_atlas_vis.m
% This script visualizes the detected border overlaied on Nissl, along with
% atlas segmentation
% Inputs:
%   - filename: section file name, without extension
%   - regionids: subregion IDs that would be included in each region (here
%   I'm lumping all MO subregions and SS subregions)
%   - nissldir: directory to load Nissl images
%   - borderdir: directory to load border files
%   - segmasdir: a cell structure. Each cell contains the directory of one
%   set of segmentation results, saved in mat files
%   - savedir: directory to save the high resolution tif and low resolution
%   png
%   - ifthicken: flag signifying if the line needs to be thickened
function atlasbnd=border_atlas_vis(filename,regionids,nissldir,borderdir,segmaskdir,savedir,options)
borderfile=[borderdir,'/',filename,'.mat'];
atlasbnd=cell(length(segmaskdir),1);
if nargin<7
    options='none';
end
se=strel('disk',5);
if exist(borderfile,'file')
    load(borderfile,'BL')
    if sum(sum(BL))>0
        disp(['Processing ',filename])
        if ~strcmpi(options,'none')
            BL=imdilate(BL,se);
            BL=BL>0;
        end
        % 1. load image
        nisslimg=imread([nissldir,filename,'.jp2']);
        % 2. load MOp-SSp border
        %     bndmask1=volFR(:,:,seci(i))>0;
        %     bndmask=imresize(bndmask1,20);
        bndmask=cast(BL,'like',nisslimg);
        %         % visualize
        %         jp2img_bnd=nisslimg.*cat(3,1-bndmask,1-bndmask,1-bndmask);
        %     figure, imagesc(jp2img_bnd)
        %     hold on
        %     axis image; axis off
        % load segmentation mask
        %         [~,filename,~]=fileparts(fileid);
        jp2img_bnd_atlas=nisslimg;
        cmap=colormap('lines');
        for r=1:length(segmaskdir)
            if isa(segmaskdir{r},'char')
                segmask=load_mapped_atlas(segmaskdir{r},filename);
                % masks for MO
                segmask0=atlas_region_segment(segmask,regionids.motorids);
                %
                if strcmpi(options,'line')
                    % masks for SS
                    segmask1=atlas_region_segment(segmask,regionids.senseids);
                    segmask0=segmask0+segmask1*2;
                    % find border and thicken it
                    atlasbnd{r}=atlas_region_borders(segmask0,5);
                    % construct the overlay
                    jp2img_bnd_atlas=single(jp2img_bnd_atlas).*single(cat(3,1-atlasbnd{r}*cmap(r,1),1-atlasbnd{r}*cmap(r,2),1-atlasbnd{r}*cmap(r,3)));
                else
                    jp2img_bnd_atlas=jp2img_bnd_atlas+uint8(cat(3,segmask0*10*r,zeros(size(segmask0)),zeros(size(segmask0))));
                    % masks for SS
                    segmask1=atlas_region_segment(segmask,regionids.senseids);
                    segmask0=segmask0+segmask1*2;
                    jp2img_bnd_atlas=jp2img_bnd_atlas+uint8(cat(3,zeros(size(segmask0)),segmask0*10*r,zeros(size(segmask0))));
                end
            elseif isa(segmaskdir{r},'logical')
                atlasbnd{r}=segmaskdir{r};
                atlasbndi=imdilate(atlasbnd{r},se);
                % construct the overlay
                jp2img_bnd_atlas=single(jp2img_bnd_atlas).*single(cat(3,1-atlasbndi*cmap(r,1),1-atlasbndi*cmap(r,2),1-atlasbndi*cmap(r,3)));
            end
        end
        % add detected border last
        jp2img_bnd_atlas=uint8(jp2img_bnd_atlas).*cat(3,1-bndmask,1-bndmask,1-bndmask);
        % save images
        imwrite(jp2img_bnd_atlas,[savedir,'/',filename,'_overlay.tif'],'compression','packbit');
        imgdown=imresize(jp2img_bnd_atlas,1/32);
        imwrite(imgdown,[savedir,'/',filename,'_overlay_preview.png'])
        disp('Completed')
    end
end