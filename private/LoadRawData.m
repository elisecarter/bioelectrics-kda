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
        raw_data(j).Behaviors = table2array(CURdata(:,6));
        raw_data(j).EndCategory = table2array(CURdata(:,5));
        
        % convert uint16 data in table3D to double, store in rawData
        for k = 1:length(fieldnames) % dont need last 4 columns in table
            if strcmpi(fieldnames{k},'cropPts')
                break % dont need anything after crop points
            end
            raw_data(j).(fieldnames{k}) = double(MATdata.table3D{1,k}{:,:})';
        end
        
        % fix this later: use droped frames column rather than hard
        % coding
        if strcmp(raw_data(j).Session{1},'20220425_unit01_session001')
            % shift bc of unsynced camera (front cam 133 frames delayed)
            raw_data(j).handZ_100(1:133) = [];
            raw_data(j).handConfZ_10k(1:133) = [];
            raw_data(j).pelletZ_100(1:133) = [];
            raw_data(j).pelletConfZ_10k(1:133) = [];

            raw_data(j).handX_100(end-132:end) = [];
            raw_data(j).handY_100(end-132:end) = [];
            raw_data(j).handConfXY_10k(end-132:end) = [];

            raw_data(j).pelletX_100(end-132:end) = [];
            raw_data(j).pelletY_100(end-132:end) = [];
            raw_data(j).pelletConfXY_10k(end-132:end) = [];

        elseif strcmp(raw_data(j).Session{1},'20220425_unit01_session002')
            % shift bc of unsynced camera (front cam 12 frames delayed)
            raw_data(j).handZ_100(1:12) = [];
            raw_data(j).handConfZ_10k(1:12) = [];
            raw_data(j).pelletZ_100(1:12) = [];
            raw_data(j).pelletConfZ_10k(1:12) = [];

            raw_data(j).handX_100(end-11:end) = [];
            raw_data(j).handY_100(end-11:end) = [];
            raw_data(j).handConfXY_10k(end-11:end) = [];

            raw_data(j).pelletX_100(end-11:end) = [];
            raw_data(j).pelletY_100(end-11:end) = [];
            raw_data(j).pelletConfXY_10k(end-11:end) = [];
        end


    end
    data{i}.RawData = raw_data;
    data{i}.Status = 'Raw';
end
close(f)
    