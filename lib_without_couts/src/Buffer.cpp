#include "Buffer.h"
#include "/home/karthik/MATLAB/R2013b/extern/include/mat.h"

typedef std::vector<int> Genes;

Buffer::Buffer(int currentUnitIndex, std::vector<int> currentBufferGenes) {
   //std::cout<<"Buffer creation begun"<<std::endl;
   unitIndex = currentUnitIndex;
   unitBufferTypeIndex = (unitIndex==0)? 0 : 1;
   bufferName = (unitBufferTypeIndex==0)? "FuelTank0" : "Battery0";
   bufferGenes= currentBufferGenes;
   GetBufferIndex();
   GetBufferFileName();
   LoadBuffer();
   UpdateBufferAvailabilityRatio();

   //bufferAvailabilityRatioOverMission.push_back(bufferAvailabilityRatio);
   //stateOfBufferOverMission.push_back(stateOfBuffer);
}

void Buffer::GetBufferIndex() {
   std::vector<int>::iterator it = std::find(bufferGenes.begin(), bufferGenes.end(),1);
   bufferIndex = std::distance(bufferGenes.begin(), it);
   if(bufferIndex==3) {
      std::cout<<"Error in buffer genes. No buffer specified"<<std::endl;
      bufferIndex = 0;
   }
}

void Buffer::GetBufferFileName() {
  std::string fileLocation = "data/";
  std::string bufferNameString = bufferName;
  std::stringstream bufferIndexStringStream;
  bufferIndexStringStream << bufferIndex;
  std::string bufferIndexString = bufferIndexStringStream.str();
  std::string fileTypeString = ".mat";
  completeBufferName = bufferNameString+bufferIndexString;
  std::string bufferFileNameString = fileLocation+completeBufferName+fileTypeString;
  bufferFileName = new char[bufferFileNameString.size()+1];
  std::copy(bufferFileNameString.begin(), bufferFileNameString.end(), bufferFileName);
  bufferFileName[bufferFileNameString.size()] = '\0';
  //std::cout<<"Buffer file name is "<<bufferFileName<<std::endl;
}

void Buffer::LoadBuffer() {
  MATFile *matFileHandle;
  matFileHandle = matOpen(bufferFileName, "r");
  int numberOfDirectories;
  const char** directoryField= (const char** )matGetDir(matFileHandle, &numberOfDirectories);
  for(int i=0; i < numberOfDirectories; i++) {
    //std::cout<<directoryField[i]<<std::endl;
    mxArray* matArrayHandle = matGetVariable(matFileHandle, directoryField[i]);
    int numberOfRows = mxGetM(matArrayHandle);
    int numberOfColumns = mxGetN(matArrayHandle);
    double* matArrayAddress = mxGetPr(matArrayHandle);
    for(int j=0;j<numberOfColumns;j++) {
      double matrixEntry = *(matArrayAddress+j);
      bufferData.push_back(matrixEntry);
    }
  }
  maximumBufferLevel = bufferData[0];
  //std::cout<<"Max. buffer level "<<maximumBufferLevel<<std::endl;
  minimumBufferLevel = bufferData[1];
  //std::cout<<"Min. buffer level "<<minimumBufferLevel<<std::endl;
  maximumStateOfBuffer = bufferData[2];
  //std::cout<<"Max. state of buffer "<<maximumStateOfBuffer<<std::endl;
  minimumAllowedStateOfBuffer = bufferData[3];
  //std::cout<<"Min. allowed state of buffer "<<minimumAllowedStateOfBuffer<<std::endl;
  openCircuitVoltage = bufferData[4];
  //std::cout<<"openCircuitVoltage "<<openCircuitVoltage<<std::endl;

  instantaneousBufferLevel=maximumBufferLevel;
  //bufferLevelOverMission.push_back(instantaneousBufferLevel);
  //std::cout<<"Inst. buffer level "<<instantaneousBufferLevel<<std::endl;


  //std::cout<<"Buffer data successfully loaded"<<std::endl;
}

std::string Buffer::ReturnBufferName() {
   return completeBufferName;
}

double Buffer::GetBufferAvailabilityRatio() {
  //std::cout<<"Inside GetBufferAvailabilityRatio()"<<std::endl;
  //std::cout<<"Test print inside GetBufferAvailabilityRatio(): "<<minimumBufferLevel<<std::endl;
  UpdateBufferAvailabilityRatio();
  //std::cout<<"bufferAvailabilityRatio "<<bufferAvailabilityRatio<<std::endl;
  return bufferAvailabilityRatio;
}

void Buffer::UpdateBufferAvailabilityRatio() {
   GetStateOfBuffer();
   bufferAvailabilityRatio = (stateOfBuffer-minimumAllowedStateOfBuffer)/
                                 (maximumStateOfBuffer-minimumAllowedStateOfBuffer);
}

void Buffer::GetStateOfBuffer() {
   stateOfBuffer = instantaneousBufferLevel/maximumBufferLevel;
   //std::cout<<"stateOfBuffer "<<stateOfBuffer<<std::endl;

   /*stateOfBuffer = (instantaneousBufferLevel-minimumBufferLevel)/
                              (maximumBufferLevel-minimumBufferLevel);//*/
}

void Buffer::RunBuffer(double powerDemand, double operatingEfficiency) {
}

Buffer::~Buffer() {
}