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
        temp{1,2} = 'ExpertToExpert';
        temp{1,3} = data.ExpertToExpert;
        temp{1,4} = ' ';
        C = vertcat(C,temp);
        clear temp
        for k = 1:length(data.Phase1ToPhase2Expert)
            temp{k,1} = ID;
            temp{k,2} = 'Phase1ToPhase2Expert';
            temp{k,3} = data.Phase1ToPhase2Expert(k).CorrCoef;
            temp{k,4} = num2str(k);
        end
        C = vertcat(C,temp);
        clear temp
        for k = 1:length(data.Phase2ToPhase1Expert)
            temp{k,1} = ID;
            temp{k,2} = 'Phase2ToPhase1Expert';
            temp{k,3} = data.Phase2ToPhase1Expert(k).CorrCoef;
            temp{k,4} = num2str(k);
        end
        C = vertcat(C,temp);
        clear temp
    end
    T = cell2table(C,"VariableNames",["MouseID","Comparison","CorrelationCoefficient","SessionNumber"]);
    writetable(T,filepath)
    clear C
    clear T
end
