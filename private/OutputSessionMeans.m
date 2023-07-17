function OutputSessionMeans(data,UI)
% creates an excel file for each cohort with session level data

T = table;

for i = 1:length(data) % iterate thru mice
    thisMouse = data{i};
    for j = 1:length(thisMouse.Sessions) % iterate thru sessions
        correlations = thisMouse.Sessions(j).Correlations;

        MouseID{j,1} = thisMouse.MouseID;
        Group{j,1} = thisMouse.GroupID;
        SessionID{j,1} = thisMouse.Sessions(j).SessionID;
        NumReaches{j,1} = thisMouse.Sessions(j).ReachAttempts;

        SuccessPercent{j,1} = thisMouse.Sessions(j).PercentSuccess;
        ExpertPercent{j,1} = thisMouse.Sessions(j).PercentExpert;
        CorrAllReachesToExpert{j,1} = correlations.AllReachesToExpert3D;
        CorrSuccessToExpert{j,1} = correlations.SuccessToExpert3D;
        CorrFailToExpert{j,1} = correlations.FailToExpert3D;
        PercentImprovement{j,1} = correlations.PercentIncreaseofFailures;
        SessionConsistency{j,1} = correlations.Consistency;

        MeanVelocityX{j,1} = thisMouse.Sessions(j).MeanEucVelocity(1,1);
        MeanVelocityY{j,1} = thisMouse.Sessions(j).MeanEucVelocity(1,2);
        MeanVelocityZ{j,1} = thisMouse.Sessions(j).MeanEucVelocity(1,3);
        MeanAbsVelocity{j,1} = thisMouse.Sessions(j).MeanAbsVelocity;
        MeanMaxVelocity{j,1} = thisMouse.Sessions(j).MeanMaxVelocity;
        MeanMaxVelocityLocation{j,1} = thisMouse.Sessions(j).MeanMaxVelLocation;
        MeanDuration{j,1} = thisMouse.Sessions(j).MeanDuration;
        MeanPathLength3D{j,1} = thisMouse.Sessions(j).MeanPathLength3D;
        MeanPathLengthXY{j,1} = thisMouse.Sessions(j).MeanPathLengthXY;
        MeanPathLengthXZ{j,1} = thisMouse.Sessions(j).MeanPathLengthXZ;

        StimAccuracy{j,1} = thisMouse.Sessions(j).StimAccuracy;
        %StimSpecificity{k,1} = data.Sessions(k).StimSpecificity;
        %StimSensitivity{k,1} = data.Sessions(k).StimSensitivty;

        PercentFailureType_Grasp{j,1} = thisMouse.Sessions(j).PercentFailuresGrasp;
        PercentFailureType_Reach{j,1} = thisMouse.Sessions(j).PercentFailuresReach;
        PercentFailureType_Retrieval{j,1} = thisMouse.Sessions(j).PercentFailuresRetrieval;
    end

    temp = table(MouseID,SessionID,Group,NumReaches,SuccessPercent,ExpertPercent, ...
        CorrAllReachesToExpert,CorrSuccessToExpert,CorrFailToExpert, ...
        PercentImprovement,SessionConsistency,MeanVelocityX, ...
        MeanVelocityY,MeanVelocityZ,MeanAbsVelocity,MeanMaxVelocity, ...
        MeanMaxVelocityLocation,MeanDuration, ...
        MeanPathLength3D,MeanPathLengthXY,MeanPathLengthXZ, ...
        StimAccuracy,PercentFailureType_Grasp, ...
        PercentFailureType_Reach,PercentFailureType_Retrieval);
    T = vertcat(T,temp);
    clearvars -except i j k T group groupID data UI
end

filename = ['SessionMeans' '_' UI.ReachType '.xlsx'];
filepath = fullfile(UI.OutPath,filename);
if ~exist(UI.OutPath,'dir')
    mkdir(UI.OutPath)
end
writetable(T,filepath)
