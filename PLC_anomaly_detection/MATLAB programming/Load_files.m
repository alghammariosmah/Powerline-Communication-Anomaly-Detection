%% Clear workspace
clear; clc;
%% Location and Filter for Dataset
DATA_PATH = 'data';

DATA_FILE_FILTER = 'Training\w*.mat';  % Training Files
%% Get all file names under the specified folder & subfolders with regex filter	
fileList = getAllFiles(DATA_PATH, DATA_FILE_FILTER);
fprintf(1,'Found %d files matching %s at %s\n', size(fileList,2), DATA_FILE_FILTER, DATA_PATH);
for i = 1:size(fileList,2)
    [~,fname,~] = fileparts(fileList{i});
    fprintf(1,'%d. %s\n', i, fname);
end
%% Load Data File
% Load one of training files, in partuclar the first.
for i = 1: 1
    fname = fileList{i}; 
    clear Buffer;

    fprintf(1, 'Loading file: %s\n', fname);
    load(fname);
    fprintf(1, 'Done loading file.\n');
end

%% Getting High Frequency data 
ProcessedData = ProcessHFRawData(Buffer);

clear Buffer;
%% Plot whole data
% Plot all available data in file. The second argument controls if the
% labels are plotted.
HF_Plot(ProcessedData, true);

%% Plot Data between first ON tagging event and last OFF tagging event + data extrapolation
ProcessedData = Data_Preprocessing(ProcessedData);
figure; 
HF_Plot(ProcessedData,true);

Data_Preprocessing2(ProcessedData);



