function [GgmedProfile] = interpProfileGGMED(PhySet, JpnIniInfo, JpnCtdInfo)
%% 函数说明
% 功能：GGMED温盐插值

% 1. 获取插值深度与先验统计信息
interpDepth = JpnCtdInfo{1}{6}(:, 1);
% prioInfo = getPrioCons(ArgoSet, JpnIniInfo, interpDepth);

% 2. 遍历所有期执行插值
nPos = length(JpnIniInfo);

for i = 1:nPos
    interpPos = JpnIniInfo{i}.pos;
    StdzNearProf{i, 1} = getStdzNearProf(interpPos, PhySet, interpDepth);
    GgmedProfile{i, 1} = polyInteModu(interpPos, StdzNearProf{i, 1});
end

