function [ groundTruth ] = GroundTruthA( T,startTime_A,endTime_A,startPositionX_A, velocityX_A, startPositionY_A, velocityY_A, movementSigma_A )
%Generating groundtruth of A
%T is SampleTime
%startTime_A is Time the target A starts to move
%endTime_A is Time the target A ends moving
%startPositionX_A is Position of X where target A starts to move
%velocityX_A is Velocity of X of target A
%startPositionY_A is Position of Y where target A starts to move
%velocityY_A is Velocity of Y of target A
%movementSigma_A is Movement noise of target A

groundTruth = zeros(4,fix((endTime_A-startTime_A)/T)+1);%initialize the groundtruth matrix
x_k = [startPositionX_A;velocityX_A;startPositionY_A;velocityY_A];%initialize the positionTemplate
k = 1; %define counter

%define state transition matrix
F = [1,T,0,0;
        0,1,0,0;
        0,0,1,T;
        0,0,0,1];
    
%define G matraix
G = [(T^2)/2,0;
        T, 0;
        0, (T^2)/2;
        0, T];
    
for i = startTime_A:T:endTime_A
    groundTruth(:,k) = x_k;
    k = k+1;
    x_k_1 = F*x_k + G*[normrnd(0,movementSigma_A); normrnd(0,movementSigma_A)];
    x_k = x_k_1;
end

%plot(groundTruth(1,:), groundTruth(3,:));
end

