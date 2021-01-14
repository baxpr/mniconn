function conncompute(roidata,fmri_nii,out_dir,tag,connmaps_out)

%% Connectivity matrix
R = corr(table2array(roidata));
Z = atanh(R) * sqrt(size(roidata,1)-3);
R = array2table(R);
Z = array2table(Z);
R.Properties.VariableNames = roidata.Properties.VariableNames;
R.Properties.RowNames = roidata.Properties.VariableNames;
Z.Properties.VariableNames = roidata.Properties.VariableNames;
Z.Properties.RowNames = roidata.Properties.VariableNames;
writetable(R,fullfile(out_dir,['R_' tag '.csv']),'WriteRowNames',true);
writetable(Z,fullfile(out_dir,['Z_' tag '.csv']),'WriteRowNames',true);


%% Connectivity maps

% Don't actually make maps unless requested
if ~strcmp(connmaps_out,'yes'), return, end

connmap_dir = [out_dir '/connmaps'];
if ~exist(connmap_dir,'dir')
	mkdir(connmap_dir);
end

% Load fmri
Vfmri = spm_vol(fmri_nii);
Yfmri = spm_read_vols(Vfmri);
osize = size(Yfmri);
rYfmri = reshape(Yfmri,[],osize(4))';

% Compute connectivity maps
Rmap = corr(table2array(roidata),rYfmri);
Zmap = atanh(Rmap) * sqrt(size(roidata,1)-3);

% Save maps to file, original and smoothed versions
for r = 1:width(roidata)

	Vout = rmfield(Vfmri(1),'pinfo');
	Vout.fname = fullfile(connmap_dir, ...
		['Z_' roidata.Properties.VariableNames{r} '_' tag '.nii']);
	Yout = reshape(Zmap(r,:),osize(1:3));
	Vout = spm_write_vol(Vout,Yout);
	
%	sfname = fullfile(conn_dir, ...
%		['sZ_' roidata.Properties.VariableNames{r} '_' tag '.nii']);
%	spm_smooth(Vout,sfname,str2double(fwhm));
	
end

