Introduction
============

This archive contains code implementing the distribution matching based
reverberant speech feature enhancement scheme evaluated in:

Palomaki K. J. and Kallasjoki H. (2014) Reverberation robust speech 
recognition by matching distributions of spectrally and temporally 
decorrelated features, REVERB Workshop 2014. 

You should be able to run the program using script demo.m in Matlab
this should result in images of dereverberated, clean and
reverberant spectrograms. 

You can run the method with freeware speech samples from the LibriVox project
you can get following the link below:
https://drive.google.com/file/d/1ewUm7h0-pTZBl8q_GHUG01yvWOmGqcMk/view?usp=sharing

Please note that the results in the paper are on different data and the
method has not been tested in ASR using these particular samples.

The source code is made available under the following BSD-license
See file LICENCE.

Files and Functions
===================

Below are short descriptions of the files and functions included in
this archive.  For more detailed documentation of functions, use the
MATLAB "help" command on them.

Main functions
--------------

demo.m:
MATLAB script containing demonstration usage of other functions.

make_train_data.m:
Generation of the training data mel-spectral features.

train_pca.m:
Training script for the PCA to decorrelate supervectors.

make_enhanced.m:
Runs the enhancement over test utterances.

dereverb_spegram.m:
Dereverberation of spectrograms given the reverberant spectrogram 
clean prior and reverberant posterior samples.

Utility functions
-----------------

dist_map.m:
Distribution mapping.

fextract_htk.m:
For our internal use mainly. Runs HTK Hcopy command for feature extraction.
Not needed in the basic setting.

fextract.m:
Runs matlab script for mel-spectral feature extraction.

getcfg.m:
For our internal use. Defines configuration files for HTK paths ect.
Not needed in the basic setting.

hcopy.m:
For our internal use. Runs hcopy from matlab.
Not needed in the basic setting.

htk_read.m:
For our internal use. Reads HTK-files.
Not needed in the basic setting.

meannorm.m:
Spectral mean normalization using Palomaki et al. 2004 method.

melfbank.m:
Mel-spectral filterbank.

sig2mel.m:
Generation of mel-spectral features from audio signals.

wstack.m:
Composes supervectors from spectrograms.

wunstack.m:
Decomposes supervectors to spectrograms.
