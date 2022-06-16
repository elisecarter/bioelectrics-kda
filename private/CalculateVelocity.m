function CalculateVelocity(euc)

for i = 1 : height(euc) - 1
    abs_velocity(i,1)=norm(euc(i+1,:) - euc(i,:));
    interp_velocity(i,:)=euc(i+1,:) - euc(i,:); %(x, y, z)

end
interp_velocity(:,2) = interpVel_max(:,2)*-1;
rawVel_max = interpVel_max;
samplePts = 1:size(interpVel_max,1);
temp = (length(samplePts)-1)/99;
queryPts = 1:temp:length(samplePts); % interpolate to have 100 pts
interpVel_max = interp1(samplePts,interpVel_max,queryPts,'pchip');
absVel_max = interp1(samplePts,absVel_max,queryPts,'pchip')';