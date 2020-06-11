%% profile_calc.m
% This script converts cortex histology image into flat profile
% Credit: Samik Banerjee, Cold Spring Harbor Laboratory 2020
function mop_border = profile_calc(ctxmask, nisslimg)
%%  Inputs :

%% Initializations

p = 0.00009; % epsilon
% pt_step = 1000; % sampling size along normal
% ft = [];
% flatIndex = []; % storage for index
delta = 1000; % smoothing parameter
% lineLen = 1500; % Length of Normal

sampling = 1; % use 1 for full size
%% Use for downsizing
% orgL = org(1:sampling:end,1:sampling:end,:);
ctxmaskL = ctxmask(1:sampling:end,1:sampling:end);


sigma = 51;
wsize = 101;
h = fspecial('gaussian', [wsize wsize], sigma);
nisslimgG = imfilter(single(nisslimg), h, 'replicate');
nisslimgL = nisslimgG(1:sampling:end,1:sampling:end) .* ctxmaskL; % mask along cortex boundary

%% Get medial axis and angle from centroid
[shiftedX, shiftedY, shiftedTheta,centroid,theta] = get_medial_axis(ctxmaskL);

%% Smoothing spline fit and the angle of the normal
smooth_shiftedY = runline1(shiftedY, 1000, 1);
smooth_shiftedX = runline1(shiftedX, 1000, 1);
d_smooth_shiftedX = d_runline(shiftedX, 1000, 1);
d_smooth_shiftedY = d_runline(shiftedY, 1000, 1);

m_smooth = atan2(-d_smooth_shiftedY,d_smooth_shiftedX);

%% flatten the cortical density map
[ft,flatIndex]=flattencortex(nisslimgL,m_smooth, smooth_shiftedX, smooth_shiftedY,ctxmaskL);

%% save all intermediate results
mop_border.ft=ft;
mop_border.shiftedX=shiftedX;
mop_border.shiftedY=shiftedY;
mop_border.shiftedTheta=shiftedTheta;
mop_border.centroid=centroid;
mop_border.flatIndex=flatIndex;
mop_border.smooth_shiftedX=smooth_shiftedX;
mop_border.smooth_shiftedY=smooth_shiftedY;
mop_border.theta=theta;
mop_border.m_smooth=m_smooth;
