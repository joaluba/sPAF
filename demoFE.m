% This is a demo showing how to use the function to extract
% periodicity-based glimpses
addpath(genpath('Gammatone Filterbank/'))
[signal, fs]=audioread('sound_mix.wav');

%% Parameters for feature extraction
common.fs=16000;
% stepsize of data aquisition
common.step_ms=20;
% duration of the signal in ms
common.dur=2000;
% sampling frequency of particle filter
common.fs_pf=50;%Hz
% length of the state trajectory
common.N=length(0:common.step_ms:common.dur);
FE=common;
FE.fs_new = FE.fs_pf;
FE.tau_E = 0.01;
FE.T1 =0.6*[0.9713 0.9611 0.9612 0.9753 0.9765 0.9545 0.9600 0.9137 0.8875 0.8700 0.8767 0.8633 0.6833 0.6825 0.5867 ...
    0.4550 0.3600 0.4000 0.4000 0.3967 0.4225 0.4129 0.3800]';
FE.T2=0.9;
FE.fomin = 80;
FE.fomax = 700;
FE.nmeanperiods = 8;
FE.Tfo = 1/FE.fs_new;
FE.rel=0;
FE.peakfinder=0;


[matfeat, vfc, vP, vT] = sPAFEmono(signal(:,1),FE);
feat= matfeat2cellfeat(matfeat,vP,vT,vfc);


%% Plots

% plot extracted features - whole signal (using features represented as matrix)
figure;implot_3dscatter(matfeat.m3PG_Etot,vfc,vP,vT);suptitle('Total periodic energy glimpses [dB]')

% plot extracted features - whole signal (using features represented as cell)
figure;implot_3dscatter(feat.o,vfc,vP,vT);suptitle('Total periodic energy glimpses [dB]')

% plot extracted features - one time instance
figure;implot_timeinst(matfeat.m3PG_Etot,34,vfc,vP);suptitle('Total periodic energy glimpses [dB]')
% plot extracted features - one channel
figure;implot_channel(matfeat.m3PG_Etot,11,vT,vP);suptitle('Total periodic energy glimpses [dB]')

