function [avg_trajectory,x,y,z] = CalculateAvgTrajectory(session_data)

x = zeros(100,length(session_data));
y = zeros(100,length(session_data));
z = zeros(100,length(session_data));

for i = 1:length(session_data) % number of reaches
    x(:,i) = session_data(i).InterpolatedHand(:,1);
    y(:,i) = session_data(i).InterpolatedHand(:,2);
    z(:,i) = session_data(i).InterpolatedHand(:,3);
end

avg_trajectory = zeros(100,3);
for i = 1:100
        % average reaches elementwise (x,y,z)
        avg_trajectory(i,1) = mean(x(i,:));
        avg_trajectory(i,2) = mean(y(i,:));
        avg_trajectory(i,3) = mean(z(i,:));
end
