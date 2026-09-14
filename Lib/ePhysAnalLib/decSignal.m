function [DecSignal] = decSignal(testArray, InvPosiResu)
%% 函数说明
% 功能：信号分解与周期分析

for idx = testArray
    % 提取
    Signal{idx,1} = [InvPosiResu.PositResu{idx,2}.ObsData.ST, ...
                     InvPosiResu.PositResu{idx,2}.ObsData.T];

    % 分解
    x = Signal{idx}(:,1); % 时间
    y = Signal{idx}(:,2); % 信号
    
    yTrend = wden(y, 'sqtwolog', 's', 'one', 9, 'db4'); % 趋势项% yTrend = yTrend - mean(yTrend);
    yRes = y - yTrend; % 波动项
    DecSignal{idx,1} = [x, y, yTrend, yRes];
    stats(idx,:) = [min(y) max(y)];
end
a = stats(:,2) - stats(:,1);



