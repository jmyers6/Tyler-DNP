%% Verifying if an Input is an Integer
%%
%% Input
% _num_: is any variable, file, etc.
%% Output
% _bool_: is 0 if _num_ is not an integer and is 1 if _num_ is an integer

function bool = isint(num)

    bool = 0;
    
    %% Testing if _num_ is an Integer
    % All numbers in MATLAB are by default double, not int. Therefore,
    % checking if a variable value is an integer is not completely straight
    % forward. Firstly, if the class of _num_ is a double, then the only
    % way to verify if it is in an integer is indirectly. A property of all
    % integers is that they are finite, so while inf, NaN etc. are double,
    % they are not finite; therefore, checking if a double is finite can
    % allow for filtering out inf, NaN etc. However, integers are only
    % single whole numbers, not arrays, so the length of the result of
    % checking if _num_ is finite must also be 1. Lastly, a property of
    % integers if that if floor division is performed on them, the result
    % will equal the input. Therefore, if _num_ is a double, checking the
    % three described properties will determine if _num_ is an integer. 
    %%
    % However, if _num_'s class is an int class, the function should still
    % output that _num_ is an int. However, MATLAB has multiple classes of
    % ints, yet the first three characters in all the int classes are
    % 'int'. Therefore, by checking the condition if the first three
    % charactersof _num_'s class are 'int', it can be determined if _num_
    % is an int.
    
    a = isfinite(num);
    lena = length(a);
    b = floor(num);
    type = class(num);
    c = string(strcat(type(1),type(2),type(3)));
    
    if c == "dou"
    
        if a == 1
            
            if lena == 1
        
                if num == b
                    bool = 1;
                end
                
            end
        
        end
        
    elseif c == "int"
        
        bool = 1;
        
    end
    
end

%% Notes
% The input used in the example is:
%%
% _num_:int64(9)
%%
% The function was run by putting:
%%
% bool = isint(int64(9))
%%
% into the command window