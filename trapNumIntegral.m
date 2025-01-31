% For a matrix of row vectors, where each row vector is some f(t), compute
% an estimate of the integral by finding the left and right Riemann sums,
% then averaging them.

function trapIntegral = trapNumIntegral(ft, dt)

ft = ft';

% left Riemann sum calculation
leftFt = ft(1:end-1, :);
leftRect = sum(leftFt) .* dt;

% right Riemann sum calculation
rightFt = ft(2:end, :);
rightRect = sum(rightFt) .* dt;

trapIntegral = (leftRect + rightRect) ./ 2;

end