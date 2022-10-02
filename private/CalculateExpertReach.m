function [data] = CalculateExpertReach(data)
% the expert reach is the mean of all successful reaches on the final
% day of training

% pull out successful reach indices
success_ind = strcmp(data.Sessions(end).Behavior,'success');

% calculate the average trajectory of all successes
[data.ExpertReach,stats] = AverageTrajectory(data.Sessions(end).InitialToMax(success_ind));
