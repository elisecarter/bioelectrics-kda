function PlotTrajectories(mouse_data,path)

p = figure("Visible","off","HandleVisibility","on"); 

for i = 1:length(mouse_data.Sessions) % num sessions for this mouse
    p_ax = axes(p);
    session_data = mouse_data.Sessions(i);
    session_str = session_data.SessionID{1}; %this will break when I take session ID out of cell
    [avg_traj,stats] = AverageTrajectory(session_data.InitialToMax);
    plot(p_ax,stats.x,stats.y,'Color','#918e8e')
    hold on
    plot(p_ax,avg_traj(:,1),avg_traj(:,2),'LineWidth', 1.5 ,'Color','#000000')

    xlabel('x (mm)')
    ylabel('y (mm)')
    str1 = sprintf('Mouse ID: %s',mouse_data.MouseID);
    str2 = sprintf('Number of reaches: %d',length(session_data.InitialToMax));
    str3 = sprintf('Session: %s',session_str); 
    title({str1;str2;str3},'Interpreter','none')
    
    saveas(p,fullfile(path,session_str),'png')
   
    clf(p)
end
