%% Estimation
% Run the mod file, set the estimation options, then perform estimation
clear; clc;

%=========================================================================%
%%%%                           RUN DYNARE                              %%%%
%=========================================================================%

% Note: if you change the calibration, you must run the mod file again
% dynare endogenous_growth_sticky.mod;
load level0workspace oo_ options_ M_

%=========================================================================%
%%%%                       ESTIMATION OPTIONS                          %%%%
%=========================================================================%

% 1. Algorithm
% 1 = csminwel, 2 = patternsearch
use_algorithm = 2; 

% 2. Number of iterations
maxit = 200;

% 3. Which parameters to estimate
options_.EST = [];
options_.EST.variables = {'eta', 'alpha_N', 'psi_N', 'rhon'}; 

% 4. Starting values
eta = 0.08303187684;
alpha_N = 0.009623755187;
psi_N = 25.08490715;
rhon = 0.8044297245;

% 5. Parameter bounds
% Note: if a parameter is not being used in estimation, the bounds are just ignored
options_.EST.LB.eta = 0.05;  
options_.EST.UB.eta = 0.35;  

options_.EST.LB.alpha_N = 0.001;  
options_.EST.UB.alpha_N = 0.02;  

options_.EST.LB.psi_N = 1;  
options_.EST.UB.psi_N = 75;  

options_.EST.LB.rhon = 0.5;
options_.EST.UB.rhon = 0.95;

options_.EST.LB.phi = 0.7;
options_.EST.UB.phi = 0.999;

options_.EST.LB.lambda_ss = .1; 
options_.EST.UB.lambda_ss = 0.5;

options_.EST.LB.gamma = 0.00001;
options_.EST.UB.gamma = 1; 

options_.EST.LB.rho_lambda = .01;
options_.EST.UB.rho_lambda = .99;

% 6. Weight the impulse responses used in estimation
% Select weights between [0,1]
% 0 = ignore this IRF in the objective function

options_.EST.weight_rd = 0;
options_.EST.weight_tfp = 1;

% 7. IRF Length (can choose between 11 and 31)
options_.EST.irf_length = 11; 

%=========================================================================%
%%%%                PLOT PVAR IRF and INITIAL GUESS                    %%%%
%=========================================================================%
% Save estimation options (for use in loop)
save level0workspace oo_ options_ M_

% Load PVAR IRFs
close all;
addpath('Scripts');
plot_var_irfs;

% Starting point
estimation_init;
select_start_point;
check_bounds;

[ params ] = bounds( x_start_unbounded );
run_model;
post_processing_irfs; 
post_processing_irfs_plot; 

%=========================================================================%
%%%%                       OPTIMIZATION                                %%%%
%=========================================================================%
    
if use_algorithm == 1
    
    % Optimizer options
    H0 = 1e-2*eye(length(x_start)); % Initial Hessian
    H0 = 1e-1*eye(length(x_start)); % Initial Hessian
    crit = 1e-7; 					% Tolerance
    
    % options_.qz_criterium = 1+1e-6; % required because it is empty by default, leading to a crash in k_order_pert
    [fhat, params_unbounded] = csminwel(@distance_fcn, x_start_unbounded, H0,[],crit,maxit); fhat

%=========================================================================%
%%%%                       ALT ESTIMATION                              %%%%
%=========================================================================%
elseif use_algorithm == 2
        
    % Starting point
    select_start_point;
    check_bounds;
    
    opts = psoptimset('Display','diagnose', 'InitialMeshSize', 3, 'MaxIter', maxit); 	% Noisy
    % opts = psoptimset('Display', 'off'); 												% Quiet
    [params_unbounded, FVAL,EXITFLAG,Output] = patternsearch(@distance_fcn, x_start_unbounded,[],[],[],[],[],[],[],opts)
end

%=========================================================================%
%%%%                       PLOT SOLUTION                               %%%%
%=========================================================================%
load level0workspace oo_ options_

% Set parameters using set_param_value()
[ params ] = bounds( params_unbounded );
run_model;
post_processing_irfs; 
post_processing_irfs_plot; 

% Plot Details
axis tight;
legend('pvar ub','pvar lb', 'pvar irf', 'initial guess', 'final guess');

% Print Estimation Results
disp(sprintf('\nEstimation Results:'));
for iii = 1:length( variables )
    disp(sprintf([char(variables( iii )), ' = %0.10g;'], params(iii) ));
end

steady_state_targets;