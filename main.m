%% Let's get started
% tic
% plotSettings; %we can 

% clearvars;
% p = true;

% Circuit params
params.subDelay = 0.05;
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT'); %loads model data
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

% Stim params that I want to loop over
allPulseDelay = 0:0.01:0.1; %0:0.005:0.1; %[0 0.025:0.025:0.1 0.15 0.25]; %0:0.005:0.05; %[0:0.005:0.02 0.025:0.025:0.15];
% params.pulseContrast = 1; 

% Stimulus params
% params.pulseDur = 0.01; 

params.fullInputDur = 2;
params.corrlNoise = false;
params.blueMean = 10;
params.redMean = 200;
params.sampleIntrv = 1E-4;

% Trial params
params.respTStart = 0.9;
params.respTEnd = 1.9;
params.repeats = 600; %number of trials per direction
params.sizeTrain = 100;

projDiscAnalysis = false;


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
        reichardtTrialSet(params, stimLeftward, stimRightward);

    %cone only
    params.subunitType = 'separateCone';
    [probTMeansL.cone(:,i), probTMeansR.cone(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward);

    % true model
    params.subunitType = 'sharedComb';
    [probTMeansL.comb(:,i), probTMeansR.comb(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward);

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


% %% Time to plot
% offsetPoints = 0.5;
% 
% % convert pulse delays from seconds to milliseconds
% xAxis = allPulseDelay .* 1000;
% 
% customPurpleColour = [0.66,0.46,0.82]; 
% 
% testTrials = (params.repeats-params.sizeTrain) * 2;
% chanceLine = testTrials / 2 .* ones(length(allPulseDelay), 1); 
% 
% figure;
% errorbar(xAxis - offsetPoints, rodMu, rodSigma, 'ko', ...
%     'MarkerFaceColor', 'b');
% hold on;
% errorbar(xAxis, coneMu, coneSigma, 'ko', ...
%     'MarkerFaceColor', 'r'); 
% hold on;
% errorbar(xAxis + offsetPoints, combMu, combSigma, 'ko', ...
%     'MarkerFaceColor', customPurpleColour); hold on;
% hold on;
% plot(xAxis, chanceLine, 'k-');
% 
% ylim(testTrials * [1/4 1]);
% 
% title(['accurately labeled trials (out of ' num2str(testTrials) ...
%     ' total trials)']);
% 
% xlabel('pulse delay (ms)');
% ylabel('labeled correctly');
% legend('rod', 'cone', 'comb', 'chance line', 'Location', 'Southeast');