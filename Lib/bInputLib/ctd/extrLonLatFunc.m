function posdd = extrLonLatFunc(posLine, type)
%% 函数说明
% 功能：提取纬度
% 仅保留有效信息
posStr = regexprep(posLine, '[^0-9\-\.NS]', '');

% 分离「度-分」和「半球标识」
hemisphere = posStr(end); 
dmStr = posStr(1:end-1); 

% 拆分「度」和「分」
dmParts = strsplit(dmStr, '-'); 
degree = str2double(dmParts{1}); 
minute = str2double(dmParts{2}); 

% 北半球（N）为正，南半球（S）为负
switch type
    case 'lon'
        if strcmpi(hemisphere, 'E')
            sign = 1;
        elseif strcmpi(hemisphere, 'W')
            sign = -1;
        else
            error('半球标识错误！');
        end
    case 'lat'
        if strcmpi(hemisphere, 'N')
            sign = 1;
        elseif strcmpi(hemisphere, 'S')
            sign = -1;
        else
            error('半球标识错误！');
        end
end

% 应用转换公式
posdd = sign * (degree + minute / 60);