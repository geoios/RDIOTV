function [P] = desiWeit(dL, type1, type2)
%% 函数说明
%功能：设计权阵
% 权阵
switch type1
    case '单位权'
        p = ones(size(dL,1),1);
end

% 抗差权因子
switch type2
    case '不抗差'
        w = ones(size(dL,1),1);
    case 'MAD法抗差'
        thre = 3;
        M = median(dL);
        M_mad = 1.4826*median(abs(dL - M));%近似中误差
        w = abs(dL - M)./M_mad;
        indexBig = find(w > thre);
        indexSma = find(w <= thre);
        w(indexBig) = 0;
        w(indexSma) = 1;
end

% 最终权
P = diag(p.*w);
