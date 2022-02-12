function kda
% Main function - run to open GUI

% Required add-ons: 
%   interparc by John D'Errico
%   arclength by John D'Errico

% create gui
window = figure( ...
    'Name', 'Kinematic Data Analyis', ...
    'NumberTitle', 'off', ...
    'Color', '#DCFFE6', ...
    'MenuBar', 'none'); 

opening_str = {'','Kinematic Data Analysis of Mouse Reach Events', ...
    '', '', '', '', 'Navigate using Toolbar'};

text = uicontrol(window, "Style", 'text', ... 
    'String', opening_str, ...
    'BackgroundColor', '#DCFFE6', ...
    'Position', [155 120 250 200]);

% file menu
menu_file = uimenu(window, 'Label', 'File');




