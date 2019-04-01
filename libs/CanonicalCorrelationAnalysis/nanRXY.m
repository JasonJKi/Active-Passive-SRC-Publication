function [Rxy,Rxx,Ryy,Ryx] = nanRXY(X,Y)
% Compute covariance with nan values
D=size(X,2);
RxyNan=nancov([X Y],'pairwise');
Rxx=RxyNan(1:D,1:D);
Ryy=RxyNan(D+1:end,D+1:end);
Rxy=RxyNan(1:D,D+1:end);
Ryx=RxyNan(D+1:end,1:D);
