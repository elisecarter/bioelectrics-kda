function OutputPhaseCorrelations(cohort,cohortID,path)
% creates an excel file for each cohort with correlation coefficients

folder = 'LearningPhaseComparisons';
folder_path = fullfile(path,folder);
if ~exist(folder_path,'dir')
    mkdir(folder_path)
end

for i = 1:length(cohort) %iterate thru cohorts
    filename = sprintf('%s.xlsx',cohortID{i}{1});
    filepath = fullfile(folder_path,filename);

    C = {};
    for j = 1:length(cohort{i}) % iterate thru mice in cohort
        data = cohort{i}{j};
        ID = data.MouseID;
        temp{1,1} = ID;
        temp{1,2} = ' ';
        temp{1,3} = ' ';
        temp{1,4} = nan;
        temp{1,5} = nan;
        temp{1,6} = nan;
        temp{1,7} = nan;
        temp{1,8} = data.ExpertToExpert;

        C = vertcat(C,temp);
        clear temp

        for k = 1:length(data.Phase1ToPhase2Expert)
            temp{k,1} = ID;
            temp{k,2} = num2str(k);
            temp{k,3} = 'Phase1ToPhase2Expert';
            temp{k,4} = data.Phase1ToPhase2Expert(k).PercentExpert;
            temp{k,5} = data.Phase1ToPhase2Expert(k).AllReaches;
            temp{k,6} = data.Phase1ToPhase2Expert(k).Success;
            temp{k,7} = data.Phase1ToPhase2Expert(k).Failure;
            temp{k,8} = nan;  
        end
        C = vertcat(C,temp);
        clear temp

        for k = 1:length(data.Phase2ToPhase1Expert)
            temp{k,1} = ID;
            temp{k,2} = num2str(k);
            temp{k,3} = 'Phase2ToPhase1Expert';
            temp{k,4} = data.Phase2ToPhase1Expert(k).PercentExpert;
            temp{k,5} = data.Phase2ToPhase1Expert(k).AllReaches;
            temp{k,6} = data.Phase2ToPhase1Expert(k).Success;
            temp{k,7} = data.Phase2ToPhase1Expert(k).Failure;
            temp{k,8} = nan;     
        end
        C = vertcat(C,temp);
        clear temp

    end
    T = cell2table(C,"VariableNames",["MouseID","SessionNumber", ...
        "Comparison","PercentExpert","AllReaches","Success","Failure", ...
        "ExpertToExpert"]);
    writetable(T,filepath)
    clear C
    clear T
end
