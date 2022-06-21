function [interp_velocity,abs_velocity,raw_velocity] = CalculateVelocity(euc)

for i = 1 : height(euc) - 1
    abs_velocity(i,1)=norm(euc(i+1,:) - euc(i,:));
    dim_velocity(i,:)=euc(i+1,:) - euc(i,:); %(x, y, z)
end

dim_velocity(:,2) = dim_velocity(:,2)*-1;
raw_velocity = dim_velocity;

samplePts = 1:size(dim_velocity,1);
temp = (length(samplePts)-1)/99;
queryPts = 1:temp:length(samplePts); % interpolate to have 100 pts
interp_velocity = interp1(samplePts,dim_velocity,queryPts,'pchip');
abs_velocity = interp1(samplePts,abs_velocity,queryPts,'pchip')';

end