%% Generating a Numeric Column Vector Entry by Entry
%% 
%% Input
% _numEntries_: is an optional input that sets the size of the generated
% column vector
%% Output
% _array_: is the column vector of all the values the user has inputted
%% Child Functions
% _isint_: checks if an input is an integer

function array = createcolumnNum(numEntries)

    %% Verifying the Existence and Validity of numEntries

    nEbool = 1;
    
    if nargin < 1
        nEbool = 0;
    elseif isint(nEbool) ~= 1
        nEbool = 0;
    end
    
    if nEbool ~= 1
        
        %% Verifying that the First User Input is Numeric
        % _str2double_ converts any non-numeric input into NaN, meaning
        % that the output of _str2double_ can be tested for numericy by the
        % property that numeric values are finite using _isfinite_.
        
        array = [];
        prompt = 'Enter the first value: ';
        inp = input(prompt,'s');
        inpa = str2double(inp);
        bool = isfinite(inpa);
        
        if bool == 1
            
            array = inpa;
            
        else
            
            while bool == 0
                
                inp = input('Please enter a number for the first value: ','s');
                inpa = str2double(inp);
                bool = isfinite(inpa);
                
                if bool == 1
                    array = inpa;
                end
                
            end
            
        end
        
        %% Appending Additional Values to the Column Vector
        % If the size of the array is not specified, the user will be
        % called to indicate if the array should be expanded or terminated.
        
        addbool = 1;
        
        while addbool == 1
            
            numval = length(array);
            numvalstr = num2str(numval);
            
            if numval == 1
                numdisp = strcat(numvalstr, {' '}, 'entry has been entered');
            else
                numdisp = strcat(numvalstr, {' '}, 'entries have been entered');
            end
            
            disp(numdisp)
            
            prompt1 = 'Would you like to enter another value? (Y/N): ';
            add = input(prompt1,'s');
            addbool = checkYN(add);
            
            if addbool == 1
                
                prompt2 = 'Enter the next value: ';
                inp = input(prompt2,'s');
                inpa = str2double(inp);
                bool = isfinite(inpa);
        
                if bool == 1
                    
                    array = [array;inpa];
                    
                else
                    
                    while bool == 0
                        
                        inp = input('Error: Please enter a number: ','s');
                        inpa = str2double(inp);
                        bool = isfinite(inpa);
                        
                        if bool == 1
                            array = [array;inpa];
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    else
        
        %% Populating _array_ if the Size of it has been Defined
        
        array = zeros(numEntries,1);
        prompt = 'Enter the first value: ';
        inp = input(prompt,'s');
        inpa = str2double(inp);
        bool = isfinite(inpa);
        
        if bool == 1
            
            array(1) = inpa;
            
        else
            
            while bool == 0
                
                inp = input('Please enter a number for the first value: ','s');
                inpa = str2double(inp);
                bool = isfinite(inpa);
                
                if bool == 1
                    array(1) = inpa;
                end
                
            end
            
        end
        
        for el = 2:numEntries
            
            numval = el-1;
            numvalstr = num2str(numval);
            
            if numval == 1
                numdisp = strcat(numvalstr, {' '}, 'entry has been entered');
            else
                numdisp = strcat(numvalstr, {' '}, 'entries have been entered');
            end
            
            disp(numdisp)
            prompt2 = 'Enter the next value: ';
            inp = input(prompt2,'s');
            inpa = str2double(inp);
            bool = isfinite(inpa);
        
            if bool == 1
                
                array(el) = inpa;
                
            else
                
                while bool == 0
                    
                    inp = input('Error: Please enter a number: ','s');
                    inpa = str2double(inp);
                    bool = isfinite(inpa);
                    
                    if bool == 1
                       array(el) = inpa;
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

%% Notes
% The input used in the example is:
%%
% _numEntries_: 5
%%
% The example was run by putting:
%%
% array = createcolumnNum(5)
%%
% into the command window
            