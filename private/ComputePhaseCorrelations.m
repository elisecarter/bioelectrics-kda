function data = ComputePhaseCorrelations(p1data, p2data)

% correlation bewtween phase 1 and phase 2 expert reaches
cc = corrcoef(p1data.ExpertReach,p2data.ExpertReach);
data.ExpertToExpert = cc(1,2);

% correlation between days in phase 1 to phase 2 expert reach (success
% only)
for i = 1:length(p1data.Sessions)
    data.Phase1ToPhase2Expert(i).SessionID = p1data.Sessions(i).SessionID;
    p1session = p1data.Sessions(i);
    % pull out successful reach indices
    success_ind = strcmp(p1session.Behavior,'success');
    % correlate each reach to expert reach
    corr = zeros(length(p1session.InitialToMax),1);
    for j = 1:length(p1session.InitialToMax) %iterate thru reaches
        temp = corrcoef(p1session.InitialToMax(j).DTWHandNormalized,p2data.ExpertReach);
        corr(j) = temp(1,2);
    end
    data.Phase1ToPhase2Expert(i).CorrCoef = mean(corr);
end

% correlation between days in phase 2 to phase 1 expert reach (success
% only)
for i = 1:length(p2data.Sessions)
    data.Phase2ToPhase1Expert(i).SessionID = p2data.Sessions(i).SessionID;
    p2session = p2data.Sessions(i);
    % pull out successful reach indices
    success_ind = strcmp(p2session.Behavior,'success');
    % correlate each reach to expert reach
    corr = zeros(length(p2session.InitialToMax),1);
    for j = 1:length(p2session.InitialToMax) %iterate thru reaches
        temp = corrcoef(p2session.InitialToMax(j).DTWHandNormalized,p1data.ExpertReach);
        corr(j) = temp(1,2);
    end
    data.Phase2ToPhase1Expert(i).CorrCoef = mean(corr);
end