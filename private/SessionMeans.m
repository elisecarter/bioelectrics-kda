function data = SessionMeans(data)
% Adds session level mean velocity, distance to pellet (using max data),

for i = 1:length(data.Sessions)
    session_data = data.Sessions(i); % interested in initial to max data
    
    % session level velocity
    data.Sessions(i).MeanVelocity = SessionMeanVelocity(session_data.InitialToMax);
    data.Sessions(i).MaxAbsVelocity = SessionMaxVelocity(session_data.InitialToMax);
    data.Sessions(i).MeanTargetLocation = SessionMeanTarget(session_data);
    
    % percent of successful reaches
    num_success = sum(strcmp(session_data.Behavior,'success'));
    num_reaches = length(session_data.Behavior);
    data.Sessions(i).PercentSuccess = num_success/num_reaches;
    
    % path length
    data.Sessions(i).MeanArcLength = mean([session_data.InitialToMax.HandArcLength]);

    % duration
    data.Sessions(i).MeanDuration = mean([session_data.InitialToMax.ReachDuration]);
    end
end