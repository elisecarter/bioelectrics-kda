function [mouseIDs,indx] = SelectMice(mouseIDs)
% UI select mice

prompt = 'Select Mice';
[indx, ~] = listdlg('ListString',mouseIDs,'PromptString',prompt);

mouseIDs = mouseIDs(indx);













