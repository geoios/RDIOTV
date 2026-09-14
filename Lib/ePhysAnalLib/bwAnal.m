function [StatsTable, StatsTable2] = bwAnal(GridSearPeriTrend, JpnIniInfo, textTime, timeLong)
%% 函数说明
% 功能：频带分析
% 划分理论频带
optCycle = GridSearPeriTrend.bestPeriod(:,1);
for i = 1:length(JpnIniInfo)
    p = optCycle(i);
    if(p >= 6 && p < 9)
        v = "非主导频带/高频变化";
    elseif(p >= 9 && p < 14)
        v = "半日潮/半日内潮频带";
    elseif(p >= 14 && p < 20)
        v = "过渡频带";
    elseif(p >= 20 && p < 26)
        v = "日潮/日内潮/近惯性频带";
    else
        v = "未分辨长周期变化";
    end
    theoBand(i,:) = v;
end

% 统计表
StatsTable.num = (1:length(JpnIniInfo))';
StatsTable.data = textTime;
StatsTable.timeLong = round(timeLong * 100) / 100;
StatsTable.optCycle = optCycle;
StatsTable.theoBand = theoBand;
StatsTable.N = round(timeLong ./ optCycle * 100) / 100;
StatsTable.R2 = GridSearPeriTrend.R2;
StatsTable = struct2table(StatsTable);

% 统计频带分布特征
idx1 = find(strcmp(StatsTable.theoBand, '非主导频带/高频变化'));
idx2 = find(strcmp(StatsTable.theoBand, '半日潮/半日内潮频带'));
idx3 = find(strcmp(StatsTable.theoBand, '过渡频带'));
idx4 = find(strcmp(StatsTable.theoBand, '日潮/日内潮/近惯性频带'));
idx5 = find(strcmp(StatsTable.theoBand, '未分辨长周期变化'));

StatsTable2.num = [length(idx1); length(idx2); length(idx3); length(idx4); length(idx5)];
StatsTable2.ratio = StatsTable2.num./length(JpnIniInfo);
StatsTable2.meanL = [mean(StatsTable.timeLong(idx1)); mean(StatsTable.timeLong(idx2)); mean(StatsTable.timeLong(idx3)); mean(StatsTable.timeLong(idx4)); mean(StatsTable.timeLong(idx5))];
StatsTable2.meanN = [mean(StatsTable.N(idx1)); mean(StatsTable.N(idx2)); mean(StatsTable.N(idx3)); mean(StatsTable.N(idx4)); mean(StatsTable.N(idx5))];
StatsTable2.meanR2 = [mean(StatsTable.R2(idx1)); mean(StatsTable.R2(idx2)); mean(StatsTable.R2(idx3)); mean(StatsTable.R2(idx4)); mean(StatsTable.R2(idx5))];
StatsTable2 = struct2table(StatsTable2);
