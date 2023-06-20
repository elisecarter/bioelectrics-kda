function OutputData(data, OUTpath, user_selections)
% creates folder for trajectory plots if it doesnt already exist in output
% directory

if user_selections.SavePlots == 1
    plot_folder = "TrajectoryPlots";
    plot_folder_path = fullfile(OUTpath,plot_folder);
    if ~exist(plot_folder_path,'dir')
        mkdir(plot_folder_path)
    end
end

json_folder = "jsonFiles";
json_folder_path = fullfile(OUTpath,json_folder);
if ~exist(json_folder_path,'dir')
    mkdir(json_folder_path)
end

mouse_name = data.MouseID;
subfolder_path = fullfile(plot_folder_path,mouse_name); %mouse subfolder in trajectory plots folder
if ~exist(subfolder_path,'dir')
    mkdir(subfolder_path)
end

if user_selections.SavePlots == 1
    PlotTrajectories(data,subfolder_path)
end

SaveJSON(data, json_folder_path)
SaveKdaFile(data, OUTpath)