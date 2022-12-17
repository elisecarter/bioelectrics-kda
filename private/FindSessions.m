function [sessions,mouseDir] = FindSessions(CURdir)
% goes into the Curator folder for each mouse and pulls out session names

mouseDir = dir(fullfile(CURdir.folder, CURdir.name));
mouseFiles = {mouseDir.name};

% only excel files
mouseDir = mouseDir(contains(mouseFiles,'.xlsx'));
sessions = {mouseDir.name};

openfiles = strfind(sessions,'~'); % "~" indicates file is open elsewhere
if any(~cellfun(@isempty,openfiles)) % a curator file is open
    % delete the extra instances of open files detected by dir()
    ind = ~cellfun(@isempty,openfiles);
    sessions(ind) = [];
    mouseDir(ind) = [];

    %     fileind = ~cellfun(@isempty,openfiles);
    %     msg = "Curator file (" + sessions{fileind} + ") is open. " + ...
    %         "Please close file before loading raw data.";
    %     err = msgbox(msg);
    %     uiwait(err)
    %     return
end