function plotInvTempAll(StatsYearBias, textTime)
%% 函数说明
% 功能：多年时序
tObs = datetime(textTime, 'InputFormat','yyyy-MM-dd');

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
color_left = "#379FB4";
color_right = "#DB498E";

% yyaxis left
plot(tObs, StatsYearBias.statsRawCtd(:,2), 's-', 'color', color_left, 'MarkerSize', 3, 'MarkerFaceColor', color_left, 'MarkerEdgeColor', color_left); hold on
plot(tObs, StatsYearBias.statsRawInv(:,2), '^-', 'color', color_right, 'MarkerSize', 3, 'MarkerFaceColor', color_right, 'MarkerEdgeColor', color_right);
ylabel('Temperature (\circC)');
ylim([5 9]);
yticks([5:1:9]);
% ax = gca;
% ax.YAxis(1).Color = color_left;

% yyaxis Right
% plot(tObs, StatsYearBias.statsDiff(:,1), 's-', 'color', color_right, 'MarkerSize', 3, 'MarkerFaceColor', color_right, 'MarkerEdgeColor', color_right);
% % plot(tObs, StatsYearBias.statsDiff(:,2), '^--', 'color', color_right, 'MarkerSize', 3);
% ylabel('Bias (\circC)');
% ylim([-0.3 0.3]);
% yticks([-0.3:0.1:0.3]);
% ax.YAxis(2).Color = color_right;

% 坐标轴设置
xlabel('Year');
xtickformat('yyyy');
xlim([datetime(2011,1,1) datetime(2021,1,1)]);
xticks(datetime(2011:2:2021,1,1));

% 标注
legend('CTD/XBT temperature','Campaign-averaged GNSS-A temperature','box','off','Location','southwest');

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 6]);