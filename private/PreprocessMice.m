function data = PreprocessMice(data,UI)

for i = 1:length(data)
    
    disp(data{i}.MouseID)
    % interpolate thru poorly tracked datapoints (low confidence)
    data{i} = InterpBadTracking(data{i});

    % filtering and compute major kinematics
    data{i}.Sessions = ProcessReachEvents(data{i}.RawData,UI);

    % calculate expert reach
    data{i} = CalculateExpertReach(data{i});

    % compute correlation coefficients
    data{i} = CalculateCorrelationCoeff(data{i});

    % add meta data
    data{i} = AddMetaData(data{i});

    % raw data indexed at reaches & saved in session structs 
    data{i} = rmfield(data{i},'RawData');

    data{i}.Status = 'KinematicsExtracted';

    % save kda files
    OutputData(data{i}, UI.OutPath, UI)
end
