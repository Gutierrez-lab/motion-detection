%% Let's get started
tic
plotSettings;
clearvars;
% p = true;

% Circuit params
params.subDelay = 0.05;
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT');
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

% Stim params that I want to loop over
allPulseDelay = 0.025:0.025:0.25; %[0:0.005:0.025 0.05:0.025:0.25]; %[0 0.025:0.025:0.1 0.15 0.25]; %0:0.005:0.05; %[0:0.005:0.02 0.025:0.025:0.15];
params.pulseContrast = 1;

% Stimulus params
params.pulseDur = 0.01; 

params.fullInputDur = 2;
params.noiseAmountNorm = 0.1;
params.blueMean = 10;
params.redMean = 200;
params.sampleIntrv = 1E-4; 

% Trial params
params.respTStart = 0.9;
params.respTEnd = 1.9;

params.repeats = 1000;

projDiscAnalysis = false;

% Output matrices to initialise
autoscoredL.rod = zeros(length(allPulseDelay), params.repeats);
autoscoredL.cone = zeros(length(allPulseDelay), params.repeats);
autoscoredL.comb = zeros(length(allPulseDelay), params.repeats);
autoscoredR.rod = zeros(length(allPulseDelay), params.repeats);
autoscoredR.cone = zeros(length(allPulseDelay), params.repeats);
autoscoredR.comb = zeros(length(allPulseDelay), params.repeats);
rodAccuracyL = zeros(length(allPulseDelay), 1);
coneAccuracyL = zeros(length(allPulseDelay), 1);
combAccuracyL = zeros(length(allPulseDelay), 1);
rodAccuracyR = zeros(length(allPulseDelay), 1);
coneAccuracyR = zeros(length(allPulseDelay), 1);
combAccuracyR = zeros(length(allPulseDelay), 1);

%%

for i = 1:length(allPulseDelay)
    
    params.pulseDelay = allPulseDelay(i);

        % Generate noisy stimuli
        leftToRight = false;
        stimLeftward = generateReichardtStim(params.pulseDur, ...
            params.pulseDelay,  params.pulseContrast, leftToRight, ...
            params.noiseAmountNorm, params.fullInputDur, params.sampleIntrv, ...
            params.redMean, params.blueMean, params.repeats);
        leftToRight = true;
        stimRightward = generateReichardtStim(params.pulseDur, ...
            params.pulseDelay,  params.pulseContrast, leftToRight, ...
            params.noiseAmountNorm, params.fullInputDur, params.sampleIntrv, ...
            params.redMean, params.blueMean, params.repeats);

        % Run rod circuit
        params.subunitType = 'separateRod';

        % Generate discriminant vector with noiseless stim
        [discriminantVect.rod(i,:), ...
            responsesLeft.rod(i,:), responsesRight.rod(i,:)] = ...
            generateNoiselessDiscV(params);

        % % Run noisy stimuli for the rest of the trials
        [autoscoredL.rod(i,:), autoscoredR.rod(i,:), ...
            rodAccuracyL(i), rodAccuracyR(i)] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward, ...
            discriminantVect.rod(i,:));

        % Run cone circuit
        params.subunitType = 'separateCone';

        % Generate discriminant vectors with noiseless stim
        [discriminantVect.cone(i,:), ...
            responsesLeft.cone(i,:), responsesRight.cone(i,:)] = ...
            generateNoiselessDiscV(params);

        % Run noisy trials
        [autoscoredL.cone(i,:), autoscoredR.cone(i,:), ...
            coneAccuracyL(i), coneAccuracyR(i)] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward, ...
            discriminantVect.cone(i,:));

        % % % Optimal combination of rod-cone signals
        % % optCombLeft = (pRodLL .* pConeLL) > (pRodLR .* pConeLR);
        % % optCombRight = (pRodRR .* pConeRR) > (pRodRL .* pConeRL);
        % % probTMeansL.optml(i) = mean(optCombLeft);
        % % probTMeansR.optml(i) = mean(optCombRight);
        
        % % Run rod-cone combined circuit
        params.subunitType = 'sharedComb';
        % % Generate discriminant vectors with noiseless stim
        [discriminantVect.comb(i,:), ...
            responsesLeft.comb(i,:), responsesRight.comb(i,:)] = ...
            generateNoiselessDiscV(params);

        [autoscoredL.comb(i,:), autoscoredR.comb(i,:), ...
            combAccuracyL(i), combAccuracyR(i)] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward, ...
            discriminantVect.comb(i,:));
end
    

params.pulseDelay = allPulseDelay;
% params.pulseContrast = pulseContrast;

toc

%% Time to plot
figure; plot(allPulseDelay, combAccuracyL, 'o-'); 
hold on; plot(allPulseDelay, coneAccuracyL, 'ro-'); 
hold on; plot(allPulseDelay, rodAccuracyL, 'bo-'); 
hold on; plot(allPulseDelay, combAccuracyR, 'o-'); 
hold on; plot(allPulseDelay, coneAccuracyR, 'o-'); 
hold on; plot(allPulseDelay, rodAccuracyR, 'ko-');
legend('combined leftward', 'cone leftward', ...
    'rod leftward', 'combined rightward', ...
    'cone rightward', 'rod rightward');
hold on; ylim([0 1])
ylabel('accuracy'); xlabel('pulse delay (s)'); 
title('performance with noiseless discriminant (1000 trials per delay)')

%% Plot noiseless HR responses
xlim1 = 0;%100;
xlim2 = 1000; %350;

% load('oliveVioletColourmap.mat');
% set(groot,'defaultAxesColorOrder',flip(oliveVioletColourmap));
plotSettings;

figure; 
subplot(2,3,1); 
plot((1:length(responsesLeft.rod))/10, responsesLeft.rod(7:end,:)'); 
%legend(["10 ms", "20 ms", "30 ms", "40 ms", "50 ms", "60 ms", ...
%    "70 ms", "80 ms", "90 ms", "100 ms"]); 
% legend(["20 ms", "40 ms", "60 ms", "80 ms", "100 ms", "120 ms", ...
%    "140 ms", "160 ms", "180 ms", "200 ms"]); 
legend(["140 ms", "160 ms", "180 ms", "200 ms"]); 
title("rod leftward"); 
xlim([xlim1 xlim2]);

hold on; 
subplot(2,3,2); 
plot((1:length(responsesLeft.cone))/10, responsesLeft.cone(7:end,:)');  
title("cone leftward");
xlim([xlim1 xlim2]);

hold on; 
subplot(2,3,3); 
plot((1:length(responsesLeft.comb))/10, responsesLeft.comb(7:end,:)');  
title("combined leftward");
xlim([xlim1 xlim2]);

hold on; 
subplot(2,3,4); 
plot((1:length(responsesRight.rod))/10, responsesRight.rod(7:end,:)');  
title("rod rightward");
xlim([xlim1 xlim2]);

hold on; 
subplot(2,3,5); 
plot((1:length(responsesRight.cone))/10, responsesRight.cone(7:end,:)');  
title("cone rightward");
xlim([xlim1 xlim2]);

hold on; 
subplot(2,3,6); 
plot((1:length(responsesRight.comb))/10, responsesRight.comb(7:end,:)');  
title("combined rightward");
xlim([xlim1 xlim2]);

%%

% xAxis = allPulseDelay .* 1000;
% xAxisMatrix = repmat(xAxis, params.totalSims, 1);
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
% errorbar(xAxis + 2*offsetPoints, lPMuOptml, lPStdOptml, 'ko', 'MarkerFaceColor', 'w'); hold on;
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
% legend('rod', 'cone', combLegend, 'optml', 'chance line', 'Location', 'Southeast');
% 
% subplot(2,1,2);
% errorbar(xAxis - offsetPoints, rPMuRod, rPStdRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
% errorbar(xAxis, rPMuCone, rPStdCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
% errorbar(xAxis + offsetPoints, rPMuComb, rPStdComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;
% errorbar(xAxis + 2*offsetPoints, rPMuOptml, rPStdOptml, 'ko', 'MarkerFaceColor', 'w'); hold on;
% plot(xAxis, chanceLine, 'k-');
% title('performance compare, rightward');
% xlabel('stim delay ms');
% ylabel('labeled right');
% ylim([0 1]);
% xlim([-8 (max(allPulseDelay)*1000)+8]);
