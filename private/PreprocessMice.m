function data = PreprocessMice(data,user_selections)

f = waitbar(0,'Please wait...'); % create wait bar
for i = 1:length(data)
    waitstr = "Preprocessing raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);
    data{i}.Sessions = PreprocessReachEvents(data{i}.RawData,user_selections);
    
    % raw data indexed at reaches & saved in previous step
    data{i} = rmfield(data{i},'RawData');
    
    % expert reach is mean trajectory of successful reaches on the final day of training
    data{i} = CalculateExpertReach(data{i});
    
    % compute session means 
    data{i} = SessionMeans(data{i});

    data{i}.Status = 'Kinematics_Extracted';
end
close(f)

ReviewFinalTrajectories(data)