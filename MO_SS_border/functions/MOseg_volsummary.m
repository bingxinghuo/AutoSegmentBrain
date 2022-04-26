serverdir='~/CSHLservers/mitragpu3/';
brainID='DK5';
cd([serverdir,'/Cell_Detection/CellDetPass1_Nissl/res/results'])
voxsize=[10,10,20];
filelist=filelsread('*.mat','~/',4);
xydim=round(24000*.46*2/voxsize(1));
mosegvol=uint8(zeros(xydim,xydim,length(filelist)));
secnums=findsection(filelist,[238,274]);
for i=secnums(1):secnums(2)
    img=load(filelist{i});
    img=img.BL;
    imgs=imresize(img,.46*2/10);
    mosegvol(:,:,i)=uint8(imgs>0)*255;
end
%% transform into atlas space
imgdir0=[serverdir,'/RegistrationData/Data/'];
atlas_vtk = '~/Dropbox (Mitra Lab)/Data and Analysis/Mouse/MouseBrainAtlases/AllenMouseBrainAtlas/Standardized/Average_Template/average_template_10.vtk';
deformation_file=[imgdir0,brainID,'/Registration_OUTPUT/atlas_to_registered_displacement.vtk'];
geometry_file=[imgdir0,'/',brainID,'/INPUT_DATA/geometry.csv'];
mosegvolatlas=transform_reg_to_atlas(mosegvol,voxsize,geometry_file,deformation_file,atlas_vtk);
mosegvolatlas=uint8(mosegvolatlas);
save('~/DK5_MOsegment_atlas','mosegvolatlas','-v7.3')
%% save in tif
mosegvolatlas_25=imresize3(mosegvolatlas,10/25);
imwrite(mosegvolatlas_25(:,:,1),'~/DK5_MOsegment_atlas_25.tif','writemode','overwrite','compression','packbit')
for j=2:size(mosegvolatlas_25,3)
    imwrite(mosegvolatlas_25(:,:,j),'~/DK5_MOsegment_atlas_25.tif','writemode','append','compression','packbit')
end