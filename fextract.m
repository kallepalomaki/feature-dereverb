function [data,frate] = fextract(file)
% FEXTRACT Mel-spectral feature extraction.
%
%   DATA = FEXTRACT(FILE) uses a matlab script to extract a linear
%   Mel-filterbank magnitude spectrogram corresponding to the audio in
%   FILE. Use regular .wav files.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

[sig,fs]=wavread(file);

[data,frate]=sig2mel(sig);
