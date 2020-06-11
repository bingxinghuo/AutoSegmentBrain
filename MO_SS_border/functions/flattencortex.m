%% flattencortex.m
% This script flattens the curved cortex
% Credit: Samik Banerjee, Cold Spring Harbor Laboratory 2020
function [ft,flatIndex]=flattencortex(nisslimgL,m_smooth, smooth_shiftedX, smooth_shiftedY,ctxmaskL)
pt_step = 1000; % sampling size along normal
lineLen = 1500; % Length of Normal
ft = [];
flatIndex = []; % storage for index
if nargin<5
    ctxmaskL=[];
end
for lTheta = 2 : 8 : length(m_smooth)
    flatIndex = [flatIndex lTheta];
    %     disp(lTheta);
    [xx1,yy1] =  calculate_cortical_normal(m_smooth, ...
        smooth_shiftedX, smooth_shiftedY, ...
        lineLen, lTheta, pt_step, ctxmaskL);
    
    %% Along the normal calcuate the profile
    ftN = [];
    for j = 1 : length(xx1)
        dnstyMat = nisslimgL(int16(xx1(j)), int16(yy1(j)));
        ftN = [ftN; dnstyMat];
    end
    
    %% Flattening of the cortical density map
    ft = [ft ftN];
    %     plot(yy1, xx1, 'r')
end