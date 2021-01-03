function [] = Trajectory(groundTruth,estimation,measurement)
% This function plots the trajectory
% groundTruth is the truth value with noise
% estimation is estimated values
% measurement is the measurement values

figure
hold on;
grid on;

plot(1000,500,'kh',groundTruth(1,:),groundTruth(3,:),'r',estimation(1,:),estimation(3,:),'g-s',measurement(1,:),measurement(2,:),'b*');
rectangle('Position',[-9000,-9500,20000,20000],'Curvature',[1,1]);
axis equal;
title('Trajectory');
xlabel('x axis/m');
ylabel('y axis/rad');
legend('Sensor','Groundtruth','Estimation','Measurement')
end

