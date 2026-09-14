function [svp] = cpTempSalSsp(iStat, type, JpnCtdInfo, GgmedInfo)
%% 函数说明
% 功能：自定义协议温盐SSP

depth = JpnCtdInfo{iStat}{6}(:,1);
latProf   = JpnCtdInfo{iStat}{5}(:,4);

switch type
    case 'Refe'
        svp = JpnCtdInfo{iStat}{6};
        svp(:,4) = JpnCtdInfo{iStat}{5}(:,2);
    case 'Ggmed'
        svp = delGrosso(GgmedInfo{iStat});
        svp(:,4) = GgmedInfo{iStat}(:,2);
    case 'Agmt'
        tempProf = 4 * ones(length(depth),1);
        salProf  = 35 * ones(length(depth),1);
        svpInfo  = [depth tempProf salProf latProf];
        [svp] = delGrosso(svpInfo);
        svp(:,4) = tempProf; % 深度 声速 偏导 温度
end