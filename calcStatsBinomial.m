% Calculate estimated mean and variance for column vectors in a dataset
% binaryDataMatrix, collected from a binomial distribution.

function [mu_hat, sigma_hat] = calcStatsBinomial(binaryDataMatrix)

n = size(binaryDataMatrix, 1);

% sum(binaryDataMatrix) works if successes are assigned "1" and failures
% assigned "0"
p_hat = sum(binaryDataMatrix) ./ n;

mu_hat = n .* p_hat;

sigma_hat_squared = mu_hat.*(1-p_hat);
sigma_hat = sqrt(sigma_hat_squared);

end