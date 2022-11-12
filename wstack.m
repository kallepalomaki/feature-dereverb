function stacked = wstack(data, T)
% WSTACK Stack frames to windows.
%
%   STACKED = WSTACK(DATA, T) will take column vectors out of the DxN
%   data matrix DATA, and stack them to the (T*D)x(N-T+1) matrix
%   STACKED.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

if T > 1
    dtype = class(data);
    
    [D, N] = size(data);
    stacked = zeros(T*D, N-(T-1), dtype);
    for w = 1:T
        stacked((w-1)*D+1:w*D, :) = data(:, w:end-T+w);
    end
else
    stacked = data;
end
