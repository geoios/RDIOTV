function r2 = calculateR2(real_y, pred_y)
%% 函数说明
% 功能：计算R2
y_mean = mean(real_y);
SST = sum((real_y - y_mean).^2);   % 总平方和
SSE = sum((real_y - pred_y).^2);  % 残差平方和
r2 = 1 - SSE / SST;