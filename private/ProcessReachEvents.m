function  [SessionData] = ProcessReachEvents(RawData)
% iterates through all reaches in each session and filters data to
% keep only reach events, calculates interpolated position/velocity,
% dynamic time warping of hand position, hand arc length,
% and normalizes dynamic time warped hand data to pellet location

% preallocate session structure
SessionData(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

vel_threshold = 1000; %mm/sec - for filtering by absolute velocity
interp_threshold = .5; %percent of datapoints that were poorly tracked (<90 confidence)

for i = 1 : length(RawData) %iterate thru sessions
    session_raw = RawData(i);
    indx = table2array(session_raw.ReachIndexPairs); %pull out reach indices

    % pull out success rate from raw data
    num_success = sum(strcmp(session_raw.Behaviors,'success'));
    num_reaches = length(session_raw.Behaviors);
    SessionData(i).PercentSuccess = num_success/num_reaches;

    % save session level info before deleting so we can use structfun
    SessionData(i).SessionID = session_raw.Session;
    SessionData(i).StimLogical = session_raw.StimLogical;
    SessionData(i).Behavior = session_raw.Behaviors;
    SessionData(i).EndCategory = session_raw.EndCategory;

    % remove unneeded fields
    session_raw = rmfield(session_raw,'Session');
    session_raw = rmfield(session_raw,'ReachIndexPairs');
    session_raw = rmfield(session_raw,'StimLogical');
    session_raw = rmfield(session_raw,'Behaviors');
    session_raw = rmfield(session_raw,'EndCategory');

    % remove impossibly short reaches
    end_duration = indx(:,3) - indx(:,1); %frames from start to end
    max_duration = indx(:,2) - indx(:,1); %from start to max
    too_short = end_duration < 5 | max_duration < 2;
    indx(too_short,:) = [];
    if any(too_short==1)
        SessionData(i).StimLogical(too_short) = [];
        SessionData(i).Behavior(too_short) = [];
        SessionData(i).EndCategory(too_short) = [];
    end

    % preprocessing
    k = 1;
    for j = 1 : height(indx) %iterate thru session reaches
        reach_start = indx(j,1);
        init_frames = reach_start:reach_start+3; %first 3 frames of reach
        conf_xy = session_raw.pelletConfXY_10k(init_frames); % initial confidence
        conf_z = session_raw.pelletConfZ_10k(init_frames);
        % if pellet confidence high (> 90%) w/ 10k multiplier
        if mean(conf_xy) > 9000 && mean(conf_z) > 9000
            pellet_loc(k,1) = mean(session_raw.pelletX_100(init_frames)./900); %mm
            pellet_loc(k,2) = mean(session_raw.pelletY_100(init_frames)./900); %mm
            pellet_loc(k,3) = mean(session_raw.pelletZ_100(init_frames)./900); %mm
            k = k + 1;
        end
    end
    SessionData(i).PelletLocation = median(pellet_loc);
    
    num_reaches = height(indx);
    deleted_log = zeros(1, num_reaches); % initialize for use for filtering
    for j = 1 : num_reaches % j: reach event
        k = j - sum(deleted_log); % subtract total # of reaches deleted to adjust index for storage
        
        start_ind = indx(j,1); % start index
        max_ind = indx(j,2); % max index
        end_ind = indx(j,3); % end index

        % reach duration - 150 fps
        duration_max = (max_ind - start_ind) / 150; %sec
        duration_end = (end_ind - start_ind) / 150; %sec

        % index only reach events from raw data (start to max/end)
        init2max = structfun(@(x) x(start_ind:max_ind), session_raw, ...
            'UniformOutput', false);
        init2end = structfun(@(x) x(start_ind:end_ind), session_raw, ...
            'UniformOutput', false);

        if max_ind > end_ind
            SessionData(i).StimLogical(k) = [];
            SessionData(i).Behavior(k) = [];
            SessionData(i).EndCategory(k) = [];    
            deleted_log(j) = true; % mark this iteration as deleted
            continue
        end

        % if percent of poorly tracked data points in this reach is greater
        % than the threshold, delete this reach
        conf = init2max.handConfXY_10k./10000;
        percent_poor = sum(conf<0.9)/length(conf); %percent poorly tracked datapts 
        if percent_poor > interp_threshold
            SessionData(i).StimLogical(k) = [];
            SessionData(i).Behavior(k) = [];
            SessionData(i).EndCategory(k) = [];    
            deleted_log(j) = true; % mark this iteration as deleted
            continue
        end

        % convert hand position units to mm
        init2max = ConvertPositionUnits(init2max);
        init2end = ConvertPositionUnits(init2end);

        % euclidean matrix of raw hand position data in mm
        tempeuc = [init2end.handX init2end.handY init2end.handZ];

        % index out initial to max euclidean matrix for further processing
        frames_max = max_ind - start_ind + 1; % number of frames from start to max
        tempeuc_max = tempeuc(1:frames_max,:);

        % velocity - interpolated, absolute, and raw in mm/sec
        [interpVel_max,absVel_max,rawVel_max] = CalculateVelocity(tempeuc_max);
        [interpVel_end,absVel_end,rawVel_end] = CalculateVelocity(tempeuc);
        
        % if absolute velocity is greater than thresh, delete this reach
        % done here to minimize run time - DTW and arclength computations are expensive)
%         if any(absVel_max > vel_threshold)
%             SessionData(i).StimLogical(k) = [];
%             SessionData(i).Behavior(k) = [];
%             SessionData(i).EndCategory(k) = [];    
%             deleted_log(j) = true; % mark this iteration as deleted
%             continue
%         end

        % hand relative to pellet - POSITION DATA RELATIVE TO PELLET
        % FROM NOW ON
        relative_hand_end = tempeuc - SessionData(i).PelletLocation;
        relative_hand_max = tempeuc_max - SessionData(i).PelletLocation;

        % hand position smoothing
        smooth_hand_end = HandSmoothing(relative_hand_end);
        smooth_hand_max = HandSmoothing(relative_hand_max);

        % hand position interpolation
        [interp_hand_max] = InterpolatePosition(smooth_hand_max);
        [interp_hand_end] = InterpolatePosition(smooth_hand_end);

        % dynamic time warping (DTW)
        [DTW_max, flagMax] = DynamicTimeWarping(smooth_hand_max);
        [DTW_end, flagEnd] = DynamicTimeWarping(smooth_hand_end);

        if flagMax || flagEnd
            SessionData(i).StimLogical(k) = [];
            SessionData(i).Behavior(k) = [];
            SessionData(i).EndCategory(k) = [];    
            deleted_log(j) = true; % mark this iteration as deleted
            continue
        end

        % arc length
        % 3D path length
        arcLength3D_max = arclength(DTW_max(:,1), DTW_max(:,2), DTW_max(:,3),'spline');
        arcLength3D_end = arclength(DTW_end(:,1), DTW_end(:,2), DTW_end(:,3),'spline');
        
        % XY path length
        arcLengthXY_max = arclength(DTW_max(:,1), DTW_max(:,2),'spline');
        arcLengthXY_end = arclength(DTW_end(:,1), DTW_end(:,2),'spline');
        
        % XZ path length
        arcLengthXZ_max = arclength(DTW_max(:,1), DTW_max(:,3),'spline');
        arcLengthXZ_end = arclength(DTW_end(:,1), DTW_end(:,3),'spline');

        % store initial to max data
        SessionData(i).InitialToEnd(k).RawData = struct2table(init2max);
        SessionData(i).InitialToMax(k).StartIndex = start_ind;
        SessionData(i).InitialToMax(k).EndIndex = max_ind;
        SessionData(i).InitialToMax(k).ReachDuration = duration_max;
        SessionData(i).InitialToMax(k).HandPositionNormalized = relative_hand_max;
        SessionData(i).InitialToMax(k).RawVelocity = rawVel_max;
        SessionData(i).InitialToMax(k).InterpolatedVelocity = interpVel_max;
        SessionData(i).InitialToMax(k).AbsoluteVelocity = absVel_max;
        SessionData(i).InitialToMax(k).InterpolatedHand = interp_hand_max;
        SessionData(i).InitialToMax(k).DTWHand = DTW_max;
        SessionData(i).InitialToMax(k).DTWHandNormalized = DTW_max;
        SessionData(i).InitialToMax(k).PathLength3D = arcLength3D_max;
        SessionData(i).InitialToMax(k).PathLengthXY = arcLengthXY_max;
        SessionData(i).InitialToMax(k).PathLengthXZ = arcLengthXZ_max;

        % store initial to end data
        SessionData(i).InitialToEnd(k).RawData = struct2table(init2end);
        SessionData(i).InitialToEnd(k).StartIndex = start_ind;
        SessionData(i).InitialToEnd(k).EndIndex = end_ind;
        SessionData(i).InitialToEnd(k).ReachDuration = duration_end;
        SessionData(i).InitialToEnd(k).HandPositionNormalized = relative_hand_end;
        SessionData(i).InitialToEnd(k).RawVelocity = rawVel_end;
        SessionData(i).InitialToEnd(k).InterpolatedVelocity = interpVel_end;
        SessionData(i).InitialToEnd(k).AbsoluteVelocity = absVel_end;
        SessionData(i).InitialToEnd(k).InterpolatedHand = interp_hand_end;
        SessionData(i).InitialToEnd(k).DTWHand = DTW_end;
        SessionData(i).InitialToEnd(k).DTWHandNormalized = DTW_end;
        SessionData(i).InitialToEnd(k).PathLength3D = arcLength3D_end;
        SessionData(i).InitialToEnd(k).PathLengthXY = arcLengthXY_end;
        SessionData(i).InitialToEnd(k).PathLengthXZ = arcLengthXZ_end;
    end
end