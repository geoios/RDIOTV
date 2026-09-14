function [velo] = meanVelo(ssp)
%% 函数说明
%功能：计算加权平均声速
%% 功能代码
area = trapz(ssp(:,1),ssp(:,2));
velo = area/(ssp(end,1)-ssp(1,1));
