function [StdzNearProf] = getStdzNearProf(interpPos, PhySet, interpDepth)
%% 函数说明
%功能：哥白尼数据集提取并预处理

% 1. 批量读取并拼接
dayOffsets = [-1, 0, 1];
nDay       = length(dayOffsets);
nPos       = 4;
for k = 1:nDay
    currentJD = interpPos(3) + dayOffsets(k);
    SameDayNearProf  = getSameDayNearProf(interpPos, currentJD, PhySet);
    
    idxStart = (k-1)*nPos + 1;
    idxEnd   = k*nPos;
    
    posAll(:, idxStart:idxEnd) = SameDayNearProf.pos;
    tempAll(:,idxStart:idxEnd) = SameDayNearProf.temp;
    salAll(:, idxStart:idxEnd) = SameDayNearProf.sal;
end

PhySetExtr.depth = PhySet.depth;
PhySetExtr.pos   = posAll;
PhySetExtr.temp  = tempAll;
PhySetExtr.sal   = salAll;

% 2. 构建含0m表层的原始剖面
PhySetExtr.depth = [0; PhySetExtr.depth];
PhySetExtr.pos   = PhySetExtr.pos;
PhySetExtr.temp  = [PhySetExtr.temp(1,:); PhySetExtr.temp];
PhySetExtr.sal   = [PhySetExtr.sal(1,:); PhySetExtr.sal];

% 3. 深度方向：线性插值 + 最小二乘外推
maxExtDepth = interpDepth(end);
nProfiles   = size(PhySetExtr.pos, 2);
% 逐剖面插值
StdzNearProf.depth = interpDepth;
StdzNearProf.pos   = PhySetExtr.pos;
for i = 1:nProfiles
    % 提取深度-温度/盐度数据
    dataTemp = [PhySetExtr.depth, PhySetExtr.temp(:, i)];
    dataSal = [PhySetExtr.depth, PhySetExtr.sal(:, i)];
    % 剔除含 NaN 的行
    validDataTemp = dataTemp(all(~isnan(dataTemp), 2), :);
    validDataSal = dataSal(all(~isnan(dataSal), 2), :);
    
    % 判断是否需要外推
    if validDataTemp(end, 1) < maxExtDepth
        % validDataTemp = [validDataTemp; lsExpnFun(validDataTemp, prioInfo(1,1:2), 2, maxExtDepth)];
        validDataTemp = [validDataTemp; [maxExtDepth validDataTemp(end,2)]];
    end
    if validDataSal(end, 1) < maxExtDepth
        % validDataSal = [validDataSal; lsExpnFun(validDataSal, prioInfo(2,1:2), 2, maxExtDepth)];
        validDataSal = [validDataSal; [maxExtDepth validDataSal(end,2)]];
    end
    
    % 执行插值
    StdzNearProf.temp(:, i) = interp1(validDataTemp(:,1), validDataTemp(:,2), interpDepth, 'linear');
    StdzNearProf.sal(:, i) = interp1(validDataSal(:,1), validDataSal(:,2), interpDepth, 'linear');
end


%% 辅助函数
function [NearProf] = getSameDayNearProf(intePos, jdDay, PhySet)
%%函数说明
%功能：根据经纬度和时间，提取哥白尼数据中最近的 N 个空间点剖面

spacPoinNum = 4;
% 1. 直接计算距离
posData   = PhySet.pos(1:2,:);   % [2, N]
lonTarget = intePos(1);             % 标量
latTarget = intePos(2);             % 标量
dist = hypot(posData(1,:) - lonTarget, posData(2,:) - latTarget).'; % 向量化距离计算

% 2. 时间筛选 + 索引
timeMask = (PhySet.pos(3,:).' == jdDay);
indexAll = (1:size(PhySet.pos,2)).';
distSameDay = dist(timeMask);     % 同天距离
idxSameDay  = indexAll(timeMask); % 同天索引

% 3. 排序 + 取最近点
[~, sortIdx] = sort(distSameDay);
selectIdx    = sortIdx(1:spacPoinNum);
index        = idxSameDay(selectIdx);

% 4. 提取数据
NearProf.depth = PhySet.depth;
NearProf.pos   = PhySet.pos(:, index);
NearProf.temp  = PhySet.temp(:, index);
NearProf.sal   = PhySet.sal(:, index);


%% 辅助函数
% function [expnData] = lsExpnFun(data, prioInfo, window, targetDepth)
% %%函数说明
% %功能：最小二乘延拓
% 
% % 1. 选取用于最小二乘拟合的底部数据段
% fitData = data(end-window+1:end,:);
% 
% % 2. 添加约束点（来自统计先验信息）
% fitData = [fitData; prioInfo];
% 
% % 3. 构造加权矩阵
% nFit = size(fitData, 1);
% P = eye(nFit);  
% 
% % 4. 构建线性方程组并求解系数
% B = [ones(nFit, 1), fitData(:, 1)];  
% coeff = pinv(B' * P * B) * B' * P * fitData(:, 2);  
% 
% % 5. 外推计算目标深度处的值
% targetValue = coeff(1) + coeff(2) * targetDepth; 
% 
% % 6. 输出结果
% expnData = [targetDepth, targetValue];  

