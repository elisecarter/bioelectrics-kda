function SaveMATFile(data, path)
% save data as .kda file (.mat file)
filename = data.MouseID;
file = fullfile(path,filename);
save(file,'data','-mat')