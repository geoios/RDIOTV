function [detalT, Grad, detalTofZ] = calcDynamicDelay(time, MP, z, alpha, IniData)
%% 函数说明
% 功能：计算基于ZTD的传播时间校正量

% 传参
knots = IniData.knots;
spdeg = IniData.spdeg;
MPNum = IniData.MPNum;
nchoosekList = IniData.nchoosekList;

% 初始化
detalT = 0;
Grad = [];
BSplineModel = 2; % B样条类型

% 边界条件判断：若节点为空，直接返回初始值
if isempty(knots)
    return;
end

% 1. 时间部分：校正传播时间
[GradT] = Bspline_Function(time, MP(MPNum(1)+1:MPNum(2)), knots{1}, spdeg, nchoosekList, BSplineModel);
detalT  =  GradT * 1;

% 2. 空间部分1：声线影响（船-海底观测站）
[GradE_T_Ray] = Bspline_Function(time, MP(MPNum(2)+1:MPNum(3)), knots{2}, spdeg, nchoosekList, BSplineModel);
[GradN_T_Ray] = Bspline_Function(time, MP(MPNum(3)+1:MPNum(4)), knots{3}, spdeg, nchoosekList, BSplineModel);
detalT_Ray = GradN_T_Ray * z(2) * cos(alpha(2)) + GradE_T_Ray * z(2) * sin(alpha(2));
detalT = detalT  + detalT_Ray;

% 3. 空间部分2：海面位置影响（船-阵列中心）
[GradE_T_Vessel] = Bspline_Function(time, MP(MPNum(4)+1:MPNum(5)), knots{4}, spdeg, nchoosekList, BSplineModel);
[GradN_T_Vessel] = Bspline_Function(time, MP(MPNum(5)+1:MPNum(6)), knots{5}, spdeg, nchoosekList, BSplineModel);
detalT_Vessel =  GradN_T_Vessel * z(1) * cos(alpha(1)) + GradE_T_Vessel * z(1) * sin(alpha(1));
detalT = detalT + detalT_Vessel;

% 4. 最终校正量
detalTofZ = - detalT;
detalT = - detalT * cos(atan(z(2)))^-1;

% 5. 组装梯度数组
Grad = [GradT, GradE_T_Ray, GradN_T_Ray, GradE_T_Vessel, GradN_T_Vessel];


%% 辅助函数
function [Y] = Bspline_Function(u, Mp, knots, spdeg, nchoosekList, model)
%%函数说明
% 功能：B样条拟合
switch model
    case 1 % der-Boor Cox
        Y = 0;
        for i=1:length(Mp)
            Y = Y + Mp(i) * Bbase(i,spdeg,u,knots);
        end
    case 2 % Clark
        Array = u-knots;
        Rnum = find(Array<=0,1);
        Rscope = knots(Rnum);
        Lnum = max(find(Array>0));
        Lscope = knots(Lnum);
        if Rscope == knots(spdeg+1)
            Rnum = Rnum+1;Lnum=Lnum+1;
            Rscope = knots(Rnum);Lscope=knots(Lnum);
        end
        r = (u-Lscope)/(Rscope-Lscope);

        Y = 0;
        for k = 0:1:spdeg
            Y = Y + Mp(Lnum-spdeg+k) * Bbase_Clark(k,spdeg,r,nchoosekList);
        end

end


%% 辅助函数
function [y] = Bbase_Clark(k, spdeg, t, nchoosekList)
%%函数说明
% 功能：B样条拟合基函数
y = 0;
for j = 0:spdeg-k
    y = y+(-1)^j*nchoosekList(j+1)*(t+spdeg-k-j)^spdeg;
end
y = y*prod([1:spdeg])^-1;
