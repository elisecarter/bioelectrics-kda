function data = SessionMeans(data,UI)
% Adds session level means for initial to max data

for i = 1:length(data.Sessions)
    if UI.ReachType == 1 % reachMax
        session_data = data.Sessions(i).InitialToMax;
        str = [data.Session(i).SessionID ': Session means calculated using InitialToMax data.'];
        disp(str)
    elseif UI.ReachType == 2 % reachEnd
        session_data = data.Sessions(i).InitialToEnd;
        str = [data.Session(i).SessionID ': Session means calculated using InitialToEnd data.'];
        disp(str)
    else % both
        break % go to next loop
    end

    % session level velocity
    [data.Sessions(i).MeanEucVelocity, data.Sessions(i).MeanAbsVelocity, data.Sessions(i).MeanMaxVelocity] = SessionMeanVelocity(session_data);

    % mean max velocity location as a percentage of the reach
    data.Sessions(i).MeanMaxVelLocation = mean([session_data.MaxVelocityLocation]);

    % mean euclidean target location
    data.Sessions(i).MeanTargetLocation = SessionMeanTarget(data.Sessions(i));

    % path length [mm]
    data.Sessions(i).MeanPathLength3D = mean([session_data.PathLength3D]);
    data.Sessions(i).MeanPathLengthXY = mean([session_data.PathLengthXY]);
    data.Sessions(i).MeanPathLengthXZ = mean([session_data.PathLengthXZ]);

    % duration [s]
    data.Sessions(i).MeanDuration = mean([session_data.ReachDuration]);
end

if UI.ReachType == 3 % both
    str = [data.Session(i).SessionID ': Session means calculated using InitialToMax and InitialToEnd data.'];
    disp(str)
    for i = 1:length(data.Sessions)
        session_data = data.Sessions(i);

        % session level velocity
        [data.Sessions(i).SessionMeansMax.MeanEucVelocity, data.InitialToMax.Sessions(i).MeanAbsVelocity, data.InitialToMax.Sessions(i).MeanMaxVelocity] = SessionMeanVelocity(session_data.InitialToMax);
        [data.Sessions(i).SessionMeansEnd.MeanEucVelocity, data.InitialToEnd.Sessions(i).MeanAbsVelocity, data.InitialToEnd.Sessions(i).MeanMaxVelocity] = SessionMeanVelocity(session_data.InitialToEnd);

        % mean max velocity location as a percentage of the reach
        data.Sessions(i).SessionMeansMax.MeanMaxVelLocation = mean([session_data.InitialToMax.MaxVelocityLocation]);
        data.Sessions(i).SessionMeansEnd.MeanMaxVelLocation = mean([session_data.InitialToEnd.MaxVelocityLocation]);

        % mean euclidean target location
        data.Sessions(i).MeanTargetLocation = SessionMeanTarget(data.Sessions(i));

        % path length [mm]
        data.Sessions(i).SessionMeansMax.MeanPathLength3D = mean([session_data.InitialToMax.PathLength3D]);
        data.Sessions(i).SessionMeansMax.MeanPathLengthXY = mean([session_data.InitialToMax.PathLengthXY]);
        data.Sessions(i).SessionMeansMax.MeanPathLengthXZ = mean([session_data.InitialToMax.PathLengthXZ]);
        data.Sessions(i).SessionMeansEnd.MeanPathLength3D = mean([session_data.InitialToEnd.PathLength3D]);
        data.Sessions(i).SessionMeansEnd.MeanPathLengthXY = mean([session_data.InitialToEnd.PathLengthXY]);
        data.Sessions(i).SessionMeansEnd.MeanPathLengthXZ = mean([session_data.InitialToEnd.PathLengthXZ]);

        % duration [s]
        data.Sessions(i).SessionMeansMax.MeanDuration = mean([session_data.InitialToMax.ReachDuration]);
        data.Sessions(i).SessionMeansEnd.MeanDuration = mean([session_data.InitialToEnd.ReachDuration]);
    end
end