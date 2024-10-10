function data = AddMetaData(data)


for i = 1:length(data.RawData)
    % number of reach attemps
    %data.Sessions(i).ReachAttempts = length(data.RawData(i).Behaviors);

    % stimulation accuracy
    stims = data.Sessions(i).StimLogical;
    behavior = data.Sessions(i).Behavior;

    truepos = sum(strcmpi('success',behavior) & stims==1);
    trueneg = sum(strcmpi('success',behavior)==0 & stims==0);
    falsepos = sum(strcmpi('success',behavior)==0 & stims==1);
    falseneg = sum(strcmpi('success',behavior) & stims==0);

    data.Sessions(i).StimAccuracy = (truepos+trueneg)/(truepos+trueneg+falsepos+falseneg);
    data.Sessions(i).StimSensitivty = truepos/(truepos+falseneg);
    data.Sessions(i).StimSpecificity = trueneg/(trueneg+falsepos);

    % percentages of failure types
    numfails = sum(contains(data.RawData(i).Behaviors,'fail'));
    data.Sessions(i).PercentFailuresGrasp = sum(contains(data.RawData(i).Behaviors,'grasp'))/numfails;
    data.Sessions(i).PercentFailuresReach = sum(contains(data.RawData(i).Behaviors,'reach'))/numfails;
    data.Sessions(i).PercentFailuresRetrieval = sum(contains(data.RawData(i).Behaviors,'retrieval'))/numfails;

end

