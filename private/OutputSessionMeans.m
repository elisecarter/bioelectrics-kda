function OutputSessionMeans(cohort,cohortID,path)
% creates an excel file for each cohort with session level data

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

            temp{k,5} = correlations.AllReachesToExpert3D;
            temp{k,6} = correlations.AllReachesToExpertX;
            temp{k,7} = correlations.AllReachesToExpertY;
            temp{k,8} = correlations.AllReachesToExpertZ;

            temp{k,9} = correlations.SuccessToExpert3D;
            temp{k,10} = correlations.SuccessToExpertX;
            temp{k,11} = correlations.SuccessToExpertY;
            temp{k,12} = correlations.SuccessToExpertZ;

            temp{k,13} = correlations.FailToExpert3D;
            temp{k,14} = correlations.FailToExpertX;
            temp{k,15} = correlations.FailToExpertY;
            temp{k,16} = correlations.FailToExpertZ;

            temp{k,17} = correlations.PercentIncreaseofFailures;

            temp{k,18} = correlations.Consistency;
            
            temp{k,19} = data.Sessions(k).MeanEucVelocity(1,1);
            temp{k,19} = data.Sessions(k).MeanEucVelocity(1,1);
            temp{k,20} = data.Sessions(k).MeanEucVelocity(1,2);
            temp{k,21} = data.Sessions(k).MeanEucVelocity(1,3);
            temp{k,22} = data.Sessions(k).MeanAbsVelocity;
            temp{k,23} = data.Sessions(k).MaxAbsVelocity;
            temp{k,24} = data.Sessions(k).MeanDuration;
            temp{k,25} = data.Sessions(k).MeanPathLength3D;
            temp{k,26} = data.Sessions(k).MeanPathLengthXY;
            temp{k,27} = data.Sessions(k).MeanPathLengthXZ;

        end
        C = vertcat(C,temp);
        clear temp
    end
    T = cell2table(C,...
        "VariableNames",["MouseID" "SessionID" "PercentSuccess" ...
        "PercentExpert" "AllReachesToExpert3D" "AllReachesToExpertX" ...
        "AllReachesToExpertY" "AllReachesToExpertZ" "SuccessToExpert3D" ...
        "SuccessToExpertX" "SuccessToExpertY" "SuccessToExpertZ" ...
        "FailToExpert3D" "FailToExpertX" "FailToExpertY" "FailToExpertZ" ...
        "PercentIncreaseOfFailures" "Consistency" ...
        "MeanVelocityX" "MeanVelocityY" "MeanVelocityZ" ...
        "MeanAbsoluteVelocity" "MaxAbsoluteVelocity" "MeanDuration" "MeanPathLength3D" ...
        "MeanPathLengthXY" "MeanPathLengthXZ"]);
    writetable(T,filepath)
    clear C
    clear T
end
