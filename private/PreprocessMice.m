function data = PreprocessMice(data)

f = waitbar(0,'Please wait...'); % create wait bar
for i = 1:length(data)
    waitstr = "Preprocessing raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);
    data{i}.Sessions = PreprocessReachEvents(data{i}.RawData);
    
    % raw data indexed at reaches & saved in previous step
    data{i} = rmfield(data{i},'RawData');

    % filter reaches using velocity threshold
    data{i} = FilterReaches(data{i});
    
    % calculate expert reach 
    data{i} = CalculateExpertReach(data{i});
    
    % compute session means 
    data{i} = SessionMeans(data{i});

    % compute correlation coefficients
    data{i} = CalculateCorrelationCoeff(data{i});
    
    % change status from raw to kinematic extracted
    data{i}.Status = 'KinematicsExtracted';
end
close(f)

ReviewFinalTrajectories(data)