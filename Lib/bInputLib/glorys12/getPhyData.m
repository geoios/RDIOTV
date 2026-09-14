function [SearProf] = getPhyData(CoperRange, CoperProf)
%% 函数说命
%功能：哥白尼剖面获取
%% 功能代码
%给定时空位置，搜索时空格网点
index = find(CoperRange.lonRange(1) <= CoperProf.pos(1,:) & CoperProf.pos(1,:) <= CoperRange.lonRange(2) ...
           & CoperRange.latRange(1) <= CoperProf.pos(2,:) & CoperProf.pos(2,:) <= CoperRange.latRange(2) ...
           & CoperRange.timeRange(1) <= CoperProf.pos(3,:) & CoperProf.pos(3,:) <= CoperRange.timeRange(2));
%提取范围内剖面
SearProf.depth = CoperProf.depth;
SearProf.pos = CoperProf.pos(:,index);
SearProf.temp = CoperProf.temp(:,index);
SearProf.sal = CoperProf.sal(:,index);
% for iProf = 1:size(SearProf.pos,2)
%     svpInfo = [SearProf.depth SearProf.temp(:,iProf) SearProf.sal(:,iProf) repmat(SearProf.pos(2,iProf),size(SearProf.depth,1),1)];
%     svp = delGrosso(svpInfo);
%     SearProf.svp(:,iProf) = svp(:,2);
% end
