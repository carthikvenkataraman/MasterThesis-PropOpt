clear all
close all
clc

% Influence of axle number
fileNumber=[3,13,22,31,34,43,52,55;
            7,14,23,32,35,44,53,56;
            11,15,24,33,36,45,54,57];
engineSize=[11,13,16];

%% Load simulation output files
for i=1:size(fileNumber,1)   % Engine size - D11, D13 or D16
    for j=1:size(fileNumber,2)   % Number of axles
        path='OutputsWithPredictiveControl/';
        fileNameNumber = int2str(fileNumber(i,j));
        fileName='/C';
        extension='.mat';
        fullPath=strcat(path, fileNameNumber,fileName, extension);
        C(i,j) = load(fullPath);
    end
end

for i=1:size(fileNumber,1)   % Engine size - D11, D13 or D16
    for j=1:size(fileNumber,2)   % Number of axles
        path='OutputsWithPredictiveControl/';
        fileNameNumber = int2str(fileNumber(i,j));
        fileName='/U0B';
        extension='.mat';
        fullPath=strcat(path, fileNameNumber,fileName, extension);
        B0(i,j) = load(fullPath);
    end
end

for i=1:size(fileNumber,1)
    for j=1:size(fileNumber,2) 
        missionTime(i,j) = size(C(i,j).positionOverMission,2);
        fuelConsumed(i,j) = 600-B0(i,j).bufferLevelOverMission(end);
        combinationStartability(i,j) = C(i,j).combinationStartability;
        mode1(i,j) = sum(C(i,j).operatingModeOverMission==1);
        mode2(i,j) = sum(C(i,j).operatingModeOverMission==2);
        mode3(i,j) = sum(C(i,j).operatingModeOverMission==3);
        mode4(i,j) = sum(C(i,j).operatingModeOverMission==4);
        modeM1(i,j) = sum(C(i,j).operatingModeOverMission==-1);
        modeM2(i,j) = sum(C(i,j).operatingModeOverMission==-2);
        mode0(i,j) = sum(C(i,j).operatingModeOverMission==0);
    end
end

%% Plot mission time

figure('name', 'Mission time vs engine size (GCW=70t)');
plot(missionTime/3600)
legend('011-000-00-000', '011-010-00-000', '011-010-01-000',...
                    '011-010-01-001','011-011-01-001','011-011-11-001','011-111-11-111','Location','Best');
title('Mission time vs engine size (GCW=70t)');
xlabel('Engine size'), ylabel('Mission time (hours)');
set(gca,'XTick',[1 2 3]);
set(gca,'XTickLabel',{'D11','D13','D16'});
saveas(gcf,'PlotsWithPredictiveControl/Mission time vs axle number and engine size.pdf');

%% Plot fuel consumed

figure('name', 'Fuel consumption vs engine size (GCW=70t)');
plot(fuelConsumed)
legend('011-000-00-000', '011-010-00-000', '011-010-01-000',...
                    '011-010-01-001','011-011-01-001','011-011-11-001','011-111-11-111','Location','Best');
title('Fuel consumption vs engine size (GCW=70t)');
xlabel('Engine size'), ylabel('Fuel consumption (litres)');
set(gca,'XTick',[1 2 3]);
set(gca,'XTickLabel',{'D11','D13','D16'});
saveas(gcf,'PlotsWithPredictiveControl/Fuel consumption vs axle number and engine size.pdf');

%% Plot startability

figure('name', 'Combination Startability vs engine size (GCW=70t)');
plot(combinationStartability)
legend('011-000-00-000', '011-010-00-000', '011-010-01-000',...
                    '011-010-01-001','011-011-01-001','011-011-11-001','011-111-11-111','Location','Best');
title('Combination Startability vs engine size (GCW=70t)');
xlabel('Engine size'), ylabel('Combination Startability (degrees)');
set(gca,'XTick',[1 2 3]);
set(gca,'XTickLabel',{'D11','D13','D16'});
saveas(gcf,'PlotsWithPredictiveControl/Combination startability vs axle number and engine size.pdf');

%% Plot mission speed

for i=1:size(fileNumber,1)
    figureName=strcat('Mission speed vs position (constant GCW = 70t, engine - D',int2str(engineSize(i)),')');
    figure('name', figureName);
    for j=1:size(fileNumber,2)
        plot(C(i,j).positionOverMission, C(i,j).speedOverMission);
        hold all
    end
    title(figureName);
    legend('011-000-00-000', '011-010-00-000', '011-010-01-000',...
                    '011-010-01-001','011-011-01-001','011-011-11-001','011-111-11-111','Location','Southwest');
    xlabel('Position over mission (m)');
    ylabel('Speed over mission (m/s)');
    saveas(gcf,strcat('PlotsWithPredictiveControl/',figureName,'.pdf'));
end

figureName=strcat('Mission speed vs position (constant GCW = 70t)'); % = ', int2str(gcw(i)), 't)');
figure('name', figureName);
for i=1:size(fileNumber,1)
    subplot(size(fileNumber,1),1,i);
    for j=1:size(fileNumber,2)
        plot(C(i,j).positionOverMission, C(i,j).speedOverMission);
        hold all
    end
    title(strcat(figureName, ' engine - D',int2str(engineSize(i)), ')'));
    legend('011-000-00-000', '011-010-00-000', '011-010-01-000',...
                    '011-010-01-001','011-011-01-001','011-011-11-001','011-111-11-111','Location','Southwest');
    xlabel('Position over mission (m)');
    ylabel('Speed over mission (m/s)');
    saveas(gcf,strcat('PlotsWithPredictiveControl/',figureName,'.pdf'));
end

%% Clear unnecessary variables from workspace
clearvars i j path fullPath fileNameNumber fileName extension;
