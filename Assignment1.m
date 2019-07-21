% Development of a Random Forest and Multiple Linear Regression Models
% MAT8190 Assignment 1 - MATHEMATICS STATISTICS COMPLEMENTARY STUDIES
% Author: John Worrall
% Description: RF modeld  and MLR for prediction 
% Requirments: Excel file (RandomForestDataA1-SD-VERSION.xlsx)
%----------------------------


clear 
clc
close all

% Number of models (Default 5 times)
nModels = 5;

% Choose Options (CO)
% 1 - Random Forest
% 2 - Multiple Linear Regression Model
% 3 - Both
% 4 - Random Forest nModels times
% 5 - MLR nModels tzdimes
CO = 1;



%randomise parameters, ensure the results are reproducible.
%rand('twister', 123);
s = RandStream('mlfg6331_64');

%IO
trnData=xlsread('RandomForestDataA1-SD-VERSION.xlsx','Training');
chkData=xlsread('RandomForestDataA1-SD-VERSION.xlsx','CheckData_testing');

%Prepare Train/Test
trnIn = trnData(:,1:12);
trnOut = trnData(:,13);
chkIn = chkData(:,1:12);
chkOut = chkData(:,13);

% Use GPU if available 
ngpus=gpuDeviceCount;
disp([num2str(ngpus) ' GPUs found'])
if ngpus>0
    lgpu=1;
    disp('GPU found')
    useGPU='yes';
else
    lgpu=0;
    disp('No GPU found')
    useGPU='no';
end
% Find number of cores
ncores=feature('numCores');
disp([num2str(ncores) ' cores found'])
% Find number of cpus
import java.lang.*;
r=Runtime.getRuntime;
ncpus=r.availableProcessors;
disp([num2str(ncpus) ' cpus found'])
if ncpus>1
    useParallel='yes';
else
    useParallel='no';
end
[archstr,maxsize,endian]=computer;
disp(['This is a ' archstr ' computer that can have up to ' num2str(maxsize) ' elements in a matlab array and uses ' endian ' byte ordering.'])

% Set up the size of the parallel pool if necessary
npool=ncores;

% Opening parallel pool
if ncpus>1
    tic
    disp('Opening parallel pool')
    % first check if there is a current pool
    poolobj=gcp('nocreate');
% If there is no pool create one
    if isempty(poolobj)
        command=['parpool(' num2str(npool) ');'];
        disp(command);
        eval(command);
    else
        poolsize=poolobj.NumWorkers;
        disp(['A pool of ' poolsize ' workers already exists.']);
    end
        % Set parallel options
        %paroptions = statset('UseParallel',true);
        %Set parrellel streams to have same seed value for repeated results
        paroptions = statset('UseParallel',true,'Streams', s, 'UseSubStreams',true);
        toc
end

%------------------------------------------------------------
if CO == 1 || CO == 3 
    
    %Random Forest Model variables
    tic % starts the timer.
    leaf=5; % this number could be varied.
    ntrees=800; % this number could be varied.
    fboot=1; % this number could be varied.
    surrogate='on'; % this could be set ‘on’ or ‘off’

    % leaf=1, 3, 5, 10, 20;
    % ntrees=50, 200, 800, 1600;
    % fboot=0, 0.4, 0.8, 1.0;
    % surrogate='on';


    %Trainging Periods ------------------
    %Build Model 
    In = trnIn;
    Out = trnOut;
    b = TreeBagger(ntrees,In,Out,'Method','regression','oobvarimp','on','surrogate',surrogate,'minleaf',leaf,'FBoot',fboot,'Options',paroptions);
    reset(s);
    toc;
    
    TrainY = oobPredict(b);
    yTrain = predict(b,In);

    %Predict with traing ------------------
    y = predict(b, In);
    simulatedTrain = y;
    dataObsTrain = Out;

    mseTrain = oobError(b,'mode','ensemble'); %single MSE for RF
    
    %Assement Train error metrics --------------------------------
    [nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObsTrain,simulatedTrain);
    ErrorsTrain = nnPI;
    asseMetricVis(dataObsTrain,simulatedTrain,nnR,1,'Random Trees - Train Errors');
    
    
    %Predict with testing ------------------
    dataSim = predict(b,chkIn);
    dataObs = chkOut;

    %Assement check error metrics --------------------------------
    [nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObs,dataSim);
    ErrorsTest = nnPI;
    asseMetricVis(dataObs,dataSim,nnR,1,'Random Trees - Test Errors');
    
    %http://kawahara.ca/matlab-treebagger-example/
    %https://www.analyticsvidhya.com/blog/2016/04/complete-tutorial-tree-based-modeling-scratch-in-python/
    %http://www.voidcn.com/article/p-hvlvijfp-xo.html
    
% Multiple Linear Regression Model
elseif CO == 2 || CO == 3 
    In = trnIn;
    Out = trnOut;
    c = regress(Out,In);
    cIn = c';
    
    y2= cIn.*chkIn; %predict(c,chkIn);
    dataSimMLR = sum(y2,2);
    dataObs = chkOut;
    %Assement error metrics --------------------------------
    [nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObs,dataSimMLR);
    ErrorsMLR = nnPI;
    asseMetricVis(dataObs,dataSimMLR,nnR,1,'Multiple Linear Regression');    
    
    %https://stackoverflow.com/questions/25027676/multivariate-linear-regression-in-matlab

elseif CO == 4
    
    %Random Forest Model variables
    tic % starts the timer.
    leaf=5; % this number could be varied.
    ntrees=800; % this number could be varied.
    fboot=1; % this number could be varied.
    surrogate='on'; % this could be set ‘on’ or ‘off’
    
    %Trainging Periods ------------------
    %Build Model 
    In = trnIn;
    Out = trnOut;
    b = TreeBagger(ntrees,In,Out,'Method','regression','oobvarimp','on','surrogate',surrogate,'minleaf',leaf,'FBoot',fboot,'Options',paroptions);
    reset(s);
    toc;

    %Predict with traing ------------------
    y = predict(b, In);
    simulatedTrain = y;
    dataObsTrain = Out;
    mseTrain = oobError(b,'mode','ensemble'); %single MSE for RF

    %Assement Train error metrics --------------------------------
    [nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObsTrain,simulatedTrain);
    ErrorsTest = nnPI;
    asseMetricVis(dataObsTrain,simulatedTrain,nnR,1,'Random Trees - Test Errors');
    
     for x = 1:nModels

        %Predict with testing ------------------
        dataSim = predict(b,chkIn);
        dataObs = chkOut;
        runs(:,x) = dataSim;
        
        %Assement check error metrics --------------------------------
        [nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObs,dataSim);
        ErrorsTest = nnPI;
        asseMetricVis(dataObs,dataSim,nnR,1,'Random Trees - Test Errors');
        runsErrorTestRF(:,x) = nnPI;

     end

        
  
%------------------------------------------------------------
elseif CO == 5   

    In = trnIn;
    Out = trnOut;

  for x = 1:nModels    
    c = regress(Out,In);
    cIn = c';
    y2= cIn.*chkIn; %predict(c,chkIn);
    dataSimMLR = sum(y2,2);
    dataObs = chkOut;
    
    %Assement error metrics --------------------------------
    [nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObs,dataSimMLR);
    runsErrorTestMLR(:,x) = nnPI;
    asseMetricVis(dataObs,dataSimMLR,nnR,1,'Multiple Linear Regression');    
  end
     
end



