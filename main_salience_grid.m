%% Let's get started
tic

% load the parameters so we can use them consistently in this simulation
load('modelParameters.mat')

% variable stim params
pulseContrasts = [0.5, 1, 1.5]; % 50%, 100%, 150%
pulseDurations = [0.005, 0.01, 0.02]; % 5, 10, 20 ms
allPulseDelay = 0:0.01:0.05; % shorter range than default

% params.pulseContrast = 1; % 100%
% params.pulseDur = 0.01; % pulse width: 10 ms by default

%% runs all experiment combos

for k = 1:length(pulseDurations)
    params.pulseDur = pulseDurations(k);

    for j = 1:length(pulseContrasts)
        params.pulseContrast = pulseContrasts(j);
        file_str = ['salienceGrid/results_Dur' num2str(params.pulseDur*1000) '_Con' num2str(params.pulseContrast*100)];

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
end

