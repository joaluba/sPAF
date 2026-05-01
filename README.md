# sPAF — Sparse Periodicity-Based Auditory Features

Feature extraction for computational auditory scene analysis, based on the theory of auditory glimpses.

**Associated publication:**  
Luberadzka J., Kayser H., Hohmann V. (2022). *Making sense of periodicity glimpses in a prediction-update-loop — A computational model of attentive voice tracking.* Journal of the Acoustical Society of America, 151(2), 712–737. [https://doi.org/10.1121/10.0009337](https://doi.org/10.1121/10.0009337)


## Overview

How do humans follow a speaker in a noisy, multi-talker environment? One influential account holds that the auditory system does not rely on a continuous signal representation, but instead picks up on sparse, robust *glimpses* — brief moments in time and frequency where a target source dominates the mixture.

**sPAF** (Sparse Periodicity-based Auditory Features) is a MATLAB implementation of an algorithm that extracts exactly these glimpses from an auditory scene. It takes a sound mixture as input and produces a compact, three-dimensional sparse representation of its most salient tonal components — indexed by **time**, **auditory frequency channel**, and **periodicity (period)**. Non-salient components are discarded, leaving only the robust parts of the signal that survive in adverse listening conditions.

sPAF was developed as the front-end feature extraction block of a larger computational model of attentive voice tracking, combining auditory glimpse theory, foreground-background segregation, and sequential Bayesian estimation (particle filtering).


## Algorithm Summary

1. **Gammatone filterbank** — decomposes the input waveform into auditory frequency channels (ERB-spaced, 32 channels by default).
2. **Short-time autocorrelation** — computed within each channel over a sliding window, yielding a periodicity representation at each time frame.
3. **Peak picking** — local maxima in the autocorrelation function are identified across the period dimension.
4. **Salience thresholding** — only peaks exceeding a threshold (relative to the channel's overall energy) are retained as glimpses.
5. **Output** — a sparse 3D array (time × channel × period) of glimpse amplitudes and associated period estimates.

---

*Developed at the Auditory Signal Processing & Digital Hearing Devices group, University of Oldenburg, Germany (Cluster of Excellence Hearing4all).*
