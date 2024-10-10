function data = LoadRawData(data,UI)
% load raw data for selected mouse from Curator and Matlab 3D folders

[curationIDs,CURdir] = GetMouseIDs(UI.CurPath);
[curationIDs,indx] = SelectMice(curationIDs);


% parse Experimentor, mouseID, and phase from curation ID
%  and create data structures for mice to process
datacount = length(data);
for i = 1:length(curationIDs)
    parts = strsplit(curationIDs{i},'_');
    data{datacount+i} = struct('MouseID',parts{2},'Experimentor', parts{1});
    if length(parts) > 2
        data{datacount+i}.Phase = parts{3};
    else
        data{datacount+i}.Phase = '';
    end
end

% index selected mice from curator directory struct
CURdir = CURdir(indx);

for i = 1:length(data) % iterate thru mice
    [sessionFiles,mouseDir] = FindSessions(CURdir(i));

    % find Matlab_3D files with names matching mouse curator files and load
    raw_data = struct;
    for j = 1:length(sessionFiles) % iterate thru sessions

        fileStr = [sessionFiles{j}(1:26), '_3D.mat'];
        MATdata = load(fullfile(UI.Mat3Dpath,fileStr),'table3D'); % uint16 array
        CURdata = readtable(fullfile(mouseDir(j).folder,mouseDir(j).name));

        fieldnames = MATdata.table3D.Properties.VariableNames;

        raw_data(j).Session = MATdata.table3D.Properties.RowNames;
        raw_data(j).ReachIndexPairs = CURdata(:,1:3);
        raw_data(j).StimLogical = logical(table2array(CURdata(:,4)));
        raw_data(j).Behaviors = table2array(CURdata(:,6));
        raw_data(j).EndCategory = table2array(CURdata(:,5));

        reach_indices = table2array(raw_data(j).ReachIndexPairs);
        for k = 1:height(reach_indices)
            % mark reaches to exclude from analysis
            if strcmp(raw_data(j).Behaviors(k),'none') %not curated
                raw_data(j).Excluded(k,1) = true;
                raw_data(j).Reason{k,1} = 'behavior=none';
            elseif anynan(reach_indices(k,:)) %at least one empty index
                raw_data(j).Excluded(k,1) = true;
                raw_data(j).Reason{k,1} = 'emptyIndex';
            elseif reach_indices(k,2)>reach_indices(k,3) %reach max marked later in time than reach end
                raw_data(j).Excluded(k,1) = true;
                raw_data(j).Reason{k,1} = 'maxInd>endInd';
            else
                raw_data(j).Excluded(k,1) = false;
                raw_data(j).Reason{k,1} = [];
            end
        end


        % convert uint16 data in table3D to double, store in rawData
        for k = 1:length(fieldnames) % dont need last 4 columns in table
            if strcmpi(fieldnames{k},'cropPts')
                continue % saving crop points later
            end
            raw_data(j).(fieldnames{k}) = double(MATdata.table3D{1,k}{:,:})';
        end
        raw_data(j).CropPoints = MATdata.table3D{1,11}{:,:};

        %make sure frame drops data is a column, sometimes it is a row
        raw_data(j).frmDropsFront = reshape(raw_data(j).frmDropsFront,[],1);
        raw_data(j).frmDropsSide = reshape(raw_data(j).frmDropsSide,[],1);
        raw_data(j).frmDropsTop = reshape(raw_data(j).frmDropsTop,[],1);

    end
    data{i}.RawData = raw_data;
    data{i}.Status = 'Raw';
    SaveKdaFile(data{i},UI.OutPath)
end
