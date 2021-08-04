// This code finds the optimal share of bonds in a portfolio split between bonds and equity
//Written by M. Hatcher: http://www.michael-hatcher.co.uk
//The model is a simple OLG world where young generations get welfare 
//from holding bonds and equity from the end of youth into old age
//and a social planner chooses the mix of assets to maximise unconditional expected utility
//Short selling is not feasible, so the optimal share must lie in the range [0,1]

//To run this file in Dynare, simply type 'dynare simple_portfolio_problem.mod' and press ENTER
//A figure plotting welfare against the portfolio share of bonds is generated automatically

//-----------------------------------------
//1. Variable declaration and calibration
//-----------------------------------------

var co, rb, rs, exp_utility, x;
varexo e, u;

parameters SHAREB SIGMAE SIGMAU RHO;

SHAREB = 0.50;
SIGMAE = 0.02;
SIGMAU = 0.06; 
RHO = 3;  //Coef of relative risk aversion

//--------------------------------
//2. Model
//--------------------------------

model;

//Total portfoilo is x = b + s;

x = 1;

//Return on bonds

rb = 1 + 0.02 + e;

//Return on equity

rs = 1 + 0.028 + u;

//Consumption when old

co = (SHAREB*rb + (1-SHAREB)*rs)*x;

//Expected utility when old (CRRA utility and no discounting)

exp_utility = (1/(1-RHO))*co(+1)^(1-RHO);

//Focus below on simulated mean to proxy unconditional mean across generations

end;

//----------------------------------------
//3. Initial values and shock calibration
//----------------------------------------

initval;
x = 1;
co = 1.024;
rb = 1.02;
rs = 1.028;
exp_utility = (1/(1-RHO))*co^(1-RHO);
end;

steady;

shocks;
var e; stderr SIGMAE;
var u; stderr SIGMAU;
var e,u = 0.0001;  //this implies a correlation just under 0.10
end;

stoch_simul(order=2, drop=0, periods = 2000, simul_seed = 1000, irf=0, noprint);

//------------------------------------------
//4. Welfare analysis using loops
//------------------------------------------ 

Stack_exp_utility = [];
Stack_shareb = [];

deltas = 0:0.01:1; 
//declares 'step size' and parameter range for welfare calculation

//IN ORDER TO MAXIMISE A UTILITARIAN SWF USING INDIVIDUAL UTILITIES
for i=1:length(deltas);
SHAREB = deltas(i);
stoch_simul(order=2, drop=0, periods = 2000, simul_seed = 1000, irf=0, noprint); 
Stack_exp_utility = [Stack_exp_utility; oo_.mean(2)]; 
Stack_shareb = [Stack_shareb; SHAREB];
end;

//IN ORDER TO MIN A SOCIAL LOSS FUNCTION OF THE FORM L = var(co)
//for i=1:length(deltas);
//SHAREB = deltas(i);
//stoch_simul(order=2, drop=0, periods = 2000, simul_seed = 1000, irf=0, noprint); 
//Stack_exp_utility = [Stack_exp_utility; oo_.var(1,1)]; 
//Stack_shareb = [Stack_shareb; SHAREB];
//end;

//IN ORDER TO MAX AN INEQUALITY-NEUTRAL SWF, W = mean(co) 
//i.e. max expected return across generations
//for i=1:length(deltas);
//SHAREB = deltas(i);
//stoch_simul(order=2, drop=0, periods = 2000, simul_seed = 1000, irf=0, noprint); 
//Stack_exp_utility = [Stack_exp_utility; oo_.mean(1)]; 
//Stack_shareb = [Stack_shareb; SHAREB];
//end;

hold on 
plot(Stack_shareb, Stack_exp_utility);
hold off
xlabel('Share of bonds in portfolio');
ylabel('Social Welfare');