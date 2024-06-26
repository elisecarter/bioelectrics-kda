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
        deleted_log = zeros(1, height(reach_indices)); % initialize for use for filtering
        for k = 1:height(reach_indices)
            l = k - sum(deleted_log); % subtract total # of reaches deleted to adjust index for storage

            % delete reaches with empty cell in curation spreadsheet
            if anynan(reach_indices(k,:))
                raw_data(j).ReachIndexPairs(l,:) = [];
                raw_data(j).StimLogical(l) = [];
                raw_data(j).Behaviors(l) = [];
                raw_data(j).EndCategory(l) = [];
                deleted_log(k) = 1;

                str = [raw_data(j).Session{1} ': Reach no. ' num2str(k) ' (starting index: ' num2str(reach_indices(k,1)) ') deleted due to empty cell in curation spreadsheet.'];
                warning(str)
                continue
            end

            % delete reaches where reach max index > reach end index
            max_ind = reach_indices(k,2);
            end_ind = reach_indices(k,3);
            if max_ind > end_ind
                raw_data(j).ReachIndexPairs(l,:) = [];
                raw_data(j).StimLogical(l) = [];
                raw_data(j).Behaviors(l) = [];
                raw_data(j).EndCategory(l) = [];
                deleted_log(k) = 1;

                str = [raw_data(j).Session{1} ': Reach no. ' num2str(k) ' (starting index: ' num2str(reach_indices(k,1)) ') deleted due to the index for reach max being greater than reach end.'];
                warning(str)
                continue
            end

            % delete reaches with "none" classification
            if strcmpi(raw_data(j).Behaviors(l),'none')
                raw_data(j).ReachIndexPairs(l,:) = [];
                raw_data(j).StimLogical(l) = [];
                raw_data(j).Behaviors(l) = [];
                raw_data(j).EndCategory(l) = [];
                deleted_log(k) = 1;
                continue
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


        %         % check if cameras are out of sync
        %         if length(raw_data(j).frmDropsSide) < length(raw_data(j).frmDropsFront) % front cam delayed
        %             numframes = length(raw_data(j).frmDropsFront) - length(raw_data(j).frmDropsSide);
        %
        %             % delete initial front cam frames to align vectors in time
        %             raw_data(j).handZ_100(1:numframes) = [];
        %             raw_data(j).handConfZ_10k(1:numframes) = [];
        %             raw_data(j).pelletZ_100(1:numframes) = [];
        %             raw_data(j).pelletConfZ_10k(1:numframes) = [];
        %
        %             % delete side cam end frames to make vectors the same length
        %             raw_data(j).handX_100(end-numframes+1:end) = [];
        %             raw_data(j).handY_100(end-numframes+1:end) = [];
        %             raw_data(j).handConfXY_10k(end-132:end) = [];
        %             raw_data(j).pelletX_100(end-numframes+1:end) = [];
        %             raw_data(j).pelletY_100(end-132:end) = [];
        %             raw_data(j).pelletConfXY_10k(end-numframes+1:end) = [];
        %
        %             str = [raw_data(j).Session{1} ': Front camera delayed by ' num2str(numframes) ' frames. Vectors were adjusted to be aligned in time.'];
        %             disp(str)
        %
        %         elseif length(raw_data(j).frmDropsSide) > length(raw_data(j).frmDropsFront) % side cam delayed
        %             numframes = length(raw_data(j).frmDropsSide) - length(raw_data(j).frmDropsFront);
        %
        %             % not adjusting side cam because reach event frames are based on side
        %             % camera - instead padding front cam with zeros to align in time
        %             raw_data(j).handZ_100 = [zeros(numframes,1); raw_data(j).handZ_100(1:end-numframes)];
        %             raw_data(j).handConfZ_10k = [zeros(numframes,1); raw_data(j).handConfZ_10k(1:end-numframes)];
        %             raw_data(j).pelletZ_100 = [zeros(numframes,1); raw_data(j).pelletZ_100(1:end-numframes)];
        %             raw_data(j).pelletConfZ_10k = [zeros(numframes,1); raw_data(j).pelletConfZ_10k(1:end-numframes)];
        %
        %             str = [raw_data(j).Session{1} ': Side camera delayed by ' num2str(numframes) ' frames. Vectors were adjusted to be aligned in time.'];
        %             disp(str)
        %         end

        %         % fix this later: use droped frames column rather than hard
        %         % coding
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
    SaveKdaFile(data{i},UI.OutPath)
end
