function [ groundTruth ] = GroundTruthB( T,startTime_B,endTime_B,startPositionX_B, velocityX_B, startPositionY_B, velocityY_B, movementSigma_B )
%Generating groundtruth of B
%T is SampleTime
%startTime_B is Time the target B starts to move
%endTime_B is Time the target B ends moving
%startPositionX_B is Position of X where target B starts to move
%velocityX_B is Velocity of X of target B
%startPositionY_B is Position of Y where target B starts to move
%velocityY_B is Velocity of Y of target B
%movementSigma_B is Movement noise of target B

groundTruth = zeros(4,fix((endTime_B-startTime_B)/T)+1);%initialize the groundtruth matrix
x_k = [startPositionX_B;velocityX_B;startPositionY_B;velocityY_B];%initialize the positionTemplate
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
    
for i = startTime_B:T:endTime_B
    groundTruth(:,k) = x_k;
    k = k+1;
    x_k_1 = F*x_k + G*[normrnd(0,movementSigma_B); normrnd(0,movementSigma_B)];
    x_k = x_k_1;
end

%plot(groundTruth(1,:), groundTruth(3,:));
end

