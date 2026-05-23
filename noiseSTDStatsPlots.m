%% fit a curve to default condition

% load the motionResults for default corr time delay of 50 ms
load('motionResults.mat')
xAxis = allPulseDelay .* 1000; % to get it into ms

PMuComb0 = mean([probTMeansL.comb;probTMeansR.comb]);

f = fit(xAxis',PMuComb0','poly3');

%% plot the grid

noiseSTD = [0.05, 0.2]; % default is 0.1
n = 2*(params.repeats - params.sizeTrain); %total trials per pulse delay

chanceLine = 0.5 .* ones(length(allPulseDelay), 1);

offsetPoints = 0.2;
purpleColor = [0.660156250000000,0.457031250000000,0.816406250000000];

figure;
fon = 16;
idx = 1;
for j = 1:2
    file_str = ['noiseSTDs/results_noiseSTD' num2str(noiseSTD(j)*100)];
    load(file_str)

    PMuRod = mean([probTMeansL.rod;probTMeansR.rod]);
    PMuCone = mean([probTMeansL.cone;probTMeansR.cone]);
    PMuComb = mean([probTMeansL.comb;probTMeansR.comb]);

    [~,pCIRod] = binofit(sum([probTMeansL.rod;probTMeansR.rod]),n);
    [~,pCICone] = binofit(sum([probTMeansL.cone;probTMeansR.cone]),n);
    [~,pCIComb] = binofit(sum([probTMeansL.comb;probTMeansR.comb]),n);

    subplot(1,2,j)
    plot(f,'c'); hold on
    plot(xAxis, chanceLine, 'k-');
    errorbar(xAxis - offsetPoints, PMuRod, PMuRod-pCIRod(:,1)', pCIRod(:,2)'-PMuRod, 'ko', 'MarkerFaceColor', 'b');
    errorbar(xAxis, PMuCone, PMuCone-pCICone(:,1)', pCICone(:,2)'-PMuCone, 'ko', 'MarkerFaceColor', 'r');
    errorbar(xAxis + offsetPoints, PMuComb, PMuComb-pCIComb(:,1)', pCIComb(:,2)'-PMuComb, 'ko', 'MarkerFaceColor', purpleColor);
    plot(xAxis,PMuComb0,'Color',purpleColor);

    title(file_str,'Interpreter','none'); legend('off')
    % xlim([-2 52])
    ylim([0.4 1])
    box('off')
    xlabel('pulse delay, \Deltas (ms)');
    ylabel('accuracy');
    fontsize(fon,"points")
end

