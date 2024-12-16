function output = combineExcAndInhTraces(iExc, iInh, excScalar, thresh)
% Converts excitatory and inhibitory current traces into a trace that
% estimates a cell's spike rate. Thresholding built in disallows negative
% spike rates.

% Input:
%   exc           - a matrix of excitatory current row vectors
%   inh           - a matrix of inhibitory current row vectors
%   excScalar     - a double that scales exc relative to inh trace

% Output:
%   output        - a matrix 
    
    vRevExc = 0;
    vRevInh = -60; 
    
    dForceExc = vRevInh - vRevExc;
    dForceInh = vRevExc - vRevInh;
    
    gExc = iExc ./ dForceExc;
    gInh = iInh ./ dForceInh;
    
    output = (excScalar .* gExc) - gInh;
    
%      output = (excScalar .* iExc) + iInh;
%      output = -output / 60;

    if thresh
        output(output < 0) = 0;
    end
    
end