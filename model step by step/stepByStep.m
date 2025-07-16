%% STEP-BY-STEP GUIDE TO THE MODEL

% This guide allows you to take apart the model circuit's outputs at each 
% computational stage, such that we can be shewwwwwwn "what exactly's 
% going on here." Hopefully it's helpful!

% NOTE: DO NOT HIT RUN ON THIS SCRIPT--THAT'S NOT HOW IT WORKS!
% You'll have to copy-paste the snippets of code from here into the
% terminal after running the appropriate scripts.

close all;

% STEP 0: Make sure to set allPulseDelay and params.subDelay
% to what you want (for instance 0.025 and 0.05, respectively).

%% STEP 1: Add a breakpoint to main.m, line 69

main; 

% Keep pressing "STEP IN" until you're at runRodConeModel.m.

%% LN MODEL OUTPUTS AS CORREALTORS %%
%% STEP 2: Add breakpoint to runRodConeModel.m, line 59

% Press "CONTINUE" to get the LEFT correlator (rod-cone ln model) output

% stim
figure(1); subplot(2,1,1); plot(stims.combinedRod(1,:), 'b'); 
title('rod only left stimuli'); subplot(2,1,2); 
plot(stims.combinedCone(1,:), 'r'); title('cone only left stimuli');

% generator signal
figure(2); 
subplot(3,1,1); plot(gsRod(1,:), 'b'); title('rod only gs left'); 
subplot(3,1,2); plot(gsCone(1,:), 'r'); title('cone only gs left'); 
subplot(3,1,3); plot(genSig(1,:)); title('combined generator signal');

% nonlinear output
figure(3); subplot(2,1,1); plot(genSig(1,:)); 
title('generator signal combined'); subplot(2,1,2); 
plot(output(1,:)); title('nonlinear output');

%% STEP 3: "STEP IN" until you've run the RIGHT correlator 

% stim
figure(4); subplot(2,1,1); plot(stims.combinedRod(1,:), 'b'); 
title('rod only right stimuli'); subplot(2,1,2); 
plot(stims.combinedCone(1,:), 'r'); title('cone only right stimuli');

% generator signal
figure(5); 
subplot(3,1,1); plot(gsRod(1,:), 'b'); title('rod only gs right'); 
subplot(3,1,2); plot(gsCone(1,:), 'r'); title('cone only gs right'); 
subplot(3,1,3); plot(genSig(1,:)); title('combined generator signal');

% nonlinear output
figure(6); subplot(2,1,1); plot(genSig(1,:)); 
title('generator signal combined'); subplot(2,1,2); 
plot(output(1,:)); title('nonlinear output');

%% NOTE: REPEAT STEPS 2 AND 3 TO SEE RIGHTWARD LN OUTPUTS. I'LL SKIP HERE.
%% HASSENSTEIN-REICHARDT OUTPUT %%
%% STEP 4: Add Breakpoint at generateReichardtResp.m line 63
% Then you can hit "CONTINUE."
% This will give you the full circuit output for the leftward  stimuli.
figure(7); 
subplot(2,2,1); plot(respL(1,:)); hold on; plot(respR(1,:)); 
legend('left correlator', 'right correlator'); 
subplot(2,2,2); plot(respLDT(1,:)); hold on; plot(respRDT(1,:)); 
legend('left delayed', 'right delayed'); 
subplot(2,2,3); plot(product1(1,:)); hold on; plot(product2(1,:)); 
legend('leftDT * right', 'left * rightDT'); 
subplot(2,2,4); plot(reichardtOut(1,:)); 
title('full reichardt output, leftward');


%% STEP 5: Hit "CONTINUE" to get the rightward stimuli

figure(8); 
subplot(2,2,1); plot(respL(1,:)); hold on; plot(respR(1,:)); 
legend('left correlator', 'right correlator'); 
subplot(2,2,2); plot(respLDT(1,:)); hold on; plot(respRDT(1,:)); 
legend('left delayed', 'right delayed'); 
subplot(2,2,3); plot(product1(1,:)); hold on; plot(product2(1,:)); 
legend('leftDT * right', 'left * rightDT'); 
subplot(2,2,4); plot(reichardtOut(1,:)); 
title('full reichardt output, rightward');

%% AUTOMATIC LABELING OUTPUT %%
%% STEP 6: Put breakpoint on reichardtTrialSet.m, line 72

% Press continue. Then, to see trial means, discriminant vector, and
% the performance of left vs right...

% Note: Lines 27-28 in reichardtTrialSet.m trim the stimuli so we’re 
% only looking at the 1 second window in which the motion occurs. For 
% this reason, the outputs from the previous steps and this next step
% will not have the same lengths.

figure(9); subplot(3,1,1); plot(leftTemp); hold on; plot(rightTemp); 
title('training means, 100 trials each'); 
legend('leftward stim', 'rightward stim'); 
subplot(3,1,2); plot(discrmntVect); 
legend('discriminant vector'); 
subplot(3,1,3); 
autoscoreBoth = [sum(autoscored_L), sum(autoscored_R)];
plot(autoscoreBoth, 'o'); 
legend('1: left, 2: right');
title('accurately labeled trials out of 500');
xlim([0.5 2.5]);
ylim([min(autoscoreBoth) - 1, max(autoscoreBoth) + 1]);
