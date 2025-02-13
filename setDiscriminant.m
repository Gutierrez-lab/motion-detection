
% This will allow you to run any type of subunit with any type of input
% noise (e.g. correlated or uncorrelated) and get a discriminant vector
% from that stimulus.

function [discrmntVect, leftTemp, rightTemp] = ...
    setDiscriminant(params, stimLeftward, stimRightward)

% Generate responses
respLeftward = generateReichardtResp(params.model, stimLeftward, ...
    params.subunitType, params.subunitInh, params.subDelay, ...
    params.sampleIntrv, params.productSubtraction);
respRightward = generateReichardtResp(params.model, stimRightward, ...
    params.subunitType, params.subunitInh, params.subDelay, ...
    params.sampleIntrv, params.productSubtraction);

% Trim away the response portions at the beginning and end that are
% just to noise (e.g. no motion stimuli)
% Might want to just shorten the stimuli
respTStart = round(params.respTStart / params.sampleIntrv); 
respTEnd = round(params.respTEnd / params.sampleIntrv);
leftTrimmed = respLeftward(:, respTStart+1:respTEnd);
rightTrimmed = respRightward(:, respTStart+1:respTEnd);
leftTemp = mean(leftTrimmed, 1);
rightTemp = mean(rightTrimmed, 1);

discrmntVect = rightTemp - leftTemp;

end