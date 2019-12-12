%% Calculating Predicted Magnetisation in the z-Direction from Model Parameters and Raw Data
%%
% This function calculates an array of predicted Mz values using the
% following relation:
%%
% $$ Mz_{measurement} = Mz_{previous~measurement} \times cos(alpha \times 
% \theta)\times exp\left(-\frac{t}{T1}\right) $$
%%
% where:
%% 
% the first _Mz_ is _M0_, the initial magnetisation
%%
% T1 is the relaxation constant for the decay of hyperpolarisation
%%
% $$ \theta $$ is the estimated flip angle of the measurement
%% 
% and _alpha_ is the flip angle correction factor that converts the flip
% angle to one actually used in the experiment
%% Inputs
% _xn_: is an array in the following format: [M0 alpha T1]
%%
% _xdataf_: is an array, where the first column contains the times where the
% measurements were taken and the second column contains the estimated flip
% angles used to take the measurements
%% Output
% f: is an array of the predicted signal strength values from the inputs

function f = T1DecayFunctionMz(xn,xdataf)

    %% Calculating the Predicted Signal Strength at the First Measurement

    f = zeros(length(xdataf(:,1)),1);
    f(1) = xn(1)*exp(-1*(xdataf(1,1)/xn(3)));
    
    %% Calculating the Remaining Values of the Output Array
    
    for el = 2:length(f)
        f(el) = f(el-1)*cosd(xn(2).*xdataf(el-1,2))*exp(-1*((xdataf(el,1)-xdataf(el-1,1)))/xn(3));
    end
    
end

%% Notes
% The inputs used in the example were:
%%
% _xn_: [6949 1.3592 44.4454]
%%
% _xdataf_: [1 5; 2 5; 3 10; 4 10; 5 15; 6 15; 7 5]
%%
% The example was run by putting:
%% 
% f = T1DecayFunctionMz([6949 1.3592 44.4454],[1 5; 2 5; 3 10; 4 10; 5 15; 6
% 15; 7 5])
%%
% into the command window