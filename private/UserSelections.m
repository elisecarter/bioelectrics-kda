function user_selections = UserSelections(switch_exp)

switch switch_exp

    case 'ExtractKinematics'
%         % Arc length? This takes a long time
%         quest = 'Would you like to compute reach arc lengths? This increases computing time.';
%         dlgtitle = 'Compute Arc Length Option';
%         btn1 = 'Yes';
%         btn2 = 'No';
%         defbtn = 'Yes';
%         answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);
% 
%         if strcmpi(answer,btn1) % user selects yes
%             user_selections.ArcLength = 1;
%         else
%             user_selections.ArcLength = 0;
%         end

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

    case 'Correlations'
        list = {'','H2','H20'};

        [indx,tf] = listdlg('ListString',list);

end