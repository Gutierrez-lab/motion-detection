clearvars;
plotSettings;

figure;

params.pulseDur = 0.01; 
params.pulseContrast = 1; 
subDelay = [0.025 0.05 0.1];

tic
position = 1;
for i = 1:length(subDelay)
        
        params.subDelay = subDelay(1,i);

        parameterRunMain;

        offsetPoints = 0.5;

        % convert pulse delays from seconds to milliseconds
        xAxis = allPulseDelay .* 1000;

        customPurpleColour = [0.66,0.46,0.82];

        testTrials = (params.repeats-params.sizeTrain) * 2;
        chanceLine = testTrials / 2 .* ones(length(allPulseDelay), 1);

        subplot(3,1,position);
        position = position + 1;
        errorbar(xAxis - offsetPoints, rodMu, rodSigma, 'ko', ...
            'MarkerFaceColor', 'b');
        hold on;
        errorbar(xAxis, coneMu, coneSigma, 'ko', ...
            'MarkerFaceColor', 'r');
        hold on;
        errorbar(xAxis + offsetPoints, combMu, combSigma, 'ko', ...
            'MarkerFaceColor', customPurpleColour); hold on;
        hold on;
        plot(xAxis, chanceLine, 'k-');

        
        % ylim([460 1000]);
        % xlim([-1 52]);
        yticks([500 1000]);

        delayInMS = params.subDelay * 1000;
        xlabel(['delay = ' num2str(delayInMS) 'ms']);

end

toc