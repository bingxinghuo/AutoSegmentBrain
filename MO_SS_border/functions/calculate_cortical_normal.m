function [xx1,yy1] =  calculate_cortical_normal(m_smooth, ...
    smooth_shiftedX, smooth_shiftedY, lineLen, lTheta, pt_step, ctxmaskL)

p = 0.00009;
%% get the end points on the line
x2 = smooth_shiftedX(lTheta) + lineLen * sin(m_smooth(lTheta));
y2 = smooth_shiftedY(lTheta) + lineLen * cos(m_smooth(lTheta));

x1 = smooth_shiftedX(lTheta) - lineLen * sin(m_smooth(lTheta));
y1 = smooth_shiftedY(lTheta) - lineLen * cos(m_smooth(lTheta));
%     pause;
% disp(lTheta);
%     plot([y1 y2], [x1 x2], 'r');
% end

%% Calculate points on normal
startp = [x1 y1];
endp = [x2 y2];
m = (endp(2)-startp(2))/(endp(1)-startp(1)+p);
xx = linspace(startp(1), endp(1), pt_step);
if ~(endp(1)-startp(1))
    yy = linspace(startp(2), endp(2), pt_step);
else
    yy = m * (xx-startp(1))+ startp(2);
end

%% Restrict to cortical width
 tabN = true(length(xx), 1);
 if nargin>6
     if ~isempty(ctxmaskL)
         tabN = false(length(xx), 1);
         
         for ii = 1 : length(xx)
             %         cmB(int16(xx(ii)), int16(yy(ii))) = false;
             if ctxmaskL(int16(xx(ii)), int16(yy(ii)))
                 tabN(ii) = true;
             end
         end
     end
 end
idx = find(tabN);
%
%% Resample the profile [0,1]
startp1 = [xx(min(idx)) yy(min(idx))];
endp1 = [xx(max(idx)) yy(max(idx))];
m1 = (endp1(2)-startp1(2))/(endp1(1)-startp1(1)+p);
xx1 = linspace(startp1(1), endp1(1), pt_step);
if ~(endp1(1)-startp1(1))
    yy1 = linspace(startp1(2), endp1(2), pt_step);
else
    yy1 = m * (xx1-startp1(1))+ startp1(2);
end
end