function [ObsInfo] = getObsData(ObsFileDetaPath,IniInfo,area)
%% 函数说明
%功能：读取obs数据
%% 功能代码
%批处理
for iFile = 1:size(ObsFileDetaPath,1)
    ObsInfo{iFile,1} = getObsDataSing(ObsFileDetaPath{iFile},IniInfo{iFile}.armLength,area);
end

%% 辅助函数1
function ObsTableInfo = getObsDataSing(ObsFileDetaPath,armLength,area)
%%函数说明
%功能：单文件读取
%%功能代码
ObsTableInfo = readtable(ObsFileDetaPath);
%臂长转换
sPoints    = [ObsTableInfo.ant_e0 ObsTableInfo.ant_n0 ObsTableInfo.ant_u0];%发射时刻坐标
rPoints    = [ObsTableInfo.ant_e1 ObsTableInfo.ant_n1 ObsTableInfo.ant_u1];
sAttitude  = [ObsTableInfo.head0  ObsTableInfo.pitch0 ObsTableInfo.roll0];%姿态
rAttitude  = [ObsTableInfo.head1  ObsTableInfo.pitch1 ObsTableInfo.roll1];
for iEpoch = 1:size(ObsTableInfo,1)
    if(strcmp('Japan',area))
        ObsTableInfo.tranEnu0(iEpoch,:) = armCalibration_Japan(armLength',sAttitude(iEpoch,:),sPoints(iEpoch,:));
        ObsTableInfo.tranEnu1(iEpoch,:) = armCalibration_Japan(armLength',rAttitude(iEpoch,:),rPoints(iEpoch,:));
    elseif(strcmp('SouthSea',area))
        ObsTableInfo.tranEnu0(iEpoch,:) = armCalibration_SouthSea(armLength',sAttitude(iEpoch,:),sPoints(iEpoch,:));
        ObsTableInfo.tranEnu1(iEpoch,:) = armCalibration_SouthSea(armLength',rAttitude(iEpoch,:),rPoints(iEpoch,:));
    else
        error('地区选择错误！');
    end
end

%% 辅助函数2
function [transducerPoint] = armCalibration_Japan(armLength,attitude,convPoint)
%%函数说明
%功能：日本臂长转换
%%功能代码
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

%% 辅助函数3
function [TransducerPoint] = armCalibration_SouthSea(armLength,attitude,ConversionPoint)
%%函数说明
%功能：南海臂长转换
%%功能代码
h = attitude(1)*pi/180;
p = attitude(2)*pi/180;
r = attitude(3)*pi/180;
%旋转矩阵
Rh = [cos(h) -sin(h) 0
      sin(h) cos(h)  0
      0      0       1];
Rp = [cos(p) 0 -sin(p)        
      0      1    0
      sin(p) 0 cos(p)];       
Rr = [1    0      0
      0 cos(r) -sin(r)
      0 sin(r) cos(r)];
R = Rh * Rp * Rr;

RR = [R(2,:);R(1,:);R(3,:)];
RRR = [RR(:,2) RR(:,1) RR(:,3)];

TransducerPoint =  (RRR * armLength)' +  ConversionPoint;