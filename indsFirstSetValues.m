%% Finding the Indices where the Values in an Array Change and Finding the Values they Change to
%%
%% Input
% _array_: is either a numeric column vector or a numeric row vector
%% Outputs
% _secvals_: is an array that contains the values that the values in the
% input array become
%%
% _secinds_: is an array that contains the indices where the values in the
% inputted array change values

function [secvals,secinds] = indsFirstSetValues(array)

    lenarray = length(array);
    els = 1;
    
    tval = array(1);
    
    %% Establishing the Size of _secvals_ and _secinds_
    
    for el = 2:lenarray
        if array(el) ~= tval
            els = els+1;
            tval = array(el);
        end
    end
    
    secvals = zeros(els,1);
    secinds = zeros(els,1);
    
    %% Generating _secvals_ and _secinds_
    
    elsf = 1;
    secvals(elsf) = array(elsf);
    secinds(elsf) = elsf;
    
    for el = 2:lenarray
        if array(el) ~= secvals(elsf)
            elsf = elsf+1;
            secvals(elsf) = array(el);
            secinds(elsf) = el;
        end
    end
    
end

%% Notes
% The input used in the example was:
%% 
% _array_: [5 5 5 8 8 9 9 9 9 10]
%%
% The example was run by putting:
%% 
% [secvals,secinds] = indsFirstSetValues([5 5 5 8 8 9 9 9 9 10])
%%
% into the command window