% Generate a kernel fit PDF to dataVector...
% Then use this to assign all elements of dataVector their
% respective probabilities.

function [discLeft, discRight, probLL, probLR, probRR, probRL] = ...
    convertProjToProb(projLD, projRD)

% fit kernel PDF
[fLD, xLD] = ksdensity(projLD);
[fRD, xRD] = ksdensity(projRD);

% use the fit points as a lookup table and match the data points to
% the indices of matching probabilities
projLDPoints = length(projLD);
projRDPoints = length(projRD);
fLDPoints = length(xLD);
fRDPoints = length(xRD);

assert(projLDPoints == projRDPoints);
assert(fLDPoints == fRDPoints);
projPoints = projLDPoints;
fPoints = fLDPoints;

lookupLDMatrix = repmat(xLD', 1, projPoints);
lookupRDMatrix = repmat(xRD', 1, projPoints);
projLDMatrix = repmat(projLD, fPoints, 1);
projRDMatrix = repmat(projRD, fPoints, 1);

% instead of interpolating PDF
lookupDiffLL = abs(lookupLDMatrix - projLDMatrix);
lookupDiffLR = abs(lookupRDMatrix - projLDMatrix);
lookupDiffRR = abs(lookupRDMatrix - projRDMatrix);
lookupDiffRL = abs(lookupLDMatrix - projRDMatrix);

[~, idxLL] = min(lookupDiffLL);
[~, idxLR] = min(lookupDiffLR);
[~, idxRR] = min(lookupDiffRR);
[~, idxRL] = min(lookupDiffRL);

probLL = fLD(idxLL);
probLR = fRD(idxLR);
probRR = fRD(idxRR);
probRL = fLD(idxRL);

discLeft = (probLL > probLR); 
discRight = (probRR > probRL);
end

