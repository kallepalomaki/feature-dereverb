function [data, rate, kind] = hcopy(config, file, stime, etime)
% HCOPY Run HTK HCopy to extract features.
%
%   [DATA, RATE, KIND] = HCOPY(CONFIG, FILE) uses the HTK HCopy tool
%   to perform feature extraction on FILE using the configuration
%   CONFIG.  See documentation of the HTK_READ function on the
%   outputs.  CONFIG can be a string or a cell array of strings; all
%   files will be passed as -C arguments to HCopy.
%
%   ... = HCOPY(CONFIG, FILE, STIME, ETIME) extracts only the region
%   between the times STIME and ETIME, expressed as seconds from start
%   of file.
%
% Copyright (c) 2014, Kalle Palomaki and Heikki Kallasjoki
% All rights reserved.
% See the included README.txt for full license terms.

cfg = getcfg();

cmd = [cfg.htkbin '/HCopy'];

if ~iscell(config)
    config = {config};
end
for i = 1:length(config)
    cmd = [cmd ' -C "' config{i} '"'];
end

if nargin >= 4
    cmd = [cmd ' -s ' num2str(stime*1e7) ' -e ' num2str(etime*1e7)];
end

tmp = tempname(cfg.tempdir);
cmd = [cmd ' "' file '" "' tmp '"'];

[status, out] = system(cmd);

if status ~= 0
    cmd
    error('hcopy:system', 'HCopy error', out);
end

[data, rate, kind] = htk_read(tmp);
delete(tmp);
