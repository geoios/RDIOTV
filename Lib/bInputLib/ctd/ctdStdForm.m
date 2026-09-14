function [Xbt] = ctdStdForm(JpnCtdInfo, textTime)
%% 函数说明
% 功能：CTD标准化格式
for i = 1:31
    t0 = datetime(textTime(i));
    count = 0;
    for j = 1:size(JpnCtdInfo{i},1)
        count = count + 1;
        Xbt{i,1}{count,1} = JpnCtdInfo{i}{j,3};
        Xbt{i,1}{count,2} = seconds(JpnCtdInfo{i}{j,3} - t0);
        Xbt{i,1}{count,3} = JpnCtdInfo{i}{j,5};
        Xbt{i,1}{count,4} = JpnCtdInfo{i}{j,6};
    end
end