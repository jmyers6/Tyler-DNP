%% Generating a Structure Array from the Results of Integration Using MestReNova
%%
% The function processes MestReNova's custom integral .csv file, where the
% file is comma delimited and the columns are the parameters: 'counts' and
% 'abs integral values'
%% Inputs
% _countAbs_: is the .csv output file from MestReNova
% _coilnum_: is the number of coils used to detect the NMR signal in the
% experiment
% _field_: is a cell containing the names of each peak quantified in a
% separate element
%% Output
% _fitted_: is a structure array of the same layout as the one produced by
% the loadJmruiAmares function among others
%% Child Functions
% _isint_: checks if an input is an integer or not
%%
% _readmatrixrig_: is a more rigorous version of the readmatrix function
% that does not throw exceptions

function fitted = summestrenova(countAbs,coilnum,field) 

    %% Calling the User if Insufficient or Invalid Inputs have been Entered
    
    if nargin < 1 
        prompt = 'Please input a MestReNova integral series file: ';
        countAbs = input(prompt,'s');
    elseif isempty(countAbs) == 1
        prompt = 'Please input a MestReNova integral series file: ';
        countAbs = input(prompt,'s');
    end
    
    bool = 0;
    
    while bool == 0
        
        if nargin < 2 
            promptc = 'Enter the number of coils of data to sum: ';
            coilnum = input(promptc);
            bool = isint(coilnum);
        elseif isempty(coilnum) == 1
            promptc = 'Enter the number of coils of data to sum: ';
            coilnum = input(promptc);
            bool = isint(coilnum);
        else
            bool = isint(coilnum);
        end
        
        if bool == 0
            disp('Error: Non-integral number of coils entered')
        end
        
    end
    
    data = readmatrixrig(countAbs);
    
    numpeak = length(data(1,:))-2;
    
    fieldbool = 0;
    
    if nargin == 3
        if string(class(field)) == "cell"
            if length(field) == numpeak
                fieldbool = 1;
            end
        end
    end
    
    if fieldbool == 0 
    
        field = cell(numpeak,1);
    
        if numpeak == 1
        
            promptp = 'Please enter a name for the peak: ';
            field{1,1} = input(promptp,'s');
        
        else
        
            promptp = 'Please enter a name for the first peak (lst column after the count from the left): ';
            field{1,1} = input(promptp,'s');
        
            for el = 2:numpeak
            
                promptpn = 'Please enter a name for the next peak: ';
                field{el,1} = input(promptpn,'s');
            
            end
        
        end
        
    end
    
    %% Summing Data from Simultaneous Detection from Multiple Coils
    
    if coilnum > 1 
        
        nummeat = length(data(:,1));
        indarray = 1:coilnum:nummeat;
        dataf = data(indarray,:);
        
        for el = 2:coilnum
            indarrayn = el:coilnum:nummeat;
            dataf = dataf+data(indarrayn,:);
        end
        
    else
        
        dataf = data;
        
    end
    
    %% Generating the _fitted_ Structure Array
    
    for el = 1:numpeak 
        datac = el+1;
        fitted.dataByPeak.(field{el}) = struct('Amplitudes',dataf(:,datac));
    end
    
end
        
%% Notes
% The example inputs used are:
%%
% _countAbs_: 'Decay_Dissolution_17_10_19.csv'
%%
% _coilnum_: 2
%%
% _field_: {'PYRUVATE','PYRUVATE_HYDRATE'}
%%
% The example was run by putting:
%%
% fitted =
% summestrenova('Decay_Dissolution_17_10_19.csv',2,{'PYRUVATE',
% 'PYRUVATE_HYDRATE'})
%%
% into the command window