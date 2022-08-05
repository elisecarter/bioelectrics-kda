function  [SessionData] = PreprocessReachEvents(RawData)
% iterates through all reaches in each session and filters data to 
% keep only reach events, calculates interpolated position/velocity, 
% dynamic time warping of hand position, hand arc length, 
% and normalizes dynamic time warped hand data to pellet location

% preallocate session structure
SessionData(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

for i = 1 : length(RawData) %iterate thru sessions
    session_raw = RawData(i);
    indx = table2array(session_raw.ReachIndexPairs);%pull out reach indices

    % save session level info before deleting so we can use structfun
    SessionData(i).SessionID = session_raw.Session;
    SessionData(i).StimLogical = session_raw.StimLogical;
    
    % remove unneeded fields
    session_raw = rmfield(session_raw,'Session');
    session_raw = rmfield(session_raw,'ReachIndexPairs');
    session_raw = rmfield(session_raw,'StimLogical');

    % remove impossibly short reaches
    end_duration = indx(:,3) - indx(:,1); %frames
    max_duration = indx(:,2) - indx(:,1);
    too_short = end_duration < 5 | max_duration < 2;
    indx(too_short) = [];

    % preprocessing
    k = 1;
    for j = 1 : height(indx) %iterate thru session reaches
        reach_start = indx(j,1);
        % find pellet location
        init_frames = reach_start:reach_start+3; %first 3 frames of reach
        conf_xy = session_raw.pelletConfXY_10k(init_frames);
        conf_z = session_raw.pelletConfZ_10k(init_frames);
        % if pellet confidence high (> 90%)
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
        startInd = indx(j,1); % reach start index
        maxInd = indx(j,2); % reach max index
        endInd = indx(j,3); % reach end index

        % index only reach events
        init2max = structfun(@(x) x(startInd:maxInd), session_raw, ...
            'UniformOutput', false);
        init2end = structfun(@(x) x(startInd:endInd), session_raw, ...
            'UniformOutput', false);
        
        % store raw data
        SessionData(i).InitialToEnd(j).RawData = init2end; 
        SessionData(i).InitialToMax(j).RawData = init2max; 

        % convert hand position units to mm
        init2max = ConvertPositionUnits(init2max);
        init2end = ConvertPositionUnits(init2end);

        % euclidean matrix of raw hand position data - mm
        tempeuc_max =[init2max.handX' init2max.handY' init2max.handZ'];
        tempeuc_end =[init2end.handX' init2end.handY' init2end.handZ']; 

        % velocity - interpolated, absolute, and raw
        [interpVel_max,absVel_max,rawVel_max] = CalculateVelocity(tempeuc_max);
        [interpVel_end,absVel_end,rawVel_end] = CalculateVelocity(tempeuc_end);

        % hand position smoothing
        smooth_euc_max = HandSmoothing(tempeuc_max);
        smooth_euc_end = HandSmoothing(tempeuc_end);

        % hand position interpolation
        [interp_hand_max] = InterpolatePosition(smooth_euc_max);
        [interp_hand_end] = InterpolatePosition(smooth_euc_end);

        % dynamic time warping (DTW)
        [DTW_euc_max,arc_length_max] = DynamicTimeWarping(smooth_euc_max);
        [DTW_euc_end,arc_length_end] = DynamicTimeWarping(smooth_euc_end);

        % DTW normalized to pellet
        DTW_norm_max = DTW_euc_max - SessionData(i).PelletLocation;
        DTW_norm_end = DTW_euc_end - SessionData(i).PelletLocation;

        % store initial to max data
        SessionData(i).InitialToMax(j).RawVelocity = rawVel_max;
        SessionData(i).InitialToMax(j).InterpolatedVelocity = interpVel_max;
        SessionData(i).InitialToMax(j).AbsoluteVelocity = absVel_max;
        SessionData(i).InitialToMax(j).InterpolatedHand = interp_hand_max;
        SessionData(i).InitialToMax(j).DTWHand = DTW_euc_max;
        SessionData(i).InitialToMax(j).DTWHandNormalized = DTW_norm_max;
        SessionData(i).InitialToMax(j).HandArcLength = arc_length_max;

        % store initial to end data
        SessionData(i).InitialToEnd(j).RawVelocity = rawVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedVelocity = interpVel_end;
        SessionData(i).InitialToEnd(j).AbsoluteVelocity = absVel_end;
        SessionData(i).InitialToEnd(j).InterpolatedHand = interp_hand_end;
        SessionData(i).InitialToEnd(j).DTWHand = DTW_euc_end;
        SessionData(i).InitialToEnd(j).DTWHandNormalized = DTW_norm_end;
        SessionData(i).InitialToEnd(j).HandArcLength = arc_length_end;
    end
end
