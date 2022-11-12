function [data, rate] = fextract_htk(file, logflag, stime, etime)
% FEXTRACT Mel-spectral feature extraction.
%
%   DATA = FEXTRACT(FILE) uses HTK HCopy to extract a linear
%   Mel-filterbank magnitude spectrogram corresponding to the audio in
%   FILE.  Both NIST SPHERE .wvX and regular .wav files work.
%
%   DATA = FEXTRACT(FILE, LOGFLAG) extracts logarithmic filterbank
%   outputs when LOGFLAG is nonzero.
%
%   DATA = FEXTRACT(FILE, LOGFLAG, STIME, ETIME) additonally restricts
%   the feature extraction to the region between the times STIME and
%   ETIME, expressed as seconds from start of file.
%
%   [DATA, RATE] = FEXTRACT(...) additionally returns the frame
%   rate of the features.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

cfg = getcfg();

if nargin < 2
    logflag = 0;
end

hconfig = cell(2, 1);

if ~logflag
    hconfig{1} = [cfg.root '/config/config.hcopy_wave2mel'];
else
    hconfig{1} = [cfg.root '/config/config.hcopy_wave2lmel'];
end

if strcmp(file(end-3:end-1), '.wv')
    hconfig{2} = [cfg.root '/config/config.hcopy_WSJCAM0'];
else
    hconfig{2} = [cfg.root '/config/config.hcopy_MCWSJAV'];
end

if nargin >= 4
    [data, rate, kind] = hcopy(hconfig, file, stime, etime);
else
    [data, rate, kind] = hcopy(hconfig, file);
end

if ~logflag && ~strcmp(kind, 'MELSPEC')
    error('fextract:kind', 'Unexpected output kind; expected MELSPEC', kind, file);
end
if logflag && ~strcmp(kind, 'FBANK')
    error('fextract:kind', 'Unexpected output kind; expected FBANK', kind, file);
end
