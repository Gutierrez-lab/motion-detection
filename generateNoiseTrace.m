% Modified from rieke-package
function [out, seed] = generateNoiseTrace(sampleIntrv, ...
    frequencyCutoff, noiseFilterCount, traceCount, traceDuration, ...
    varargin)

numvarargs = length(varargin);

if numvarargs > 3
    error('Too many input arguments');
elseif numvarargs == 3
    stimMean = varargin{1};
    stimSTD = varargin{2};
    seed = varargin{3};
    scaleStimMean = true;
    scaleStimSTD = true;
elseif numvarargs == 2
    stimMean = varargin{1};
    stimSTD = varargin{2};
    scaleStimMean = true;
    scaleStimSTD = true;
elseif numvarargs == 1
    stimMean = varargin{1};
    scaleStimMean = true;
    scaleStimSTD = false;
else
    scaleStimMean = false;
    scaleStimSTD = false;
end

% Generates the length of trace
stimPts = round(traceDuration / sampleIntrv);

% Quits if it finds you have an odd number length filter
assert(mod(stimPts,2) == 0);

% Create gaussian noise with one rng stream.
if ~exist('seed')
    rngInstance = rng('shuffle');
    seed = rngInstance.Seed; 
end
stream = RandStream('mt19937ar', 'Seed', seed);
stimTrace = stream.randn(traceCount, stimPts);
stimTraceFft = fft(stimTrace, [], 2);

% Construct the filter.
freqStep = 1 / (sampleIntrv * stimPts);
frequencies = (0:stimPts / 2) * freqStep;
oneSidedFilter = 1 ./ (1 + (frequencies / frequencyCutoff) .^ ...
    (2 * noiseFilterCount));
filter = [oneSidedFilter fliplr(oneSidedFilter(2:end - 1))];
filter = repmat(filter, traceCount, 1);

% Apply the filter!
stimTraceFft = stimTraceFft .* filter;
stimTraceFft(1) = 0;
filteredStimTrace = (ifft(stimTraceFft, [], 2));

out = real(filteredStimTrace);

% Now we scale to match the desired mean and STD.
if scaleStimSTD
    out = out .* (stimSTD / std(out(:)));
end

if scaleStimMean
    out = out + (stimMean .* ones(1, stimPts));
end

end