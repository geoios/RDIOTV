function [textTime, timeLong] = readTimeMark(JpnIniInfo, JpnObsInfo)
%% 函数说明
% 功能：读取时间标记

% =============太阳历==============
obsTime = cellfun(@(x) x.gridTime, JpnIniInfo, 'UniformOutput', false);
obsTime = cell2mat(obsTime);
obsTimeOut = datetime(obsTime(:,1), obsTime(:,2), obsTime(:,3));
textTime = string(obsTimeOut, 'yyyy-MM-dd');

% ==============月亮历================
% for i = 1:length(textTime)
%     % 提取观测时间并转换为小时
%     time = JpnObsInfo{i}.ST ./ 3600;
%     timeMark(i,1) = (max(time) + min(time)) / 2;
% end
% 
% addDay = floor((timeMark + 8) / 24);
% obsTime(:,3) = obsTime(:,3) + addDay(:,1);
% obsTimeStd = datetime(obsTime(:,1), obsTime(:,2), obsTime(:,3));
% 
% for i = 1:length(textTime)
%     obj = clsdate(year(obsTimeStd(i)), month(obsTimeStd(i)), day(obsTimeStd(i)));
%     lunarDate = obj.SolarDate2LunarDate();
%     obsTimeLunar(i,:) = [lunarDate.year lunarDate.month lunarDate.day];
% end
% obsTimeLunarOut = datetime(obsTimeLunar(:,1), obsTimeLunar(:,2), obsTimeLunar(:,3));
% textTimeLunar = string(obsTimeLunarOut, 'yyyy-MM-dd');

% =============时间长度================
for i = 1:length(textTime)
    % 提取观测时间并转换为小时
    time = JpnObsInfo{i}.ST ./ 3600;
    diffTime = diff(time);
    idx = (find(diffTime > 1)).';

    if(isempty(idx))
        timeLong(i,1) = max(time) - min(time);
    else
        idxS = [1 idx+1];
        idxE = [idx length(time)];
        for j = 1:length(idxS)
            timeLongTmp(j,1) = time(idxE(j)) - time(idxS(j));
        end
        timeLong(i,1) = sum(timeLongTmp);
    end 
end
