%% fit a curve to default condition

% load the motionResults for default corr time delay of 50 ms
load('motionResults.mat')

%Stimulus intensities
xAxis = allPulseDelay .* 1000; % to get it into ms
% Format inputs as [NumConditions x NumStimLevels] matrices
StimLevels = [xAxis; xAxis; xAxis];

%Number of positive responses (e.g., 'yes' or 'correct' at each of the 
%   entries of the Stim Levels)  
SuccessesComb = sum([probTMeansL.comb;probTMeansR.comb]);
SuccessesCone = sum([probTMeansL.cone;probTMeansR.cone]);
SuccessesRod = sum([probTMeansL.rod;probTMeansR.rod]);
NumPos = [SuccessesCone; SuccessesComb; SuccessesRod]; 

%Number of trials at each entry of 'StimLevels'
N = 2*(params.repeats-params.sizeTrain);
Ntrials = N.*ones(size(SuccessesComb));
OutOfNum = N .* ones(size(NumPos));

%Use the Logistic function
PF = @PAL_Weibull; %@PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull,
                     %PAL_Quick, PAL_logQuick,
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter
%Guesses for free parameters, fixed values for fixed parameters
paramsInit = [15, 1, 0.5, 0.01];

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = min(xAxis):max(xAxis); %0.01:.001:.11; %thresholds, i.e. half(max-min)
searchGrid.beta = logspace(0,3,101); %slopes
searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.01; %0:0.001:0.01;  %ditto %lapse rate. let it be non-zero.

%Perform fit
% Fit the Restricted Model (Constrained Equal)
% We force both conditions to share a single common threshold and slope.
% [paramsL, LLRestr] = PAL_PFML_FitMultiple(...
%     StimLevels, NumPos, OutOfNum, paramsInit, PF, ...
%     'thresholds', 'constrained','slopes', 'constrained', ...
%     'guessrates','fixed','lapserates','constrained',...
%     'lapseLimits',lapseLimits, 'searchOptions', options);
% 
% % Fit the Full Model (Unconstrained)
% [paramsF, LLFull] = PAL_PFML_FitMultiple(...
%     StimLevels, NumPos, OutOfNum, paramsL, PF, ...
%     'thresholds', 'unconstrained', 'slopes', 'unconstrained', ...
%     'guessrates','fixed','lapserates','unconstrained',...
%     'lapseLimits',lapseLimits, 'searchOptions', options);

% Could do one at a time for fun. Results are exactly the same as above.
disp('Fitting function.....');
[paramsValuesComb, LL, exitflag] = PAL_PFML_Fit(xAxis,SuccessesComb,Ntrials,searchGrid,paramsFree,PF);
[paramsValuesCone, LL, exitflag] = PAL_PFML_Fit(xAxis,SuccessesCone,Ntrials,searchGrid,paramsFree,PF);
[paramsValuesRod, LL, exitflag] = PAL_PFML_Fit(xAxis,SuccessesRod,Ntrials,searchGrid,paramsFree,PF);

disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValuesComb(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValuesComb(2));
disp(message);

%% Standard errors
%Number of simulations to perform to determine standard error
B=400;                  

disp('Determining standard errors.....');
ParOrNonPar = 2;
if ParOrNonPar == 1
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(...
        xAxis, Ntrials, paramsValuesComb, paramsFree, B, PF, ...
        'searchGrid', searchGrid);
else
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapNonParametric(...
        xAxis, SuccessesComb, Ntrials, [], paramsFree, B, PF,...
        'searchGrid',searchGrid);
end

disp('done:');
message = sprintf('Standard error of Threshold: %6.4f',SD(1));
disp(message);
message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
disp(message);

%% Goodness of fit
%Number of simulations to perform to determine Goodness-of-Fit
B=1000;

disp('Determining Goodness-of-fit.....');

[Dev pDev] = PAL_PFML_GoodnessOfFit(xAxis, SuccessesComb, Ntrials, ...
    paramsValuesComb, paramsFree, B, PF, 'searchGrid', searchGrid);

disp('done:');

%Put summary of results on screen
message = sprintf('Deviance: %6.4f',Dev);
disp(message);
message = sprintf('p-value: %6.4f',pDev);
disp(message);

%Create simple plot
ProportionCorrectObservedComb = SuccessesComb./Ntrials; 
ProportionCorrectObservedCone = SuccessesCone./Ntrials; 
ProportionCorrectObservedRod = SuccessesRod./Ntrials; 
StimLevelsFineGrain=[min(xAxis):max(xAxis)./1000:max(xAxis)];
ProportionCorrectModelComb = PF(paramsValuesComb,StimLevelsFineGrain);
ProportionCorrectModelCone = PF(paramsValuesCone,StimLevelsFineGrain);
ProportionCorrectModelRod = PF(paramsValuesRod,StimLevelsFineGrain);

%% Psychometric fit figure
figure('name','Maximum Likelihood Psychometric Function Fitting');
purpleColor = [0.66, 0.46, 0.82];
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModelCone,'-','color','r','linewidth',4);
plot(StimLevelsFineGrain,ProportionCorrectModelComb,'-','color',purpleColor,'linewidth',4);
plot(StimLevelsFineGrain,ProportionCorrectModelRod,'-','color','b','linewidth',4);

plot(xAxis,ProportionCorrectObservedCone,'ko', 'MarkerFaceColor', 'r');
plot(xAxis,ProportionCorrectObservedComb,'ko', 'MarkerFaceColor', purpleColor);
plot(xAxis,ProportionCorrectObservedRod,'ko', 'MarkerFaceColor', 'b');

% Plot Chance Line
plot([0 max(xAxis)], [0.5 0.5], 'k--', 'LineWidth', 1);

legend('Cone','Rod+Cone','Rod','Location','East')
xlabel('Pulse Delay, \Deltas (ms)');
ylabel('Accuracy'); %'Proportion Correct'
set(gca,'FontSize',16)
xlim([xAxis(1)-2, xAxis(end)+2])

set(gca, 'fontsize',16);
set(gca, 'Xtick',xAxis);
% axis([min(xAxis) max(xAxis) .4 1]);

%% Figure with data and psychometric fits
figure;
purpleColor = [0.66, 0.46, 0.82];
offsetPoints = 0.2;
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModelCone,'-','color','r','linewidth',4);
plot(StimLevelsFineGrain,ProportionCorrectModelComb,'-','color',purpleColor,'linewidth',4);
plot(StimLevelsFineGrain,ProportionCorrectModelRod,'-','color','b','linewidth',4);

PMuRod = mean([probTMeansL.rod(1:500,:);probTMeansR.rod(1:500,:)]);
PMuCone = mean([probTMeansL.cone(1:500,:);probTMeansR.cone(1:500,:)]);
PMuComb = mean([probTMeansL.comb(1:500,:);probTMeansR.comb(1:500,:)]);

% Clopper-Pearson confidence intervals
n = 1000; %total trials per pulse delay
[~,pCIRod] = binofit(sum([probTMeansL.rod(1:500,:);probTMeansR.rod(1:500,:)]),n);
[~,pCICone] = binofit(sum([probTMeansL.cone(1:500,:);probTMeansR.cone(1:500,:)]),n);
[~,pCIComb] = binofit(sum([probTMeansL.comb(1:500,:);probTMeansR.comb(1:500,:)]),n);


errorbar(xAxis - offsetPoints, PMuRod, PMuRod - pCIRod(:,1)', pCIRod(:,2)' - PMuRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
errorbar(xAxis, PMuCone, PMuCone-pCICone(:,1)', pCICone(:,2)'-PMuCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
errorbar(xAxis + offsetPoints, PMuComb, PMuComb-pCIComb(:,1)', pCIComb(:,2)'-PMuComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;

% Plot Chance Line
plot([0 max(xAxis)], [0.5 0.5], 'k--', 'LineWidth', 1);

% legend('Cone','Rod+Cone','Rod','Location','East')
xlabel('Pulse Delay, \Deltas (ms)');
ylabel('Accuracy'); %'Proportion Correct'
set(gca,'FontSize',16)
xlim([xAxis(1)-2, xAxis(end)+2])

set(gca, 'fontsize',16);
set(gca, 'Xtick',xAxis);