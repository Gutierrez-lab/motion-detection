function [output, genSig] = runRodConeModel(filters, nlFuncs, stims, ...
    runType, nlEvaluator)

% Computes predicted responses given stimuli, filter, nonlinearity, and
% the type of forward run

% Input:
%   filters    - struct containing rod and cone filter vectors
%   stims      - struct containing rod and cone stimuli matrices
%   nlFuncs    - struct containing nonlinearity polynomial fits and scaling
%   runType    - string that's either 'sharedRod', 'sharedCone', or
%                'separateRod', 'separateCone', or 'sharedComb',
%                'separateComb'
% Output:
%   output     - a struct containing predicted current input traces
%   genSig     - a struct containing generator signal values

antiCausal = false;

if strcmp(runType, 'separateRod')
    genSig = convolveFilterWithStim(filters.rod, stims.rod, antiCausal);
    output = passToNonlinearity(genSig, nlEvaluator, nlFuncs.rod);

elseif strcmp(runType, 'separateCone')
    genSig = convolveFilterWithStim(filters.cone, stims.cone, antiCausal);
    output = passToNonlinearity(genSig, nlEvaluator, nlFuncs.cone);

elseif strcmp(runType, 'separateComb')
    gsRod = convolveFilterWitheStim(filters.rod, stims.combinedRod, antiCausal);
    gsCone = convolveFilterWithStim(filters.cone, stims.combinedCone, antiCausal);
    
    rodPredict = passToNonlinearity(gsRod, nlEvaluator, nlFuncs.rod);
    conePredict = passToNonlinearity(gsCone, nlEvaluator, nlFuncs.cone);
    
    genSig.rod = gsRod;
    genSig.cone = gsCone;
    output = rodPredict + conePredict;
    
elseif strcmp(runType, 'sharedRod')
    genSig = convolveFilterWithStim(filters.rod, stims.rod, antiCausal);
    output = passToNonlinearity(genSig, nlEvaluator, nlFuncs.combined);
    
elseif strcmp(runType, 'sharedCone')
    genSig = convolveFilterWithStim(filters.scaledCone, stims.cone, antiCausal);
    output = passToNonlinearity(genSig, nlEvaluator, nlFuncs.combined);
    
elseif strcmp(runType, 'sharedComb')
    gsRod = convolveFilterWithStim(filters.rod, stims.combinedRod, antiCausal);
    gsCone = convolveFilterWithStim(filters.scaledCone, stims.combinedCone, antiCausal);
    
    genSig = gsRod + gsCone;
    
    output = passToNonlinearity(genSig, nlEvaluator, nlFuncs.combined);
    
else
    error('run type string not recognized');
end

end



