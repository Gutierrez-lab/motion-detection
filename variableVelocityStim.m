function [rodConeReichardtStim, allDelays] = ...
    variableVelocityStim(delayBounds,  ...
    numDelays,  pulseContrast, pulseDur, leftToRight, noiseAmountNorm, ...
    fullInputDur, sampleIntrv, redMean, blueMean)


% Randomise the velocities between the specified bounds
rng(0,'twister');
minDelay = delayBounds(1);
maxDelay = delayBounds(2);
allDelays = (maxDelay-minDelay).*rand(numDelays,1) + minDelay;
allDelaysRounded = round(allDelays ./ sampleIntrv);

% Calculate some vector lengths, from inputs given in seconds
totalStimLength = round(fullInputDur / sampleIntrv);
pulseLength = round(pulseDur / sampleIntrv);
pulseTrace = pulseContrast .* ones(1, pulseLength);

% Find out how much you need to pad the motion stimuli temporally
% to get it to the specified total stimulus length (do this for both the
% left and right subunits)
bufferLength1 = (totalStimLength - pulseLength) / 2;
if (mod(bufferLength1, 2) == 0)
    bufferLength2 = bufferLength1;
else
    bufferLength1 = floor(bufferLength1);
    bufferLength2 = bufferLength1;
end

% Set the stimuli for subunit 1
buffer1 = zeros(numDelays, bufferLength1);
buffer2 = zeros(numDelays, bufferLength2);
pulseRep = repmat(pulseTrace, [numDelays, 1]);

s1Stim = [buffer1 pulseRep buffer2];
s2Stim = zeros(numDelays, totalStimLength);
% Set the stimuli for subunit 2 (which takes into account the variable
% velocity/pulse delays)
for i = 1:numDelays
    delayLength = allDelaysRounded(i);
    delayedBufferLength1 = bufferLength1 + delayLength;
    delayedBufferLength2 = bufferLength2 - delayLength;
    dbuffer1 = zeros(1, delayedBufferLength1);
    dbuffer2 = zeros(1, delayedBufferLength2);
    s2Stim(i,:) = [dbuffer1 pulseTrace dbuffer2];  
end


%% s1Stim = (s1Stim .* meanIntensity) + meanIntensity;

s1.blue = (s1Stim .* blueMean) + blueMean;
s2.blue = (s2Stim .* blueMean) + blueMean;
s1.red = (s1Stim .* redMean) + redMean;
s2.red = (s2Stim .* redMean) + redMean;
    

% Add the type of noise set by the parameters
if noiseAmountNorm ~= 0
    
    % Generate a noise trace for the two different pulse stimuli
    noiseTrace1 = generateNoiseTrace(sampleIntrv, 20, 4, numDelays, ...
        fullInputDur, 0, noiseAmountNorm);
    noiseTrace2 = generateNoiseTrace(sampleIntrv, 20, 4, numDelays, ...
        fullInputDur, 0, noiseAmountNorm);
    
    blueNoiseTrace1 = blueMean .* noiseTrace1;
    blueNoiseTrace2 = blueMean .* noiseTrace2;
    
    % Generate another set of noise so that rod and cone is different
    noiseTraceAlt1 = generateNoiseTrace(sampleIntrv, 20, 4, numDelays, ...
        fullInputDur, 0, noiseAmountNorm);
    noiseTraceAlt2 = generateNoiseTrace(sampleIntrv, 20, 4, numDelays, ...
        fullInputDur, 0, noiseAmountNorm);

    redNoiseTrace1 = redMean .* noiseTraceAlt1;
    redNoiseTrace2 = redMean .* noiseTraceAlt2;
    
    % The noise model is additive (i.e. not signal dependent)?
    s1.blue = s1.blue + blueNoiseTrace1;
    s1.red = s1.red + redNoiseTrace1;
    
    s2.blue = s2.blue + blueNoiseTrace2;
    s2.red = s2.red + redNoiseTrace2;
        
end

% Designate the direction of motion
if leftToRight
    leftStim = s1;
    rightStim = s2;
else
    leftStim = s2;
    rightStim = s1;
end

rodConeReichardtStim.leftStim = leftStim;
rodConeReichardtStim.rightStim = rightStim;

end
