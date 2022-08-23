function data = SessionLevelData(data)
% Adds session level mean velocity, distance to pellet (using max data
% point), 

for i = 1:length(data)
    [data{i}.ExpertReach,~,~,~] = AverageTrajectory(data{i}.Sessions(end).InitialToMax);
    for j = 1:length(data{i}.Sessions)
        session_data = data{i}.Sessions(j).InitialToMax;
        
        data{i}.Sessions(j).MeanVelocity = SessionVelocity(session_data);
        data{i}.Sessions(j).MeanDistanceToPellet = ClosestDistanceToPellet(session_data);
    end
end

%eep = corrcoef(DTWHand)