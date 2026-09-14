function plotObsShap(InvPosiResu, textTime)
%% 函数说明
% 功能：绘制观测形状

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = subplot(1,2,1);
plotSitePosi([130 138], [30 36], 'E:\cResearchTopic_code\0Data\Data_import\ETOPO1\japan1\ETOPO1_Ice_g_gmt4.grd');

% 文本标记设置
text(0.5, -0.12, '(a) TOS2 site', 'Units', 'normalized', ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

% 子图大小设置
r = 1; c = 1;
xBase = 0.05; yBase = 0.15;
xDelta = 0.5; yDelta = 0.8;
xWide = 0.4; yHigh = 0.75; 
set(h1,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
h2 = subplot(1,2,2);
scatter3(InvPosiResu.PositResu{2,1}.ObsData.tranEnu0(:,1), InvPosiResu.PositResu{2,1}.ObsData.tranEnu0(:,2), InvPosiResu.PositResu{2,1}.ObsData.tranEnu0(:,3), 20, hex2rgb('#6CA3D4'), '.'); hold on
scatter3(InvPosiResu.PositResu{2,1}.tprCoor(:,1), InvPosiResu.PositResu{2,1}.tprCoor(:,2), InvPosiResu.PositResu{2,1}.tprCoor(:,3), 20, hex2rgb('#E1807E'), 'x', 'LineWidth', 1.5); hold on

% 坐标轴设置
box on
grid on
xticks(-2000:2000:2000);
yticks(-2000:2000:2000);
zticks(-2000:500:0);
xlim([-2000 2000]);
ylim([-2000 2000]);

xlabel('E (m)','Position',[0 -3000 -2000]);
ylabel('N (m)','Position',[-2700 0 -2000]);

% 文本标记设置
text(0.5, -0.12, '(b) GNSS-A observation geometry (2011/12/13)', 'Units', 'normalized', ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
     'FontSize', 8, 'FontName', 'Times new roman');

% 子图大小设置
r = 1; c = 2;
set(h2,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])

% 标注
legend('Surface transducer','Seafloor transponder','position',[0.70 0.87 0.1 0.1],'Box','off','NumColumns',2);

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 15 6]);