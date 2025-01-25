% To see an individual response
% after putting a breakpoint at 
% generateReichardtResp line 74

figure; plot(mean(respR) ./ mean(mean((respR))))
hold on; plot(mean(respL) ./ mean(mean(respL)));
hold on; plot(mean(reichardtOut) ./ mean(mean(reichardtOut)), 'k')


figure; plot(respR)
hold on; plot(respL);
hold on; plot((reichardtOut), 'k')