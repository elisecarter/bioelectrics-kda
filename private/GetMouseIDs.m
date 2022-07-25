function [mouseIDs,CURdir] = GetMouseIDs(CURpath)
CURdir = dir(CURpath);

% remove anything that is not a subdirectory in curator folder
CURdir(~[CURdir.isdir]) = [];

% get names of folders
CURnames = {CURdir.name};

% remove parent dirs
CURdir = CURdir(~ismember(CURnames ,{'.','..'}));
mouseIDs = {CURdir.name};

end