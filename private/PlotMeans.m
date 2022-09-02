function PlotMeans(data, OUTpath)

numMice = length(data);

fig = uifigure('Name','Final Session Reaches', ...
    'Position',[100 100 700 550],'Visible','off');
movegui(fig,'center')
ax = uiaxes(fig, Position=[75 75 550 450]);

for i = 1 : numMice

    % put session averages into vectors
    velocity = [data{i}.Sessions.MeanVelocity];

    % plot the average reach trajectory of final session
    bar(velocity)

    str1 = "Mouse ID: " + data{i}.MouseID;
    title(ax,str1,'Interpreter', 'none')

    if i == numMice % see next mouse
        btn = uicontrol(fig,'Position', [515 30 100 22], 'String', 'Close', ...
            'Callback', 'uiresume(gcbf)');
    else % seeing last mouse
        btn = uicontrol(fig,'Position', [515 30 100 22], 'String', 'Next', ...
            'Callback', 'uiresume(gcbf)');
    end

    set(fig, 'visible', 'on'); % make figure visible after plotting

    saveas(fig,fullfile(OUTpath,),'png')

    uiwait(fig) % wait for button press
    set(fig, 'visible', 'off'); % make figure invisible
    hold(ax,"off") % remove plotted lines
end
