function PlotTrajectories(data)
% this function plots the average and individual reach events from the 
% final session for each mouse 

numMice = length(data);
fig = uifigure('Name','Final Session Reaches', ...
    'Position',[100 100 700 550],'Visible','off');
movegui(fig,'center')
ax = uiaxes(fig, Position=[75 75 550 450]);

% iterate through reaches from final session
for i = 1 : numMice
    for j = 1 : length(data(i).Sessions(end).InitialToEnd)
        tempX = data(i).Sessions(end).InitialToMax(j).InterpolatedHandEuclidean_100(:,1);
        tempY = data(i).Sessions(end).InitialToMax(j).InterpolatedHandEuclidean_100(:,2);

        %9 pixels per mm, stored data from CLARA is multiplied by 100
        handX(:,j) = tempX./900;
        handY(:,j) = tempY./900;
    end

    numReaches = size(handX,2); %number of reaches in final session
    for k = 1 : numReaches
        % average reaches elementwise (x,y)
        avgReach(k,1) = mean(handX(k,:));
        avgReach(k,2) = mean(handY(k,:));

        % plot each reach trajectory
        plot(ax,handX(:,k), handY(:,k),'Color','#918e8e')
        hold(ax,"on")
    end

    % plot the average reach trajectory of final session
    plot(ax,avgReach(:,1), avgReach(:,2),'LineWidth', 1.5 ,'Color','#000000')
    xlabel(ax,'x (mm)')
    ylabel(ax,'y (mm)')
    str1 = "Mouse ID: " + data(i).MouseID;
    str2 = "Number of reaches: " + numReaches;
    str3 = "Session: " + data(i).Sessions(end).SessionID;
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
