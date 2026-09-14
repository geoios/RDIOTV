function [t,y,z,l,sinTheta] = rayTrack(ssp,theta0,trackH)
%% 函数说明
%功能：声线跟踪(ssp，theta弧度制，trackH正值)
%% 功能代码
p = sin(theta0*pi/180)/ssp(1,2);
sinTheta(1,1) = sin(theta0*pi/180);
for i = 1:size(ssp,1)-1
    ssp_iFloor = ssp(i:i+1,:);
    [ti(i,1),yi(i,1),zi(i,1),li(i,1)] = rayTrack_singLayer_ds(ssp_iFloor,p);
    sinTheta(i+1,1) = p*ssp_iFloor(2,2);
    %最后一层
    if(sum(zi) == trackH)%情况1
        t = sum(ti);
        y = sum(yi);
        z = sum(zi);
        l = sum(li);
        break;
    elseif(sum(zi) > trackH)%情况2
        zi_last = trackH - sum(zi(1:end-1));
        [ti_last,yi_last,zi_last,li_last] = rayTrack_singLayer_ds(ssp_iFloor,p,zi_last);
        t = sum(ti(1:end-1)) + ti_last;
        y = sum(yi(1:end-1)) + yi_last;
        z = sum(zi(1:end-1)) + zi_last;
        l = sum(li(1:end-1)) + li_last;

        c = interp1(ssp_iFloor(:,1),ssp_iFloor(:,2),ssp_iFloor(1,1)+zi_last,"linear");
        sinTheta(end,1) = p*c;
        break;
    end
end

%% 辅助函数
function [dti,dyi,dzi,dli] = rayTrack_singLayer_dz(ssp_iFloor,p,dzi)
%%函数说明
%功能：第i层常梯度声线跟踪_zi、zi+1（赵建虎）
%%功能代码
deltaSsp = ssp_iFloor(2,:) - ssp_iFloor(1,:);
gi = deltaSsp(2)/deltaSsp(1);%梯度
if(nargin == 2)
    dzi = deltaSsp(1);%层深度
end
Ci = ssp_iFloor(1,2);%声速
%水平距、传播时间、斜距、出射角
if(p ~= 0 && gi ~= 0)%常梯度
    dyi = ((1-(p*Ci)^2)^(1/2)-(1-(p*(Ci+gi*dzi))^2)^(1/2)) / (p*gi);
    dti = (asin(p*(Ci+gi*dzi))-asin(p*Ci)) / (p*gi^2*dzi) * log(1+(gi*dzi)/(Ci));
elseif(p ~= 0 && gi == 0)%常声速
    dyi = (p*Ci*dzi)/(1-(p*Ci)^2)^(1/2);
    dti = (dzi)/(Ci*(1-(p*Ci)^2)^(1/2));
elseif(p == 0 && gi ~= 0)%入射角为0
    dyi = 0;
    dti = (1/gi*(log(Ci+gi*dzi))) - (1/gi*log(Ci));
elseif(p == 0 && gi == 0)%入射角为0
    dyi = 0;
    dti = dzi/Ci;
end
dli = sqrt(dzi^2 + dyi^2);

%% 辅助函数2
function [dti,dyi,dzi,dli] = rayTrack_singLayer_ds(ssp_iFloor,p,dzi)
%%函数说明
%功能：第i层常梯度声线跟踪_zi、zi+1（陆秀平，2012）
%%功能代码
deltaSsp = ssp_iFloor(2,:) - ssp_iFloor(1,:);
gi = deltaSsp(2)/deltaSsp(1);%梯度
if(nargin == 2)
    dzi = deltaSsp(1);%层深度
end
Ci = ssp_iFloor(1,2);%声速
%水平距、传播时间、斜距、出射角
if(p ~= 0 && gi ~= 0)%常梯度
    dyi = ((1-(p*Ci)^2)^(1/2)-(1-(p*(Ci+gi*dzi))^2)^(1/2)) / (p*gi);
    dti = 1/gi * log( ((Ci+gi*dzi)*(1+(1-(p*Ci)^2)^(1/2))) / (Ci*(1+(1-(p*(Ci+gi*dzi))^2)^(1/2))) );
elseif(p ~= 0 && gi == 0)%常声速
    dyi = (p*Ci*dzi)/(1-(p*Ci)^2)^(1/2);
    dti = (dzi)/(Ci*(1-(p*Ci)^2)^(1/2));
elseif(p == 0 && gi ~= 0)%入射角为0
    dyi = 0;
    dti = 1/gi * log(((Ci+gi*dzi)*(1+(1-(p*Ci)^2)^(1/2))) / (Ci*(1+(1-(p*(Ci+gi*dzi))^2)^(1/2))));
elseif(p == 0 && gi == 0)%入射角为0
    dyi = 0;
    dti = dzi/Ci;
end
dli = sqrt(dzi^2 + dyi^2);
