function [data] = CalculateExpertReach(data)
% the expert reach is the mean of all successful reaches on the final two
% days of training

% pull out successful reach indices on last two days of training
finalDayBehav = [data.Sessions(end).InitialToMax(:).Behavior];
successLocs = strcmp(finalDayBehav,'success');
success_data = data.Sessions(end).InitialToMax(successLocs);

stacked_traj = [];
for i = 1:length(success_data) % number of reaches
    % stack trajectories so we can take mean in the 3rd dimension
    stacked_traj = cat(3,stacked_traj,success_data(i).DTWHand);
end
expert_1 = mean(stacked_traj,3);

% check that there are at least two days of training to calculate expert traj. from
if length(data.Sessions) > 1
    behav = [data.Sessions(end-1).InitialToMax(:).Behavior];
    successLocs = strcmp(behav,'success');
    success_data = data.Sessions(end-1).InitialToMax(successLocs);

    stacked_traj = [];
    for i = 1:length(success_data) % number of reaches
        % stack trajectories so we can take mean in the 3rd dimension
        stacked_traj = cat(3,stacked_traj,success_data(i).DTWHand);
    end
    expert_2 = mean(stacked_traj,3);
    expert_stacked = cat(3,expert_1,expert_2);
else
    expert_stacked = expert_1;
end

data.ExpertReach = mean(expert_stacked,3);