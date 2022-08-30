function data = LoadRawData(data,MATpath,CURdir)
% load raw data for selected mouse from Curator and Matlab 3D folders

f = waitbar(0,'Please wait...'); % create wait bar

for i = 1:length(data) % iterate thru mice
    waitstr = "Loading raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);

    [sessionFiles,mouseDir] = FindSessions(CURdir(i));
    
    % find Matlab_3D files with names matching mouse curator files and load
    raw_data = struct;
    for j = 1:length(sessionFiles) % iterate thru sessions

        fileStr = [sessionFiles{j}(1:27), '3D.mat'];
        MATdata = load(fullfile(MATpath,fileStr),'table3D'); % uint16 array
        CURdata = readtable(fullfile(mouseDir(j).folder,mouseDir(j).name));

        fieldnames = MATdata.table3D.Properties.VariableNames;

        raw_data(j).Session = MATdata.table3D.Properties.RowNames;
        raw_data(j).ReachIndexPairs = CURdata(:,1:3);
        raw_data(j).StimLogical = logical(table2array(CURdata(:,4)));
        
        % convert uint16 data in table3D to double, store in rawData
        for k = 1:length(fieldnames)-1 % everything expect crop pts
            raw_data(j).(fieldnames{k}) = double(MATdata.table3D{1,k}{:,:});
        end

    end
    data{i}.RawData = raw_data;
    data{i}.Status = 'Raw';
end
close(f)
    