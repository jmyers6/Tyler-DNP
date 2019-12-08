%% Fitting an Exponential to the Buildup of Polarisation
%%
% When a sample is undergoing DNP, using: 
%%
% $$ dMz = (Mmax-Mz)/T1 $$
%%
% signal strength can be modelled as a function of:
%%
% $$ Mmax+[M0-Mmax]exp(-t/T1) $$
%% Inputs
% _x_: is a column vector containing the times each measurement was taken
%%
% _y_: is an array containing the signal strength at each time measured.
% Values for different peaks go in different columns
%%
% _peaknames_: is a cell containing the names of each NMR peak measured
%%
% _titl_: is the title of the scatter plot (character vector)
%% Alternative Inputs
% _sys_: is 'Y' if the data was collected using the Alpha System or 'N' if
% the data was collected using the Hypersense
%%
% _dat_: depending on how the data was collected, _dat_ is:
%%
% a cell containing the .txt output of AMARES (Alpha System)
%%
% a .csv output file using the custom integration output using counts and
% values comma delimited from MestReNova (Alpha System)
%%
% a .dat file outputted from using the Hypersense containing comma
% delimited data
%%
% _proc_: is the procpar file, which is used to find the times measured
% (Alpha System only)
%%
% _inp_: is 'A' if the data was processed with JMRUI AMARES or is 'M' if
% the data was processed using MestReNova (Alpha System only)
%%
% _coilnum_: if the data was processed using MestReNova, it is the number
% of coils used to collect the data
%%
% _field_: is a cell containing the names of the peaks from which data was
% collected if the data was processed using MestReNova
%% Outputs
% _T1_: is the longitudinal relaxation constant that describes buildup of
% the signal to its equilibrium in the hyperpolariser magnet
%%
% _Mmax_: is the maxmimum signal strength achievable from the conditions
% used to hyperpolarise the sample
%%
% _M0: is the signal strength at the start of the buildup. It is
% proportional to the polarisation of the sample at 1.5K rather than the
% polarisation achieved from the transfer of electron spin to the sample
% nuclei (_Mmax_)
%%
% _CODs_: is a column vector containing the coefficients of determination
% describing how well the other calculated outputs fit the raw data, where
% the relationship is as follows:
%%
% $$ Signal = Mmax + (M0 - Mmax) \times exp(- \frac{t}{T1}) $$
%% Child Functions
% _checkYN_: checks if an input is 'Y', 'y', 'N', 'n' or something else
%%
% _alphaparse_: parses data collected using the Alpha System and/or 300MHz 
% Magnet into the _x_ and _y_ column vectors, so it can be analysed
%%
% _isdatfile_: checks if an input is a readible file
%%
% _parsedat_: parses data collected using the Hypersense into the _x_ and
% _y_ column vectors

function [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc(x,y,sys,dat,proc,inp,coilnum,field)

    boolxy = 1;
    
    %% Verifying _x_ and _y_ Exist and are Valid
    % _x_ and _y_ must both be populated arrays that contain the same
    % number of rows
    
    if nargin < 2
        boolxy = 0;
    elseif isempty(x) == 1
        boolxy = 0;
    elseif isempty(y) == 1
        boolxy = 0;
    elseif length(x) ~= length(y)
        boolxy = 0;
    end
   
    
    %% Generating _x_ and _y_ if Invalid or Non-Existent Inputs
    % Depending on the system the data was collected on, the outputted raw
    % data will be in a different format. If the data was collected using
    % the Alpha System, _alphaparse_ is suited to process the data.
    % Otherwise, if the data was collected using the Hypersense, _parsedat_
    % is better suited to process the data.
    
    if boolxy == 0
        
        prompt = 'Was the data collected on the Alpha System (Y) or the Hypersense (N)? (Y/N): ';
        
        if nargin < 3
            sys = input(prompt,'s');
        end
        
        sysbool = checkYN(sys);
        
        while sysbool == 0
            sys = input('Please enter Y if the data was collected on the Alpha System or N if the data was collected on the Hypersense (Y/N): ','s');
            sysbool = checkYN(sys);
        end
        
        if sysbool == 1
            if nargin >= 8
                [x,y] = alphaparse([],inp,'N',dat,coilnum,field,proc);
            elseif nargin >= 7
                [x,y] = alphaparse([],inp,'N',dat,coilnum,[],proc);
            elseif nargin >= 6
                [x,y] = alphaparse([],inp,'N',dat,[],[],proc);
            elseif nargin >= 7
                [x,y] = alphaparse([],[],'N',dat,[],[],proc);
            elseif nargin >= 6
                [x,y] = alphaparse([],[],'N',dat,[],[]);
            elseif nargin >= 5
                [x,y] = alphaparse([],[],'N');
            end
        elseif sysbool == 2
            
            if nargin < 4
                dat = input('Enter the .dat file containing the Buildup data: ','s');
            end
            
            datbool = isdatfile(dat);
                
            while datbool == 0
                dat = input('Error: Please enter a valid .dat file','s');
                datbool = isdatfile(dat);
            end
                
            if datbool == 1
                data = parsedat(dat);
                x = data(:,1);
                y = data(:,2);
            end
            
        end
        
    end
    
    %% Generating Arrays to Hold the Estimated Calculated Parameters
    % Parameters are collected for each peak of data quantified from the
    % raw buildup data. At this point, estimates are generated to be fed
    % into the _lsqcurvefit_ function
    
    count = 1;
    
    numpeak = length(y(1,:));
    
    cod = zeros(1,numpeak);
    
    eMmax = zeros(1,numpeak);
    eM0 = zeros(1,numpeak);
    
    mdl = cell(1,numpeak);
    
    for el = 1:numpeak
        eMmax(el) = max(y(:,el))*1.01;
    end
    
    %% Iterating _Mmax_ to Find the Best Estimated Fit
    % The raw data is linearised using:
    %%
    % $$ ln(Mmax-y) = -\frac{t}{T1} + ln(Mmax-M0) $$
    %%
    % The _fitlm_ function is then used to calculate the gradient and
    % intercept of the linearised data. _Mmax_ is iterated 100 times to 
    % minimise the coefficient of determination
    
    while count < 100
        
        yada = eMmax-y;
        yad = log(yada);
        
        for el = 1:numpeak
        
            mdl{el} = fitlm(x,yad(:,el));
        
            codd = mdl{el}.Rsquared.Adjusted;
        
            if codd > cod
                cod(el) = codd;
                eMmax(el) = eMmax(el)*1.01;
            end
            
        end
        
        count = count+1;
        
    end
    
    %% Calculating the Estimated Buildup Curve
    % From the linearised data, the estimated  _T1_ is -1/gradient from 
    % the fit, while the estimated _M0_ is _Mmax_-intercept
    
    eT1s = zeros(numpeak,1);
    
    
    for el = 1:numpeak
    
        T1ada = mdl{el}.Coefficients(2,1);
        T1ad = table2array(T1ada);
        eT1 = -1/T1ad;
        eT1s(el) = eT1;
    
        intada = mdl{el}.Coefficients(1,1);
        intad = table2array(intada);
        inta = exp(intad);
        eM0(el) = eMmax(el)-inta;
        
    end
    
    %% Calculated the Parameters for the Buildup Curve
    % The estimated parameters are fed into _lsqcurvefit_ to calcualte the
    % buildup curve. The coefficient of determination is calculated using: 
    %%
    % $$ Rsquared = 1 - \frac{SSres}{SStot} $$
    %%
    % where _SSres_ is the squared sum of the residuals between the model
    % and raw data and _SStot_ is the sample variance of the signal 
    % strength raw data multiplied by the number of points measured minus 1
    
    f = @(xn,x)xn(1)+((xn(2)-xn(1))*exp(-x/xn(3)));
    
    Mmax = zeros(numpeak,1);
    M0 = zeros(numpeak,1);
    T1 = zeros(numpeak,1);
    CODs = zeros(numpeak,1);
    
    for el = 1:numpeak
        x0 = [eMmax(el) eM0(el) eT1s(el)];
        lb = [0 0 0];
        ub = [inf inf inf];
        options = optimoptions('lsqcurvefit', ...
            'MaxFunctionEvaluations', 3000,'TolFun',1e-9);
        [xn,~,residual] = lsqcurvefit(f,x0,x,y(:,el),lb,ub,options);
        sqresidual = residual.*residual;
        SSres = sum(sqresidual);
        Variance = var(y(:,el));
        nums = length(x);
        SStot = (nums-1)*Variance;
        CODs(el) = 1-(SSres/SStot);
        Mmax(el) = xn(1);
        M0(el) = xn(2);
        T1(el) = xn(3);
    end
    
end

%% Notes
% The inputs used in the example are:
%%
% _x_: []
%%
% _y_: []
%%
% _sys_: 'Y'
%%
% _dat_: {'Buildup_1Pyr_28_11_19.txt'}
%%
% _proc_: 'procpar28_11_19'
%%
% _inp_: 'A'
%%
% The example was run by putting:
% [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],'Y',{'Buildup_1Pyr_28_11_19.txt'},'procpar28_11_19','A')
%%
% into the command window
    
                
           