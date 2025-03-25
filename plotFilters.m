
figure; 
t = 1:length(exc.filters.rod);
t = t ./ 10;

plot(t, exc.filters.rod ./ -min(exc.filters.rod), 'b'); 
hold on; 
plot(t, exc.filters.cone ./ -min(exc.filters.cone), 'r');

legend('rod filter', 'cone filter');

xlim([0 1000]);
ylim([-1.2 0.7]);
ylabel('norm output');
xlabel('time (ms)');
