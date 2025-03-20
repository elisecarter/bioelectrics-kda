function ReviewFinalTrajectories(data)
% plots the average and individual reach events from the 
% final session for each mouse 

numMice = length(data);
fig = uifigure('Name','Final Session Reaches', ...
    'Position',[100 100 700 550],'Visible','off');
movegui(fig,'center')
ax = uiaxes(fig, Position=[75 75 550 450]);

% iterate through reaches from final session
for i = 1 : numMice
    session_data = data{i}.Sessions(end).InitialToMax;
    [avg_traj,ind_traj] = AverageTrajectory(session_data);

    numReaches = length(session_data); %number of reaches in final session
    for j = 1 : numReaches
        % plot each reach trajectory
        plot(ax,ind_traj.x(:,j), ind_traj.y(:,j),'Color','#918e8e','LineWidth',1)
        set(ax,'YDir','reverse') 
        hold(ax,"on")
    end

    % plot the pellet location
    plot(ax,0,0,'.','MarkerSize',200,'Color',"#65ad79")

    % plot the average reach trajectory of final session
    plot(ax,avg_traj(:,1),avg_traj(:,2),'LineWidth', 3 ,'Color','#000000')
    xlabel(ax,'X (mm)')
    ylabel(ax,'Y (mm)')
    set(ax, 'box', 'off')
    str1 = "Mouse ID: " + data{i}.MouseID;
    str2 = "Number of reaches: " + numReaches;
    str3 = "Session: " + data{i}.Sessions(end).SessionID;
    title(ax,[str1, str2, str3],'Interpreter', 'none')

    if i == numMice % see next mouse
        btn = uicontrol(fig,'Position', [515 30 100 22], 'String', 'Close', ...
            'Callback', 'uiresume(gcbf)');
    else % seeing last mouse
        btn = uicontrol(fig,'Position', [515 30 100 22], 'String', 'Next', ...
            'Callback', 'uiresume(gcbf)');
    end

    set(fig, 'visible', 'on'); % make figure visible after plotting
    uiwait(fig) % wait for button press
    set(fig, 'visible', 'off'); % make figure invisible
    hold(ax,"off") % remove plotted lines
end
