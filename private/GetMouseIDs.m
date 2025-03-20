function [curationIDs,CURdir] = GetCurationIDs(CURpath)
% creates list of curation IDs from names of files in the Curator folder
CURdir = dir(CURpath);

% remove anything that is not a subdirectory in curator folder
CURdir(~[CURdir.isdir]) = [];

% get names of folders
CURnames = {CURdir.name};

% remove parent dirs
CURdir = CURdir(~ismember(CURnames ,{'.','..'}));
curationIDs = {CURdir.name};

end