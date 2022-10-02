function [avg_trajectory,stats] = AverageTrajectory(session_data)

% pull out x, y, and z location with a column for each reach
x = zeros(100,length(session_data));
y = zeros(100,length(session_data));
z = zeros(100,length(session_data));
for i = 1:length(session_data) % number of reaches
    x(:,i) = session_data(i).InterpolatedHand(:,1);
    y(:,i) = session_data(i).InterpolatedHand(:,2);
    z(:,i) = session_data(i).InterpolatedHand(:,3);
end

% get average for each index (1:100) in each dimension
mean_x = zeros(100,1);
mean_y = zeros(100,1);
mean_z = zeros(100,1);
for i = 1:100
    mean_x(i) = mean(x(i,:));
    mean_y(i) = mean(y(i,:));
    mean_z(i) = mean(z(i,:));
end

%calculate CIs for each index in each dimension
CI_x = zeros(length(x),2);
for i = 1:height(x)
    standard_error = std(x(i,:))/sqrt(size(x,2)); %standard Error
    ts = tinv([0.025  0.975],size(x,2)-1); %t-score for 95% conf. interval
    CI_x(i,:) = mean_x(i) + ts.*standard_error; %confidence interval
end

CI_y = zeros(length(y),2);
for i = 1:height(y)
    standard_error = std(y(i,:))/sqrt(size(y,2)); 
    ts = tinv([0.025  0.975],size(y,2)-1); 
    CI_y(i,:) = mean_y(i) + ts.*standard_error;
end

CI_z = zeros(length(z),2);
for i = 1:height(z)
    standard_error = std(z(i,:))/sqrt(size(z,2)); 
    ts = tinv([0.025  0.975],size(z,2)-1);
    CI_z(i,:) = mean_z(i) + ts.*standard_error; 
end

avg_trajectory = [mean_x mean_y mean_z]; %euclidean

% save stats for output
stats.x = x;
stats.y = y;
stats.z = z;
stats.CI_x = CI_x;
stats.CI_y = CI_y;
stats.CI_x = CI_z;