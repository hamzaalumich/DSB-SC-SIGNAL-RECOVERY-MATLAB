%ECE-550 Project
% MESSAGE + (AWGN + Narrowband Interference) + NOISY DSB-SC + BETTER FILTER + RECOVERY
% Interference is placed FAR from the carrier band (easy to filter)
% You will hear + save: noise_only, noisy_message_baseband, recovered_message

clear; clc; close all;

%% =====================================================
% STEP 1 — LOAD MESSAGE AUDIO  m(t)
%% =====================================================

[fileM, pathM] = uigetfile('*.m4a','Select MESSAGE audio');
[m, Fs] = audioread(fullfile(pathM,fileM));

if size(m,2) > 1
    m = mean(m,2);
end
m = m(:);

Tsec = 3;
m = m(1:min(length(m), round(Tsec*Fs)));

m = m - mean(m);
m = m / (max(abs(m)) + 1e-12);

t = (0:length(m)-1)'/Fs;
N = length(m);

%% =====================================================
% STEP 2 — MESSAGE FFT PLOTS
%% =====================================================

figure('Name','1 - Message Time');
plot(t,m); grid on;
title('Message m(t) - Time');
xlabel('Time (s)'); ylabel('Amplitude');

M = fftshift(fft(m));
f = (-N/2:N/2-1)'*(Fs/N);

figure('Name','2 - Message Magnitude');
plot(f, abs(M)/N); grid on;
title('Message |M(f)|');
xlabel('Frequency (Hz)'); xlim([-8000 8000]);

threshold = 0.01*max(abs(M));
phaseM = angle(M);
phaseM(abs(M)<threshold) = NaN;

figure('Name','3 - Message Phase');
plot(f, phaseM); grid on;
title('Message Phase');
xlabel('Frequency (Hz)'); xlim([-8000 8000]);

%% =====================================================
% STEP 3 — DSB-SC MODULATION
%% =====================================================

fc = 10000;
carrier = cos(2*pi*fc*t);
s = m .* carrier;

%% =====================================================
% STEP 4 — ADD NOISE + INTERFERENCE
%% =====================================================

nyq = Fs/2;

% Put tones VERY high (close to Nyquist), but keep a little margin
f1 = nyq - 3500;    % very high
f2 = nyq - 1500;    % even higher

% If Fs is too low, ensure tones are still > fc + B region
minHigh = fc + 6000;
if f1 < minHigh, f1 = min(nyq-2500, minHigh); end
if f2 < minHigh+1000, f2 = min(nyq-1500, minHigh+2000); end

A = 0.30;
Bint = 0.30;

interf = Bint*cos(2*pi*f1*t) + A*cos(2*pi*f2*t);

SNRdB_awgn = 12;  % gaussian noise strength (higher = less noise)

% baseband (for listening)
s1 = m + interf;
s2 = add_awgn_measured(s1, SNRdB_awgn);

% passband noisy DSB-SC (this is what you recover from)
x = s + interf;
x = add_awgn_measured(x, SNRdB_awgn);
x = x / (max(abs(x)) + 1e-12);

noise_only = s2 - m;
noise_only = noise_only / (max(abs(noise_only)) + 1e-12);

disp(['Fs=' num2str(Fs) ' Hz, Nyquist=' num2str(nyq) ' Hz']);
disp(['Interference tones: f1=' num2str(f1) ' Hz, f2=' num2str(f2) ' Hz (VERY HIGH, easy to filter)']);

%% =====================================================
% STEP 5 — QUICK PLOTS (time + spectra)
%% =====================================================

figure('Name','4 - Baseband Noisy (s2) Time');
plot(t(1:min(3000,N)), s2(1:min(3000,N))); grid on;
title('Baseband Noisy s2(t) = m(t) + tones + AWGN');
xlabel('Time (s)'); ylabel('Amplitude');

NO = fftshift(fft(noise_only));
figure('Name','5 - Noise Only Magnitude');
plot(f, abs(NO)/N); grid on;
title('Noise Only |N_{only}(f)|');
xlabel('Frequency (Hz)'); xlim([-Fs/2 Fs/2]);

figure('Name','6 - Noisy DSB-SC Time');
plot(t(1:min(3000,N)), x(1:min(3000,N))); grid on;
title('Noisy DSB-SC x(t)');
xlabel('Time (s)'); ylabel('Amplitude');

X = fftshift(fft(x));
fX = (-N/2:N/2-1)'*(Fs/N);

figure('Name','7 - Noisy DSB-SC Magnitude');
plot(fX, abs(X)/N); grid on;
title('Noisy DSB-SC |X(f)|');
xlabel('Frequency (Hz)'); xlim([-Fs/2 Fs/2]);

%% =====================================================
% STEP 6 — PSD ESTIMATION (Welch)
%% =====================================================

winLen   = 2048;
win      = hamming(winLen);
noverlap = round(0.5*winLen);
nfft     = 4096;

[Pm, fP] = pwelch(m, win, noverlap, nfft, Fs, 'centered');
figure('Name','8 - PSD Message (Welch)');
plot(fP, 10*log10(Pm)); grid on;
title('PSD of Message m(t) (Welch)');
xlabel('Frequency (Hz)'); ylabel('dB/Hz'); xlim([-8000 8000]);

[Pno, fPno] = pwelch(noise_only, win, noverlap, nfft, Fs, 'centered');
figure('Name','9 - PSD Noise Only (Welch)');
plot(fPno, 10*log10(Pno)); grid on;
title('PSD of Noise Only (tones + AWGN)');
xlabel('Frequency (Hz)'); ylabel('dB/Hz'); xlim([-Fs/2 Fs/2]);

[Px, fPx] = pwelch(x, win, noverlap, nfft, Fs, 'centered');
figure('Name','10 - PSD Noisy DSB-SC (Welch)');
plot(fPx, 10*log10(Px)); grid on;
title('PSD of Noisy DSB-SC x(t) (Welch)');
xlabel('Frequency (Hz)'); ylabel('dB/Hz'); xlim([-Fs/2 Fs/2]);

%% =====================================================
% STEP 7 — BETTER BANDPASS FILTER AROUND CARRIER
%% =====================================================

Mmag = abs(M)/N;
Mmag = Mmag / (max(Mmag) + 1e-12);

thr = 0.05;
idx = find(Mmag > thr);
if isempty(idx)
    B = 4000;
else
    B = max(abs(f(idx)));
end

B = 1.05*B;

f1bp = max(10, fc - B);
f2bp = min(Fs/2 - 10, fc + B);

bpOrder = 900;
bBP = fir1(bpOrder, [f1bp f2bp]/(Fs/2), 'bandpass', kaiser(bpOrder+1, 9));

x_bp = filtfilt(bBP, 1, x);

Xbp = fftshift(fft(x_bp));
figure('Name','11 - Bandpass Filtered |Xbp(f)|');
plot(fX, abs(Xbp)/N); grid on;
title('Bandpass Filtered DSB-SC |X_{bp}(f)|');
xlabel('Frequency (Hz)'); xlim([-Fs/2 Fs/2]);

disp(['Estimated B = ' num2str(B,'%.1f') ' Hz   Bandpass: [' num2str(f1bp,'%.1f') ', ' num2str(f2bp,'%.1f') '] Hz']);

%% =====================================================
% STEP 8 — RECOVERY (coherent demod + LPF) + HEAR + SAVE
%% =====================================================

z = 2 * x_bp .* cos(2*pi*fc*t);

lpCut = min(1.05*B, Fs/2 - 50);
lpOrder = 900;
bLP = fir1(lpOrder, lpCut/(Fs/2), 'low', kaiser(lpOrder+1, 9));

m_rec = filtfilt(bLP, 1, z);

m_rec = m_rec - mean(m_rec);
m_rec = m_rec / (max(abs(m_rec)) + 1e-12);

figure('Name','12 - Recovered Message Time');
plot(t, m_rec); grid on;
title('Recovered Message m_{rec}(t)');
xlabel('Time (s)'); ylabel('Amplitude');

% Save audio
m_save = m / (max(abs(m)) + 1e-12);
m_noisy_baseband = s2 / (max(abs(s2)) + 1e-12);

audiowrite('clean_message.wav', m_save, Fs);
audiowrite('noise_only.wav', noise_only, Fs);
audiowrite('noisy_message_baseband.wav', m_noisy_baseband, Fs);
audiowrite('recovered_message.wav', m_rec, Fs);

disp('Saved: clean_message.wav, noise_only.wav, noisy_message_baseband.wav, recovered_message.wav');

% Listen
disp('Playing: noise only...');
sound(noise_only, Fs); pause(length(noise_only)/Fs + 0.5);

disp('Playing: noisy message (baseband) ...');
sound(m_noisy_baseband, Fs); pause(length(m_noisy_baseband)/Fs + 0.5);

disp('Playing: recovered message...');
sound(m_rec, Fs);

%% =====================================================
% STEP 9 — SNR & MSE
%% =====================================================

Lmin = min(length(m), length(m_rec));
m_ref = m(1:Lmin);
m_est = m_rec(1:Lmin);

err = m_ref - m_est;

SNR_rec = 10*log10( sum(m_ref.^2) / (sum(err.^2) + 1e-12) );
MSE_rec = mean(err.^2);

disp(['Recovered SNR = ' num2str(SNR_rec,'%.2f') ' dB']);
disp(['Recovered MSE = ' num2str(MSE_rec,'%.6f')]);

%% =====================================================
% STEP 10 — PSD COMPARISON (Original vs Recovered)
%% =====================================================

[P_orig, f_psd] = pwelch(m_ref, win, noverlap, nfft, Fs, 'centered');
[P_rec, ~]      = pwelch(m_est, win, noverlap, nfft, Fs, 'centered');

figure('Name','13 - PSD Comparison: Original vs Recovered');
plot(f_psd, 10*log10(P_orig), 'b','LineWidth',1.5); hold on;
plot(f_psd, 10*log10(P_rec),  'r','LineWidth',1.5);
grid on;
legend('Original','Recovered');
title('PSD Comparison (Welch)');
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
xlim([-8000 8000]);

disp('DONE.');

%% =====================================================
% Local helper: AWGN with fallback if awgn() not available
%% =====================================================
function y = add_awgn_measured(x, SNRdB)
    try
        y = awgn(x, SNRdB, 'measured');
    catch
        Px = mean(x.^2);
        Pn = Px / (10^(SNRdB/10));
        n = sqrt(Pn) * randn(size(x));
        y = x + n;
    end
end