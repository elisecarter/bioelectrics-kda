function UI = UserSelections(UI,switch_exp)
% creates stucture to hold user selections for processing options

switch switch_exp
    case 'ExtractKinematics'
        % Save session trajectory plots?
        quest = 'Would you like save session trajectory plots?';
        dlgtitle = 'Trajectory Plot Save Option';
        btn1 = 'Yes';
        btn2 = 'No';
        defbtn = 'Yes';
        answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
        if strcmpi(answer,btn1) % user selects yes
            UI.SavePlots = 1;

        % file type

        else
            UI.SavePlots = 0;
        end

        % reach type for sessions means (max, end or both)
        quest = 'What reach type would you like to use to calculate session means?';
        dlgtitle = 'Session Mean Options';
        btn1 = 'reachMax';
        btn2 = 'reachEnd';
        btn3 = 'Both';
        defbtn = 'reachMax';
        answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,defbtn);
        if strcmpi(answer,btn1) % use reachMax
            UI.ReachType = 'max';
        elseif strcmpi(answer,btn2) % use reachEnd
            UI.ReachType = 'end';
        elseif strcmpi(answer,btn3) % use both
            UI.ReachType = 'both';
        end

         % filter by velocity?
%          if yes
%              threshold = 
%          end
end