function OutputData(data, OUTpath)

plot_folder = "Trajectory Plots";
for i = 1:length(data)
    folder_name = data(i).MouseID;
    folder_path = fullfile(OUTpath,folder_name);
%     if ~exists(folder_path)
%         mkdir(folder_path)
%     end
    
    plot_path = fullfile(folder_path,plot_folder);
%     if ~exists(plot_path)
%         mkdir(plot_path)
%     end

    PlotTrajectories(data(i),plot_path)
    SaveJSON(data(i), folder_path)
    SaveMATFile(data(i), folder_path)
    
end

