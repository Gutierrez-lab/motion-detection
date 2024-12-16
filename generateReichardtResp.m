function reichardtOut = generateReichardtResp(model, stim, subunitType, ...
    subunitInh, subDelay, sampleIntrv, productSubtraction)

% Set the stimulus struct such that it can run with the specified subunit.
if contains(subunitType, 'shared')
    leftStim.combinedRod = stim.leftStim.blue;
    leftStim.combinedCone = stim.leftStim.red;
    rightStim.combinedRod = stim.rightStim.blue;
    rightStim.combinedCone = stim.rightStim.red;

elseif strcmp(subunitType, 'separateRod')
    leftStim.rod = stim.leftStim.blue;
    rightStim.rod = stim.rightStim.blue;
    
elseif strcmp(subunitType, 'separateCone')
    leftStim.cone = stim.leftStim.red;
    rightStim.cone = stim.rightStim.red;
    
end

% Run the stimuli
[~, respL] = runRodConeModel(model.exc.filters, model.exc.nlFuncs, ...
    leftStim, subunitType, model.excNLFuncH);
[~, respR] = runRodConeModel(model.exc.filters, model.exc.nlFuncs, ...
    rightStim, subunitType, model.excNLFuncH);

% Add inhibition if this is specified.
if subunitInh
    [~, inhL] = runRodConeModel(model.inh.filters, model.inh.nlFuncs, ...
        leftStim, subunitType, model.inhNLFuncH);
    [~, inhR] = runRodConeModel(model.inh.filters, model.inh.nlFuncs, ...
        rightStim, subunitType, model.inhNLFuncH);
    
else
    inhL = 0;
    inhR = 0;
end

% Convert from current input to spike output
excScalar = 3;
thresh = true;
respL = combineExcAndInhTraces(respL, inhL, excScalar, thresh);
respR = combineExcAndInhTraces(respR, inhR, excScalar, thresh);

% Set the delay trace
lengthDT = round(subDelay ./ sampleIntrv);
respLDT = circshift(respL, lengthDT, 2);
respRDT = circshift(respR, lengthDT, 2);

% Calculate the Reichardt subunit output products
product1 = respLDT .* respR; 
product2 = respL .* respRDT;

% Designate the output based on whether a subtraction (for stimulus induced
% correlations is removed from the coincidence detector output) is desired
% or not
if productSubtraction
    reichardtOut = product1 - product2;
else
    reichardtOut = product1;
end

end