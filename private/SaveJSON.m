function SaveJSON(mouse_data,path)

file_name = sprintf('%s.json',mouse_data.MouseID);
file = fullfile(path,file_name);
fid = fopen(file,'w');
encodedJSON = jsonencode(mouse_data, PrettyPrint=true);
fprintf(fid, encodedJSON);