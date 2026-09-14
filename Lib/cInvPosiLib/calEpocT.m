function [T, V] = calEpocT(InvPosiResu, Xbt)
%% 函数说明
% 功能：计算V
for i = 1:31
    st = InvPosiResu.PositResu{i,2}.ObsData.tdrtpr(:,1);
    count = 0;
    for j = 1:size(Xbt{i,1},1)
        at = Xbt{i,1}{j,2};
        idx = find(st <= at, 1, 'last');
        obs = InvPosiResu.PositResu{i,2}.ObsData.tdrtpr(idx,:);

        try
            obsTest1 = InvPosiResu.PositResu{i,2}.ObsData.tdrtpr(idx-1,:);
            obsTest2 = InvPosiResu.PositResu{i,2}.ObsData.tdrtpr(idx+1,:);
        catch
            continue;
        end
        if(isempty(obs) || isempty(obsTest1) || isempty(obsTest2))
            continue;
        end

        count = count + 1;
        % 计算温度
        startH = -(obs(4) + obs(7))./2;
        endH = -obs(10);
        tempProf = cutSsp(startH, endH, Xbt{i,1}{j,3}(:,1:2));
        T{i,1}(count,:) = [st(idx) trapz(tempProf(:, 1), tempProf(:, 2)) ./ (endH-startH)];

        % 计算声速
        % svpProf = cutSsp(startH, endH, Xbt{i,1}{j,4}(:,1:2));
        % V{i,1}(count,:) = [st(idx) trapz(svpProf(:, 1), svpProf(:, 2)) ./ (endH-startH)];
        [t1,y1,z1] = invRayTrack(obs(2:4),obs(8:10),Xbt{i,1}{j,4}(:,1:2));
        [t2,y2,z2] = invRayTrack(obs(5:7),obs(8:10),Xbt{i,1}{j,4}(:,1:2));
        V{i,1}(count,:) = [st(idx) (sqrt(y1^2+z1^2)/t1 + sqrt(y2^2+z2^2)/t2)/2];
    end
end
