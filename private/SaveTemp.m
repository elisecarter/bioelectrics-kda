function SaveTemp(data)
% data saved to temp file to be shared between callback functions

save('tempdata.mat','data','-v7.3')