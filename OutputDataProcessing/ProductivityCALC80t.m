% Calculate productivity for Combination#11 on Malmö-Göteborg with GCW 50t
% Tractor engine - D16, Electric motors used - M01, Buffer size - B01

%% WHAT CHANGES EVERY 5 YEARS
% Battery mass - hence mPayload, hence Revenue
% Battery price
% Fuel price
% Electricity price
% Driver hourly wages

%% WHAT TO CHANGE

% FileNumber on lines 27-31
% File number on lines 152, 162 and 170
% nEAxles on line 49
% Comment out lines 28-31 if necessary

%% -----------------------------------------------------------------------------------------------------------------------------------

clear all
close all
% clc

%% Currency conversion

USDtoEUR = 0.76;

%% Simulation outputs

C = load('/home/karthik/Documents/GitHubRepos/MasterThesis-PropOpt/OutputDataProcessing/OutputsWithOtherGCWs/80/11/C.mat');
B(1) = load('/home/karthik/Documents/GitHubRepos/MasterThesis-PropOpt/OutputDataProcessing/OutputsWithOtherGCWs/80/11/U0B.mat');
% B(2) = load('/home/karthik/Documents/GitHubRepos/MasterThesis-PropOpt/OutputDataProcessing/OutputsWithOtherGCWs/80/11/U1B.mat');
% B(3) = load('/home/karthik/Documents/GitHubRepos/MasterThesis-PropOpt/OutputDataProcessing/OutputsWithOtherGCWs/80/11/U2B.mat');
% B(4) = load('/home/karthik/Documents/GitHubRepos/MasterThesis-PropOpt/OutputDataProcessing/OutputsWithOtherGCWs/80/11/U3B.mat');

dMission = C.positionOverMission(end)/1000;    % km
tMission = size(C.positionOverMission,2)/3600; % hours
vFuel = C.fuelConsumptionOverMission(end);     % litres 

%% Get Parameters over years

ParameterEvolution;

%% Combination and mission data

sizeBattery = [batterySizes(2) batterySizes(2) batterySizes(2)];    % SIZE OF BATTERY 

%% ------CHANGE BELOW DATA TO CHANGE CONFIGURATION ----------------------------------------------------------------------
nUnits = 4;
nEAxles = [0 0 0]; 
battIndex = [0 0 0];    % Binary - Battery exists - YES or NO - 1 or 0
nEUnits = size(nEAxles,2);

%% ------CHANGE BELOW DATA FOR N_FIRST_OWNER AND TRIPS ------------------------------------------------------------------

nFirstOwner=5;
nMissionDaily = 2;
nMissionAnnual = nMissionDaily*365;

%% Productivity evolution over years 2015-2030 in 5 year intervals
% YEARS = [2015 2020 2025 2030];

for nYear=1:4     
    %% --- Mission revenues----------------------------------------------------------------------------------------------

    revUnitFreight = 0.06*USDtoEUR; % [12] CHANGE IF REVENUE PER UNIT FREIGHT CHANGES

    KerbWeight = [9000, 7000, 3000, 4000];
    
    %% --- CHANGE THESE TO OBSERVE EFFECTS OF GCW-------------------------------------------------------------------------
    
    AxleLoads(1,:) = [7094, 15340/2*[1 1]];   
    AxleLoads(2,:) = 22400/3*[1 1 1];    
    AxleLoads(3,:) = 12500/2*[1 1 0];    
    AxleLoads(4,:) = 22400/3*[1 1 1];   
    
    GVW=0;
    GCW=0;
    for i=1:nUnits
        GVW = GVW+KerbWeight(i);
        GCW = GCW+sum(AxleLoads(i,:));
    end
    
    mBattery(nYear,:) = [batteryMass(2,nYear) batteryMass(2,nYear) batteryMass(2,nYear)];    % MASS OF BATTERY ON EACH TRAILING UNIT IN FIRST YEAR
    mMotor = 43*nEAxles;
    mEAxle(nYear,:) = mBattery(nYear,:)+mMotor;
    deltaMAxle(nYear) = sum(mEAxle(nYear,:));

    mPayloadGross = GCW-GVW;
    mPayloadNet(nYear) = mPayloadGross - deltaMAxle(nYear);    % INCREASES as deltaMAxle decreases every 5 years
    
    revMission(nYear) = revUnitFreight*(70000/1000)*300; %revUnitFreight*(mPayloadNet(nYear)/1000)*dMission;
    revAnnual(nYear) = revMission(nYear) * nMissionAnnual;
    rN(nYear) = revAnnual(nYear)*nFirstOwner;

    %% --- Fixed Costs-----------------------------------------------------------------------------------------------------

    % Base combination
    pTractorBase = 130000;
    deltaPowertrain = 15000;    % D16-D11
    pUnit = [pTractorBase, 70000, 40000, 70000]*USDtoEUR+[deltaPowertrain, 0, 0, 0];
    cFixedConv = sum(pUnit);

    % Electrification
    pEMotor = 30000;
    pEAxle = pEMotor*nEAxles;   % EUR
    pBattery(nYear,:) = batteryPrice(2,nYear)*battIndex;
    cFixedElec(nYear,:) = pBattery(nYear,:)+pEAxle;
    
    cFixed(nYear) = cFixedConv+sum(cFixedElec(nYear,:));

    %% --- Operational costs------------------------------------------------------------------------------------------------

    %% --- CHANGE BELOW IF RATIOS OF OTHER COSTS TO DRIVER COSTS CHANGES ---------------------------------------------------
    rMntDriver = 6/35;
    rTyreDriver = 7/35;
    rTollDriver = 14/35;

    if(any(nEAxles)==1)
        for j=2:nUnits
            if(nEAxles(j-1)~=0)
                deltaSOC = (B(1,j-1).stateOfBufferOverMission(1))-(B(1,j-1).stateOfBufferOverMission(end));
                if(deltaSOC<1)
                    deltaSOC=0;
                end
                chargeConsumedUnit(j-1) = deltaSOC*sizeBattery(1,j-1);
            else
                chargeConsumedUnit(j-1) = 0;
            end
        end
        chargeConsumedUnitTotal = sum(chargeConsumedUnit);
    else
        chargeConsumedUnitTotal=0;
    end
    eRecharge = chargeConsumedUnitTotal*3.6/3.6e6;  %kWh

    cDriver(nYear) = tMission*driverPrice(nYear);
    cFuel(nYear) = vFuel*fuelPrice(nYear);
    cMnt(nYear) = cDriver(nYear)*rMntDriver;
    cTyres(nYear) = cDriver(nYear)*rTyreDriver;
    cTolls(nYear) = cDriver(nYear)*rTollDriver;
    cElec(nYear) = eRecharge*elecPrice(nYear);

    cVariableMission(nYear) = cDriver(nYear)+cFuel(nYear)+cMnt(nYear)+cTyres(nYear)+cTolls(nYear)+cElec(nYear);
    cVariableN(nYear) = cVariableMission(nYear)*nFirstOwner*nMissionAnnual;

    %% Productivity

    P(nYear) = rN(nYear)/(cFixed(nYear)+cVariableN(nYear));
end

save('OutputsWithOtherGCWs/80/11/ProductivityFixedRevenue.mat');

figure('name', 'Mission costs and revenues over years');
plot(rN)
hold all, plot(cFixed)
hold all, plot(cVariableN)
legend('Mission Revenue (Annual)', 'Fixed Cost', 'Operating Cost (Annual)')
xlabel('Year'), ylabel('Mission fixed & operating costs, mission revenues (EUR)');
set(gca,'XTick',[1 2 3 4]);
set(gca,'XTickLabel',{'2015','2020','2025', '2030'});
saveas(gcf, 'PlotsProductivityWithOtherGCWs/80/11/MFORvsYearFixedRevenue.pdf');

figure('name', 'Mission productivity over years');
plot(P);
legend('N-year Productivity')
xlabel('Year'), ylabel('Mission N-year Productivity (EUR/EUR)');
set(gca,'XTick',[1 2 3 4]);
set(gca,'XTickLabel',{'2015','2020','2025', '2030'});
saveas(gcf, 'PlotsProductivityWithOtherGCWs/80/11/ProdvsYearFixedRevenue.pdf');

P