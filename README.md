# DSB-SC Signal Recovery with Spectral Filtering in MATLAB

## Overview

This project implements and evaluates a complete amplitude-modulation and signal-recovery chain using Double-Sideband Suppressed-Carrier (DSB-SC) modulation in MATLAB.

A real audio signal is used as the baseband message. The signal is preprocessed, modulated using a 10 kHz carrier, corrupted by different noise and interference conditions, analyzed in both the time and frequency domains, filtered, coherently demodulated, and reconstructed.

The recovered signal is evaluated using:

- Signal-to-Noise Ratio (SNR)
- Mean Squared Error (MSE)
- Fast Fourier Transform (FFT) analysis
- Welch Power Spectral Density (PSD) estimation
- Time-domain waveform comparison
- Audio playback and saved output files

The project includes two channel-noise experiments:

1. Recorded audio noise
2. Additive White Gaussian Noise (AWGN) combined with narrowband interference

The results demonstrate how spectral filtering can effectively suppress out-of-band interference, while also showing the limitations of filtering when unwanted noise overlaps the useful signal bandwidth.

---

## Project Objectives

The main objectives of this project are to:

- Implement DSB-SC modulation using a real baseband audio signal
- Analyze the baseband and modulated signals in the time and frequency domains
- Introduce realistic channel noise and interference
- Estimate signal energy distribution using Welch PSD analysis
- Estimate the effective baseband bandwidth
- Design bandpass and low-pass filters for signal recovery
- Apply frequency-domain spectral masking
- Perform coherent demodulation
- Reconstruct and save the recovered audio signal
- Quantify recovery quality using SNR and MSE

The complete methodology, mathematical background, figures, and results are documented in the included technical report. :contentReference[oaicite:0]{index=0}

---

## System Workflow

The complete processing chain is:

```text
Input Audio
    ↓
Stereo-to-Mono Conversion
    ↓
DC Removal and Normalization
    ↓
DSB-SC Modulation
    ↓
Noise and Interference Addition
    ↓
FFT and Welch PSD Analysis
    ↓
Baseband Bandwidth Estimation
    ↓
Bandpass Filtering / Spectral Masking
    ↓
Coherent Demodulation
    ↓
Low-Pass Filtering
    ↓
Recovered Audio Signal
    ↓
SNR, MSE, PSD, and Waveform Evaluations.
