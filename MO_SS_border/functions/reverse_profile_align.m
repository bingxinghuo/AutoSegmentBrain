%% reverse_profile_align.m
% This function reverses the profile alignment with respect to a landmark
% (midpoint)
% Inputs:
%   - xpos: a vector containing the x coordinates of points in
%   the flatmap
%   - ypos: a vector containing the y coordinates of points in
%   the flatmap.
%   - centind: Nx2 matrix containing x and y coordinates of the landmark
function [xpos1,ypos1]=reverse_profile_align(xpos,ypos,centind)
centind_common=max(centind);
xshift=centind(:,1)-centind_common(:,1); % column shift
yshift=centind(:,2)-centind_common(:,2); % row shift
xpos1=xpos+xshift;
ypos1=ypos+yshift;
