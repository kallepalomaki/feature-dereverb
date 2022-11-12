function [norm_feats, norm_vec] = meannorm(feats, N, mask)
%MEANNORM  Peak-based mean normalization for missing-data methods.
%   [NORM_FEATS, NORM_VEC] = MEANNORM(FEATS) returns a mean-normalized
%   version of FEATS, as well as the normalization coefficient vector.
%   A fraction of 1/5 of the data surrounding the highest maxima on
%   each channel is used to compute the normalization.
%
%   [...] = MEANNORM(FEATS, N) additionally specifies the
%   normalization parameter such that a fraction of 1/N is used
%   instead.
%
%   [...] = MEANNORM(FEATS, N, MASK) further restricts the
%   normalization to take into account only values for which the
%   binary mask MASK is true.
%
%   The details of the feature normalization can be found in Palomäki
%   et al., "Techniques for handling convolutional distortion with
%   'missing data' automatic speech recognition". Speech
%   Communication, 43(1-2), pp. 123-142, 2004.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

[nchans, nframes] = size(feats);
keep = round((nframes-1) / N);

if nargin < 3 || isempty(mask)
    mask = true(nchans, nframes);
end

masked = feats(:,1:end-1) .* mask(:, 1:end-1);
lp = largest_peaks(masked, keep);
norm_vec = sum(lp, 2) ./ sum(lp > 0, 2);

% Fill empty blocks in normalization vectors by linear interpolation
% from neighbors, or by repeating if at the edge of the vector.

bad = isnan(norm_vec) | isinf(norm_vec);

t = diff([0;bad;0]);
bad1 = find(t == 1);
bad2 = find(t == -1) - 1;
nbad = length(bad1);

for t = 1:nbad
    b = [bad1(t)-1 bad2(t)+1];
    if b(1) >= 1 && b(2) <= nchans
        norm_vec(b(1)+1:b(2)-1) = interp1(b, norm_vec(b), b(1)+1:b(2)-1, 'linear');
    elseif b(2) <= nchans
        norm_vec(1:b(2)-1) = norm_vec(b(2));
    elseif b(1) >= 1
        norm_vec(b(1)+1:end) = norm_vec(b(1));
    else
        error('meannorm:bad', 'No normalization vector elements found at all (blank mask?)');
    end
end

norm_feats = bsxfun(@rdivide, feats, norm_vec);

function P = largest_peaks(x, N)
%LARGEST_PEAKS  Keep only values near peaks.
%   P = LARGEST_PEAKS(X, N) returns a copy of X where only N largest
%   samples (per channel) have been kept nonzero.

[nchans, nframes] = size(x);
P = zeros(nchans, nframes);
for i = 1:nchans
    [~,idx] = sort(x(i,:));
    P(i, idx(end-N:end)) = x(i, idx(end-N:end));
end
