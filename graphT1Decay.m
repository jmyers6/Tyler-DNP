%% Generating Plots Showing Signal Strength as a Function of Flip Angle and T1 Decay and Showing Decay of Hyperpolarisation
%%
% Two plots are generated for each quantified peak. One plot shows the
% signal strength as a function of time (T1 decay) and the flip angles used
% to generate each measurement. The other plot shows Mz (hyperpolarisation)
% as a function of flip angles used at each measurement and time (T1 decay)
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
% Scatter plot of raw data with fitted curve used to predict the T1 decay
% constant
%%
% Scatter plot of Mz vs. Time with the fitted curve (NB Mz is calculated
% using the flip angles in the procpar file and flip angle correction
% factor _alpha_)
%% Child Functions
% _T1DecayCalc_: calculates the _T1_, _M0_ and _alpha_ constants for each
% peak. It also calculates the fit of the model to the data and parses the
% raw data files into a readible format
%%
% _T1DecayFunction_: calculates the signal strength values from the model
% using inputted _T1_, _M0_ and _alpha_ parameters as well as the times and
% flip angles used
%%
% _T1DecayFunctionMz_: calculates the Mz values from the model using 
% inputted _T1_, _M0_ and _alpha_ parameters as well as the times and
% flip angles used

function graphT1Decay(proc,inp,dat,coilnum,field)

    %% Calculating Parameters of the Fitted Decay Curve
    % _T1_ is the relaxation constant of the hyperpolarisation returning to
    % thermal equilibrium. _M0_ is the initial total magnetisation in
    % arbitrary units (amount of hyperpolarisation). _alpha_ is the flip
    % angle correction factor applied to all flip angles in the flip1
    % parameter in the procpar file. _CODs_ is the coefficients of
    % determinations of the fit of the model to the data. _data_ is an
    % array containing the raw data and estimated flip angles. _peaknames_
    % is a cell containing the names of each peak quantified. _secinds_ and
    % _secvals_ are arrays containing the indices where the estimated flip
    % angle is changed and what the estimated flip angles are for each
    % part of the data set respectively

    if nargin >= 5
        [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc,inp,dat,coilnum,field);
        TR = TRfromProcpar(proc);
    elseif nargin >= 4
        [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc,inp,dat,coilnum);
        TR = TRfromProcpar(proc);
    elseif nargin >= 3
        [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc,inp,dat);
        TR = TRfromProcpar(proc);
    elseif nargin >= 2
        [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc,inp);
        TR = TRfromProcpar(proc);
    elseif nargin >= 1
        [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc);
        TR = TRfromProcpar(proc);
    else
        proc = readprocpar;
        [T1,M0,alpha,CODs,data,peaknames,secinds,secvals] = T1DecayCalc(proc);
        TR = TRfromProcpar(proc);
    end
    
    if length(secinds) < 2
        disp('Not enough flip angles were used to calculate decay parameters')
        return
    end
    
    %% Plotting the Raw Data and Overlaying the Fitted Curve
    % The fitted curve obeys the following relation:
    % $$ Mxy_{measurement} (measured~signal) = Mz_{previous~measurement}
    % \times cos(flip~angle~correction~factor (alpha) \times est.~Flip~
    % Angle) \times exp\left(-\frac{TR}{T1}\right) \times sin(alpha \times
    % est.~Flip~Angle) $$
    %%
    % _Mz_ of the previous measurement is calculated with the following:
    %%
    % $$ Mz_{previous~measurement} = \frac{Mxy_{previous~
    % measurement}}{sin(alpha \times est.~Flip~Angle_{previous~
    % measurement}} $$
    %%
    % The _Mz_ of the first measurement is _M0_
    %%
    % Each part of the data set that was collected using a different
    % estimated flip angle is plotted with a different colour, which is
    % shown on the legend
    
    for el = 1:length(peaknames)
    
        figure('Position',[0 0 600 450])
        fitfun = T1DecayFunction([M0(el) alpha(el) T1(el)],data(:,1:2));
        if length(TR) == 1
            equ = strcat("Mxy = Mz(prev. measurement) x cos(",num2str(alpha(el)),{' '},'x est. Flip Angle)',...
                'x exp(-',num2str(TR),'/',num2str(T1(el)),'s)',{' '}, 'x sin(',num2str(alpha(el)),{' '},'x est. Flip Angle)',{', '},'Rsquared = ',num2str(CODs(el)));
        else
            equ = strcat("Mxy = Mz(prev. measurement) x cos(",num2str(alpha(el)),{' '},'x est. Flip Angle)',...
                'x exp(-TR/',num2str(T1(el)),'s)',{' '}, 'x sin(',num2str(alpha(el)),{' '},'x est. Flip Angle)',{', '},'Rsquared = ',num2str(CODs(el)));
        end
        plot(data(:,1),fitfun)
        hold on
        Legend = cell(length(secinds)+1,1);
        Legend{1} = equ;
        
        for ele = 1:length(secinds)
            if ele == length(secinds)
                scatter(data(secinds(ele):end,1),data(secinds(ele):end,el+2))
            else
                scatter(data(secinds(ele):secinds(ele+1)-1,1),data(secinds(ele):secinds(ele+1)-1,el+2))
            end
            legent = strcat(num2str(secvals(ele)),"° Est. Flip Angle");
            Legend{ele+1} = legent;
        end
        
        xlabel('Time /s')
        ylabel('Signal Strength /Arbitrary Units')
        title(strcat("Signal Strength vs. Time for the T1 Decay of",{' '},peaknames{el}))
        legend(Legend)
        
    end
    
    %% Plotting Mz at Each Measurement and the Fitted Curve
    % The fitted equation is the same as above except the equation does not
    % have the last sin term since:
    %%
    % $$ Mxy = Mz \times sin(flip angle) $$
    
    for el = 1:length(peaknames)
    
        figure('Position',[0 0 600 450])
        fitfun = T1DecayFunctionMz([M0(el) alpha(el) T1(el)],data(:,1:2));
        y = [M0(el);fitfun];
        x = [0;data(:,1)];
        if length(TR) == 1
            equ = strcat("Mz = Mz(prev. measurement) x cos(",num2str(alpha(el)),{' '},'x est. Flip Angle) x exp(-',num2str(TR),'/',num2str(T1(el)),'s)',{', '},'Rsquared = ',num2str(CODs(el)));
        else
            equ = strcat("Mz = Mz(prev. measurement) x cos(",num2str(alpha(el)),{' '},'x est. Flip Angle) x exp(-TR/',num2str(T1(el)),'s)',{', '},'Rsquared = ',num2str(CODs(el)));
        end
        plot(x,y)
        hold on
        Legend = cell(length(secinds)+1,1);
        Legend{1} = equ;
        
        data(:,el+2) = data(:,el+2)./sind(data(:,2).*alpha(el));
        
        for ele = 1:length(secinds)
            if ele == length(secinds)
                scatter(data(secinds(ele):end,1),data(secinds(ele):end,el+2))
            else
                scatter(data(secinds(ele):secinds(ele+1)-1,1),data(secinds(ele):secinds(ele+1)-1,el+2))
            end
            legent = strcat(num2str(secvals(ele)),"° Est. Flip Angle");
            Legend{ele+1} = legent;
        end
        
        xlabel('Time /s')
        ylabel('Mz /Arbitrary Units')
        title(strcat("Mz vs. Time for the T1 Decay of",{' '},peaknames{el}))
        legend(Legend)
        
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
% graphT1Decay('procpar28_11_19_Dissolution','A',
% {'Decay_Dissolution_28_11_19_even.txt',
% 'Decay_Dissolution_28_11_19_odd.txt'})
%%
% into the command window