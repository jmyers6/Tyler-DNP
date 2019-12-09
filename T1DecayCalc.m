%% Calculating the T1 Relaxation Constant for Decay of Hyperpolarisation and Initial Magnetisation
%%
% The T1 relaxation constant is calculated, along with the initial
% magnetisation (this is the magnetisation in the z-direction and is
% directly proportional to the degree of hyperpolarisation). Additionally,
% a correction factor, _alpha_, is calculated to adjust the predicted flip
% angles from the magnet to the ones that were actually used in the
% experiment. The parameters are calculated using the following relation:
%%
% $$ Mxy_{measurement} = Mz_{previous~measurement} \times cos(\theta)
% \times exp\left(-\frac{t}{T1}\right) \times sin(\theta) $$
%%
% where:
%% 
% $$ Mz_{previous~measurement} =
% \frac{Mxy_{previous~measurement}}{sin(\theta_{previous~measurement})} $$
%% 
% and the first _Mz_ is _M0_, the initial magnetisation
%% 
% and $$ \theta $$ is the flip angle of the measurement
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
% _T1_: is an array of the T1 relaxation constants for each peak quantified
%%
% _M0_: is an array of the initial magnetisations in the z-direction for
% each peak quantified
%%
% _alpha_: is an array of the flip angle correction factors. These values
% correct the flip angles stored in _flip1_ in the procpar file to the
% actual values used
%%
% _CODs_: is an array of the coefficients of determination for the fit of
% data to the model. It is calculated using:
%%
% $$ COD = 1-\frac{SS_{res}}{SS_{tot}} $$
%%
% (see the wikipedia entry for more details)
%%
% _data_: is an array containing the raw data from the experiment. The
% first column is the times each measurement was collected in seconds; the
% second column is the estimated flip angle used for each measurement in
% degrees; the remaining columns are the signal strengths of each
% measurement for each peak
%%
% _secinds_ & _secvals_: are arrays containing the indices where the flip
% angle used for a measurement is changed and the value the flip angle is
% changed to respectively
%% Child Functions
% _estParamT1Decay_: generates a first estimate for _T1_, _M0_ and _alpha_.
% It also parses the raw data files into a readible format
%% 
% _T1DecayFunction_: calculates the signal strength values from the model
% using inputted _T1_, _M0_ and _alpha_ parameters as well as the times and
% flip angles used

function [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc,inp,dat,coilnum,field)

    %% Calculating Estimates for the _T1_, _M0_ and _alpha_ Parameters
    % _estParamT1Decay_ is used to calculate initial estimates to feed into
    % _lsqcurvefit_ later

    if nargin == 5
        [eT1,eM0,eAlpha,data,peaknames,secinds,secvals] = estParamT1Decay(proc,inp,dat,coilnum,field);
    elseif nargin == 4
        [eT1,eM0,eAlpha,data,peaknames,secinds,secvals] = estParamT1Decay(proc,inp,dat,coilnum);
    elseif nargin == 3
        [eT1,eM0,eAlpha,data,peaknames,secinds,secvals] = estParamT1Decay(proc,inp,dat);
    elseif nargin == 2
        [eT1,eM0,eAlpha,data,peaknames,secinds,secvals] = estParamT1Decay(proc,inp);
    elseif nargin == 1
        [eT1,eM0,eAlpha,data,peaknames,secinds,secvals] = estParamT1Decay(proc);
    else
        [eT1,eM0,eAlpha,data,peaknames,secinds,secvals] = estParamT1Decay;
    end
    
    numpeak = length(peaknames);
    M0 = zeros(numpeak,1);
    alpha = zeros(numpeak,1);
    T1 = zeros(numpeak,1);
    CODs = zeros(numpeak,1);
    
    for el = 1:numpeak
        
        %% Calculating _T1_, _M0_, _alpha_ and _COD_ for each Quantified Peak

        x0 = [eM0(el),eAlpha(el),eT1(el)];
    
        xdataf(:,1) = data(:,1);
        xdataf(:,2) = data(:,2);
        sigdata = data(:,el+2);
        
        minAlpha = 0.001;
        maxAlpha = floor(90/max(data(:,2)));
        
        if x0(2) < minAlpha
            x0(2) = minAlpha;
        end

        lb = [0 0.001 0]; 
        ub = [inf maxAlpha inf]; 
        options = optimoptions('lsqcurvefit', ...
            'MaxFunctionEvaluations', 3000,'TolFun',1e-9); 
        try
            
            [xn,~,residuals] = lsqcurvefit(@T1DecayFunction,x0,xdataf,sigdata,lb,ub,options); 
            M0(el) = xn(1);
            alpha(el) = xn(2);
            T1(el) = xn(3);
            SSres = sum(residuals)*sum(residuals);
            SStot = var(sigdata)*(length(sigdata)-1);
            CODs(el) = 1-(SSres/SStot);
            
        catch
            peak = peaknames{el};
            error = strcat('Error: Cannot evaluate T1 for data from the peak corresponding to ', {' '}, peak);
            disp(error)
            M0store = M0(1:el-1);
            alphastore = alpha(1:el-1);
            T1store = T1(1:el-1);
            CODsStore = CODs(1:el-1);
            peaknameStoreb = peaknames{1:el-1};
            
            if el < numpeak
                peaknameStoree = peaknames{el+1:numpeak};
                peaknames = {peaknameStoreb, peaknameStoree};
            else
                peaknames = {peaknameStoreb};
            end
            
            numpeak = numpeak-1;
            M0 = zeros(numpeak,1);
            alpha = zeros(numpeak,1);
            T1 = zeros(numpeak,1);
            CODs = zeros(numpeak,1);
            M0(1:el-1) = M0store;
            alpha(1:el-1) = alphastore;
            T1(1:el-1) = T1store;
            CODs(1:el-1) = CODsStore;
            
        end
        
    end
    
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
% [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = 
% T1DecayCalc('procpar28_11_19_Dissolution','A',
% {'Decay_Dissolution_28_11_19_even.txt',
% 'Decay_Dissolution_28_11_19_odd.txt'})
%%
% into the command window