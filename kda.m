function kda
%  Main function
%  Performs kinematic data analysis of mouse reach events 
%  with data obtained from the CLARA system. Locations of Curator 
%  and Matlab_3D folders are required. Users have the ability to run
%  for certain mice or for all mice found in folder. To avoid 
%  unnecessary computing, save sessions with mouse data and add 
%  new data using the "Load Session" feature. Data can be exported in
%  .json format.

%  Required add-ons: 
%    interparc by John D'Errico
%    arclength by John D'Errico

% to do:
% check for empty cur folders
% size figures
% checkboxes for add meta
% opening text/pic/README
% add wait bar for loadrawdata
% load error when csv is open

%% Setup, Create GUI
clc; clear;

% create figure: "window"
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none'); 

% text to display on window
%opening_str = {'','Kinematic Data Analysis of Mouse Reach Events', ...
%    '', '', '', '', 'Navigate using Toolbar'};
%uicontrol(window, "Style", 'text', ... 
%    'String', opening_str, ...
%    'BackgroundColor', '#DCFFE6', ...
%    'Position', [155 120 250 200]);

% file menu -- add accelerators?
menu_file = uimenu(window, 'Label', 'File');
uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @LoadData)
uimenu(menu_file, 'Text', 'Save As', 'Callback', @FileSaveAs)
uimenu(menu_file, 'Text', 'Export', 'Callback', @FileExport)
uimenu(menu_file, 'Text', 'Quit', 'Callback', @QuitProgram)

% process menu
%menu_file = uimenu(window, 'Label', 'File');
%uimenu(menu_file, 'Text', 'Load Raw Data', 'Callback', @LoadData)

% change directory to Program Files so functions are on path
cd ProgramFiles/

% preallocation for callback function variables
data = [];

%% Callback Functions

% UI navigate to dirs, UI select mice, load raw data
    function LoadData(varargin)
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


% 
% function LoadSavedSession
% end
% 

% 
% % function PlotHistogram
% end
% 
% function PlotBoxPlot
% end
% 
% function ExportJSON
% JSONFILE_name= sprintf('JSON.json'); 
%     fid=fopen(JSONFILE_name,'w'); 
%     encodedJSON = jsonencode(data(1), PrettyPrint=true); 
%     fprintf(fid, encodedJSON);
% end
% 
% function ExportMAT
% end
%     end
function FileExit(varargin)
         close all
end




% %% Process

% function CalculateReachVelocities
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
% end
end