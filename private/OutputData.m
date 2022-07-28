function OutputData(data, OUTpath)
plot_folder = "Trajectory Plots";

for i = 1:length(data)
    folder_name = data{i}.MouseID;
    folder_path = fullfile(OUTpath,folder_name);
     if ~exist(folder_path,'dir')
         mkdir(folder_path)
     end
    
    plot_path = fullfile(folder_path,plot_folder);
     if ~exist(plot_path,'dir')
         mkdir(plot_path)
     end

    PlotTrajectories(data{i},plot_path)
    SaveJSON(data{i}, folder_path)
    SaveKdaFile(data{i}, folder_path)
    
end

