% To see an individual response
% after putting a breakpoint at 
% generateReichardtResp line 63

figure; plot(mean(respR) ./ mean(mean((respR))))
hold on; plot(mean(respL) ./ mean(mean(respL)));
hold on; plot(mean(reichardtOut) ./ mean(mean(reichardtOut)), 'k')