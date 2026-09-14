function [IniData, ObsData, MP] = preCalc(IniData, ObsData)
%% 函数说明
% 功能：预计算

% 传参
MPNum = IniData.MPNum;
spdeg = IniData.spdeg;
tranEnu0 = ObsData.tranEnu0;
tranEnu1 = ObsData.tranEnu1;
N_shot = IniData.Data_file.N_shot;

% 1. 提取坐标参数
initTprCoor = [];
paramFields = fieldnames(IniData.Model_parameter);
for i = 1:length(paramFields)
    if contains(paramFields{i}, '_dPos')
        fieldValue = getfield(IniData.Model_parameter, paramFields{i});
        initTprCoor = [initTprCoor, fieldValue(1:3)];
    end
end
MPNum = [length(initTprCoor), MPNum];
MPNum = cumsum(MPNum);
MP = zeros(1,MPNum(end));
MP(1:MPNum(1)) = initTprCoor;
IniData.MPNum = MPNum;

% 2. 计算各历元对应测站位置标识
Stations = strsplit(IniData.Site_parameter.Stations, ' ');
for i = 1:length(Stations)
    matchIdx = strcmp(ObsData.MT, Stations{i});
    ObsData.MTPSign(matchIdx,1) = (i - 1) * 3 + 1; % 在MP中的位置
end

% 3. 计算方位角与天顶角
% 计算天线坐标均值
surfAntMean_ST = [mean(ObsData.ant_e0) mean(ObsData.ant_n0)];
surfAntMean_RT = [mean(ObsData.ant_e1) mean(ObsData.ant_n1)];
IniData.surfAntMean_ST = surfAntMean_ST; 
IniData.surfAntMean_RT = surfAntMean_RT;

% 逐历元计算角度
for ShotNum = 1:N_shot
    index = ObsData.MTPSign(ShotNum);
    tranEnu_ST = tranEnu0(ShotNum,:);
    tranEnu_RT = tranEnu1(ShotNum,:);
    % 方位角（基准-船）
    alpha0_Vessel(ShotNum,1) = getAzimuth(surfAntMean_ST, tranEnu_ST(1:2));
    z0_Vessel(ShotNum,1) = norm(tranEnu_ST(1:2)-surfAntMean_ST) / -(initTprCoor(index+2)-tranEnu_ST(3));
    % 天顶角（基准-船）
    alpha1_Vessel(ShotNum,1) = getAzimuth(surfAntMean_RT, tranEnu_RT(1:2));
    z1_Vessel(ShotNum,1) = norm(tranEnu_RT(1:2)-surfAntMean_RT) / -(initTprCoor(index+2)-tranEnu_RT(3));
end
% 存储
ObsData.alpha0_Vessel = alpha0_Vessel;
ObsData.alpha1_Vessel = alpha1_Vessel;
ObsData.z0_Vessel = z0_Vessel;
ObsData.z1_Vessel = z1_Vessel;

% 4. 预计算组合数列表
for j = 0:spdeg
    IniData.nchoosekList(j + 1) = nchoosek(spdeg+1,j);
end
