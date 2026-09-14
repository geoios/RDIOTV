function plotDt(InvPosiResu, textTime)
%% 函数说明
%功能：绘制声速变化

h1 = subplot(3,1,1);
plot([5 9],[5 9],'k--'); hold on

y1Save = []; y2Save = []; 
for i = 1:length(textTime)
    % 绘制曲线
    y1 = InvPosiResu.PositResu{i,1}.ObsData.T;
    y2 = InvPosiResu.PositResu{i,2}.ObsData.T;
    scatter(y1, y2, 10, 'filled'); hold on
    
    % 坐标轴设置
    grid on
    box on
    xlim([5 9]); ylim([5 9]);
    xlabel('{\itT}_{CTD} (\circC)');
    ylabel('{\itT}_{GLORYS12} (\circC)','Position',[4.65 7]);
    xticks(5:1:9);

    % 存储
    y1Save = [y1Save; y1];
    y2Save = [y2Save; y2];
end

% 文本标记
R = corr(y1Save, y2Save);
text(0.5, 0.8, ['R=' num2str(R, '%.4g')], 'Units', 'normalized', ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

% 子图大小设置
r = 1; c = 1;
xBase = 0.15; yBase = 0.75;
xDelta = 0.8; yDelta = 0.33;
xWide = 0.75; yHigh = 0.2; 
set(h1,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])

% 文本标记设置
text(6.75, 9.6, '(a) CTD-based vs GLORYS12-based temperature', ...%, 'Units', 'normalized'
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
h2 = subplot(3,1,2);
for i = 1:length(textTime)
    % 绘制曲线
    y1 = InvPosiResu.PositResu{i,1}.ObsData.T;
    y2 = InvPosiResu.PositResu{i,2}.ObsData.T;
    dy = y2-y1;
    plot(i*ones(length(dy),1), dy, '.'); hold on
    
    % 坐标轴设置
    box on
    grid on
    xlabel('Campaigns');
    ylabel('\Delta{\itT}_{GLORYS12-CTD} (\circC)','Position',[-3 0]);
    yticks(-0.1:0.1:0.1);
end

% 子图大小设置
r = 2; c = 1;
set(h2,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])

% 文本标记设置
text(7, 0.135, '(b) Campaign-wise bias', ...%, 'Units', 'normalized'
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
h3 = subplot(3,1,3);
x1 = InvPosiResu.PositResu{2,1}.ObsData.ST./3600;
y1 = InvPosiResu.PositResu{2,1}.ObsData.T;
x2 = InvPosiResu.PositResu{2,2}.ObsData.ST./3600;
y2 = InvPosiResu.PositResu{2,2}.ObsData.T;
scatter(x1, y1, 1, 'filled', 'MarkerFaceColor', hex2rgb('#379FB4'), 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1); hold on
scatter(x2, y2, 1, 'filled', 'MarkerFaceColor', hex2rgb('#DB498E'), 'MarkerFaceAlpha',  1, 'MarkerEdgeAlpha', 1); 

% 坐标轴设置
box on
grid on
xlabel('Observation time (h)');
ylabel('{\itT} (\circC)','Position',[8 7.55]);
ylim([7.4 7.7]);

% 标注
legend('CTD','GLORYS12','position',[0.47 0.23 0.1 0.1],'Box','off','NumColumns',2);

% 子图大小设置
r = 3; c = 1;
set(h3,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])

% 文本标记设置
text(15, 7.75, '(c) Representative time series', ...%, 'Units', 'normalized'
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');





% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 8.5 12]);