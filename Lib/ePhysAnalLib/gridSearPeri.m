function [Output] = gridSearPeri(testArray, DecSignal, type)
%% 函数说明
% 功能：格网搜索周期 + 最优周期拟合

% 1. 参数配置
switch type
    case 'trend'
        periodRange = (6:0.1:30)';  
        targetCols  = [1, 3];     

    case 'res'
        periodRange = ((30:1:120)./60)';  
        targetCols  = [1, 4];    
end

% 2. 逐期格网搜索最优周期
numPeriods = length(periodRange);
for i = testArray
    % 提取当期信号
    x = DecSignal{i}(:,targetCols(1));
    y = DecSignal{i}(:,targetCols(2));
    
    % 遍历所有周期计算拟合残差
    for j = 1:numPeriods
        currPeriod = periodRange(j);
        [~, rss(j,1)] = fitSinglePeriod(x, y, currPeriod);
    end
    
    % 保存当期搜索结果 & 寻找最优周期
    GridSearArray{i,1} = [periodRange, rss];
    GridSearArray{i,1} = sortrows(GridSearArray{i}, 2);
    bestPeriod(i,:) = GridSearArray{i}(1,:);
    % 如果最优值触碰边界，以极值代替

    % 最优周期重新拟合
    bestPeriodFit{i,1} = [x y fitSinglePeriod(x, y, bestPeriod(i,1))];
    R2(i,1) = calculateR2(bestPeriodFit{i,1}(:,2), bestPeriodFit{i,1}(:,3));
end

% 导出
Output.GridSearArray = GridSearArray;
Output.bestPeriod = bestPeriod;
Output.bestPeriodFit = bestPeriodFit;
Output.R2 = R2;
