function mouseIDs = SelectMice(CURdir)
% UI select mice to load data for

% remove anything that is not a subdirectory in curator folder
CURdir(~[CURdir.isdir]) = [];

% get names of folders
CURnames = {CURdir.name};

% remove parent dirs
CURdir = CURdir(~ismember(CURnames ,{'.','..'}));
mouseIDs = {CURdir.name};

% UI select mice
prompt = 'Select Mice';
[indx, ~] = listdlg('ListString',mouseIDs,'PromptString', prompt);

CURdir = CURdir(indx); 

end
















