function OutputPhaseCorrelations(corrData,path)
% creates an excel file for each cohort with correlation coefficients

T = table;
for i = 1:length(corrData) %iterate thru animals
    data = corrData{i};
    MouseID = string(data.MouseID);
    Experimentor = string(data.Experimentor);
    Group = string(data.GroupID);
    SessionID = " ";
    P1 = string(data.Phase1);
    P2 = string(data.Phase2);
    Comparison = "P1ExpertToP2Expert";
    PercentExpert = nan;
    AllReaches = nan;
    Success = nan;
    Failure = nan;
    ExpertToExpert = data.ExpertToExpert;

    temp = table(MouseID,Experimentor,Group,SessionID,P1,P2,Comparison, ...
        PercentExpert,AllReaches,Success,Failure,ExpertToExpert);
    T = vertcat(T,temp);
    clear temp

    for j = 1:length(data.Phase1ToPhase2Expert)
        SessionID = string(data.Phase1ToPhase2Expert(j).SessionID);
        Comparison = "P1ToP2Expert";
        PercentExpert = data.Phase1ToPhase2Expert(j).PercentExpert;
        AllReaches = data.Phase1ToPhase2Expert(j).AllReaches;
        Success = data.Phase1ToPhase2Expert(j).Success;
        Failure = data.Phase1ToPhase2Expert(j).Failure;
        ExpertToExpert = nan;

        temp = table(MouseID,Experimentor,Group,SessionID,P1,P2,Comparison, ...
            PercentExpert,AllReaches,Success,Failure,ExpertToExpert);
        T = vertcat(T,temp);
        clear temp
    end

    for j = 1:length(data.Phase2ToPhase1Expert)

        SessionID = string(data.Phase2ToPhase1Expert(j).SessionID);
        Comparison = "P2ToP1Expert";
        PercentExpert = data.Phase2ToPhase1Expert(j).PercentExpert;
        AllReaches = data.Phase2ToPhase1Expert(j).AllReaches;
        Success = data.Phase2ToPhase1Expert(j).Success;
        Failure = data.Phase2ToPhase1Expert(j).Failure;
        ExpertToExpert = nan;

        temp = table(MouseID,Experimentor,Group,SessionID,P1,P2,Comparison, ...
            PercentExpert,AllReaches,Success,Failure,ExpertToExpert);
        T = vertcat(T,temp);
        clear temp

    end
eend

file = 'LearningPhaseComparisons.xlsx';
filePath = fullfile(path,file);
writetable(T,filePath)
clear T


