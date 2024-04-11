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
    ind_traj.y(end,:) = NaN;
    
    % plot the pellet location
    plot(p_ax,0,0,'.','MarkerSize',150,'Color',"#65ad79")
    hold on

    % plot individual trajectories
    indLines = patch(p_ax,ind_traj.x,ind_traj.y,'b','LineWidth',1);
    indLines.EdgeAlpha = 0.15;
    set(p_ax,'YDir','reverse')

    if ~isempty(mouse_data.ExpertReach)
        % plot expert reach
        plot(p_ax,mouse_data.ExpertReach(:,1),mouse_data.ExpertReach(:,2),'LineWidth', 1 ,'Color','#000000')
    end
    
    %set(p_ax,'XLim',) % use crop points to set XLim and YLim?
    set(p_ax,'XLim',[-20 10], 'YLim', [-10 10])
    set(p,'Position', [400 345 560 375])
    set(p_ax,'YTick', -10:5:10, 'XTick',-20:5:10)

    xlabel('X (mm)')
    ylabel('Y (mm)')
    set(p_ax, 'box', 'off')
    str1 = sprintf('Mouse ID: %s',mouse_data.MouseID);
    str4 = sprintf('Phase: %s',mouse_data.Phase);
    str2 = sprintf('Number of reaches plotted: %d',length(session_data.InitialToMax));
    str3 = sprintf('Session: %s',session_str);
    title({str1;str4;str2;str3},'Interpreter','none')

    if strcmp(UI.PlotFileType,'.png') || strcmp(UI.PlotFileType,'both')
        exportgraphics(p_ax,fullfile(path,[session_str '.png']))
    end
    if strcmp(UI.PlotFileType,'.svg') || strcmp(UI.PlotFileType,'both')
        print(p,fullfile(path,[session_str '.svg']),'-dsvg','-vector')
    end
    cla(p_ax)
end

