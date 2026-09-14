function [svpCutHandTail] = cutSsp(souH,aimH,svp)
%% 函数说明
%功能：上下裁剪ssp
%输入：+souPos 源坐标（正数）
%      +aimPos 目标坐标（正数）
%      +ssp 观测声速剖面
%输出：+output 裁剪ssp
%% 功能代码
% 缩减剖面起始位置
if (souH >= svp(1,1)) 
    depthMark = find(svp(:,1) <= souH);
    extRange = [svp(depthMark(end),:);svp(depthMark(end)+1,:)];
    %线性插值
    k = (extRange(2,2)-extRange(1,2))/(extRange(2,1)-extRange(1,1));
	souV = extRange(1,2) + k*(souH - extRange(1,1));
    svpCutHand = [souH souV;svp(depthMark(end)+1:end,:)];
else
    error('换能器位置错误！');
end
% 裁剪剖面终止位置
if (aimH == svpCutHand(end,1))%不变
    svpCutHandTail = svpCutHand;
elseif (aimH < svpCutHand(end,1))%收缩 
    depthMark2 = find(svpCutHand(:,1) >= aimH);
    extRange = [svpCutHand(depthMark2(1)-1,:);svpCutHand(depthMark2(1),:)];
    k = (extRange(2,2)-extRange(1,2))/(extRange(2,1)-extRange(1,1));
    aimV = extRange(1,2) + k*(aimH - extRange(1,1));
    svpCutHandTail = [svpCutHand(1:depthMark2(1)-1,:);aimH aimV];
else%简单扩展
    error('声速剖面需要延拓！');
	% extRange = [svpCutHand(end-1,:);svpCutHand(end,:)];
	% k = (extRange(2,2)-extRange(1,2))/(extRange(2,1)-extRange(1,1));
    % aimV = extRange(1,2) + k*(aimH - extRange(1,1));
    % svpCutHandTail = [svpCutHand;aimH aimV];
end

