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


[m3PD,m3PG_Etot,m3PG_Erel,mE,vfc,vP, vT] = sPAFEmono(signal(:,1),FE);


%% Plots

% plot for one time frame t
t=31;
figure;implot_timeinst(m3PD,t,vfc,vP);suptitle('Normalized periodic energy [0,1]')
figure;implot_timeinst(m3PG_Etot,t,vfc,vP);suptitle('Total periodic energy glimpses [dB]')
figure;implot_timeinst(m3PG_Erel,t,vfc,vP);suptitle('Normalized periodic energy glimpses [0,1]')

% plot for one channel c
c=10
figure;implot_channel(m3PD,c,vT,vP);suptitle('Normalized periodic energy [0,1]')
figure;implot_channel(m3PG_Etot,c,vT,vP);suptitle('Total periodic energy glimpses [dB]')
figure;implot_channel(m3PG_Erel,c,vT,vP);suptitle('Normalized periodic energy glimpses [0,1]')






