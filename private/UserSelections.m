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
        else
            user_selections.SavePlots = 0;
        end

end