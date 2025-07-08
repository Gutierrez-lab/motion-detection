%% Let's get started
% tic
plotSettings;

% clearvars;
% p = true;r

% Circuit params
params.subDelay = 0.075;
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT'); %loads model data
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

% Stim params that I want to loop over
allPulseDelay = 0:0.01:0.1; %0:0.005:0.1; %[0 0.025:0.025:0.1 0.15 0.25]; %0:0.005:0.05; %[0:0.005:0.02 0.025:0.025:0.15];
params.pulseContrast = 1; 

% Stimulus params
params.pulseDur = 0.01; 

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

%% Calculating significance
coneBinary = [probTMeansL.cone; probTMeansR.cone];
combBinary = [probTMeansL.comb; probTMeansR.comb];
aov = zeros(length(allPulseDelay),1);

for i = 1:length(allPulseDelay)
    x = [coneBinary(:,i) combBinary(:,i)];
    aov(i) = kruskalwallis(x, [], 'off');
end

%% Calculating trial CI

n = (params.repeats-params.sizeTrain) * 2;
rodSuccess = sum(probTMeansL.rod) + sum(probTMeansR.rod);
coneSuccess = sum(probTMeansL.cone) + sum(probTMeansR.cone);
combSuccess = sum(probTMeansL.comb) + sum(probTMeansR.comb);

[pHatRod,pciRod] = binofit(rodSuccess,n);
[pHatCone,pciCone] = binofit(coneSuccess,n);
[pHatComb,pciComb] = binofit(combSuccess,n);


%% Time to plot
errorLengthRod = pciRod - [pHatRod' pHatRod'];
errorLengthCone = pciCone - [pHatCone' pHatCone'];
errorLengthComb = pciComb - [pHatComb' pHatComb'];

offsetPoints = 0.5;

% convert pulse delays from seconds to milliseconds
xAxis = allPulseDelay .* 1000;

customPurpleColour = [0.66,0.46,0.82];

chanceLine = 0.5 .* ones(1,length(xAxis));

figure;
errorbar(xAxis - offsetPoints, pHatRod, errorLengthRod(:,1), ...
    errorLengthRod(:,2), 'ko', 'MarkerFaceColor', 'b');
hold on;
errorbar(xAxis, pHatCone, errorLengthCone(:,1), errorLengthCone(:,2),...
    'ko', 'MarkerFaceColor', 'r');
hold on;
errorbar(xAxis + offsetPoints, pHatComb, errorLengthComb(:,1), ...
    errorLengthComb(:,2), 'ko',  'MarkerFaceColor', customPurpleColour); 
hold on;
plot(xAxis, chanceLine, 'k-');

title(['discrimination accuracy (n=' num2str(n) ')']);

xlabel('pulse delay (ms)');
ylabel('p');
legend('rod', 'cone', 'rod+cone', 'chance', 'Location', 'Southeast');

