
%Extract the filters and normalise them
coneFilter = params.model.exc.filters.cone ./ -min(params.model.exc.filters.cone);
rodFilter = params.model.exc.filters.rod ./ -min(params.model.exc.filters.rod);

%plot and label
figure; plot(coneFilter, 'r'); hold on; plot(rodFilter, 'b');
plot(zeros(1,length(coneFilter)), 'k--'); 
title("Rod and cone filters (normalised)")
ylabel("Normalized magnitude")
xlabel("Time (ms)")

xlim([0 7000]);%length(coneFilter)]);
ylim([-1.5 0.6]);

% based on params.sampleIntrv... looks like there were
% 10 pts for every 1 ms...
xticklabels(0:100:700);

