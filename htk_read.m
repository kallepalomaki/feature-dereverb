function [data, rate, kind] = htk_read(file)
% HTK_READ Read a HTK format parameter file.
%
%   DATA = HTK_READ(FILE) reads the contents of FILE in the HTK
%   parameter data file format.  The data is returned as a matrix
%   of column vectors, where each column is a sample.
%
%   [DATA, RATE] = HTK_READ(FILE) returns the recorded sampling
%   rate information from the file.
%
%   [DATA, RATE, KIND] = HTK_READ(FILE) additionally returns the
%   HTK "parameter kind" contained in the input file.

% Read and parse the HTK header.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.


f = fopen(file, 'r', 'ieee-be');
if f == -1
    error('htk_read:fopen', 'Unable to open input file', file);
end

nSamples = fread(f, 1, '*uint32');
sampPeriod = fread(f, 1, '*uint32');
sampSize = fread(f, 1, '*uint16');
parmKind = fread(f, 1, '*uint16');

[~, t] = ferror(f);
if t || feof(f)
    error('htk_read:header', 'Unable to read HTK header', file);
end

if bitand(parmKind, oct2dec(2000))
    error('htk_read:compressed', 'Compressed HTK file not supported', file);
end

if nargout > 1
    rate = round(1e7/double(sampPeriod));
end

if nargout > 2
    kinds = {'WAVEFORM', ...
             'LPC', 'LPREFC', 'LPCEPSTRA', 'LPDELCEP', 'IREFC', ...
             'MFCC', 'FBANK', 'MELSPEC', ...
             'USER', 'DISCRETE', 'PLP'};
    flags = 'ENDACZK0VT';

    k = bitand(parmKind, 63);
    if k < length(kinds)
        kind = kinds{k+1};
    else
        kind = 'UNKNOWN';
    end
    
    for t = 1:length(flags)
        if bitand(parmKind, bitshift(64, t-1))
            kind = [kind '_' flags(t)];
        end
    end
end

% Get the data.

dim = double([sampSize/4 nSamples]);
data = fread(f, dim, 'single');
if ~all(size(data) == dim) || feof(f)
    error('htk_read:data', 'Unable to read HTK data', file);
end

fclose(f);
