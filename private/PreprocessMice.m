function data = PreprocessMice(data,UI)

f = waitbar(0,'Please wait...'); % create wait bar
for i = 1:length(data)
    waitstr = "Preprocessing raw data... (" + data{i}.MouseID + ")";
    waitbar(i/length(data),f,waitstr);

    % interpolate thru poorly tracked datapoints (low confidence)
    data{i} = InterpBadTracking(data{i});
    
    % filtering and compute major kinematics
    data{i}.Sessions = ProcessReachEvents(data{i}.RawData);
    
    % raw data indexed at reaches & saved in previous step - delete big
    % vectors
    data{i} = rmfield(data{i},'RawData');
    
    % calculate expert reach 
    data{i} = CalculateExpertReach(data{i});
    
    % compute session means 
    data{i} = SessionMeans(data{i});

    % compute correlation coefficients
    data{i} = CalculateCorrelationCoeff(data{i});
    
    % change status from raw to kinematic extracted
    data{i}.Status = 'KinematicsExtracted';

    AddMetaData()

    % save json and kda files
    OutputData(data{i}, UI.OutPath, UI.extractSelections)
end
close(f)

