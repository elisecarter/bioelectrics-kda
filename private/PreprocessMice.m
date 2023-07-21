function data = PreprocessMice(data,UI)

for i = 1:length(data)
    
    disp(data{i}.MouseID)
    % interpolate thru poorly tracked datapoints (low confidence)
    data{i} = InterpBadTracking(data{i});

    % filtering and compute major kinematics
    data{i}.Sessions = ProcessReachEvents(data{i}.RawData,UI);

    % raw data indexed at reaches & saved in previous step - delete big
    % vectors
    fields = fieldnames(data{i}.RawData);
    data{i}.RawData = rmfield(data{i}.RawData,fields(6:15));

    % calculate expert reach
    data{i} = CalculateExpertReach(data{i});

    % compute correlation coefficients
    data{i} = CalculateCorrelationCoeff(data{i});

    % add meta data
    data{i} = AddMetaData(data{i});

    data{i}.Status = 'KinematicsExtracted';

    % save json and kda files
    OutputData(data{i}, UI.OutPath, UI)
end
