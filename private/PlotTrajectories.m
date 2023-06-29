function PlotTrajectories(mouse_data,path)

p = figure("Visible","off","HandleVisibility","on"); 
p_ax = axes(p);

for i = 1:length(mouse_data.Sessions) % num sessions for this mouse
    session_data = mouse_data.Sessions(i);
    session_str = session_data.SessionID{1}; %this will break when I take session ID out of cell
    [avg_traj,ind_traj] = AverageTrajectory(session_data.InitialToMax);
    plot(p_ax,ind_traj.x,ind_traj.y,'Color','#918e8e','LineWidth',1)
    set(p_ax,'YDir','reverse')
    hold on
    plot(p_ax,avg_traj(:,1),avg_traj(:,2),'LineWidth', 3 ,'Color','#000000')
    

    %set(p_ax,'XLim',) % use crop points to set XLim and YLim?
    
    % plot the pellet location
    plot(p_ax,0,0,'.','MarkerSize',200,'Color',"#65ad79")

    xlabel('X (mm)')
    ylabel('Y (mm)')
    set(p_ax, 'box', 'off')
    str1 = sprintf('Mouse ID: %s',mouse_data.MouseID);
    str2 = sprintf('Number of reaches: %d',length(session_data.InitialToMax));
    str3 = sprintf('Session: %s',session_str); 
    title({str1;str2;str3},'Interpreter','none')
    
    saveas(p,fullfile(path,session_str),'png')
   
    cla(p_ax)
end
