% Implement Agresti-Coull Interval Method... 
% who suggested adding 4 observations to the sample, 
% two successes and two failures, and then using the Wald 
% formula to construct a 95% confidence interval (CI).1 In other words, 2 counts are added to the numerator and 4 counts are added to the denominator.
% Adapted from https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Agresti%E2%80%93Coull_interval

function [pHat, pci] = agrestiCoull(x,n)

z = 2;
n = n+z^2;

pHat = (1/n)*(x+(z^2/2));

upperCandidate = pHat + z * sqrt(pHat/n .* (1 - pHat));
lowerCandidate = pHat - z * sqrt(pHat/n .* (1 - pHat));

upper = min(upperCandidate, 1);
lower = max(lowerCandidate, 0);

pci = [lower; upper];

pci = pci';

end