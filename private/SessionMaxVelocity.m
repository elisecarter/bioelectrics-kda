function session_max = SessionMaxVelocity(session_data)
% computes avg max velocity for the session

reach_max = zeros(length(session_data),1);
for i = 1:length(session_data)
    reach_max(i) = max(session_data(i).AbsoluteVelocity);
end

session_max = mean(reach_max);