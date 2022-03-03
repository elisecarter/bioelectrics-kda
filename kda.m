function kda
%  Main function

%  Performs kinematic data analysis of mouse reach events 
%  with data obtained from the CLARA system. Locations of Curator 
%  and Matlab_3D folders required. Users have the ability to run
%  for certain mice or for all mice found in folder. To avoid 
%  unnecessary computing, save sessions with mouse data and add 
%  new data using the "Load Session" feature. Data can be exported in
%  .json format.

%  Required add-ons: 
%    interparc by John D'Errico
%    arclength by John D'Errico


%% Create GUI
% create figure: "window"
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none'); 

% text to display on window
opening_str = {'','Kinematic Data Analysis of Mouse Reach Events', ...
    '', '', '', '', 'Navigate using Toolbar'};
uicontrol(window, "Style", 'text', ... 
    'String', opening_str, ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [155 120 250 200]);

% load menu -- accelerators?
menu_load = uimenu(window, 'Label', 'Load');
uimenu(menu_load, 'Text', 'Load Raw Data', @LoadRawData)

% preallocation for callback function variables
data = [];


%% Nested Functions

% UI navigate to dirs, UI select mice, load raw data
function LoadRawData(varargin)
    if  isempty(data)
        % user naviagate to Matlab_3D folder
        %f = msgbox('Select Matlab_3D Folder');
        %uiwait(f)
        MATpath = uigetdir();
        MATdir = dir(fullfile(MATpath, '*.mat'));

        % user navigate to curator folder
        %f = msgbox('Select Curator Folder');
        %uiwait(f)
        CURpath = uigetdir();
        CURdir = dir(CURpath);

        % remove anything that is not a subdirectory in curator folder
        CURdir(~[CURdir.isdir]) = [];

        %else
        % call function to add to session or new session
    end
    mouseIDs = SelectMice(CURdir);
end



% load selected mice
function StoreMouseData

    % load
    for i = length(mouseIDs)
        rawdata(i) = load(fullfile(path, files(i).name));

    end
    
end


% 
% function LoadSavedSession
% end
% 
% 
% 
% 
% function ProcessReachVelocity
% end
% 
% % function PlotHistogram
% end
% 
% function PlotBoxPlot
% end
% 
% function ExportJSON
% end
% 
% function ExportMAT
% end
%     end
% function FileExit(varargin)
%         close all
% end

% 
% function FindMouseSessions
% end






% %% Process
% 
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
