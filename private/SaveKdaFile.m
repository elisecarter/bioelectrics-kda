function SaveKdaFile(data, path)
% save data as .kda file (.mat file)
filename = sprintf('%s.kda',data.MouseID);
file = fullfile(path,filename);
save(file,'-struct','data','-mat')