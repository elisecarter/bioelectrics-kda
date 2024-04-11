function data = CalculateCorrelationCoeff(data)
%calculate different correlation coefficients (based on user selections?)

for i = 1:length(data.Sessions) % iterate thru sessions
    session = data.Sessions(i);
    % pull out successful reach indices
    success_ind = strcmp(session.Behavior,'success');

    if ~isempty(data.ExpertReach)
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

        % improvement of failures normalized to day one (percent increase of
        % failures?)
        this_session = data.Sessions(i).Correlations.FailToExpert3D;
        day_one = data.Sessions(1).Correlations.FailToExpert3D;
        percent_increase = (this_session - day_one) / day_one;
        data.Sessions(i).Correlations.PercentIncreaseofFailures = percent_increase;

    else
        % no expert reach
        data.Sessions(i).Correlations.AllReachesToExpert3D = [];
        data.Sessions(i).Correlations.SuccessToExpert3D = [];
        data.Sessions(i).Correlations.FailToExpert3D = [];
        data.Sessions(i).PercentExpert = [];
        data.Sessions(i).Correlations.PercentIncreaseofFailures = [];
    end

    %calculate reach consistency 
    % shape: mean of pairwise linear correlation of all reaches in session
    % spatial: mean of pairwise euc distance of all reaches in session
    all_reaches = zeros(300,length(session.InitialToMax));
    for j = 1:length(session.InitialToMax)
        all_reaches(:,j) = vertcat(session.InitialToMax(j).DTWHand(:,1), ...
            session.InitialToMax(j).DTWHand(:,2), ...
            session.InitialToMax(j).DTWHand(:,3));
    end
    rho = corr(all_reaches);
    lower_tri = tril(rho,-1); % makes all upper tri values (including the diag) zero
    lower_tri(lower_tri == 0) = [];
    data.Sessions(i).Correlations.shapeConsistency = mean(lower_tri);

    dist = pdist(all_reaches','euclidean');
    data.Sessions(i).Correlations.spatialConsistency = mean(dist);

end