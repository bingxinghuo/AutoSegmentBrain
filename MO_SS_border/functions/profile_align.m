%% profile_align.m
% This script aligns all the flattened profiles and atlas
% continue from script_mopBorder_BH_May24.m
%% load all profiles and flattened segmentations
for f = seci
    segft=cell(2,1);
    tic;
    disp(['Processing ',filelist{f},'...']);
    [~,filename,~]=fileparts(filelist{f}); % get file name
    savefile=fullfile(savedir,[filename,'.mat']);
    if exist(savefile,'file')
        try
            profiles(f-seci(1)+1)=load(savefile,'mop_border');
            flatatlas(f-seci(1)+1)=load(savefile,'segft');
        catch
            disp(['No data for ',filename,'.'])
        end
    end
end
%% align medial axes
[medaxX_a,medaxY_a,midx,midy]=medial_axis_align(profiles);
%  z=[1:L]*20/.92;
%  figure, plot3(medaxX_a,medaxY_a,z)
%% find middle points in the flatmap
centind=zeros(length(profiles),2);
for i=1:L
    mop_border=profiles(i).mop_border;
    if ~isempty(mop_border)
        % find the coordinates of the midpoint in flatmap
        [~,kXft]=min(abs(mop_border.flatIndex-midx(i)));
        centind(i,:)=[kXft,size(mop_border.ft,1)/2];
    else
        kXft=0;
        centind(i,:)=[kXft,0];
    end
end
%% alternative centroid by theta=0
% centind=zeros(length(profiles),2);
% for i=1:length(profiles)
%     mop_border=profiles(i).mop_border;
%     % find the coordinate shift during flattening
%     [sortedTheta, idxTheta] = sort(mop_border.theta);
%     dtheta = diff(sortedTheta);
%     [idxJ, ~] = find(abs(dtheta)>0.1);
%     % reverse shift to find the coordinates of centroids in flatmap
%     [~,kX]=min(abs(mop_border.centroid(1)-circshift(mop_border.shiftedX,idxJ)));
%     [~,kXft]=min(abs(mop_border.flatIndex-kX));
%     [~,kY]=min(abs(mop_border.centroid(2)-circshift(mop_border.shiftedY,idxJ)));
%     [~,kYft]=min(abs(mop_border.flatIndex-kY));
%     centind(i,:)=[kXft,500];
% end
%% assemble cell arrays containing the flattend images
ftall=cell(L,1); % cortical profiles
atlasft=cell(length(segmaskdir),1); % atlas segmentation for cortex
bndmask=cell(length(segmaskdir),1);  % MO-SS border in the atlas
for i=1:L
    mop_border=profiles(i).mop_border;
    if ~isempty(mop_border)
        ftall{i}=flip(mop_border.ft);
        for r=1:length(flatatlas(i).segft)
            atlasft{r}{i}=flip(flatatlas(i).segft{r});
            bndmask{r}{i}=mo_ss_atlas_border(atlasft{r}{i},regionids.motorids,regionids.senseids);
        end
    end
end
%% align as stacks and save in images
ftstack=flatstack(ftall,centind,[savedir,'wholeprofile3d.tif']);
for r=1:length(segmaskdir)
    namei=strfind(segmaskdir{r},'_pad');
    if length(segmaskdir{r})<=namei+4
        atlasname='_V3';
    else
        atlasname=segmaskdir{r}(namei+4:end);
    end
    flatstack(atlasft{r},centind,[savedir,'flatatlasstack',atlasname,'.tif']);
    flatstack(bndmask{r},centind,[savedir,'MO_SS_border',atlasname,'.tif']);
end
%%