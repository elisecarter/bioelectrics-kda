function mouseIDs = SelectMice(mouseIDs)
% UI select mice to load data for

[indx, ~] = listdlg('ListString',mouseIDs);
mouseIDs = mouseIDs(indx);
