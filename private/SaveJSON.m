function SaveJSON(mouse_data,path)
% creates a json file containing the data struct for each mouse

file_name = sprintf('%s.json',mouse_data.MouseID);
file = fullfile(path,file_name);
fid = fopen(file,'w');
encodedJSON = jsonencode(mouse_data, PrettyPrint=true);
fprintf(fid, encodedJSON);