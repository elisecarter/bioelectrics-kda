function data = LoadRawData(mouseIDs)
% load selected mice

    % EDIT INPUT/OUTPUT BC I CANT SEE IT :,)

     % create structrure x by 1 struct where x = n mice
    for i = 1:length(mouseIDs)
        data(i).MouseID = mouseIDs(i);
    end
    
    data = FindSessions(data)
end