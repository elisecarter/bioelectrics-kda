function data = AddMetaData(data)


for i = 1:length(data.Sessions)
    % number of reach attemps
    data.Sessions(i).ReachAttempts = length(data.Sessions(i).InitialToMax);

    % stimulation accuracy
    stims = data.Sessions(i).StimLogical;
    truepos = sum(strcmpi('success',data.Sessions(i).Behavior) & stims==1);
    trueneg = sum(strcmpi('success',data.Sessions(i).Behavior)==0 & stims==0);
    falsepos = sum(strcmpi('success',data.Sessions(i).Behavior)==0 & stims==1);
    falseneg = sum(strcmpi('success',data.Sessions(i).Behavior) & stims==0);

    data.Sessions(i).StimAccuracy = (truepos+trueneg)/(truepos+trueneg+falsepos+falseneg);
    data.Sessions(i).StimSensitivty = truepos/(truepos+falseneg);
    data.Sessions(i).StimSpecificity = trueneg/(trueneg+falsepos);

    % percentages of failure types
    numfails = sum(contains(data.Sessions(i).Behavior,'fail'));

    data.Sessions(i).PercentFailuresGrasp = sum(contains(data.Sessions(i).Behavior,'grasp'))/numfails;
    data.Sessions(i).PercentFailuresReach = sum(contains(data.Sessions(i).Behavior,'reach'))/numfails;
    data.Sessions(i).PercentFailuresRetrieval = sum(contains(data.Sessions(i).Behavior,'retrieval'))/numfails;

end

