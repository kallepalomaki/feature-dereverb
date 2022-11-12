function [enh] = rev_pca(feats,H_rev_post,H_prior,params)

% Inputs: 
% feats       : feature spectrograms in mag or power spectral domain
% H_rev_post  : reverberant posterior sample in pca-supervector domain
% H_prior     : clean prior sampe in pca-supervector domain
% params      : a structure containing parameters
%
% Output: 
% enh         : enhanced features spectrogram
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.



% Set parameters
% testing stuff

do_plot=0;
dim_pca=params.dim_pca;
dim_stack=params.dim_stack;
sX=params.sX;
mX=params.mX;
wei_clean=params.wei_clean;
coeff=params.pca_coeff;

% Mean-normalize features, apply frequency weighting, stack
nch=size(feats,1);
nframes = size(feats, 2);

% transform reverb data channel gains to corresponding clean data gains
% applying Palomäki et al 2004 method
if params.normaliz(1)==1
  [feats_mn,wei_fea]=meannorm(feats,5,ones(size(feats,1),size(feats,2)));
  for cnt_ch=1:nch
    feats(cnt_ch,:)=feats_mn(cnt_ch,:)*wei_clean(cnt_ch);
  end
end

% construct spectral supervector for reverberant data
X_rev=wstack(log(feats),dim_stack)';

% apply same mean and variance normalization factors that was done for 
% the clean data this makes sense after above mean normalization step
X_rev=bsxfun(@rdivide, bsxfun(@minus, X_rev, mX), sX);

% transform spectra supervector to the pca-domain
H_rev = X_rev*coeff(:,1:dim_pca);

tmp=[];

% distribution mapping
for cnt_dim=1:size(H_prior,2)
  mini=min([size(H_rev_post,1) size(H_prior,1)]);
  %tmp=dereverberate_stab(H_rev_post(1:mini,cnt_dim)',H_prior(1:mini,cnt_dim)',H_rev(:,cnt_dim)');
  tmp=dist_map(H_rev_post(1:mini,cnt_dim)',H_prior(1:mini,cnt_dim)',H_rev(:,cnt_dim)');
  H_dereverb(cnt_dim,:)=tmp;
end

% transform reverberant data from pca domain to spectral domain supervector
% this matrix is smoothed by reduced pca-coeffs (dim_pca)
V_rev=H_rev*coeff(:,1:dim_pca)';

% transform dereveberated data to spectral domain supervector
V_dereverb=H_dereverb'*coeff(:,1:dim_pca)';

% return clean data means and variances
X_rev=bsxfun(@plus, bsxfun(@times, X_rev, sX), mX);
V_rev=bsxfun(@plus, bsxfun(@times, V_rev, sX), mX);
V_dereverb=bsxfun(@plus, bsxfun(@times, V_dereverb, sX), mX);

% construct spectral vectors from super vectors
% smooth dereverberated data
v_dereverb=wunstack(V_dereverb',dim_stack);

% reverberated data
x_rev=wunstack(X_rev',dim_stack); 

% smooth reverberated data
v_rev=wunstack(V_rev',dim_stack);

% we call this step the Wiener filter in the paper
v_dereverb_filt=v_dereverb+x_rev-v_rev;

enh=exp(v_dereverb_filt);

% return clean data channel gains
if params.normaliz(2)==1
  [enh_mn,wei_fea]=meannorm(enh,5,ones(size(feats,1),size(feats,2)));
  for cnt_ch=1:nch
    enh(cnt_ch,:)=enh_mn(cnt_ch,:)*wei_clean(cnt_ch);
  end
end


% plotting some of the figures in the Reverb workshop poster
if do_plot==1
  f_size=20;
  end_le=80;
  h=figure(1)
  clf
  set(h,'paperpositionmode','auto');  
  subplot(2,1,1)
  imagesc(v_rev)
  title('smooth reverberant','FontSize',f_size)
  subplot(2,1,2)
  imagesc(x_rev)
  title('reverberant','FontSize',f_size)
  
  figure(2)
  clf
  subplot(2,1,1)
  imagesc(v_dereverb(:,1:end-end_le))
  title('smooth dereverberated','FontSize',f_size)
  subplot(2,1,2)
  imagesc(v_dereverb_filt(:,1:end-end_le))    
  title('Wiener filtered dereverberated','FontSize',f_size)
  size_ve=[.2 .1 .4 .2];
  h=figure(3);
  set(h,'units','normalized','position',size_ve,'paperpositionmode','auto')
  imagesc(x_rev(:,1:end-end_le))    
  title('reverberant specra','FontSize',f_size)
  print -djpeg spe_reverb
  
  figure(4)
  imagesc(X_rev(1:end-end_le,:)')
  title('reverberant spectral supervectors','FontSize',f_size)
  print -djpeg supervect_spe_reverb
  
  size_ve2=[.2 .1 .4 .3];  
  figure(5)
  h=figure(5);
  set(h,'units','normalized','position',size_ve2,'paperpositionmode','auto')
  imagesc(H_rev(1:end-end_le,:)')
  title('reverberant pca supervectors','FontSize',f_size)
  print -djpeg supervect_pca_reverb
  
  figure(6)
  h=figure(6);
  set(h,'units','normalized','position',size_ve2,'paperpositionmode','auto')
  imagesc(H_dereverb(:,1:end-end_le));
  title('dereverberated pca supervector','FontSize',f_size)
  print -djpeg supervect_pca_dereverb

  figure(7)
  imagesc(V_dereverb(1:end-end_le,:)');
  title('dereverberated spectral supervector','FontSize',f_size)
  print -djpeg supervect_spe_dereverb

  h=figure(8);
  set(h,'units','normalized','position',size_ve,'paperpositionmode','auto')
  imagesc(v_dereverb(:,1:end-end_le));
  title('smooth dereverberated spectra','FontSize',f_size)
  print -djpeg smooth_dereverb

  h=figure(9);
  set(h,'units','normalized','position',size_ve,'paperpositionmode','auto')
  imagesc(v_dereverb_filt(:,1:end-end_le));
  title('Wiener filtered dereverberated spectra','FontSize',f_size)
  print -djpeg wf_dereverb
  input('pause')
end
