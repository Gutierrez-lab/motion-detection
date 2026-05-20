%% fit a curve to default condition

% load the motionResults for default corr time delay of 50 ms
load('motionResults.mat')
xAxis = allPulseDelay .* 1000; % to get it into ms

PMuComb0 = mean([probTMeansL.comb;probTMeansR.comb]);

f = fit(xAxis',PMuComb0','poly3');

%% plot the grid

corrTimeDelays = [0.025, 0.075]; % 25, 75 ms
n = 2*(params.repeats - params.sizeTrain); %total trials per pulse delay

chanceLine = 0.5 .* ones(length(allPulseDelay), 1);

offsetPoints = 0.2;
purpleColor = [0.660156250000000,0.457031250000000,0.816406250000000];

figure;
idx = 1;
for j = 1:2
    file_str = ['corrTimeDels/results_CTDelay' num2str(corrTimeDelays(j)*1000)];
    load(file_str)

    PMuRod = mean([probTMeansL.rod;probTMeansR.rod]);
    PMuCone = mean([probTMeansL.cone;probTMeansR.cone]);
    PMuComb = mean([probTMeansL.comb;probTMeansR.comb]);

    [~,pCIRod] = binofit(sum([probTMeansL.rod;probTMeansR.rod]),n.*ones(1,length(allPulseDelay)));
    [~,pCICone] = binofit(sum([probTMeansL.cone;probTMeansR.cone]),n.*ones(1,length(allPulseDelay)));
    [~,pCIComb] = binofit(sum([probTMeansL.comb;probTMeansR.comb]),n.*ones(1,length(allPulseDelay)));

    subplot(1,2,idx)
    plot(f,'c'); hold on
    plot(xAxis, chanceLine, 'k-');
    errorbar(xAxis - offsetPoints, PMuRod, PMuRod - pCIRod(:,1)', pCIRod(:,2)' - PMuRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
    errorbar(xAxis, PMuCone, PMuCone-pCICone(:,1)', pCICone(:,2)'-PMuCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
    errorbar(xAxis + offsetPoints, PMuComb, PMuComb-pCIComb(:,1)', pCIComb(:,2)'-PMuComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;

    title(file_str); legend('off')
    xlabel('')
    ylabel('')
    xlim([-2 52])
    ylim([0.45 1])
    box('off')
    xlabel('pulse delay, \Deltas (ms)');
    ylabel('accuracy');

    idx = idx+1;
end

