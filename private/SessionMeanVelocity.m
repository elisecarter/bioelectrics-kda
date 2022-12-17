function mean_velocity = SessionMeanVelocity(session_data)
% computes mean euclidean velocity for each session

reach_velocities = zeros(length(session_data),3);
for i = 1:length(session_data)
    reach_velocities(i,:) = mean(session_data(i).InterpolatedVelocity);
end

mean_velocity = mean(reach_velocities);