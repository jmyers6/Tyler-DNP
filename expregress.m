%% Generating a Scatter Plot from a Buildup with a Curve Overlaid with Calculated Mmax, M0 and T1 Parameters
%%
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
%% Output
% A scatter plot of the buildup data with a curve overlaid obeying the
% following relation:
%%
% $$ Signal Strength = Mmax + (M0 - Mmax) \times exp(-\frac{t}{T1}) $$
%% Child Function
% _BuildupParamCalc_: Calculates _T1_, _Mmax_ and _M0_ from the buildup
% data. It also calculates the coefficient of determination (_CODs_) from
% the fit of the calculated parameters and if _x_ and _y_ were not
% inputted/were invalid, it yields _x_ and _y_ too

function expregress(x,y,peaknames,titl,sys,dat,proc,inp,coilnum,field)

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
   
    
    %% Generating _x_ and _y_ if Invalid or Non-Existent and Calculating _T1_, _Mmax_, _M0_ and _Rsquared_
    
    if boolxy == 0
        if nargin == 10
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],sys,dat,proc,inp,coilnum,field);
        elseif nargin == 9
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],sys,dat,proc,inp,coilnum);
        elseif nargin == 8
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],sys,dat,proc,inp);
        elseif nargin == 7
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],sys,dat,proc);
        elseif nargin == 6
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],sys,dat);
        elseif nargin == 5
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc([],[],sys);
        else
            [T1,Mmax,M0,CODs,x,y] = BuildupParamCalc;
        end
    else
        [T1,Mmax,M0,CODs] = BuildupParamCalc(x,y);
    end
    
    %% Verifying Data is Labelled
    % The _peaknames_ variable contains the names of the data collected
    % (the names of the peaks) from the buildup experiment. If the variable
    % is invalid or not inputted, it is by default, set to 'Data'.
    
    if nargin < 3
        peaknames = {'Data'};
    elseif string(class(peaknames)) ~= "cell"
        peaknames = {'Data'};
    end

    numpeak = length(y(1,:));
    
    equ = cell(numpeak,1);
    
    %% Displaying the Equation for the Fitted Exponential Curve
    % The parameters calcualted from _BuildupParamCalc_ are used to
    % generate the full equation describing the exponential curve, which
    % will later be displayed on the plotted curve.
    
    for el = 1:numpeak
        sMmax = num2str(Mmax(el));
        sM0 = num2str(M0(el));
        sT1 = num2str(T1(el));
        equ{el} = strcat('Signal Strength =', {' '}, sMmax, {' '}, '+ [', sM0, {' '}, '-', {' '}, sMmax, ']exp(-time/', sT1, 's)');
    end

    %% Setting the Title of the Figure
    % If no title is given, a default title is given
    
    if nargin < 4
        titl = 'Signal Strength vs. Time';
    elseif ischarvec(titl) ~= 1
        titl = 'Signal Strength vs. Time';
    end
    
    %% Generating a Scatter Plot of the Buildup Data with Fitted Curve
    
    figure('Position',[0 0 600 450])
    scatter(x,y(:,1))
    hold on
    inter = max(x)*0.01;
    x1 = 0:inter:max(x);
    y1 = Mmax(1) + (M0(1)-Mmax(1)).*exp(-x1./T1(1));
    
    if numpeak == 1
        plot(x1,y1,'k')
    else
        plot(x1,y1)
    end
    
    if numpeak > 1
        for el = 2:numpeak
            scatter(x,y(:,el))
            y1 = Mmax(el) + (M0(el)-Mmax(el)).*exp(-x1./T1(el));
            plot(x1,y1)
        end
    end
    
    legpeaks = cell(2*numpeak,1);
    
    for el = 1:2:(2*numpeak)
        legpeaks{el} = peaknames{el};
        legpeaks{el+1} = char(strcat(equ{el}, {', '}, 'Rsquared =', {' '}, num2str(CODs(el))));
    end
    
    legend(legpeaks,'Location','southeast')
    
    xlabel('Time /s')
    ylabel('Signal Strength /Arbitrary Units')
    
    title(titl)
    
end

%% Notes
% The inputs used in the example are:
%%
% _x_: []
%%
% _y_: []
%%
% _peaknames_: []
%%
% _titl_: 'Buildup of Urea using 1mM Bis Gd with OHOH Ligand 6/12/19'
%%
% _sys_: 'Y'
%%
% _dat_: {'BuildupUreaOHOH_06_12_19_2_2.txt'}
%%
% _proc_: 'procpar06_12_19_Buildup2_1'
%%
% _inp_: 'A'
%%
% The example was run by putting:
%%
% expregress([],[],[],'Buildup of Urea using 1mM Bis Gd with OHOH Ligand 6/12/19','Y',{'BuildupUreaOHOH_06_12_19_2_2.txt'},'procpar06_12_19_Buildup2_1','A')
%%
% into the command window