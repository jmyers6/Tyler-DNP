%% Checking if an Input has been Set to 'Y' or 'N'
%%
%% Input
% _inp_: is any variable, file etc.
%% Output
% _bool_: is 0 if _inp_ is neither 'Y' nor 'N'. Otherwise, _bool_ is 1 if
% _inp_ is 'Y' or 2 if _inp_ is 'N'

function bool = checkYN(yn)

    %% Setting the Value of _bool_

    bool = 0;
    
    if string(yn) == "Y"
        bool = 1;
    elseif string(yn) == "y"
        bool = 1;
    elseif string(yn) == "N"
        bool = 2;
    elseif string(yn) == "n"
        bool = 2;
    end
    
end

%% Notes
% The input used in the example is:
%%
% _inp_: 'N'
%%
% The example was run by putting:
%%
% bool = checkYN('N') 
%%
% in the command window