function kda
% Main function
% This program analyzes paw tracking data generated by CLARA to extract
% kinematic features and compute session level means for mice performing
% a skilled reaching task.
%
% Required add-ons (already included in private folder):
%     interparc by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc
%     arclength by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34871-arclength

%% Create GUI
% turn off TEX interpreter
set(0, 'DefaulttextInterpreter', 'none');

% create main window
window = figure( ...
    'Name', 'Kinematic Data Analysis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none', ...
    'HandleVisibility','off');
movegui(window,'center')

% create objects to store text
% data summary handle:
dHand = uicontrol(window, "Style", 'text', ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [130 75 300 300]);
% output directory handle:
outHand = uicontrol(window, "Style", 'text', ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [14 20 535 22]);

% matlab 3d directory handle:
matHand = uicontrol(window, "Style", 'text', ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [14 45 535 22]);

% text to display on window
opening_str = {'','','','Extracts Kinematic Features from CLARA-Generated Datasets', ...
    '', 'Version 1.1', '', 'Navigate using Toolbar'};
set(dHand,'String', opening_str)

% file menu
menu_file = uimenu(window, 'Label', 'File');
uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @FileLoadData)
uimenu(menu_file, 'Text', 'Load KDA File(s)', 'Callback', @FileLoadSavedSession)
uimenu(menu_file, 'Text', 'Change MATLAB 3D Directory','Callback', @FileChangeMatPath)
uimenu(menu_file, 'Text', 'Change Output Directory','Callback', @FileChangeOutPath)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @FileQuit)

% analysis menu
menu_analysis = uimenu(window, 'Label', 'Analysis');
uimenu(menu_analysis, 'Text', 'Extract Kinematics', 'Callback', @AnalysisExtractKinematics)
uimenu(menu_analysis, 'Text', 'Learning Phase Correlations', 'Callback', @AnalysisPhaseCorrelations)

% export menu
menu_export = uimenu(window, 'Label', 'Export');
uimenu(menu_export, 'Text', 'Session Means Table', 'Callback', @ExportSessionMeans)
uimenu(menu_export, 'Text', 'Individual Reach Table', 'Callback',@ExportIndivReaches)
uimenu(menu_export,'Text','Reach Inclusion Tables','Callback',@ExportInclusionTables)
uimenu(menu_export, 'Text', 'Individual Trajectories', 'Callback', @ExportIndivTraj)
uimenu(menu_export, 'Text', 'Session Trajectories', 'Callback', @ExportSessionTraj)
uimenu(menu_export, 'Text', 'KDA File(s) to Base Workspace', 'Callback', @ExportKdaToBase)

% initialize data for nested functions
data = [];
UI = struct;

% checks for file containing matlab 3D path (this txt file is created the first
% time a user defines the path
if isfile('rawDataPath.txt')
    fileID = fopen('rawDataPath.txt','r');
    UI.Mat3Dpath = fscanf(fileID, '%s');

    % update displayed matlab 3d path
    string = ['MATLAB 3D directory: ' UI.Mat3Dpath];
    set(matHand, 'String', string)
end

%% File Menu

% UI navigate to dirs, UI select mice, load raw data
    function FileLoadData(varargin)
        %add to session or new session
        if  ~isempty(data)
            quest = 'Would you like to start a new session or add the the current session?';
            dlgtitle = 'New Session or Add to Session';
            btn1 = 'New Session';
            btn2 = 'Add to current session';
            defbtn = 'Add to current session';
            answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);

            % if new session, delete data
            if strcmpi(answer,btn1)
                data = [];
            end
        end

        if isfield(UI,'Mat3Dpath') %if matlab 3d path was autopopulated
            % if path does not lead to exisitng directory, prompt for new path
            if ~isfolder(UI.Mat3Dpath)
                % user naviagate to Matlab_3D folder
                msg1 = msgbox('Select Matlab_3D Folder');
                uiwait(msg1)
                UI.Mat3Dpath = uigetdir();
                % if canceled then return
                if UI.Mat3Dpath == 0
                    warning('User cancelled: No Matlab_3D folder selected.')
                    return
                end
                % save path in text file
                fID = fopen('rawDataPath.txt','w');
                fprintf(fID,'%s',UI.Mat3Dpath);
            end

        else % need to prompt user for matlab 3d path
            % user naviagate to Matlab_3D folder
            msg1 = msgbox('Select Matlab_3D Folder');
            uiwait(msg1)
            UI.Mat3Dpath = uigetdir();
            % if canceled then return
            if UI.Mat3Dpath == 0
                warning('User cancelled: No Matlab_3D folder selected.')
                return
            end
            % save path in text file
            fID = fopen('rawDataPath.txt','w');
            fprintf(fID,'%s',UI.Mat3Dpath);
        end

        % user navigate to curator folder
        msg2 = msgbox('Select Curators Folder');
        uiwait(msg2)
        UI.CurPath = uigetdir();
        %if canceled then return
        if UI.CurPath == 0
            warning('User cancelled: No Curator folder selected.')
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end
        
        disp('Loading raw data...')
        data = LoadRawData(data,UI);
        DataSummary(data,dHand) %update
        disp('Raw data successfully loaded and saved to output directory. Proceed with analysis.')
    end

    function FileLoadSavedSession(varargin)
        %add to session or new session
        if  ~isempty(data)
            quest = 'Would you like to start a new session or add the the current session?';
            dlgtitle = 'New Session or Add to Session';
            btn1 = 'New Session';
            btn2 = 'Add to current session';
            defbtn = 'Add to current session';
            answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);

            % if new session, delete data
            if strcmpi(answer,btn1)
                data = [];
            end
        end

        datacount = length(data);

        %user navigate to .kda file(s)
        [file, path] = uigetfile('*.kda', 'Select Session File','MultiSelect','on');

        disp('Loading kda files...')
        if ~iscell(file)
            if file == 0
                warning('User cancelled: No kda file selected.')
                return
            end
            datacount = datacount+1;
            data{datacount} = load(fullfile(path,file),'-mat');
        elseif iscell(file)
            for i = 1:length(file)
                datacount = datacount+1;
                data{datacount} = load(fullfile(path,file{i}),'-mat');
            end
        end
        DataSummary(data,dHand)
        disp('Kda files successfully loaded. Proceed with analysis/export.')
    end

    function FileChangeMatPath(varargin)
        % user navigate to matlab 3d directory
        UI.Mat3Dpath = uigetdir();
        if UI.Mat3Dpath == 0
            warning('User cancelled: MATLAB 3D folder not selected.')
            return
        end
        % save path in text file
        fID = fopen('rawDataPath.txt','w');
        fprintf(fID,'%s',UI.Mat3Dpath);
        % update displayed output path
        str = ['MATLAB 3D directory: ' UI.Mat3Dpath];
        set(matHand, 'String', str)
    end


    function FileChangeOutPath(varargin)
        % user navigate to output directory
        msg = msgbox('Select Output Directory');
        uiwait(msg)
        UI.OutPath = uigetdir();
        if UI.OutPath == 0
            warning('User cancelled: No output folder selected.')
            return
        end
        % update displayed output path
        str = ['Output directory: ' UI.OutPath];
        set(outHand, 'String', str)
    end

    function FileQuit(varargin)
        close ('all','hidden')
    end

%% Analysis Menu
    function AnalysisExtractKinematics(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Please load raw ' ...
                'data before extracting kinematics.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'Raw'), data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please load raw data before extracting kinematics.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        UI = UserSelections(UI,'ExtractKinematics');
        disp('Extracting kinematics...')
        data = PreprocessMice(data,UI);
        DataSummary(data,dHand)
        disp('Kinematics successfully extracted and saved to output directory. Proceed with session means export.')
    end

    function AnalysisPhaseCorrelations(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to compare. Please load data with ' ...
                'kinematics extracted before comparing learning phases.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please extract kinematics before exporting session means.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        % create cell array of all phases
        for i = 1:length(data)
            allPhases{i} = data{i}.Phase;
        end

        % find unique phases
        [grps, id] = findgroups(allPhases);
        if length(id) ~= 2
            error(['Only two learning phases are allowed at a time and ' num2str(length(id)) 'were found.']);
        end
        msg = [[num2str(length(id)) ' phases found: '] id];
        box = msgbox(msg);
        uiwait(box);

        % group by phase
        for i = 1:length(id)
            ind = (grps == i);
            group{i} = [data(ind)];
        end

        % make sure same number of mice in each phase
        if length(group{1}) ~= length(group{2})
            error('Number of animals in each phase is not equivalent. Ensure all mice are loaded into the workspace.')
        end

        %check that mouseIDs in secondary list are in same order as primary list
        prmpt = sprintf('Select Phase ID for Phase 1');
        [ind1, ~] = listdlg('ListString',id,'PromptString',prmpt,'SelectionMode','single');
        prmpt = sprintf('Select Phase ID for Phase 2');
        [ind2, ~] = listdlg('ListString',id,'PromptString',prmpt,'SelectionMode','single');

        for i = 1:length(group{1})
            primary{i} = group{ind1}{i}.MouseID;
            secondary{i} = group{ind2}{i}.MouseID;
        end

        if ~any(strcmpi(primary,secondary))
            [~,pind] = sort(primary);
            [~,sind] = sort(secondary);
            group{ind1} = group{ind1}(pind);
            group{ind2} = group{ind2}(sind);
        end

        % opt to group by cohort
        quest = 'Would you like to group by experimental condition?';
        dlgtitle = 'Group Option';
        yes = 'yes';
        no = 'no';
        defbtn = 'yes';
        answer = questdlg(quest,dlgtitle,yes,no,defbtn);

        % ui select mice to group
        if strcmpi(answer,yes)
            % user input number of cohorts
            prompt = {'Enter the number of cohorts:'};
            dlgtitle = 'Number of Cohorts';
            dims = [1 35];
            definput = {'2'};
            num_cohorts = str2double(inputdlg(prompt,dlgtitle,dims,definput));
            dat = SelectCohorts(group{1},num_cohorts,group{2});

        elseif strcmpi(answer,no)
            % single cohort
            dat = {group{1} group{2}};
            for i = 1:length(dat{1})
                dat{1}{i}.GroupID = ' ';
                dat{2}{i}.GroupID = ' ';
            end
        end

        % compute phase correlations for each animal
        for i = 1:length(group{1})
            corrData{i} = ComputePhaseCorrelations(dat{1,ind1}{1,i},dat{1,ind2}{1,i});
        end

        OutputPhaseCorrelations(corrData,UI.OutPath)
    end


%% Export Menu
    function ExportSessionMeans(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Please load kinematic ' ...
                'data before exporting session means.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please extract kinematics before exporting session means.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        if ~isfield([data{:}],'GroupID')
            quest = 'Would you like to group by experimental condition?';
            dlgtitle = 'Group Option';
            yes = 'Yes';
            no = 'No';
            defbtn = 'Yes';
            answer = questdlg(quest,dlgtitle,yes,no,defbtn);

            % ui select mice to group
            if strcmpi(answer,yes)
                % user input number of groups
                prompt = {'Enter the number of groups:'};
                dlgtitle = 'Number of Groups';
                dims = [1 35];
                definput = {'2'};
                num_cohorts = str2double(inputdlg(prompt,dlgtitle,dims,definput));
                data = SelectCohorts(data,num_cohorts);

            elseif strcmpi(answer,no)
                for i = 1:length(data)
                    data{i}.GroupID = ' ';
                end
            end
        end

        UI = UserSelections(UI,'OutputSessionMeans');
        
        disp('Exporting session means...')
        for i = 1:length(data)
            % compute session means
            data{i} = SessionMeans(data{i},UI);
            SaveKdaFile(data{i}, UI.OutPath)
        end

        OutputSessionMeans(data,UI)
        disp('Session means successfully exported to output directory.')
    end
    
    function ExportIndivReaches(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Please load kinematic ' ...
                'data before exporting session means.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please extract kinematics before exporting session means.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        if ~isfield([data{:}],'GroupID')
            quest = 'Would you like to group by experimental condition?';
            dlgtitle = 'Group Option';
            yes = 'Yes';
            no = 'No';
            defbtn = 'Yes';
            answer = questdlg(quest,dlgtitle,yes,no,defbtn);

            % ui select mice to group
            if strcmpi(answer,yes)
                % user input number of groups
                prompt = {'Enter the number of groups:'};
                dlgtitle = 'Number of Groups';
                dims = [1 35];
                definput = {'2'};
                num_cohorts = str2double(inputdlg(prompt,dlgtitle,dims,definput));
                data = SelectCohorts(data,num_cohorts);

            elseif strcmpi(answer,no)
                for i = 1:length(data)
                    data{i}.GroupID = ' ';
                end
            end
        end

        %UI = UserSelections(UI,'OutputSessionMeans');
        
        disp('Exporting reach table...')

        OutputReachTable(data,UI)
        disp('Reach table successfully exported to output directory.')
    end

    function ExportInclusionTables(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Please load kinematic ' ...
                'data before exporting inclusion tables.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Please extract kinematics before exporting inclusion tables.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        disp('Exporting reach inclusion tables...')
        for i = 1:length(data)
            pat = fullfile(UI.OutPath,'InclusionTables');
            folder = [data{i}.Experimentor,'_',data{i}.MouseID];
            if ~strcmp(data{i}.Phase,'') %is a phase for file
                folder = [folder,'_',data{i}.Phase];
            end
            pat = fullfile(pat,folder);
            if ~exist(pat,'dir')
                mkdir(pat)
            end
            OutputInclusionTable(data{i},pat)
        end
        disp('Inclusion tables successfully exported to output directory.')
    end

    function ExportIndivTraj(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Load kinematic data ' ...
                'before plotting trajectories.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Extract kinematics before plotting trajectories.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        UI = UserSelections(UI,'PlotTrajectories');
        disp('Exporting individual trajectories...')
        PlotIndivTrajectories(data,UI)
        disp('Trajectories successfully exported to output directory.')
    end

    function ExportSessionTraj(varargin)
        % check that mice are loaded and have correct status
        if isempty(data)
            err1 = msgbox(['No data to process. Load kinematic data ' ...
                'before plotting trajectories.']);
            uiwait(err1)
            return
        elseif any(cellfun(@(x) ~strcmp(x.Status,'KinematicsExtracted'),data))
            err2 = msgbox(['Data does not have correct status. ' ...
                'Extract kinematics before plotting trajectories.']);
            uiwait(err2)
            return
        end

        % check if output folder path has been not yet been defined
        if ~isfield(UI,'OutPath')
            FileChangeOutPath()
        end

        UI = UserSelections(UI,'PlotTrajectories');
        disp('Exporting session trajectories...')
        plot_folder = "TrajectoryPlots";
        plot_folder_path = fullfile(UI.OutPath,plot_folder);
        if ~exist(plot_folder_path,'dir')
            mkdir(plot_folder_path)
        end

        for i = 1:length(data)
            mouse_name = [data{i}.Experimentor '_' data{i}.MouseID '_' data{i}.Phase];
            subfolder_path = fullfile(plot_folder_path,mouse_name); %mouse subfolder in trajectory plots folder
            if ~exist(subfolder_path,'dir')
                mkdir(subfolder_path)
            end
            PlotTrajectories(data{i},subfolder_path,UI)
        end
        disp('Trajectories successfully exported to output directory.')
    end

    function ExportKdaToBase(varargin)
        %         chose kda files to export and load
        %         [file, path] = uigetfile('*.kda', 'Select Session File','MultiSelect','on');
        %         if ~iscell(file)
        %             if file == 0
        %                 warning('User cancelled: No session folder selected.')
        %                 return
        %             end
        %             exportdata = load(fullfile(path,file),'-mat');
        %         elseif iscell(file)
        %             for i = 1:length(file)
        %                 exportdata{i} = load(fullfile(path,file{i}),'-mat');
        %             end
        %         end
        if isempty(data)
            err1 = msgbox(['No data in workspace to export. ']);
            uiwait(err1)
            return
        end
        disp('Exporting kda files...')
        kdaData = data;
        assignin('base',"kdaData",kdaData) %export to base
        str = 'Kda filed successfully exported to Base workspace in kdaData.';
        disp(str)
    end

end
