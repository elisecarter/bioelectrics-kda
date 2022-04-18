function [sessions,mouseDir] = FindSessions(CURdir)
% goes into the Curator folder for each mouse and pulls out session names

mouseDir = dir(fullfile(CURdir.folder, CURdir.name));
mouseFiles = {mouseDir.name};

% only excel files
mouseDir = mouseDir(contains(mouseFiles,'.xlsx'));
sessions = {mouseDir.name};

openfiles = strfind(sessions,'~'); % "~" indicates file is open elsewhere
if ~cellfun(@isempty,openfiles)
    fileind = ~cellfun(@isempty,openfiles);
    msg = "Curator file (" + sessions{fileind} + ") is open. Please close before reloading raw data.";
    error(msg)
    return
end

end