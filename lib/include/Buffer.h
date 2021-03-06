#ifndef _BUFFER_H
#define _BUFFER_H

#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <memory>
#include <sstream>
#include <cstring>

class Buffer {
      int unitIndex, unitBufferTypeIndex;
      std::string bufferName, completeBufferName;
      std::vector<int> bufferGenes; 
      char* bufferFileName;
      std::vector<double> bufferData;

      std::vector<double> bufferEfficiency;  
      double maximumPower;

      void GetBufferIndex();
      void GetBufferFileName();
      void LoadBuffer();
      void UpdateBufferAvailabilityRatio();

   public:
      int bufferIndex;             
      double maximumBufferLevel, minimumBufferLevel, instantaneousBufferLevel;//, bufferCapacity; 
      double referenceStateOfBuffer, maximumStateOfBuffer;         
      double stateOfBuffer;
      double openCircuitVoltage;
      double instantaneousBufferDemand;
      double bufferAvailabilityRatio;
      double minimumStateOfBuffer;
      double referenceDepthOfDischarge = 0.8;
      int numberOfBatteryReplacements;

      double endOfStepPowerDemand;
      std::vector<double> bufferLevelOverMission, bufferPowerDemandOverMission;
      std::vector<double> bufferAvailabilityRatioOverMission, stateOfBufferOverMission;
      std::vector<double> referenceSoCOverMission;

      Buffer(int , std::vector<int> );
      void GetStateOfBuffer();
      double GetBufferAvailabilityRatio();
      void UpdateReferenceSoC(double );
      std::string ReturnBufferName();
      virtual void RunBuffer(double , double );
      ~Buffer();
};

#endif