%% Sticky Price Model of Endogenous Growth  
% August/Sept 2016 Update
% Includes Jaimovich-Rebelo Preferences, a simplified innovation sector, and adjustment costs
% Requires endogenous_growth_sticky_steadystate.m
% Albert SS Solver Oct 2016

close all;
do_estimate = 0; % if 0, just simulate

%===================================================================%
%                    DECLARATION OF VARIABLES                       %
%===================================================================%
var

% ENDOGENOUS VARIABLES
g            ${g}$   (long_name='Growth')  % notes ...
ZD           ${Z_D}$                       % Total Measure of Technologies (adopted or not)
lambda       ${\lambda}$                   % Adoption probability
VD           ${V_D}$                       % New innovation / technologies created this period (adopted or not)
M            ${M}$                         %
J            ${J}$                         % Value of unadopted tech
H            ${H}$                         % Value of adopted tech
PI           ${\Pi}$                       % 
ND           ${N_D}$                       % 
YDW          ${Y^W_D}$                     % New in model 4.4.1. Why is this needed? (might be needed later in the sticky price model)
YD           ${Y_D}$                       % 
CD           ${C_D}$                       % 
LAMBDA       ${\Lambda}$                   % Note Lambda(+1) = \Lambda_{t,t+1} (HOUSEHOLD STOCHASTIC DISCOUNT FACTOR)
UCD          ${U_{CD}}$                    % 
muD          ${{\mu}_{D}}$                 % 
L            ${L}$                         % 
GammaD       ${\Gamma_D}$                  % 
KD           ${K_D}$                       % 
Q            ${Q}$                         % 
ID           ${I_D}$                       % 
zeta         ${\zeta}$                     % 
SD           ${\mathcal{S}_{D}}$           % 
XD           ${X_D}$                       % 
RD           ${\mathcal{R}_{D}}$           % 

% Sticky Price Variables
mkup         ${\mathcal{M}}$               % Markup
pi           ${\pi}$                       % Inflation
pi_star      ${\pi^*}$                     % Inflation in the optimal reset price (or is it slighly different? in eqn 213, P_t-1 is not P*_t-1)
x1D          ${x_{1D}}$                    % Simplification 1 used in Optimal Reset Price
x2D          ${x_{2D}}$                    % Simplification 2 used in Optimal Reset Price
R_nom        ${R}$                         % R_t is nominal interest rate between t and t+1

% "Functions"
% Note: these are technically detrended
f_fcn             ${\left.       f\left( \cdot \right)            \right|}$
f_fcn_prime       ${\left.       f^{\prime}\left( \cdot \right)   \right|}$
g_fcn             ${\left.       g\left( \cdot \right)            \right|}$
g_fcn_prime       ${\left.       g^{\prime}\left( \cdot \right)   \right|}$;

% EXOGENOUS SHOCKS
varexo epsilon_chi    ${\epsilon}^{\chi}$;  

%=========================================================================%
%%%%                    DECLARATION OF PARAMETERS                      %%%%
%=========================================================================%
 
parameters 

% ORIGINAL PARAMETERS 
beta           $\beta$         
alpha          $\alpha$        
epsilon        $\epsilon$             % Inverse Frisch labor supply elasticity
rho            $\rho$                 % Inverse of intertemporal elasticity of substitution
delta          $\delta$               
chi            $\chi$                 % disutility of labor supply
vartheta       $\vartheta$              
gamma          $\gamma$               % weight of current consumption on JR term; indexes strength of wealth effects (0->no wealth effect (GHH), 1-> KPR prefs)
phi            $\phi$                 
eta            $\eta$                 
rhozeta        ${{\rho}_{\zeta}}$       % persistence of exogenous "innovation productivity" shock
sigmazeta      ${{\sigma}_{\zeta}}$     % size of impulse on exogenous "innovation productivity" shock
zeta_bar       ${\overline{\zeta}}$

psi_N          ${\psi_N}$               % Magnitude of N adjustment cost
psi_I          ${\psi_I}$               % Magniturde if I investment cost

% NEW PARAMETERS (STICKY PRICE)
gamma_pi       ${{\gamma}_{\pi}}$
gamma_y        ${{\gamma}_{y}}$
omega          ${\omega}$
theta          ${\theta}$

% SEPTEMBER ADDITIONS
lambda_bar     ${\bar{\lambda}}$
rho_lambda     ${\rho_\lambda}$       % 0 < rho_lambda < 1


% CALIBRATED STEADY-STATE VALUES
g_ss           ${g^{SS}}$              % Steady-state growth rate (seen in adjustment cost functions)
L_ss           ${L^{SS}}$              % Steady-state labor
lambda_ss      ${\lambda^{SS}}$        % Steady-state adoption rate
mkup_ss        ${\mkup^{SS}}$
;

%=========================================================================%
%%%%                     PARAMETERS' VALUES                            %%%%
%=========================================================================%

% CONVENTIONAL
beta    = 0.96;       % discount factor
alpha   = 0.33;       % capital share
epsilon = 0.5;        % inv Frisch
rho     = 1;          % IES
delta   = 0.1;        % capital deprec

% GROWTH
vartheta  = 2.4925; % elast. of subst. across varieties (mkup = vartheta/(vartheta-1)
gamma     = 0.90;   % Jaimovich-Rebelo term on preferences (0-> no wealth effect)
phi       = 0.90;   % Survival rate of technologies
eta       = 0.25;   % elasticity of innovations to R&D
rho_lambda= 0.80;   % elasticity of adoption prob. to adoption expenditure

% NEW VARIABLES - sticky price part
gamma_pi = 1.5;
gamma_y  = 0.1;
theta    = 0.75;
omega    = 4.167;                  %  Markup. In the flex price model, markup is exogenous and given by M = ?/(? ? 1). I took this numbers from Gertler-Karadi �a model of unconventional monetary policy??, who take them from estimates by Primiceri et al

psi_I    = 1;                      %  Adjustment cost to Inv
psi_N    = 10;                     %  Adjustment cost to N

% steady-state values of endogenous variables:
g_ss      = 1.0118; %1.02; % calibrate g (growth rate); back out zeta_bar
lambda_ss = 0.15;   %0.15; % calibrate lambda (adoption probability); back out lambda_bar
L_ss      =  2;        % calibrate SS L; back out chi 
mkup_ss   = omega/(omega-1);

% need to back out: zeta_bar, lambda_bar, chi -> set in steady-state file

% AR(1) parameters for zeta shock (productivity of R&D)
rhozeta    = 0.90;
sigmazeta  = 0.50;
% rhozeta    = 0.4;
% sigmazeta  = 2;

%% Estimation Results 

% 1) Attempt to Match R&D Only
% RD_Almost_Perfect_Fit.pdf
% eta = 0.6377034476;
% phi = 0.959998326;
% lambda_ss = 0.4999995261;
% psi_N = 1.199560391;
% rhozeta = 0.8771009836;
% sigmazeta = 0.1949092608;
% gamma = 0.8976501214;
% rho_lambda = 0.2997568403;

% 2) Pretty good match of both
% But TFP increases too much
% eta = 0.6962027055;
% phi = 0.9942372411;
% lambda_ss = 0.1000000012;
% psi_N = 0.5199199482;
% rhozeta = 0.9899;
% sigmazeta = 0.1279661829;
% gamma = 0.9099;
% rho_lambda = 0.2997568403;

% Plot 1
% Attempt to Match TFP Only
% eta = 0.95;
% phi = 0.9587878475;
% lambda_ss = 0.7;
% psi_N = 50;
% rhozeta = 0.0001;
% sigmazeta = 0.2094361245;
% gamma = 0.91;
% rho_lambda = 0.9266736473;

% Attempt to Match TFP (weight=1) and R&D (weight = 0.3) with 11 periods
% eta = 0.9;
% phi = 0.999;
% lambda_ss = 0.5;
% psi_N = 3.132485312;
% rhozeta = 0.4655720529;
% sigmazeta = 0.2647972323;
% gamma = 0.03725332262;
% rho_lambda = 0.01;

% Estimate 2
% Attempt to Match TFP (weight=1) and R&D (weight = 0.3) with 11 periods
% wider bounds on params
% maxit of 800 reached
eta = 0.95;
phi = 0.9999;
lambda_ss = 0.195651203;
psi_N = 4.340377426;
rhozeta = 0.5913817911;
sigmazeta = 0.2706380004;
gamma = 0.04593762978;
rho_lambda = 0.001;


%=========================================================================%
%%%%                     EQUILIBRIUM CONDITIONS                        %%%%
%=========================================================================%

model;
%=========================ENDOGENOUS VARIABLES============================%
% 1. Evolution of number of firm varieties
g = lambda * phi * (ZD-1) + phi;

% 2. Evolution of technological frontier Z
ZD * g(-1) = phi * ZD(-1) + VD(-1);

% 3. Innovators' production function. Q: Why is this not the supply curve of new firms?
VD = zeta_bar * zeta * ZD * (ND * g(-1) / KD(-1))^eta;

% 4. Euler equation for entrepreneurs
J = -M + phi * LAMBDA(+1) * (lambda*H(+1) + (1-lambda)*J(+1)   );

% 5. Price of adopted technology H
H = PI + phi * ( LAMBDA(+1) * H(+1) );

% 6. Profits per period
PI = (1/vartheta) * (1/mkup) * YDW;

% 7. Innovators' FOC wrt N
LAMBDA(+1) * J(+1) * zeta_bar * zeta * ZD * (1 /  (KD(-1)/g(-1))^eta)   * (1 / ND^(1-eta) ) =  1 + log(f_fcn_prime) *  (ND * g(-1) /  ND(-1)) +  log(f_fcn) - LAMBDA(+1) * log(f_fcn_prime(+1)) * (ND(+1) * g / ND )^2;

% 8. Adopters' FOC
rho_lambda * lambda_bar * phi * LAMBDA(+1) * (H(+1) - J(+1)) = M ^ (1 - rho_lambda);

% 9. Adoption Probability:
lambda = lambda_bar * M ^ rho_lambda;

% 10. Aggregate production function
YD = YDW;

% 11. Aggregate production function W
YDW = ((KD(-1) / g(-1))^alpha) * L^(1-alpha);

% 12. Resource constraint, with adjustment cost
YD = CD + (1 + log(g_fcn)) * ID + (1 + log(f_fcn)) * ND + (ZD-1)*M;

% 13. HH's stochastic discount factor
LAMBDA = ((beta * UCD) / UCD(-1)) * g(-1)^(-rho);

% 14. Marginal utility of consumption
% Modifed such that muD is positive
UCD = ( CD - GammaD * ( chi / (1+epsilon)) * L^(1+epsilon) ) ^ (-rho) + -1*muD * gamma * (GammaD(-1) / ( CD * g(-1) )) ^ (1-gamma);

% 15. Lagrange multiplier on labor disutility law of motion (new)
% Modifed such that muD is positive
muD   = beta * (1-gamma) * ( g^(-rho) * muD(+1) * (CD(+1) * g/ GammaD)^gamma ) + ((CD - GammaD*( chi / (1+epsilon)) * L^(1+epsilon))^(-rho)) * ( chi / (1+epsilon)) * L^(1+epsilon);

% 16. Labor market equilibrium
chi * GammaD * L^epsilon * (1/UCD) * (CD - GammaD * ( chi / (1+epsilon)) * L^(1+epsilon))^(-rho) = (1/mkup) * ((vartheta - 1)/vartheta) * (1 - alpha) * (YD/L);

% 17. Labor disutility term
GammaD = (CD^gamma) * ( GammaD(-1) / g(-1) )^(1-gamma);

% 18. Capital evolution
KD = (1-delta) * (KD(-1) / g(-1)) + ID ;

% 19. Q-equation (capital producers)
Q = 1 + log(g_fcn) + ((ID * g(-1)) / ID(-1)) * log(g_fcn_prime) - LAMBDA(+1) * ((ID(+1) * g) / ID)^2 * log(g_fcn_prime(+1));

% 20. Equation 263. Capital Euler Equation
Q = LAMBDA(+1) * ((g* (vartheta - 1) *YDW(+1) * alpha)/(mkup * KD * vartheta) + Q(+1) * (1 - delta));

% 21. Exogenous shock to entrepreneurs' production function
log(zeta) = rhozeta * log(zeta(-1)) + sigmazeta * epsilon_chi;

% 22. Stock market value (taken directly from May model)
SD = Q * KD + H  +  J * ( ZD + VD - 1 )  + XD;

% 23. 
XD =  ( LAMBDA(+1) * g * ( J(+1) * VD(+1) + XD(+1) ) );
 
% 24. Aggregate R&D expenditure [ (albert) in this model, R&D expenditures
% are given by the variable N)
RD = ND;   
 
%====================== ADJUSTMENT COST FCNS =============================%
f_fcn = exp( (psi_N / 2) * ((ND * g(-1) / ND(-1) ) - g_ss)^2 ); % 22
f_fcn_prime = exp( psi_N * ((ND * g(-1) / ND(-1) ) - g_ss)   ); % 23
g_fcn = exp( (psi_I / 2) * ((ID * g(-1) / ID(-1) ) - g_ss)^2 ); % 24
g_fcn_prime = exp( psi_I * ((ID * g(-1) / ID(-1) ) - g_ss)   ); % 25

%=========================STICKY PRICE EQNS===============================%

% 26. Pricing Equation
pi ^(1-omega) = theta + (1-theta)*pi_star^(1-omega);
% 27. Optimal Pricing Equation 
pi_star = (omega / (omega - 1)) * (x1D / x2D) * pi;
% 28, 29. Simplifications used in the Optimal Pricing Equation
x1D = UCD * (1/mkup) * YD + beta * theta * g^(1-rho) * pi(+1)^omega * x1D(+1);
x2D = UCD * YD + beta * theta * g^(1-rho) * pi(+1)^(omega-1) * x2D(+1);
% 30. Euler Equation
1 = LAMBDA(+1) * R_nom / pi(+1);
% 31. Taylor Rule
R_nom / ( (beta*g_ss^(-rho))^(-1) ) = pi ^ gamma_pi * (  (1/mkup) / (1/mkup_ss)   )^gamma_y;

end;

write_latex_dynamic_model;
write_latex_static_model;

%=========================================================================%
%%%%                       RUN                                         %%%%
%=========================================================================%

% Load PVAR IRFs
global pvarcoirfs_clean;
% load 'pvar_coirfs_full'; % has 10 periods of data. pvar with gdp first
load 'pvar_coirfs_full_30periods_tfp_first' % has 30 periods of data. pvar with tfp first
pvarcoirfs_clean = pvarcoirfs;

shocks;
var epsilon_chi;
stderr 1;
end;

% Setup counters
COUNT.total = 0;
COUNT.ss_found = 0;
COUNT.ss_notfound = 0;
COUNT.ss_neg = 0;

% Set seed for simulation
% set_dynare_seed(092677);

estimation_init;

% This saves everything, which is then called in each loop
evalin('base','save level0workspace oo_ M_ options_')

steady;
check;

% Produce simulation using above calibration, compare with VAR IRFs
% NOTE: loglinear option causes oo_.steady_state to become logged
stoch_simul(order=1,periods=600, irf=31, nograph, nodisplay, nocorr, nomoments, loglinear);

post_processing_irfs;                                                       % Create IRFs with trend
plot_var_irfs;                                                              % Plot VAR IRFs
post_processing_irfs_plot;                                                  % Plot IRFs
post_processing_irfs_distance;                                              % Compute distance between model and VAR IRFs
steady_state_targets

%=========================================================================%
%%%%                       SIMULATED SERIES                            %%%%
%=========================================================================%

% Clear out the loglinear dr
load level0workspace oo_ options_

% Produce simulated series WITHOUT the loglinear command
stoch_simul(order=1,periods=1000, irf=31, nograph, nodisplay, nocorr, nomoments, noprint);

% Collect the key series
g_simul = oo_.endo_simul(1,:);
RD_simul = oo_.endo_simul(24,:);
YD_simul = oo_.endo_simul(11,:);

% Compute TFP (using a cumulative product of g)
A_lead = cumprod(g_simul);
A_simul = ones(size(A_lead));
A_simul(2:end) = A_lead(1:end-1);

% Multiply this trend with R_D and Y_D
R_simul = RD_simul .* A_simul;
Y_simul = YD_simul .* A_simul;

%=========================================================================%
%%%%                     PLOT SIMULATED SERIES                         %%%%
%=========================================================================%

% Plot
length = 300;
figure();
subplot(2,2,1);
plot(R_simul(:,1:length));
title('R');

subplot(2,2,2);
plot(A_simul(:,1:length));
title('A');

subplot(2,2,3);
plot(Y_simul(:,1:length));
title('Y');

% Output to a csv
SimulData = [A_simul', R_simul', Y_simul'];
csvwrite('Data_A_R_Y.csv', SimulData);

% Sanity check: these are all equal to the steady state values
% mean(YD_simul);
% mean(g_simul);
% mean(RD_simul);
    
%=========================================================================%
%%%%                       OPTIMIZATION                                %%%%
%=========================================================================%

if do_estimate == 0;
    return;
elseif do_estimate == 1

% IMPORTANT: Estimation variables should be changed in estimation_init.m

% Starting point (based on earlier calibration)
select_start_point;
check_bounds;

% Optimizer options
H0 = 1e-2*eye(length(x_start)); % Initial Hessian 
H0 = 1e-1*eye(length(x_start)); % Initial Hessian 
% H0 = 1*eye(length(x_start)); % Initial Hessian 

crit = 1e-7; % Tolerance
nit = 1000; % Number of iterations
% nit = 800;
 
nit = 100;
% nit = 20;

% Make sure Dynare does not print out stuff during runs
options_.nocorr=1;
options_.noprint=1;
options_.verbosity=0;

% options_.qz_criterium = 1+1e-6; % required because it is empty by default, leading to a crash in k_order_pert
[fhat, params_unbounded] = csminwel(@distance_fcn     ,x_start_unbounded,H0,[],crit,nit);
%                          csminwel(fcn               ,x0,H0,grad,crit,nit,varargin)

fhat

%=========================================================================%
%%%%                       ALT ESTIMATION                              %%%%
%=========================================================================%
elseif do_estimate == 2
        
    % Starting point (based on earlier calibration)
    select_start_point;
    check_bounds;
    
    opts = psoptimset('Display','diagnose', 'InitialMeshSize', 3, 'MaxIter', 1200); % debugging % , 'MaxIter', 20
    % opts = psoptimset('Display', 'off'); % estimation
    [params_unbounded, FVAL,EXITFLAG,Output] = patternsearch(@distance_fcn, x_start_unbounded,[],[],[],[],[],[],[],opts)

%=========================================================================%
%%%%                    MULTI START ESTIMATION                         %%%%
%=========================================================================%
elseif do_estimate == 3

    
    fhat = 301;
    while fhat > 300
        % Starting point (based on earlier calibration)
        x_start = [eta, phi, lambda_ss, rhozeta, sigmazeta]; % gamma, psi_N, rhozeta, sigmazeta, rho_lambda

        %% Select random start
        % Search until I find an inital guess that solves
        dist_guess = 1e+10;
        while dist_guess >= 1e+10
            % Generate guess along uniform [0,1] then scale based on bounds
            rand_guess;
            guess
            x_start_unbounded = boundsINV(guess);
            
            % original way of guessing x0
            % x_start_unbounded = randn(size(x_start));
            % x_start_unbounded(5) = -1.1180e+03;
            
            dist_guess = distance_fcn(x_start_unbounded)
        end
        
        disp('========================New Guess============================')
        bounds(x_start_unbounded)

        % Optimizer options
        H0 = 1e-1*eye(length(x_start)); % Initial Hessian 

        crit = 1e-7; % Tolerance
        nit = 1000; % Number of iterations
        % nit = 800;

        % nit = 20;
        nit = 50;
        
        [fhat, params_unbounded] = csminwel(@distance_fcn     ,x_start_unbounded,H0,[],crit,nit);
        fhat
    end
end

%=========================================================================%
%%%%                       PLOT SOLUTION                               %%%%
%=========================================================================%
if do_estimate > 0
    load level0workspace oo_ options_
    
    % Set parameters using set_param_value()
    [ params ] = bounds( params_unbounded );
    variables = options_.EST.variables;
    for iii = 1:length( variables )
        set_param_value( char(variables( iii )) , params( iii ) );
    end
    
    options_.nocorr = 1;
    options_.nograph = 1;
    options_.nomoments = 1;
    options_.order = 1;
    
    options_.periods = 600;
    options_.irf = options_.EST.irf_length;
    options_.loglinear = 1;
    options_.nodisplay = 0;
    options_.noprint = 0;

    steady;

    var_list_=[];
    info = stoch_simul(var_list_);                                              % WARNING: this does not compute the steady state. It just uses the pre defined ss
    post_processing_irfs;                                                       % Create IRFs with trend
    post_processing_irfs_plot;                                                  % Plot IRFs
    axis tight;
    % post_processing_irfs_distance;                                              % Compute distance between model and VAR IRFs
    legend('initial','var', 'b', 'b', 'final');

    % disp('[eta, phi, lambda_ss]')
    % params
    % x_start

    % Print Estimation Results
    disp(sprintf('\nEstimation Results:'));
    for iii = 1:length( variables )
        disp(sprintf([char(variables( iii )), ' = %0.10g;'], params(iii) ));
    end

    steady_state_targets

end
