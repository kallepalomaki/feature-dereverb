function cfg = getcfg()
% GETCFG Return global configuration settings.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

cfg = struct();

cfg.root = '/akulabra/projects/T40511/kpalomak/reverb-challenge';
cfg.in_root = '/akulabra/projects/T40511/htkallas/reverb-challenge';

cfg.tempdir = '/tmp';
cfg.htkbin = [cfg.root '/sys/asr/tools/HTK/htk/bin'];
cfg.nistbin = [cfg.root '/sys/asr/tools/SPHERE/nist/bin'];
