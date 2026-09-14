function [Output] = calSystBias(T2, T3, DecSignal)
%% 函数说明
% 功能：计算系统偏差

%（1）合并 T2 T3
TofObs = [];
for i = 1:31
    TofObs{i,1} = [T2{i}; T3{i}];
end

%（2）计算DecSignal{i}(:,[1 2])中的对应值
for i = 1:31
    TofInv{i,1} = [TofObs{i}(:,1) interp1(DecSignal{i}(:,1), DecSignal{i}(:,2), TofObs{i}(:,1), "linear")];
end

%（3）统计分析
for i = 1:31
    % Raw
    statsRawCtd(i,:) = [mean(TofObs{i})];
    statsRawInv(i,:) = [mean(TofInv{i})];

    % diff
    % diffT{i} = TofObs{i}(:,2) - TofInv{i}(:,2);
    % statsDiff(i,:) = [mean(diffT{i}) std(diffT{i})];
end
statsDiff = statsRawCtd(:,2) - statsRawInv(:,2);

% 输出
Output.statsRawInv = statsRawInv;
Output.statsRawCtd = statsRawCtd;
Output.statsDiff = statsDiff;
Output.meanAndStd = [mean(statsDiff) std(statsDiff)];

