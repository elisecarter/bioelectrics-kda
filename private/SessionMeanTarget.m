function target_location = SessionMeanTarget(session_data)

for i = 1:length(session_data.InitialToMax)
    reach_max(i,1:3) = session_data.InitialToMax(i).HandPositionNormalized(end,:);
end

target_location = mean(reach_max);