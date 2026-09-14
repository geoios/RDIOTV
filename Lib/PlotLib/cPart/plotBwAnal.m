function plotBwAnal(GridSearPeriTrend, textTime)
%% 函数说明
% 功能：频带分析
tObs = datetime(textTime, 'InputFormat','yyyy-MM-dd');

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
color_left = "#379FB4";
color_right = "#DB498E";

yyaxis left
plot(tObs, GridSearPeriTrend.bestPeriod(:,1), 's-', 'color', color_left, 'MarkerSize', 3, 'MarkerFaceColor', color_left, 'MarkerEdgeColor', color_left); 
ylabel('Optimal period (h)','Color',color_left);
ylim([5 35]);
yticks([5:5:35]);
ax = gca;
ax.YAxis(1).Color = color_left;
% x_min = min(tObs); x_max = max(tObs);
% fill([x_min x_max x_max x_min],[9 9 14 14],'r','FaceAlpha',0.15,'EdgeColor','none');

yyaxis Right
plot(tObs, GridSearPeriTrend.R2, '^-', 'color', color_right, 'MarkerSize', 3, 'MarkerFaceColor', color_right, 'MarkerEdgeColor', color_right);
ylabel('R^2');
ylim([0 1]);
yticks([0:0.2:1]);
ax.YAxis(2).Color = color_right;

% 坐标轴设置
xtickformat('yyyy');
xlim([datetime(2011,1,1) datetime(2021,1,1)]);
xticks(datetime(2011:2:2021,1,1));

% 标注
% legend('Obs','Inv','box','off');

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 6]);