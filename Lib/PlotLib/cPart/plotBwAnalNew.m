function plotBwAnal(GridSearPeriTrend, textTime)
%% 函数说明
% 功能：频带分析
tObs = datetime(textTime, 'InputFormat','yyyy-MM-dd');
color_left = "#379FB4";
color_right = "#DB498E";

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,1,1)
plot(tObs, GridSearPeriTrend.bestPeriod(:,1), 's-', 'color', color_left, 'MarkerSize', 3, 'MarkerFaceColor', color_left, 'MarkerEdgeColor', color_left); 
ylabel('Period (h)');
ylim([5 35]);
yticks([5:5:35]);

% 坐标轴设置
xtickformat('yyyy');
xlim([datetime(2011,1,1) datetime(2021,1,1)]);
xticks(datetime(2011:2:2021,1,1));

% 水平参考线（不同样式以作区分）
h1 = yline(12.42, ':b', 'M_2', 'LineWidth', 1.2, ...
      'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'top', 'FontSize', 6); hold on
% h2 = yline(12.00, ':b', 'S_2', 'LineWidth', 1.2, ...
%       'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom', 'FontSize', 6); hold on
h3 = yline(24.00, ':b', 'diurnal', 'LineWidth', 1.2, ...
      'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'top', 'FontSize', 6); hold on
h4 = yline(22.37, ':b', 'inertial', 'LineWidth', 1.2, ...
      'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom', 'FontSize', 6); hold on

% 文本标记设置
text(datetime(2012,6,1), 39, '(a) Optimal period', ...%, 'Units', 'normalized'
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,1,2)
plot(tObs, GridSearPeriTrend.R2, '^-', 'color', color_right, 'MarkerSize', 3, 'MarkerFaceColor', color_right, 'MarkerEdgeColor', color_right);
xlabel('Year');
ylabel('R^2');
ylim([0 1]);
yticks([0:0.2:1]);

% 坐标轴设置
xtickformat('yyyy');
xlim([datetime(2011,1,1) datetime(2021,1,1)]);
xticks(datetime(2011:2:2021,1,1));

% 文本标记设置
text(datetime(2013,5,1), 1.15, '(b) Determination coefficient', ...%, 'Units', 'normalized'
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 8.5 8]);