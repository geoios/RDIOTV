function plotGridSear31(GridSearPeriTrend, textTime)
%% 函数说明
% 功能：格网搜索
numRow = 8;
numColumns = 4;

count = 0;
for i = 1:length(textTime)+1
    count = count + 1;
    if(i == 4)
        continue;
    elseif(i > 4)
        i = i-1;
    end
    r = ceil(count / numColumns);
    c = mod(count-1, numColumns) + 1;
    h = subplot(numRow, numColumns, count);

    % 绘制曲线
    x = GridSearPeriTrend.GridSearArray{i}(:,1);
    y = GridSearPeriTrend.GridSearArray{i}(:,2);
    plot(x, y, 'b.'); hold on
    plot(GridSearPeriTrend.bestPeriod(i,1), GridSearPeriTrend.bestPeriod(i,2), 'r^');

    % 坐标轴设置
    sy = 0;%floor(min(y)*10)/10;
    ey = ceil(max(y)*10)/10;
    ylim(sy:ey-sy:ey);
    yticks(sy:ey-sy:ey);
    ytickformat('%.1f');
    xticks(0:15:30);

    if(r ~= 8)
        xticklabels({});
    end

    if(r == 4 && c == 1)
        ylabel('RSS (\circC^2)','Position',[-10 0]);
    end
    if(r == 8 && c == 2)
        xlabel('Period (h)','Position',[35 -5]);
    end

    % 子图大小设置
    xBase = 0.12; yBase = 0.88;
    xDelta = 0.22; yDelta = 0.113;
    xWide = 0.15; yHigh = 0.06; 
    set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])
end

% 标注
legend('Search','Best','position',[0.8 0.86 0.1 0.1],'Box','off');

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 12]);
