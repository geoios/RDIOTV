function plotDt(DecSignal, T2, T3, textTime)
%% 函数说明
%功能：绘制声速变化
color1 = '#4DAF4A';
color2 = '#FFCE5B';
color3 = '#D65190';
color4 = '#0076B9';

zSave = [];
for i = 1:length(textTime)
    % 绘制曲线
    x1 = DecSignal{i,1}(:,1)./3600;
    x1 = (x1 - min(x1)) / (max(x1) - min(x1));

    y1 = i*ones(length(x1),1);

    z1 = DecSignal{i,1}(:,2);
    z1 = z1 - mean(z1);

    scatter(x1, y1, 3, z1, 'filled'); hold on
    zSave = [zSave; z1];
    
    % 坐标轴设置
    box on
    % sy = floor(min([y1;y2;y3;y4])*10)/10;
    % ey = ceil(max([y1;y2;y3;y4])*10)/10;
    % ylim(sy:ey-sy:ey);
    % yticks(sy:ey-sy:ey);

    % sx = floor(min(x1));
    % ex = ceil(max(x1));
    % xlim(sx:ex-sx:ex);
    % xticks(sx:ex-sx:ex);

    % ytickformat('%.1f');
    % if(r == 4 && c == 1)
    %     ylabel('Temperature (\circC)','Position',[15 8.2]);
    % end
    % if(r == 8 && c == 2)
    %     xlabel('Observation time (h)','Position',[39 5.45]);
    % end

    % 子图大小设置
    % xBase = 0.12; yBase = 0.88;
    % xDelta = 0.22; yDelta = 0.113;
    % xWide = 0.15; yHigh = 0.06; 
    % set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])
end

% 标注
caxis([min(zSave), max(zSave)]);
colorbar

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 8.5 6]);