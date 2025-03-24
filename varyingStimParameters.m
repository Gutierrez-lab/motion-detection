clearvars;
plotSettings;

figure;

pulseDur = [0.02 0.01 0.005];
pulseContrast = [0.5 1 1.5];

tic
position = 1;
for i = 1:length(pulseContrast)
    params.pulseDur = pulseDur(i);
    for j = 1:length(pulseDur)
        
        params.pulseContrast = pulseContrast(j);

        parameterRunMain;

        offsetPoints = 0.5;

        % convert pulse delays from seconds to milliseconds
        xAxis = allPulseDelay .* 1000;

        customPurpleColour = [0.66,0.46,0.82];

        testTrials = (params.repeats-params.sizeTrain) * 2;
        chanceLine = testTrials / 2 .* ones(length(allPulseDelay), 1);

        subplot(3,3,position);
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

        ylim([460 1000]);
        xlim([-1 52]);
        yticks([500 1000]);

        if position < 8
            xticks([]);
        end

        xlabel([num2str(params.pulseDur) '   ' num2str(params.pulseContrast)]);

    end
end

toc