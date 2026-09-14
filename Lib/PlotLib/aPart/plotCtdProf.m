function plotCtdProf(JpnCtdInfo, textTime, type)
%% 函数说明
%功能：绘制CTD剖面

numRow = 7;
numColumns = 5;
for i = 1:length(textTime)
    r = ceil(i / numColumns);
    c = mod(i-1, numColumns) + 1;

    % 绘制曲线
    h = subplot(numRow, numColumns, i);
    switch type
        case 'T'
            for j = 1:size(JpnCtdInfo{i},1)
                plot(JpnCtdInfo{i}{j,5}(:,2), JpnCtdInfo{i}{j,5}(:,1), '.-'); hold on
            end
        case 'S'
            for j = 1:size(JpnCtdInfo{i},1)
                plot(JpnCtdInfo{i}{j,5}(:,3), JpnCtdInfo{i}{j,5}(:,1), '.-'); hold on
            end
        case 'A'
            for j = 1:size(JpnCtdInfo{i},1)
                plot(JpnCtdInfo{i}{j,6}(:,2), JpnCtdInfo{i}{j,5}(:,1), '.-'); hold on
            end
    end

    % 坐标轴设置
    set(gca,'ydir','reverse');
    ylabel('Depth (m)');
    xlabel('Sound speed (m/s)');
    % xlim([1450 1550]);

    if(i ~= 16)
        ylabel('');
    end
    if(i ~= 33)
        xlabel('');
    end
    
    if(c ~= 1)
        set(gca,'yticklabel',[]);
    end
    
    if(r ~= 7)
        set(gca,'xticklabel',[]);
    end

    % 标题设置
    title(textTime(i));

    % 子图大小设置
    xBase = 0.08; yBase = 0.85;
    xDelta = 0.18; yDelta = 0.13;
    xWide = 0.15; yHigh = 0.10; 
    set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])
end

% 标签设置
% legend('SVP','CTD',...
%     'position',[0.45 0.97 0.1 0.01],'NumColumns', 4)

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 16.6 17.7]);