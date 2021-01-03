function [errorPositionA,errorVelocityA,errorPositionB,errorVelocityB,falseTrackRate,latencyTantativeA,latencyDeleteA,latencyTantativeB,latencyDeleteB] = Track(DAStrategy)
%TRACK Summary of this function goes here

%DAStrategy is data association strategy,0 measn PDA,1 means NN
%T is SampleTime
%End is Time when the radar ends the detection
%startTime_A is Time the target A starts to move
%endTime_A is Time the target A ends moving
%startPositionX_A is Position of X where target A starts to move
%velocityX_A is Velocity of X of target A
%startPositionY_A is Position of Y where target A starts to move
%velocityY_A is Velocity of Y of target A
%movementSigma_A is Movement noise of target A
%startTime_B is Time the target B starts to move
%endTime_B is Time the target B ends moving
%startPositionX_B is Position of X where target B starts to move
%velocityX_B is Velocity of X of target B
%startPositionY_B is Position of Y where target B starts to move
%velocityY_B is Velocity of Y of target B
%movementSigma_B is Movement noise of target B

inputParameter = InputParameter;%initialize the inputparameter
%DAStrategy = inputParameter.DAStrategy; 
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

%%%%%%%%%%%track plot variable part%%%%%%%%%%%%%%
key = 0;
dataPlot = zeros(2,1,2000);
countOfDataOfEachTrack = zeros(1,2000);
trackID = zeros(1,2000);
confirmedTrack = 0;
color(:,:,1) = [0 0 1];
color(:,:,2) = [0 1 1];
color(:,:,3) = [1 0 1];
color(:,:,4) = [1 1 0];
color(:,:,5) = [0 0 0];
color(:,:,6) = [0 0.4470 0.7410];
color(:,:,7) = [0.8500 0.3250 0.0980];
color(:,:,8) = [0.9290 0.6940 0.1250];
color(:,:,9) = [0.4940 0.1840 0.5560];
color(:,:,10) = [0.4660 0.6740 0.1880];
color(:,:,11) = [0.3010 0.7450 0.9330];
color(:,:,12) = [0.6350 0.0780 0.1840];
color(:,:,13) = [0.79 0.235 0.158];
color(:,:,14) = [0.25 0.217 0.358];
color(:,:,15) = [0.368 0.0147 0.874];
color(:,:,16) = [0.741 0.1455 0.2158];
color(:,:,17) = [0.3 0.0589 0.0254];
color(:,:,18) = [0.259 0.879 0.012];
color(:,:,19) = [0.651 0.897 0.894];
color(:,:,20) = [0.168 0.054 0.203];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%performance evaluation variables%%%%%%%%
TentativeSwitchA = 0;
TentativeSwitchB = 0;
falseTrackRate = zeros(1,End);
countOfConfirmed = 0;
countOfTrue = 0;
errorPositionA = zeros(1,End);
errorVelocityA = zeros(1,End);
errorPositionB = zeros(1,End);
errorVelocityB = zeros(1,End);
latencyTantativeA = 0;
latencyDeleteA = 0;
latencyTantativeB = 0;
latencyDeleteB = 0;
%%%%%%%%%%%%%%%performance evaluation variables%%%%%%%%

counter = 0;
P = zeros(4,4,1000);%define 200 state covariance matrix
x0 = zeros(4,1,1000);%define 200 initial state vector
measurement = zeros(2,200,1000);%define 30 measurement matrix
Radius = 10000;
Lambda = inputParameter.Lambda;

%the state of track, 0 means tentative, 1 means confirmed, 2 means deleted
trackState = zeros(1,1,1000);

%define the quality of track(quality-based track management)
qualityOfTrack = zeros(1,1,1000);

%define the number of track
numberOfTrack = 0;

%%%%%%%%%%%%%%%% define the variables %%%%%%%%%%%%%%%%%%%%%%
meaCandidate = zeros(2,1,1000);%define the measurement candidate measurement
groundTruthA = GroundTruthA(T,startTime_A,endTime_A,startPositionX_A,velocityX_A,startPositionY_A,velocityY_A,movementSigma_A);%generating the groundtruthA
groundTruthB = GroundTruthB(T,startTime_B,endTime_B,startPositionX_B,velocityX_B,startPositionY_B,velocityY_B,movementSigma_B);%generating the groundtruthB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot the groudtruth of A and B, and the detection range
plot(groundTruthA(1,:),groundTruthA(3,:),'+-r',groundTruthB(1,:),groundTruthB(3,:),'+-g');
rectangle('Position',[1000-10000,500-10000,2*10000,2*10000],'Curvature',[1,1],'linewidth',1),axis equal
title('Groundtruth and Trajectory')
legend('GroundTruth of Target A','GroundTruth of Target A');
hold on
grid on

for t = T:T:End
    counter = counter + 1;
    numberOfFalseAlarm = poissrnd(2*pi*Radius*Lambda);%number of falsealarms;
    numberOfmea = numberOfFalseAlarm;
    for j = 1:numberOfmea
        xPolar = 0 + 10000*rand(1); %generating the random number in polar coordinate 
        yPolar = -pi+2*pi*rand(1); %generating the random number in y polar coordinate
        meaCandidate(1,j) = xPolar; %convert the polar coordinate to x axis
        meaCandidate(2,j) = yPolar; %convert the polar coordinate to y axis
    end
    
    %time when target1 appears
    if t >= startTime_A && t<= endTime_A
        pddA =  rand(1);
        %the situation in which A was detected and B was missed
        if pddA <= 0.9
            numberOfmea = numberOfmea + 1;
            xPolar = sqrt(abs((groundTruthA(1,fix((t-startTime_A)/T)+1)-1000))*abs((groundTruthA(1,fix((t-startTime_A)/T)+1)-1000))+(groundTruthA(3,fix((t-startTime_A)/T)+1)-500)*(groundTruthA(3,fix((t-startTime_A)/T)+1)-500) + normrnd(0,10));
            yPolar = atan2((groundTruthA(3,fix((t-startTime_A)/T)+1)-500),(groundTruthA(1,fix((t-startTime_A)/T)+1)-1000)) + normrnd(0,0.01);
            meaCandidate(1,numberOfmea) = xPolar;
            meaCandidate(2,numberOfmea) = yPolar;
        end
    end
    
    %time when target2 appears
    if  t>= startTime_B && t<= endTime_B
        pddB = rand(1);
        %the situation in which both A and B were detected
        if pddB <= 0.9
            numberOfmea = numberOfmea + 1;
            xPolar = sqrt(abs((groundTruthB(1,fix((t-startTime_B)/T)+1)-1000))*abs((groundTruthB(1,fix((t-startTime_B)/T)+1)-1000))+(groundTruthB(3,fix((t-startTime_B)/T)+1)-500)*(groundTruthB(3,fix((t-startTime_B)/T)+1)-500) + normrnd(0,10));
            yPolar = atan2((groundTruthB(3,fix((t-startTime_B)/T)+1)-500),(groundTruthB(1,fix((t-startTime_B)/T)+1)-1000)) + normrnd(0,0.01);
            meaCandidate(1,numberOfmea) = xPolar;
            meaCandidate(2,numberOfmea) = yPolar;
        end
    end
    
    %initialize the track when time = 1
    if t == T
        [P_temp,x0_temp,measurement_temp,trackState_temp,qualityOfTrack_temp,numberOfTrack_temp ]= Initialization(meaCandidate,numberOfmea);
        numberOfTrack = numberOfTrack_temp;
        P(:,:,1:numberOfTrack) = P_temp(:,:,1:numberOfTrack);
        x0(:,:,1:numberOfTrack) = x0_temp(:,:,1:numberOfTrack);
        measurement(:,:,1:numberOfTrack) = measurement_temp(:,:,1:numberOfTrack);
        trackState(:,:,1:numberOfTrack) = trackState_temp(:,:,1:numberOfTrack);
        qualityOfTrack(:,:,1:numberOfTrack) = qualityOfTrack_temp(:,:,1:numberOfTrack);
    end
    
    if t > T
    %implement the tracking management
        if DAStrategy == 0
        [P_temp,x0_temp,measurement_temp,trackState_temp,qualityOfTrack_temp,numberOfTrack_temp ] = TrackManagementNN(P,x0,measurement,trackState,qualityOfTrack,numberOfTrack, meaCandidate,numberOfmea);   
        numberOfTrack = numberOfTrack_temp;
        P(:,:,1:numberOfTrack) = P_temp(:,:,1:numberOfTrack);
        x0(:,:,1:numberOfTrack) = x0_temp(:,:,1:numberOfTrack);
        measurement(:,:,1:numberOfTrack) = measurement_temp(:,:,1:numberOfTrack);
        trackState(:,:,1:numberOfTrack) = trackState_temp(:,:,1:numberOfTrack);
        qualityOfTrack(:,:,1:numberOfTrack) = qualityOfTrack_temp(:,:,1:numberOfTrack);
        end
        if DAStrategy == 1
        [P_temp,x0_temp,measurement_temp,trackState_temp,qualityOfTrack_temp,numberOfTrack_temp ] = TrackManagement(P,x0,measurement,trackState,qualityOfTrack,numberOfTrack, meaCandidate,numberOfmea);   
        numberOfTrack = numberOfTrack_temp;
        P(:,:,1:numberOfTrack) = P_temp(:,:,1:numberOfTrack);
        x0(:,:,1:numberOfTrack) = x0_temp(:,:,1:numberOfTrack);
        measurement(:,:,1:numberOfTrack) = measurement_temp(:,:,1:numberOfTrack);
        trackState(:,:,1:numberOfTrack) = trackState_temp(:,:,1:numberOfTrack);
        qualityOfTrack(:,:,1:numberOfTrack) = qualityOfTrack_temp(:,:,1:numberOfTrack);
        end
    end
    
    %plot the confirmed track
    for k = 1:numberOfTrack  
        %%%%%%%%%%%%plot the track%%%%%%%%%%%%
        if trackState(:,:,k) == 1    
            if confirmedTrack == 0
                confirmedTrack = confirmedTrack + 1;
                trackID(1,confirmedTrack) = k;
                dataPlot(1,1,confirmedTrack) = x0(1,trackID(1,confirmedTrack));
                dataPlot(2,1,confirmedTrack) = x0(3,trackID(1,confirmedTrack));
                countOfDataOfEachTrack(1,confirmedTrack) = countOfDataOfEachTrack(1,confirmedTrack) + 1;
            end
            for h = 1:confirmedTrack
                if trackID(1,h) == k;
                    countOfDataOfEachTrack(1,h) = countOfDataOfEachTrack(1,h) + 1;
                    dataPlot(1,countOfDataOfEachTrack(1,h),h) = x0(1,k);
                    dataPlot(2,countOfDataOfEachTrack(1,h),h) = x0(3,k);
                    key = 1;
                    break;
                end   
            end
            if key == 0 
                confirmedTrack = confirmedTrack + 1;
                trackID(1,confirmedTrack) = k;
                dataPlot(1,1,confirmedTrack) = x0(1,k);
                dataPlot(2,1,confirmedTrack) = x0(3,k);
                countOfDataOfEachTrack(1,confirmedTrack) = countOfDataOfEachTrack(1,confirmedTrack) + 1;
            end 
            key = 0;   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end   
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%Latency%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if confirmedTrack >= 1
        for w = 1:confirmedTrack
            if trackState(1,1,trackID(w)) == 1
%%%%%%%tentative latency%%%%%%%%%
                if TentativeSwitchA == 0 &&  t >= startTime_A && t <= endTime_A 
                    tentativeADistance = sqrt((x0(1,1,trackID(w)) - groundTruthA(1,fix((t-startTime_A)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthA(3,fix((t-startTime_A)/T)+1))^2);
                    if tentativeADistance <=60
                        latencyTantativeA = t - startTime_A;
                        TentativeSwitchA = 1;
                    end
                end
                if TentativeSwitchB == 0 && t >= startTime_B && t <= endTime_B 
                    tantativeBDistance = sqrt((x0(1,1,trackID(w)) - groundTruthB(1,fix((t-startTime_B)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthB(3,fix((t-startTime_B)/T)+1))^2);
                    if tantativeBDistance <= 60
                        latencyTantativeB = t - startTime_B;
                        TentativeSwitchB = 1;
                    end
                end
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%false track rate%%%%%%%%%%%%%%
                countOfConfirmed = countOfConfirmed + 1;
                if t >= startTime_A && t <= endTime_A 
                    farDistanceA = sqrt((x0(1,1,trackID(w)) - groundTruthA(1,fix((t-startTime_A)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthA(3,fix((t-startTime_A)/T)+1))^2);
                    if farDistanceA <=150 
                        countOfTrue = countOfTrue + 1;
                        if TentativeSwitchA == 1
                            errorPositionA(1,1:startTime_A+TentativeSwitchA -1) = nan;
                            errorVelocityA(1,1:startTime_A+TentativeSwitchA -1) = nan;
                            errorPositionA(1,counter) = farDistanceA;
                            errorVelocityA(1,counter) = (x0(2,1,trackID(w)) - groundTruthA(2,fix((t-startTime_A)/T)+1))^2 + (x0(4,1,trackID(w)) - groundTruthA(4,fix((t-startTime_A)/T)+1)); 
                        end
                    end
                end
                if t > endTime_A 
                    farDistanceA = sqrt((x0(1,1,trackID(w)) - groundTruthA(1,fix((endTime_A-startTime_A)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthA(3,fix((endTime_A-startTime_A)/T)+1))^2);
                    if farDistanceA <=150 
                        countOfTrue = countOfTrue + 1;
                        errorPositionA(1,counter:End) = nan;
                        errorVelocityA(1,counter:End) = nan;
                    end
                end                
                if t >= startTime_B && t <= endTime_B 
                    farDistanceB = sqrt((x0(1,1,trackID(w)) - groundTruthB(1,fix((t-startTime_B)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthB(3,fix((t-startTime_B)/T)+1))^2);
                    if farDistanceB <=150 
                        countOfTrue = countOfTrue + 1;
                        if TentativeSwitchB == 1
                            errorPositionB(1,1:startTime_B+TentativeSwitchB -1) = nan;
                            errorVelocityB(1,1:startTime_B+TentativeSwitchB -1) = nan;                  
                            errorPositionB(1,counter) = farDistanceB;
                            errorVelocityB(1,counter) = (x0(2,1,trackID(w)) - groundTruthB(2,fix((t-startTime_B)/T)+1))^2 + (x0(4,1,trackID(w)) - groundTruthB(4,fix((t-startTime_B)/T)+1));            
                        end
                    end
                end
                if t > endTime_B 
                    farDistanceB = sqrt((x0(1,1,trackID(w)) - groundTruthB(1,fix((endTime_B-startTime_B)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthB(3,fix((endTime_B-startTime_B)/T)+1))^2);
                    if farDistanceB <=150 
                        countOfTrue = countOfTrue + 1;
                        errorPositionB(1,counter:End) = nan;
                        errorVelocityB(1,counter:End) = nan;
                    end
                end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
            end  
%%%%%%%%delete latency%%%%%%%%%
            if trackState(1,1,trackID(w)) == 2
                deleteADistance = sqrt((x0(1,1,trackID(w)) - groundTruthA(1,fix((endTime_A-startTime_A)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthA(3,fix((endTime_A-startTime_A)/T)+1))^2);
                deleteBDistance = sqrt((x0(1,1,trackID(w)) - groundTruthB(1,fix((endTime_B-startTime_B)/T)+1))^2 + (x0(3,1,trackID(w)) - groundTruthB(3,fix((endTime_B-startTime_B)/T)+1))^2);
                if deleteADistance <= 150
                    latencyDeleteA = t - endTime_A;
                end
                if deleteBDistance <= 150
                    latencyDeleteB = t - endTime_B;
                end
            end
%%%%%%%%%%%%%%%%%%%%%%%% 
        end
        if countOfConfirmed ~= 0
        falseTrackRate(1,counter) = countOfConfirmed - countOfTrue;
        end
    end
    if confirmedTrack == 0 
%%%%%%%%%%calculate the falseTrackRate when there is no confirmed track%%%%%%%%%%%%%%%%%%%%%
        falseTrackRate(1,counter) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    countOfConfirmed = 0;%reset the count of confirmed track
    countOfTrue = 0;%reset the count of true track
end

%%%%%%%%%%%%%%%%%%%%%%%%%plot the trajectory%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p = 1:confirmedTrack;
    %plot(dataPlot(1,1:countOfDataOfEachTrack(1,p),p),dataPlot(2,1:countOfDataOfEachTrack(1,p),p),'^-','color',color(:,:,p));
    hold on;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end