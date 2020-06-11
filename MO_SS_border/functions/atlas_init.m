%% init 1: atlas directory
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
%% init 2: necessary files for transformation
atlas_vtk = [atlasdir,'average_template_25.vtk']; % reference brain
deformation_file=[imgdir0,brainID,'/Registration_OUTPUT/atlas_to_registered_displacement.vtk'];
geometry_file=[imgdir0,brainID,'/INPUT_DATA/geometry.csv'];
atlas_anno_vtk=[atlasannodir,'annotation_25.vtk']; % annotation