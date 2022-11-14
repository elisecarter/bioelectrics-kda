function OutputSessionMeans(cohort,cohortID,path)

folder = 'SessionMeans';
folder_path = fullfile(path,folder);
if ~exist(folder_path,'dir')
    mkdir(folder_path)
end

for i = 1:length(cohort) %iterate thru cohorts
    filename = sprintf('%s.xlsx',cohortID{i}{1});
    filepath = fullfile(folder_path,filename);

    C = {};
    %pull out session means and put into table
    for j = 1:length(cohort{i}) % iterate thru mice in cohort
        data = cohort{i}{j};
        ID = data.MouseID;

        temp = cell(length(data.Sessions),12);
        for k = 1:length(data.Sessions) % iterate thru sessions
            correlations = data.Sessions(k).Correlations;

            temp{k,1} = ID;
            temp{k,2} = data.Sessions(k).SessionID;

            temp{k,3} = data.Sessions(k).PercentSuccess;
            temp{k,4} = data.Sessions(k).PercentExpert;

            temp{k,5} = correlations.AllReachesToExpert;
            temp{k,6} = correlations.SuccessToExpert;
            temp{k,7} = correlations.FailToExpert;
            temp{k,8} = correlations.PercentIncreaseofFailuresNorm;

            temp{k,9} = data.Sessions(k).MeanVelocity(1,1);
            temp{k,10} = data.Sessions(k).MeanVelocity(1,2);
            temp{k,11} = data.Sessions(k).MeanVelocity(1,3);

            temp{k,12} = data.Sessions(k).MaxAbsVelocity;
            temp{k,13} = data.Sessions(k).MeanDuration;
            temp{k,14} = data.Sessions(k).MeanArcLength;
        end
        C = vertcat(C,temp);
        clear temp
    end
    T = cell2table(C,...
        "VariableNames",["MouseID" "SessionID" "PercentSuccess" ...
        "PercentExpert" "AllReachesToExpert" "SuccessToExpert" ...
        "FailToExpert" "PercentIncreaseOfFailures" "MeanVelocityX" ...
        "MeanVelocityY" "MeanVelocityZ" "MaxAbsoluteVelocity" ...
        "MeanDuration" "MeanPathLength"]);
    writetable(T,filepath)
    clear C
    clear T
end
