function [groundTruth] = GroundTruth(T, End,startPositionX, startVelocityX, startPositionY, startVelocityY, movementSigma)
%  T is sample time
%  End is the total time
%  This function generates true values
%  originalX is the original x position of target
%  originalY is the original y position of traget
%  xVelocity is the velocity in x axis
%  yVelocity is the velocity in y axis
%  sigma is the noise

numberOfColumns = fix((End/T))+1;%number of colomuns of groundtruth matrix
groundTruth = zeros(4,numberOfColumns);%define groundtruch matrix
x_k = [startPositionX;startVelocityX;startPositionY;startVelocityY];%initialize the positionTemplate
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

for i = 0:T:End
    groundTruth(:,k) = x_k;
    k = k+1;
    x_k_1 = F*x_k + G*[normrnd(0,movementSigma); normrnd(0,movementSigma)];
    x_k = x_k_1;
end

%plot(groundTruth(1,:), groundTruth(3,:));
end