% This program calculates the slopes of linear regression models 
% on moving average windows
% Built by Dinh-Tuan Phan, Ph.D.

clf
clc
clear all


% specify input video
file = 'trial-David-01.xlsx';
calibratedslope = 0.0918;
samplingwindow = 180;
startingdatapoint = 1;             % the starting datapoint to process (remove bad frames at the beginning)
endingdatapoints = 1;               % the ending datapoints to process (remove bad frames at the end)
collectionarea = 10;

[filepath,name,ext] = fileparts(file);

% set programed profile

%profile = [0 15; 1 1];
%profile = [0 10 18 27; 0.1 1 1 0.1];

%profile = [0 3 3.01 6 6.01 9 9.01 12 12.01 15 15.01 18 18.01  21 21.01 24 24.01 27 27.01 30;...
%           0.5 0.5 1 1 1.5 1.5 1 1 0.5 0.5 1 1 1.5 1.5 1 1 0.5 0.5 1 1];

data = readtable(file);
time = data{startingdatapoint:end-endingdatapoints,1}/60;
cap = data{startingdatapoint:end-endingdatapoints,3};
cap = medfilt1(cap,180);

fid = fopen(strcat(name,'.txt'),'w');

for i = 1:length(time)
    if i <= samplingwindow/2
        
        x = time(i:i+samplingwindow);
        y = cap(i:i+samplingwindow);
        linearCoefficients = polyfit(x, y, 1);
        
        
    elseif i > length(time)-samplingwindow/2
        
        x = time((i-samplingwindow):i);
        y = cap((i-samplingwindow):i);
        linearCoefficients = polyfit(x, y, 1);
        
    else
        x = time(i-samplingwindow/2:i+samplingwindow/2);
        y = cap(i-samplingwindow/2:i+samplingwindow/2);
        linearCoefficients = polyfit(x, y, 1);
        
    end
    
    flowrate(i) = linearCoefficients(1)/calibratedslope/collectionarea;
    
    fprintf(fid,'%4f,%4f,%4f\r\n',time(i),cap(i),flowrate(i));
    
end

fclose(fid);

colororder({'k','r'})
figure('Name',strcat(name),'NumberTitle','off');
yyaxis left;
plot(time,cap,'LineWidth',2,'Color',[0 0 0]);
xlabel('Time (min)');
xlim([5 30])
ylabel('Capacitance change ΔC (pF)');
hold on

yyaxis right
% plot(profile(1,:),profile(2,:),'--','LineWidth',2,'Color',[0 0 1]);
% hold on

flowrate = medfilt1(flowrate,10);
plot(time(181:end),flowrate(181:end),'-','LineWidth',2,'Color',[1 0 0]);
ylabel('Sweat rate (µL min^-^1 cm^-^2)','Color',[1 0 0]);

legend('capacitance change ΔC','sweat rate','location','nw');

shg
