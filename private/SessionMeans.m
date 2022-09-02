function data = SessionMeans(data)
% Adds session level mean velocity, distance to pellet (using max data),

for i = 1:length(data.Sessions)
    session_data = data.Sessions(i).InitialToMax; % interested in initial to max data

    data.Sessions(i).MeanVelocity = SessionVelocity(session_data);
    data.Sessions(i).MeanDistanceToPellet = ClosestDistanceToPellet(session_data);

    if exist('session_data.HandArcLength','var')
        data.Sessions(i).MeanArcLength = mean([session_data.HandArcLength]);
    end

end