function data = CalculateCorrelationCoeff(data)
%calculate different correlation coefficients based on user seelctions

%correlate each reach to expert reach 
for i = 1:length(data.Sessions)
    session = data.Sessions(i);
    corr = zeros(length(session.InitialToMax),1);
    for j = 1:length(session.InitialToMax)
        temp = corrcoef(session.InitialToMax(j).DTWHandNormalized,data.ExpertReach);
        corr(j) = temp(1,2);
    end
    data.Sessions(i).Correlations.ReachesToExpert = corr;
    data.Sessions(i).Correlations.MeanReachesToExpert = mean(corr);
end