function [input,pls_opts] = myPLS_analysis_initialize(input,pls_opts)

% function to set up the defaults and to check for valitidy of inputs for
% the function myPLS_analysis 

disp('... Initialization ...')


%% 1. inputs
% compatibility with X0 and Y0 inputs
if ~isfield(input,'brain_data') && isfield(input,'X0')
    input.brain_data=input.X0;
elseif ~isfield(input,'brain_data') && ~isfield(input,'X0')
    error('brain data input missing');
end
if ~isfield(input,'behav_data') && isfield(input,'Y0')
    input.behav_data=input.Y0;
elseif ~isfield(input,'behav_data') && ~isfield(input,'Y0')
    error('behavior data input missing');
end

% Check that dimensions of X & Y are correct
if(size(input.brain_data,1) ~= size(input.behav_data,1))
    error('Input arguments X and Y should have the same number of rows');
end


% number and IDs of groups
groupIDs=unique(input.grouping);
nGroups=length(groupIDs);
% number of behavior scores
nBehav=size(input.behav_data,2);

% create defaults for group and behavior names, if not specified
if ~isfield(input,'group_names') || isempty(input.group_names)
    input.group_names=cell(nGroups,1);
    for iG=1:nGroups
        input.group_names{iG}=['group ' num2str(groupIDs(iG))];
    end
end
if ~isfield(input,'behav_names') || isempty(input.behav_names)
    input.behav_names=cell(nBehav,1);
    for iB=1:nBehav
        input.behav_names{iB}=['behavior ' num2str(iB)];
    end
end


%% 2. options
% default analysis type: behavior PLS
if ~isfield(pls_opts,'behav_type') || isempty(pls_opts.behav_type)
    pls_opts.behav_type='behavior';
elseif ~(strcmp(pls_opts.behav_type,'behavior') || ...
        strcmp(pls_opts.behav_type,'contrast') || ...
        strcmp(pls_opts.behav_type,'contrastBehav') || ...
        strcmp(pls_opts.behav_type,'contrastBehavInteract'))
    error('Invalid behav_type selected')
end

% set up defaults for PLS grouping
if ~isfield(pls_opts,'grouped_PLS')
    disp('PLS grouping not specified, falling back to defaults:')
    if contains(pls_opts.behav_type,'contrast')
        pls_opts.grouped_PLS=0;
        disp('   PLS includes contrast --> PLS without consideration of groups')
    else
        pls_opts.grouped_PLS=1;
        disp('   PLS without contrast --> PLS under consideration of groups')
    end
end

% check if normalization is compatible with contrast PLS
if contains(pls_opts.behav_type,'contrast')
    if pls_opts.normalization_behav==2 || pls_opts.normalization_behav==4 || ...
            pls_opts.normalization_img==2 || pls_opts.normalization_img==4
        error('Normalization within groups selected, but contrast in Y -> please change normalization to be done across all subjects!')
    end
    if pls_opts.grouped_PLS==1
        error('Grouped PLS selected, but contrast in Y --> please change grouped_PLS variable to 0!')
    end
end


% set up defaults for permutation/bootstrapping grouping
if ~isfield(pls_opts,'grouped_perm') || isempty(pls_opts.grouped_perm)
    disp('Permutations grouping not specified, falling back to defaults:')
    if contains(pls_opts.behav_type,'contrast')
        pls_opts.grouped_perm=0;
        disp('   PLS includes contrast --> Permutations without consideration of groups')
    else
        pls_opts.grouped_perm=1;
        disp('   PLS without contrast --> Permutations under consideration of groups')
    end
end
if ~isfield(pls_opts,'grouped_boot') || isempty(pls_opts.grouped_boot)
    disp('Permutations grouping not specified, falling back to defaults:')
    if contains(pls_opts.behav_type,'contrast')
        pls_opts.grouped_boot=0;
        disp('   PLS includes contrast --> Bootstrapping without consideration of groups')
    else
        pls_opts.grouped_boot=1;
        disp('   PLS without contrast --> Bootstrapping under consideration of groups')
    end
end
% compatibility check for grouping in PLS/Permutations/Bootstrapping
if pls_opts.grouped_boot~=pls_opts.grouped_perm
    disp('!!! grouping option for permutations and bootstrapping not identical - make sure that this is what you would like to do!')
end
if pls_opts.grouped_PLS~=pls_opts.grouped_perm
    disp('!!! Grouping option for PLS and permutations not identical - make sure that this is what you would like to do!')
end

% set up defaults for Procrustes computation in bootstrapping
if ~isfield(pls_opts,'boot_procrustes_mod') || isempty(pls_opts.boot_procrustes_mod)
    disp('Procrustes computation mode for bootstrapping not specified, falling back to default:')
    pls_opts.boot_procrustes_mod=1;
    disp('   Computation of Procrustes transform only using U (behavior saliences)')
end
if pls_opts.boot_procrustes_mod~=1 && pls_opts.boot_procrustes_mod~=2
    error('Invalid value in pls_opts.boot_procrustes_mod -> please set to either 1 or 2');
end

disp(' ')

