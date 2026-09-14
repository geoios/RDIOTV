%% 脚本说明
%功能：温度反演


%% 脚本配置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc; clear;
fullPath = mfilename('fullpath');
scriPath = fileparts(fullPath);
% 导入路径
    % 日本观测文件
    impoIniPath = 'E:\cResearchTopic_code\0Data\Data_import\GNSSA\Jpn\data_Tohoku2011-2020\initcfg\TOS2\';
    impoObsPath = 'E:\cResearchTopic_code\0Data\Data_import\GNSSA\Jpn\data_Tohoku2011-2020\obsdata\TOS2\';
    impoSvpPath = 'E:\cResearchTopic_code\0Data\Data_import\GNSSA\Jpn\data_Tohoku2011-2020\obsdata\TOS2\';
    % 实测Ctd
    impoCtdPath = 'E:\cResearchTopic_code\0Data\Data_import\GNSSA\JpnWithCtd\TOS2\';
    % GGMED
    load('E:\cResearchTopic_code\0Data\Data_import\GGMED\Phy\PhySetNew.mat');
% 导出路径
    expoFigPath = [scriPath '\Data_export\Fig\']; 
    expoMatPath = [scriPath '\Data_export\Mat\']; 
% 绘图设置
set(0, 'DefaultAxesFontSize', 10, ...
    'DefaultAxesFontName', 'Times new roman', ...
    'DefaultAxesLineWidth', 0.75, ...
    'DefaultAxesTickDir', 'in', ...
    'Defaultfigurecolor','w', ...
    'DefaultFigureUnits', 'centimeter', ...
    'DefaultFigurePosition', [5 5 8.5 8.5]);


%% ====================== 1. 提取CTD ====================================
% 读取观测数据
[IniFilePath] = getFileDetaPath(impoIniPath,'*-initcfg.ini');
[SvpFilePath] = getFileDetaPath(impoSvpPath,'*-svp.csv');
[ObsFilePath] = getFileDetaPath(impoObsPath,'*-obs.csv');
[JpnIniInfo] = getIniData(IniFilePath);
[JpnSvpInfo] = getSvpData(SvpFilePath);
[JpnObsInfo] = getObsData(ObsFilePath, JpnIniInfo, 'Japan');

% 读取CTD
[JpnCtdInfo] = extractMatchCtd(impoCtdPath, JpnIniInfo, JpnSvpInfo, '一期一条'); %定位CTD
[JpnCtdInfo2] = extractMatchCtd(impoCtdPath, JpnIniInfo, JpnSvpInfo, '一期多条'); %CTD
[JpnCtdInfo3] = extractMatchCtd3(impoCtdPath, JpnIniInfo, JpnSvpInfo, JpnCtdInfo); %XBT

% 读取时间标记
[textTime, timeLong] = readTimeMark(JpnIniInfo, JpnObsInfo);

% 全球格网海洋环境
[GgmedProfile] = interpProfileGGMED(PhySetNew, JpnIniInfo, JpnCtdInfo);


figure % 绘制CTD声速剖面 JpnCtdInfo2 JpnCtdInfo3
plotCtdProf(JpnCtdInfo, textTime, 'T'); 

figure % 绘制GGMED剖面
plotGgmedProf(GgmedProfile, JpnCtdInfo, JpnIniInfo, 'T');


%% ===================== 2. 反演定位 =====================================
testArray = 1:length(JpnCtdInfo);
[InvPosiResu] = cmpInvPosi(testArray, IniFilePath, ObsFilePath, JpnCtdInfo, GgmedProfile);

% 外符合验证
[Xbt2] = ctdStdForm(JpnCtdInfo2, textTime);
[Xbt3] = ctdStdForm(JpnCtdInfo3, textTime);
[T2] = calEpocT(InvPosiResu, Xbt2);
[T3] = calEpocT(InvPosiResu, Xbt3);


figure % 观测构型
plotObsShap(InvPosiResu, textTime);

figure % 观测构型
plotObsShapNew(InvPosiResu, textTime);
print(gcf,'-djpeg','-r600',[expoFigPath 'Fig1']);

figure % 反演温度对比（GGMED）
plotDtGgmed(InvPosiResu, textTime);

figure % 反演温度对比（GGMED）
plotDtGgmedNew(InvPosiResu, textTime);
print(gcf,'-djpeg','-r600',[expoFigPath 'Fig8']);

figure % 相关分析
plotDtCorr(InvPosiResu, textTime);


%% ===================== 3. 物理分析 =====================================
%  信号分解
[DecSignal] = decSignal(testArray, InvPosiResu);

% 最优周期格网法搜索
[GridSearPeriTrend] = gridSearPeri(testArray, DecSignal, 'trend');
[GridSearPeriRes] = gridSearPeri(testArray, DecSignal, 'res');

% 信息统计
[StatsTable, StatsTableMore] = bwAnal(GridSearPeriTrend, JpnIniInfo, textTime, timeLong);

% 系统偏差
[StatsYearBias] = calSystBias(T2, T3, DecSignal);


figure % 反演温度对比
plotDt(DecSignal, T2, T3, textTime);

figure % 反演温度对比
plotDtNew(DecSignal, T2, T3, textTime);

% figure % 反演温度对比
plotDtNew2(DecSignal, T2, T3, textTime);
print(gcf,'-djpeg','-r600',[expoFigPath 'Fig2']);

figure % 多年时序
plotDtMy(StatsYearBias, textTime);
print(gcf,'-djpeg','-r600',[expoFigPath 'Fig3']);

figure % 频带分布
plotBwAnal(GridSearPeriTrend, textTime);

figure % 频带分布
plotBwAnalNew(GridSearPeriTrend, textTime);
print(gcf,'-djpeg','-r600',[expoFigPath 'Fig4']);

figure % 高频信号分析
plotBwAnalHf(GridSearPeriRes, textTime);
print(gcf,'-djpeg','-r600',[expoFigPath 'Fig5']);

figure % 相关分析
plotHfCorrAnal(GridSearPeriRes, InvPosiResu, textTime);

figure % 趋势搜索*
plotGridSear(GridSearPeriTrend, textTime);

figure % 残差搜索*
plotGridSear(GridSearPeriRes, textTime);

%保存
save([expoMatPath 'Main20260727.mat']);
