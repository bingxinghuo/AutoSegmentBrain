function dxs = d_runline(x,n,dn)
% d_runline computes a smooth derivative using the runline smoothing
xs=runline1(x,n,dn);
dxs=[0 diff(xs)']; 
end

