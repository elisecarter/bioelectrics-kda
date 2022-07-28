function kda
% Main function
%     Performs kinematic data analysis of mouse reach events
%     with data obtained from the CLARA system. Locations of Curator
%     and Matlab_3D folders are required.
%
% Authors:
%     Spencer Bowles
%     Elise Carter (elise.carter@cuanschutz.edu)
%
% Required add-ons:
%     interparc by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc
%     arclength by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34871-arclength

%% Create GUI
% turn off TEX interpreter
set(0, 'DefaulttextInterpreter', 'none');

% create figure: "window"
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none');
movegui(window,'center')

% text to display on window
opening_str = {'','Kinematic Data Analysis of Mouse Reach Events', ...
    '', '', '', 'Navigate using Toolbar'};
uicontrol(window, "Style", 'text', ...
    'String', opening_str, ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [155 120 250 200]);

% file menu
menu_file = uimenu(window, 'Label', 'File');
uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @FileLoadData)
uimenu(menu_file, 'Text', 'Load Saved Session File(s)', 'Callback', @FileLoadSavedSession)
uimenu(menu_file, 'Text', 'Save Session', 'Callback', @FileSaveSession)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @FileQuit)

% process menu
menu_process = uimenu(window, 'Label', 'Process');
uimenu(menu_process, 'Text', 'Extract Kinematics', 'Callback', @ProcessPreprocessData)

% Statistics menu
menu_stats = uimenu(window, 'Label', 'Statistics');
uimenu(menu_stats, 'Text', 'Reach Duration', 'Callback', @StatsReachDuration)
uimenu(menu_stats, 'Text', 'Velocity', 'Callback', @StatsVelocity)
uimenu(menu_stats, 'Text', 'Path Length', 'Callback', @StatsPathLength)

% initialize data for nested functions
data = [];

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

            if strcmpi(answer,btn1)
                data = [];
            end
        end

        % user naviagate to Matlab_3D folder
        msg1 = msgbox('Select Matlab_3D Folder');
        uiwait(msg1)
        MATpath = uigetdir();
        if MATpath == 0
            warning('User cancelled: No Matlab_3D folder selected.')
            return
        end

        % user navigate to curator folder
        msg2 = msgbox('Select Curators Folder');
        uiwait(msg2)
        CURpath = uigetdir();
        if CURpath == 0
            warning('User cancelled: No Curator folder selected.')
            return
        end

        [mouseIDs,CURdir] = GetMouseIDs(CURpath);
        [mouseIDs,indx] = SelectMice(mouseIDs);
        CURdir = CURdir(indx);

        datacount = length(data);
        for i = 1:length(mouseIDs)
            data{datacount+i} = struct('MouseID',mouseIDs(i));
        end
        data = LoadRawData(data, MATpath,CURdir);
        DataSummary(data,window)
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

            if strcmpi(answer,btn1)
                data = [];
            end
        end

        datacount = length(data);

        %user navigate to .kda file(s)
        [file, path] = uigetfile('*.kda', 'Select Session File','MultiSelect','on');
        if iscell(file)
            for i = 1:length(file)
                datacount = datacount+1;
                data{datacount} = load(fullfile(path,file{i}),'-mat');
            end
        else
            datacount = datacount+1;
            data{datacount} = load(fullfile(path,file),'-mat');
        end
        
        DataSummary(data,window)
    end

    function FileSaveSession(varargin) %%%%
        if isempty(data)
            error('No session data to save.')
        end

        % save data as .kda file (.mat file)
        path = uigetdir();
        for i = 1:length(data)
            SaveKdaFile(data{i},path)
        end
    end

    function FileQuit(varargin)
        close all
    end

%% Process Menu
    function ProcessPreprocessData(varargin)
        % user navigate to output directory
        msg3 = msgbox('Navigate to Output Directory');
        uiwait(msg3)
        OUTpath = uigetdir();
        if OUTpath == 0
            warning('User cancelled: No Output folder selected.')
            return
        end

        f = waitbar(0,'Please wait...'); % create wait bar
        for i = 1:length(data)
            waitstr = "Preprocessing raw data... (" + data{i}.MouseID + ")";
            waitbar(i/length(data),f,waitstr);
            data{i}.Sessions = PreprocessReachEvents(data{i}.RawData);
            data{i}.Status = 'Kinematics Extracted';
        end
        close(f)
        DataSummary(data,window)
        ReviewFinalTrajectories(data)
        OutputData(data, OUTpath)
    end

end