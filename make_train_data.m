%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

[list_clean]=textread('train_files.txt','%s%*[^\n]');

Fea=[];

if flag_aalto_internal==1                            
  fextractf=@(inputpath) fextract_htk(inputpath);
elseif flag_aalto_internal==0
  fextractf=@(inputpath) fextract(inputpath);
end


for idx_clean=1:length(list_clean)
  name_wav=char(list_clean(idx_clean));
  fprintf(1, 'training data generation: %s (%d/%d)\n', name_wav, idx_clean,length(list_clean));        

  [feats] = fextractf(name_wav);
  Fea=[Fea feats];
end

save train_data Fea
