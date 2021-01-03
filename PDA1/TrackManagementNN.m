function [ P,x,measurement,trackState,qualityOfTrack,numberOfTrack ] = TrackManagementNN( P0,x0,measurement_0,trackState_0,qualityOfTrack_0,numberOfTrack, meaCandidate,numberOfmea)
%TRACKMANAGEMENT Summary of this function goes here

%P0,x0,measurement_0,tentativeJudge,deleteJudge,trackState_0,numberOfTrack is the information of tracks
%meaCandidate is measurement matrix

inputParameter = InputParameter;
P = zeros(4,4,1000);
x = zeros(4,1,1000);
measurement = zeros(2,200,1000);
trackState = zeros(1,1,1000);
trackState(1,1,1:numberOfTrack) = trackState_0(1,1,1:numberOfTrack);
qualityOfTrack = zeros(1,1,1000);

%the probablity of detection
PD = 0.9;

%probablity of gating
PG = 0.99;

%false alarm
Lambda = inputParameter.Lambda;

%the value of gating
gamma = chi2inv(0.99,2);

%the number of associated measurement_0
numberOfAssocaition = 0;

%initialize the state transition matrix
T = inputParameter.T;
F(1,:) = [1,T,0,0];
F(2,:) = [0,1,0,0];
F(3,:) = [0,0,1,T];
F(4,:) = [0,0,0,1];

%generate process covariance matrix
movementSigma = 0.5;
G = [(T^2)/2 0;T 0;0 (T^2)/2;0 T];
Q = G*(movementSigma^2)*transpose(G);

%define the R matrix
R(1,:) = [100,0];
R(2,:) = [0,0.0001];

x_ = zeros(4,1,numberOfTrack);%define x(k + 1|k) matrix
P_ = zeros(4,4,numberOfTrack);%define P(k + 1|k) matrix
meaState = zeros(1,numberOfmea);%define measurement_0 state matrix indicating if the measurement_0 was associated
meaAssociated = zeros(2,20);%define the matrix which contain the associated measurement_0s for every track
likelihoodRatio = zeros(1,20);%define the likelihoodratio matrix for every measurement_0
sumOfLikelihoodRatio = 0; %define the sume of likelihoodratio

for i = 1:numberOfTrack
    if trackState_0(:,:,i) ~= 2
        x_(:,:,i) = F*x0(:,:,i);%x(k + 1|k) = F (k)* x(k|k)
        P_(:,:,i) = F*(P0(:,:,i)*(F.')) + Q;%P (k + 1|k) = F (k)P (k|k)F (k)' + Q(k)
    
        %define the H matrix(Jacobian Matrix)
        H = zeros(2,4);
        H(1,:) = [(x_(1,1,i)-1000)/(sqrt((x_(1,1,i)-1000)^2+(x_(3,1,i)-500)^2)),0,(x_(3,1,i)-500)/(sqrt((x_(1,1,i)-1000)^2+(x_(3,1,i)-500)^2)),0];
        H(2,:) = [(500-x_(3,1,i))/((x_(1,1,i)-1000)^2+(x_(3,1,i)-500)^2),0,(x_(1,1,i)-1000)/((x_(1,1,i)-1000)^2+(x_(3,1,i)-500)^2),0];
    
        %define S matrix
        S = H*P_(:,:,i)*transpose(H) + R;
    
        %z_hat matrix
        z_hat(1,1) = sqrt((x_(1,1,i)-1000)^2+(x_(3,1,i)-500)^2);
        z_hat(2,1) = atan2((x_(3,1,i)-500),(x_(1,1,i)-1000));
    
        W = (P_(:,:,i)) * ((H')* (inv(S)));
    
        for j = 1:numberOfmea
            %z matrex
            z(1,1) = meaCandidate(1,j);
            z(2,1) = meaCandidate(2,j);
     
            distance = (z-z_hat)'*(inv(S))*(z-z_hat);
            if distance <= gamma
                meaState(1,j) = 1; %1 means the measurement was associated
                numberOfAssocaition = numberOfAssocaition+1;
                meaAssociated(:,numberOfAssocaition) = z;
            end
        end
    
        if numberOfAssocaition > 0 %if measurements fell into the gate
            for k = 1:numberOfAssocaition
            nnDistance = (meaAssociated(:,k)-z_hat)'*(inv(S))*(meaAssociated(:,k)-z_hat);
            if k == 1
                maxValue = nnDistance;
                zCandidate = meaAssociated(:,k);
            end
            if maxValue <= nnDistance
                maxValue = nnDistance;
                zCandidate = meaAssociated(:,k);
            end
            likelihoodRatio(1,k) = mvnpdf(meaAssociated(:,k),z_hat,S)*PD/Lambda;
            sumOfLikelihoodRatio = sumOfLikelihoodRatio + likelihoodRatio(1,k);
            end
            
            x(:,:,i) = x_(:,:,i) + W*(zCandidate - z_hat);
            P(:,:,i) = P_(:,:,i) - W*S*(W');
        
            %%%%%%%%%%%%Judge if the track should be deleted%%%%%%%%%%%
            qualityOfTrack(:,:,i) = (1-(PD*PG-PD*PG*sumOfLikelihoodRatio))*0.98*qualityOfTrack_0(:,:,i)/(1-(PD*PG-PD*PG*sumOfLikelihoodRatio)*0.98*qualityOfTrack_0(:,:,i));
            if trackState_0(:,:,i) == 0
                if qualityOfTrack(:,:,i) >= 0.95
                    trackState(:,:,i) = 1;
                elseif qualityOfTrack(:,:,i) < 0.005
                    trackState(:,:,i) = 2;
                end
            end
        
            if trackState_0(:,:,i) == 1
                if qualityOfTrack(:,:,i) <= 0.005
                    trackState(:,:,i) = 2;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    
        if numberOfAssocaition == 0%if no measurement fell into the gating
            x(:,:,i) = x_(:,:,i);
            P(:,:,i) = P_(:,:,i);
            qualityOfTrack(:,:,i) = ((1-PD*PG))*0.98*qualityOfTrack_0(:,:,i)/(1-PD*PG*0.98*qualityOfTrack_0(:,:,i));
                if trackState_0(:,:,i) == 0
                    if qualityOfTrack(:,:,i) >= 0.95
                        trackState(:,:,i) = 1;
                    elseif qualityOfTrack(:,:,i) < 0.005
                        trackState(:,:,i) = 2;
                    end
                end
        
                if trackState_0(:,:,i) == 1
                    if qualityOfTrack(:,:,i) <= 0.005
                        trackState(:,:,i) = 2;
                    end
                end
        end
    
    end
    
    %%%%%%%%%%%%reset the temp variable%%%%%%%%
    x_ = zeros(4,1,numberOfTrack);
    P_ = zeros(4,4,numberOfTrack);
    meaAssociated = zeros(2,20);
    likelihoodRatio = zeros(1,20);
    sumOfLikelihoodRatio = 0; 
    numberOfAssocaition = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%use unassociated points to initialize
for n = 1:numberOfmea
    if meaState(1,n) == 0
        [P_tmep,x_temp,measurement_temp,trackState_temp,qualityOfTrack_temp,numberOfTrack_temp] = Initialization(meaCandidate(:,n) , 1);
        numberOfTrack = numberOfTrack + numberOfTrack_temp;
        P(:,:,numberOfTrack) = P_tmep(:,:,numberOfTrack_temp);
        x(:,:,numberOfTrack) = x_temp(:,:,numberOfTrack_temp);
        measurement(:,:,numberOfTrack) = measurement_temp(:,:,numberOfTrack_temp);
        trackState(:,:,numberOfTrack) = trackState_temp(:,:,numberOfTrack_temp);
        qualityOfTrack(:,:,numberOfTrack) = qualityOfTrack_temp(:,:,numberOfTrack_temp);     
    end
end

end

