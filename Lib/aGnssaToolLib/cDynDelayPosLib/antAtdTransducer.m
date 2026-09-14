function [ObsData] = antAtdTransducer(IniData, ObsData)
%% 函数说明
% 功能：臂长转换

% 臂长
armLength = IniData.Model_parameter.ATDoffset(1:3);

% 天线及姿态
sPoints    = [ObsData.ant_e0 ObsData.ant_n0 ObsData.ant_u0];%发射时刻坐标
rPoints    = [ObsData.ant_e1 ObsData.ant_n1 ObsData.ant_u1];
sAttitude  = [ObsData.head0  ObsData.pitch0 ObsData.roll0];%姿态
rAttitude  = [ObsData.head1  ObsData.pitch1 ObsData.roll1];

% 转换
for iEpoch = 1:length(ObsData.TT)
    ObsData.tranEnu0(iEpoch,:) = armCalibration_Japan(armLength',sAttitude(iEpoch,:),sPoints(iEpoch,:));
    ObsData.tranEnu1(iEpoch,:) = armCalibration_Japan(armLength',rAttitude(iEpoch,:),rPoints(iEpoch,:));
end


%% 辅助函数
function [transducerPoint] = armCalibration_Japan(armLength, attitude, convPoint)
%%函数说明
% 功能：天线位置到换能器位置
h = attitude(1)*pi/180;
p = attitude(2)*pi/180;
r = attitude(3)*pi/180;
%旋转矩阵
Rf = [0 1 0
      1 0 0
      0 0 -1];
Rh = [cos(h) -sin(h) 0
      sin(h) cos(h)  0
      0      0       1];
Rp = [cos(p) 0 sin(p)  
      0      1    0
      -sin(p) 0 cos(p)];
Rr = [1    0      0
      0 cos(r) -sin(r)
      0 sin(r) cos(r)];
R = Rf * Rh * Rp * Rr;
%转换结果
transducerPoint =  (R * armLength)' +  convPoint;

