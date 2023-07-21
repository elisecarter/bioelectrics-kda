function [meanEucVelocity, meanAbsVelocity, meanMaxVelocity] = SessionMeanVelocity(session_data)
% computes mean euclidean velocity for each session

eucVelocities = zeros(length(session_data),3);
absVelocities = zeros(length(session_data),1);
maxVelocities = zeros(length(session_data),1);
for i = 1:length(session_data)
    eucVelocities(i,:) = mean(session_data(i).InterpolatedVelocity);
    absVelocities(i) = mean(session_data(i).AbsoluteVelocity);
    maxVelocities(i) = session_data(i).MaxAbsVelocity;
end

meanEucVelocity = mean(eucVelocities);
meanAbsVelocity = mean(absVelocities);
meanMaxVelocity = mean(maxVelocities);