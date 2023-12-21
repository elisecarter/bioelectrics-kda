function PlotIndivTrajectories(data,UI)

f = figure("Visible","off","HandleVisibility","on");;
ax = axes('Parent',f);
plot(ax,0,0,'.','MarkerSize',150,'Color',"#65ad79")
hold on
plt = plot(ax,0,0);

for i = 1:length(data)
    % create folder for individual reaches in mouse dir
    folder = 'Individual Reaches';
    folder_path = fullfile(UI.OutPath,'TrajectoryPlots',[data{i}.Experimentor '_' data{i}.MouseID '_' data{i}.Phase],folder);
    if ~exist(folder_path,'dir')
        mkdir(folder_path)
    end

    for j = 1:length(data{i}.Sessions)
        % create folder for each session
        folder = data{i}.Sessions(j).SessionID{1};
        subfolder_path = fullfile(folder_path,folder);
        if ~exist(subfolder_path,'dir')
            mkdir(subfolder_path)
        end
    end

    for k = 1:length(data{i}.Sessions(j).InitialToMax)
        if strcmp(UI.PlotReach,'max')
            XData = data{i}.Sessions(j).InitialToMax(k).InterpolatedHand(:,1);
            YData = data{i}.Sessions(j).InitialToMax(k).InterpolatedHand(:,2);
        elseif strcmp(UI.PlotReach,'end')
            XData = data{i}.Sessions(j).InitialToEnd(k).InterpolatedHand(:,1);
            YData = data{i}.Sessions(j).InitialToEnd(k).InterpolatedHand(:,2);
        end
        set(plt,'XData',XData,'YData',YData,'Color','#000000','LineWidth',3)

        set(ax,'YDir','reverse')
        set(f,'Position', [400 345 560 350])
        set(ax,'YTick', -10:5:10, 'XTick',-20:5:10)
        xlim([-20 10])
        ylim([-10 10])
        xlabel('X (mm)')
        ylabel('Y (mm)')
        set(ax, 'box', 'off')
        drawnow

        filename = [data{i}.Sessions(j).SessionID{1} '_reach' num2str(k)];
        path = fullfile(subfolder_path,filename);

        if strcmp(UI.PlotFileType,'.png') || strcmp(UI.PlotFileType,'both')
            exportgraphics(ax,[path '.png'])
        end

        if strcmp(UI.PlotFileType,'.svg') || strcmp(UI.PlotFileType,'both')
            print(f,[path '.svg'],'-dsvg','-vector')
        end
    end

end