function [output] = polyInteModu(interpPos, StdzNearProf)
%% 函数说明
%功能：基于EOF分析和多项式的时空插值

% 1. EOF 经验正交函数分解
TempEofResult = calcEOF(StdzNearProf.temp);
SalEofResult = calcEOF(StdzNearProf.sal);

% 2. 多项式插值计算
[rescaledTempProf] = reconsProfByEOF(interpPos, StdzNearProf, TempEofResult);
[rescaledSalProf] = reconsProfByEOF(interpPos, StdzNearProf, SalEofResult);

% 3. 导出温盐剖面
n = size(rescaledSalProf,1);
output = [rescaledTempProf rescaledSalProf(:,2) repmat(interpPos(2),n,1)];


%% 辅助函数
function [Eof] = calcEOF(dataMatr)
%%函数说明
% 功能：EOF 经验正交分解

% 1. 去均值处理
[~, nTime] = size(dataMatr);  % 空间点数、时间步数
spatialMean = mean(dataMatr, 2);   % 每个空间点的时间平均
anomData = dataMatr - spatialMean; % 距平（异常场）

% 2. 协方差矩阵 + SVD 分解
covMatrix = (anomData * anomData') / nTime; % 空间协方差矩阵
[f, singularVal, ~] = svd(covMatrix, 0);    % 奇异值分解（EOF 模态）
lambda = diag(singularVal);                 % 特征值（方差）

% 3. 计算主成分 PC
pc = f' * anomData;

% 4. 方差贡献率 & 累积贡献率
contrRatio = lambda / sum(lambda) * 100; % 单个模态贡献率
accuContr = cumsum(contrRatio);          % 累积贡献率

% 5. 自动选取 95% 方差贡献的阶数
pcOrder = find(accuContr >= 95, 1);

% 6. 结果存入结构体
Eof.oriDataMatr = dataMatr;                      % 原始数据
Eof.spatialMean = spatialMean;                   % 均值
Eof.anomData = anomData;                         % 距平场
Eof.spatialMean = repmat(spatialMean, 1, nTime); % 空间平均场
Eof.f = f;                                       % EOF 空间模态
Eof.pc = pc;                                     % 主成分时间序列
Eof.lambda = lambda;                             % 特征值（方差）
Eof.contrRatio = contrRatio;                     % 贡献率
Eof.accuContr = accuContr;                       % 累积贡献率
Eof.pcOrder = pcOrder;                           % 95% 贡献阶数


%% 辅助函数
function [rescaledProfile] = reconsProfByEOF(interpPos, StdzNearProf, EofResult)
%%函数说明
% 功能：基于EOF分解的多项式时空插值

% 1. 获取 EOF 阶数
pcOrder = EofResult.pcOrder;

% 2. 逐主成分进行最小二乘插值
for iPc = 1:pcOrder
    % 构建训练数据集：位置 + 主成分
    trainData = [StdzNearProf.pos', EofResult.pc(iPc, :)'];
    
    % 构建线性方程组系数矩阵
    numSamples = size(trainData, 1);
    coeffMatrix = [ones(numSamples, 1), trainData(:, 1:3)];
    
    % 最小二乘求解系数
    targetVector = EofResult.pc(iPc, :)';
    interceptCoef = pinv(coeffMatrix' * coeffMatrix) * coeffMatrix' * targetVector;
    
    % 插值得到新主成分
    newPrincipalComponent(iPc, 1) = [1, interpPos] * interceptCoef;
end

% 3. 重构最终剖面
rescaledProfile(:, 1) = StdzNearProf.depth;
rescaledProfile(:, 2) = EofResult.spatialMean(:, 1) + EofResult.f(:, 1:pcOrder) * newPrincipalComponent;