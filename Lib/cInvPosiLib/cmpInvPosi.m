function [Output] = cmpInvPosi(testArray, IniFilePath, ObsFilePath, JpnCtdInfo, GgmedProfile)
%% 函数说明
% 功能：反演定位比较
for iStat = testArray
    iStat
    % （1）现场温盐剖面-基准
    cfgPar = 1;
    [Svp{iStat,1}] = cpTempSalSsp(iStat, 'Refe', JpnCtdInfo);
    [PositResu{iStat,1}] = compPositResu_v002(cfgPar, IniFilePath{iStat}, ObsFilePath{iStat}, Svp{iStat,1});

    % （2）GGMED协议温盐剖面
    cfgPar = 1;
    [Svp{iStat,2}] = cpTempSalSsp(iStat, 'Ggmed', JpnCtdInfo, GgmedProfile);
    [PositResu{iStat,2}] = compPositResu_v002(cfgPar, IniFilePath{iStat}, ObsFilePath{iStat}, Svp{iStat,2});
    % 
    % % （3）GGMED协议温盐剖面——约束
    % cfgPar = 2;
    % [PositResu{iStat,3}] = compPositResu_v002(cfgPar, IniFilePath{iStat}, ObsFilePath{iStat}, Svp{iStat,2}, PositResu{iStat,1}.tprCoor);
end

% 导出
Output.Svp = Svp;
Output.PositResu = PositResu;

