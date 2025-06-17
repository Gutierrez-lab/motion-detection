clearvars;

dt = [50 25];
totalLength = 1000;
pulseWidth = 0:5:100;
stimDelay = 0:5:100;

overlap = zeros(length(pulseWidth), length(stimDelay));
condition = overlap;

for d = 1:length(dt)
    for i = 1:length(pulseWidth)
        for j = 1:length(stimDelay)
            pulseTrace = ones(1,pulseWidth(i));
            stimTrace1 = [pulseTrace zeros(1,totalLength-pulseWidth(i))];
            stimTrace1DT = circshift(stimTrace1, dt(d));

            stimTrace2 = [zeros(1, stimDelay(j)), pulseTrace, ...
                zeros(1, totalLength - (stimDelay(j) + pulseWidth(i)))];

            s = stimTrace1DT .* stimTrace2;

            if sum(s) > 0
                overlap(i,j) = true;
            else
                overlap(i,j) = false;
            end
        end
    end

    % xVal = repmat(pulseWidth, length(stimDelay), 1);
    % yVal = repmat(stimDelay', 1, length(pulseWidth));

    figure(102); 
    subplot(length(dt), 1, d);
    heatmap(stimDelay, flip(pulseWidth), flip(overlap,1));
    colorbar('off')
    ylabel('pulse width (ms)');
    xlabel('stim delay (ms)')
    title(['HR delay = ', num2str(dt(d)), ' ms']);
end


% figure; plot(stimTrace1DT); hold on; plot(stimTrace2)