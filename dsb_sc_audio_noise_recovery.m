%ECE-550 Project 

% MESSAGE + NOISE + NOISY DSB-SC

clear; clc; close all;

%% =====================================================
% STEP 1 — LOAD MESSAGE AUDIO
%% =====================================================

[fileM, pathM] = uigetfile('*.m4a','Select MESSAGE audio');
[m, Fs] = audioread(fullfile(pathM,fileM));

% Force column vector (prevents 14400x14400 error)
m = m(:);

% Stereo → mono
if size(m,2) > 1
    m = mean(m,2);
end

% Use first 3 seconds only (keeps memory small)
Tsec = 3;
m = m(1:min(length(m), round(Tsec*Fs)));

% Remove DC and normalize
m = m - mean(m);
m = m / max(abs(m));

t = (0:length(m)-1)'/Fs;   % column vector
N = length(m);

%% =====================================================
% MESSAGE PLOTS 
%% =====================================================

% 1 — Message Time
figure('Name','1 - Message Time');
plot(t,m); grid on;
title('Message m(t) - Time');
xlabel('Time (s)'); ylabel('Amplitude');

% FFT
M = fftshift(fft(m));
f = (-N/2:N/2-1)'*(Fs/N);

% 2 — Message Magnitude
figure('Name','2 - Message Magnitude');
plot(f, abs(M)/N); grid on;
title('Message |M(f)|');
xlabel('Frequency (Hz)');
xlim([-8000 8000]);

% 3 — Message Phase
threshold = 0.01*max(abs(M));
phaseM = angle(M);
phaseM(abs(M)<threshold) = NaN;

figure('Name','3 - Message Phase');
plot(f, phaseM); grid on;
title('Message Phase');
xlabel('Frequency (Hz)');
xlim([-8000 8000]);

%% =====================================================
% STEP 2 — DSB-SC MODULATION
%% =====================================================

fc = 10000; % 10 kHz

carrier = cos(2*pi*fc*t);  % column vector
s = m .* carrier;          % SAFE multiplication

% 1 — Message Time
figure('Name','1 - DSB-SC Message Time');
plot(t,s); grid on;
title('DSB-SC Message s(t) - Time');
xlabel('Time (s)'); ylabel('Amplitude');

% FFT
S = fftshift(fft(s));
f = (-N/2:N/2-1)'*(Fs/N);

% 2 — Message Magnitude
figure('Name','2 - DSB-SC Message Magnitude');
plot(f, abs(S)/N); grid on;
title('DSB-SC Message |S(f)|');
xlabel('Frequency (Hz)');
xlim([-8000 8000]);

% 3 — Message Phase
threshold = 0.01*max(abs(S));
phaseM = angle(S);
phaseM(abs(S)<threshold) = NaN;

figure('Name','3 - DSB-SC Message Phase');
plot(f, phaseM); grid on;
title('DSB-SC Message Phase');
xlabel('Frequency (Hz)');
xlim([-8000 8000]);

%% =====================================================
% STEP 3 — LOAD NOISE AUDIO
%% =====================================================

[fileN, pathN] = uigetfile('*.m4a','Select NOISE audio');
[n0, FsN] = audioread(fullfile(pathN,fileN));

n0 = n0(:);

if size(n0,2)>1
    n0 = mean(n0,2);
end

% Resample if needed
if FsN ~= Fs
    n0 = resample(n0, Fs, FsN);
end

% Trim to same length as message
L = min(length(m), length(n0));
m = m(1:L);
s = s(1:L);
n = n0(1:L);

t = t(1:L);
N = L;

% Normalize noise
n = n - mean(n);
n = n / max(abs(n));

%% =====================================================
% NOISE PLOTS 
%% =====================================================

% 4 — Noise Time
figure('Name','4 - Noise Time');
plot(t,n); grid on;
title('Noise n(t) - Time');
xlabel('Time (s)');

Nn = length(n);
NfftN = fftshift(fft(n));
fN = (-Nn/2:Nn/2-1)'*(Fs/Nn);

% 5 — Noise Magnitude
figure('Name','5 - Noise Magnitude');
plot(fN, abs(NfftN)/Nn); grid on;
title('Noise |N(f)|');
xlabel('Frequency (Hz)');
xlim([-8000 8000]);

% 6 — Noise Phase
thresholdN = 0.01*max(abs(NfftN));
phaseN = angle(NfftN);
phaseN(abs(NfftN)<thresholdN)=NaN;

figure('Name','6 - Noise Phase');
plot(fN, phaseN); grid on;
title('Noise Phase');
xlabel('Frequency (Hz)');
xlim([-8000 8000]);

%% =====================================================
% STEP 4 — ADD NOISE TO DSB-SC
%% =====================================================

alpha = 0.4;     % noise strength
x = s + alpha*n;
x = x / max(abs(x));



%% =====================================================
% NOISY DSB-SC PLOTS 
%% =====================================================

% 7 — Noisy AM Time
figure('Name','7 - Noisy DSB-SC Time');
plot(t(1:3000), x(1:3000)); grid on;
title('Noisy DSB-SC x(t)');
xlabel('Time (s)');

% FFT
X = fftshift(fft(x));
fX = (-N/2:N/2-1)'*(Fs/N);

% 8 — Noisy AM Magnitude
figure('Name','8 - Noisy DSB-SC Magnitude');
plot(fX, abs(X)/N); grid on;
title('Noisy DSB-SC |X(f)|');
xlabel('Frequency (Hz)');
xlim([-Fs/2 Fs/2]);

% 9 — Noisy AM Phase
thresholdX = 0.01*max(abs(X));
phaseX = angle(X);
phaseX(abs(X)<thresholdX)=NaN;

figure('Name','9 - Noisy DSB-SC Phase');
plot(fX, phaseX); grid on;
title('Noisy DSB-SC Phase');
xlabel('Frequency (Hz)');
xlim([-Fs/2 Fs/2]);

disp('DONE. You should now see 9 figures.');

%% =========================
% SAVE AUDIO FILES (FIXED)
%% =========================

% 1) Clean message (baseband)
m_save = m ./ (max(abs(m)) + 1e-12);

% 2) Noise only
n_save = n ./ (max(abs(n)) + 1e-12);

% 3) Noisy message in BASEBAND (this is what you want to hear)
m_noisy = m + alpha*n;
m_noisy_save = m_noisy ./ (max(abs(m_noisy)) + 1e-12);

% Save WAV files
audiowrite('clean_message.wav', m_save, Fs);
audiowrite('noise_only.wav', n_save, Fs);
audiowrite('noisy_message.wav', m_noisy_save, Fs);

disp('Audio files saved successfully: clean_message.wav, noise_only.wav, noisy_message.wav');


%% =====================================================
% STEP 5 — PSD ESTIMATION (Welch)
%% =====================================================

% Welch settings (tweak if you want)
winLen   = 2048;                 % window length (samples)
win      = hamming(winLen);      % window
noverlap = round(0.5*winLen);    % 50% overlap
nfft     = 4096;                 % FFT points for PSD

% PSD of message m(t)
[Pm, fP] = pwelch(m, win, noverlap, nfft, Fs, 'centered');

figure('Name','10 - PSD Message (Welch)');
plot(fP, 10*log10(Pm)); grid on;
title('PSD of Message m(t) using Welch');
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
xlim([-8000 8000]);

% PSD of noise n(t)
[Pn, fP2] = pwelch(n, win, noverlap, nfft, Fs, 'centered');

figure('Name','11 - PSD Noise (Welch)');
plot(fP2, 10*log10(Pn)); grid on;
title('PSD of Noise n(t) using Welch');
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
xlim([-8000 8000]);

% PSD of noisy DSB-SC x(t)
[Px, fP3] = pwelch(x, win, noverlap, nfft, Fs, 'centered');

figure('Name','12 - PSD Noisy DSB-SC (Welch)');
plot(fP3, 10*log10(Px)); grid on;
title('PSD of Noisy DSB-SC x(t) using Welch');
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
xlim([-Fs/2 Fs/2]);

%% =====================================================
% STEP 6 — BANDPASS FILTER AROUND CARRIER (filters noise)
%% =====================================================

% 1) Estimate message bandwidth B from |M(f)|
Mmag = abs(M)/N;                 
Mmag = Mmag / max(Mmag);

thr = 0.05;                      % 5% threshold (tweak 0.02 to 0.1)
idx = find(Mmag > thr);
B = max(abs(f(idx)));            % bandwidth in Hz (baseband)

% Safety margin so we don't cut message
B = 1.2*B;

% 2) Design FIR bandpass around fc ± B
f1 = max(10, fc - B);            % lower edge (Hz)
f2 = min(Fs/2 - 10, fc + B);     % upper edge (Hz)

bpOrder = 300;                   % 200-500 is fine
bBP = fir1(bpOrder, [f1 f2]/(Fs/2), 'bandpass', hamming(bpOrder+1));

% 3) Filter the noisy DSB-SC
x_bp = filtfilt(bBP, 1, x);      % zero-phase, avoids delay

% Plot to verify
Xbp = fftshift(fft(x_bp));
figure('Name','13 - Bandpass Filtered |Xbp(f)|');
plot(fX, abs(Xbp)/N); grid on;
title('Bandpass Filtered DSB-SC |X_{bp}(f)|');
xlabel('Frequency (Hz)'); xlim([-Fs/2 Fs/2]);

disp(['Estimated B = ' num2str(B,'%.1f') ' Hz   Bandpass: [' num2str(f1,'%.1f') ', ' num2str(f2,'%.1f') '] Hz']);

%% =====================================================
% STEP 6 — FREQUENCY-DOMAIN MASK (ones/zeros)
%% =====================================================

% Estimate B same way
Mmag = abs(M)/N;
Mmag = Mmag / max(Mmag);
thr = 0.05;
idx = find(Mmag > thr);
B = 1.2*max(abs(f(idx)));

% Build mask H(f): 1 in [fc-B, fc+B] and [-fc-B, -fc+B], else 0
H = zeros(N,1);

pass1 = (abs(fX - fc) <= B);
pass2 = (abs(fX + fc) <= B);
H(pass1 | pass2) = 1;

% Apply in frequency domain
Xfilt = X .* H;
x_fd = real(ifft(ifftshift(Xfilt)));

% Plot
figure('Name','13 - Mask H(f)');
plot(fX, H); grid on;
title('Frequency-Domain Mask H(f)');
xlabel('Frequency (Hz)'); ylabel('Gain');
xlim([-Fs/2 Fs/2]);

figure('Name','14 - Filtered |Xfilt(f)|');
plot(fX, abs(Xfilt)/N); grid on;
title('Filtered Spectrum |X_{filt}(f)|');
xlabel('Frequency (Hz)'); xlim([-Fs/2 Fs/2]);

%% =====================================================
% STEP 7 — RECOVERY (coherent demod + LPF) + LISTEN + SAVE
%% =====================================================

% Use the filtered DSB-SC signal:
x_filt = x_bp;      % (if you used FIR bandpass)
% x_filt = x_fd;    % (if you used frequency mask instead)

% 1) Coherent demodulation
z = 2 * x_filt .* cos(2*pi*fc*t);

% 2) Lowpass filter (cutoff = message bandwidth)
% If you already computed B in the filter step, reuse it.
% If not, set something safe like 4000 Hz.
if ~exist('B','var')
    B = 4000;   % fallback cutoff in Hz
end

lpCut = min(B, Fs/2 - 50);
lpOrder = 300;
bLP = fir1(lpOrder, lpCut/(Fs/2), 'low', hamming(lpOrder+1));

m_rec = filtfilt(bLP, 1, z);     % zero-phase LPF

% 3) Normalize recovered audio
m_rec = m_rec - mean(m_rec);
m_rec = m_rec / (max(abs(m_rec)) + 1e-12);

% Optional: trim a tiny transient at start
trimS = round(0.05*Fs);          % 50 ms
m_rec_play = m_rec(trimS+1:end);

% 4) Listen
disp('Playing recovered audio...');
sound(m_rec_play, Fs);

% 4) Save
audiowrite('recovered_message.wav', m_rec, Fs);
disp('Saved: recovered_message.wav');


figure('Name','1 - Recovered Message Time');
plot(t,m_rec); grid on;
title('Message m(t) - Time');
xlabel('Time (s)'); ylabel('Amplitude');

%% =====================================================
% STEP 8 — SNR & MSE
%% =====================================================

% Make sure lengths match
Lmin = min(length(m), length(m_rec));
m_ref = m(1:Lmin);
m_est = m_rec(1:Lmin);

% Compute noise (error)
err = m_ref - m_est;

% SNR
SNR_rec = 10*log10( sum(m_ref.^2) / sum(err.^2) );

% MSE
MSE_rec = mean(err.^2);

disp(['Recovered SNR = ' num2str(SNR_rec,'%.2f') ' dB']);
disp(['Recovered MSE = ' num2str(MSE_rec,'%.6f')]);

%% =====================================================
% STEP 9 — PSD COMPARISON (Welch)
%% =====================================================

winLen = 2048;
win = hamming(winLen);
noverlap = round(0.5*winLen);
nfft = 4096;

[P_orig, f_psd] = pwelch(m_ref, win, noverlap, nfft, Fs, 'centered');
[P_rec, ~]      = pwelch(m_est, win, noverlap, nfft, Fs, 'centered');

figure('Name','PSD Comparison: Original vs Recovered');
plot(f_psd, 10*log10(P_orig), 'b','LineWidth',1.5); hold on;
plot(f_psd, 10*log10(P_rec), 'r','LineWidth',1.5);
grid on;
legend('Original','Recovered');
title('PSD Comparison (Welch Method)');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
xlim([-8000 8000]);

