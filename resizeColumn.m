%% Resizing a Column Vector
%%
% The role of this function is to resize an inputted column vector to a
% specified size. If the size is larger than the inputted column vector,
% the values of the column vector are spread out in the new column vector.
% If the reverse is true, the inputted column vector is truncated
%% Inputs
% _iarray_: is the inputted numeric column vector
%%
% _size_: is the size of the desired column vector, the number of elements
% in it
%% Output
% _array_: is the resized column vector

function array = resizeColumn(iarray,size)

    arrayreal = 1;
    lenarray = length(iarray);
    
    %% Verifying the Input is a Numeric Array
    % If the input is not a numeric array, the output is a column vector of
    % ones to the specified size
        
    for el = 1:lenarray
        tiarray = string(class(iarray(el)));
        if tiarray ~= "double"
            arrayreal = 0;
        end
        tiarray1 = isfinite(iarray(el));
        if tiarray1 ~= 1
            arrayreal = 0;
        end
    end
        
    if arrayreal == 0
        
        array = ones(size,1);
        
    else
        
        %% Resizing the Inputted Column Vector
        
        if size > lenarray
            
            arrayvals = iarray;
            array = zeros(size,1);
            count = 0;
            arrayind = 1;
            countcrit = floor(size/lenarray);
            
            for el = 1:size
                if count < countcrit
                    array(el) = arrayvals(arrayind);
                    count = count+1;
                else
                    arrayind = arrayind+1;
                    if arrayind > length(arrayvals)
                        arrayind = length(arrayvals);
                    end
                    array(el) = arrayvals(arrayind);
                    count = 1;
                end
            end
            
        else
            array = iarray(1:size);
        end
        
    end
        
end

%% Notes
% The inputs used in the example were:
%%
% _iarray_: [5;5;10;10;15;15]
%%
% _size_: 11
%% 
% The example was run by putting:
%%
% array = resizeColumn([5;5;10;10;15;15],11)
%%
% into the command window