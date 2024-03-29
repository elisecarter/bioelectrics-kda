function SaveJSON(mouse_data,OUTpath)
% creates a json file containing the data struct for each mouse

json_folder = "jsonFiles";
json_folder_path = fullfile(OUTpath,json_folder);
if ~exist(json_folder_path,'dir')
    mkdir(json_folder_path)
end

file_name = sprintf('%s_%s_%s.json',mouse_data.Experimentor,mouse_data.MouseID,mouse_data.Phase);
file = fullfile(json_folder_path,file_name);
fid = fopen(file,'w');
encodedJSON = jsonencode(mouse_data, PrettyPrint=true);
fprintf(fid, encodedJSON);