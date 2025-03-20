function OutputData(data, OUTpath, UI)
% creates folder for trajectory plots if it doesnt already exist in output
% directory

if UI.SavePlots == 1
    plot_folder = "TrajectoryPlots";
    plot_folder_path = fullfile(OUTpath,plot_folder);
    if ~exist(plot_folder_path,'dir')
        mkdir(plot_folder_path)
    end

    mouse_name = [data.Experimentor '_' data.MouseID '_' data.Phase];
    subfolder_path = fullfile(plot_folder_path,mouse_name); %mouse subfolder in trajectory plots folder
    if ~exist(subfolder_path,'dir')
        mkdir(subfolder_path)
    end
    PlotTrajectories(data,subfolder_path,UI)
end


SaveKdaFile(data, OUTpath)