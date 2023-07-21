function data = CalculateCorrelationCoeff(data)
%calculate different correlation coefficients (based on user selections?)

for i = 1:length(data.Sessions) % iterate thru sessions
    session = data.Sessions(i);
    % pull out successful reach indices
    success_ind = strcmp(session.Behavior,'success');

    % correlate each reach to expert reach
    cc = zeros(length(session.InitialToMax),1);
    for j = 1:length(session.InitialToMax) %iterate thru reaches
        temp = corrcoef(session.InitialToMax(j).DTWHand,data.ExpertReach);
        cc(j) = temp(1,2);
    end
    data.Sessions(i).Correlations.AllReachesToExpert3D = mean(cc);
    
    % index out correlation of successful reaches
    data.Sessions(i).Correlations.SuccessToExpert3D = mean(cc(success_ind));
    
    % index out correlation of failed reaches
    data.Sessions(i).Correlations.FailToExpert3D = mean(cc(~success_ind));

    % determine percent of expert reaches
    num_expert = sum(cc >= 0.95);
    num_reaches = length(cc);
    data.Sessions(i).PercentExpert = num_expert/num_reaches;

    %correlations to expert reach in each dimension
    ccEuc = zeros(length(session.InitialToMax),1);
    for j = 1:length(session.InitialToMax) %iterate thru reaches
        temp = corr(session.InitialToMax(j).DTWHand,data.ExpertReach);
        ccEuc(j,1) = temp(1,1); %x
        ccEuc(j,2) = temp(2,2); %y
        ccEuc(j,3) = temp(3,3); %z
    end
    data.Sessions(i).Correlations.AllReachesToExpertX = mean(ccEuc(:,1));
    data.Sessions(i).Correlations.AllReachesToExpertY = mean(ccEuc(:,2));
    data.Sessions(i).Correlations.AllReachesToExpertZ = mean(ccEuc(:,3));
    
    % index out correlation of successful reaches
    data.Sessions(i).Correlations.SuccessToExpertX = mean(ccEuc(success_ind,1));
    data.Sessions(i).Correlations.SuccessToExpertY = mean(ccEuc(success_ind,2));
    data.Sessions(i).Correlations.SuccessToExpertZ = mean(ccEuc(success_ind,3));
    
    % index out correlation of failed reaches
    data.Sessions(i).Correlations.FailToExpertX = mean(ccEuc(~success_ind,1));
    data.Sessions(i).Correlations.FailToExpertY = mean(ccEuc(~success_ind,2));
    data.Sessions(i).Correlations.FailToExpertZ = mean(ccEuc(~success_ind,3));

    %calculate reach consistency (mean of pairwise correlation of all
    %reaches in session)
    all_reaches = zeros(300,length(session.InitialToMax));
    for j = 1:length(session.InitialToMax)
        all_reaches(:,j) = vertcat(session.InitialToMax(j).DTWHand(:,1), ...
            session.InitialToMax(j).DTWHand(:,2), ...
            session.InitialToMax(j).DTWHand(:,3));
    end
    rho = corr(all_reaches);
    lower_tri = tril(rho,-1); % makes all upper tri values (including the diag) zero
    lower_tri(lower_tri == 0) = [];
    data.Sessions(i).Correlations.Consistency = mean(lower_tri);

    % improvement of failures normalized to day one (percent increase of
    % failures?)
    this_session = data.Sessions(i).Correlations.FailToExpert3D;
    day_one = data.Sessions(1).Correlations.FailToExpert3D;
    percent_increase = (this_session - day_one) / day_one;
    data.Sessions(i).Correlations.PercentIncreaseofFailures = percent_increase;
    
end