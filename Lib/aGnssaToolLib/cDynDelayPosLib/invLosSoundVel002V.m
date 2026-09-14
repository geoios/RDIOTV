function [ObsData] = invLosSoundVel(IniData, ObsData, SvpData, tranEnu_ST, tranEnu_RT, MP, H0, H1, Grad0, Grad1, index, ShotNum)
%% 函数说明
% 功能：反演声速场

% 传参
svp = SvpData(:,1:2);

% 1. gammar常数计算
souH1 = abs(tranEnu_ST(3));
aimH = abs(MP(index+2));
svpCutHandTail1 = cutSsp(souH1,aimH,svp);
gammar10 = trapz(svpCutHandTail1(:,1), svpCutHandTail1(:,2).^-2);
gammar20 = trapz(svpCutHandTail1(:,1), svpCutHandTail1(:,2).^-2 .* svpCutHandTail1(:,1));

souH2 = abs(tranEnu_RT(3));
svpCutHandTail2 = cutSsp(souH2,aimH,svp);
gammar11 = trapz(svpCutHandTail2(:,1), svpCutHandTail2(:,2).^-2);
gammar21 = trapz(svpCutHandTail2(:,1), svpCutHandTail2(:,2).^-2 .* svpCutHandTail2(:,1));

% 2. 往返均值计算
H = (H0 + H1)/2;
gammar1 = (gammar10 + gammar11)/2;
gammar2 = (gammar20 + gammar21)/2;

% 3. 观测梯度赋值(Grad1是天顶项)
ObsData.GradT(ShotNum,1)  = (Grad0(:,1) + Grad1(:,1))/2 / gammar1;
ObsData.GradVe(ShotNum,1) = (Grad0(:,2) + Grad1(:,2))/2 * 1000 ./ gammar2;
ObsData.GradVn(ShotNum,1) = (Grad0(:,3) + Grad1(:,3))/2 * 1000 ./ gammar2;
ObsData.GradRe(ShotNum,1) = (Grad0(:,4) + Grad1(:,4))/2 * 1000 ./ H ./ gammar1;
ObsData.GradRn(ShotNum,1) = (Grad0(:,5) + Grad1(:,5))/2 * 1000 ./ H ./ gammar1;

% 4. 声速变化计算（δC(t) = GradT + (ΔE*GradVe + ΔN*GradVn) + (ΔE'*GradRe + ΔN'*GradRn)）
delta_E_V = tranEnu_ST(1) - MP(index);          % E向船-站距离（m）
delta_N_V = tranEnu_ST(2) - MP(index+1);        % N向船-站距离（m）
delta_E_R = tranEnu_ST(1) - IniData.surfAntMean_ST(1);  % E向船-基准距离（m）
delta_N_R = tranEnu_ST(2) - IniData.surfAntMean_ST(2);  % N向船-基准距离（m）
% delta_E_V = MP(index) - MP(index);          % E向船-站距离（m）
% delta_N_V = MP(index+1) - MP(index+1);        % N向船-站距离（m）
% delta_E_R = MP(index) - IniData.surfAntMean_ST(1);  % E向船-基准距离（m）
% delta_N_R = MP(index+1) - IniData.surfAntMean_ST(2);  % N向船-基准距离（m）

ObsData.dV(ShotNum,1) = ObsData.GradT(ShotNum) ...
    + [ObsData.GradVe(ShotNum), ObsData.GradVn(ShotNum)] * [delta_E_V; delta_N_V] / 1000 ... % Unit: 1m/s/m => 1000m/s/km
    + [ObsData.GradRe(ShotNum), ObsData.GradRn(ShotNum)] * [delta_E_R; delta_N_R] / 1000;

% [t1,y1,z1] = invRayTrack(tranEnu_ST, MP(index:index+2), svp);
% [t2,y2,z2] = invRayTrack(tranEnu_RT, MP(index:index+2), svp);
% v01 = sqrt(y1^2+z1^2)/t1;
% v02 = sqrt(y2^2+z2^2)/t2;
C = meanVelo(SvpData);

ObsData.V(ShotNum,1) = C + ObsData.dV(ShotNum,1); %不准确
ObsData.hRange(ShotNum,:) = [souH1 souH2 aimH];
ObsData.tdrtpr(ShotNum,:) = [ObsData.ST(ShotNum,1) tranEnu_ST tranEnu_RT MP(index:index+2)];