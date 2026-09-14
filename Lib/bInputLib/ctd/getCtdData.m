function [SvpFileInfo] = getCtdData(SvpFileDetaPath, pos)
%% 函数说明
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
    svpInfo = [SvpTabl.depth SvpTabl.temperature SvpTabl.salinity repmat(latitude,size(SvpTabl.depth,1),1)];
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
