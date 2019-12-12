%% Calculating Polarisation at Thermal Equilibrium
%%
% Polarisation at thermal equilibrium can be described by:
%%
% $$ P = tanh\left(\frac{B_0\gamma\hbar}{2k_BT}\right) $$
%%
% where _P_ is the polarisation, _tanh_ is the hyperbolic tangent
% describing:
%%
% $$ tanh(x) = \frac{exp(2x)-1}{exp(2x)+1} $$
%%
% $$ B_0 $$ is the magnetic field strength, $$ \gamma $$ is the
% gyromagnetic ratio of the detected nucleus, $$ \hbar $$ is the reduced
% Planck constant and $$ k_B $$ is the Boltzmann constant
%% Inputs
% _B0_: is the magnetic field strength in Tesla
%%
% _gyro_: is the gyromagnetic ratio in radians per second per Tesla
%%
% _T_: is the temperature in degrees Celsius
%%
%% Output
% _thermalpol_: is the polarisation of a given nuclei type inside a the
% magnetic field, _B0_ at thermal equilibrium

function thermalpol = findThermalEqPol(B0,gyro,T)

    kB = 1.38064852*(10^(-23));
    redPlanck = 1.054571817*(10^(-34));
    T = T+273.21;
    
    thermalpol = tanh((gyro*B0*redPlanck)/(2*kB*T));
    
end

%% Notes
% The inputs used in the example were:
%%
% _B0_: 7
%%
% _gyro_: 67280000
%%
% _T_: 21
%% 
% The example was run by putting:
%%
% thermalpol = findThermalEqPol(7,67280000,21)
%%
% into the command window