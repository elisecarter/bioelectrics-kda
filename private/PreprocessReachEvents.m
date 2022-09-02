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

    % remove unneeded fields
    session_raw = rmfield(session_raw,'Session');
    session_raw = rmfield(session_raw,'ReachIndexPairs');
    session_raw = rmfield(session_raw,'StimLogical');

    % remove impossibly short reaches
    end_duration = indx(:,3) - indx(:,1); %frames from start to end
    max_duration = indx(:,2) - indx(:,1); %from start to max
    too_short = end_duration < 5 | max_duration < 2;
    indx(too_short) = [];

    % preprocessing
    k = 1;
    for j = 1 : height(indx) %iterate thru session reaches
        reach_start = indx(j,1);
        init_frames = reach_start:reach_start+3; %first 3 frames of reach
        conf_xy = session_raw.pelletConfXY_10k(init_frames); % initial confidence
        conf_z = session_raw.pelletConfZ_10k(init_frames);
        % if pellet confidence high (> 90%) w/ 10k multiplier
        if mean(conf_xy) > 9000 && mean(conf_z) > 9000
            x = (session_raw.pelletX_100(init_frames)./900)'; %mm
            y = (session_raw.pelletY_100(init_frames)./900)'; %mm
            z = (session_raw.pelletZ_100(init_frames)./900)'; %mm
            pellet_loc(k,:) = mean([x,y,z]);
            k = k + 1;
        end
    end
    SessionData(i).PelletLocation = median(pellet_loc);

    for j = 1 : height(indx) % j: reach event
        start_ind = indx(j,1); % reach start index
        max_ind = indx(j,2); % reach max index
        end_ind = indx(j,3); % reach end index

        % reach duration
        duration_max = (max_ind - start_ind) / 150; %sec
        duration_end = (end_ind - start_ind) / 150; %sec

        % index only reach events from raw data - start to end
        init2end = structfun(@(x) x(start_ind:end_ind), session_raw, ...
            'UniformOutput', false);

        % store raw data
        SessionData(i).InitialToEnd(j).RawData = struct2table(init2end);
        %SessionData(i).InitialToMax(j).RawData = init2max;

        % convert hand position units to mm
        init2end = ConvertPositionUnits(init2end);

        % euclidean matrix of raw hand position data - mm
        tempeuc = [init2end.handX init2end.handY init2end.handZ];

        % index out initial to max euclidean matrix to pass into the
        % velocity function
        relative_max = max_ind - start_ind;
        tempeuc_max = tempeuc(1:relative_max,:);

        % hand relative to pellet
        relative_hand = tempeuc - SessionData(i).PelletLocation;

        % hand position smoothing - should this be used to find hand
        % relative to pellet?
        smooth_hand_end = HandSmoothing(tempeuc);
        smooth_hand_max = HandSmoothing(tempeuc_max);

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
        SessionData(i).InitialToMax(j).HandPosition = relative_hand(1:relative_max);
        SessionData(i).InitialToMax(j).RawVelocity = rawVel_max;
        SessionData(i).InitialToMax(j).InterpolatedVelocity = interpVel_max;
        SessionData(i).InitialToMax(j).AbsoluteVelocity = absVel_max;
        SessionData(i).InitialToMax(j).InterpolatedHand = interp_hand_max;
        SessionData(i).InitialToMax(j).DTWHand = DTW_max;
        SessionData(i).InitialToMax(j).DTWHandNormalized = DTW_norm_max;

        % store initial to end data
        SessionData(i).InitialToEnd(j).StartIndex = start_ind;
        SessionData(i).InitialToEnd(j).EndIndex = end_ind;
        SessionData(i).InitialToEnd(j).ReachDuration = duration_end;
        SessionData(i).InitialToEnd(j).HandPosition = relative_hand;
        SessionData(i).InitialToEnd(j).RawVelocity = rawVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedVelocity = interpVel_end;
        SessionData(i).InitialToEnd(j).AbsoluteVelocity = absVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedHand = interp_hand_end;
        SessionData(i).InitialToEnd(j).DTWHand = DTW_end;
        SessionData(i).InitialToEnd(j).DTWHandNormalized = DTW_norm_end;

    end
end
