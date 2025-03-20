function SaveKdaFile(data, path)
% this function will add kda file to existing 'kdaFiles' folder, or create
% a new one

folder = 'kdaFiles';

kda_path = fullfile(path,folder);
if ~exist(kda_path,'dir')
    mkdir(kda_path)
end

% save data as .kda file (.mat file)
filename = sprintf('%s_%s_%s_%s.kda',data.Experimentor,data.MouseID,data.Phase,data.Status);
file = fullfile(kda_path,filename);
save(file,'-struct','data','-v7.3','-mat')