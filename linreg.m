%% Performing Ordinary Least Squares Linear Regression on a Dataset Split into Sections
%%
% If multiple sections of data are inside one set of _x_ and _y_ arrays,
% _linreg_ can perform OLS regression on the individual sections provided
% the indices where each section begins is given
%% Inputs
% _x_: is a column vector containing the data on the x-axis
%%
% _y_: is an array containing the data on the y-axis. Each row representing
% data corresponding to a different data series with the same x-values
%%
% _secinds_: is either a column or row vector containing the first index of
% each section of data on which OLS linear regression will be performed
%% Outputs
% _grads_: is an array where each column has the gradient for a section of
% the data and where each row represents each data series
%%
% _ints_: is an array where each column has the y-intercept for a section 
% of the data and where each row represents each data series
%%
% _Rsquareds_: is an array where each column has the coefficient of 
% determination for a section  of the data and where each row represents 
% each data series

function [grads,ints,Rsquareds] = linreg(x,y,secinds)

    %% Determining the Number of Times OLS Linear Regression Needs to be Performed

    numsecs = length(secinds);
    rounds = length(y(1,:));
    
    grads = zeros(numsecs,rounds);
    ints = zeros(numsecs,rounds);
    Rsquareds = zeros(numsecs,rounds);
    
    %% Performing OLS Linear Regression on Each Section of Each Data Series
    
    if numsecs == 1
        if rounds == 1
            
            mdl = fitlm(x,y);
        
            gradsa = mdl.Coefficients(2,1);
            gradsb = table2array(gradsa);
            grads = gradsb;
    
            inta = mdl.Coefficients(1,1);
            intb = table2array(inta);
            ints = intb;
                
            Rsquareds = mdl.Rsquared.Adjusted;
            
        else
            for el = 1:rounds
                
                mdl = fitlm(x,y(:,el));
        
                gradsa = mdl.Coefficients(2,1);
                gradsb = table2array(gradsa);
                grads(el) = gradsb;
    
                inta = mdl.Coefficients(1,1);
                intb = table2array(inta);
                ints(el) = intb;
                
                Rsquareds(el) = mdl.Rsquared.Adjusted;
                
            end
        end 
    else
        for el = 1:numsecs
            for ele = 1:rounds
                if el ~= numsecs
        
                    mdl = fitlm(x(secinds(el):(secinds(el+1))-1),y(secinds(el):(secinds(el+1))-1,ele));
    
                    gradsa = mdl.Coefficients(2,1);
                    gradsb = table2array(gradsa);
                    grad = gradsb;
                    grads(el,ele) = grad;
    
                    inta = mdl.Coefficients(1,1);
                    intb = table2array(inta);
                    int = intb;
                    ints(el,ele) = int;
    
                    Rsquared = mdl.Rsquared.Adjusted;
                    Rsquareds(el,ele) = Rsquared;
                
                else
                
                    mdl = fitlm(x(secinds(el):end),y(secinds(el):end,ele));
    
                    gradsa = mdl.Coefficients(2,1);
                    gradsb = table2array(gradsa);
                    grad = gradsb;
                    grads(el,ele) = grad;
    
                    inta = mdl.Coefficients(1,1);
                    intb = table2array(inta);
                    int = intb;
                    ints(el,ele) = int;
    
                    Rsquared = mdl.Rsquared.Adjusted;
                    Rsquareds(el,ele) = Rsquared;
                    
                end 
            end
        end
    end
    
end

%% Notes
% The inputs used in the example were:
%%
% _x_: [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]
%%
% _y_: [1 2; 2 4; 4 8; 6 12; 8 16; 11 21; 14 26; 17 31; 20 36; 23 41]
%%
% _secinds_: [1;3;6]
%% 
% The example was run by putting:
%%
% [grads,ints,Rsquareds] = linreg([1; 2; 3; 4; 5; 6; 7; 8; 9; 10],
% [1 2; 2 4; 4 8; 6 12; 8 16; 11 21; 14 26; 17 31; 20 36; 23 41],[1;3;6])
%%
% into the command window