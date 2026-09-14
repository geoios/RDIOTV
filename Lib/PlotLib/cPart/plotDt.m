function plotDt(DecSignal, T2, T3, textTime)
%% 函数说明
%功能：绘制声速变化
color1 = '#4DAF4A';
color2 = '#FFCE5B';
color3 = '#D65190';
color4 = '#0076B9';

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
    x1 = DecSignal{i,1}(:,1)./3600;
    y1 = DecSignal{i,1}(:,2);

    x2 = DecSignal{i,1}(:,1)./3600;
    y2 = DecSignal{i,1}(:,3);

    try
        x3 = T2{i}(:,1)./3600;
        y3 = T2{i}(:,2);
    catch
        x3 = [];
        y3 = [];
    end

    x4 = T3{i}(:,1)./3600;
    y4 = T3{i}(:,2);


    % range(count,1) = max(y1) - min(y1);
    % plot(x1, y1, 'g.'); hold on
    % plot(x2, y2, 'b.'); hold on
    % plot(x3, y3, 'r.');

    scatter(x1, y1, ...
        3, 'filled', 'MarkerFaceColor',color1,'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1); hold on
    scatter(x2, y2, ...
        3, 'filled', 'MarkerFaceColor',color2,'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1); hold on
    scatter(x3, y3, ...
        3, 'filled', 'MarkerFaceColor',color3,'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1); hold on
    scatter(x4, y4, ...
        3, 'filled', 'MarkerFaceColor',color4,'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
    
    % 坐标轴设置
    box on
    sy = floor(min([y1;y2;y3;y4])*10)/10;
    ey = ceil(max([y1;y2;y3;y4])*10)/10;
    ylim(sy:ey-sy:ey);
    yticks(sy:ey-sy:ey);

    sx = floor(min(x1));
    ex = ceil(max(x1));
    xlim(sx:ex-sx:ex);
    xticks(sx:ex-sx:ex);

    ytickformat('%.1f');
    if(r == 4 && c == 1)
        ylabel('Temperature (\circC)','Position',[15 8.2]);
    end
    if(r == 8 && c == 2)
        xlabel('Observation time (h)','Position',[39 5.45]);
    end

    % 子图大小设置
    xBase = 0.12; yBase = 0.88;
    xDelta = 0.22; yDelta = 0.113;
    xWide = 0.15; yHigh = 0.06; 
    set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])
end

% 标注
legend('Raw','Trend','CTD','XBT','position',[0.8 0.86 0.1 0.1],'Box','off');

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 12]);