function UI = UserSelections(UI,switch_exp)
% creates stucture to hold user selections for processing options

switch switch_exp
    case 'ExtractKinematics'
        % Save session trajectory plots?
        quest = 'Would you like save session trajectory plots?';
        dlgtitle = 'Trajectory Plot Save Option';
        btn1 = 'yes';
        btn2 = 'no';
        defbtn = 'yes';
        answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
        if strcmpi(answer,btn1) % user selects yes
            UI.SavePlots = 1;

            % plot reach max or end
            quest = 'What reach type would you like to plot?';
            dlgtitle = 'Trajectory Plot Reach Type';
            btn1 = 'reachMax';
            btn2 = 'reachEnd';
            defbtn = 'reachMax';
            answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
            if strcmpi(answer,btn2) % use reachEnd
                UI.PlotReach = 'end';
            else % use reachMax
                UI.PlotReach = 'max';
            end

            % file type
            quest = 'What file type would you like to save plots as?';
            dlgtitle = 'Trajectory Plot File Type';
            btn1 = '.png';
            btn2 = '.eps';
            btn3 = 'both';
            defbtn = '.png';
            answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,defbtn);
            if strcmpi(answer,btn2) 
                UI.PlotFileType = '.eps';
            elseif strcmp(answer,btn3)
                UI.PlotFileType = 'both';
            else % png
                UI.PlotFileType = '.png';
            end
        else
            UI.SavePlots = 0;
        end

        

        % filter by velocity?
        quest = 'Would you like to filter reaches by absolute velocity?';
        dlgtitle = 'Velocity Filtering Option';
        btn1 = 'yes';
        btn2 = 'no';
        defbtn = 'no';
        answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
        if strcmpi(answer,btn1) %yes
            % ask for threshold
            prompt = 'Enter velocity threshold (mm/sec):';
            dlgtitle = 'Velocity Threshold Input';
            dims = [1 60];
            definput = {'1000'};
            thresh = inputdlg(prompt,dlgtitle,dims,definput);
            UI.VelocityTresh = str2double(thresh{1});
        end


    case 'PlotIndivTrajectories'
        % plot reach max or end
        quest = 'What reach type would you like to plot?';
        dlgtitle = 'Trajectory Plot Reach Type';
            btn1 = 'reachMax';
            btn2 = 'reachEnd';
            defbtn = 'reachMax';
            answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
            if strcmpi(answer,btn2) % use reachEnd
                UI.PlotReach = 'end';
            else % use reachMax
                UI.PlotReach = 'max';
            end

            % file type
            quest = 'What file type would you like to save plots as?';
            dlgtitle = 'Inidividual Trajectory Plots File Type';
            btn1 = '.png';
            btn2 = '.eps';
            btn3 = 'both';
            defbtn = '.png';
            answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,defbtn);
            if strcmpi(answer,btn2) 
                UI.PlotFileType = '.eps';
            elseif strcmp(answer,btn3)
                UI.PlotFileType = 'both';
            else % png
                UI.PlotFileType = '.png';
            end

    case 'OutputSessionMeans'
        % reach type for sessions means (max, end or both)
        quest = 'What reach type would you like to use to calculate session means?';
        dlgtitle = 'Session Mean Options';
        btn1 = 'reachMax';
        btn2 = 'reachEnd';
        defbtn = 'reachMax';
        answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
        if strcmpi(answer,btn2) % use reachEnd
            UI.ReachType = 'end';
        else % reachMax
            UI.ReachType = 'max';
        end

end