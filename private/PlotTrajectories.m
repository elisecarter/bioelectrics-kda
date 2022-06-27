function PlotTrajectories(mouse_data,path)

figure("Visible","on") %change visibilty

for i = 1:length(mouse_data.Sessions) % num sessions for this mouse
    session_data = mouse_data.Sessions(i);
    session_str = session_data.SessionID{1}; %this will break when I take session ID out of cell
    [avg_traj,x,y,~] = CalculateAvgTrajectory(session_data.InitialToMax);
    plot(x,y,'Color','#918e8e')
    hold on
    plot(avg_traj(:,1),avg_traj(:,2),'LineWidth', 1.5 ,'Color','#000000')

    xlabel('x (mm)')
    ylabel('y (mm)')
    str1 = sprintf('Mouse ID: %s',mouse_data.MouseID);
    str2 = sprintf('Number of reaches: %d',length(session_data.InitialToMax));
    str3 = sprintf('Session: %s',session_str); 
    title({str1;str2;str3},'Interpreter','none')
    
    saveas(gcf,fullfile(path,session_str),'png')

    clf
end
