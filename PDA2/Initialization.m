function [P,x0,measurement,trackState,qualityOfTrack,numberOfTrack] = Initialization( pointsToBeInitialized,numberOfmea)
%Initialization is to initialize the track

numberOfTrack = numberOfmea;%obtain the number of tracks
P = zeros(4,4,numberOfTrack);%initialize P matrix
x0 = zeros(4,1,numberOfTrack);%initialize x0 vector
measurement = zeros(2,200,numberOfTrack);%initialize the measurement matrix
trackState = zeros(1,1,numberOfTrack);%initialize the trackState matrix
qualityOfTrack = zeros(1,1,numberOfTrack);%initialize the qualityOfTrack matrix

for i = 1:numberOfTrack
    
    P(1,:,i) = [20,0,0,0];
    P(2,:,i) = [0,5,0,0];
    P(3,:,i) = [0,0,20,0];
    P(4,:,i) = [0,0,0,5];
    
    x0(1,1,i) = 600 + cos(pointsToBeInitialized(2,i))*pointsToBeInitialized(1,i);
    x0(2,1,i) = 0;
    x0(3,1,i) = 600 + sin(pointsToBeInitialized(2,i))*pointsToBeInitialized(1,i);
    x0(4,1,i) = 0;
    
    qualityOfTrack(1,1,i) = 0.2;%the initial value of qualityOfTrack
    
end

end

