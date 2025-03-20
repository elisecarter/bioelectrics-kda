function [interp_hand_euc] = InterpolatePosition(smooth_euc)

samplePts = 1:length(smooth_euc(:,1));
temp = (length(samplePts)-1)/99;
queryPts = 1:temp:length(samplePts);
interp_hand_euc(:,1) = interp1(samplePts,smooth_euc(:,1),queryPts,'pchip')';
interp_hand_euc(:,2) = interp1(samplePts,smooth_euc(:,2),queryPts,'pchip')';
interp_hand_euc(:,3) = interp1(samplePts,smooth_euc(:,3),queryPts,'pchip')';

end