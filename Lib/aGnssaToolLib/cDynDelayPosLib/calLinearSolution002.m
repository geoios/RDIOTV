function [dX, JCB] = calLinearSolution(IniData, ObsData, SvpData, MP)
%% 函数说明
% 功能：线性化解算

% 传参
MPNum = IniData.MPNum;
N_shot = IniData.Data_file.N_shot;
knots = IniData.knots;
spdeg = IniData.spdeg;
ST = ObsData.ST;
RT = ObsData.RT;
transducer0 = ObsData.tranEnu0;
transducer1 = ObsData.tranEnu1;
alpha0 = ObsData.alpha0;
alpha1 = ObsData.alpha1;
z0 = ObsData.z0;
z1 = ObsData.z1;
detalLOri = ObsData.detalL;
C = meanVelo(SvpData);

% 1. 坐标部分雅可比矩阵
Jcb = zeros(N_shot,MPNum(end));
for ShotNum = 1:N_shot
    index = ObsData.MTPSign(ShotNum);
    tranEnu_ST = transducer0(ShotNum,:);
    tranEnu_RT = transducer1(ShotNum,:);
    % 计算雅可比
    e0 = calCoorJcb(tranEnu_ST,MP(index:index+2));
    e1 = calCoorJcb(tranEnu_RT,MP(index:index+2));
    Jcb(ShotNum,index:index + 2) = -(e0 + e1) ./C;
end

% 2. B样条参数部分雅可比
GamTmp = zeros(1,MPNum(end)-MPNum(1));
for GamNum = 1:length(GamTmp)
    GamTmp(GamNum) = 1;
    detalT = zeros(N_shot,1);
    for ShotNum = 1:N_shot
        [detalT1] = calcDynamicDelay(ST(ShotNum),[MP(1:MPNum(1)),GamTmp],z0(ShotNum,:),alpha0(ShotNum,:),IniData);
        [detalT2] = calcDynamicDelay(RT(ShotNum),[MP(1:MPNum(1)),GamTmp],z1(ShotNum,:),alpha1(ShotNum,:),IniData);
        detalT(ShotNum) = detalT1 + detalT2;
    end
    Jcb(:,MPNum(1)+ GamNum) = detalT;
    GamTmp(GamNum) = 0;
end

% 粗差剔除
trueIndex = find(strcmp(ObsData.flag,'True')==1);
Jcb(trueIndex,:) = [];

% 自动检测并删除无效 / 退化 / 异常的 B 样条参数
DeteleList = [];
for i = 1:length(knots) %删掉节点异常导致失效的B样条参数
    dknots = round(knots{i}(2:end)-knots{i}(1:end-1));
    index = find(dknots>mode(dknots));
    for j = 1 :length(index)
        DeteleIndex = index(j)-spdeg:index(j);
        DeteleList =[DeteleList, DeteleIndex + MPNum(i)];
    end
end
for i = 1:MPNum(end) %删掉雅可比列没变化的退化参数
    if length(unique(Jcb(:,i)))<3
        DeteleList =[DeteleList, i];
    end
end
DeteleList = unique(DeteleList); % 去重、保留有效索引
slvidx = 1:MPNum(end); 
slvidx(DeteleList)= [];
JCB = Jcb(:,slvidx);

% 随机模型
for ShotNum = 1:N_shot
    index = ObsData.MTPSign(ShotNum);
    tranEnu_ST = transducer0(ShotNum,:);
    tranEnu_RT = transducer1(ShotNum,:);
    % 高度角权
    SinPhi0 = (tranEnu_ST(3)-MP(index+2)) / norm(MP(index:index+2)-tranEnu_ST);
    SinPhi1 = (tranEnu_RT(3)-MP(index+2)) / norm(MP(index:index+2)-tranEnu_RT);
    Phi(ShotNum,1) = (SinPhi0 + SinPhi1)/2;
end
Phi(trueIndex)=[];
P = diag(Phi.^2);

% 解算策略
dX = zeros(MPNum(end),1);
detalLOri(trueIndex,:) = [];
switch IniData.constraintTerm
    case 1 % LS
        dx = inv(JCB'*P*JCB)*JCB'*P*detalLOri;
        dX(slvidx) = dx;
    case 2 % 坐标约束LS
        tranCoor = IniData.tranCoor;

        n = size(JCB,2);
        A = eye(MPNum(1));
        B = zeros(MPNum(1),n-MPNum(1));
        JCB = [JCB; A B];

        P2 = (1/0.001^2)*eye(MPNum(1));
        P = blkdiag(P,P2);

        tranCoor = tranCoor';
        dL = tranCoor(:) - MP(1:MPNum(1))';
        detalLOri = [detalLOri; dL];

        dx = inv(JCB'*P*JCB)*JCB'*P*detalLOri;
        dX(slvidx) = dx; 
end


%% 辅助函数
function [ei] = calCoorJcb(tdrPoin, tprPoin)
%%函数说明
% 功能：计算坐标雅可比
deltaCoor = tdrPoin - tprPoin;
if(norm(deltaCoor(1:2)) == 0)
    sin_beta = 0; % 水平方向上的角度为零
    cos_beta = 0; 
    sin_alfa = 1; % 高度角为垂直向上
    cos_alfa = 0;
else
    sin_beta = deltaCoor(2) / norm(deltaCoor(1:2));
    cos_beta = deltaCoor(1) / norm(deltaCoor(1:2));
    sin_alfa = deltaCoor(3) / norm(deltaCoor);
    cos_alfa = norm(deltaCoor(1:2)) / norm(deltaCoor);
end
ei(1) = cos_beta * cos_alfa;%beta方位角；alfa高度角
ei(2) = sin_beta * cos_alfa;
ei(3) = sin_alfa;