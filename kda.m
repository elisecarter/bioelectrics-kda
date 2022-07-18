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
%
% to do:
%   add option to add meta (day of training, performance, end category,
%       behaviors, add cohort tag (check if exists in cur)
%   opening text/read me for guidance, data guide (units, multiplier)
%   add start and end of reaches to data, reach dur?
%   FOLDER W SAVED SESSION DATA (.json, .kda for each mouse) AND SAVED FIGURES (TITLE: MOUSE NUMBER, SESSION)
%   add data summary to program 
%   checkbox for processing steps (DTW,arclength,velocity?)
%   fix wait bar
%   after click load data, ask user if they want to save figures
%   error catching - tell user which mouse
%   if there is an empty cell make it a zero (stim)
%   units
%   add key to plots
%   make sure loading saved sessions will let you load multiple (either a
%   whole folder or select indiv .kda files
% meeting:
%   units: everything in mm? get rid of multipliers? (leave raw, convert
%   processed)
%   filter reaches during exporting or during preprocessing?

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
   '', '', '', '', 'Navigate using Toolbar'};
uicontrol(window, "Style", 'text', ...
   'String', opening_str, ...
   'BackgroundColor', '#DCFFE6', ...
   'Position', [155 120 250 200]);

% file menu 
menu_file = uimenu(window, 'Label', 'File');
uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @FileLoadData)
uimenu(menu_file, 'Text', 'Load Saved Session', 'Callback', @FileLoadSavedSession)
uimenu(menu_file, 'Text', 'Save Session', 'Callback', @FileSaveSession)
uimenu(menu_file, 'Text', 'Export', 'Callback', @FileExportJSON)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @FileQuit)

% process menu
menu_file = uimenu(window, 'Label', 'Process');
uimenu(menu_file, 'Text', 'Dynamic Time Warping', 'Callback', @ProcessDynamicTimeWarping)
uimenu(menu_file, 'Text', 'Hand Arc Length', 'Callback', @ProcessFilterReaches)
uimenu(menu_file, 'Text', 'Filter Reaches', 'Callback', @ProcessFilterReaches) %part of export json?

% plot menu
menu_file = uimenu(window, 'Label', 'Plot');
uimenu(menu_file, 'Text', 'Reach Duration', 'Callback', @ProcessFilterReaches)
uimenu(menu_file, 'Text', 'Dynamic Time Warping', 'Callback', @ProcessDynamicTimeWarping)

% initialize data for nested functions 
data = [];

%% File Menu

% UI navigate to dirs, UI select mice, load raw data
    function FileLoadData(varargin)
        %if  isempty(data)
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

        % else
        % call function to add to session or new session
        
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

    function FileExportJSON(varargin) 
        % if empty,error
        % else name file and save selected mice
        [file,~,~] = uiputfile('Session1.json');
        fid = fopen(file,'w');
        encodedJSON = jsonencode(data, PrettyPrint=true);
        fprintf(fid, encodedJSON);
    end

    function FileQuit(varargin)
        close all
    end

%% Process Menu

    function ProcessDynamicTimeWarping
        %     %dynamic time warping normalized to pellet
        %     %hand arc length
    end

%% Plot Menu
    function PlotHistogram
    end

    function PlotBoxPlot
    end
    
% function PlotReachCorrelation
%     %Day2Day
%     %Reach2Reach
%     %Reach2Ideal
% end

    function ShowSummary(window,data)
    end

end