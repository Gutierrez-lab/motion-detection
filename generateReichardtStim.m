function rodConeReichardtStim = generateReichardtStim(pulseDur, ...
    pulseDelay,  pulseContrast, leftToRight, noiseAmountNorm, ...
    fullInputDur, sampleIntrv, redMean, blueMean, repeats)

% Calculate some vector lengths, from inputs given in seconds
pulseLength = round(pulseDur / sampleIntrv);
delayLength = round(pulseDelay / sampleIntrv);
% pulseAndDelayLength = pulseLength + delayLength;
totalStimLength = round(fullInputDur / sampleIntrv);

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
delayedBufferLength1 = bufferLength1 + delayLength;
delayedBufferLength2 = bufferLength2 - delayLength;

% bufferLength1 = 0;
% bufferLength2 = totalStimLength - pulseLength;
% delayedBufferLength1 = delayLength;
% delayedBufferLength2 = totalStimLength - pulseAndDelayLength;

% Generate pulse traces for red and blue
s1.blue = setMotionTrace(bufferLength1, bufferLength2, ...
    pulseLength, pulseContrast, repeats, blueMean);
s2.blue = setMotionTrace(delayedBufferLength1, delayedBufferLength2, ...
    pulseLength, pulseContrast, repeats, blueMean);

s1.red = setMotionTrace(bufferLength1, bufferLength2, ...
    pulseLength, pulseContrast, repeats, redMean);
s2.red = setMotionTrace(delayedBufferLength1, delayedBufferLength2, ...
    pulseLength, pulseContrast, repeats, redMean);

% Add the type of noise set by the parameters
if noiseAmountNorm ~= 0
    
    % Generate a noise trace for the two different pulse stimuli
    noiseTrace1 = generateNoiseTrace(sampleIntrv, 20, 4, repeats, ...
        fullInputDur, 0, noiseAmountNorm);
    noiseTrace2 = generateNoiseTrace(sampleIntrv, 20, 4, repeats, ...
        fullInputDur, 0, noiseAmountNorm);
    
    blueNoiseTrace1 = blueMean .* noiseTrace1;
    blueNoiseTrace2 = blueMean .* noiseTrace2;
    
    % if corrlNoise
    %     redNoiseTrace1 = redMean .* noiseTrace1;
    %     redNoiseTrace2 = redMean .* noiseTrace2;
    % else
        % Generate another set of noise so that rod and cone is different
        noiseTraceAlt1 = generateNoiseTrace(sampleIntrv, 20, 4, repeats, ...
            fullInputDur, 0, noiseAmountNorm);
        noiseTraceAlt2 = generateNoiseTrace(sampleIntrv, 20, 4, repeats, ...
            fullInputDur, 0, noiseAmountNorm); 
        
        redNoiseTrace1 = redMean .* noiseTraceAlt1;
        redNoiseTrace2 = redMean .* noiseTraceAlt2;
        
    % end
    
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
