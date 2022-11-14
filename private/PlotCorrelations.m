function PlotCorrelations(data)

days = 1:length(data.Sessions);
correlations = [data.Sessions.Correlations];
ReachesToExpert = [correlations.MeanReachesToExpert];

figure;
plot(days,ReachesToExpert)
