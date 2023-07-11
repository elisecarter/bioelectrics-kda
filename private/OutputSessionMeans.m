function OutputSessionMeans(group,groupID,path)
% creates an excel file for each cohort with session level data

T = table;
for i = 1:length(group) % iterate thru experiemental groups
    for j = 1:length(group{i}) % iterate thru mice in each group
        data = group{i}{j};
        for k = 1:length(data.Sessions) % iterate thru sessions
            correlations = data.Sessions(k).Correlations;

            MouseID{k,1} = data.MouseID;
            Group{k,1} = groupID{i};
            SessionID{k,1} = data.Sessions(k).SessionID;
            NumReaches{k,1} = data.Sessions(k).ReachAttempts;

            SuccessPercent{k,1} = data.Sessions(k).PercentSuccess;
            ExpertPercent{k,1} = data.Sessions(k).PercentExpert;
            CorrAllReachesToExpert{k,1} = correlations.AllReachesToExpert3D;
            CorrSuccessToExpert{k,1} = correlations.SuccessToExpert3D;
            CorrFailToExpert{k,1} = correlations.FailToExpert3D;
            PercentImprovement{k,1} = correlations.PercentIncreaseofFailures;
            SessionConsistency{k,1} = correlations.Consistency;

            MeanVelocityX{k,1} = data.Sessions(k).MeanEucVelocity(1,1);
            MeanVelocityY{k,1} = data.Sessions(k).MeanEucVelocity(1,2);
            MeanVelocityZ{k,1} = data.Sessions(k).MeanEucVelocity(1,3);
            MeanAbsVelocity{k,1} = data.Sessions(k).MeanAbsVelocity;
            MeanMaxVelocity{k,1} = data.Sessions(k).MeanMaxVelocity;
            MeanMaxVelocityLocation{k,1} = data.Sessions(k).MeanMaxVelLocation;
            MeanDuration{k,1} = data.Sessions(k).MeanDuration;
            MeanPathLength3D{k,1} = data.Sessions(k).MeanPathLength3D;
            MeanPathLengthXY{k,1} = data.Sessions(k).MeanPathLengthXY;
            MeanPathLengthXZ{k,1} = data.Sessions(k).MeanPathLengthXZ;

            StimAccuracy{k,1} = data.Sessions(k).StimAccuracy;
            StimSpecificity{k,1} = data.Sessions(k).StimSpecificity;
            StimSensitivity{k,1} = data.Sessions(k).StimSensitivty;

            PercentFailureType_Grasp{k,1} = data.Sessions(i).PercentFailuresGrasp;
            PercentFailureType_Reach{k,1} = data.Sessions(i).PercentFailuresReach;
            PercentFailureType_Retrieval{k,1} = data.Sessions(i).PercentFailuresRetrieval;
        end

        temp = table(MouseID,SessionID,Group,NumReaches,SuccessPercent,ExpertPercent, ...
            CorrAllReachesToExpert,CorrSuccessToExpert,CorrFailToExpert, ...
            PercentImprovement,SessionConsistency,MeanVelocityX, ...
            MeanVelocityY,MeanVelocityZ,MeanAbsVelocity,MeanMaxVelocity, ...
            MeanMaxVelocityLocation,MeanDuration, ...
            MeanPathLength3D,MeanPathLengthXY,MeanPathLengthXZ, ...
            StimAccuracy,StimSpecificity,StimSensitivity,PercentFailureType_Grasp, ...
            PercentFailureType_Reach,PercentFailureType_Retrieval);
        T = vertcat(T,temp);
        clearvars -except i j k T path group groupID data
    end
end

filename = 'SessionMeans.xlsx';
filepath = fullfile(path,filename);
if ~exist(path,'dir')
    mkdir(path)
end
writetable(T,filepath)
