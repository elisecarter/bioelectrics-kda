function OutputData(data, OUTpath)

%csvfolder_name = "CSV Files";
trajplot_folder = "Trajectory Plots";

for i = 1:length(data)
    folder_name = data(i).MouseID;
    folder_path = sprintf('%s/%s',OUTpath,folder_name);
    mkdir(folder_path)
    
%     csv_path = sprintf('%s/%s',folder_path,csvfolder_name);
%     mkdir(csv_path)
% 
%     CreateCSV(data(i),csv_path);
    traj_plot_path = sprintf('%s/%s',folder_path,trajplot_folder);
    mkdir(traj_plot_path)
    PlotTrajectories(data(i),traj_plot_path)

end

