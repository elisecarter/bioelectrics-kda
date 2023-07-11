function PlotTrajectories(mouse_data,path,UI)

p = figure("Visible","off","HandleVisibility","on");
p_ax = axes(p);

for i = 1:length(mouse_data.Sessions) % num sessions for this mouse
    session_data = mouse_data.Sessions(i);
    session_str = session_data.SessionID{1}; %this will break when session ID taken out of cell

    if strcmp(UI.PlotReach,'end')
        [avg_traj,ind_traj] = AverageTrajectory(session_data.InitialToEnd);
    elseif strcmp(UI.PlotReach,'max')
        [avg_traj,ind_traj] = AverageTrajectory(session_data.InitialToMax);
    end

    plot(p_ax,ind_traj.x,ind_traj.y,'Color','#918e8e','LineWidth',1)
    set(p_ax,'YDir','reverse')
    hold on
    plot(p_ax,avg_traj(:,1),avg_traj(:,2),'LineWidth', 3 ,'Color','#000000')

    %set(p_ax,'XLim',) % use crop points to set XLim and YLim?
    set(p_ax,'XLim',[-20 10], 'YLim', [-10 10])
    set(p,'Position', [400 345 560 375])
    set(p_ax,'YTick', -10:5:10, 'XTick',-20:5:10)

    % plot the pellet location
    plot(p_ax,0,0,'.','MarkerSize',150,'Color',"#65ad79")

    xlabel('X (mm)')
    ylabel('Y (mm)')
    set(p_ax, 'box', 'off')
    str1 = sprintf('Mouse ID: %s',mouse_data.MouseID);
    str2 = sprintf('Number of reaches: %d',length(session_data.InitialToMax));
    str3 = sprintf('Session: %s',session_str);
    title({str1;str2;str3},'Interpreter','none')

    if strcmp(UI.PlotFileType,'.png') || strcmp(UI.PlotFileType,'both')
        exportgraphics(p_ax,fullfile(path,[session_str '.png']))
    end
    if strcmp(UI.PlotFileType,'.eps') || strcmp(UI.PlotFileType,'both')
        exportgraphics(p_ax,fullfile(path,[session_str '.eps']))
    end
    cla(p_ax)
end
