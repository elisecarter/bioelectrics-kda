function PlotTrajectories(data)
% this function plots the average and individual reach events from the 
% final session for each mouse 

numMice = length(data);
fig = uifigure("Position",[100 100 700 550],'Visible','off');
movegui(fig,'center')
ax = uiaxes(fig, Position=[75 75 550 400]);

%fig = uifigure('visible','on'); %turn off
%faxes = axes;

% iterate through reaches from final session
for i = 1 : numMice
    for j = 1 : length(data(i).Sessions(end).InitialToEnd)
        tempX = data(i).Sessions(end).InitialToEnd(j).InterpolatedHandX_100;
        tempY = data(i).Sessions(end).InitialToEnd(j).InterpolatedHandY_100;

        %9 pixels per mm, stored data from CLARA is multiplied by 100
        handX(:,j) = tempX./900;
        handY(:,j) = tempY./900;
    end

    numReaches = size(handX,2); %number of reaches in final session
    %hold off %remove previous trajector MOVE THIS

    for k = 1 : numReaches
        % average reaches elementwise (x,y)
        avgReach(k,1) = mean(handX(k,:));
        avgReach(k,2) = mean(handY(k,:));

        % plot each reach trajectory
        plot(ax,handX(:,k), handY(:,k),'Color','#918e8e')
        hold(ax,"on")
    end

    % plot the average reach trajectory of final session
    plot(ax,avgReach(:,1), avgReach(:,2),'LineWidth', 2 ,'Color','#000000')
    xlabel(ax,'x (mm)')
    ylabel(ax,'y (mm)')
    str = "Final session reaches: " + data(i).MouseID;
    title(ax,str)

    if i == numMice
        btn = uicontrol(fig,'Position', [500 30 100 22], 'String', 'Close', ...
            'Callback', 'uiresume(gcbf)');
    else
        btn = uicontrol(fig,'Position', [500 30 100 22], 'String', 'Next', ...
            'Callback', 'uiresume(gcbf)');
    end

    set(fig, 'visible', 'on');
    uiwait(fig)
    set(fig, 'visible', 'off');
    hold(ax,"off")
end
