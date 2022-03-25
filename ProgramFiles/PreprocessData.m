function  [Session] = PreprocessData(RawData)
% filters data to keep only reach events, 
% calculates interpolated position/velocity,
%

% preallocate Session struct
Session(length(RawData)) = struct('SessionID',[],'InitialToMax',[],...
    'InitialToEnd',[],'StimLogical',[]);

for i = 1 : length(RawData) % i: session
    sessionData = RawData(i);
    indx = table2array(sessionData.ReachIndexPairs);

    %preallocate structs to hold data for each session
    init2max = struct('handX_100',[],'handY_100',[],'handZ_100',[],...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[],...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[],...
        'pelletConfZ_10k',[]);
    init2end = struct('handX_100',[],'handY_100',[],'handZ_100',[],...
        'handConfXY_10k',[],'handConfZ_10k',[],'pelletX_100',[],...
        'pelletY_100',[],'pelletZ_100',[],'pelletConfXY_10k',[],...
        'pelletConfZ_10k',[]);

%     init2end = struct('handX',[],'handY',[],'handZ',[],...
%         'handConfSide',[],'handConfFront',[],'pelletX',[],'pelletY',[],...
%         'pelletZ',[],'pelletConfSide',[],'pelletConfFront',[]);
    
    % save this info before deleting so we can use structfun
    Session(i).SessionID = sessionData.Session;
    Session(i).StimLogical = sessionData.StimLogical;

    % remove uneeded fields
    sessionData = rmfield(sessionData, 'Session');
    sessionData = rmfield(sessionData, 'ReachIndexPairs');
    sessionData = rmfield(sessionData, 'StimLogical');

    % pull out the indices of reach events
    for j = 1 : height(indx) % j: reach event
        startInd = indx(j,1); % reach start index
        maxInd = indx(j,2); % reach max index
        endInd = indx(j,3); % reach end index

         init2max(j)= structfun(@(x) x(startInd:maxInd), sessionData, 'UniformOutput', false);
         init2end(j) = structfun(@(x) x(startInd:endInd), sessionData, 'UniformOutput', false);

        % could use this^ need to delete other fields first
%         init2max(j).handX = sessionData.handX_100(startInd:maxInd);
%         init2max(j).handY = sessionData.handY_100(startInd:maxInd);
%         init2max(j).handZ = sessionData.handZ_100(startInd:maxInd);
%         init2max(j).handConfSide = sessionData.handConfXY_10k(startInd:maxInd);
%         init2max(j).handConfFront = sessionData.handConfZ_10k(startInd:maxInd);
%         init2max(j).pelletX = sessionData.pelletX_100(startInd:maxInd);
%         init2max(j).pelletY = sessionData.pelletY_100(startInd:maxInd);
%         init2max(j).pelletZ = sessionData.pelletZ_100(startInd:maxInd);
%         init2max(j).pelletConfSide = sessionData.pelletConfXY_10k(startInd:maxInd);
%         init2max(j).pelletConfFront = sessionData.pelletConfZ_10k(startInd:maxInd);
% 
%         init2end(j).handX = sessionData.handX_100(startInd:endInd);
%         init2end(j).handY = sessionData.handY_100(startInd:endInd);
%         init2end(j).handZ = sessionData.handZ_100(startInd:maxInd);
%         init2end(j).handConfSide = sessionData.handConfXY_10k(startInd:endInd);
%         init2end(j).handConfFront = sessionData.handConfZ_10k(startInd:endInd);
%         init2end(j).pelletX = sessionData.pelletX_100(startInd:endInd);
%         init2end(j).pelletY = sessionData.pelletY_100(startInd:endInd);
%         init2end(j).pelletZ = sessionData.pelletZ_100(startInd:endInd);
%         init2end(j).pelletConfSide = sessionData.pelletConfXY_10k(startInd:endInd);
%         init2end(j).pelletConfFront = sessionData.pelletConfZ_10k(startInd:endInd);
    end
    Session(i).InitialToMax = init2max;
    Session(i).InitialToEnd = init2end;
    
end





