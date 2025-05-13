clearvars;
plotSettings;

figure;
params.subDelay = 0.05;
pulseDur = [0.02 0.01 0.005];
pulseContrast = [0.5 1 1.5];
allPulseDelay = 0:0.01:0.05;

aovAll = ...
    zeros(length(allPulseDelay), length(pulseContrast) * length(pulseDur));
tic
position = 1;
for i = 1:length(pulseContrast)
    params.pulseDur = pulseDur(i);
    for j = 1:length(pulseDur)
        
        params.pulseContrast = pulseContrast(j);

        parameterRun;

        aovAll(:,position) = aov;

        errorLengthRod = pciRod - [pHatRod' pHatRod'];
        errorLengthCone = pciCone - [pHatCone' pHatCone'];
        errorLengthComb = pciComb - [pHatComb' pHatComb'];

        offsetPoints = 0.5;

        % convert pulse delays from seconds to milliseconds
        xAxis = allPulseDelay .* 1000;

        customPurpleColour = [0.66,0.46,0.82];

        chanceLine = 0.5 .* ones(1,length(xAxis));

        subplot(3,3,position);
        position = position + 1;
        
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

        ylim([0.48 1]);
        xlim([-1 52]);
        yticks([0.5 1]);

        if position < 8
            xticks([]);
        end

        xlabel([num2str(params.pulseDur) '   ' num2str(params.pulseContrast)]);

    end
end

toc