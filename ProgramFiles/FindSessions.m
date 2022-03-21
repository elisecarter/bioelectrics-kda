function [mouseDir] = FindSessions(CURdir)

% go into the Curator folder for the mouse and pull out session names

mouseDir = dir(fullfile(CURdir.folder, CURdir.name));
mouseFiles = {mouseDir.name};
mouseDir = mouseDir(~ismember(mouseFiles ,{'.','..'}));
end