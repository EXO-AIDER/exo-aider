%% Returns the initial preallocated DataBuffer - 15 minuts of storage
% and a table containing the variable names of the different columns.
function [returnMatrix, returnColumnName] = getMatrix(Task)

Row = 15*60*1000; % Each row corrosponds to 1 ms 

%% IMU
if strcmp(Task.Properties.VariableNames,'IMU')
    NameOfVariables = {'AccX1', 'AccY1', 'AccZ1', 'GyroX1', 'GyroY1', 'GyroZ1', 'AccX2', 'AccY2', 'AccZ2', 'GyroX2', 'GyroY2', 'GyroZ2'};
    Column = length(NameOfVariables);
end
%% FSR
if strcmp(Task.Properties.VariableNames,'FSR')
    NameOfVariables = {'FSR1', 'FSR3', 'FSR4', 'FSR2', 'FSR5', 'FSR7', 'FSR8', 'FSR6'};
    Column = length(NameOfVariables);
end
%% EMG
if strcmp(Task.Properties.VariableNames,'EMG')
    NameOfVariables = {'EMG1', 'EMG2', 'EMG3', 'EMG4'};
    Column = length(NameOfVariables);
end
%% All
if strcmp(Task.Properties.VariableNames,'All')
    NameOfVariables = {'FSR1', 'FSR3', 'FSR4', 'FSR2', 'FSR5', 'FSR7', 'FSR8', 'FSR6',...
                       'EMG1', 'EMG2', 'EMG3', 'EMG4',...
                       'AccX1', 'AccY1', 'AccZ1', 'GyroX1', 'GyroY1', 'GyroZ1', 'AccX2', 'AccY2', 'AccZ2', 'GyroX2', 'GyroY2', 'GyroZ2'};
    Column = length(NameOfVariables);
end

%% Return table 
SizeOfData = [Row Column];
returnMatrix = zeros(SizeOfData);
returnColumnName = getTable(Task,1:Column)
