load('singleRun25Ms.mat');

trainN = 100;
[meanLeft, ~, leftTest] = splitTrainTest(respLeftward, trainN);
[meanRight, ~, rightTest] = splitTrainTest(respRightward, trainN);

discriminantV = meanRight - meanLeft;

[leftProj, ~] = projWithTemplate(discriminantV, leftTest);
[rightProj, ~] = projWithTemplate(discriminantV, rightTest);

[fLD, xLD] = ksdensity(leftProj);
[fRD, xRD] = ksdensity(rightProj);

% fLD = fLD ./ sum(fLD);
% fRD = fRD ./ sum(fRD);

figure; plot(xLD, fLD); hold on; plot(xRD, fRD);
legend('leftward trials', 'rightward trials');

% ylim([0 0.05]);
ylabel('probability');
xlabel('projection value');
yticks([0 0.01 0.02 0.03 0.04 0.05]);