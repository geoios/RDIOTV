function [t,y,z,l,theta0,iLoop] = invRayTrack(launPoin,reciPoin,ssp)
%% 函数说明
%功能：声线跟踪反问题
%% 功能代码
%声速剖面截取
if(ssp(1,1)<=abs(launPoin(3)) && ssp(end,1)>=abs(reciPoin(3)))
    [ssp_cut] = cutSsp(abs(launPoin(3)),ssp(end,1),ssp);
else
   error('声速剖面深度范围过小！');
end
%迭代搜索入射角并声线跟踪
trachH = abs(reciPoin(3)-launPoin(3));
trachY = norm(reciPoin(1:2)-launPoin(1:2));
maxIter = 20;
term = 10^-6;
deltaSita = 10^(-6);
theta_temp(1) = atan(trachY/trachH)*180/pi;
for iLoop = 1:maxIter
    %牛顿法
    [~,y1] = rayTrack(ssp_cut,theta_temp(iLoop),trachH);
    [~,y2] = rayTrack(ssp_cut,theta_temp(iLoop)+deltaSita,trachH);
    res1 = y1 - trachY;
    res2 = y2 - trachY;
    k = (res1 - res2)/deltaSita;
    if(trachY == 0)
        theta_temp(iLoop+1) = 0;
    else
        theta_temp(iLoop+1) = theta_temp(iLoop) + res1/k;
    end
    %迭代截止条件
    if(abs(theta_temp(iLoop+1) - theta_temp(iLoop)) < term || iLoop == maxIter)
        theta0 = theta_temp(iLoop+1);
        [t,y,z,l] = rayTrack(ssp_cut,theta0,trachH);
        break;
    end
end