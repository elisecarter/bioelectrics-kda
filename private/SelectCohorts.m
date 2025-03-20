function data = SelectCohorts(data,num_cohorts,secondaryData)
% user input for number of cohorts and assign mice

catStruct = [data{:}];
mouseIDs = {catStruct.MouseID};
for i = 1:num_cohorts
    prompt = sprintf('Enter the identifier for cohort %d',i);
    dlgtitle = 'Input Cohort Name';
    dims = [1 35];
    definput = {''};
    cohortID = inputdlg(prompt,dlgtitle,dims,definput);

    prompt = sprintf('Select Mice in %s Cohort',cohortID{1});
    [indx, ~] = listdlg('ListString',mouseIDs,'PromptString',prompt);
    cohort{i} = data(indx);

    for j = 1:length(cohort{i})
        cohort{i}{j}.GroupID = cohortID{1};
    end
    mouseIDs(indx) = [];
    data(indx) = [];

    if exist('secondaryData','var')
        cohort2{i} = secondaryData(indx);
        for j = 1:length(cohort2{i})
            cohort2{i}{j}.GroupID = cohortID{1};
        end
        secondaryData(indx) = [];
    end
end

clear data
if exist('secondaryData','var')
    clear secondaryData
    data{1} = [cohort{:}];
    data{2} = [cohort2{:}];
else
    data = [cohort{:}];
end