function OutputSessionMeans(data,UI)
% creates an excel file for each cohort with session level data

T = table;

for i = 1:length(data) % iterate thru mice
    thisMouse = data{i};
    for j = 1:length(thisMouse.Sessions) % iterate thru sessions
        if isempty(thisMouse.Sessions(j).InitialToMax)
            continue
        end
        correlations = thisMouse.Sessions(j).Correlations;

        MouseID{j,1} = thisMouse.MouseID;
        Group{j,1} = thisMouse.GroupID;
        Phase{j,1} = thisMouse.Phase;
        Experimentor{j,1} = thisMouse.Experimentor;
        SessionID{j,1} = thisMouse.Sessions(j).SessionID;

        AnalyzedReaches{j,1} = thisMouse.Sessions(j).AnalyzedReaches;
        SuccessPercent{j,1} = thisMouse.Sessions(j).PercentSuccess;
        ExpertPercent{j,1} = thisMouse.Sessions(j).PercentExpert;

        CorrAllReachesToExpert{j,1} = correlations.AllReachesToExpert3D;
        CorrSuccessToExpert{j,1} = correlations.SuccessToExpert3D;
        CorrFailToExpert{j,1} = correlations.FailToExpert3D;

        PercentImprovement{j,1} = correlations.PercentIncreaseofFailures;
        ShapeConsistency{j,1} = correlations.shapeConsistency;
        SpatialConsistency{j,1} = correlations.spatialConsistency;
        MeanTargetDistanceFromPellet{j,1} = thisMouse.Sessions(j).MeanTargetDistance;

        MeanVelocityX{j,1} = thisMouse.Sessions(j).MeanEucVelocity(1,1);
        MeanVelocityY{j,1} = thisMouse.Sessions(j).MeanEucVelocity(1,2);
        MeanVelocityZ{j,1} = thisMouse.Sessions(j).MeanEucVelocity(1,3);
        MeanAbsVelocity{j,1} = thisMouse.Sessions(j).MeanAbsVelocity;
        MeanMaxVelocity{j,1} = thisMouse.Sessions(j).MeanMaxVelocity;
        MeanMaxVelocityLocation{j,1} = thisMouse.Sessions(j).MeanMaxVelLocation;
        MeanDuration{j,1} = thisMouse.Sessions(j).MeanDuration;
        MeanPathLength3D{j,1} = thisMouse.Sessions(j).MeanPathLength3D;
        % MeanPathLengthXY{j,1} = thisMouse.Sessions(j).MeanPathLengthXY;
        % MeanPathLengthXZ{j,1} = thisMouse.Sessions(j).MeanPathLengthXZ;

        StimAccuracy{j,1} = thisMouse.Sessions(j).StimAccuracy;
        StimSpecificity{j,1} = thisMouse.Sessions(j).StimSpecificity;
        StimSensitivity{j,1} = thisMouse.Sessions(j).StimSensitivty;

        PercentFailureType_Grasp{j,1} = thisMouse.Sessions(j).PercentFailuresGrasp;
        PercentFailureType_Reach{j,1} = thisMouse.Sessions(j).PercentFailuresReach;
        PercentFailureType_Retrieval{j,1} = thisMouse.Sessions(j).PercentFailuresRetrieval;
        
        NumExcluded{j,1} = sum(thisMouse.Sessions(j).Excluded);
    end

    if exist("SessionID","var")
        temp = table(SessionID,MouseID,Group,Phase,Experimentor,AnalyzedReaches, ...
            NumExcluded,SuccessPercent,ExpertPercent, ...
            CorrAllReachesToExpert,CorrSuccessToExpert,CorrFailToExpert, ...
            PercentImprovement,ShapeConsistency,SpatialConsistency,MeanTargetDistanceFromPellet, ...
            MeanVelocityX,MeanVelocityY,MeanVelocityZ,MeanAbsVelocity,MeanMaxVelocity, ...
            MeanMaxVelocityLocation,MeanDuration, ...
            MeanPathLength3D, ...
            StimAccuracy,StimSensitivity,StimSpecificity, ...
            PercentFailureType_Grasp,PercentFailureType_Reach,PercentFailureType_Retrieval);
        T = vertcat(T,temp);
    end
    clearvars -except i j k T group groupID data UI
end

filename = ['SessionMeans' '_' UI.ReachType '.xlsx'];
filepath = fullfile(UI.OutPath,filename);
if ~exist(UI.OutPath,'dir')
    mkdir(UI.OutPath)
end
writetable(T,filepath)
