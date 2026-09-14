function plotCorrAnal(GridSearPeriRes, InvPosiResu, textTime)
%% 函数说明
% 功能：
tObs = datetime(textTime, 'InputFormat','yyyy-MM-dd');
for i = 1:31
    y = GridSearPeriRes.bestPeriodFit{i}(:,2);

    z = atan(InvPosiResu.PositResu{i,1}.ObsData.z0(:,2));
    zp = atan(InvPosiResu.PositResu{i,1}.ObsData.z0(:,1));
    alfa = InvPosiResu.PositResu{i,1}.ObsData.alpha0(:,1);
    alfap = InvPosiResu.PositResu{i,1}.ObsData.alpha0(:,2);
    h = InvPosiResu.PositResu{i,1}.ObsData.tranEnu0(:,3);

    y21 = tan(z) .* cos(alfa);
    y22 = tan(z) .* sin(alfa);
    y23 = tan(zp) .* cos(alfap);
    y24 = tan(zp) .* sin(alfap);
    y25 = h;

    rr(i,:) = [corr(y,y21) corr(y,y22) corr(y,y23) corr(y,y24) corr(y,y25)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
color1 = "#A5D395";
color2 = "#6CA3D4";
color3 = "#BF95C1";
color4 = "#EDD283";
color5 = "#E1807E";

h = subplot(1,1,1);
plot(tObs, rr(:,1), 's-', 'color', color1, 'MarkerSize', 3, 'MarkerFaceColor', color1, 'MarkerEdgeColor', color1); hold on
plot(tObs, rr(:,2), 's-', 'color', color2, 'MarkerSize', 3, 'MarkerFaceColor', color2, 'MarkerEdgeColor', color2); hold on
plot(tObs, rr(:,3), 's-', 'color', color3, 'MarkerSize', 3, 'MarkerFaceColor', color3, 'MarkerEdgeColor', color3); hold on
plot(tObs, rr(:,4), 's-', 'color', color4, 'MarkerSize', 3, 'MarkerFaceColor', color4, 'MarkerEdgeColor', color4); hold on
plot(tObs, rr(:,5), 's-', 'color', color5, 'MarkerSize', 3, 'MarkerFaceColor', color5, 'MarkerEdgeColor', color5); 
ylabel('Correlation coefficient');
ylim([-1 1]);
yticks([-1:0.5:1]);

% 坐标轴设置
xtickformat('yyyy');
xlim([datetime(2011,1,1) datetime(2021,1,1)]);
xticks(datetime(2011:2:2021,1,1));

% 子图大小设置
c = 1; r = 1;
xBase = 0.15; yBase = 0.1;
xDelta = 0.8; yDelta = 0.8;
xWide = 0.75; yHigh = 0.75; 
set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])

% 标注
legend('tan z * cos a','tan z * sin a','tan z'' * cos a''','tan z'' * sin a''','h','NumColumns', 3,'box','off','position',[0.47 0.92 0.1 0.01]);%

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 6]);