function [yFit, rss] = fitSinglePeriod(x, y, tHour)
%% 函数说明
% 功能：sin cos拟合
T = tHour * 3600; % 小时 → 秒
omega = 2 * pi / T;

% 构建拟合基阵（无相位，必须 cos + sin 组合）
x = x(:);
A = [cos(omega*x), sin(omega*x), ones(size(x))];

% 最小二乘求解 A, B
coeff = A \ y(:); % 直接左除，比pinv更稳定

% 拟合波形
yFit = A * coeff;

% % 合成振幅（物理意义幅值）
% amplitude = sqrt(A^2 + B^2);

% 残差平方和
rss = sum((y - yFit).^2);