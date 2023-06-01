function [data] = CalculateExpertReach(data)
% the expert reach is the mean of all successful reaches on the final two
% days of training

% pull out successful reach indices on last two days of training
success_1 = strcmp(data.Sessions(end).Behavior,'success');

% calculate the average trajectory of all successes on last two days of training
[expert_1 ,~] = AverageTrajectory(data.Sessions(end).InitialToMax(success_1));

% check that there are at least two days of training to calculate expert traj. from
if length(data.Sessions) > 1
    success_2 = strcmp(data.Sessions(end-1).Behavior,'success');
    [expert_2 ,~] = AverageTrajectory(data.Sessions(end-1).InitialToMax(success_2));
    expert_stacked = cat(3,expert_1,expert_2);
else
    expert_stacked = expert_1;
end

data.ExpertReach = mean(expert_stacked,3);