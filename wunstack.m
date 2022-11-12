function data = wunstack(stacked, T, noavg)
% WUNSTACK Unstack and average stacked data.
%
%   DATA = WUNSTACK(STACKED, T) is the inverse operation of WSTACK.
%   It will take the (T*D)xW matrix STACKED, and return the Dx(W+T-1)
%   overlap-and-averaged version.
%
%   DATA = WUNSTACK(STACKED, T, NOAVG) will, if NOAVG is true, skip
%   the averaging, and return the reconstruction with simple addition.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

if nargin < 3; noavg = 0; end

if T > 1
    dtype = class(stacked);
    
    [TD, W] = size(stacked);
    N = W+T-1;
    
    D = round(TD/T);
    assert(T*D == TD);
    
    data = zeros(D, N, dtype);
    for w = 1:T
        data(:, w:end-T+w) = data(:, w:end-T+w) + stacked((w-1)*D+1:w*D, :);
    end
    
    if ~noavg
        overlap = min(W, T);
        dataN = overlap*ones(1, N, dtype);
        dataN(1:overlap) = 1:overlap;
        dataN(end-overlap+1:end) = overlap:-1:1;
        data = bsxfun(@rdivide, data, dataN);
    end
else
    data = stacked;
end
