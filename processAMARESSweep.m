%% Appending Negative Data from AMARES to its Corresponding Positive Data
%%
% In experiments such as microwave sweeps, the signal can be either
% negative or positive representing negative and positive hyperpolarisation
% respectively. The AMARES algorithm does not quantify data as negative
% when run. This function will process the output from two AMARES outputs,
% one corresponding to the positive data and one corresponding to the
% negative data into two separate structure arrays that can be manipulated
% by other functions.
%% Inputs
% _inp_: is the AMARES .txt output file corresponding to negative
% polarisation (positive amplitudes) 
%%
% _inpneg_: is the AMARES .txt output file corresponding to positive
% polarisation (higher microwave frequencies and negative amplitudes in the
% raw data)
%% Outputs
% _fitted_: is a structure array of the _inp_ AMARES output
% _fittedneg_: is a structure array of the _inpneg_ AMARES output
%% Child Functions
% _loadJmruiAmares_: parse the .txt output from AMARES in JMRUI into a
% structure array
% _validateAMARES_: verifies that a file can be passed into
% _loadJmruiAmares without throwing an exception

function [fitted,fittedneg] = processAMARESSweep(inp,inpneg) 

    %% Calling the User if There are Insufficient Inputs
    % The function requires two .txt files from the output of the AMARES
    % algorithm. If two files have not been entered into the inputs, the
    % function will call the user to enter more inputs. See processAMARES
    % and loadJmruiAmares for functions that do not require multiple
    % outputs from AMARES.
    
    prompt = 'Enter the AMARES .txt output corresponding to positive data to process: ';
    prompt1 = 'Please enter a valid AMARES .txt output corresponding to the positive data to process: ';
    
    promptn = 'Enter the AMARES .txt outputs corresponding to negative data to process: ';
    promptn1 = 'Please enter a valid AMARES .txt output corresponding to the negative data to process: ';

    if nargin == 0
        
        inp = input(prompt,'s');
        bool = validateAMARES(inp);
        
        while bool == 0
            inp = input(prompt1,'s');
            bool = validateAMARES(inp);
        end
        
        fitted = loadJmruiAmares(inp); 
    
        inpneg = input(promptn,'s');
        bool = validateAMARES(inpneg);
        
        while bool == 0
            inpneg = input(promptn1,'s');
            bool = validateAMARES(inpneg);
        end
        
        fittedneg = loadJmruiAmares(inpneg);
        
    elseif isempty(inp) == 1
        
        inp = input(prompt,'s');
        bool = validateAMARES(inp);
        
        while bool == 0
            inp = input(prompt1,'s');
            bool = validateAMARES(inp);
        end
        
        fitted = loadJmruiAmares(inp);
        
        if nargin < 2
            
            promptn = 'Enter the AMARES .txt outputs corresponding to negative data to process: '; 
            inpneg = input(promptn,'s');
            bool = validateAMARES(inp);
        
            while bool == 0
                inpneg = input(promptn1,'s');
                bool = validateAMARES(inpneg);
            end
        
            fittedneg = loadJmruiAmares(inpneg);
            
        end
        
    elseif nargin < 2
        
        fitted = loadJmruiAmares(inp);
        promptn = 'Enter the AMARES .txt outputs corresponding to negative data to process: '; 
        inpneg = input(promptn,'s');
        bool = validateAMARES(inpneg);
        
        while bool == 0
            inpneg = input(promptn1,'s');
            bool = validateAMARES(inpneg);
        end
        
        fittedneg = loadJmruiAmares(inpneg);
        
    else
        
        bool = validateAMARES(inp);
        
        while bool == 0
            inp = input(prompt1,'s');
            bool = validateAMARES(inp);
        end
        
        fitted = loadJmruiAmares(inp);
        
        bool = validateAMARES(inpneg);
        
        while bool == 0
            inp = input(promptn1,'s');
            bool = validateAMARES(inp);
        end
        
        fittedneg = loadJmruiAmares(inpneg);
        
    end
   
end

%% Notes
% The inputs used in the example are:
%%
% _inp_: '21_11_19_pyrSweep_pos.txt' 
%%
% _inpneg_: '21_11_19_pyrSweep_neg.txt' 
%% 
% The example was run by putting:
%%
% [fitted,fittedneg] = processAMARESSweep('21_11_19_pyrSweep_pos.txt','21_11_19_pyrSweep_neg.txt')
%%
% into the command window