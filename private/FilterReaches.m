function data = FilterReaches(data)

threshold = 1000; %mm/sec
num_sessions = length(data.Sessions);
for i = 1:num_sessions
    num_reaches = length(data.Sessions(i).InitialToMax);
    deleted_log = zeros(1, num_reaches); % initialize for use in loop below
    for j = 1:num_reaches
        k = j - sum(deleted_log); % subtract total # of reaches deleted to adjust index
        this_reach = data.Sessions(i).InitialToMax(k);
        if any(this_reach.AbsoluteVelocity>threshold)
            data.Sessions(i).InitialToMax(k) = [];
            data.Sessions(i).InitialToEnd(k) = [];
            data.Sessions(i).StimLogical(k) = [];
            data.Sessions(i).Behavior(k) = [];
            data.Sessions(i).EndCategory(k) = [];
            
            deleted_log(j) = true; % mark this iteration as deleted
        end
    end
end