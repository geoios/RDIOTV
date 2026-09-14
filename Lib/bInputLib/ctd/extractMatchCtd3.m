function [CtdInfo] = extractMatchCtd(impoObsPath, IniInfo, SvpInfo, JpnCtdInfo)
%% 函数说明
% 功能：提取匹配CTD

% ===========1. CTD按期分类==================
for i = 1:length(IniInfo)
    [CtdDetaPath] = getFileDetaPath(impoObsPath, ['*', IniInfo{i}.campaign, '.*xbt*.csv']);
    [CtdInfo{i,1}] = getCtdData(CtdDetaPath, IniInfo{i}.pos);
end


% ==============3. 温盐延拓先验约束===================
aimDepth = SvpInfo{i}(:,1);
for i = 1:length(IniInfo)
    for j = 1:size(CtdInfo{i,1},1)
        dtsl = CtdInfo{i}{j,1};
        dtsl = [0 dtsl(1,2:3); dtsl; 2500 dtsl(end,2:3)]; %延拓
    
        newTemp = interp1(dtsl(:,1), dtsl(:,2), aimDepth, "linear");
        newSal = JpnCtdInfo{i}{1,5}(:,3);
        newLat = interp1(dtsl(:,1), dtsl(:,3), aimDepth, "linear");
        newSvp = delGrosso([aimDepth newTemp newSal newLat]);
    
        CtdInfo{i,1}{j,5} = [aimDepth newTemp newSal newLat];
        CtdInfo{i,1}{j,6} = newSvp;
    end
end




%% 辅助函数
function [SvpFileInfo] = getCtdData(SvpFileDetaPath, pos)
%%函数说明
% 功能：读取svp观测文件
% 获取声速剖面
for iFile = 1:size(SvpFileDetaPath,1)
    % 按配置读取注释行 -----------------------------------------------------
    filename = SvpFileDetaPath{iFile};
    fid = fopen(filename, 'r', 'n', 'UTF-8');  
    commentLines = {};
    lineIdx = 1;

    while ~feof(fid)
        line = fgetl(fid);
        if ~isempty(line) && startsWith(line, '#') % 按配置的注释规则筛选
            commentLines{lineIdx} = line;
            lineIdx = lineIdx + 1;
        end
    end
    fclose(fid);

    % 用readtable读取数据 --------------------------------------------------
    SvpTabl = readtable(filename);
    try
        latitude = extrLonLatFunc(commentLines{1}, 'lat');
    catch
        latitude = pos(2);
    end
    try 
        longitude = extrLonLatFunc(commentLines{2}, 'lon');
    catch
        longitude = pos(1);
    end
    svpInfo = [SvpTabl.depth SvpTabl.temperature repmat(latitude,size(SvpTabl.depth,1),1)];
    SvpFileInfo{iFile,1} = svpInfo;

    [~,name,ext] = fileparts(SvpFileDetaPath{iFile});%提取文件名
    SvpFileInfo{iFile,2} = [name ext];

    timePattern = '\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}'; % 正则模式：年-月-日 时:分
    timeStr = regexp(commentLines{3}, timePattern, 'match', 'once'); % 提取匹配的字符串
    formTime = datetime(timeStr);
    SvpFileInfo{iFile,3} = formTime;

    try
        SvpFileInfo{iFile,4} = [longitude latitude compJdDay(formTime.Year, formTime.Month, formTime.Day)];
    catch
        SvpFileInfo{iFile,4} = [longitude latitude pos(3)];
    end
end