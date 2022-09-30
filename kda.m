function kda
% Main function
%     Performs kinematic data analysis of mouse reach events
%     with data obtained from the CLARA system. User is required to 
%     navigate to Curator and Matlab_3D folders.
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

% create main window
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none', ...
    'HandleVisibility','off');
movegui(window,'center')

% text to display on window
opening_str = {'','Kinematic Data Analysis for use with CLARA', ...
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

% analysis menu
menu_analysis = uimenu(window, 'Label', 'Analysis');
uimenu(menu_analysis, 'Text', 'Extract Kinematics', 'Callback', @AnalysisExtractKinematics)
uimenu(menu_analysis, 'Text', 'Correlations', 'Callback', @AnalysisCorrelations,'Enable','off')
uimenu(menu_analysis, 'Text', 'Compare Cohorts', 'Callback', @AnalysisCompareCohorts,'Enable','off')

% plot menu
menu_plot = uimenu(window, 'Label', 'Plot');
uimenu(menu_plot, 'Text', 'Session Means', 'Callback', @PlotSessionMeans,'Enable','off')


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
        
        % datacount should be zero if nothing loaded
        datacount = length(data);
        
        % create data structures for mice to process
        for i = 1:length(mouseIDs)
            data{datacount+i} = struct('MouseID',mouseIDs(i));
        end
        
        data = LoadRawData(data,MATpath,CURdir);
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
        if path == 0
            warning('User cancelled: No Output folder selected.')
            return
        end

        for i = 1:length(data)
            SaveKdaFile(data{i},path)
        end
    end

    function FileQuit(varargin)
        close ('all','hidden')
    end

%% Analysis Menu
    function AnalysisExtractKinematics(varargin)
        % user navigate to output directory
        msg3 = msgbox('Navigate to Output Directory');
        uiwait(msg3)
        OUTpath = uigetdir();
        if OUTpath == 0
            warning('User cancelled: No Output folder selected.')
            return
        end
        
        user_selections = UserSelections('ExtractKinematics');
        data = PreprocessMice(data, user_selections);
        DataSummary(data,window)
        OutputData(data, OUTpath,user_selections)
    end

    function AnalysisCorrelations
        % user navigate to output directory
        msg3 = msgbox('Navigate to Output Directory');
        uiwait(msg3)
        OUTpath = uigetdir();
        if OUTpath == 0
            warning('User cancelled: No Output folder selected.')
            return
        end
        
        user_selections = UserSelections('Correlations');

    end

%% Plot Menu
    function PlotSessionMeans(varargin)
        quest = 'Would you like save session mean plots?';
        dlgtitle = 'Session Plots Save Option';
        btn1 = 'Yes';
        btn2 = 'No';
        defbtn = 'Yes';
        answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);

        if strcmpi(answer,btn1)
            % user navigate to output directory
            msg4 = msgbox('Navigate to Output Directory');
            uiwait(msg4)
            OUTpath = uigetdir();
            if OUTpath == 0
                warning('User cancelled: No Output folder selected.')
                return
            end
        else
            OUTpath = 0;
        end

        MouseIDs = [data{1:end}.MouseID];
        %MouseIDs = {temp.MouseID};
        [~,indx] = SelectMice(MouseIDs);
        plotdata = data(indx);

        PlotMeans(plotdata,OUTpath)

    end

end
