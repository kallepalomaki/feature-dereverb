% This scripts is made to run a demonstration of the study: 
%
% Palomäki K. J. and Kallasjoki H. (2014) Reverberation robust 
% speech recognition by matching distributions of spectrally and 
% temporally decorrelated features, REVERB Workshop 2014.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.
%
% Setting flag_aalto_internal=1 
% relies in some Aaltos internal filestructures
% to run original reverb-challenge experiments.
% Set zero to use outside Aalto to run over provided 
% freeware samples.
%

flag_aalto_internal=0;

if flag_aalto_internal==0
  make_train_data
end

train_pca

make_enhanced
