classdef InputParameter
%Class generating inputParamter
    
    properties
        DAStrategy = 0;%data association algorithm
        MCRTime = 80;%MCR times
        T = 1; %SampleTime
        End = 50; %Time when the radar ends the detection
        startTime_A =10; %Time the target A starts to move
        endTime_A = 44; %Time the target A ends moving
        startPositionX_A = 1200; %Position of X where target A starts to move
        velocityX_A = 6; %Velocity of X of target A
        startPositionY_A = 600; %Position of Y where target A starts to move
        velocityY_A = 7; %Velocity of Y of target A
        movementSigma_A = 0.5; %Movement noise of target A
        startTime_B = 8; %Time the target B starts to move
        endTime_B = 44; %Time the target B ends moving
        startPositionX_B =-200; %Position of X where target B starts to move
        velocityX_B =  6; %Velocity of X of target B
        startPositionY_B = -400; %Position of Y where target B starts to move
        velocityY_B = 6; %Velocity of Y of target B
        movementSigma_B = 0.5; %Movement noise of target B
        Lambda = 10^-3;
    end
end

