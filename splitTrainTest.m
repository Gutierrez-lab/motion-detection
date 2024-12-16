
% Splits a set of vector responses into test set and training set. Does not
% reshuffle!
% Input:
%   fullMatrix    - original data matrix of simulated response row vectors
%   sizeTrain     - int, the amount of trials for training
% Output:
%   avgTrain      - row vector, the means of trainMatrix
%   trainMatrix   - matrix
%   testMatrix    - matrix

function [avgTrain, trainMatrix, testMatrix] = ...
    splitTrainTest(fullMatrix, sizeTrain)

trainMatrix = fullMatrix(1:sizeTrain, :);
testMatrix = fullMatrix(sizeTrain+1:end, :);
avgTrain = mean(trainMatrix);

end


