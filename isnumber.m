%% Verifying if an Input is a Number
%%
%% Input
% _num_: is any input
%% Output
% _bool_: is 1 if the input is a number, or 0 otherwise

function bool = isnumber(num)

    if nargin ~= 1
        disp('Error: No input entered')
        return
    end
    
    bool = 0;
    
    if string(class(num)) == "double"
        cont = isfinite(num);
        if cont == 1
            bool = 1;
        end
    end
    
end

%% Notes
% In the example, the input was:
%%
% _num_: 5
%%
% The example was run by putting:
%%
% bool = isnumber(5)
%%
% into the command window