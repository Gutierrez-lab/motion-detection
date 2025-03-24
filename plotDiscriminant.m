% Used to plot mean responses taken from mat file.
load('singleRun25Ms.mat');


x = (1:size(resp,2))' - 1;
x = x ./ 10;
meanLeftward = mean(respLeftward,1)';
meanRightward = mean(respRightward,1)';
discriminantV = meanRightward - meanLeftward;

figure;
plot(x, meanLeftward);
hold on; plot(x, meanRightward);
hold on; plot(x, discriminantV, 'k:');

legend('leftward mean', 'rightward mean', 'discriminant vector')

ylabel('Output')
xlabel('Time (ms)')