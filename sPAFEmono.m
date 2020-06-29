function [m3PD, m3PG_Etot,m3PG_Erel, mE,vfc,vP,vT] = sPAFEmono(sig_0, params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  sparse Periodicity Auditory Feature Extraction %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function extracts the sparse Periodicity Auditory Features
% ------------------- Input ----------------------: 
% sig_0 - single-channel waveform
% params - struct contraining feature extraction parameters (see demo file)
% ------------------- Output ----------------------: 
% m3PD      - 3-dimensional matrix (channels x tested periods x time instances)
%             containing values of the relative periodic energy for each tested 
%             period in each frequency channel
% m3PG_Etot - 3-dimensional matrix (channels x tested periods x time instances)
%             containing values of the total periodic energy 
%             (total energy of 8 synchrogram windows) for those 
%             tested periods, which fulfill the glimpse criteria, all other
%             entries are zero
% m3PG_Erel - 3-dimensional matrix (channels x tested periods x time instances)
%             containing values of the relative periodic energy for those 
%             tested periods, which fulfill the glimpse criteria, all other
%             entries are zero
% mE   - 2-dim matrix (channels x time instances) containing values of
%        signal power in a given time and frequency band (estimated with a 
%        2.5 Hz filter)
% vfc  - vector with center frequencies [Hz] of gammatone channels
% vP   - vector with tested period values [s]
% vT   - vector with time points [s] for which the analysis was done
% ------------------------------------------------------------------- 
% Authors: This script is based on scripts created during several years 
% of research about modeling auditory features, which includs the work 
% of Volker Hohmann, Matthias Dietz, Chen Zhangli, Angela Josupeit,
% Joanna Luberadzka and probably more.
% Restructured and documented by Joanna in 2020. 
% Note: This code uses the external gammatone filterbank implementation by
% T.Herzke/T.Peters
% ------------------------------------------------------------------------

%% ////////////////// 1. AUDITORY PREPROCESSING \\\\\\\\\\\\\\\\\\\\\\\\

%% ---- 1.a) middle ear band pass filtering ------
middle_ear_thr = [500 2000]; % Bandpass freqencies for middle ear transfer
middle_ear_order = 2;        % Only even numbers possible
alpha = 0;                   % Internal noise strength
[b,a] = butter(middle_ear_order,middle_ear_thr(2)/(params.fs/2),'low');
sig_1 = filter(b,a,sig_0);
[b,a] = butter(middle_ear_order,middle_ear_thr(1)/(params.fs/2),'high');
sig_2 = filter(b,a,sig_1);

%% ---- 1.b) gammatone filtering ------
% Define GFB variables
lower_centre_frequency_hz = 200;
upper_centre_frequency_hz = 5000;
resample_factor = floor(params.fs/(2*upper_centre_frequency_hz));
sig_3 = resample(sig_2,1,resample_factor); % downsample signal
params.fs = params.fs / resample_factor; % Accordingly downsample sampling frequency
t = (1:length(sig_3))/params.fs; % time vector
base_frequency_hz = 1000;
filters_per_ERB = 1.0;
% Initialize analyzer
analyzer = Gfb_Analyzer_new(params.fs, lower_centre_frequency_hz ...
    , base_frequency_hz, upper_centre_frequency_hz, filters_per_ERB);
vfc = round(analyzer.center_frequencies_hz);
% Analyze (with filterbank implementation of Tobias Herzke)
[sigs_0, ~] = Gfb_Analyzer_process(analyzer, sig_3.');

% Only the real part of the complex signal is analyzed
sigs_0=real(sigs_0);


%% ---- 1.c) cochlear compression ------
compression_power=0.4;
sigs_1 = sign(sigs_0).*abs(sigs_0).^compression_power;

%% ---- 1.d) Half-wave rectification ------
sigs_2 = max( sigs_1, 0 );

%% ---- 1.e) 770 Hz low pass ------
filter_order=5;
cutofffreq=2000;
% due to the successive application of the filter, the given 2000 Hz
% correspond to a cut off-frequency of 770 Hz after the five iterations
[b, a] = butter(1, cutofffreq*2/params.fs);
sigs_3=sigs_2;
for ii=1:filter_order
    sigs_3 = filter(b,a, sigs_3,[],2);
end

%% ////////////////// 2. PERIODICITY ANALYSIS \\\\\\\\\\\\\\\\\\\\\\\\

%% ---- 2.a) periodicity path: 40Hz highpass ------
% this step is performed to remove demodulated 
% spectrum and a DC component after HWR
cutoff_periodicity=40;
[b, a] = butter(2, cutoff_periodicity/(params.fs/2),'high');
sigs_3a = filter(b,a,sigs_3,[],2);

%% ---- 2.b) extract periodicity using synchrogram method ------

% number of time instances
N_T=round(size(sigs_3a,2)/round(params.Tfo*params.fs));
% number of channels
N_C=size(sigs_3a,1);
% number of tested periods
N_P= length([round(params.fs/params.fomax):round(params.fs/params.fomin)]); % m�gliche Perioden
% allocate matrix for periodicity glimpses with total periodic energy(PG)
m3PG_Etot=zeros(N_C,N_P,N_T);
% allocate matrix for periodicity glimpses with relative periodic energy(PG)
m3PG_Erel=zeros(N_C,N_P,N_T);
% allocate matrix for periodicity degree (PD)
m3PD=zeros(N_C,N_P,N_T);

% for each frequency channel...
for c=1:N_C
display(['periodicity for channel ', num2str(c)])
% pick time signal in that freq. band
sig_ch=sigs_3a(c,:);
% compute normalized synchrogram in that band
[pres_ch,ptot_ch,vvp_ch,vperiods,vP,vT]  = ...
    synchrogram(sig_ch,params.fs,params.fomin,params.fomax,params.nmeanperiods,params.step_ms/1000);

%% ---------- 2.c) glimpsing --------------
% glimpsing thresholds for that channel
T1=params.T1(c,1);
T2=params.T2;
% extract glimpses
[m3PG_Etot(c,:,:),m3PG_Erel(c,:,:), m3PD(c,:,:)]=glimpsing(pres_ch,ptot_ch,T1,T2);
end 


%% ////////////////// 3. SIGNAL POWER  \\\\\\\\\\\\\\\\\\\\\\\\
%% ---- power path 2.5Hz low pass ------
% this step is performed to estimate the 
% power of the signal in each band
cutoff_power=2.5;
[b, a] = butter(3, cutoff_power/(params.fs/2),'low');
sigs_3b = filter(b,a,sigs_3);
timeinst_samples=round(vT*params.fs);
% take power corresponding to time instances 
% in which the periodicity was extracted (vT) 
mE=sigs_3b(:,timeinst_samples);


end
