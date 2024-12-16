function prediction = passToNonlinearity(generatorSignal, nlFn, fnParams)
% Computes predicted responses given stimuli, linear filter, and nonlinear function.
% Input:
%   filter    - vector containing the linear filter
%   stim      - matrix of row vectors containing stimuli
%   nlFn      - handle for function that evaluates the nonlinearity
%   fnParams  - structure countaining params for the nonlinear function
%   filterHasAnticausalHalf  - boolean

if isequal(nlFn, @polyval)
    prediction = nlFn(fnParams.coeff, generatorSignal, [], fnParams.mu);
elseif isequal(nlFn, @piecewisePoly)
    prediction = nlFn(generatorSignal, fnParams.p1, fnParams.p2, ...
        fnParams.mu1, fnParams.mu2, fnParams.dividingLine);
elseif isequal(nlFn, @piecewiseCGauss)
    prediction = nlFn(generatorSignal, fnParams.beta1, fnParams.beta2, ...
        fnParams.dividingLine);
elseif isequal(nlFn, @evalSigmoid)
    error('not implemented yet')
else
    error('not recognized function')
end

end
