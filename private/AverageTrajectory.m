function [avg_trajectory,individual_trajectories] = AverageTrajectory(session_data)

x = zeros(100,length(session_data));
y = zeros(100,length(session_data));
z = zeros(100,length(session_data));

stacked_traj = [];
for i = 1:length(session_data) % number of reaches
    % store individual reaches in matrix for each dimension for plotting
    x(:,i) = session_data(i).InterpolatedHand(:,1);
    y(:,i) = session_data(i).InterpolatedHand(:,2);
    z(:,i) = session_data(i).InterpolatedHand(:,3);

    % stack trajectories so we can take mean in the 3rd dimension
    stacked_traj = cat(3,stacked_traj,session_data(i).InterpolatedHand);
end

avg_trajectory = mean(stacked_traj,3);

individual_trajectories.x = x;
individual_trajectories.y = y;
individual_trajectories.z = z;