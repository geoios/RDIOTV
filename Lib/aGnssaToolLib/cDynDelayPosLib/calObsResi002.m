function [ObsData] = calObsResi(IniData, ObsData, SvpData, MP)
%% 函数说明
% 功能：计算观测残差

% 传参
N_shot = IniData.Data_file.N_shot;
MTPSign = ObsData.MTPSign;
transducer0 = ObsData.tranEnu0;
transducer1 = ObsData.tranEnu1;
ST = ObsData.ST;
RT = ObsData.RT;
alpha0_Vessel = ObsData.alpha0_Vessel;
alpha1_Vessel = ObsData.alpha1_Vessel;
z0_Vessel = ObsData.z0_Vessel;
z1_Vessel = ObsData.z1_Vessel;

% 计算传播时间
for ShotNum = 1:N_shot
    index = MTPSign(ShotNum);
    tranEnu_ST = transducer0(ShotNum,:);
    tranEnu_RT = transducer1(ShotNum,:);

    % 方位角（船-应答器）
    alpha0_Ray(ShotNum,1) = getAzimuth(tranEnu_ST(1:2), MP(index:index+1));
    alpha1_Ray(ShotNum,1) = getAzimuth(tranEnu_RT(1:2), MP(index:index+1));
    % 天顶角（船-应答器）
    H0 = -(MP(index+2)-tranEnu_ST(3)); 
    H1 = -(MP(index+2)-tranEnu_RT(3));
    z0_Ray(ShotNum,1) = norm(tranEnu_ST(1:2)-MP(index:index+1)) / H0;
    z1_Ray(ShotNum,1) = norm(tranEnu_RT(1:2)-MP(index:index+1)) / H1;
    % 合并角
    alpha0(ShotNum,:) = [alpha0_Vessel(ShotNum,1) alpha0_Ray(ShotNum,1)];
    alpha1(ShotNum,:) = [alpha1_Vessel(ShotNum,1) alpha1_Ray(ShotNum,1)];
    z0(ShotNum,:) = [z0_Vessel(ShotNum,1) z0_Ray(ShotNum,1)];
    z1(ShotNum,:) = [z1_Vessel(ShotNum,1) z1_Ray(ShotNum,1)];
    % 存储合并角
    ObsData.alpha0(ShotNum,:) = alpha0(ShotNum,:);
    ObsData.alpha1(ShotNum,:) = alpha1(ShotNum,:);
    ObsData.z0(ShotNum,:) = z0(ShotNum,:);
    ObsData.z1(ShotNum,:) = z1(ShotNum,:);
    
    % 1. 声线跟踪
    [t0] = invRayTrack(tranEnu_ST, MP(index:index+2), SvpData(:,1:2));
    [t1] = invRayTrack(tranEnu_RT, MP(index:index+2), SvpData(:,1:2));

    % 2. 动态延迟补偿
    [detalL0, grad0, detalTofZ0] = calcDynamicDelay(ST(ShotNum), MP, z0(ShotNum,:), alpha0(ShotNum,:), IniData);
    [detalL1, grad1, detalTofZ1] = calcDynamicDelay(RT(ShotNum), MP, z1(ShotNum,:), alpha1(ShotNum,:), IniData);
    compensateL = detalL0 + detalL1;
    ObsData.CompensateL(ShotNum,1) = compensateL;

    ObsData.grad0(ShotNum,1) = -sum(grad0);
    ObsData.grad1(ShotNum,1) = -sum(grad1);
    
    % 3. 总的时间
    ObsData.ModelL(ShotNum,:) = (t0+t1) + compensateL; 

    % 声速时空变化值（视线方向） 
    [ObsData] = invLosSoundVel002(ObsData, SvpData, tranEnu_ST, tranEnu_RT, MP, index, detalTofZ0, detalTofZ1, ShotNum);
    [ObsData] = invLosSoundVel002V(IniData, ObsData, SvpData, tranEnu_ST, tranEnu_RT, MP, H0, H1, grad0, grad1, index, ShotNum);
end

% 4. 计算残差
ObsData.detalL = ObsData.TT - ObsData.ModelL;

% 5. 残差粗差剔除标记
[ObsData] = markError(ObsData);


%% 辅助函数
function [ObsData] = markError(ObsData)
%%函数说明
% 功能：3.5σ 粗差标记

% 获取有效观测索引（flag为False的观测值）
validIdx = strcmp(ObsData.flag, 'False');
FalseIndex = find(validIdx);

% 计算有效残差的均值与标准差
residualMean = mean(ObsData.detalL(FalseIndex));
residualStd  = std(ObsData.detalL(FalseIndex));

% 计算3.5倍标准差上下限
upperLimit = residualMean + 3.5 * residualStd;
lowerLimit = residualMean - 3.5 * residualStd;

% 遍历剔除粗差，标记异常值
for j = 1:length(ObsData.TT)
    currentResidual = ObsData.detalL(j);
    if currentResidual < lowerLimit || currentResidual > upperLimit
        ObsData.flag{j} = 'True';   % 标记为异常值（剔除）
    else
        ObsData.flag{j} = 'False';  % 标记为有效值
    end
end