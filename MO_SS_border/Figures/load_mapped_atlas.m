%% load_mapped_atlas.m
% This function load the mapped atlas segmentation of a particular section
% input: 
%   - segmaskdir: the directory that contains the registered segmantation
%   mask
%   - filename: the section ID 
% output:
%   - segmask: the mapped atlas segmentation
function segmask=load_mapped_atlas(segmaskdir,filename)
if isempty(str2double(filename(end))) % last element in the file name is not a number
    [~,filename,~]=fileparts(filename); % remove extension
end
segmask=load(fullfile(segmaskdir,[filename,'.mat']));
segmask=segmask.seg;