function [dereverberated]=dereverberate(reverb_post,clean_prior,reverb_local)

% Inputs: 
% reveb_post    : reverberant posterior sample of pca-processed supervector 
%                 features one pca-component at time
%                 Note! reverberant posterior sample needs to include
%                 samples in the reverb_loca, otherwise mapping is not stable
% clean_prior   : clean prior features in the same format
% reverb_local  : reverberant features in the same format
%                 that will be dereverberated
% Outputs:
% dereverberated: dereverberated features in the same format
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.


mini=min([size(reverb_post,2) size(clean_prior,2)]);
reverb_post=reverb_post(:,end-mini+1:end);
clean_prior=clean_prior(:,1:mini);
reverb_post_sorted=unique(reverb_post);
clean_prior_sorted=sort(clean_prior(1:length(reverb_post_sorted)));
dereverberated=interp1(reverb_post_sorted,clean_prior_sorted,reverb_local,'pchip');

