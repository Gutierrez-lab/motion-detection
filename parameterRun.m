% Circuit params
params.productSubtraction = true;
params.subunitInh = false;
params.model = load('fullModelMAT'); %loads model data
params.model.excNLFuncH = params.model.excWithInfo.params.nlEvaluator;
params.model.inhNLFuncH = params.model.inhWithInfo.params.nlEvaluator;

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

readoutRod = [probTMeansL.rod; probTMeansR.rod];
readoutCone = [probTMeansL.cone; probTMeansR.cone];
readoutComb = [probTMeansL.comb; probTMeansR.comb];


n = (params.repeats-params.sizeTrain) * 2;
rodSuccess = sum(probTMeansL.rod) + sum(probTMeansR.rod);
coneSuccess = sum(probTMeansL.cone) + sum(probTMeansR.cone);
combSuccess = sum(probTMeansL.comb) + sum(probTMeansR.comb);

coneBinary = [probTMeansL.cone; probTMeansR.cone];
rodBinary = [probTMeansL.rod; probTMeansR.rod];
combBinary = [probTMeansL.comb; probTMeansR.comb];
aov = zeros(length(allPulseDelay),1);

for idx = 1:length(allPulseDelay)
    x = [coneBinary(:,idx) combBinary(:,idx)];
    aov(idx) = kruskalwallis(x, [], 'off');
end

[pHatRod,pciRod] = binofit(rodSuccess,n);
[pHatCone,pciCone] = binofit(coneSuccess,n);
[pHatComb,pciComb] = binofit(combSuccess,n);

