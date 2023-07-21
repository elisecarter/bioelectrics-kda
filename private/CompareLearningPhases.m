function data = CompareLearningPhases(phaseLists, kdaPath)

% check phase lists are same length
if ~length(phaseLists{1}) == length(phaseLists{2})
    return
end

k = 0;
for i = 1:length(phaseLists{1})
    % load phase 1 data
    p1data = load(fullfile(kdaPath,phaseLists{1}(i)),'-mat');

    % pull out mouse ID and find match in phase 2 list
    p1ID = p1data.MouseID;
    ID = regexpi(p1ID,'^\w*\-*\w*(?=\_)','match'); % ID without the phase identifier
    matchInd = find(contains(phaseLists{2},ID));

    % check that there was a match in phase 2 list
    if isempty(matchInd)
        k = k + 1;
        msg = sprintf('Skipping %s. No matching ID in phase 2 list.',ID{1});
        warning(msg)
        continue
    end
    
    % load phase 2 data 
    p2data = load(fullfile(kdaPath,phaseLists{2}(matchInd)),'-mat');

    data{i-k} = ComputePhaseCorrelations(p1data, p2data);
    data{i-k}.MouseID = ID{1};
    
end