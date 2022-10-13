function data = CalculateCorrelationCoeff(data)
%calculate different correlation coefficients (based on user seelctions?)

for i = 1:length(data.Sessions)
    session = data.Sessions(i);
    % pull out successful reach indices
    success_ind = strcmp(session.Behavior,'success');

    % correlate each reach to expert reach
    corr = zeros(length(session.InitialToMax),1);
    for j = 1:length(session.InitialToMax) %iterate thru reaches
        temp = corrcoef(session.InitialToMax(j).DTWHandNormalized,data.ExpertReach);
        corr(j) = temp(1,2);
    end
    %data.Sessions(i).Correlations.ReachesToExpert = corr;
    data.Sessions(i).Correlations.AllReachesToExpert = mean(corr);
    
    % index out correlation of successful reaches
    %data.Sessions(i).Correlations.SuccessToExpert = corr(success_ind);
    data.Sessions(i).Correlations.SuccessToExpert = mean(corr(success_ind));
    
    % index out correlation of failed reaches
    %data.Sessions(i).Correlations.FailToExpert = corr(~success_ind);
    data.Sessions(i).Correlations.FailToExpert = mean(corr(~success_ind));

    % determine percent of expert reaches
    num_expert = sum(corr >= 0.95);
    num_reaches = length(corr);
    data.Sessions(i).PercentExpert = num_expert/num_reaches;

    % improvement of failures normalized to day one (percent increase of
    % failures?)
    this_session = data.Sessions(i).Correlations.FailToExpert;
    day_one = data.Sessions(1).Correlations.FailToExpert;
    percent_increase = abs(this_session - day_one) / day_one;
    data.Sessions(i).Correlations.PercentIncreaseofFailuresNorm = percent_increase;
    
end