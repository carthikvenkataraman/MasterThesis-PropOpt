clear all
close all
clc

% Buffer Data in order [maximumBufferLevel, minimumBufferLevel, maximumStateOfBuffer, minimumAllowedStateOfBuffer]
maximumBufferLevel = 5e6;   % MegaCoulombs
minimumBufferLevel = 0;
maximumStateOfBuffer = 0.7;
minimumAllowedStateOfBuffer = 0.3;  % Minimum allowed SoC / fuel level can be adjusted
openCircuitVoltage = 3.6;  % Volts

bufferData=[maximumBufferLevel, minimumBufferLevel, maximumStateOfBuffer, minimumAllowedStateOfBuffer, openCircuitVoltage];

save('Battery00.mat','bufferData'); 
clear bufferData;