%% Let's get started
tic
plotSettings;
% clearvars;
% p = true;

% Circuit params
params.subDelay = 0.05;
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT');
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

% Stim params that I want to loop over
% allPulseDelay = 0.02:0.01:0.2;%[0:0.005:0.025 0.05:0.025:0.25]; %[0 0.025:0.025:0.1 0.15 0.25]; %0:0.005:0.05; %[0:0.005:0.02 0.025:0.025:0.15];
params.pulseContrast = 1; 

% Stimulus params
params.pulseDur = 0.01; 

params.fullInputDur = 2;
% params.noiseAmountNorm = 0.2; %0.1;
params.corrlNoise = false;
params.blueMean = 10;
params.redMean = 200;
params.sampleIntrv = 1E-4;

% Trial params
params.respTStart = 0.9;
params.respTEnd = 1.9;
params.repeats = 1100;
params.sizeTrain = 100;
sizeTest = params.repeats - params.sizeTrain;
params.totalSims = 5; 

projDiscAnalysis = false;

%%

for i = 1:length(allPulseDelay)
    
    params.pulseDelay = allPulseDelay(i);
    
    for j = 1:params.totalSims
        
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
        params.subunitType = 'separateRod';
        [probTMeansL.rod(j,i), probTMeansR.rod(j,i), ...
            pRodLL, pRodLR, pRodRR, pRodRL] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward, ...
            projDiscAnalysis);
        
        params.subunitType = 'separateCone';
        [probTMeansL.cone(j,i), probTMeansR.cone(j,i), ...
            pConeLL, pConeLR, pConeRR, pConeRL] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward, ...
            projDiscAnalysis);

        % Optimal combination of rod-cone signals
        optCombLeft = (pRodLL .* pConeLL) > (pRodLR .* pConeLR);
        optCombRight = (pRodRR .* pConeRR) > (pRodRL .* pConeRL);
        probTMeansL.optml(j,i) = mean(optCombLeft);
        probTMeansR.optml(j,i) = mean(optCombRight);
        
        params.subunitType = 'sharedComb';
        [probTMeansL.comb(j,i), probTMeansR.comb(j,i)] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward, ...
            projDiscAnalysis);
    end
    
end

params.pulseDelay = allPulseDelay;
% params.pulseContrast = pulseContrast;

toc

%% Time to plot
xAxis = allPulseDelay .* 1000;
xAxisMatrix = repmat(xAxis, params.totalSims, 1);
chanceLine = 0.5 .* ones(length(allPulseDelay), 1); 

errorPlot = true;
offsetPoints = 0.2;
purpleColor = [0.660156250000000,0.457031250000000,0.816406250000000];

lPMuRod = mean(probTMeansL.rod);
rPMuRod = mean(probTMeansR.rod);
lPMuCone = mean(probTMeansL.cone);
rPMuCone = mean(probTMeansR.cone);
lPMuComb = mean(probTMeansL.comb);
rPMuComb = mean(probTMeansR.comb);
lPMuOptml = mean(probTMeansL.optml);
rPMuOptml = mean(probTMeansR.optml);
lPStdRod = std(probTMeansL.rod);
rPStdRod = std(probTMeansR.rod);
lPStdCone = std(probTMeansL.cone);
rPStdCone = std(probTMeansR.cone);
lPStdComb = std(probTMeansL.comb);
rPStdComb = std(probTMeansR.comb);
lPStdOptml = std(probTMeansL.optml);
rPStdOptml = std(probTMeansR.optml);

figure;
subplot(2,1,1);
errorbar(xAxis - offsetPoints, lPMuRod, lPStdRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
errorbar(xAxis, lPMuCone, lPStdCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
errorbar(xAxis + offsetPoints, lPMuComb, lPStdComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;
errorbar(xAxis + 2*offsetPoints, lPMuOptml, lPStdOptml, 'ko', 'MarkerFaceColor', 'w'); hold on;
plot(xAxis, chanceLine, 'k-');
title('performance compare, leftward');
xlabel('stim delay ms');
ylabel('labeled left');
ylim([0 1]);
xlim([-8 (max(allPulseDelay)*1000)+8]);
if params.corrlNoise
    combLegend = 'corr rod+cone';
else
    combLegend = 'uncorr rod+cone';
end
legend('rod', 'cone', combLegend, 'optml', 'chance line', 'Location', 'Southeast');

subplot(2,1,2);
errorbar(xAxis - offsetPoints, rPMuRod, rPStdRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
errorbar(xAxis, rPMuCone, rPStdCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
errorbar(xAxis + offsetPoints, rPMuComb, rPStdComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;
errorbar(xAxis + 2*offsetPoints, rPMuOptml, rPStdOptml, 'ko', 'MarkerFaceColor', 'w'); hold on;
plot(xAxis, chanceLine, 'k-');
title('performance compare, rightward');
xlabel('stim delay ms');
ylabel('labeled right');
ylim([0 1]);
xlim([-8 (max(allPulseDelay)*1000)+8]);
