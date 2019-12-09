%% Calculating Initial Estimates for the T1 Relaxation Constant of the Decay of Hyperpolarisation, Initial Magnetisation and the Flip Angle Correction Factor
%%
% This function is the parent function of functions that calculate initial
% estimates of the T1 relaxation constant for the decay of
% hyperpolarisation, the flip angle correction factor and the initial
% magnetisation vector (which is proportional to total polarisation). The
% parameters are calculated by:
%%
% Splitting the data into sections determined by the flip angle used to
% measure the data (Ex. If the first two measurements used a 5° flip angle,
% the next two, 10° and the last two 5°, the data would be split into three
% sections, the first set of data collected using 5°, the 10° data and the
% second set of data collected using 5°)
% For each section, the data is treated as continuous and, each section is 
% modelled with the following relation:
%% 
% $$ Mz = M0 \times cos^{t/TR}(alpha \times \theta) \times
% exp\left(-\frac{t}{T1}\right) $$
%%
% where _Mz_ represents the magnetisation in the z-direction, _M0_ is the
% initial magnetisation in the z-direction, _t_ is the time, _TR_ is the
% average repetition time for the section (the average time interval before
% taking a measurement), _alpha_ is the flip angle correction factor, $$
% \theta $$ is the estimated flip angle found from the _flip1_ parameter of
% the procpar file and _T1_ is the longitudinal relaxation constant, which
% describes the decay of hyperpolarisation
%%
% The above relation is not strictly true, since signal is actually
% proportional to Mxy and the data is discrete with the sense of the exact
% time when a measurement is taken, but the relation yields a good first
% estimate
%% 
% The model is applied to the data by linearising it using:
%%
% $$ \ln{Mz} = \left(\frac{1}{TR}\times \ln{[cos(alpha \times \theta)]} -
% \frac{1}{T1}\right)\times t+\ln{M0} $$
%%
% By applying a linear model to the logarithm of the signal data, the
% gradient of the data is:
%% 
% $$ \left(\frac{1}{TR}\times \ln{[cos(alpha \times \theta)]} -
% \frac{1}{T1}\right) $$
%%
% The intercept of the data is:
%% 
% $$ \ln{M0} $$
%% 
% At this stage, the value of _alpha_ is iterated and T1 is calculated for
% each set of data. The best _alpha_ value is chosen to be the one where
% the coefficient of variation of the T1s is minimised.
%% Inputs
% _procpar_: is the procpar file for the experiment, which is used to find
% the flip angles, repetition times (TRs) and times each measurement was
% taken
%%
% _inp_: is 'A' if the data was quantified using AMARES from JMRUI, or it
% should be 'M' if the data was quantified using integration in MestReNova
% and the data is a custom .csv integral file
%%
% _coilnum_: should only be entered if _inp_ is 'M'. It is the number of
% coils used to collect the data.
%%
% _field_: should only be entered if _inp_ is 'M'. It is a cell containing
% the names of the peaks that have been quantified
%% Outputs
% _eT1_: is an array containing the estimated _T1_ values for each peak
% quantified
%%
% _eM0_: is an array containing  the estimated _M0_ values for each peak
% quantified
%%
% _eAlpha_: is an array containing the estimated _alpha_ values for each
% peak quantified
%%
% _data_: is an array, where the first column is the times each measurement
% was performed at, the second column is the estimated flip angle used to
% take each measurement and the remaining columns are the signal strength
% of each measurement where each subsequent column is measurements from
% different peaks
%%
% _peaknames_: is a cell, where each element is the name of a quantified
% peak
%%
% _secinds_ & _secvals_: are arrays containing the indices where the flip
% angle used for a measurement is changed and the value the flip angle is
% changed to respectively
%%
% _grads_: is an array containing the gradients calculated for the
% linearised raw data fitted to the above model. The rows correspond to the
% different sections, while the columns correspond to the different
% quantified peaks
%%
% _int_: is an array containing the y-intercepts calculated for the
% linearised raw data fitted to the above model. The rows correspond to the
% different sections, while the columns correspond to the different
% quantified peaks
%%
% _Rsquareds_: is an arraying containing the coefficients of determination
% for the linearised raw data fitted to the above model. The rows 
% correspond to the different sections, while the columns correspond to the 
% different quantified peaks
%% Child Functions
% _flipAnglesFromProcpar_: returns the contents of the _flip1_ parameter in
% the procpar file for the experiment
%%
% _alphaparse_: parses the raw data files into a readible extracting the
% times measurements were conducted at, the measurements themselves and the
% names of the peaks quantified
%%
% _resizeColumn: resizes the array containing the contents of _flip1_ if
% there is non-size agreement between it and the raw data. This function
% serves as a data verification step
%%
% _indsFirstSetValues: returns the indices where the flip angles used are
% charged and the values that they were changed to
%%
% _linreg_: applies the above model to the linearised raw data and
% calculates the gradient, intercept and coefficient of determination
%%
% _averageTRs: finds the average repetition time used in each section
%%
% _findDecayParams_: uses the output from _linreg_ to find the best
% first estimate for _T1_, _M0_ and _alpha_


function [eT1,eM0,eAlpha,data,peaknames,secinds,secvals,grads,ints,Rsquareds] = estParamT1Decay(proc,inp,dat,coilnum,field)

    procbool = 1;
    
    if nargin < 1
        procbool = 0;
    end
    
    %% Finding the Estimated Flip Angles Used in the Experiment
    
    if procbool == 1
        flips = flipAnglesFromProcpar(proc);
    else
        flips = flipAnglesFromProcpar;
    end
    
    %% Parsing the Raw Data
    
    if nargin >= 5
        [x,y,peaknames] = alphaparse([],inp,'N',dat,coilnum,field,proc);
    elseif nargin >= 4
        [x,y,peaknames] = alphaparse([],inp,'N',dat,coilnum,[],proc);
    elseif nargin >= 3
        [x,y,peaknames] = alphaparse([],inp,'N',dat,[],[],proc);
    elseif nargin >= 2
        [x,y,peaknames] = alphaparse([],inp,'N',[],[],[],proc);
    elseif nargin >= 1
        [x,y,peaknames] = alphaparse([],[],'N',[],[],[],proc);
    else
        [x,y,peaknames] = alphaparse([],[],'N');
    end
    
    %% Verifying the Number of Flip Angle Entries Found Matches the Number of Measurements
    % If there is disagreement, the user is allowed to either terminate or
    % continue with correction applied to the flip array as described below
    
    nummeas = length(y(:,1));
    
    nummeasflip = length(flips);
    contbool = 0;
    
    if nummeas ~= nummeasflip
        
        disp('Error: The number of measurements is not equal to the flip angles arrayed in flip1 in the procpar')
        prompt = 'To continue, if there are multiple entries in flip1, they will be spread along the number of measurements. Otherwise, if flip1 is empty, flip1 will be set to 1. Type Y to continue or N to stop (Y/N): ';
        contbool = input(prompt,'s');
        
    end
    
    if contbool == 1
        flips = resizeColumn(flips);  
    end
    
    %% Creation of the _data_ Array
    
    numpeak = length(peaknames);
    
    datacols = numpeak+2;
    data = zeros(nummeas,datacols);
    
    data(:,1) = x;
    data(:,2) = flips;
    data(:,3:end) = y;
    
    if contbool == 2
        return
    end
    
    %% Verifying Enough Flip Angles were Used in the Experiment to Estimate _T1_
    
    FlipSets = unique(flips);
    
    if length(FlipSets) < 2
        disp('Error: Not enough flip angles arrayed to estimate T1')
        return
    end
    
    %% Finding the Indices Where the Flip Angle was Changed
    
    [secvals,secinds] = indsFirstSetValues(flips);
    
    %% Linearising the Raw Data
    
    ylog = log(y);
    
    %% Calculating the Gradients, Intercepts and Coefficients of Determination of the Linearised Raw Data
    
    [grads,ints,Rsquareds] = linreg(x,ylog,secinds);
    
    %% Finding the Average TR for Each Section
    
    avTRs = averageTRs(x,secinds);
    
    %% Estimating _T1_ and _alpha_ from the Linear Model
    
    [eT1,eAlpha] = findDecayParams(grads,secvals,avTRs);
    
    intf = exp(ints(1,:));
    eM0 = intf./sind(eAlpha.*secvals(1));
    
end

%% Notes
% The inputs used in the example were:
%%
% _proc_: 'procpar28_11_19_Dissolution'
%%
% _inp_: 'A'
%%
% _dat_: {'Decay_Dissolution_28_11_19_even.txt',
% 'Decay_Dissolution_28_11_19_odd.txt'}
%%
% The example was run by putting:
%%
% [eT1,eM0,eAlpha,data,peaknames,secinds,secvals,grads,ints,Rsquareds] = 
% estParamT1Decay('procpar28_11_19_Dissolution','A',
% {'Decay_Dissolution_28_11_19_even.txt',
% 'Decay_Dissolution_28_11_19_odd.txt'})
%%
% into the command window