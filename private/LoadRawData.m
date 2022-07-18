function data = LoadRawData(MATpath, CURdir)
% load raw data for selected mouse from Curator and Matlab 3D folders

[CURdir, data] = SelectMice(CURdir);
f = waitbar(0,'Please wait...'); % create wait bar

for i = 1:length(data) % i: mouse index
    waitstr = "Loading and preprocessing data... (" + data(i).MouseID + ")";
    waitbar(i/length(data),f,waitstr);

    [sessionFiles,mouseDir] = FindSessions(CURdir(i));
    
    raw_data = struct('Session',[],'ReachIndexPairs',[],...
            'StimLogical',[],'pelletX',[],...
            'pelletY',[],'pelletZ',[],'pelletConfXY',[],...
            'pelletConfZ',[],'handX',[],'handY',[], ...
            'handZ',[],'handConfXY',[],'handConfZ',[]);

    % find Matlab_3D files with names matching mouse curator files and load
    for j = 1:length(sessionFiles) % j: session index
        fileStr = [sessionFiles{j}(1:27), '3D.mat'];
        MATdata = load(fullfile(MATpath,fileStr)); % uint16 array
        CURdata = readtable(fullfile(mouseDir(j).folder,mouseDir(j).name));

        % convert uint16 data in table3D to double, store in rawData
        raw_data(j).Session = MATdata.table3D.Properties.RowNames;
        raw_data(j).ReachIndexPairs = CURdata(:,1:3);
        raw_data(j).StimLogical = logical(table2array(CURdata(:,4)));
        raw_data(j).pelletX = double(MATdata.table3D{1,1}{:,:})/100;
        raw_data(j).pelletY = double(MATdata.table3D{1,2}{:,:})/100;
        raw_data(j).pelletZ = double(MATdata.table3D{1,3}{:,:})/100;
        raw_data(j).pelletConfXY = double(MATdata.table3D{1,4}{:,:})/10000;
        raw_data(j).pelletConfZ = double(MATdata.table3D{1,5}{:,:})/10000;
        raw_data(j).handX = double(MATdata.table3D{1,6}{:,:})/100;
        raw_data(j).handY = double(MATdata.table3D{1,7}{:,:})/100;
        raw_data(j).handZ = double(MATdata.table3D{1,8}{:,:})/100;
        raw_data(j).handConfXY = double(MATdata.table3D{1,9}{:,:})/10000;
        raw_data(j).handConfZ = double(MATdata.table3D{1,10}{:,:})/10000;
    end
    % preprocess, store session reach data in data struct
    data(i).Sessions = ProcessReachEvents(raw_data);
end

waitstr = "Plotting final session trajectories...";
waitbar(1,f,waitstr);
ReviewFinalTrajectories(data)
waitstr = "Done!";
waitbar(1,f,waitstr);
close(f) % close waitbar

save('temp.mat','data','-v7.3')
