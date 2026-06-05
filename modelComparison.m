%% Palamedes Model Comparison Script: Comb vs Cone
% This script uses the correct PAL_PFML_FitMultiple function to compare
% a full model (independent curves) against a restricted model (shared parameters)
% via a Likelihood Ratio Test.

clearvars;
close all;

%% 1. Load and Format Your Data
load('motionResults.mat'); % Contains allPulseDelay, probTMeansL, probTMeansR, params

% Setup Independent Variable (X-axis) in ms
xAxis = allPulseDelay .* 1000; 
NumConditions = 2; % Condition 1: Cone, Condition 2: Comb

% Format inputs as [NumConditions x NumStimLevels] matrices
StimLevels = repmat(xAxis, NumConditions, 1);

SuccessesCone = sum([probTMeansL.cone; probTMeansR.cone], 1);
SuccessesComb = sum([probTMeansL.comb; probTMeansR.comb], 1);
NumPos = [SuccessesCone; SuccessesComb]; 

N_trials_per_delay = 2 * (params.repeats - params.sizeTrain);
OutOfNum = N_trials_per_delay .* ones(size(NumPos));

% Use the Weibull function as selected in defaultStatsPlots.m
PF = @PAL_Weibull; 

% Options for the Nelder-Mead optimization search
options = PAL_minimize('options');
% % % may need more options from PAL_PFLR_Demo.m % % %

%% 2. Fit the Full Model (Unconstrained)
% We allow thresholds and slopes to vary freely across conditions.
% 'thresholds', 'unconstrained' means separate thresholds.
% 'slopes', 'unconstrained' means separate slopes.

% initParamsFull = [15.0, 2.0, 0.5, 0.0]; % [Threshold, Slope, Guess, Lapse]
% paramsFreeFull = [1 1 0 1]; % Free: Threshold & Slope. Fixed: Guess (0.5) & Lapse (0).

%Guesses for free parameters, fixed values for fixed parameters
params = [15, 1, 0.5, 0.01];    %or e.g.: [0 1 .5 0; 0 1 .5 0];

[paramsF, LLFull] = PAL_PFML_FitMultiple(...
    StimLevels, NumPos, OutOfNum, params, PF, ...
    'thresholds', 'unconstrained', ...
    'slopes', 'unconstrained', ...
    'searchOptions', options);

% Extract independent thresholds and slopes
thresholdsFull = paramsF(:,1);
slopesFull = paramsF(:,2);
NumParamsFull = 4; % 2 thresholds + 2 slopes

fprintf('--- Full Model Fit (Separate Curves) ---\n');
fprintf('Cone -> Threshold: %6.2f ms, Slope: %6.2f\n', thresholdsFull(1), slopesFull(1));
fprintf('Comb -> Threshold: %6.2f ms, Slope: %6.2f\n', thresholdsFull(2), slopesFull(2));
fprintf('Total Log-Likelihood: %6.2f\n\n', LLFull);

%plot fitted functions
figure; hold on
purpleColor = [0.660156250000000,0.457031250000000,0.816406250000000];

ProportionCorrectObserved = NumPos ./ OutOfNum; 
StimLevelsFineGrain = [min(min(StimLevels)):(max(max(StimLevels) - ... 
    min(min(StimLevels))))./1000:max(max(StimLevels))];

ProportionCorrectModel = PF(paramsF(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color','r');
ProportionCorrectModel = PF(paramsF(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',purpleColor);

plot(StimLevels(1,:),ProportionCorrectObserved(1,:),'ko','markersize',...
    10,'markerfacecolor','r');
plot(StimLevels(2,:),ProportionCorrectObserved(2,:),'ko','markersize',...
    10,'markerfacecolor',purpleColor);

xlabel('Stimulus Intensity');
ylabel('Proportion Correct');


%% 3. Fit the Restricted Model (Constrained Equal)
% We force both conditions to share a single common threshold and slope.
% 'thresholds', 'equal' forces threshold(Cone) == threshold(Comb)
% 'slopes', 'equal' forces slope(Cone) == slope(Comb)

[constrainedParams, LLRestr] = PAL_PFML_FitMultiple(...
    StimLevels, NumPos, OutOfNum, initParamsFull, paramsFreeFull, PF, ...
    'thresholds', 'equal', ...
    'slopes', 'equal', ...
    'searchOptions', options);

% In 'equal' mode, Palamedes outputs the same shared parameters for both rows
sharedThreshold = constrainedParams(1,1);
sharedSlope = constrainedParams(1,2);
NumParamsRestr = 2; % 1 Shared Threshold + 1 Shared Slope

fprintf('--- Restricted Model Fit (Equal Curves) ---\n');
fprintf('Shared Threshold: %6.2f ms, Shared Slope: %6.2f\n', sharedThreshold, sharedSlope);
fprintf('Total Log-Likelihood: %6.2f\n\n', LLRestr);

%% 4. Likelihood Ratio Test (LRT) Comparison
TLR = 2 * (LLFull - LLRestr);
df = NumParamsFull - NumParamsRestr; % Degrees of freedom (4 - 2 = 2)

% Calculate p-value using the Chi-Square Distribution
p_value = 1 - chi2cdf(TLR, df);

fprintf('--- Statistical Comparison ---\n');
fprintf('LRT Statistic (TLR): %6.2f\n', TLR);
fprintf('Degrees of Freedom: %d\n', df);
fprintf('p-value: %e\n', p_value);
if p_value < 0.05
    fprintf('Result: SIGNIFICANT (p < 0.05). The Comb and Cone curves are statistically distinct.\n');
else
    fprintf('Result: NOT SIGNIFICANT. The curves can be modeled with identical parameters.\n');
end

%% 5. Generate Plots (Matching your custom figure style)
figure('Position', [100, 100, 850, 550]);
fineX = linspace(0, max(xAxis), 200);
purpleColor = [0.66, 0.46, 0.82];

% Plot Raw Data Points
plot(xAxis, NumPos(1,:)./OutOfNum(1,:), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8); hold on;
plot(xAxis, NumPos(2,:)./OutOfNum(2,:), 'ko', 'MarkerFaceColor', purpleColor, 'MarkerSize', 8);

% Plot Full Model Fits (Smooth Curves)
fitCone = PF([thresholdsFull(1), slopesFull(1), 0.5, 0.0], fineX);
fitComb = PF([thresholdsFull(2), slopesFull(2), 0.5, 0.0], fineX);
plot(fineX, fitCone, 'r-', 'LineWidth', 2);
plot(fineX, fitComb, '-', 'Color', purpleColor, 'LineWidth', 2);

% Plot Chance Line
plot([0 max(xAxis)], [0.5 0.5], 'k--', 'LineWidth', 1);

% Graph Adjustments
title(sprintf('Model Comparison Fit (p = %e)', p_value), 'FontSize', 14);
xlabel('Pulse Delay (ms)', 'FontSize', 12);
ylabel('Accuracy (Proportion Correct)', 'FontSize', 12);
ylim([0.4 1.05]);
xlim([-2 max(xAxis)+2]);
legend('Cone Data', 'Comb Data', 'Cone Fit', 'Comb Fit', 'Chance Floor', 'Location', 'Southeast');
grid on;
set(gca, 'FontSize', 11);