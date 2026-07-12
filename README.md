# DSB-SC Signal Recovery with Spectral Filtering in MATLAB

A MATLAB implementation of a complete Double-Sideband Suppressed-Carrier (DSB-SC) communication and signal-recovery chain using real audio, recorded noise, additive white Gaussian noise, narrowband interference, spectral analysis, digital filtering, and coherent demodulation.

## Overview

This project investigates the transmission and recovery of an amplitude-modulated audio signal under different channel-noise conditions.

A real audio recording is used as the baseband message. The signal is preprocessed, modulated using DSB-SC modulation with a 10 kHz carrier, corrupted by noise and interference, analyzed in the time and frequency domains, filtered, coherently demodulated, and reconstructed.

Two channel conditions are evaluated:

1. Recorded audio noise
2. Additive White Gaussian Noise (AWGN) with narrowband interference

Recovery performance is measured using:

- Signal-to-Noise Ratio (SNR)
- Mean Squared Error (MSE)
- Fast Fourier Transform (FFT) analysis
- Welch Power Spectral Density (PSD) estimation
- Time-domain waveform comparison
- Original-versus-recovered spectral comparison
- Recovered audio playback

---

## Key Results

| Experiment | Channel Condition | Recovered SNR | Recovered MSE |
|---|---|---:|---:|
| Experiment 1 | Recorded audio noise | 16.23 dB | 0.000249 |
| Experiment 2 | AWGN and narrowband interference | 6.79 dB | 0.001967 |

The recorded-noise experiment produced stronger recovery because a significant portion of the unwanted energy could be removed through spectral filtering.

The AWGN experiment was more challenging because broadband noise overlaps the useful signal spectrum. Filtering can reduce out-of-band noise and isolated interference, but it cannot completely eliminate in-band noise without also affecting the desired message.

---

## Technical Highlights

This project demonstrates:

- Real audio-signal preprocessing
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
- Quantitative validation using SNR and MSE

---

## Signal-Processing Chain

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

The input message is represented by:

$$
m(t)
$$

The audio is converted to mono, limited to a short processing interval, centered by removing its DC component, and normalized before modulation.

### DSB-SC Modulation

The transmitted DSB-SC signal is:

$$
s(t)=m(t)\cos(2\pi f_c t)
$$

where:

- $m(t)$ is the normalized baseband message
- $f_c$ is the carrier frequency
- $s(t)$ is the DSB-SC modulated signal

The carrier frequency used in this project is:

$$
f_c = 10\text{ kHz}
$$

In the frequency domain, modulation shifts the baseband spectrum to two symmetric sidebands centered around $+f_c$ and $-f_c$.

### Noisy Received Signal

For the recorded-noise experiment, the received signal is modeled as:

$$
x(t)=s(t)+\alpha n(t)
$$

where:

- $s(t)$ is the transmitted DSB-SC signal
- $n(t)$ is the normalized noise signal
- $\alpha$ controls the noise amplitude
- $x(t)$ is the corrupted received signal

---

## Experimental Configurations

### Experiment 1 — Recorded Audio Noise

The first experiment uses a recorded audio signal as the noise source.

The message and noise recordings are:

- Converted to mono
- Resampled when necessary
- Trimmed to equal lengths
- DC-corrected
- Independently normalized

The normalized noise is then added to the DSB-SC signal using a configurable amplitude factor.

This experiment represents a nonuniform noise source whose energy is concentrated in particular frequency regions.

### Experiment 2 — AWGN and Narrowband Interference

The second experiment replaces the recorded-noise channel with:

- Additive White Gaussian Noise
- Narrowband sinusoidal interferers

AWGN introduces a broadband spectral floor across the frequency range, while the narrowband interferers appear as concentrated spectral peaks.

This creates a more difficult recovery problem because some of the unwanted energy overlaps the useful sidebands.

---

## Audio Preprocessing

Before modulation, the message audio is processed using the following sequence:

1. Load the selected audio file
2. Convert stereo audio to mono
3. Limit the signal duration to approximately three seconds
4. Remove the DC component
5. Normalize the signal amplitude
6. Generate the time vector
7. Compute the centered FFT
8. Estimate the effective baseband bandwidth

The preprocessing stage ensures consistent amplitude scaling and prepares the signal for modulation, filtering, and performance comparison.

---

## Time- and Frequency-Domain Analysis

The Fast Fourier Transform is used to analyze:

- The original baseband message
- The noise signal
- The DSB-SC modulated signal
- The noisy received signal
- The bandpass-filtered signal
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

Welch's method is used to obtain a statistically smoother estimate of signal-power distribution.

The PSD calculation uses:

- Hamming windows
- Overlapping signal segments
- A centered frequency representation
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

Welch PSD analysis helps distinguish useful signal energy from the surrounding noise floor more clearly than a single FFT magnitude plot.

---

## Message-Bandwidth Estimation

The effective message bandwidth is estimated from the normalized magnitude spectrum of the original audio signal.

The implementation:

1. Normalizes the FFT magnitude
2. Applies an amplitude threshold
3. Identifies the significant frequency components
4. Determines the maximum baseband frequency
5. Adds a safety margin to reduce signal truncation

The estimated bandwidth is then used to determine:

- The bandpass-filter limits
- The frequency-domain mask width
- The low-pass-filter cutoff frequency

---

## Filtering Approaches

Two filtering methods are implemented.

### FIR Bandpass Filtering

A finite impulse response bandpass filter is designed around the positive carrier region:

$$
f_c-B \leq f \leq f_c+B
$$

where:

- $f_c$ is the carrier frequency
- $B$ is the estimated message bandwidth

The implementation uses:

```matlab
fir1
hamming
filtfilt
```

`filtfilt` performs forward and reverse filtering, resulting in zero-phase distortion and avoiding a net group delay in the recovered waveform.

### Frequency-Domain Spectral Masking

A binary spectral mask is also implemented to preserve the sidebands around both positive and negative carrier frequencies:

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
y(t)=\operatorname{IFFT}\{Y(f)\}
$$

This method removes frequency components outside the selected DSB-SC sideband regions.

---

## Coherent Demodulation

After filtering, the DSB-SC signal is coherently demodulated using a synchronized local carrier:

$$
z(t)=2y(t)\cos(2\pi f_c t)
$$

This operation produces:

- The recovered baseband message
- A high-frequency component centered around $2f_c$

A low-pass FIR filter removes the high-frequency term and preserves the reconstructed message.

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

$$
\text{SNR}
=
10\log_{10}
\left(
\frac{\sum m^2(t)}
{\sum [m(t)-m_{\text{rec}}(t)]^2}
\right)
$$

A higher SNR indicates that the recovered signal more closely matches the original message.

### Mean Squared Error

The MSE is calculated as:

$$
\text{MSE}
=
\frac{1}{N}
\sum
[m(t)-m_{\text{rec}}(t)]^2
$$

A lower MSE indicates a smaller average reconstruction error.

---

## Results and Discussion

### Recorded Audio-Noise Experiment

The recorded-noise experiment achieved:

```text
Recovered SNR: 16.23 dB
Recovered MSE: 0.000249
```

The filtering stage successfully preserved the desired DSB-SC sidebands while reducing a significant portion of the unwanted out-of-band energy.

The recovered waveform retained the primary structure of the original audio signal, and the Welch PSD comparison showed close agreement throughout the useful baseband region.

### AWGN and Narrowband-Interference Experiment

The AWGN and interference experiment achieved:

```text
Recovered SNR: 6.79 dB
Recovered MSE: 0.001967
```

The narrowband interferers were visible as concentrated spectral peaks and could be reduced when they were located outside the desired sideband regions.

However, the broadband Gaussian noise overlapped the useful signal bandwidth. Because the message and noise occupied the same frequencies, conventional filtering could not completely separate them.

This resulted in a higher reconstruction error and lower recovered SNR.

---

## Engineering Interpretation

The results support several important signal-processing conclusions:

- DSB-SC modulation translates the baseband spectrum to symmetric carrier-centered sidebands.
- FFT analysis provides direct visibility into signal bandwidth, carrier placement, noise, and interference.
- Welch PSD estimation provides a smoother view of energy distribution and noise-floor behavior.
- Bandpass filtering is effective when unwanted components are outside the desired signal bands.
- Frequency-domain masking provides direct control over the retained spectral regions.
- Narrowband interferers are easier to identify and suppress than broadband in-band noise.
- AWGN cannot be completely removed when it overlaps the desired message spectrum.
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

Implements the complete DSB-SC modulation and recovery chain using a recorded audio-noise input.

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

Implements the second channel experiment using:

- Additive White Gaussian Noise
- Narrowband sinusoidal interference
- Spectral analysis
- Bandpass filtering
- Coherent demodulation
- Signal reconstruction
- SNR and MSE evaluation

---

## Audio Files

### Inputs

- [`audio_signal.m4a`](audio_signal.m4a) — Baseband message audio
- [`noise_signal.m4a`](noise_signal.m4a) — Recorded noise used in Experiment 1

### Generated Outputs

- [`clean_message.wav`](clean_message.wav) — Normalized baseband message
- [`noise_only.wav`](noise_only.wav) — Normalized noise signal
- [`noisy_message.wav`](noisy_message.wav) — Message combined with noise
- [`noisy_message_baseband.wav`](noisy_message_baseband.wav) — Additional noisy baseband output
- [`recovered_message.wav`](recovered_message.wav) — Reconstructed message after demodulation and filtering

Generated output files may be overwritten when the scripts are executed again.

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

- Generate the time- and frequency-domain plots
- Calculate Welch PSD estimates
- Design and apply the filters
- Recover and play the message
- Save the output audio
- Display SNR and MSE in the Command Window

### 4. Run the AWGN and Interference Experiment

```matlab
run('dsb_sc_awgn_interference_recovery.m')
```

The script will generate the AWGN and narrowband interference, apply the recovery process, and display the corresponding results.

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

- Input signal bandwidth
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

- Input-SNR control and automated SNR sweeps
- Output-SNR versus input-SNR plots
- Carrier phase-offset analysis
- Carrier frequency-offset analysis
- Notch filtering for narrowband interferers
- Adaptive noise cancellation
- Comparison of FIR, IIR, and ideal frequency-domain filters
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

Developed for **ECE 550 — Communication Systems** at the **University of Michigan–Dearborn**, Winter 2026.

---

## Author

**Hamza Al-Zakarneh**

Electrical Engineer focused on:

- Embedded systems
- Electrical and electronic hardware design
- Hardware validation
- Software and test automation
- Functional safety analysis
- Power electronics
- Digital signal processing
- Automotive electronics

---

## License

This project is licensed under the [MIT License](LICENSE).
