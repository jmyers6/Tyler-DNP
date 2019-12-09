%% Estimating the T1 Relaxation Constand and Flip Angle Correction Factor from OLS Linearised Raw Data
%%
% For each section, the data is treated as continuous and, each section is 
% modelled with the following relation:
%% 
% $$ Mz = M0 \times cos^{t/TR}(alpha \times \theta) \times
% exp\left(-\frac{t}{T1}\right) $$
%%
% where _Mz_ represents the magnetisation in the z-direction, _M0_ is the
% initial magnetisation in the z-direction, _t_ is the time, _TR_ is the
% average repetition time for the section (the average time interval before
% taking a measurement), _alpha_ is the flip angle correction factor, $$
% \theta $$ is the estimated flip angle found from the _flip1_ parameter of
% the procpar file and _T1_ is the longitudinal relaxation constant, which
% describes the decay of hyperpolarisation
%%
% The above relation is not strictly true, since signal is actually
% proportional to Mxy and the data is discrete with the sense of the exact
% time when a measurement is taken, but the relation yields a good first
% estimate
%% 
% The model is applied to the data by linearising it using:
%%
% $$ \ln{Mz} = \left(\frac{1}{TR}\times \ln{[cos(alpha \times \theta)]} -
% \frac{1}{T1}\right)\times t+\ln{M0} $$
%%
% By applying a linear model to the logarithm of the signal data, the
% gradient of the data is:
%% 
% $$ \left(\frac{1}{TR}\times \ln{[cos(alpha \times \theta)]} -
% \frac{1}{T1}\right) $$
%%
% This function iterates through _alpha_ to find the best estimate for
% _T1_. The best estimate is characterised by minimising the coefficient of
% variation between the different sections of data
%% Inputs
% _grads_: is an array where each row holds the gradients for different
% sections of measurements for the same NMR peak. The different sections
% correspond to different flip angles. The columns hold data for different
% NMR peaks
%%
% _flips_: is an array holding the values of the estimated flip angles for
% each section of data
%%
% _TRs_: is an array holding the average repetition time for each section
% of data
%% Outputs
% _eT1_: is an array holding the best first estimate for _T1_ for each peak
%%
% _eAlpha_: is an array holding the best first estimate for _alpha_ for
% each peak
%%
% _covs_: is an array holding the coefficients of variations between the
% different secitions of data for the final estimated _T1_ and _alpha_
% values

function [eT1,eAlpha,covs] = findDecayParams(grads,flips,TRs)

    cols = length(grads(:,1));
    rows = length(grads(1,:));
    
    eT1 = zeros(1,rows);
    eAlpha = ones(1,rows);
    
    alphasa = zeros(1,rows);
    alphas = 0.001+alphasa;
    
    facs = ones(1,rows);
    afacs = ones(1,rows);
    afacs = 0.01*afacs;
    
    covs = ones(1,rows);
    covs = 10000*covs;
    
    iTR = 1./TRs;
    
    iTRs = zeros(cols,rows);
    
    for el = 1:rows
        iTRs(:,el) = iTR;
    end
    
    %% Setting the Minimum and Maximum _alpha_ Values
    % _alpha_ cannot ever be allowed to be zero otherwise _T1_ will be
    % undefined. In a hyperpolarisation experiment, the flip angles used
    % can never be greater than 90°, or all of the polarisation will be
    % lost, so _alpha_ is not allowed to iterate greater than $$
    % 90/(Max~Estiamted~Flip~Angle) $$
    
    minAlpha = 0.001;
    maxAlphaa = max(flips);
    maxAlpha = floor(90/maxAlphaa);
    
    count = 0;
    
    avoid = [];
    
    %% _alpha_ is Iterated 200 Times to Find the Best Value
    % First _alpha_ is verified to be valid, not 0 or smaller or greater
    % than the maximum _alpha_ value. If _alpha_ is invalid, it is iterated
    % until it is valid again.
    %%
    % _T1_ is calculated using:
    %%
    % $$ T1 = \frac{1}{\frac{1}{TR}\times \ln{[cos(alpha\times \theta)]} -
    % gradient} $$
    %%
    % Since _T1_ can't be negative, the first half of the denominator must
    % be greater than the gradient. If that is not the case, _alpha_ is
    % iterated up to 1000 times until that is true. If more than 1000
    % iterations occur, the function gives up.
    %%
    % After _T1_ is calcualted, the coefficient of variation (cov) is 
    % calculated for all the _T1_s in a section. If the cov is better than
    % currently stored value, the estimated stored values for _alpha_ and
    % _T1_ are set to the currently calculated values and _alpha_ is
    % iterated in the same direction as it has been going with a bigger
    % jump than before. If that is not the case, _alpha_ is iterated in the
    % opposite direction that it had been previously with a smaller jump
    % than the previous one.
    
    while count < 200
        
        for el = 1:rows
            while alphas(el) <= minAlpha
                facs(el) = 1;
                dafac = 1.2*facs(el)*afacs(el);
                alphas(el) = alphas(el)+dafac;
            end
            while alphas(el) >= maxAlpha
                facs(el) = -1;
                dafac = 1.2*facs(el)*afacs(el);
                alphas(el) = alphas(el)+dafac;
            end
        end
        
        angle = alphas.*flips;
        coss = cosd(angle);
        lnof = coss;
        lnp = log(lnof);
        halfdenom = iTRs.*lnp;
        
        trut = 1;
        
        while trut == 1
            
            trut = 0;
            
            for el = 1:rows
                for ele = 1:cols
                    halfdenomn = halfdenom(ele,el);
                    counter = 0;
                    bool = 0;
                    if isempty(avoid) ~= 1
                        for elem = 1:length(avoid)
                            if el == avoid(elem)
                                bool = 1;
                            end
                        end
                    end
                    if bool == 0
                        while counter < 1000
                            if halfdenom(ele,el) <= grads(ele,el)
                                trut = 1;
                                facs(el) = -1*facs(el);
                                if halfdenom(ele,el) >= halfdenomn
                                    facs(el) = -1*facs(el);
                                end
                                dafac = 1.2*facs(el)*afacs(el);
                                if alphas(el)+dafac < maxAlpha
                                    alphas(el) = alphas(el)+dafac;
                                elseif alphas(el)+dafac > minAlpha
                                    alphas(el) = alphas(el)+dafac;
                                else
                                    counter = 1000;
                                end
                                angle(:,el) = alphas(el)*flips;
                                coss = cosd(angle(ele,el));
                                lnof = coss;
                                lnp = log(lnof);
                                halfdenom(ele,el) = iTRs(ele,el)*lnp;
                                if halfdenom(ele,el) > halfdenomn
                                halfdenomn = halfdenom(ele,el);
                                end
                                counter = counter+1;
                                if counter == 1000
                                avoid = [avoid el];
                                end
                            else
                                counter = 1000;
                            end
                        end
                    end
                end
            end
            
        end
        
        denom = halfdenom-grads;
        T1sn = 1./denom;
        covsn = findCOV(T1sn);
        
        for el = 1:rows
            if covsn(el) < covs(el)
                
                covs(el) = covsn(el);
                
                eT1(el) = mean(T1sn(:,el));
                eAlpha(el) = alphas(el);
                
                alphabacka = 0.1*facs(el)*afacs(el);
                alphaback = alphas(el)-alphabacka;
                    
                anglesh = alphaback.*flips;
                cossh = cosd(anglesh);
                lnofh = cossh;
                lnph = log(lnofh);
                halfdenomh = iTRs(:,el).*lnph;
                denomh = halfdenomh-grads(:,el);
                
                T1snh = 1./denomh;
                covsnh = findCOV(T1snh);
                
                if covsnh < covs(el)
                    
                    covs(el) = covsnh;
                    
                    eT1(el) = mean(T1snh);
                    eAlpha(el) = alphaback;
                    
                    facs(el) = -1*facs(el);
                    afacs(el) = 0.1*afacs(el);
                    afacsmove = facs(el)*afacs(el);
                    
                    alphas(el) = alphas(el)+afacsmove;
                    
                else
                    
                    afacs(el) = 2*afacs(el);
                    afacsmove = facs(el)*afacs(el);
                    
                    alphas(el) = alphas(el)+afacsmove;
                    
                end
                
            elseif covsn(el) >= covs(el)
                
                afacs(el) = 0.9*afacs(el);
                facs(el) = -1*facs(el);
                afacsmove = facs(el)*afacs(el);
                
                alphas(el) = alphas(el)+afacsmove;
                
            end
        end
        
        count = count+1;
        
    end
    
    if isempty(avoid) ~= 1
        disp('It was not possible to calculate T1 for peaks corresponding to the following indices ')
        disp(string(avoid))
    end
    
end

%% Notes
% The inputs in the example were:
%%
% _grads_: [-0.0286;-0.0520;-0.0888;-0.0284;-0.0519;-0.0875]
%%
% _flips_: [5;10;15;5;10;15]
%%
% _TRs_: [1;1;1;1;1;1]
%%
% The example was run by putting:
%%
% [eT1,eAlpha,covs] = findDecayParams(
% [-0.0286;-0.0520;-0.0888;-0.0284;-0.0519;-0.0875],[5;10;15;5;10;15],
% [1;1;1;1;1;1])
%%
% into the command window
                
        