function data = SessionMeans(data)
% Adds session level means including velocity, percent success, path
% length, and duration

for i = 1:length(data.Sessions)
    session_data = data.Sessions(i);
    
    % session level velocity
    [data.Sessions(i).MeanEucVelocity, data.Sessions(i).MeanAbsVelocity] = SessionMeanVelocity(session_data.InitialToMax);
    data.Sessions(i).MaxAbsVelocity = SessionMaxVelocity(session_data.InitialToMax);

    % mean euclidean target location
    data.Sessions(i).MeanTargetLocation = SessionMeanTarget(session_data);
    
    % path length [mm]
    data.Sessions(i).MeanPathLength3D = mean([session_data.InitialToMax.PathLength3D]);
    data.Sessions(i).MeanPathLengthXY = mean([session_data.InitialToMax.PathLengthXY]);
    data.Sessions(i).MeanPathLengthXZ = mean([session_data.InitialToMax.PathLengthXZ]);

    % duration [s]
    data.Sessions(i).MeanDuration = mean([session_data.InitialToMax.ReachDuration]);
end