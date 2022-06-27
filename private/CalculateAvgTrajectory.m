function [avg_trajectory,x,y,z] = CalculateAvgTrajectory(session_data)

x = zeros(100,length(session_data));
y = zeros(100,length(session_data));
z = zeros(100,length(session_data));

for i = 1:length(session_data) % number of reaches
    temp_x = session_data(i).InterpolatedHandEuc_100(:,1);
    temp_y = session_data(i).InterpolatedHandEuc_100(:,2);
    temp_z = session_data(i).InterpolatedHandEuc_100(:,3);

    %9 pixels per mm, stored data from CLARA is multiplied by 100
    x(:,i) = temp_x./900;
    y(:,i) = temp_y./900;
    z(:,i) = temp_z./900;
end

avg_trajectory = zeros(100,3);
for i = 1:100
        % average reaches elementwise (x,y,z)
        avg_trajectory(i,1) = mean(x(i,:));
        avg_trajectory(i,2) = mean(y(i,:));
        avg_trajectory(i,3) = mean(z(i,:));
end
