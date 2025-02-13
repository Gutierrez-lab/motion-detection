%% Let's get started
% tic
 plotSettings; %we can 

clearvars;
% p = true;

% Circuit params
params.subDelay = 0.05;
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT'); %loads model data
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

% Stim params that I want to loop over
allPulseDelay = 0:0.005:0.1; %[0 0.025:0.025:0.1 0.15 0.25]; %0:0.005:0.05; %[0:0.005:0.02 0.025:0.025:0.15];
params.pulseContrast = 1; 

% Stimulus params
minPulseDelay = 0;
maxPulseDelay = 0.1;
params.pulseDelayRange = [minPulseDelay maxPulseDelay];
params.numPulses = 1000;

params.pulseDur = 0.01; 

params.fullInputDur = 2;
params.corrlNoise = false;
params.blueMean = 10;
params.redMean = 200;
params.sampleIntrv = 1E-4;

% Trial params
params.respTStart = 0.9;
params.respTEnd = 1.9;
params.repeats = 1000; %number of trials per direction

projDiscAnalysis = false;

%% generate variable velocity stimuli

params.noiseAmountNorm = 0;
leftToRight = false;
[stimDiscLeftward, discLeftDelays] = ...
    variableVelocityStim(params.pulseDelayRange,  ...
    params.numPulses,  params.pulseContrast, params.pulseDur, leftToRight, ...
    params.noiseAmountNorm, params.fullInputDur, params.sampleIntrv, ...
    params.redMean, params.blueMean);
leftToRight = true;
[stimDiscRightward, discRightDelays] = ...
    variableVelocityStim(params.pulseDelayRange,  ...
    params.numPulses,  params.pulseContrast, params.pulseDur, leftToRight, ...
    params.noiseAmountNorm, params.fullInputDur, params.sampleIntrv, ...
    params.redMean, params.blueMean);


%% compute "discriminant vector" for all circuits

params.subunitType = 'separateRod';
[discrmntVectRod, leftMeanRod, rightMeanRod] = ...
    setDiscriminant(params, stimDiscLeftward, stimDiscRightward); 

params.subunitType = 'separateCone';
[discrmntVectCone, leftMeanCone, rightMeanCone] = ...
    setDiscriminant(params, stimDiscLeftward, stimDiscRightward); 

params.subunitType = 'sharedComb';
[discrmntVectComb, leftMeanComb, rightMeanComb] = ...
    setDiscriminant(params, stimDiscLeftward, stimDiscRightward); 


%% runs all experiment combos

params.noiseAmountNorm = 0.1;
for i = 1:length(allPulseDelay)

    params.pulseDelay = allPulseDelay(i);

    % Generate stimuli
    leftToRight = false;
    stimLeftward = generateReichardtStim(params.pulseDur, ...
        params.pulseDelay,  params.pulseContrast, leftToRight, ...
        params.noiseAmountNorm, params.fullInputDur, params.sampleIntrv, ...
        params.redMean, params.blueMean, params.repeats, params.corrlNoise);
    leftToRight = true;
    stimRightward = generateReichardtStim(params.pulseDur, ...
        params.pulseDelay,  params.pulseContrast, leftToRight, ...
        params.noiseAmountNorm, params.fullInputDur, params.sampleIntrv, ...
        params.redMean, params.blueMean, params.repeats, params.corrlNoise);

    % Run stimuli on different circuits
    % rod only
    params.subunitType = 'separateRod';
    [probTMeansL.rod(:,i), probTMeansR.rod(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward, ...
        discrmntVectRod);

    %cone only
    params.subunitType = 'separateCone';
    [probTMeansL.cone(:,i), probTMeansR.cone(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward, ...
        discrmntVectCone);

    % true model
    params.subunitType = 'sharedComb';
    [probTMeansL.comb(:,i), probTMeansR.comb(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward, ...
        discrmntVectComb);

end


params.pulseDelay = allPulseDelay;

toc

%% Calculating trial stats

readoutRod = [probTMeansL.rod; probTMeansR.rod];
readoutCone = [probTMeansL.cone; probTMeansR.cone];
readoutComb = [probTMeansL.comb; probTMeansR.comb];

[rodMu, rodSigma] = calcStatsBinomial(readoutRod);
[coneMu, coneSigma] = calcStatsBinomial(readoutCone);
[combMu, combSigma] = calcStatsBinomial(readoutComb);


%% Time to plot
offsetPoints = 0.5;

% convert pulse delays from seconds to milliseconds
xAxis = allPulseDelay .* 1000;

customPurpleColour = [0.66,0.46,0.82]; 

chanceLine = params.repeats .* ones(length(allPulseDelay), 1); 

figure;
errorbar(xAxis - offsetPoints, rodMu, rodSigma, 'ko', ...
    'MarkerFaceColor', 'b');
hold on;
errorbar(xAxis, coneMu, coneSigma, 'ko', ...
    'MarkerFaceColor', 'r'); 
hold on;
errorbar(xAxis + offsetPoints, combMu, combSigma, 'ko', ...
    'MarkerFaceColor', customPurpleColour); hold on;
hold on;
plot(xAxis, chanceLine, 'k-');

ylim(params.repeats * [1/2 2]);

title(['accurately labeled trials (out of ' num2str(params.repeats * 2)...
    ' total trials)']);

xlabel('pulse delay (ms)');
ylabel('labeled correctly');
legend('rod', 'cone', 'comb', 'chance line', 'Location', 'Southeast');