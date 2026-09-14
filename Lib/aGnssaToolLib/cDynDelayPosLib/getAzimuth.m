function [azimuth] = GetAzimuth(tdrPoint, tprPoint)
%% 函数说明
% 功能：计算应答器相对换能器的方位角

% 计算相对坐标
deltaE = tprPoint(1) - tdrPoint(1);  % 水平方向偏移（东向为正）
deltaN = tprPoint(2) - tdrPoint(2);  % 竖直方向偏移（北向为正） 顺时针起始方位

% 计算原始方位角（atan2(y, x) 这里参数顺序是deltaE, deltaN，对应方位角定义）
azimuthOfRaw = atan2(deltaE, deltaN);

% 将方位角归一化到 [0, 2π) 范围
if azimuthOfRaw < 0
    azimuth = 2 * pi + azimuthOfRaw;
else
    azimuth = azimuthOfRaw;
end