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
uimenu(menu_file, 'Text', 'Load Saved Session', 'Callback', @FileLoadSavedSession)
uimenu(menu_file, 'Text', 'Save Session', 'Callback', @FileSaveSession)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @FileQuit)

% process menu
%menu_process = uimenu(window, 'Label', 'Process');
%uimenu(menu_process, 'Text', 'Dynamic Time Warping', 'Callback', @ProcessDynamicTimeWarping)
%uimenu(menu_process, 'Text', 'Hand Arc Length', 'Callback', @ProcessFilterReaches)
%uimenu(menu_process, 'Text', 'Filter Reaches', 'Callback', @ProcessFilterReaches) %part of export json?

% Statistics menu
menu_stats = uimenu(window, 'Label', 'Statistics');
uimenu(menu_stats, 'Text', 'Reach Duration', 'Callback', @StatsReachDuration)
uimenu(menu_stats, 'Text', 'Velocity', 'Callback', @StatsVelocity)
uimenu(menu_stats, 'Text', 'Path Length', 'Callback', @StatsPathLength)
uimenu(menu_stats, 'Text', 'Path Length', 'Callback', @StatsPathLength)

% initialize data for nested functions 
data = [];

%% File Menu

% UI navigate to dirs, UI select mice, load raw data
    function FileLoadData(varargin)
      %add to session or new session
      %if  ~isempty(data)    
      %else
      %end
        
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
        CURdir = dir(CURpath);

        % user navigate to output directory
        msg3 = msgbox('Navigate to Output Directory');
        uiwait(msg3)
        OUTpath = uigetdir();
        if OUTpath == 0
            warning('User cancelled: No Output folder selected.')
            return
        end

        
        % clean this up eventually
        data = LoadRawData(MATpath, CURdir);
        OutputData(data, OUTpath)

        %ShowSumary(window,data)
    end

    function FileLoadSavedSession(varargin) %%%%
        % add to current session or new session
        %else 
        % new
        [file, path] = uigetfile('*.kda', 'Select Session File');
        data = load(fullfile(path,file),'-mat');
    end

    function FileSaveSession(varargin) %%%%
        % save data as .kda file (.mat file)
        [file,path,~] = uiputfile('Session1.kda');
        filename = fullfile(path,file);
        save(filename,'data', '-mat')
    end

    function FileQuit(varargin)
        close all
    end



end