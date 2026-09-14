function [Output] = compTransPositResu(IniInfo, SvpInfo, ObsInfo, ParGrid)
%% 函数说明
%功能：海底应答器纯声线跟踪定位（enu）
% 提取观测
statName = str2num(IniInfo.statName(:,2:end));
sSess = 1; lLine = inf; mStat = statName;
index = matcInde(sSess, lLine, mStat, ObsInfo);
ObsData = ObsInfo(index,:);

% 构造待估参数向量
statCoorX0 = IniInfo.statCoor(1:size(mStat,1),:);

% 迭代计算
maxIter = 20; term = 1*10^-3; %截止条件
for iLoop = 1:maxIter
    % 观测方程线性化
    if (nargin == 3) 
        [A, dL, P] = obsEqLinearization(ObsData, mStat, statCoorX0, SvpInfo);
    elseif (nargin == 4)
        [A, dL, P] = obsEqLinearizationRange(ObsData, mStat, statCoorX0, ParGrid, IniInfo);
    end

    % 最小二乘解
    N = A'*P*A;
    U = A'*P*dL;
    dx = N^(-1)*U;

    % 截止条件判断
    dxMatr = reshape(dx, 3, [])';
    if max(vecnorm(dxMatr,2,2)) <= term
        disp('达到收敛条件')
        break
    end

    % 更新坐标
    xNum = size(mStat, 1);
    dStatCoorX0 = (reshape(dx,3,xNum))';
    statCoorX0 = statCoorX0 + dStatCoorX0;
end

% 导出
Output.tranCoor = statCoorX0;
Output.centCoor = mean(Output.tranCoor);
Output.loopNum = iLoop;
Output.dL = dL.*diag(P);


%% 辅助函数1
function [A, dL, P] = obsEqLinearization(ObsData, mStat, xStat, ssp)
%%函数说明
%功能：观测方程线性化
% 初始化
xNum = size(mStat, 1);
e0 = []; e1 = []; t0 = []; t1 = []; tt = []; bb = []; v = [];

% 遍历站
for iStat = 1:xNum
    idx = matcInde(inf, inf, mStat(iStat), ObsData);
    sLoc = ObsData.tranEnu0(idx,:);
    rLoc = ObsData.tranEnu1(idx,:);
    e0Temp = []; e1Temp = []; t0Temp = []; t1Temp = []; ttTemp = [];
    ttTemp = ObsData.TT(idx,:);

    % 遍历历元
    epochNum = size(sLoc, 1);
    for iEpoch = 1:epochNum
        [e0Temp(iEpoch,:), t0Temp(iEpoch,:)] = rayJac(sLoc(iEpoch,:), xStat(iStat,:), ssp);
        [e1Temp(iEpoch,:), t1Temp(iEpoch,:)] = rayJac(rLoc(iEpoch,:), xStat(iStat,:), ssp);
    end

    % 累加计算
    e0 = blkdiag(e0, e0Temp);
    e1 = blkdiag(e1, e1Temp);
    t0 = [t0; t0Temp]; 
    t1 = [t1; t1Temp];
    tt = [tt; ttTemp]; 
end

% 雅可比矩阵
A = -(e0 + e1);
% 观测残差
v = meanVelo(ssp);
dL = (tt - (t0 + t1)) .* v;
% 观测权阵
P = desiWeit(dL,'单位权','MAD法抗差');


%% 辅助函数
function [A, dL, P] = obsEqLinearizationRange(ObsData, mStat, xstat, ParGrid, IniInfo)
%%函数说明
%功能：观测方程线性化
% 初始化
Cc = 1402.392 + 46.691403254999995745 + 17.449376005599997548;
xNum = size(mStat, 1);
e0 = []; e1 = []; dL = [];

% 遍历站
for iStat = 1:xNum
    idx = matcInde(inf, inf, mStat(iStat), ObsData);
    sLoc = ObsData.tranEnu0(idx,:);
    rLoc = ObsData.tranEnu1(idx,:);
    e0Temp = []; e1Temp = []; dLTemp = [];
    tt = ObsData.TT(idx,:);

    % 遍历历元
    for iEpoch = 1:size(sLoc,1)
        aimH = abs(xstat(iStat,3));
        % 往程
        souH0 = abs(sLoc(iEpoch,3));
        dealt0 = sLoc(iEpoch,:) - xstat(iStat,:);
        zRadTan0 = sqrt(dealt0(1)^2 + dealt0(2)^2) / abs(dealt0(3));
        [delayOut0, kc0] = calDelayCorr(souH0, aimH, zRadTan0, ParGrid, 1);

        % 返程
        souH1 = abs(rLoc(iEpoch,3));
        dealt1 = rLoc(iEpoch,:) - xstat(iStat,:);
        zRadTan1 = sqrt(dealt1(1)^2 + dealt1(2)^2)/abs(dealt1(3));
        [delayOut1, kc1] = calDelayCorr(souH1, aimH, zRadTan1, ParGrid, 1);
        
        e0Temp(iEpoch,:) = [dealt0/norm(dealt0)];
        e1Temp(iEpoch,:) = [dealt1/norm(dealt1)];
        L0 = norm(dealt0);
        L1 = norm(dealt1);
        kc = (kc0 + kc1) / 2;
        dLTemp(iEpoch,:) = (tt(iEpoch,:)*Cc-sum(delayOut0)-sum(delayOut1)) / kc - (L0+L1);
    end

    %累加计算
    e0 = blkdiag(e0,e0Temp);
    e1 = blkdiag(e1,e1Temp);
    dL = [dL; dLTemp];
end

% 雅可比矩阵
A = -(e0 + e1);
% 观测权阵
P = desiWeit(dL,'单位权','MAD法抗差');


