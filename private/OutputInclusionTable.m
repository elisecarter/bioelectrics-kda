function OutputInclusionTable(data,path)

for i = 1:length(data.Sessions) % iterate thru sessions
    reachInit = data.Sessions(i).ReachIndexPairs(:,1);
    reachMax = data.Sessions(i).ReachIndexPairs(:,2);
    reachEnd = data.Sessions(i).ReachIndexPairs(:,3);
    stim = double(data.Sessions(i).StimLogical);
    end_category = data.Sessions(i).EndCategory;
    behaviors = data.Sessions(i).Behavior;
    included = double(~data.Sessions(i).Excluded);
    exclusion_reason = data.Sessions(i).Reason;

    T = table(reachInit,reachMax,reachEnd,stim,end_category,behaviors, ...
        included,exclusion_reason);

    filename = [char(data.Sessions(i).SessionID),'_',data.Experimentor,'_',data.MouseID];
    if ~strcmp(data.Phase,'') %is a phase for file
        filename = [filename,'_',data.Phase,'.xlsx'];
    else
        filename = [filename,'.xlsx'];
    end
    filepath = fullfile(path,filename);
    writetable(T,filepath)

    clearvars -except i data path
end



