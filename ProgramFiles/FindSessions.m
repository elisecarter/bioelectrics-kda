function [sessions,mouseDir] = FindSessions(CURdir)
% goes into the Curator folder for each mouse and pull out session names

mouseDir = dir(fullfile(CURdir.folder, CURdir.name));
mouseFiles = {mouseDir.name};

% only excel files
mouseDir = mouseDir(contains(mouseFiles,'.xlsx'));
sessions = {mouseDir.name};

end