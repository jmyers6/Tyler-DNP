%% Converting Zeros in an Array to NaNs
%% 
%% Input
% _iarray_: is a numeric array
%% Output
% _array_: is an array where all zeros in the input are replaced with 'NaN'

function array = zeroToNaN(iarray)

    cols = length(iarray(:,1));
    rows = length(iarray(1,:));
    
    array = zeros(cols,rows);
    
    for el = 1:rows
        for ele = 1:cols
            if iarray(ele,el) == 0
                array(ele,el) = NaN;
            else
                array(ele,el) = iarray(ele,el);
            end
        end
    end
    
end
%% Notes
% The input used in the example was:
%%
% _iarray_: [1 4 0 7 6 0 45]
%%
% The example was run by putting:
%%
% array = zeroToNaN([1 4 0 7 6 0 45])
%%
% into the command window