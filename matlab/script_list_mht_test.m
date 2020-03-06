
% Parameter setup
%--------------------------------------------------------------------------
rng('default');

n_treatments = 3;
n_subgroups = 2;
n_obs_per_cell = 10^2;
n_boot = 10^3;

error_mean = 4;

% Simulate Data
%--------------------------------------------------------------------------
n_obs = n_treatments*n_subgroups*n_obs_per_cell;

Z = kron((1:n_subgroups)', ones(n_obs_per_cell*n_treatments, 1));
D = repmat((0:n_treatments-1)', [n_obs_per_cell*n_subgroups, 1]);
errors = error_mean*randn(n_obs,1);

Y = D + Z + errors;

% Calculate p_values
%--------------------------------------------------------------------------

R = [[0,1,1,1];
     [0,2,1,1];     
     [0,1,2,1];
     [0,2,2,1]];
 
[difference_absolute_og_vector, p_values_single, p_value_multi] = mht.calculate(R, Y, D, Z, n_boot);
