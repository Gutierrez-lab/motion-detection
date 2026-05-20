%% Let's get started
tic
% plotSettings; 

% clearvars;
% p = true;

% Circuit params
params.subDelay = 0.05; %50 ms
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT'); %loads model data
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

% Stim params that I want to loop over
allPulseDelay = 0:0.01:0.1; %0:0.005:0.05; %[0 0.025:0.025:0.1 0.15 0.25]; %0:0.005:0.05; %[0:0.005:0.02 0.025:0.025:0.15]; % ms

params.fullInputDur = 2; % seconds
params.noiseAmountNorm = 0.1; %0.1;
params.corrlNoise = false;
params.blueMean = 10;
params.redMean = 200;
params.sampleIntrv = 1E-4; % sampling rate

% Trial params
params.respTStart = 0.9;
params.respTEnd = 1.9;
params.repeats = 5500; %number of trials per condition
params.sizeTrain = 500;
% sizeTest = params.repeats - params.sizeTrain; % isn't used here
% params.totalSims = 3; %5 set this back when done testing - I don't think
% we use it anymore since we generate all the trials in an array

% projDiscAnalysis = false; % isn't used here

% save the parameters so we can use them consistently in other simulations
save('modelParameters.mat','params','allPulseDelay')

% variable stim params
params.pulseContrast = 1; % 100%
params.pulseDur = 0.01; % pulse width: 10 ms by default

%% runs all experiment combos

p = zeros(size(allPulseDelay));

for i = 1:length(allPulseDelay)
    
    params.pulseDelay = allPulseDelay(i);
    
    % for j = 1:params.totalSims %repeats per stim
        
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
        % This is where the noise should be added in.
        params.subunitType = 'separateRod';
        [probTMeansL.rod(:,i), probTMeansR.rod(:,i), ...
            pRodLL, pRodLR, pRodRR, pRodRL] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward);

        % Call same function as above, but with no noise (and only 2 
        % trials).

        % Function that deals with discriminant + projections (inputs to 
        % this should be the noisy trials and the 2 noiseless trials).
        
        %cone only
        params.subunitType = 'separateCone';
        [probTMeansL.cone(:,i), probTMeansR.cone(:,i), ...
            pConeLL, pConeLR, pConeRR, pConeRL] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward);

        % % Optimal combination of rod-cone signals
        % optCombLeft = (pRodLL .* pConeLL) > (pRodLR .* pConeLR);
        % optCombRight = (pRodRR .* pConeRR) > (pRodRL .* pConeRL);
        % probTMeansL.optml(j,i) = mean(optCombLeft);
        % probTMeansR.optml(j,i) = mean(optCombRight);
        
        % true model
        params.subunitType = 'sharedComb';
        [probTMeansL.comb(:,i), probTMeansR.comb(:,i)] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward);

        % Kruskal-Wallis test
        p(i) = kruskalwallis([[probTMeansL.comb(:,i);probTMeansR.comb(:,i)],[probTMeansL.cone(:,i);probTMeansR.cone(:,i)]],[],'off');
    % end
    
end

params.pulseDelay = allPulseDelay;
% params.pulseContrast = pulseContrast;

toc

%% better figure
xAxis = allPulseDelay .* 1000; % to get it into ms
chanceLine = 0.5 .* ones(length(allPulseDelay), 1); 

offsetPoints = 0.2;
purpleColor = [0.660156250000000,0.457031250000000,0.816406250000000];

PMuRod = mean([probTMeansL.rod;probTMeansR.rod]);
PMuCone = mean([probTMeansL.cone;probTMeansR.cone]);
PMuComb = mean([probTMeansL.comb;probTMeansR.comb]);

% Clopper-Pearson confidence intervals
n = 2*(params.repeats - params.sizeTrain); %total trials per pulse delay
[~,pCIRod] = binofit(sum([probTMeansL.rod;probTMeansR.rod]),n.*ones(1,length(allPulseDelay)));
[~,pCICone] = binofit(sum([probTMeansL.cone;probTMeansR.cone]),n.*ones(1,length(allPulseDelay)));
[~,pCIComb] = binofit(sum([probTMeansL.comb;probTMeansR.comb]),n.*ones(1,length(allPulseDelay)));

figure;
errorbar(xAxis - offsetPoints, PMuRod, PMuRod - pCIRod(:,1)', pCIRod(:,2)' - PMuRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
errorbar(xAxis, PMuCone, PMuCone-pCICone(:,1)', pCICone(:,2)'-PMuCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
errorbar(xAxis + offsetPoints, PMuComb, PMuComb-pCIComb(:,1)', pCIComb(:,2)'-PMuComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;
% plot(xAxis + 2*offsetPoints, mean([probTMeansL.coneShiftCone;probTMeansR.coneShiftCone]),'ko','MarkerFaceColor','y');
plot(xAxis, chanceLine, 'k-');

xlabel('pulse delay, \Deltas (ms)');
ylabel('accuracy');


%% save the results!

save('motionResults.mat','params','allPulseDelay','probTMeansL','probTMeansR','stimLeftward','stimRightward','p')