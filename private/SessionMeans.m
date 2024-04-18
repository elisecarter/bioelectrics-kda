function data = SessionMeans(data,UI)
% Adds session level means for initial to max data

for i = 1:length(data.Sessions)
    if strcmp(UI.ReachType,'max') % use reachMax
        session_data = data.Sessions(i).InitialToMax;
        str = [data.Sessions(i).SessionID{1} ': Session means calculated using InitialToMax data.'];
        disp(str)
    elseif strcmp(UI.ReachType,'end') % use reachEnd
        session_data = data.Sessions(i).InitialToEnd;
        str = [data.Sessions(i).SessionID{1} ': Session means calculated using InitialToEnd data.'];
        disp(str)
    end

    if ~isempty(session_data)
    % session level velocity
    [data.Sessions(i).MeanEucVelocity, data.Sessions(i).MeanAbsVelocity, data.Sessions(i).MeanMaxVelocity] = SessionMeanVelocity(session_data);

    % mean max velocity location as a percentage of the reach
    data.Sessions(i).MeanMaxVelLocation = mean([session_data.MaxVelocityLocation]);

    % mean euclidean target location
    data.Sessions(i).MeanTargetDistance = SessionMeanTarget(data.Sessions(i));

    % path length [mm]
    data.Sessions(i).MeanPathLength3D = mean([session_data.PathLength3D]);
    data.Sessions(i).MeanPathLengthXY = mean([session_data.PathLengthXY]);
    data.Sessions(i).MeanPathLengthXZ = mean([session_data.PathLengthXZ]);

    % duration [s]
    data.Sessions(i).MeanDuration = mean([session_data.ReachDuration]);
    else % no reaches
        data.Sessions(i).MeanEucVelocity = [];]
        data.Sessions(i).MeanAbsVelocity = [];
        data.Sessions(i).MeanMaxVelocity = [];
        data.Sessions(i).MeanMaxVelLocation = [];
        data.Sessions(i).MeanTargetDistance = [];
        data.Sessions(i).MeanPathLength3D = [];
        data.Sessions(i).MeanPathLengthXY = [];
        data.Sessions(i).MeanPathLengthXZ = [];
        data.Sessions(i).MeanDuration = [];
    
    end
end