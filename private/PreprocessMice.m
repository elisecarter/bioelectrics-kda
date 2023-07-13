function data = PreprocessMice(data,UI)

for i = 1:length(data)
    % interpolate thru poorly tracked datapoints (low confidence)
    data{i} = InterpBadTracking(data{i});

    % filtering and compute major kinematics
    data{i}.Sessions = ProcessReachEvents(data{i}.RawData,UI);

    % raw data indexed at reaches & saved in previous step - delete big
    % vectors
    data{i} = rmfield(data{i},'RawData');

    %if ~isempty(data{i}.Sessions.InitialToMax)
    % calculate expert reach
    data{i} = CalculateExpertReach(data{i});
    %end

    %if isfield(data{i},'')
    %if ~isempty(data{i}.ExpertReach)
    % compute correlation coefficients
    data{i} = CalculateCorrelationCoeff(data{i});
    %end
    % end

    % change status from raw to kinematic extracted
    data{i}.Status = 'KinematicsExtracted';

    data{i} = AddMetaData(data{i});

    %if ~isempty(data{i}.Sessions.InitialToMax)
    % save json and kda files
    OutputData(data{i}, UI.OutPath, UI)
    %end
end
