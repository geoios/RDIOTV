function plotSitePosi(lonRang, latRang, etopoPath)
%% Founction description
%Founction:Draw site Position
plotGeoEtop(lonRang, latRang, etopoPath);
hold on

for i = 1
    lon = 134.03194444;
    lat = 32.42861111;
    name = 'TOS2';

    % 绘制方形标记
    m_line(lon,lat,'marker','s','color','r','linewi',1,...
        'linest','none','markersize',3,'markerfacecolor','none');hold on

    % 标签经度偏移
    dLon = 0.4;
    m_text(lon+dLon, lat, name, 'color',[0 0 0],...
            'FontWeight','bold','Fontname','Times new roman','FontSize',8);
end

% 标签
% legend([h1,h2,h3],{'Train sample','Test sample','Site'},'Location','northwest');

% 设置图片大小
% set(gca,'Position',[0.05 0.05 0.9 0.9]); % 留一点边距
set(gcf,'Units','centimeter','Position',[0 0 8.5 6]);


%% 辅助函数
function plotGeoEtop(lonRang, latRang, etopoPath)
%%Founction description
%Founction:Draw ETOPO1

% 读取经纬高
lon = ncread(etopoPath,'x');
lat = ncread(etopoPath,'y');
hei = ncread(etopoPath,'z');

% 截取指定范围
lon1 = lonRang(1); lon2 = lonRang(2);
lat1 = latRang(1); lat2 = latRang(2);
ix = (lon1+180)*60+1 : (lon2+180)*60+1;
iy = (lat1+90)*60+1  : (lat2+90)*60+1;
x = lon(ix);
y = lat(iy);
z = hei(ix,iy)';

% m_map绘图
m_proj('miller','lon',[lon1,lon2],'lat',[lat1,lat2]);%'miller' 'lambert'
m_pcolor(x,y,z);

% 配色与色标
caxis([-6000, 2000]);
cmap = [m_colmap('blues',90); m_colmap('gland',30)];
cmap = cmap + (1 - cmap) * 0.5;
colormap(cmap);

% 网格样式
m_grid('linestyle','none','box','fancy','tickdir','in');
m_grid('fontsize', 8); 