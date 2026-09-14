function [ObsData] = invLosSoundVel(ObsData, svpData, tranEnu_ST, tranEnu_RT, MP, index, detalTofZ0, detalTofZ1, ShotNum)
%% 函数说明
% 功能：反演温度

% 提取声速剖面核心数据
depth = svpData(:, 1);           % 深度
soundSpeed = svpData(:, 2);      % 声速
dcDt = svpData(:, 3);            % 声速对温度的偏导数 ∂c/∂T
temperature = svpData(:, 4);     % 温度

% 提取收发端深度（取绝对值）
souH1 = abs(tranEnu_ST(3));    % 发射端深度
souH2 = abs(tranEnu_RT(3));  % 接收端深度
aimH = abs(MP(index + 2));   % 目标深度

% 计算平均深度与垂直高度差
souH = (souH1 + souH2) / 2;
h = abs(aimH - souH);  % 积分高度差

% 计算t0
tempProfileCut = cutSsp(souH, aimH, [depth, temperature]);
t0 = trapz(tempProfileCut(:, 1), tempProfileCut(:, 2)) / h;

% 计算dt
newProfile = [depth, dcDt ./ soundSpeed.^2];
newProfileCut = cutSsp(souH, aimH, newProfile);
integralVal = trapz(newProfileCut(:, 1), newProfileCut(:, 2));

deltaTofZAvg = (detalTofZ0 + detalTofZ1) / 2;
dt = - deltaTofZAvg / integralVal;

% 保存
ObsData.deltaTofZAvg(ShotNum,1) = deltaTofZAvg;
ObsData.T(ShotNum,1) = t0 + dt;
ObsData.dT(ShotNum,1) = dt;