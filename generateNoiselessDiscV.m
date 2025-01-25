function [discriminantVect, trimmedLeftNoiseless, trimmedRightNoiseless] ...
    = generateNoiselessDiscV(params)

% Set noise level to zero and only run one trial
zeroNoise = 0;
oneRepeat = 1;

% Generate leftward and rightward stim traces for one noiseless trial
leftToRight = false;
stimLeftwardNoiseless = generateReichardtStim(params.pulseDur, ...
    params.pulseDelay,  params.pulseContrast, leftToRight, ...
    zeroNoise, params.fullInputDur, params.sampleIntrv, ...
    params.redMean, params.blueMean, oneRepeat);
leftToRight = true;
stimRightwardNoiseless = generateReichardtStim(params.pulseDur, ...
    params.pulseDelay,  params.pulseContrast, leftToRight, ...
    zeroNoise, params.fullInputDur, params.sampleIntrv, ...
    params.redMean, params.blueMean, oneRepeat);

% Run the stim through the model circuit
leftNoiseless = generateReichardtResp(params.model, ...
    stimLeftwardNoiseless, ...
    params.subunitType, params.subunitInh, params.subDelay, ...
    params.sampleIntrv, params.productSubtraction);
rightNoiseless = generateReichardtResp(params.model, ...
    stimRightwardNoiseless, ...
    params.subunitType, params.subunitInh, params.subDelay, ...
    params.sampleIntrv, params.productSubtraction);

% Trim away the response portions at the beginning and end that are
% just to noise (e.g. no motion stimuli)
% Might want to just shorten the stimuli
respTStart = params.respTStart / params.sampleIntrv; 
respTEnd = params.respTEnd / params.sampleIntrv;

% Start the indexing at respTStart+1 and not respTStart because of 
% MATLAB's 1-based indexing
trimmedLeftNoiseless = leftNoiseless(:, respTStart:respTEnd);
trimmedRightNoiseless = rightNoiseless(:, respTStart:respTEnd);

% Compute a discriminant vector by subtracting the leftward resp trace
% from the rightward resp trace.
discriminantVect = trimmedRightNoiseless - trimmedLeftNoiseless;

% discriminantVect = rightNoiseless - leftNoiseless;

end