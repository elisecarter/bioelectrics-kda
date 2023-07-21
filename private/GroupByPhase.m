function phaseLists = GroupByPhase(phaseID, kdaPath)

kdaDir = dir(kdaPath);
allFiles = {kdaDir.name};

phaseLists = cell(1,length(phaseID));
for i = 1:length(phaseID)
    index = contains(allFiles,char(phaseID{i}));
    phaseLists{i} = string({allFiles{index}}); 
end

