function data = AddDayofTraining(data)
% compare session lists to full session list to find missing days of
% training

% find a mouse with most unique session IDs
allMice = [data{:}];
for i = 1:length(allMice)
    num_sessions(i) = length(allMice(i).RawData);
    allSessions{i} = [allMice(i).RawData.Session];
end
total_sessions = max(num_sessions);

ind = zeros(1,length(allSessions));
for i = 1:length(allSessions)
    ind(i) = (length(allSessions{i}) == total_sessions);
end

fullSessions = allSessions(find(ind, 1, 'first'));
fullSessionList = [fullSessions{:}];
fullSessionDateStr = cellfun(@(x) x(1:8),fullSessionList,'UniformOutput',false);
fullSessionDates = datetime(fullSessionDateStr,'InputFormat','yyyyMMdd');


    % find mice that have less than total number of sessions
    for i = 1:length(num_sessions)
        if num_sessions(i) < total_sessions
            sessionList = allSessions{i};
            sessionDatesStr = cellfun(@(x) x(1:8),sessionList,'UniformOutput',false);
            sessionDates = datetime(sessionDatesStr,'InputFormat','yyyyMMdd');
            
            ind = fullSessionDates == sessionDates;
            % compare session date lists
            %ind = cellfun(@(x) );

        else
            trainingDay = 1:total_sessions;

        end
    end
end
