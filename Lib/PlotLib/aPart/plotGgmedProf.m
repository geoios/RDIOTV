function plotGgmedProfT(GgmedProfile, JpnCtdInfo, IniInfo, type)
%% 函数说明
%功能：绘制GGMED剖面
statiSeriNum = size(IniInfo,1);
for i = 1:statiSeriNum
    obsTime(i,:) = IniInfo{i}.gridTime;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numRow = 7;
numColumns = 5;
for iStat = 1:statiSeriNum
    r = ceil(iStat / numColumns);
    c = mod(iStat-1, numColumns) + 1;

    % 绘制曲线
    h = subplot(numRow, numColumns, iStat);

    switch type
        case 'T'
            svp1 = JpnCtdInfo{iStat}{5}(:,[1 2]);
            svp2 = GgmedProfile{iStat}(:,[1 2]);
        case 'S'
            svp1 = JpnCtdInfo{iStat}{5}(:,[1 3]);
            svp2 = GgmedProfile{iStat}(:,[1 3]);
    end

    try
        plot(svp1(:,2), svp1(:,1), 'b-', 'lineWidth',3); hold on
        plot(svp2(:,2), svp2(:,1), 'r-', 'lineWidth',1.5); 
    catch
        continue
    end

    % 坐标轴设置
    set(gca,'ydir','reverse');
    ylabel('Depth (m)');

    if(iStat ~= 16)
        ylabel('');
    end
    if(iStat ~= 33)
        xlabel('');
    end
    
    if(c ~= 1)
        set(gca,'yticklabel',[]);
    end
    
    if(r ~= 7)
        set(gca,'xticklabel',[]);
    end

    % 文本标记设置
    textYear = obsTime(iStat, 1);
    textMonth = obsTime(iStat, 2);
    textDay = obsTime(iStat, 3);

    TextTime.year = sprintf('%d', textYear);  
    TextTime.month = sprintf('%02d', textMonth);  
    TextTime.day = sprintf('%02d', textDay); 

    switch type
        case 'T'
            % xlabel('Temperature (\circC)');
            xlim([0 30]);
            text(18.25,1510,[TextTime.year ' '; TextTime.month '/' TextTime.day]);
        case 'S'
            % xlabel('Salinity (ppm)');
            xlim([33 36]);
            text(35,1510,[TextTime.year ' '; TextTime.month '/' TextTime.day]);
    end
	

    % 子图大小设置
    xBase = 0.08; yBase = 0.85;
    xDelta = 0.18; yDelta = 0.13;
    xWide = 0.15; yHigh = 0.10; 
    set(h,'position',[xBase+(c-1)*xDelta yBase-(r-1)*yDelta xWide yHigh])
end

% 标签设置
legend('SVP','CTD',...
    'position',[0.45 0.97 0.1 0.01],'NumColumns', 4)

% 图片大小设置
set(gcf,'Units','centimeter','Position',[0 0 16.6 17.7]);