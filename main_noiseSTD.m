%% Let's get started
tic

% load the parameters so we can use them consistently in this simulation
load('modelParameters.mat')

params.pulseContrast = 1; % 100%
params.pulseDur = 0.01; % pulse width: 10 ms by default

noiseSTD = [0.05, 0.2]; % default is 0.1

%% runs all experiment combos

for j = 1:length(noiseSTD)
    params.noiseAmountNorm = noiseSTD(j); %50 ms
    file_str = ['noiseSTDs/results_noiseSTD' num2str(params.noiseAmountNorm*100)];

    p = zeros(size(allPulseDelay));
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
        [probTMeansL.rod(:,i), probTMeansR.rod(:,i), ...
            pRodLL, pRodLR, pRodRR, pRodRL] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward);

        %cone only
        params.subunitType = 'separateCone';
        [probTMeansL.cone(:,i), probTMeansR.cone(:,i), ...
            pConeLL, pConeLR, pConeRR, pConeRL] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward);

        % true model
        params.subunitType = 'sharedComb';
        [probTMeansL.comb(:,i), probTMeansR.comb(:,i)] = ...
            reichardtTrialSet(params, stimLeftward, stimRightward);

        % Kruskal-Wallis test/Mann-Whitney U test
        % to compare combined model to cone-only
        p(i) = kruskalwallis([[probTMeansL.comb(:,i);probTMeansR.comb(:,i)],[probTMeansL.cone(:,i);probTMeansR.cone(:,i)]],[],'off');
    end

    save(file_str,'params','probTMeansL','probTMeansR','p','allPulseDelay')
    toc
end


