%% Finding the Gyromagnetic Ratio Given the Elemental Abreviation
%%
%% Input
% _element_: is the elemental abreviation of an element detectable by NMR
%% Output
% _gyro_: is the gyromagnetic ratio of the input in rad per second per
% Tesla

function gyro = findgyro(element)

    %% Elements with Stored Gyromagnetic Ratios

    elements = ["H";"D";"C";"N";"O";"P";"Si"];
    
    %% Verifying _element_ is Stored in the List of Gyromagnetic Ratios
    % If the input is not stored in the array of gyromagnetic ratios, the
    % user can type 'ls' to see all currently available gyromagnetic ratios
    
    elebool = 1;
    
    if nargin ~= 1
        elebool = 0;
    elseif isempty(element) == 1
        elebool = 0;
    elseif string(class(element)) ~= "char"
        elebool = 0;
    end

    if elebool == 1
        loc = find(elements == string(element));
        if isint(loc) == 0
            elebool = 0;
        end
    end
    
    while elebool == 0
        elebool = 1;
        element = input('Enter the abreviation of the element used to collect data, or enter ls to see the list of all possible inputs: ','s');
        if string(element) == "ls"
            disp(elements)
        end
        loc = find(elements == element);
        if isint(loc) == 0
            elebool = 0;
        end
    end
    
    %% Assigning the Gyromagnetic Ratio Corresponding to the Input
    
    gyros = [267520000;41066000;67280000;-27130000;-36280000;108390000;-53190000];
    
    gyro = gyros(loc);
    
end

%% Notes
% The input in the example was:
%%
% _element_: 'C'
%%
% The example was run by putting:
%% 
% gyro = findgyro('C')
%%
% into the command window