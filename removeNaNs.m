%% Removing any Rows in an Inputted Array Containing NaN
%%
%% Inputs
% _iarray_: is a numeric array, where some rows 
% contain NaN (Not a number)
%%
% _len_: is the number of rows in the output array. This parameter should 
% be specified, especially if the input and ouput arrays are large, so that
% MATLAB properly allocates memory for the task
%% Output
% _array_: is the outputted numeric array after the NaNs have been removed
% from _iarray_

function array = removeNaNs(iarray,len)

    %% Verifying the Existence and Validity of the Inputted Array

    cont = 1;

    if nargin == 0
        cont = 0;
    elseif string(class(iarray)) ~= "double"
        cont = 0;
    end
    
    if cont == 0
        disp('Error: Invalid input. Input must be a numeric array')
        return
    end

    cols = length(iarray(1,:));
    
    %% Verifying if the Size of the Output Array has been Specified
    % If the size of the ouput array is specified, the function runs much
    % faster
    
    lenbool = 1;
    
    if nargin < 2
        lenbool = 0;
    elseif isint(len) == 0
        lenbool = 0;
    end
    
    if lenbool == 1
        array = zeros(len,cols);
    else
        array = [];
    end
    
    numel = length(iarray(:,1));
    
    count = 1;
    
    %% Iterating through the Input Array Search for NaNs
    % For every row without NaNs, the row is appended to the outputted
    % array
    
    for el = 1:numel
        
        entbool = 1;
        
        for ele = 1:cols
            if isnan(iarray(el,ele))
                entbool = 0;
            end
        end
        
        if entbool == 1
            if lenbool == 1
                array(count,:) = iarray(el,:);
                count = count+1;
            else
                array = [array;iarray(el,:)];
            end
        end
        
    end
    
end

%% Notes
% The inputs used in the example were:
%%
% _iarray_: [5;8;45;NaN;54;3787;1;NaN;NaN;777]
%%
% _len_: 7
%%
% The example was run by putting:
%%
% array = removeNaNs([5;8;45;NaN;54;3787;1;NaN;NaN;777],7) 
%%
% into the command window