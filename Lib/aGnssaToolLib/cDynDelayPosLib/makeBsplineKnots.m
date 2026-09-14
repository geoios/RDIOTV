function [IniData] = makeBsplineKnots(IniData, ObsData)
%% 函数说明
% 功能：基于观测数据时间范围生成B样条节点，并计算对应的参数个数

% 传参与设置
BSpan = [15,35,35,35,35]; %[]; % B样条分段时间
spdeg = 3; % B样条阶数
SET = ObsData.SET;
ST = ObsData.ST;
RT = ObsData.RT;

% BSpan为空时直接返回空值
if isempty(BSpan)
    knots = []; 
    MPNum = [];
    return;
end

% 初始化
numBSpan = length(BSpan);
knots = cell(1, numBSpan);
MPNum = zeros(1,numBSpan);

% 1. 计算每个section时长及平均时长
uniqueSets = unique(SET);
numSets = length(uniqueSets);
for i = 1:numSets
    % 找到当前观测段对应的所有数据索引
    setIdx = cellfun(@(x) contains(x, uniqueSets{i}), SET);
    % 提取当前观测段的所有起始/结束时间
    segmentST = ST(setIdx);
    segmentRT = RT(setIdx);
    % 计算当前观测段的最早起始时间和最晚结束时间
    st0s(i) = min(segmentST);
    stfs(i) = max(segmentRT);
end
setDurations = stfs - st0s; 
avgSetDuration = mean(setDurations);

% 2. 每个section的B样条参数初始化
totalST = min(ST); 
totalRT = max(RT);
totalObsDuration = totalRT - totalST;
numCycles = fix(totalObsDuration / avgSetDuration);
% 各BSpan对应的节点总数
nestSum = fix(avgSetDuration ./ (BSpan*60)); % 按指定时长(分钟)分段
numKnots = nestSum * numCycles; 
% 生成初始均匀节点
for i = 1:numBSpan
    knots{i} = linspace(totalST, totalRT, numKnots(i) + 1);
end

% 3. 优化节点(剔除间断区间并扩展两边)
for i = 1:numBSpan
    % 跳过空节点集
    if numKnots(i) == 0
        knots{i} = [];
        continue;
    end

    % 处理观测数据时间间断
    removeKnotIdx = [];
    % 判断观测数据中是否存在长时间观测间断
    for k = 1:numSets - 1
        % 找到当前间隙的时间范围
        gapStart = stfs(k);
        gapEnd = st0s(k+1);
        % 找到间隙内的节点索引
        gapKnotIdx = find(knots{i} > gapStart & knots{i} < gapEnd);
        % 仅剔除超过阈值的长间隙内的节点(保留边界spdeg+2个节点)
        if length(gapKnotIdx) > 2*(spdeg + 2)
            removeKnotIdx = [removeKnotIdx, gapKnotIdx(spdeg+2 : end-spdeg-1)];
        end
    end

    % 剔除间断区间内的冗余节点
    if ~isempty(removeKnotIdx)
        knots{i}(removeKnotIdx) = [];
    end

    % 扩展节点边界(满足B样条阶数要求)
    knotInterval = (totalRT - totalST) / numKnots(i);
    % 左侧扩展节点
    leftExtKnots = totalST + knotInterval * (-spdeg : -1);
    % 右侧扩展节点
    rightExtKnots = totalRT + knotInterval * (1 : spdeg);
    % 合并扩展节点
    knots{i} = [leftExtKnots, knots{i}, rightExtKnots];

    % 计算参数个数
    MPNum(i) = length(knots{i}) - spdeg - 1;
end

% 导出
IniData.BSpan = BSpan;
IniData.spdeg = spdeg;
IniData.knots = knots;
IniData.MPNum = MPNum;

