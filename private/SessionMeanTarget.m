function distance_from_pellet = SessionMeanTarget(session_data)
% computes mean location of hand at reach max for the session

for i = 1:length(session_data.InitialToMax)
    reachMax_location = session_data.InitialToMax(i).HandPositionNormalized(end,:);
    distance(i) = norm(reachMax_location);
end

distance_from_pellet = mean(distance);