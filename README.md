# DSB-SC Signal Recovery with Spectral Filtering in MATLAB

A MATLAB implementation of a complete Double-Sideband Suppressed-Carrier communication system using real audio, channel-noise modeling, FFT analysis, Welch power spectral density estimation, digital filtering, coherent demodulation, and quantitative signal-recovery evaluation.

---

## Overview

This project investigates the transmission and recovery of an amplitude-modulated audio signal under multiple channel-noise conditions.

A real audio recording is used as the baseband message. The signal is preprocessed, modulated using DSB-SC modulation with a 10 kHz carrier, corrupted by noise and interference, analyzed in the time and frequency domains, filtered, coherently demodulated, and reconstructed.

Two channel conditions are evaluated:

1. Recorded audio noise
2. Additive White Gaussian Noise combined with narrowband interference

Recovery performance is evaluated using:

- Signal-to-Noise Ratio
- Mean Squared Error
- Fast Fourier Transform analysis
- Welch Power Spectral Density estimation
- Time-domain waveform comparison
- Original-versus-recovered PSD comparison
- Recovered audio playback

---

## Key Results

| Experiment | Channel Condition | Recovered SNR | Recovered MSE |
|---|---|---:|---:|
| Experiment 1 | Recorded audio noise | 16.23 dB | 0.000249 |
| Experiment 2 | AWGN and narrowband interference | 6.79 dB | 0.001967 |

The recorded-noise experiment produced stronger recovery because a significant portion of the unwanted spectral energy could be reduced through filtering.

The AWGN experiment was more challenging because broadband noise overlapped the useful message spectrum. Conventional filtering can reduce out-of-band noise and isolated interference, but it cannot completely remove in-band noise without also affecting the desired signal.

---

## Technical Highlights

This project demonstrates:

- Audio-signal preprocessing
- Stereo-to-mono conversion
- DC-offset removal
- Signal normalization
- DSB-SC amplitude modulation
- Carrier-based frequency translation
- FFT magnitude and phase analysis
- Welch PSD estimation
- Recorded-noise channel modeling
- AWGN generation
- Narrowband interference modeling
- Automatic message-bandwidth estimation
- FIR bandpass-filter design
- Frequency-domain spectral masking
- Zero-phase digital filtering
- Coherent demodulation
- FIR low-pass filtering
- Audio reconstruction and playback
- Performance validation using SNR and MSE

---

## Signal-Processing Workflow

```text
Input Audio
    │
    ▼
Stereo-to-Mono Conversion
    │
    ▼
DC Removal and Normalization
    │
    ▼
DSB-SC Modulation
    │
    ▼
Noise and Interference Addition
    │
    ▼
FFT and Welch PSD Analysis
    │
    ▼
Baseband Bandwidth Estimation
    │
    ▼
Bandpass Filtering / Spectral Masking
    │
    ▼
Coherent Demodulation
    │
    ▼
Low-Pass Filtering
    │
    ▼
Recovered Baseband Audio
    │
    ▼
SNR, MSE, Waveform, and PSD Evaluation
```

---

## System Model

### Baseband Message

The baseband message is represented by:

$$
m(t)
$$

The input audio is converted to mono, limited to a short processing interval, centered by removing its DC component, and normalized before modulation.

### DSB-SC Modulation

The transmitted signal is defined as:

$$
s(t)=m(t)\cos(2\pi f_c t)
$$

where:

- $m(t)$ is the normalized baseband message
- $f_c$ is the carrier frequency
- $s(t)$ is the DSB-SC modulated signal

The carrier frequency used in this project is:

$$
f_c=10\text{ kHz}
$$

In the frequency domain, modulation shifts the baseband spectrum to two symmetric sidebands centered around $+f_c$ and $-f_c$.

The resulting spectrum can be represented as:

$$
S(f)=\frac{1}{2}\left[M(f-f_c)+M(f+f_c)\right]
$$

---

## Channel Models

### Recorded Audio-Noise Channel

The first experiment uses a recorded audio signal as the channel-noise source.

The corrupted signal is modeled as:

$$
x(t)=s(t)+\alpha n(t)
$$

where:

- $s(t)$ is the transmitted DSB-SC signal
- $n(t)$ is the normalized recorded noise
- $\alpha$ controls the noise amplitude
- $x(t)$ is the received noisy signal

The message and noise recordings are:

- Converted to mono
- Resampled when required
- Trimmed to equal lengths
- DC-corrected
- Independently normalized

This experiment represents a nonuniform noise source whose energy is concentrated in particular frequency regions.

### AWGN and Narrowband-Interference Channel

The second experiment uses:

- Additive White Gaussian Noise
- Narrowband sinusoidal interference

AWGN introduces a broadband spectral floor across the frequency range, while narrowband interferers appear as concentrated peaks in the spectrum.

This produces a more difficult signal-recovery problem because part of the unwanted energy overlaps the desired DSB-SC sidebands.

---

## Audio Preprocessing

Before modulation, the input audio is processed using the following sequence:

1. Load the selected audio file
2. Convert stereo audio to mono
3. Limit the processed duration to approximately three seconds
4. Remove the DC component
5. Normalize the signal amplitude
6. Generate the corresponding time vector
7. Compute the centered FFT
8. Estimate the effective baseband bandwidth

The preprocessing stage ensures consistent amplitude scaling and prepares the signal for modulation, filtering, and quantitative comparison.

---

## Time- and Frequency-Domain Analysis

The Fast Fourier Transform is used to analyze:

- The original baseband message
- The noise signal
- The DSB-SC modulated signal
- The noisy received signal
- The filtered signal
- The recovered message

The implementation uses:

```matlab
fft
fftshift
ifft
ifftshift
```

Magnitude and phase plots are generated to identify:

- Baseband signal bandwidth
- Carrier-centered sidebands
- Broadband noise
- Narrowband interference
- Filter passbands
- Spectral changes after recovery

---

## Welch Power Spectral Density Estimation

Welch's method is used to obtain a smoother and more statistically stable estimate of signal-power distribution.

The PSD calculation uses:

- Hamming windows
- Overlapping signal segments
- Centered frequency representation
- Logarithmic power display in dB/Hz

The MATLAB implementation uses:

```matlab
pwelch
hamming
```

PSD estimates are generated for:

- The original message
- The noise signal
- The noisy DSB-SC signal
- The recovered message
- Original-versus-recovered comparison

Welch PSD analysis provides a clearer representation of signal energy and noise-floor behavior than a single FFT magnitude plot.

---

## Message-Bandwidth Estimation

The effective message bandwidth is estimated from the normalized FFT magnitude of the original audio signal.

The implementation:

1. Normalizes the FFT magnitude
2. Applies an amplitude threshold
3. Identifies significant spectral components
4. Determines the highest significant baseband frequency
5. Adds a safety margin to reduce signal truncation

The estimated bandwidth is used to determine:

- Bandpass-filter limits
- Frequency-domain mask width
- Low-pass-filter cutoff frequency

---

## Filtering Methods

Two filtering approaches are implemented.

### FIR Bandpass Filtering

A finite impulse response bandpass filter is designed around the carrier frequency:

$$
f_c-B\leq f\leq f_c+B
$$

where:

- $f_c$ is the carrier frequency
- $B$ is the estimated baseband bandwidth

The implementation uses:

```matlab
fir1
hamming
filtfilt
```

The use of `filtfilt` performs forward and reverse filtering, resulting in zero-phase distortion and no net group delay.

The FIR bandpass output is used as the default input to the coherent-demodulation stage.

### Frequency-Domain Spectral Masking

A binary frequency-domain mask is also implemented to preserve the desired sideband regions around both carrier frequencies:

$$
H(f)=
\begin{cases}
1, & |f-f_c|\leq B \\
1, & |f+f_c|\leq B \\
0, & \text{otherwise}
\end{cases}
$$

The filtered spectrum is calculated using:

$$
Y(f)=X(f)H(f)
$$

The corresponding time-domain signal is reconstructed using the inverse FFT:

$$
y(t)=\mathrm{IFFT}\{Y(f)\}
$$

This method removes spectral components outside the selected DSB-SC sideband regions.

The MATLAB implementation also allows the frequency-domain filtered signal to be selected instead of the FIR-filtered signal for recovery and comparison.

---

## Coherent Demodulation

After filtering, the DSB-SC signal is coherently demodulated using a synchronized local carrier:

$$
z(t)=2y(t)\cos(2\pi f_c t)
$$

Using the modulation identity, this produces:

$$
z(t)=m(t)+m(t)\cos(4\pi f_c t)
$$

The result contains:

- The recovered baseband message
- A high-frequency component centered around $2f_c$

A low-pass FIR filter removes the high-frequency component and preserves the reconstructed message:

$$
m_{\mathrm{rec}}(t)=\mathrm{LPF}\{z(t)\}
$$

The recovered signal is then:

- DC-corrected
- Normalized
- Displayed in the time domain
- Played through MATLAB
- Saved as a WAV file

---

## Performance Metrics

### Signal-to-Noise Ratio

The recovered SNR is calculated as:

```math
\mathrm{SNR}
=
10\log_{10}
\left(
\frac{\sum m^2(t)}
{\sum \left[m(t)-m_{\mathrm{rec}}(t)\right]^2}
\right)
```

A higher SNR indicates that the recovered signal more closely matches the original message.

### Mean Squared Error

The MSE is calculated as:

```math
\mathrm{MSE}
=
\frac{1}{N}
\sum
\left[m(t)-m_{\mathrm{rec}}(t)\right]^2
```

A lower MSE indicates a smaller average reconstruction error.

---

## Results and Discussion

### Experiment 1 — Recorded Audio Noise

The recorded-noise experiment achieved:

```text
Recovered SNR: 16.23 dB
Recovered MSE: 0.000249
```

The filtering stage preserved the desired DSB-SC sidebands while reducing a significant portion of the unwanted out-of-band energy.

The recovered waveform retained the primary structure of the original audio signal, and the Welch PSD comparison showed close agreement across the useful baseband region.

This result demonstrates that spectral filtering can provide effective recovery when much of the unwanted noise energy lies outside the useful message bandwidth.

### Experiment 2 — AWGN and Narrowband Interference

The AWGN and narrowband-interference experiment achieved:

```text
Recovered SNR: 6.79 dB
Recovered MSE: 0.001967
```

The narrowband interferers were visible as concentrated spectral peaks and could be suppressed when they were located outside the desired sideband regions.

However, the broadband Gaussian noise overlapped the useful signal bandwidth. Because the message and noise occupied the same frequency regions, conventional filtering could not completely separate them.

This resulted in a higher reconstruction error and lower recovered SNR.

---

## Engineering Interpretation

The results support several important signal-processing conclusions:

- DSB-SC modulation translates the baseband spectrum to symmetric sidebands around the carrier frequency.
- FFT analysis provides direct visibility into signal bandwidth, carrier placement, noise, and interference.
- Welch PSD estimation provides a smoother representation of signal and noise power.
- Bandpass filtering is effective when unwanted components are outside the desired signal bands.
- Frequency-domain masking provides direct control over the retained spectral regions.
- Narrowband interferers are easier to identify and suppress than broadband in-band noise.
- AWGN cannot be completely removed when it overlaps the useful message spectrum.
- Coherent demodulation requires an accurately synchronized carrier.
- Low-pass filtering is required to isolate the recovered baseband component.
- SNR and MSE provide complementary measurements of signal-recovery quality.

---

## Repository Contents

```text
DSB-SC-SIGNAL-RECOVERY-MATLAB/
│
├── README.md
├── LICENSE
├── AM_Signal_Recovery_with_Spectral_Filtering.pdf
│
├── dsb_sc_audio_noise_recovery.m
├── dsb_sc_awgn_interference_recovery.m
│
├── audio_signal.m4a
├── noise_signal.m4a
│
├── clean_message.wav
├── noise_only.wav
├── noisy_message.wav
├── noisy_message_baseband.wav
└── recovered_message.wav
```

---

## MATLAB Scripts

### `dsb_sc_audio_noise_recovery.m`

Implements the complete modulation and recovery chain using recorded audio noise.

The script includes:

- Audio loading and preprocessing
- Sample-rate matching
- DSB-SC modulation
- Recorded-noise addition
- FFT magnitude and phase analysis
- Welch PSD estimation
- Message-bandwidth estimation
- FIR bandpass filtering
- Frequency-domain masking
- Coherent demodulation
- FIR low-pass filtering
- Audio playback and export
- SNR and MSE calculation

### `dsb_sc_awgn_interference_recovery.m`

Implements the second experiment using:

- Additive White Gaussian Noise
- Narrowband sinusoidal interference
- FFT and PSD analysis
- Bandpass filtering
- Coherent demodulation
- Signal reconstruction
- SNR and MSE evaluation

---

## Audio Files

### Input Files

- [`audio_signal.m4a`](audio_signal.m4a) — Baseband message audio
- [`noise_signal.m4a`](noise_signal.m4a) — Recorded noise used in Experiment 1

### Generated Output Files

- [`clean_message.wav`](clean_message.wav) — Normalized baseband message
- [`noise_only.wav`](noise_only.wav) — Normalized recorded-noise signal
- [`noisy_message.wav`](noisy_message.wav) — Baseband message combined with noise
- [`noisy_message_baseband.wav`](noisy_message_baseband.wav) — Additional noisy baseband output
- [`recovered_message.wav`](recovered_message.wav) — Reconstructed message after filtering and demodulation

Generated files may be overwritten when the scripts are executed again.

---

## Requirements

- MATLAB
- Signal Processing Toolbox

Major MATLAB functions used include:

```matlab
audioread
audiowrite
fft
fftshift
ifft
ifftshift
pwelch
fir1
filtfilt
hamming
resample
sound
uigetfile
```

---

## How to Run

### 1. Download the Repository

Download or clone the repository and open the project folder in MATLAB.

### 2. Set the Working Directory

Set the repository folder as the current MATLAB working directory.

### 3. Run the Recorded-Noise Experiment

```matlab
run('dsb_sc_audio_noise_recovery.m')
```

When prompted:

1. Select `audio_signal.m4a` as the message audio
2. Select `noise_signal.m4a` as the noise audio

The script will:

- Generate time-domain plots
- Generate FFT magnitude and phase plots
- Calculate Welch PSD estimates
- Estimate the message bandwidth
- Design and apply the filters
- Recover and play the message
- Save the output audio
- Display the calculated SNR and MSE

### 4. Run the AWGN and Interference Experiment

```matlab
run('dsb_sc_awgn_interference_recovery.m')
```

The script will generate the AWGN and narrowband interference, perform the recovery process, and display the corresponding results.

---

## Limitations

The current implementation assumes:

- Ideal carrier synchronization
- No carrier-frequency offset
- No carrier-phase error
- A fixed carrier frequency
- A short input-audio duration
- A stationary channel
- No multipath fading
- No nonlinear channel distortion
- Threshold-based message-bandwidth estimation
- Fixed FIR-filter orders

Recovery performance is influenced by:

- Input-signal bandwidth
- Noise amplitude
- Interference frequency
- Sampling frequency
- Carrier-frequency selection
- Bandwidth-estimation threshold
- Filter order
- Filter cutoff frequencies

---

## Future Improvements

Possible extensions include:

- Automated input-SNR control
- Output-SNR versus input-SNR analysis
- Carrier phase-offset simulation
- Carrier frequency-offset simulation
- Notch filtering for narrowband interferers
- Adaptive noise cancellation
- Comparison of FIR, IIR, and frequency-domain filters
- Automatic filter-order selection
- Spectrogram-based analysis
- Real-time microphone input
- MATLAB App Designer interface
- Comparison with conventional AM and single-sideband modulation
- Time-varying or fading channel simulation
- Digital-message transmission and BER analysis
- Automated export of plots and performance results

---

## Conclusion

This project successfully implements a complete DSB-SC modulation and signal-recovery system in MATLAB using real audio and two different channel-noise conditions.

The processing chain combines audio preprocessing, modulation, channel modeling, FFT analysis, Welch PSD estimation, bandwidth estimation, digital filtering, coherent demodulation, low-pass filtering, audio reconstruction, and quantitative performance evaluation.

The recorded audio-noise experiment achieved an SNR of 16.23 dB and an MSE of 0.000249, demonstrating that spectral filtering can provide strong recovery when a significant portion of the unwanted energy lies outside the desired signal bands.

The AWGN and narrowband-interference experiment achieved an SNR of 6.79 dB and an MSE of 0.001967. This lower performance demonstrates the fundamental limitation of conventional filtering when broadband noise overlaps the useful message spectrum.

Overall, the project demonstrates the practical relationship between modulation, spectral analysis, digital filter design, coherent detection, channel characteristics, and signal-quality evaluation.

---

## Technical Report

The complete project report is available here:

[View the full technical report](AM_Signal_Recovery_with_Spectral_Filtering.pdf)

The report includes:

- Theoretical background
- System specifications
- Mathematical derivations
- Time-domain analysis
- FFT magnitude and phase analysis
- Welch PSD estimation
- Filter design
- Recovered-signal evaluation
- SNR and MSE results
- Discussion and conclusions

---

## Academic Context

Developed for **ECE 550 — Communication Systems** at the **University of Michigan**, Winter 2026.

---

## License

This project is licensed under the [MIT License](LICENSE).
