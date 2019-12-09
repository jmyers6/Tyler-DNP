%% Checking if an Input has been Set to 'A' or 'M'
%%
%% Input
% _inp_: is any variable, file etc.
%% Output
% _bool_: is 0 if _inp_ is neither 'A' nor 'M'. Otherwise, _bool_ is 1 if
% _inp_ is 'A' or 2 if _inp_ is 'M'

function bool = checkinp(inp)

    %% Setting the Value of _bool_

    bool = 0;
    
    if inp == 'A'
        bool = 1;
    elseif inp == 'a'
        bool = 1;
    elseif inp == 'M'
        bool = 2;
    elseif inp == 'm'
        bool = 2;
    end
    
end

%% Notes
% The input used in the example is:
%%
% _inp_: 'a'
%%
% The example was run by putting:
%%
% bool = checkinp('a') 
%%
% in the command window