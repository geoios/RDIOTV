function [Output] = compPositResu_v002(cfgPar, IniFilePath, ObsFilePath, SvpFilePath, tranCoor)
%% 函数说明
%功能：附加时变延迟的定位结果

% 1. 读取文件
[IniData, ObsData] = readDataToStruct(IniFilePath, ObsFilePath);
SvpData = SvpFilePath;

% 2. 臂长转换
[ObsData] = antAtdTransducer(IniData, ObsData);

% 3. 构造B样条节点
[IniData] = makeBsplineKnots(IniData, ObsData);

% 4. 预计算（包括方位角、天顶角等）
[IniData, ObsData, MP] = preCalc(IniData, ObsData);

% 5. 解算
IniData.constraintTerm = cfgPar;
if(cfgPar == 2)
    IniData.tranCoor = tranCoor;
end

for iLoop = 1:20
    % （1）计算残差
    ObsData = calObsResi002(IniData, ObsData, SvpData, MP);
    % （2）线性化解算
    dX = calLinearSolution002(IniData, ObsData, SvpData(:,1:2), MP);
    MP = MP + dX';
    saveDx(:,iLoop) = dX;
    % （3）收敛条件判断
    tprNum = IniData.MPNum(1);
    dposmax(iLoop) = max(abs(dX(1:tprNum)));
    dbspmax(iLoop) = max(abs(dX(tprNum+1:end)));

    % 收敛判断
    if dposmax(iLoop) < 5e-4 % && dbspmax(iLoop) < 10e-10
        tprCoor = reshape(MP(1:tprNum),3,[]).';
        ctrCoor = mean(tprCoor);
        break;
    end
end

% 导出
Output.tprCoor = tprCoor;
Output.ctrCoor = ctrCoor;
Output.ObsData = ObsData;
Output.saveDx  = saveDx;
Output.loop = iLoop;