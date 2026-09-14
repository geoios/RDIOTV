function [CtdInfo] = extractMatchCtd(impoObsPath, IniInfo, SvpInfo, type)
%% 函数说明
% 功能：提取匹配CTD

% ===========1. CTD按期分类==================
for i = 1:length(IniInfo)
    [CtdDetaPath] = getFileDetaPath(impoObsPath, ['*', IniInfo{i}.campaign, '.*ctd*.csv']);
    [CtdInfo{i,1}] = getCtdData(CtdDetaPath, IniInfo{i}.pos);
end

% ============2. 同天多个CTD取最邻近0点==================
switch type
    case '一期一条'
        for i = 1:length(IniInfo)
            iniTime(i,:) = datetime(IniInfo{i}.gridTime);
            diffTime{i,1} = abs([CtdInfo{i}{:,3}] - iniTime(i, :))';
            
            numCTD = size(CtdInfo{i}, 1);
            if(numCTD > 1)
                [~, idx] = min(diffTime{i});
                CtdInfo{i} = CtdInfo{i}(idx, :); 
            end
        end
    case '一期多条'
        
end
% 去粗差
for i = 1:length(IniInfo)
    if(i == 30 & strcmp(IniInfo{1}.siteName,'TOS2')) 
        CtdInfo{i}{1}(end-1:end,:) = [];
    end
end

% ==============3. 温盐延拓先验约束===================
aimDepth = SvpInfo{i}(:,1);
for i = 1:length(IniInfo)
    for j = 1:size(CtdInfo{i,1},1)
        dtsl = CtdInfo{i}{j,1};
        dtsl = [0 dtsl(1,2:4); dtsl; 2500 dtsl(end,2:4)]; %延拓
    
        newTemp = interp1(dtsl(:,1), dtsl(:,2), aimDepth, "linear");
        newSal = interp1(dtsl(:,1), dtsl(:,3), aimDepth, "linear");
        newLat = interp1(dtsl(:,1), dtsl(:,4), aimDepth, "linear");
        newSvp = delGrosso([aimDepth newTemp newSal newLat]);
    
        CtdInfo{i}{j,5} = [aimDepth newTemp newSal newLat];
        CtdInfo{i}{j,6} = newSvp;
    end
end

% 错误日期修改
CtdInfo{1,1}{1,3}.Year = 2011;



