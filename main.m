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
params.noiseAmountNorm = 0.1;
params.corrlNoise = false;
params.blueMean = 10;
params.redMean = 200;
params.sampleIntrv = 1E-4;

% Trial params
params.respTStart = 0.9;
params.respTEnd = 1.9;
params.repeats = 1000; %number of trials per condition

projDiscAnalysis = false;

%% generate variable velocity stimuli

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
        discrmntVect);

    %cone only
    params.subunitType = 'separateCone';
    [probTMeansL.cone(:,i), probTMeansR.cone(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward, ...
        discrmntVect);

    % true model
    params.subunitType = 'sharedComb';
    [probTMeansL.comb(:,i), probTMeansR.comb(:,i)] = ...
        reichardtTrialSet(params, stimLeftward, stimRightward, ...
        discrmntVect);

end

params.pulseDelay = allPulseDelay;

toc


%% Time to plot
% xAxis = allPulseDelay .* 1000;
% % xAxisMatrix = repmat(xAxis, params.totalSims, 1);
% chanceLine = 0.5 .* ones(length(allPulseDelay), 1); 
% 
% errorPlot = true;
% offsetPoints = 0.2;
% purpleColor = [0.660156250000000,0.457031250000000,0.816406250000000];
% 
% lPMuRod = mean(probTMeansL.rod);
% rPMuRod = mean(probTMeansR.rod);
% lPMuCone = mean(probTMeansL.cone);
% rPMuCone = mean(probTMeansR.cone);
% lPMuComb = mean(probTMeansL.comb);
% rPMuComb = mean(probTMeansR.comb);
% % lPMuOptml = mean(probTMeansL.optml);
% % rPMuOptml = mean(probTMeansR.optml);
% lPStdRod = std(probTMeansL.rod);
% rPStdRod = std(probTMeansR.rod);
% lPStdCone = std(probTMeansL.cone);
% rPStdCone = std(probTMeansR.cone);
% lPStdComb = std(probTMeansL.comb);
% rPStdComb = std(probTMeansR.comb);
% % lPStdOptml = std(probTMeansL.optml);
% % rPStdOptml = std(probTMeansR.optml);
% 
% figure;
% subplot(2,1,1);
% errorbar(xAxis - offsetPoints, lPMuRod, lPStdRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
% errorbar(xAxis, lPMuCone, lPStdCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
% errorbar(xAxis + offsetPoints, lPMuComb, lPStdComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;
% % errorbar(xAxis + 2*offsetPoints, lPMuOptml, lPStdOptml, 'ko', 'MarkerFaceColor', 'w'); hold on;
% plot(xAxis, chanceLine, 'k-');
% title('performance compare, leftward');
% xlabel('stim delay ms');
% ylabel('labeled left');
% ylim([0 1]);
% xlim([-8 (max(allPulseDelay)*1000)+8]);
% if params.corrlNoise
%     combLegend = 'corr rod+cone';
% else
%     combLegend = 'uncorr rod+cone';
% end
% legend('rod', 'cone', combLegend, 'optml', 'chance line', 'Location', 'Southeast');
% 
% subplot(2,1,2);
% errorbar(xAxis - offsetPoints, rPMuRod, rPStdRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
% errorbar(xAxis, rPMuCone, rPStdCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
% errorbar(xAxis + offsetPoints, rPMuComb, rPStdComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;
% % errorbar(xAxis + 2*offsetPoints, rPMuOptml, rPStdOptml, 'ko', 'MarkerFaceColor', 'w'); hold on;
% plot(xAxis, chanceLine, 'k-');
% title('performance compare, rightward');
% xlabel('stim delay ms');
% ylabel('labeled right');
% ylim([0 1]);
% xlim([-8 (max(allPulseDelay)*1000)+8]);
