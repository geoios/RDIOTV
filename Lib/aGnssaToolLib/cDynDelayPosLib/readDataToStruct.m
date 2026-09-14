function [IniDataStruct, ObsDataStruct, SvpDataStruct] = readDataToStruct(iniFilePath, obsFilePath, svpFilePath)
%% 函数说明
% 功能：读取OBS与INI文件

% 读取INI文件（并转结构体）
IniDataStruct = readIniToStruct(iniFilePath);

% 读取OBS文件（并转结构体）
ObsDataTable = readtable(obsFilePath);
ObsDataStruct = tableToStruct(ObsDataTable);

% 读取SVP文件（并转结构体）
if nargin == 3
    SvpDataStruct = readSvpToStruct(svpFilePath);
else
    SvpDataStruct = [];
end


%% 辅助函数1
function [DataStruct] = tableToStruct(DataTable)
%%函数说明
% 功能：table转结构体
% 初始化输出结构体
DataStruct = struct();
% 获取数据表的变量名列表
variableNames = DataTable.Properties.VariableNames;
% 遍历变量名并构建结构体
for varIdx = 1:length(variableNames)
    % 获取当前变量名
    currentVarName = variableNames{varIdx};
    % 过滤系统默认的Var开头字段
    if strncmp(variableNames{varIdx},'Var',3)
        continue; % 跳过默认字段
    else
        % 将有效字段赋值到结构体
        DataStruct.(currentVarName) = DataTable.(currentVarName);
    end
end


%% 辅助函数2
function [IniDataStruct] = readIniToStruct(impoIniPath)
%%函数说明
% 功能：读取Ini到结构体
key = inifile(impoIniPath);
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


%% 辅助函数3
function [key] = inifile(impoIniPath)
%%函数说明
%功能：读取ini文件到key变量
fid = fopen(impoIniPath);
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


%% 辅助函数4
function [SvpDataStruct] = readSvpToStruct(impoSvpPath)
%%函数说明
% 功能：读取svp观测文件
SvpDataTable = readtable(impoSvpPath);
[SvpDataStruct] = tableToStruct(SvpDataTable);
