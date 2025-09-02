function OutputReachTable(data,UI)
T = table;

for i = 1:length(data) % iterate thru mice
    thisMouse = data{i};
    for j = 1:length(thisMouse.Sessions) % iterate thru sessions
        if isempty(thisMouse.Sessions(j).InitialToMax)
            continue
        end
        for k = 1: length(thisMouse.Sessions(j).InitialToMax)
            thisReach = thisMouse.Sessions(j).InitialToMax(k);
            ID{k,1} = thisMouse.MouseID;
            Group{k,1} = thisMouse.GroupID;
            Phase{k,1} = thisMouse.Phase;
            Experimentor{k,1} = thisMouse.Experimentor;
            SessionID{k,1} = thisMouse.Sessions(j).SessionID;
            Day{k,1} = j;

            ReachNo{k,1} = k;
            StartIndex{k,1} = thisReach.StartIndex;
            Behavior{k,1} = thisReach.Behavior;
            ReachDuration{k,1} = thisReach.ReachDuration;

            MaxAbsVelocity{k,1} = thisReach.MaxAbsVelocity;
            MeanAbsVelocity{k,1} = mean(thisReach.AbsoluteVelocity);
            MaxVelocityLocation{k,1} = thisReach.MaxVelocityLocation;
            
            meanVel = mean(abs(thisReach.InterpolatedVelocity),1);
            MeanVelocity_X{k,1} = meanVel(1,1);
            MeanVelocity_Y{k,1} = meanVel(1,2);
            MeanVelocity_Z{k,1} = meanVel(1,3);
            
            maxVel = max(abs(thisReach.InterpolatedVelocity),[],1);
            MaxVelocity_X{k,1} = maxVel(1,1);
            MaxVelocity_Y{k,1} = maxVel(1,2);
            MaxVelocity_Z{k,1} = maxVel(1,3);

            TargetDistance{k,1} = norm(thisReach.HandPositionNormalized(end,:));
            PathLength3D{k,1} = thisReach.PathLength3D;
            PathLengthXY{k,1} = thisReach.PathLengthXY;

        end
    end

    if exist("SessionID","var")
        temp = table(SessionID,ID,Group,Phase,Day, ReachNo,StartIndex, ...
            Behavior,ReachDuration,TargetDistance,PathLength3D,PathlengthXY, ...
            MeanAbsVelocity,MaxAbsVelocity,MaxVelocityLocation, ...
            MeanVelocity_X,MeanVelocity_Y,MeanVelocity_Z, ...
            MaxVelocity_X,MaxVelocity_Y,MaxVelocity_Z);
        T = vertcat(T,temp);
    end
    clearvars -except i j k T data UI
end

filename = 'ReachTable_reachMax.xlsx';
filepath = fullfile(UI.OutPath,filename);
if ~exist(UI.OutPath,'dir')
    mkdir(UI.OutPath)
end
writetable(T,filepath)
end