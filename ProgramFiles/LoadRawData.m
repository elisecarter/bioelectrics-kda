function LoadRawData(MATpath, CURdir)
% load raw data for selected mouse from Curator and Matlab 3D folders

rawData = struct('Session',[],'ReachIndexPairs',[],'StimLogical',[],'pelletX_100',[],...
    'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[],...
    'pelletConfZ_10k',[],'handX_100',[],'handY_100',[],'handZ_100',[],...
    'handConfXY_10k',[],'handConfZ_10k',[],'cropPts',[]); 

for i = 1 : length(data) % i: mouse index
    [sessionFiles,mouseDir] = FindSessions(CURdir(i));

    % find Matlab_3D files with names matching mouse curator files and load
    for j = 1 : length(sessionFiles) % j: session index
        fileStr = [sessionFiles{j}(1:27), '3D.mat'];
        MATdata = load(fullfile(MATpath,fileStr)); % uint16 array
        CURdata = readtable(fullfile(mouseDir(j).folder,mouseDir(j).name));
        % convert uint16 data in table3D to double, store in rawData
        rawData(j).Session = MATdata.table3D.Properties.RowNames;
        rawData(j).ReachIndexPairs = CURdata(:,1:3);
        rawData(j).StimLogical = CURdata(:,4);
        rawData(j).pelletX_100 = double(MATdata.table3D{1,1}{:,:});
        rawData(j).pelletY_100 = double(MATdata.table3D{1,2}{:,:});
        rawData(j).pelletZ_100 = double(MATdata.table3D{1,3}{:,:});
        rawData(j).pelletConfXY_10k = double(MATdata.table3D{1,4}{:,:});
        rawData(j).pelletConfZ_10k = double(MATdata.table3D{1,5}{:,:});
        rawData(j).handX_100 = double(MATdata.table3D{1,6}{:,:});
        rawData(j).handY_100 = double(MATdata.table3D{1,7}{:,:});
        rawData(j).handZ_100 = double(MATdata.table3D{1,8}{:,:});
        rawData(j).handConfXY_10k = double(MATdata.table3D{1,9}{:,:});
        rawData(j).handConfZ_10k = double(MATdata.table3D{1,10}{:,:});
        rawData(j).cropPts = MATdata.table3D{1,11}{:,:};
    end
    % store raw data in data structure
    data(i).RawData = rawData;
end

% data saved to files to be shared between callback functions
save('datafiles.mat','data','-v7.3')