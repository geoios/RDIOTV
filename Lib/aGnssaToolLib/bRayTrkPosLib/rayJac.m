function [ei,t,theta0,altiAng] = rayJac(launPoin,reciPoin,ssp)
%% 函数说明
%功能：求解声线跟踪雅可比矩阵
%% 功能代码
%声线跟踪反问题
[t,y,z,l,theta0,loop] = invRayTrack(launPoin,reciPoin,ssp);
%计算雅可比矩阵
deltaCoor = launPoin - reciPoin;
if(norm(deltaCoor(1:2)) == 0)
    sin_beta = 0; % 水平方向上的角度为零
    cos_beta = 0; 
    sin_alfa = 1; % 高度角为垂直向上
    cos_alfa = 0;
else
    sin_beta = deltaCoor(2) / norm(deltaCoor(1:2));
    cos_beta = deltaCoor(1) / norm(deltaCoor(1:2));
    sin_alfa = deltaCoor(3) / norm(deltaCoor);
    cos_alfa = norm(deltaCoor(1:2)) / norm(deltaCoor);
end
ei(1) = cos_beta * cos_alfa;%beta方位角；alfa高度角
ei(2) = sin_beta * cos_alfa;
ei(3) = sin_alfa;

%高度角
altiAng = asin(sin_alfa)*180/pi;
