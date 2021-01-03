function [] = MCR()
% This function is Monte Carlo Runs

parameters = InputParameter;

T = parameters.sampleTime;
End = parameters.endTime;
startPositionX = parameters.startPositionX;
startVelocityX = parameters.startVelocityX;
startPositionY = parameters.startPositionY;
startVelocityY = parameters.startVelocityY;
movementSigma = parameters.movementSigma;
numberOfMCR = parameters.numberOfMCR;

%calculating the number of columns
numberOfColumns = fix((End/T))+1;

%Monte Carlo Runs Matrix
mcr_xPosition = zeros(numberOfMCR,numberOfColumns);
mcr_yPosition = zeros(numberOfMCR,numberOfColumns);
mcr_startVelocityX = zeros(numberOfMCR,numberOfColumns);
mcr_startVelocityY = zeros(numberOfMCR,numberOfColumns);
    
%RMSE Matrix
RMSE_xPosition = zeros(1,numberOfColumns);
RMSE_yPosition = zeros(1,numberOfColumns);
RMSE_startVelocityX = zeros(1,numberOfColumns);
RMSE_startVelocityY = zeros(1,numberOfColumns);

%Temporary variables
temp_xPosition = 0;
temp_yPosition = 0;
temp_startVelocityX = 0;
temp_startVelocityY = 0; 

%numberOfMCR times Monte Carlo Runs
for i = 1:numberOfMCR
    
    [groundTruth,estimation,measurement] = Estimation(T,End,startPositionX,startVelocityX,startPositionY,startVelocityY,movementSigma);
    
    for j = 1:numberOfColumns
    mcr_xPosition(i,j) = (estimation(1,j) - groundTruth(1,j))^2;
    mcr_yPosition(i,j) = (estimation(3,j) - groundTruth(3,j))^2;
    mcr_startVelocityX(i,j) = (estimation(2,j) - groundTruth(2,j))^2;
    mcr_startVelocityY(i,j) = (estimation(4,j) - groundTruth(4,j))^2;
    end
end

%calculating the RMSE
for k = 1:numberOfColumns

    for h = 1:numberOfMCR
        temp_xPosition = temp_xPosition + mcr_xPosition(h,k);
        temp_yPosition = temp_yPosition + mcr_yPosition(h,k);
        temp_startVelocityX = temp_startVelocityX + mcr_startVelocityX(h,k);
        temp_startVelocityY = temp_startVelocityY + mcr_startVelocityY(h,k);
    end
    
    RMSE_xPosition(1,k) = temp_xPosition/numberOfMCR;
    RMSE_yPosition(1,k) = temp_yPosition/numberOfMCR;
    RMSE_startVelocityX(1,k) = temp_startVelocityX/numberOfMCR;
    RMSE_startVelocityY(1,k) = temp_startVelocityY/numberOfMCR;
    
    temp_xPosition = 0;
    temp_yPosition = 0;
    temp_startVelocityX = 0;
    temp_startVelocityY = 0;
end

%ploting RMSE curve
x = 1:numberOfColumns;
figure;
subplot(1,2,1);
plot(x,RMSE_xPosition,x,RMSE_yPosition);
title('RMSE of Position');
xlabel('Kth Tracking');
ylabel('RMSE');
legend('xPosition','yPosition');
subplot(1,2,2);
plot(x,RMSE_startVelocityX,x,RMSE_startVelocityY);
title('RMSE of Velocity');
xlabel('Kth Tracking');
ylabel('RMSE');
legend('startVelocityX','startVelocityY');
end

