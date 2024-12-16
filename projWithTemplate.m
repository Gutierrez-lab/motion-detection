% use a matrix of column vectors trainMatrix and gets the scalar projection
% of each test vector in testMatrix against the mean of trainMatrix. 
% The output is the vector projVector which contains all the values and 
% projSummary, which contains the std and mean of projections.

function [projVector, projSummary] = projWithTemplate(vectorTemplate,...
    trainMatrix)

vectorTemplate = vectorTemplate';
trainMatrix = trainMatrix';

vectorCount = size(trainMatrix, 2);

templateMeanMag = sqrt(sum(vectorTemplate.^2));
templateMatrix = repmat(vectorTemplate, 1, vectorCount);
scaledTemplateMatrix = templateMatrix ./ templateMeanMag;

projVector = dot(trainMatrix, scaledTemplateMatrix);

projSummary = [mean(projVector) std(projVector)];

end

