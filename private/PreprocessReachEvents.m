function  [SessionData] = PreprocessReachEvents(RawData, user_selections)
% iterates through all reaches in each session and filters data to
% keep only reach events, calculates interpolated position/velocity,
% dynamic time warping of hand position, hand arc length,
% and normalizes dynamic time warped hand data to pellet location

% preallocate session structure
SessionData(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

for i = 1 : length(RawData) %iterate thru sessions
    session_raw = RawData(i);
    indx = table2array(session_raw.ReachIndexPairs); %pull out reach indices

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

    for j = 1 : height(indx) % j: reach event
        start_ind = indx(j,1); % start index
        max_ind = indx(j,2); % max index
        end_ind = indx(j,3); % end index

        % reach duration - 150 fps
        duration_max = (max_ind - start_ind) / 150; %sec
        duration_end = (end_ind - start_ind) / 150; %sec

        % index only reach events from raw data (start to end)
        init2end = structfun(@(x) x(start_ind:end_ind), session_raw, ...
            'UniformOutput', false);

        % store initial to end raw data
        SessionData(i).InitialToEnd(j).RawData = struct2table(init2end);

        % convert hand position units to mm
        init2end = ConvertPositionUnits(init2end);

        % euclidean matrix of raw hand position data [mm]
        tempeuc = [init2end.handX init2end.handY init2end.handZ];

        % index out initial to max euclidean matrix for further processing
        frames_max = max_ind - start_ind + 1; % number of frames from start to max
        tempeuc_max = tempeuc(1:frames_max,:);

        % hand relative to pellet - ALL POSITION DATA RELATIVE TO PELLET
        % FROM NOW ON
        relative_hand_end = tempeuc - SessionData(i).PelletLocation;
        relative_hand_max = tempeuc_max - SessionData(i).PelletLocation;

        % hand position smoothing
        smooth_hand_end = HandSmoothing(relative_hand_end);
        smooth_hand_max = HandSmoothing(relative_hand_max);

        % velocity - interpolated, absolute, and raw 
        [interpVel_max,absVel_max,rawVel_max] = CalculateVelocity(tempeuc_max);
        [interpVel_end,absVel_end,rawVel_end] = CalculateVelocity(tempeuc);

        % hand position interpolation
        [interp_hand_max] = InterpolatePosition(smooth_hand_max);
        [interp_hand_end] = InterpolatePosition(smooth_hand_end);

        % dynamic time warping (DTW)
        DTW_max = DynamicTimeWarping(smooth_hand_max);
        DTW_end = DynamicTimeWarping(smooth_hand_end);

        % arc length
        if user_selections.ArcLength == 1
            arc_length_max = arclength(DTW_max(:,1), DTW_max(:,2), DTW_max(:,3),'spline');
            arc_length_end = arclength(DTW_end(:,1), DTW_end(:,2), DTW_end(:,3),'spline');

            SessionData(i).InitialToMax(j).HandArcLength = arc_length_max;
            SessionData(i).InitialToEnd(j).HandArcLength = arc_length_end;
        end

        % DTW normalized to pellet
        DTW_norm_max = DTW_max - SessionData(i).PelletLocation;
        DTW_norm_end = DTW_end - SessionData(i).PelletLocation;

        % store initial to max data
        SessionData(i).InitialToMax(j).StartIndex = start_ind;
        SessionData(i).InitialToMax(j).EndIndex = max_ind;
        SessionData(i).InitialToMax(j).ReachDuration = duration_max;
        SessionData(i).InitialToMax(j).HandPositionNormalized = relative_hand_max;
        SessionData(i).InitialToMax(j).RawVelocity = rawVel_max;
        SessionData(i).InitialToMax(j).InterpolatedVelocity = interpVel_max;
        SessionData(i).InitialToMax(j).AbsoluteVelocity = absVel_max;
        SessionData(i).InitialToMax(j).InterpolatedHand = interp_hand_max;
        SessionData(i).InitialToMax(j).DTWHand = DTW_max;
        SessionData(i).InitialToMax(j).DTWHandNormalized = DTW_max;

        % store initial to end data
        SessionData(i).InitialToEnd(j).StartIndex = start_ind;
        SessionData(i).InitialToEnd(j).EndIndex = end_ind;
        SessionData(i).InitialToEnd(j).ReachDuration = duration_end;
        SessionData(i).InitialToEnd(j).HandPositionNormalized = relative_hand_end;
        SessionData(i).InitialToEnd(j).RawVelocity = rawVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedVelocity = interpVel_end;
        SessionData(i).InitialToEnd(j).AbsoluteVelocity = absVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedHand = interp_hand_end;
        SessionData(i).InitialToEnd(j).DTWHand = DTW_end;
        SessionData(i).InitialToEnd(j).DTWHandNormalized = DTW_end;

    end
end
