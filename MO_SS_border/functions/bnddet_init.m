%% This script initializes files and folders for subsequent scripts and should be modified
%% init 1: server directory to connect to M drives
serverdir='~/CSHLservers/mitragpu5/';
keepdir=input(['Accept the server dir at ',serverdir,'? (y/n) '],'s');
if strcmpi(keepdir,'n')
    serverdir='';
    while ~exist(serverdir,'dir')
        serverdir=input('Please enter the path to where the M drives are mounted: ','s');
    end
end
%% init 2: saving directory to save outputs
savedir0='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/Joint_Analysis/MOborder/';
keepdir=input(['Accept the saving dir at ',savedir0,'? (y/n) '],'s');
if strcmpi(keepdir,'n')
    savedir0='';
    while ~exist(savedir0,'dir')
        savedir0=input('Please enter the path to parent directory where the output should be saved: ','s');
    end
end
%% init 3: brain ID
imgdir0=[serverdir,'M32/RegistrationData/Data/']; % currently all data are saved in M32
datadir='';
while ~exist(datadir,'dir')
    brainID=input('Please enter the brain ID: ','s');
    datadir=fullfile(imgdir0,brainID);
end
%% init 4: derived subfolders
% 4.1 jp2 image folder
transformdir=[datadir,'/Transformation_OUTPUT/'];
% transformdir=[imgdir0,'/',brainID,'/Transformation_OUTPUT_lossybackup/']; % PMD2057
imgdir=search_mba_transformjp2(imgdir0,brainID,transformdir);
cd(imgdir)
filelist=filelsread('*N*.jp2','~/'); % read all Nissl images and sort by their section numbers
% 4.2 segmentation folders
if strcmpi(brainID(1),'D')
    segmaskdir{1}=fullfile(transformdir,'reg_high_seg_pad_V3');
elseif strcmpi(brainID(1),'P')
    segmaskdir{1}=fullfile(transformdir,'reg_high_seg_pad');
end
% segmaskdir{2}=fullfile(datadir,'Transformation_OUTPUT/reg_high_seg_pad_V2');
% segmaskdir{3}=fullfile(datadir,'/Transformation_OUTPUT/reg_high_seg_pad__Osten');
% 4.3 output folder
savedir=[savedir0,'/',brainID,'/'];
if ~exist(savedir,'dir')
    mkdir(savedir)
end
%% init 5: output file for volume-wise data
volsavefile=[savedir,brainID,'_MO_SS_border.mat'];
%% init 6: atlas directory
atlasdir='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/MouseBrainAtlases/AllenMouseBrainAtlas/Standardized/Average_Template/';
keepdir=input(['Accept the atlas dir at ',atlasdir,'? (y/n) '],'s');
if strcmpi(keepdir,'n')
    atlasdir='';
    while ~exist(atlasdir,'dir')
        atlasdir=input('Please enter the path to parent directory where the atlas vtk is: ','s');
    end
end
% 
atlasannodir='~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/MouseBrainAtlases/AllenMouseBrainAtlas/Standardized/Annotation/CCF3_2017/';
keepdir=input(['Accept the atlas annotation dir at ',atlasannodir,'? (y/n) '],'s');
if strcmpi(keepdir,'n')
    atlasannodir='';
    while ~exist(atlasannodir,'dir')
        atlasannodir=input('Please enter the path to parent directory where the atlas vtk is: ','s');
    end
end
