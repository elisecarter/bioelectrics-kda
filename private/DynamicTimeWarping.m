function [DTW_euclidean,deleteReach] = DynamicTimeWarping(euc)

deleteReach = false;

x = euc(:,1);
y = euc(:,2);
z = euc(:,3);

try
    [pt,~,~] = interparc(linspace(0,1,100), x, y, z);

catch % error in interparc due to position values staying same
     while any(diff(x)==0) || any(diff(y)==0) || any(diff(z)==0) %hand stays in same spot for more than 1 frame on any axis
         is_moving = (diff(x)~=0 & diff(y)~=0 & diff(z)~=0);%index out only moving frames
         x = x(is_moving); % index only the moving frames
         y = y(is_moving);
         z = z(is_moving);
     end

     if length(x) < 2
         deleteReach = true;
         DTW_euclidean = [];
         return
     end

     [pt,~,~] = interparc(linspace(0,1,100), x, y, z);
 end

DTW_euclidean = pt;

