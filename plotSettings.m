set(0, 'DefaultAxesFontName','Helvetica')
set(0, 'DefaultAxesFontSize', 16)
set(0, 'DefaultLineLineWidth', 2);

% Wtf is groot here, I don't know. But these lines set the interpreter
% set(groot,'defaulttextinterpreter','latex'); 
% set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
% set(groot, 'defaultLegendInterpreter','latex');

co = [169 117 209; 20 136 153; 250 117 125; 69 130 68; 36 186 89] ./ 256;

% co = [236 202 202; 216 184 230; 234 224 202; 239 155 213; ...
%     178 226 207; 202 227 197; 182 210 228; 195 221 229; 207 204 225; ...
%     191 237 195] ./ 256 .* 0.95; 

set(groot,'defaultAxesColorOrder',co)

box off
main