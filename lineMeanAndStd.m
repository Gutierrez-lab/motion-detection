% Used to plot mean responses taken from mat file.
load('singleRun25Ms.mat');
resp = respLeftward;

x = (1:size(resp,2))' - 1;
x = x ./ 10;
y = mean(resp,1)';
err = std(resp,1)';

lo = y - err;
hi = y + err;

f = figure();
title('Combined Responses');

subplot(2,1,1);
hp = patch([x; x(end:-1:1); x(1)], [lo; hi(end:-1:1); lo(1)], 'k');
hold on;
hl = line(x,y);

set(hp, 'facecolor', [.7 .7 .7], 'edgecolor', 'none');
set(hl, 'color', 'k');


%ylim([-6000 2000]);
%%

resp = respRightward;

x = (1:size(resp,2))';
x = x ./ 10;
y = mean(resp,1)';
err = std(resp,1)';

lo = y - err;
hi = y + err;

subplot(2,1,2);
hp = patch([x; x(end:-1:1); x(1)], [lo; hi(end:-1:1); lo(1)], 'k');
hold on;
hl = line(x,y);

set(hp, 'facecolor', [.7 .7 .7], 'edgecolor', 'none');
set(hl, 'color', 'k');

xlabel('Time (ms)')



%ylim([-2000 6000]);