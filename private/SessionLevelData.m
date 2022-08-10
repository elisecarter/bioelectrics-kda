function data = SessionLevelData(data)

for i = 1:length(data)
data = data{i};
    for j = 1:length(data.Sessions)
        session_data = data.Sessions(j);
        session_data.MeanVelocity = SessionVelocity(session_data.InitialToMax);

        session_data.DistanceToPellet = DistanceToPellet(session_data.InitialToMax);
    end
end