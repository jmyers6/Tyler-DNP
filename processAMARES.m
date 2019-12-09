%% Processing Multiple .txt AMARES Outpus into One Structure Array
%%
% This function is similar to loadJmruiAmares, but allows for keeping
% related AMARES files in together in one output. Instead of a 1x1
% structure array being generated, a 1xnumber of files size structure array
% is generated instead. This function also allows for manually entering in
% the files to be concatenated if necessary.
%% Input
% _inp_: is a cell containing each .txt AMARES output file in a separate
% element. In the case of only processing one file, _inp_ is a 1x1 cell,
% where the sole element is the file to be processed
%% Output
% _fitted_: is a structure array of the files stored in _inp_
%% Child Functions
% _loadJmruiAmares_: parses the .txt output from AMARES in JMRUI into a
% structure array
%%
% _validateAMARES_: verifies that a file can be passed into
% _loadJmruiAmares_ without throwing an exception

function fitted = processAMARES(inp)

%% Calling the User to Individually Enter Files to Process
% If no files are inputted or invalid files entered, the user will instead 
% be called to enter files to process one by one.

    runbool = 0;
    canrun = 1;
    
    while runbool == 0

        if nargin == 0
        
            prompt = 'Enter an AMARES .txt file to process: '; 
            prompt1 = 'Please enter a valid AMARES .txt file to process: ';
            inp = input(prompt,'s');
            bool = validateAMARES(inp);
        
            while bool == 0
                inp = input(prompt1,'s');
                bool = validateAMARES(inp);
            end
        
            fitted = loadJmruiAmares(inp);
    
            promptn = 'Would you like to enter another AMARES .txt file to process? (Y/N): ';
            promptn1 = 'Error: Please enter Y to process another AMARES .txt file or N to quit: ';
            inp = input(promptn,'s');
    
            boolyn = checkYN(inp);
        
            while boolyn == 0
                inp = input(promptn1,'s');
                boolyn = checkYN(inp);
            end
            
            %% Adding More AMARES Files to the Output _fitted_
    
            while boolyn == 1
        
                prompta = 'Enter the next AMARES .txt file to process: ';
                inp = input(prompta,'s');
            
                bool = validateAMARES(inp);
            
                while bool == 0
                    inp = input(prompt1,'s');
                    bool = validateAMARES(inp);
                end
                
                fitteda = loadJmruiAmares(inp);
        
                fitted = [fitted, fitteda];
        
                promptn = 'Would you like to enter another AMARES .txt file to process? (Y/N): ';
                inp = input(promptn,'s');
    
                boolyn = checkYN(inp);
        
                while boolyn == 0
                    inp = input(promptn1,'s');
                    boolyn = checkYN(inp);
                end
        
            end
            
            runbool = 1;
            
        %% Entering Files Individually if _inp_ is Invalid
            
        elseif canrun == 0
            
            prompt = 'Enter an AMARES .txt file to process: '; 
            prompt1 = 'Please enter a valid AMARES .txt file to process: ';
            inp = input(prompt,'s');
            bool = validateAMARES(inp);
        
            while bool == 0
                inp = input(prompt1,'s');
                bool = validateAMARES(inp);
            end
        
            fitted = loadJmruiAmares(inp);
    
            promptn = 'Would you like to enter another AMARES .txt file to process? (Y/N): ';
            promptn1 = 'Error: Please enter Y to process another AMARES .txt file or N to quit: ';
            inp = input(promptn,'s');
    
            boolyn = checkYN(inp);
        
            while boolyn == 0
                inp = input(promptn1,'s');
                boolyn = checkYN(inp);
            end
    
            while boolyn == 1
        
                prompta = 'Enter the next AMARES .txt file to process: ';
                inp = input(prompta,'s');
            
                bool = validateAMARES(inp);
            
                while bool == 0
                    inp = input(prompt1,'s');
                    bool = validateAMARES(inp);
                end
                
                fitteda = loadJmruiAmares(inp);
        
                fitted = [fitted, fitteda];
        
                promptn = 'Would you like to enter another AMARES .txt file to process? (Y/N): ';
                inp = input(promptn,'s');
    
                boolyn = checkYN(inp);
        
                while boolyn == 0
                    inp = input(promptn1,'s');
                    boolyn = checkYN(inp);
                end
        
            end
            
            runbool = 1;
            
        %% Verifying _inp_ is Valid and Processing _inp_
        
        else
        
            if string(class(inp)) == "cell"
        
                len = length(inp);
            
                bool = 1;
            
                for el = 1:len
                    
                    checkbool = validateAMARES(inp{el});
                    
                    if checkbool == 0
                        bool = 0;
                    end
                end
            
                if bool == 1
        
                    fitted = loadJmruiAmares(char(inp{1}));
        
                    for el = 2:len
                        fitteda = loadJmruiAmares(char(inp{el}));
                        fitted = [fitted,fitteda];
                    end
                    
                    runbool = 1;
                    
                else
                    
                    canrun = 0;
                
                end
                
            end
            
        end
        
    end
    
end
                
%% Notes
% The input used in the example is:
%%
% _inp_: {'Decay_Dissolution_17_10_19_even.txt','Decay_Dissolution_17_10_19_odd.txt'}
%%
% The example was run by putting:
%%
% fitted = processAMARES({'Decay_Dissolution_17_10_19_even.txt','Decay_Dissolution_17_10_19_odd.txt'})
%%
% into the command window.