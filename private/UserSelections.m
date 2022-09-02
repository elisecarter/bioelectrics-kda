function user_selections = UserSelections()

% Arc length? This takes a long time
quest = 'Would you like to compute reach arc lengths? This increases computing time.';
dlgtitle = 'Compute Arc Length Option';
btn1 = 'Yes';
btn2 = 'No';
defbtn = 'Yes';
answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn);

if strcmpi(answer,btn1) % user selects yes
    user_selections.ArcLength = 1;
else
    user_selections.ArcLength = 0;
end

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