function plotObsShap(InvPosiResu, textTime)
%% 函数说明
% 功能：绘制观测形状
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
    scatter(InvPosiResu.PositResu{i,1}.ObsData.tranEnu0(:,1), InvPosiResu.PositResu{i,1}.ObsData.tranEnu0(:,2), 10, hex2rgb('#6CA3D4'), '.'); hold on
    scatter(InvPosiResu.PositResu{i,1}.tprCoor(:,1), InvPosiResu.PositResu{i,1}.tprCoor(:,2), 10, hex2rgb('#E1807E'), 'x', 'LineWidth', 1.5); hold on
    
    % 坐标轴设置
    box on
    grid on
    xticks(-3000:3000:3000);
    yticks(-3000:3000:3000);
    xlim([-3000 3000]);
    ylim([-3000 3000]);
    if(c ~= 1)
        yticklabels({});
    end
    if(r ~= 8)
        xticklabels({});
    end
    if(r == 4 && c == 1)
        ylabel('N (m)','Position',[-6500 -4000]);
    end
    if(r == 8 && c == 2)
        xlabel('E (m)','Position',[4000 -6500]);
    end

    % 文本标记设置
    title(textTime(i),'FontSize',8);

    % 子图大小设置
    xBase = 0.12; yBase = 0.87;
    xDelta = 0.22; yDelta = 0.112;
    xWide = 0.15; yHigh = 0.08; 
    set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])
end

% 标注
legend('Surface transducer','Seafloor transponder','position',[0.8 0.87 0.1 0.1],'Box','off');

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 9 12]);