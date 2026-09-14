function plotDtCorr(InvPosiResu, textTime)
%% 函数说明
% 功能：计算相关
tObs = datetime(textTime, 'InputFormat','yyyy-MM-dd');
for i = 1:31
    y1 = InvPosiResu.PositResu{i,1}.ObsData.T;
    y2 = InvPosiResu.PositResu{i,2}.ObsData.T;
    r(i,:) = [corr(y1, y2) mean(y1 - y2)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
color_left = "#379FB4";
color_right = "#DB498E";

yyaxis left
plot(tObs, r(:,1), 's-', 'color', color_left, 'MarkerSize', 3, 'MarkerFaceColor', color_left, 'MarkerEdgeColor', color_left);
ylabel('Correlation coefficient','Color',color_left);
ylim([0.9998 1.0002]);
yticks([0.9998:0.0002:1.0002]);
ax = gca;
ax.YAxis(1).Color = color_left;

yyaxis Right
plot(tObs, r(:,2), '^-', 'color', color_right, 'MarkerSize', 3, 'MarkerFaceColor', color_right, 'MarkerEdgeColor', color_right);
ylabel('Systematic deviation (\circC)');
ylim([-0.15 0.15]);
yticks([-0.15:0.15:0.15]);
ax.YAxis(2).Color = color_right;

% 坐标轴设置
xtickformat('yyyy');
xlim([datetime(2011,1,1) datetime(2021,1,1)]);
xticks(datetime(2011:2:2021,1,1));

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 6]);