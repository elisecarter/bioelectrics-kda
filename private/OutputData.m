function OutputData(data, OUTpath, user_selections)
% creates folder for trajectory plots if it doesnt already exist in output
% directory

plot_folder = "TrajectoryPlots";
plot_folder_path = fullfile(OUTpath,plot_folder);
if ~exist(plot_folder_path,'dir')
    mkdir(plot_folder_path)
end

json_folder = "jsonFiles";
json_folder_path = fullfile(OUTpath,json_folder);
if ~exist(json_folder_path,'dir')
    mkdir(json_folder_path)
end

for i = 1:length(data)
    mouse_name = data{i}.MouseID;
    subfolder_path = fullfile(plot_folder_path,mouse_name); %mouse subfolder in trajectory plots folder
    if ~exist(subfolder_path,'dir')
        mkdir(subfolder_path)
    end

    if user_selections.SavePlots == 1 
        PlotTrajectories(data{i},subfolder_path)
    end
    
    SaveJSON(data{i}, json_folder_path)
    SaveKdaFile(data{i}, OUTpath)

end

