%% find_bnd_nrml_pts.m
% This script converts lines in flat profile into cortical normals
% Credit: Samik Banerjee, Cold Spring Harbor Laboratory 2020
function cortical_normals=find_bnd_nrml_pts(bndpos_profile,filelist1,savedir)
% load('L5boundposition.mat');

% direc = dir('DK5_630/*.mat');

RIndex = bndpos_profile.right;
LIndex = bndpos_profile.left;
if nargin<3
    savedir='./';
end
% cortical_normals(length(filelist1)) = struct();
for i = 1 : length(filelist1)
    %     disp(direc(i).name);
    disp(filelist1{i})
    [~,filename,~]=fileparts(filelist1{i});
    %     load(['DK5_630/' direc(i).name]);
    M=matfile([savedir,filename,'.mat']);
    ctxmask=M.ctxmask;
    BL=false(size(ctxmask));
    try
        mop_border=M.mop_border;
    catch
        mop_border=[];
    end
    %         load([savedir,filename,'.mat'],'ctxmask','mop_border')
    cortical_normals(i).right = [];
    if ~isempty(mop_border)
        if(~isnan(RIndex(i,1)) && RIndex(i,1)>0)
            [cortical_normals(i).right(:,1),cortical_normals(i).right(:,2)] = ...
                calculate_cortical_normal( ...
                mop_border.m_smooth, ...
                mop_border.smooth_shiftedX, ...
                mop_border.smooth_shiftedY, ...
                1000, ... % line length
                mop_border.flatIndex(floor(RIndex(i,1))), ...
                1000, ... % pt_step
                ctxmask);
            for j=1:size(cortical_normals(i).right,1)
                BL(round(cortical_normals(i).right(j,1)),round(cortical_normals(i).right(j,2)))=true;
            end
        end
        if(~isnan(LIndex(i,1))&& LIndex(i,1)>0)
            [cortical_normals(i).left(:,1),cortical_normals(i).left(:,2)] = ...
                calculate_cortical_normal( ...
                mop_border.m_smooth, ...
                mop_border.smooth_shiftedX, ...
                mop_border.smooth_shiftedY, ...
                1000, ... % line length
                mop_border.flatIndex(floor(LIndex(i,1))), ...
                1000, ... % pt_step
                ctxmask);
            for j=1:size(cortical_normals(i).left,1)
                BL(round(cortical_normals(i).left(j,1)),round(cortical_normals(i).left(j,2)))=true;
            end
        end
    end
    save([savedir,filename,'.mat'],'BL','-append')
end

% save('boundary_normal_pts.mat', 'cortical_normals');


% RIndex(Rindex)