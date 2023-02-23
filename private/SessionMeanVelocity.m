function [meanEucVelocity, meanAbsVelocity] = SessionMeanVelocity(session_data)
% computes mean euclidean velocity for each session

eucVelocities = zeros(length(session_data),3);
absVelocities = zeros(length(session_data),1);
for i = 1:length(session_data)
    eucVelocities(i,:) = mean(session_data(i).InterpolatedVelocity);
    absVelocities(i) = mean(session_data(i).AbsoluteVelocity);
end

meanEucVelocity = mean(eucVelocities);
meanAbsVelocity = mean(absVelocities);