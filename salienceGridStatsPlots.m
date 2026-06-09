%% fit a curve to default condition

% load('salienceGrid/results_Dur10_Con100.mat')
pulseContrasts = [0.5, 1, 1.5]; % 50%, 100%, 150%
pulseDurationsrev = [0.02, 0.01, 0.005]; % 5, 10, 20 ms but reversed to making plotting the grid easy
allPulseDelay = 0:0.01:0.05; % shorter range than default

xAxis = allPulseDelay .* 1000; % to get it into ms

% load the model fit
load('modelFitComb.mat')

%% plot the grid - the old way
% but this time with the default rod+cone curve fit on each plot
Nsamples = 500; % 500 samples on each side = 1,000 total per condition
n = 2*Nsamples; %total trials per pulse delay
% n = 2*(params.repeats - params.sizeTrain); %total trials per pulse delay

chanceLine = 0.5 .* ones(length(allPulseDelay), 1);

offsetPoints = 0.5;
purpleColor = [0.66, 0.46, 0.82];

figure;
idx = 1;
for k = 1:3
    for j = 1:3
        file_str = ['salienceGrid/results_Dur' num2str(pulseDurationsrev(k)*1000) '_Con' num2str(pulseContrasts(j)*100)];
        load(file_str)

        rodSamples = [probTMeansL.rod(1:Nsamples,:);probTMeansR.rod(1:Nsamples,:)];
        coneSamples = [probTMeansL.cone(1:Nsamples,:);probTMeansR.cone(1:Nsamples,:)];
        combSamples = [probTMeansL.comb(1:Nsamples,:);probTMeansR.comb(1:Nsamples,:)];

        % Accuracy
        PMuRod = mean(rodSamples);
        PMuCone = mean(coneSamples);
        PMuComb = mean(combSamples);

        % Clopper-Pearson confidence intervals
        n = 2*Nsamples; %total trials per pulse delay
        [~,pCIRod] = binofit(sum(rodSamples),n);
        [~,pCICone] = binofit(sum(coneSamples),n);
        [~,pCIComb] = binofit(sum(combSamples),n);

        % Kruskal-Wallis test/Mann-Whitney U test
        p_values = zeros(size(allPulseDelay));
        for i = 1:length(allPulseDelay)
            p_values(i) = kruskalwallis([combSamples(:,i),coneSamples(:,i)],[],'off');
        end

        % logical array for significant p_values
        p_significant = p_values<0.05;

        subplot(3,3,idx)
        hold on
        plot(StimLevelsFineGrain,ProportionCorrectModelComb,'-','color',purpleColor,'linewidth',1);

        errorbar(xAxis - offsetPoints, PMuRod, PMuRod-pCIRod(:,1)', pCIRod(:,2)'-PMuRod, 'ko', 'MarkerFaceColor', 'b'); hold on;
        errorbar(xAxis, PMuCone, PMuCone-pCICone(:,1)', pCICone(:,2)'-PMuCone, 'ko', 'MarkerFaceColor', 'r'); hold on;
        errorbar(xAxis + offsetPoints, PMuComb, PMuComb-pCIComb(:,1)', pCIComb(:,2)'-PMuComb, 'ko', 'MarkerFaceColor', purpleColor); hold on;

        plot(xAxis, chanceLine, 'k--');

        % plot significant points
        plot(xAxis(p_significant),max([pCICone(p_significant,2),pCIComb(p_significant,2),pCIRod(p_significant,2)]')+0.02,'*','MarkerSize',8,'Color','k');

        title(file_str); legend('off')
        xlabel('')
        ylabel('')
        xlim([-2 52])
        ylim([0.45 1.025])
        box('off')

        set(gca, 'fontsize',18);
        set(gca, 'Xtick',[0:20:100]);
        set(gca, 'YTick',[0:0.5:1.5]);

        idx = idx+1;
    end
end

subplot(3,3,8); xlabel('pulse delay, \Deltas (ms)');
subplot(3,3,4); ylabel('accuracy');
subplot(3,3,3); legend('','rod','cone','rod+cone','chance','Location','East')
set(gcf,'Position',[300 300 1100 950])

%% plot the grid - the new way
% Format inputs as [NumConditions x NumStimLevels] matrices
StimLevels = [xAxis; xAxis; xAxis];

%Number of trials at each entry of 'StimLevels'
N = 2*(params.repeats-params.sizeTrain);

chanceLine = 0.5 .* ones(length(allPulseDelay), 1);

offsetPoints = 0.5;
purpleColor = [0.66, 0.46, 0.82];

% prepare model fit
PF = @PAL_Weibull;

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
searchGrid.lambda = 0:0.01:0.1;  %ditto %lapse rate. let it be non-zero.

% Options for the Nelder-Mead optimization search
options = PAL_minimize('options');
lapseLimits = [0 0.2];        %Range on lapse rates. Will go ignored here
                             %if lapse rate is not a free parameter
maxTries = 4;               %Try each fit at most four times        
rangeTries = [2 1.9 0 0.1];   %Range of random jitter to apply to initial
                            %parameter values on retries of failed fits.

figure;
idx = 1;
for k = 1:3
    for j = 1:3
        file_str = ['salienceGrid/results_Dur' num2str(pulseDurationsrev(k)*1000) '_Con' num2str(pulseContrasts(j)*100)];
        load(file_str)

        %Number of positive responses (e.g., 'yes' or 'correct' at each of the
        %   entries of the Stim Levels)
        SuccessesComb = sum([probTMeansL.comb;probTMeansR.comb]);
        SuccessesCone = sum([probTMeansL.cone;probTMeansR.cone]);
        SuccessesRod = sum([probTMeansL.rod;probTMeansR.rod]);
        NumPos = [SuccessesCone; SuccessesComb; SuccessesRod];

        Ntrials = N.*ones(size(SuccessesComb));
        OutOfNum = N .* ones(size(NumPos));

        % Data points
        ProportionCorrectObservedComb = SuccessesComb./Ntrials;
        ProportionCorrectObservedCone = SuccessesCone./Ntrials;
        ProportionCorrectObservedRod = SuccessesRod./Ntrials;

        % Curve fits one at a time
        [paramsValuesComb, LL, exitflag] = PAL_PFML_Fit(xAxis,SuccessesComb,Ntrials,searchGrid,paramsFree,PF);
        [paramsValuesCone, LL, exitflag] = PAL_PFML_Fit(xAxis,SuccessesCone,Ntrials,searchGrid,paramsFree,PF);
        [paramsValuesRod, LL, exitflag] = PAL_PFML_Fit(xAxis,SuccessesRod,Ntrials,searchGrid,paramsFree,PF);

        % Model curve fits
        StimLevelsFineGrain=[min(xAxis):max(xAxis)./1000:max(xAxis)];
        ProportionCorrectModelComb = PF(paramsValuesComb,StimLevelsFineGrain);
        ProportionCorrectModelCone = PF(paramsValuesCone,StimLevelsFineGrain);
        ProportionCorrectModelRod = PF(paramsValuesRod,StimLevelsFineGrain);

        % 1PF fit
        [paramsL, LLRestr] = PAL_PFML_FitMultiple(...
            StimLevels(1:2,:), NumPos(1:2,:), OutOfNum(1:2,:), paramsInit, PF, ...
            'thresholds', 'constrained','slopes', 'constrained', ...
            'guessrates','fixed','lapserates','constrained',...
            'lapseLimits',lapseLimits, 'searchOptions', options);
        % 2PF fit
        [paramsF, LLFull] = PAL_PFML_FitMultiple(...
            StimLevels(1:2,:), NumPos(1:2,:), OutOfNum(1:2,:), paramsL, PF, ...
            'thresholds', 'unconstrained', 'slopes', 'unconstrained', ...
            'guessrates','fixed','lapserates','unconstrained',...
            'lapseLimits',lapseLimits, 'searchOptions', options);

        % model comparison btween cone-only and rod+cone
        NumConditions=2;
        TLR1 = 2 * (LLFull - LLRestr);
        NumParamsRestr = 3; % 1 Shared Threshold + 1 Shared Slope + 1 Share Lapse Rate
        NumParamsFull = NumConditions*NumParamsRestr; % 2 thresholds + 2 slopes
        dfree = NumParamsFull - NumParamsRestr; % Degrees of freedom (4 - 2 = 2)

        % Calculate p-value using the Chi-Square Distribution
        p_value = 1 - chi2cdf(TLR1, dfree);

        subplot(3,3,idx)
        hold on
        plot(StimLevelsFineGrain,ProportionCorrectModelCone,'-','color','r','linewidth',4);
        plot(StimLevelsFineGrain,ProportionCorrectModelComb,'-','color',purpleColor,'linewidth',4);
        plot(StimLevelsFineGrain,ProportionCorrectModelRod,'-','color','b','linewidth',4);

        plot(xAxis,ProportionCorrectObservedCone,'ko', 'MarkerFaceColor', 'r');
        plot(xAxis,ProportionCorrectObservedComb,'ko', 'MarkerFaceColor', purpleColor);
        plot(xAxis,ProportionCorrectObservedRod,'ko', 'MarkerFaceColor', 'b');

        % Plot Chance Line
        plot(xAxis, chanceLine, 'k--');

        % annotate with p-value
        if p_value<0.05
            p_annot = ['p < 0.05'];
        else
            p_annot = ['p = ' num2str(p_value,'%6.3f')];
        end
        text(35,0.55,p_annot,'FontSize',14);

        % title(file_str); 
        legend('off')
        xlabel('')
        ylabel('')
        xlim([-2 52])
        ylim([0.45 1])
        box('off')

        set(gca, 'fontsize',18);
        set(gca, 'Xtick',[0:20:100]);
        set(gca, 'YTick',[0:0.5:1.5]);

        save(file_str,'ProportionCorrectModelComb','ProportionCorrectObservedComb','StimLevelsFineGrain',"-append")

        idx = idx+1;
    end
end

subplot(3,3,8); xlabel('pulse delay, \Deltas (ms)');
subplot(3,3,4); ylabel('accuracy');
subplot(3,3,3); legend('cone','rod+cone','rod','','','','chance','Location','East')
set(gcf,'Position',[300 300 1100 950])