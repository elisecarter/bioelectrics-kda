function kda
% Main function
%     Performs kinematic data analysis of mouse reach events
%     with data obtained from the CLARA system. Locations of Curator
%     and Matlab_3D folders are required. Users have the ability to run
%     for certain mice or for all mice found in folder. Data can be
%     exported in .json format. Data can also be saved
% 
% Authors:
%     Spencer Bowles
% 
%     Elise Carter 
%         elise.carter@cuanschutz.edu
% 
% Required add-ons:
%     interparc by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc
%     arclength by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34871-arclength

% to do:
% check for empty cur folders
% size/center figures
% checkboxes for add meta
% opening text/pic/README
% load error when csv is open
% raw velocity in preproccesing
% units: fps, or mm/sec
% make traj plots figure title (Final Session Reaches)
% add day, number of reaches to plot title
% pick reach max/end for trajectory plots, option to see traj plots?

%% Create GUI

% create figure: "window"
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none');
movegui(window,'center')

% text to display on window
%opening_str = {'','Kinematic Data Analysis of Mouse Reach Events', ...
%    '', '', '', '', 'Navigate using Toolbar'};
%uicontrol(window, "Style", 'text', ...
%    'String', opening_str, ...
%    'BackgroundColor', '#DCFFE6', ...
%    'Position', [155 120 250 200]);

% file menu -- add accelerators?
menu_file = uimenu(window, 'Label', 'File');
uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @FileLoadData)
uimenu(menu_file, 'Text', 'Load Saved Session', 'Callback', @FileLoadSavedSession)
uimenu(menu_file, 'Text', 'Save As', 'Callback', @FileSaveAs)
uimenu(menu_file, 'Text', 'Export', 'Callback', @FileExport)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @FileQuit)

% process menu
menu_file = uimenu(window, 'Label', 'Process');
uimenu(menu_file, 'Text', 'Filter Reaches', 'Callback', @ProcessFilterReaches)
uimenu(menu_file, 'Text', 'Dynamic Time Warping', 'Callback', @ProcessDynamicTimeWarping)

% change directory to Program Files so functions are on path
cd ProgramFiles/

% preallocation for callback function variables
data = [];

%% Callback Functions

% File Menu

% UI navigate to dirs, UI select mice, load raw data
    function FileLoadData(varargin)
        %if  isempty(data)
        % user naviagate to Matlab_3D folder
        msg1 = msgbox('Select Matlab_3D Folder');
        uiwait(msg1)
        MATpath = uigetdir();
        %MATdir = dir(fullfile(MATpath, '*.mat'));

        % user navigate to curator folder
        msg2 = msgbox('Select Curator Folder');
        uiwait(msg2)
        CURpath = uigetdir();
        CURdir = dir(CURpath);

        %else
        % call function to add to session or new session

        [CURdir, data] = SelectMice(CURdir); %put inside load raw data?
        %meta = SelectMeta;
        data = LoadRawData(data, MATpath, CURdir);
    end

    function FileLoadSavedSession %%%%
    end


    function FileSaveAs %%%%
    end


    function FileExportJSON
        [file,path,indx] = uiputfile('kda.json');
        fid=fopen(file,'w');
        encodedJSON = jsonencode(data(1), PrettyPrint=true);
        fprintf(fid, encodedJSON);
    end


    function FileQuit(varargin)
        close all
    end

% Process Menu

    function ProcessDynamicTimeWarping()
        %     %raw velocity
        %     %interp velocity
        %     %interp position
        %     %dynamic time warping normalized to pellet
        %     %hand arc length
        % end
        %
        % function StoreMetaData
        % end
        %
        % function ReachCorrelation
        %     %Day2Day
        %     %Reach2Reach
        %     %Reach2Ideal
    end

% Plot Menu
    function PlotHistogram
    end

    function PlotBoxPlot
    end
end