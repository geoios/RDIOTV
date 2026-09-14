function [IniDataStruct, SvpDataStruct, ObsDataStruct] = readGnssaData(impoIniPath, impoSvpPath, impoObsPath)
%% 函数说明
% 功能：读取GNSS-A数据

% 文件路径
[IniFileDetaPath] = getFileDetaPath(impoIniPath,'*-initcfg.ini');
[SvpFileDetaPath] = getFileDetaPath(impoSvpPath,'*-svp.csv');
[ObsFileDetaPath] = getFileDetaPath(impoObsPath,'*-obs.csv');

% 读取文件
for i = 1:length(IniFileDetaPath)
    [IniDataStruct{i,1}] = readIniData(IniFileDetaPath{i});
    [SvpDataStruct{i,1}] = readSvpData(SvpFileDetaPath{i});
    [ObsDataStruct{i,1}] = readObsData(ObsFileDetaPath{i});
end

% 臂长转换
for i = 1:length(IniFileDetaPath)
    armLength  = IniDataStruct{i}.Model_parameter.ATDoffset(1:3);
    sPoints    = [ObsDataStruct{i}.ant_e0 ObsDataStruct{i}.ant_n0 ObsDataStruct{i}.ant_u0];
    rPoints    = [ObsDataStruct{i}.ant_e1 ObsDataStruct{i}.ant_n1 ObsDataStruct{i}.ant_u1];
    sAttitude  = [ObsDataStruct{i}.head0  ObsDataStruct{i}.pitch0 ObsDataStruct{i}.roll0];
    rAttitude  = [ObsDataStruct{i}.head1  ObsDataStruct{i}.pitch1 ObsDataStruct{i}.roll1];

    for j = 1:size(ObsDataStruct{i},1)
        ObsDataStruct{i}.tdrEnu0(j,:) = armCalibration(armLength, sAttitude(j,:), sPoints(j,:), 'Japan');
        ObsDataStruct{i}.tdrEnu1(j,:) = armCalibration(armLength, rAttitude(j,:), rPoints(j,:), 'Japan');
    end
end

% 历元对应测站标识
for i = 1:length(IniFileDetaPath)
    Stations = strsplit(IniDataStruct{i}.Site_parameter.Stations, ' ');
    for j = 1:length(Stations)
        matchIdx = strcmp(ObsDataStruct{i}.MT, Stations{j});
        ObsDataStruct{i}.MTPSign(matchIdx,1) = (j - 1) * 3 + 1; % 在MP中的位置
    end
end

% 待估坐标参数向量
for i = 1:length(IniFileDetaPath)
    initTprCoor = [];
    paramFields = fieldnames(IniDataStruct{i}.Model_parameter);
    for j = 1:length(paramFields)
        if contains(paramFields{j}, '_dPos')
            fieldValue = getfield(IniDataStruct{i}.Model_parameter, paramFields{j});
            initTprCoor = [initTprCoor, fieldValue(1:3)];
        end
    end
    IniDataStruct{i}.x0 = initTprCoor;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 辅助函数1
function [IniDataStruct] = readIniData(iniFilePath)
%%函数说明
% 功能：读取Ini到结构体
key = inifile(iniFilePath);
IniDataStruct = struct();
nRows = size(key, 1);
for i = 1:nRows
    % 提取当前行的关键信息
    level1 = key{i,1};
    level2 = key{i,3};
    value = key{i,4};
    % 标准化字段名
    level1 = strrep(level1, '-', '_');
    level2 = strrep(level2, '(', '_');
    level2 = strrep(level2, ')', '_');
    level2 = strrep(level2, '.', '_');
    % 尝试将值转换为数值（如果是数字/数字列表）
    if ischar(value)
        % 处理空格分隔的数字列表（如 Center_ENU、M01_dPos）
        numVal = str2double(strsplit(value));
        if ~all(isnan(numVal))  % 转换成功则用数值，否则保留字符串
            value = numVal;
        end
    end
    % 动态赋值到嵌套结构体
    IniDataStruct.(level1).(level2) = value;
end


%% 辅助函数2
function [key] = inifile(iniFilePath)
%%函数说明
% 功能：读取ini文件到key变量
fid = fopen(iniFilePath);
count = 0;
% 逐行读取
while ~feof(fid)
    tline = fgetl(fid);
    if isempty(tline)
    %跳过空行
        continue;
    end
    %key读取
    if(contains(tline,'['))
        tline(find(isspace(tline))) = [];%去除空格
        keyWord = tline(2:end-1);%去除[]
        continue;
    end
    %跳过注释
    if(contains(tline,'#'))
        continue;
    end

    %赋值
    count = count + 1;
    key{count,1} = strtrim(keyWord);%去左右空格
    key{count,2} = '';%仿网络ini读取函数
    %分割
    secStr = split(tline,"=");%等号左右分割
    secStrLine = secStr';
    %三四元胞赋值
    countInsi = 0;
    for iColu = 3:3+size(secStrLine,2)-1
        if(size(secStrLine,2)>=2)
            countInsi = countInsi + 1;
            key{count,iColu} = strtrim(secStrLine{1,countInsi});
        end
    end

    %结束跳出
    if (tline == -1)
        %文件末尾跳出
        break;
    end
 end
 fclose(fid);


%% 辅助函数3
function [SvpDataTable] = readSvpData(svpFilePath)
%%函数说明
% 功能：读取SVP数据
SvpDataTable = readtable(svpFilePath);
%SvpDataStruct = tableToStruct(SvpDataTable);


%% 辅助函数4
function [ObsDataTable] = readObsData(obsFilePath)
%%函数说明
% 功能：读取观测数据

ObsDataTable = readtable(obsFilePath);
% ObsDataStruct = tableToStruct(ObsDataTable);


%% 辅助函数5
function [tdrPoint] = armCalibration(armLength, attitude, convPoint, type)
%%函数说明
% 功能：日本臂长转换

h = attitude(1)*pi/180;
p = attitude(2)*pi/180;
r = attitude(3)*pi/180;

% 旋转矩阵
switch type
    case 'Japan'
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
    case 'SouthSea'
        Rh = [cos(h) -sin(h) 0
              sin(h) cos(h)  0
              0      0       1];
        Rp = [cos(p) 0 -sin(p)        
              0      1    0
              sin(p) 0 cos(p)];       
        Rr = [1    0      0
              0 cos(r) -sin(r)
              0 sin(r) cos(r)];
        RRR = Rh * Rp * Rr;
        RR = [RRR(2,:);RRR(1,:);RRR(3,:)];
        R = [RR(:,2) RR(:,1) RR(:,3)];
end

% 转换结果
tdrPoint =  (R * armLength(:))' +  convPoint;


