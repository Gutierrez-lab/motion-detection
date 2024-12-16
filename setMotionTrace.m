function stimTrace = setMotionTrace(firstBufferLength, ...
    secondBufferLength, pulseLength, pulseContrast, repeats, ...
    meanIntensity)

% Generates a one-pulse stim trace
%
% Input:
%   firstBufferLength  - int with point count before pulse
%   secondBufferLength - int with point count after pulse
%   pulseLength        - int
%   pulseContrast      - double with a contrast to set over mean intensity
%   addNoise           - boolean to randomize over contrast with a gaussian
%   meanIntensity      - double
% 
% Output:
%   stimTrace          - vector

pulseTrace = pulseContrast .* ones(1, pulseLength);

firstBufferTrace = zeros(1, firstBufferLength);
secondBufferTrace = zeros(1, secondBufferLength);
stimTraceContrast = [firstBufferTrace pulseTrace secondBufferTrace];

% If there is no mean, make sure to output in terms of contrast.
if meanIntensity == 0
    stimTrace = stimTraceContrast;
else
    stimTrace = (stimTraceContrast .* meanIntensity) + meanIntensity;
end

stimTrace = repmat(stimTrace, repeats, 1);

end