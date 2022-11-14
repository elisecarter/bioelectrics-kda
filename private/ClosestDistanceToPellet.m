function mean_distance = ClosestDistanceToPellet(session_data)
% calculates the session level mean closest distance to pellet from
% (initiation to max)
% NOTE: this is finding the min distance, should it be finding whatever
% distance is at reach max

closest_distance = zeros(1,length(session_data));
for i = 1:length(session_data)
    delta = session_data(i).HandPositionNormalized; %already relative to pellet (pellet at 0,0)

    distance = vecnorm(delta,2,2); %mm 
    closest_distance(i) = min(distance);
end

mean_distance = mean(closest_distance);
