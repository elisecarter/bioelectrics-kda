function OutputData(data, OUTpath)

plot_folder = "Trajectory Plots";
for i = 1:length(data)
    folder_name = data(i).MouseID;
    folder_path = fullfile(OUTpath,folder_name);
    mkdir(folder_path)
    
    plot_path = fullfile(folder_path,plot_folder);
    mkdir(plot_path)

    PlotTrajectories(data(i),plot_path)
    SaveJSON(data(i), folder_path)
    
end

