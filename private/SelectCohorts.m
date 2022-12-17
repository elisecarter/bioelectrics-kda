function [cohort,cohortID] = SelectCohorts(data,num_cohorts)
% user input for number of cohorts and assign mice

catStruct = [data{:}];
mouseIDs = {catStruct.MouseID};
for i = 1:num_cohorts
    prompt = sprintf('Enter the identifier for cohort %d',i);
    dlgtitle = 'Input Cohort Name';
    dims = [1 35];
    definput = {''};
    cohortID{i} = inputdlg(prompt,dlgtitle,dims,definput);

    prompt = sprintf('Select Mice in %s Cohort',cohortID{i}{1});
    [indx, ~] = listdlg('ListString',mouseIDs,'PromptString',prompt);
    cohort{i} = data(indx);
    mouseIDs(indx) = [];
    data(indx) = [];
end