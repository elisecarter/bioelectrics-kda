function data = ComputePhaseCorrelations(p1data, p2data)

if ~strcmpi(p1data.MouseID,p2data.MouseID)
    error('Aborting phase correlations, mouse IDs do not match.')
end
data.MouseID = p1data.MouseID;
data.GroupID = p1data.GroupID;
data.Experimentor = p1data.Experimentor;
data.Phase1 = p1data.Phase;
data.Phase2 = p2data.Phase;

%if isfield(p1data,'ExpertReach') && isfield(p2data,'ExpertReach')
% correlation bewtween phase 1 and phase 2 expert reaches
cc = corrcoef(p1data.ExpertReach,p2data.ExpertReach);
data.ExpertToExpert = cc(1,2);

% correlation between days in phase 1 to phase 2 expert reach
for i = 1:length(p1data.Sessions)
    data.Phase1ToPhase2Expert(i).SessionID = p1data.Sessions(i).SessionID;

    p1session = p1data.Sessions(i);
    % correlate each reach to expert reach
    corr = zeros(length(p1session.InitialToMax),1);
    for j = 1:length(p1session.InitialToMax) %iterate thru reaches
        temp = corrcoef(p1session.InitialToMax(j).DTWHand,p2data.ExpertReach);
        corr(j) = temp(1,2);
    end
    data.Phase1ToPhase2Expert(i).AllReaches = mean(corr);

    % pull out successful reach indices
    success_ind = strcmp(p1session.Behavior,'success');
    data.Phase1ToPhase2Expert(i).Success = mean(corr(success_ind));

    % failed reaches (not success)
    data.Phase1ToPhase2Expert(i).Failure = mean(corr(~success_ind));

    % percent expert on phase 1 days using expert from phase 2
    % determine percent of expert reaches
    num_expert = sum(corr >= 0.95);
    num_reaches = length(corr);
    data.Phase1ToPhase2Expert(i).PercentExpert = num_expert/num_reaches;
end

% correlation between days in phase 2 to phase 1 expert reach 
for i = 1:length(p2data.Sessions)
    data.Phase2ToPhase1Expert(i).SessionID = p2data.Sessions(i).SessionID;

    p2session = p2data.Sessions(i);
    % correlate each reach to expert reach
    corr = zeros(length(p2session.InitialToMax),1);
    for j = 1:length(p2session.InitialToMax) %iterate thru reaches
        temp = corrcoef(p2session.InitialToMax(j).DTWHand,p1data.ExpertReach);
        corr(j) = temp(1,2);
    end
    data.Phase2ToPhase1Expert(i).AllReaches = mean(corr);

    % pull out successful reach indices
    success_ind = strcmp(p2session.Behavior,'success');
    data.Phase2ToPhase1Expert(i).Success = mean(corr(success_ind));

    % failed reaches (not success)
    data.Phase2ToPhase1Expert(i).Failure = mean(corr(~success_ind));

    % percent expert on phase 2 days using expert from phase 1 (recovery)
    % determine percent of expert reaches
    num_expert = sum(corr >= 0.95);
    num_reaches = length(corr);
    data.Phase2ToPhase1Expert(i).PercentExpert = num_expert/num_reaches;
end

    
