function data = PreprocessMice(data)

f = waitbar(0,'Please wait...'); % create wait bar
for i = 1:length(data)
    waitstr = "Preprocessing raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);
    data{i}.Sessions = PreprocessReachEvents(data{i}.RawData);
    
    % raw data indexed at reaches & saved in previous step
    data{i} = rmfield(data{i},'RawData');
    
    % calculate expert reach 
    data{i} = CalculateExpertReach(data{i});
    
    % compute session means 
    data{i} = SessionMeans(data{i});

    data{i}.Status = 'KinematicsExtracted';
end
close(f)

ReviewFinalTrajectories(data)