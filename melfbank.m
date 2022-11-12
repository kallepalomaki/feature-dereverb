function mel = melfbank(dim, varargin)
%MELFBANK  Create a mel-scale filterbank matrix.
%   MELFBANK(DIM) returns a 21xDIM matrix that can be used to
%   left-multiply a DIMxN FFT domain spectrogram to generate a
%   (linear) mel-domain spectrogram.
%
%   MELFBANK(DIM, 'Option', Value, ...) can be used to override the
%   following options, with their default values given in brackets:
%
%   'Rate' [16000]: Sampling rate of the input signal.
%
%   'Channels' [determined based on sample rate]: Number of channels
%   in the mel filterbank, overriding the default selection.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.


%% input arguments

p = inputParser;
p.FunctionName = 'melfbankl';
addParamValue(p, 'Rate', 16000);
addParamValue(p, 'Channels', []);
parse(p, varargin{:});
arg = p.Results;

if isempty(arg.Channels)
    arg.Channels = round((21+2)*log10(1+arg.Rate/1400)/log10(1+16000/1400)-2);
end

%% mel-scale filterbank

nedges = arg.Channels + 2;
step = log10(1 + arg.Rate/1400) / nedges;
edges = 1400*(10.^((1:nedges)*step) - 1) * (dim-1) / arg.Rate;

mel = sparse(arg.Channels, dim);

for ch = 1:arg.Channels
    % mel filter triangle coordinates
    tbeg = edges(ch); tbegi = max(ceil(tbeg), 1);
    tmid = edges(ch+1)+1; tmidi = floor(tmid);
    tend = edges(ch+2)+1; tendi = floor(tend);
    % filter weights
    mel(ch, tbegi:tendi) = [ ...
        ((tbegi:tmidi).' - tbeg) / (tmid - tbeg); ...
        (tend - (tmidi+1:tendi).') / (tend - tmid) ];
end
