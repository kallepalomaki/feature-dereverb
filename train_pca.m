%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

if flag_aalto_internal==0
  load train_data
elseif flag_aalto_internal==1
  load ../../Enh
  Fea=Clean;
end
[Fea_mn,wei_clean]=meannorm(Fea,5,ones(size(Fea,1),size(Fea,2)));

dim_stack=20;
dim_pca=40;
X=wstack(log(Fea),dim_stack)';

mX = mean(X, 1);
sX = std(X, [], 1);

save wei_mean_clean wei_clean mX sX

X = bsxfun(@rdivide, bsxfun(@minus, X, mX), sX);
coeff=pca(X);

X_pca=X*coeff(:,1:dim_pca);
V=X_pca*coeff(:,1:dim_pca)';

%figure(1)
%imagesc(X_pca')

%figure(2)
%imagesc(V')

save pca_coeff coeff X_pca
