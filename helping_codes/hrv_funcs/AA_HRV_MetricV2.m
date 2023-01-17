%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [ output ] = AA_HRV_MetricV2( tmpData, ind_sec)
% inputs:       
%           f:          filename of ibi file from PLOC data
%           ind_sec:    2 second values used for defining the segment (indicies) of the ibi
%                       from f to be used for HRV analysis
% outputs:
%           output.SDNN, output.RMSSD, output.aHF, output.nHF
%% Preparation of the IBI 
opt.headerSize =0;
% Calling the load IBI_cyle function to retrive desired IBI segment
ibi=adjust_ibi(tmpData);
% Using indices set by a previous function to focus on a section of the IBI file
if ~isempty(ind_sec)
    ind = find(ibi(:, 1)>= ind_sec(1) & ibi(:, 1)< ind_sec(2));
    ibi = ibi(ind, :);
end

%% Time Domain calculation of metrics (Standard Deviation: SDNN, and Root Mean Square Successive Difference: RMSSD)
output.SDNN=round(std(ibi)*10)/10;
output.RMSSD=round(RMSSD(ibi)*10)/10; %RMSSD Calls the RMSSD function
%% Freq. Domain calculation of metrics (Power of HF: aHF, and Normalized Units of HF: nHF)
% declaration of variables required to call functions
ibi = ibi/1000;
methods = {};
methInput = []; 
settings.ArtReplace = 'None';
replaceWin =0;
settings.Detrend ='None';
 settings.SmoothMethod ='loess';
 settings.SmoothSpan =5;
 settings.SmoothDegree=0.1;
 settings.PolyOrder = 1;
 settings.WaveletType ='db';
 settings.WaveletType2 =3;
 settings.WaveletLevels =6;
 settings.PriorsLambda =10;
 settings.Interp =2;
 % calling the preproccessing function from the original HRVAS program
[dIBI,nIBI,trend,art] = preProcessIBI(ibi, ...
    'locateMethod', methods, 'locateInput', methInput, ...
    'replaceMethod', settings.ArtReplace, ...
    'replaceInput',replaceWin, 'detrendMethod', settings.Detrend, ...
    'smoothMethod', settings.SmoothMethod, ...
    'smoothSpan', settings.SmoothSpan, ...
    'smoothDegree', settings.SmoothDegree, ...
    'polyOrder', settings.PolyOrder, ...
    'waveletType', [settings.WaveletType num2str(settings.WaveletType2)], ...
    'waveletLevels', settings.WaveletLevels, ...
    'lambda', settings.PriorsLambda,...
    'resampleRate',settings.Interp,...
    'meanCorrection',true);
% declaration of frequency and output related variables
VLF = [0, 0.04];
LF = [0.04, 0.15];
HF = [0.15, 0.4] ;
AR_order = 16;
window = 128;
noverlap =64;
nfft = 1024;
fs = 2;
methods = [];
% preparation of output statements and calling of the Frequency function
% from the original HRVAS program
output_freq = ...
    freqDomainHRV(dIBI,VLF,LF,HF,AR_order,window,noverlap,nfft,fs);
% combination of outputs into single output matrix
output.aHF = output_freq.welch.hrv.aHF;
output.nHF = output_freq.welch.hrv.nHF;


end

