function [DTW_euclidean, arc_length] = DynamicTimeWarping(euc)

x = euc(:,1);
y = euc(:,2);
z = euc(:,3);

try
    [pt,~,~] = interparc(linspace(0,1,100), x, y, z);

catch % error in interparc due to position values staying same
    moving_log = (diff(x)~=0 & diff(y)~=0 & diff(z)~=0);
    x = x(moving_log);
    y = y(moving_log);
    z = z(moving_log);
    [pt,~,~] = interparc(linspace(0,1,100), x, y, z);
end

DTW_euclidean = pt;

