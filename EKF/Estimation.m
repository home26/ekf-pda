function [groundTruth,estimation,measurement] = Estimation(T, End,startPositionX, startVelocityX, startPositionY, startVelocityY, movementSigma)
% This function generates estimated value
% T is sample time
% End is the total time
% startPositionX is startPosition in x axis
% startVelocityX is startVelocity in x axis
% startPositionY is startPosition in y axis
% startVelocityY is startVelocity in y axis
% movementSigma is the movement noise

numberOfColumns = fix((End/T))+1;%number of colomuns of measurement and estimation matrix
groundTruth = GroundTruth(T, End,startPositionX, startVelocityX, startPositionY, startVelocityY, movementSigma);%generate groundtruth
estimation = zeros(4,numberOfColumns);%matrix for estimation
measurement = zeros(2,numberOfColumns);%matrix for measurement
minimumDiatance = 0;%initialize minumumDistance
numberOfDetection = 0;%initialize numberOfDetection

%initialize the state transition matrix
F(1,:) = [1,T,0,0];
F(2,:) = [0,1,0,0];
F(3,:) = [0,0,1,T];
F(4,:) = [0,0,0,1];

%initialize the state covariance matrix
P(1,:) = [120,0,0,0];
P(2,:) = [0,10,0,0];
P(3,:) = [0,0,120,0];
P(4,:) = [0,0,0,10];

%define measurement covariance matrix
R(1,:) = [100,0];
R(2,:) = [0,0.0001];

%generate process covariance matrix
G = [(T^2)/2 0;T 0;0 (T^2)/2;0 T];
Q = G*(movementSigma^2)*transpose(G);

%define the initial state vector
x0 = [startPositionX, startVelocityX, startPositionY, startVelocityY]';
initialState = mvnrnd(x0, P)';
x = initialState;

%define measurement vector
z = [0;0];

for i=1:numberOfColumns
    
    x_ = F*x; %x(k + 1|k) = F (k)* x(k|k)
    P_ = F*(P*(F.')) + Q; %P (k + 1|k) = F (k)P (k|k)F (k)¡ä + Q(k)
    
    %define the H matrix(Jacobian Matrix)
    H = zeros(2,4);
    H(1,:) = [(x_(1)-1000)/(sqrt((x_(1)-1000)^2+(x_(3)-500)^2)),0,(x_(3)-500)/(sqrt((x_(1)-1000)^2+(x_(3)-500)^2)),0];
    H(2,:) = [(500-x_(3))/((x_(1)-1000)^2+(x_(3)-500)^2),0,(x_(1)-1000)/((x_(1)-1000)^2+(x_(3)-500)^2),0]; 
    
    %define S matrix
    S = H*P_*transpose(H) + R;
    
    %estimated measurement
    z_hat(1,1) = sqrt((x_(1)-1000)^2+(x_(3)-500)^2);
    z_hat(2,1) = atan2((x_(3)-500),(x_(1)-1000));

    
    %Considering the Pd = 0.9
    pdd = rand(1);
    if pdd <= 0.9
        
        numberOfFalseAlarm = poissrnd(2*pi);%number of falsealarms;
        numberOfDetection = numberOfFalseAlarm + 1;%number of detections
        candidateValue = zeros(2,numberOfDetection);%matrix for nearest-neighbour assocaition
        %Generating the specific number of target detections
        for j = 1:numberOfFalseAlarm
            xPolar = 0 + 10000*rand(1);
            yPolar = -pi+2*pi*rand(1);
            candidateValue(1,j) = xPolar;
            candidateValue(2,j) = yPolar;
        end
        candidateValue(1,numberOfDetection) = sqrt(abs((groundTruth(1,i)-1000))*abs((groundTruth(1,i)-1000))+(groundTruth(3,i)-500)*(groundTruth(3,i)-500) + normrnd(0,10));
        candidateValue(2,numberOfDetection) = atan2((groundTruth(3,i)-500),(groundTruth(1,i)-1000)) + normrnd(0,0.01);
        
    elseif pdd > 0.9
        
        numberOfFalseAlarm = poissrnd(2*pi);%number of falsealarms;
        numberOfDetection = numberOfFalseAlarm;%number of detections
        candidateValue = zeros(2,numberOfDetection);%matrix for nearest-neighbour assocaition
        %Generating the specific number of target detections
        for j = 1:numberOfFalseAlarm
            xPolar = 0 + 10000*rand(1);
            yPolar = -pi+2*pi*rand(1);
            candidateValue(1,j) = xPolar;
            candidateValue(2,j) = yPolar;
        end
        
    end
    
    
    
    %Nearest-Neighbour Assocaition 
    for k = 1:numberOfDetection
        %calculate gating;
        gamma = chi2inv(0.99,2);
        %calculating the distance D(z) = [z-z?(k + 1|k)]¡ä*inv(S(k + 1))*[z-z?(k + 1|k)] 
        distance = (([candidateValue(1,k);candidateValue(2,k)] - z_hat).')*(inv(S))*([candidateValue(1,k);candidateValue(2,k)] - z_hat);
        
        if distance > gamma 
            continue;
        end
        
        if minimumDiatance == 0
            minimumDiatance = distance;
        end

        if distance <= minimumDiatance
            %generating the nearest measurement
            minimumDiatance = distance;
            z(1,1) = candidateValue(1,k);
            z(2,1) = candidateValue(2,k);
        end  
    end
    
    if size(candidateValue,2) ~= 0
        measurement(1,i) = 1000 + cos(candidateValue(2,k))*candidateValue(1,k);
        measurement(2,i) = 500 + sin(candidateValue(2,k))*candidateValue(1,k);
    end    
    
    %if all detections are beyond the gate,then use estimated measurements
    if (z(1,1) == 0) || (z(2,1) == 0)
        %z(1,1) = z_hat(1,1);
        %z(2,1) = z_hat(2,1);
        estimation(:,i) = x_;
        x = x_;
        P = P_;
        continue;
    end
    
    minimumDiatance = 0;%reset the minumum distance
    
    y = z - z_hat; %the error between the real measurement and estimated measurement
    W = P_*transpose(H)*S^-1; %generating the Kalman Filter gain
    P = P_ - (W*S*(transpose(W))); %update the state covariance matrix
    x = x_ + (W*y); %update state vector
    estimation(:,i) = x; %output estimation matrix
    z(1,1) = 0;
    z(2,1) = 0;
end
Trajectory(groundTruth,estimation,measurement);%plot the trajectory
end