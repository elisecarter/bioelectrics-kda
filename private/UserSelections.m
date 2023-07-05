function user_selections = UserSelections(switch_exp)
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
            user_selections.SavePlots = 1;

            % file type

        else
            user_selections.SavePlots = 0;
        end

        % reach type for sessions means (max, end or both)
        quest = 'What reach type would you like to calculate session means for?';
        dlgtitle = 'Session Mean Options';
        btn1 = 'reachMax';
        btn2 = 'reachEnd';
        btn3 = 'Both';
        defbtn = 'reachMax';
        answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,defbtn);
        if strcmpi(answer,btn1) % use reachMax
            user_selections.ReachType = 1;
        elseif strcmpi(answer,btn2) % use reachEnd
            user_selections.ReachType = 2;
        elseif strcmpi(answer,btn3) % use both
            user_selections.ReachType = 3;
        end

         % filter by velocity?
%          if yes
%              threshold = 
%          end
end