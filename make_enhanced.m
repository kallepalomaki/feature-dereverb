% make_enhanced.m
% Generate enhanced features for REVERB challenge.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

%% Settings

do_plot=1;


if flag_aalto_internal==1                            
   name_list_clean=[cfg.in_root '/flists/audio_SimData_et_for_cln_room3.lst'];
   name_list=[cfg.in_root '/flists/audio_SimData_et_for_1ch_far_room3_A.lst'];
   % matlab script to run htk's hcopy to make features
   fextractf=@(inputpath) fextract_htk(inputpath);
   cfg = getcfg();
   outbase = '/akulabra/projects/T40511/kpalomak/reverb-challenge/db/enh'
 
elseif flag_aalto_internal==0
   name_list_clean='test_list_clean.txt';
   name_list='test_list.txt';
   % matlab script to make features
   fextractf=@(inputpath) fextract(inputpath);
   outbase = './data/enh';
end

[list_clean]=textread(name_list_clean,'%s%*[^\n]');
[list]=textread(name_list,'%s%*[^\n]');

method_id='rev_to_web';

% number of audio files to processed
nfiles = length(list);
% Process all files
Feats_fullbatch_ini=[];
Feats_fullbatch=[];

% load spectral weights and pca coefficients pre-trained using clean speech
load wei_mean_clean
load pca_coeff

% parameter settings
params.pca_coeff=coeff;
params.wei_clean=wei_clean;
params.mX=mX;
params.sX=sX;
params.dim_stack=20;
params.dim_pca=40;
dim_stack=params.dim_stack;
dim_pca=params.dim_pca;

% collect and apply spectral normalization for the reverberant over 
% the full the batch length
for fidx = 1:nfiles          
  inpath = list{fidx};
  % extraction of spectral features
  [feats_0, frate] = fextractf(inpath);
  % channel by shannel meannormalization according Palomäki et al. 2004
  [feats_0_mn,wei_fea]=meannorm(feats_0,5,ones(size(feats_0,1),size(feats_0,2)));
  for cnt_ch=1:size(feats_0,1)
     feats_0(cnt_ch,:)=feats_0_mn(cnt_ch,:)*wei_clean(cnt_ch);
  end
  Feats_fullbatch_ini=[Feats_fullbatch_ini feats_0];
end

% construct posterior sample for distribution mapping for first iteration
X_rev_fullbatch=wstack(log(Feats_fullbatch_ini),dim_stack)';
X_rev_fullbatch=bsxfun(@rdivide, bsxfun(@minus, X_rev_fullbatch, mX), sX);
% transform posterior sample to pca-domain
H_rev_global_0=X_rev_fullbatch*coeff(:,1:dim_pca);

for cnt_rnd=1:2
  for fidx = 1:nfiles
    fprintf(1, '%s (%d/%d)\n', inpath, fidx, nfiles);        
    inpath = list{fidx};
    inpath_clean=list_clean{fidx};%strrep(inpath,'-rev','');

    % extraction of spectral features
    [feats_clean, frate] = fextractf(inpath_clean);
    [feats, frate] = fextractf(inpath);
        
    params.normaliz(1)=1;
    params.normaliz(2)=0;
    [enh_0]= dereverb_spegram(feats, H_rev_global_0, X_pca, params);

    % collect enhanced features of the whole batch length
    % for the next round posterior sample
    if cnt_rnd==1;
      Feats_fullbatch=[Feats_fullbatch enh_0];
    end

    if cnt_rnd==2
      params.normaliz(1)=0;
      params.normaliz(2)=0;
      [enh]= dereverb_spegram(enh_0, H_rev_global, X_pca, params);
    end
    
    % Save enhanced features    
    outpath = [outbase '/' method_id];
    [outdir, dummy, dummy] = fileparts(outpath);
    [dummy, outfile, dummy]=fileparts(inpath);
    outpath = [outdir '/' outfile '.mel'];
        
    [~,~,~] = mkdir(outdir);    
    if cnt_rnd==2
      nchans = size(enh, 1);
      fbank = log(enh + exp(-700));
      mfnorm = sqrt(2.0 / nchans);
      fbank = [fbank; mfnorm * sum(fbank, 1)];
      fprintf(1, 'outpath %s\n', outpath);
      if flag_aalto_internal
        htk_write(outpath, fbank, frate, 'FBANK_0');  
      end
      min_siz=min([size(feats,2) size(feats_clean,2)]);
 
      % plot some of the features in the reverb-workshop poster
      if do_plot==1 
        f_size=14;
        figure(10)
        subplot(3,1,1)
        imagesc(log(enh(:,1:min_siz)))
        title('dereverberated','FontSize',f_size)
        subplot(3,1,2)
        imagesc(log(feats_clean(:,1:min_siz)))
        title('clean','FontSize',f_size)
        subplot(3,1,3)
        imagesc(log(feats(:,1:min_siz)))
        title('reverberant','FontSize',f_size)
        print -djpeg dereverb_clean_reverb
        input('pause');
      end
    end
  end
  % construct posterior sample for distribution mapping for the second 
  % iteration
  X_rev_fullbatch=wstack(log(Feats_fullbatch),dim_stack)';
  X_rev_fullbatch=bsxfun(@rdivide, bsxfun(@minus, X_rev_fullbatch, mX), sX);
  % transform posterior sample to pca-domain
  H_rev_global=X_rev_fullbatch*coeff(:,1:dim_pca);
end

