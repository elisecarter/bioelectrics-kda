function  [Session] = PreprocessData(RawData)
% filters data to keep only reach events,
% calculates interpolated position/velocity, UPDATE

% add a function to select number of interpolated pts?

% preallocate session struct
Session(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

for i = 1 : length(RawData) % i: session
    sessionData = RawData(i);
    indx = table2array(sessionData.ReachIndexPairs);

    %preallocate structs to hold data indexed at reach events for each session
    init2max = struct('handX_100',[],'handY_100',[],'handZ_100',[], ...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[], ...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[], ...
        'pelletConfZ_10k',[]);
    init2end = struct('handX_100',[],'handY_100',[],'handZ_100',[], ...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[], ...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[], ...
        'pelletConfZ_10k',[]);

    % save this info before deleting so we can use structfun
    Session(i).SessionID = sessionData.Session;
    Session(i).StimLogical = sessionData.StimLogical;

    % remove uneeded fields
    sessionData = rmfield(sessionData, 'Session');
    sessionData = rmfield(sessionData, 'ReachIndexPairs');
    sessionData = rmfield(sessionData, 'StimLogical');

    for j = 1 : height(indx) % j: reach event 
        startInd = indx(j,1); % reach start index
        maxInd = indx(j,2); % reach max index
        endInd = indx(j,3); % reach end index

        % index only reach events
        init2max = structfun(@(x) x(startInd:maxInd), sessionData, ...
            'UniformOutput', false);
        Session(i).InitialToMax(j).RawData = init2max; %store

        init2end = structfun(@(x) x(startInd:endInd), sessionData, ...
            'UniformOutput', false);
        Session(i).InitialToEnd(j).RawData = init2end; %store

        % create euclidean matrix
        tempeuc_max =[init2max.handX_100' init2max.handY_100' init2max.handZ_100'];
        tempeuc_end =[init2end.handX_100' init2end.handY_100' init2end.handZ_100'];

        % velocity preprocessing - initial to max (pixels/frame)
        for k = 1 : height(tempeuc_max) - 1
            absVel_max(k,1)=norm(tempeuc_max(k+1,:) - tempeuc_max(k,:));
            interpVel_max(k,:)=tempeuc_max(k+1,:) - tempeuc_max(k,:); %(x, y, z)
            
        end
        interpVel_max(:,2)=interpVel_max(:,2)*-1;
        samplePts=1:size(interpVel_max,1);
        temp=(length(samplePts)-1)/99;
        queryPts=1:temp:length(samplePts); % interpolate to have 100 pts
        interpVel_max=interp1(samplePts,interpVel_max,queryPts,'pchip');
        absVel_max=interp1(samplePts,absVel_max,queryPts,'pchip')';

        % velocity preprocessing - intitial to end (pixels/frame)
        for k = 1 : height(tempeuc_end) - 1
            absVel_end(k,1)=norm(tempeuc_end(k+1,:) - tempeuc_end(k,:)); 
            interpVel_end(k,:)=tempeuc_end(k+1,:) - tempeuc_end(k,:); %(x, y, z)
        end
        interpVel_end(:,2) = interpVel_end(:,2)*-1;
        samplePts = 1:size(interpVel_end,1);
        temp = (length(samplePts)-1)/99;
        queryPts = 1:temp:length(samplePts); % interpolate to have 100 pts
        interpVel_end = interp1(samplePts,interpVel_end,queryPts,'pchip'); 
        absVel_end = interp1(samplePts,absVel_end,queryPts,'pchip')';
        
        % hand position preprocessing - initial to max
        samplePts = 1:length(init2max.handX_100);
        temp = (length(samplePts)-1)/99;
        queryPts = 1:temp:length(samplePts);
        interpX_max = interp1(samplePts,init2max.handX_100,queryPts,'pchip')';
        interpY_max = interp1(samplePts,init2max.handY_100,queryPts,'pchip')';
        interpZ_max = interp1(samplePts,init2max.handZ_100,queryPts,'pchip')';

        % hand position preprocessing - initial to end
        samplePts = 1:length(init2end.handX_100);
        temp = (length(samplePts)-1)/99;
        queryPts = 1:temp:length(samplePts);
        interpX_end = interp1(samplePts,init2end.handX_100,queryPts,'pchip')';
        interpY_end = interp1(samplePts,init2end.handY_100,queryPts,'pchip')';
        interpZ_end = interp1(samplePts,init2end.handZ_100,queryPts,'pchip')';

        % store initial to max data
        Session(i).InitialToMax(j).InterpolatedVelocity = interpVel_max;
        Session(i).InitialToMax(j).AbsoluteVelocity = absVel_max;
        Session(i).InitialToMax(j).InterpolatedHandX_100 = interpX_max;
        Session(i).InitialToMax(j).InterpolatedHandY_100 = interpY_max;
        Session(i).InitialToMax(j).InterpolatedHandZ_100 = interpZ_max;
        
        %store initial to end data
        Session(i).InitialToEnd(j).InterpolatedVelocity = interpVel_end;
        Session(i).InitialToEnd(j).AbsoluteVelocity = absVel_end;
        Session(i).InitialToEnd(j).InterpolatedHandX_100 = interpX_end;
        Session(i).InitialToEnd(j).InterpolatedHandY_100 = interpY_end;
        Session(i).InitialToEnd(j).InterpolatedHandZ_100 = interpZ_end;
    end
end
