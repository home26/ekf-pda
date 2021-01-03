function [] = MCR()
%MCR function runs mcrTime monte carlo process

inputParameter = InputParameter;
MCRTime = inputParameter.MCRTime;
T = inputParameter.T;
End = inputParameter.End;
startTime_A = inputParameter.startTime_A;
endTime_A = inputParameter.endTime_A;
startPositionX_A = inputParameter.startPositionX_A;
velocityX_A = inputParameter.velocityX_A;
startPositionY_A = inputParameter.startPositionY_A;
velocityY_A = inputParameter.velocityY_A;
movementSigma_A = inputParameter.movementSigma_A;
startTime_B = inputParameter.startTime_B;
endTime_B = inputParameter.endTime_B;
startPositionX_B = inputParameter.startPositionX_B;
velocityX_B = inputParameter.velocityX_B;
startPositionY_B = inputParameter.startPositionY_B;
velocityY_B = inputParameter.velocityY_B;
movementSigma_B = inputParameter.movementSigma_B;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PDA%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%performance evaluation temporary variables%%%%%%
%1.RMSE
RMSEPositionA_temp = zeros(MCRTime,End);
RMSEVelocityA_temp = zeros(MCRTime,End);
RMSEPositionB_temp = zeros(MCRTime,End);
RMSEVelocityB_temp = zeros(MCRTime,End);

%2.falseTrackrate
falseTrackRate_temp = zeros(MCRTime,End);

%latency
latencyTantativeA_temp = zeros(MCRTime,1);
latencyDeleteA_temp = zeros(MCRTime,1);
latencyTantativeB_temp = zeros(MCRTime,1);
latencyDeleteB_temp = zeros(MCRTime,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sumRMSEPositionA_temp = zeros(1,End);
sumRMSEVelocityA_temp = zeros(1,End);
sumRMSEPositionB_temp = zeros(1,End);
sumRMSEVelocityB_temp = zeros(1,End);
sumFalseTrackRate_temp = zeros(1,End);
sumLatencyTantativeA_temp = 0;
sumLatencyDeleteA_temp = 0;
sumLatencyTantativeB_temp = 0;
sumLatencyDeleteB_temp = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NN%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%performance evaluation temporary variables%%%%%%
%1.RMSE
RMSEPositionA_temp_NN = zeros(MCRTime,End);
RMSEVelocityA_temp_NN = zeros(MCRTime,End);
RMSEPositionB_temp_NN = zeros(MCRTime,End);
RMSEVelocityB_temp_NN = zeros(MCRTime,End);

%2.falseTrackrate
falseTrackRate_temp_NN = zeros(MCRTime,End);

%latency
latencyTantativeA_temp_NN = zeros(MCRTime,1);
latencyDeleteA_temp_NN = zeros(MCRTime,1);
latencyTantativeB_temp_NN = zeros(MCRTime,1);
latencyDeleteB_temp_NN = zeros(MCRTime,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sumRMSEPositionA_temp_NN = zeros(1,End);
sumRMSEVelocityA_temp_NN = zeros(1,End);
sumRMSEPositionB_temp_NN = zeros(1,End);
sumRMSEVelocityB_temp_NN = zeros(1,End);
sumFalseTrackRate_temp_NN = zeros(1,End);
sumLatencyTantativeA_temp_NN = 0;
sumLatencyDeleteA_temp_NN = 0;
sumLatencyTantativeB_temp_NN = 0;
sumLatencyDeleteB_temp_NN = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%PDA%%%%%%%%%%%%%%%%
for e = 1:MCRTime
    [RMSEPositionA_temp(e,:),RMSEVelocityA_temp(e,:),RMSEPositionB_temp(e,:),RMSEVelocityB_temp(e,:),falseTrackRate_temp(e,:),latencyTantativeA_temp(e,:),latencyDeleteA_temp(e,:),latencyTantativeB_temp(e,:),latencyDeleteB_temp(e,:)] = Track(0);
    sumRMSEPositionA_temp = sumRMSEPositionA_temp + RMSEPositionA_temp(e,:);
    sumRMSEVelocityA_temp = sumRMSEVelocityA_temp + RMSEVelocityA_temp(e,:);
    sumRMSEPositionB_temp = sumRMSEPositionB_temp + RMSEPositionB_temp(e,:);
    sumRMSEVelocityB_temp = sumRMSEVelocityB_temp + RMSEVelocityB_temp(e,:);
    sumFalseTrackRate_temp = sumFalseTrackRate_temp + falseTrackRate_temp(e,:);
    sumLatencyTantativeA_temp = sumLatencyTantativeA_temp + latencyTantativeA_temp(e,:);
    sumLatencyDeleteA_temp = sumLatencyDeleteA_temp + latencyDeleteA_temp(e,:);
    sumLatencyTantativeB_temp = sumLatencyTantativeB_temp + latencyTantativeB_temp(e,:);
    sumLatencyDeleteB_temp = sumLatencyDeleteB_temp + latencyDeleteB_temp(e,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%NN%%%%%%%%%%%%%%%%
for e = 1:MCRTime
    [RMSEPositionA_temp_NN(e,:),RMSEVelocityA_temp_NN(e,:),RMSEPositionB_temp_NN(e,:),RMSEVelocityB_temp_NN(e,:),falseTrackRate_temp_NN(e,:),latencyTantativeA_temp_NN(e,:),latencyDeleteA_temp_NN(e,:),latencyTantativeB_temp_NN(e,:),latencyDeleteB_temp_NN(e,:)] = Track(1);
    sumRMSEPositionA_temp_NN = sumRMSEPositionA_temp_NN + RMSEPositionA_temp_NN(e,:);
    sumRMSEVelocityA_temp_NN = sumRMSEVelocityA_temp_NN + RMSEVelocityA_temp_NN(e,:);
    sumRMSEPositionB_temp_NN = sumRMSEPositionB_temp_NN + RMSEPositionB_temp_NN(e,:);
    sumRMSEVelocityB_temp_NN = sumRMSEVelocityB_temp_NN + RMSEVelocityB_temp_NN(e,:);
    sumFalseTrackRate_temp_NN = sumFalseTrackRate_temp_NN + falseTrackRate_temp_NN(e,:);
    sumLatencyTantativeA_temp_NN = sumLatencyTantativeA_temp_NN + latencyTantativeA_temp_NN(e,:);
    sumLatencyDeleteA_temp_NN = sumLatencyDeleteA_temp_NN + latencyDeleteA_temp_NN(e,:);
    sumLatencyTantativeB_temp_NN = sumLatencyTantativeB_temp_NN + latencyTantativeB_temp_NN(e,:);
    sumLatencyDeleteB_temp_NN = sumLatencyDeleteB_temp_NN + latencyDeleteB_temp_NN(e,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hold off


%%%%%%%%%%%%%%%%%%%%%%%%%PDA%%%%%%%%%%%
sumRMSEPositionA_temp = sumRMSEPositionA_temp/MCRTime;
sumRMSEVelocityA_temp = sumRMSEVelocityA_temp/MCRTime;
sumRMSEPositionB_temp = sumRMSEPositionB_temp/MCRTime;
sumRMSEVelocityB_temp = sumRMSEVelocityB_temp/MCRTime;
sumFalseTrackRate_temp = sumFalseTrackRate_temp/MCRTime;
sumLatencyTantativeA_temp = sumLatencyTantativeA_temp/MCRTime;
sumLatencyDeleteA_temp = sumLatencyDeleteA_temp/MCRTime;
sumLatencyTantativeB_temp = sumLatencyTantativeB_temp/MCRTime;
sumLatencyDeleteB_temp = sumLatencyDeleteB_temp/MCRTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%NN%%%%%%%%%%%
sumRMSEPositionA_temp_NN = sumRMSEPositionA_temp_NN/MCRTime;
sumRMSEVelocityA_temp_NN = sumRMSEVelocityA_temp_NN/MCRTime;
sumRMSEPositionB_temp_NN = sumRMSEPositionB_temp_NN/MCRTime;
sumRMSEVelocityB_temp_NN = sumRMSEVelocityB_temp_NN/MCRTime;
sumFalseTrackRate_temp_NN = sumFalseTrackRate_temp_NN/MCRTime;
sumLatencyTantativeA_temp_NN = sumLatencyTantativeA_temp_NN/MCRTime;
sumLatencyDeleteA_temp_NN = sumLatencyDeleteA_temp_NN/MCRTime;
sumLatencyTantativeB_temp_NN = sumLatencyTantativeB_temp_NN/MCRTime;
sumLatencyDeleteB_temp_NN = sumLatencyDeleteB_temp_NN/MCRTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure(1)
plot(1:End,sumRMSEPositionA_temp(1,:),'^-r',1:End,sumRMSEPositionB_temp(1,:),'v-g',1:End,sumRMSEPositionA_temp_NN(1,:),'^-b',1:End,sumRMSEPositionB_temp_NN(1,:),'v-m');
title('RMSE of Position');
legend('Target A With PDA','Target B With PDA','Target A With NN','Target B With NN');

figure(2)
plot(1:End,sumRMSEVelocityA_temp(1,:),'^-r',1:End,sumRMSEVelocityB_temp(1,:),'v-g',1:End,sumRMSEVelocityA_temp_NN(1,:),'^-b',1:End,sumRMSEVelocityB_temp_NN(1,:),'v-m');
title('RMSE of Velocity');
legend('Target A With PDA','Target B With PDA','Target A With NN','Target B With NN');

figure(3)
plot(1:End,sumFalseTrackRate_temp(1,:),'*-r',1:End,sumFalseTrackRate_temp_NN(1,:),'*-g');
title('Number of False Track');
legend('PDA','NN');

end

