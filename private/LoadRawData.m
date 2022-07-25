function data = LoadRawData(data,MATpath,CURdir)
% load raw data for selected mouse from Curator and Matlab 3D folders

f = waitbar(0,'Please wait...'); % create wait bar

for i = 1:length(data) % i: mouse index
    waitstr = "Loading raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);

    [sessionFiles,mouseDir] = FindSessions(CURdir(i));
    
    raw_data = struct('Session',[],'ReachIndexPairs',[],...
            'StimLogical',[],'pelletX_100',[],...
            'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[],...
            'pelletConfZ_10k',[],'handX_100',[],'handY_100',[], ...
            'handZ_100',[],'handConfXY_10k',[],'handConfZ_10k',[]);

    % find Matlab_3D files with names matching mouse curator files and load
    for j = 1:length(sessionFiles) % j: session index

        fileStr = [sessionFiles{j}(1:27), '3D.mat'];
        MATdata = load(fullfile(MATpath,fileStr)); % uint16 array
        CURdata = readtable(fullfile(mouseDir(j).folder,mouseDir(j).name));

        % convert uint16 data in table3D to double, store in rawData
        raw_data(j).Session = MATdata.table3D.Properties.RowNames;
        raw_data(j).ReachIndexPairs = CURdata(:,1:3);
        raw_data(j).StimLogical = logical(table2array(CURdata(:,4)));
        raw_data(j).pelletX_100 = double(MATdata.table3D{1,1}{:,:});
        raw_data(j).pelletY_100 = double(MATdata.table3D{1,2}{:,:});
        raw_data(j).pelletZ_100 = double(MATdata.table3D{1,3}{:,:});
        raw_data(j).pelletConfXY_10k = double(MATdata.table3D{1,4}{:,:});
        raw_data(j).pelletConfZ_10k = double(MATdata.table3D{1,5}{:,:});
        raw_data(j).handX_100 = double(MATdata.table3D{1,6}{:,:});
        raw_data(j).handY_100 = double(MATdata.table3D{1,7}{:,:});
        raw_data(j).handZ_100 = double(MATdata.table3D{1,8}{:,:});
        raw_data(j).handConfXY_10k = double(MATdata.table3D{1,9}{:,:});
        raw_data(j).handConfZ_10k = double(MATdata.table3D{1,10}{:,:});
    end
    data{i}.RawData = raw_data;
end
close(f)
    