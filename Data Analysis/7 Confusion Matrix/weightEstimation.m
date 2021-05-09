
%---   Parallelized EM for fitting the full model (mixture of 4 model)  ---
%--------------------------------------------------------------------------

function params = weightEstimation ( sampleGroupNum )
    
    warning('off','all')
%    close all
%    clc
    
    %######################################################################
    %#              Critical parameters
    %######################################################################

    subjectsNum             = 15                                                    ;
    EMiterationNum          = 40                                                    ;
    
    model                   = zeros (4,1)                                           ;
    model (1)               = 1                     ;% Model-based                  ;
    model (2)               = 1                     ;% Pruning                      ;
    model (3)               = 0                     ;% Model-free (Elig=1)          ;
    model (4)               = 0                     ;% Model-free (Elig=0)          ;

    fminuncInitialPointsNum = 2                                                     ;
    normalizationSamplesNum = 500                                                   ;
    iBICSamplesNum          = 5000                                                  ;
    fminuncMaxIterationNum  = 50000                                                 ;
    fminuncMaxFunEvals      = 500000                                                ;
           
    %######################################################################
    %#    Defining available hyperparameters and priors over them:
    %#                mu     = prior hyperparameter mean
    %#                sigma2 = prior hyperparameter covariance matrix
    %######################################################################
    modelsNum = model(1) + model(2) + model(3) + model(4)                           ;   % Number of models = 1..4
    maxFreeParametersNum    = 12                                                    ;   % Maximum number of free parameters
    freeParametersNum       = 0                                                     ;   % Number of free parameters, determined by model
    isParamAvailable        = zeros (maxFreeParametersNum,1)                        ;   % 1: parameter is available;  0: parameter is not available
    MU                      = zeros (freeParametersNum,1)                           ;   % Means value of the hyperparamteres
    sigma2                  = zeros (freeParametersNum,freeParametersNum)           ;   % Covariance matrix over the hyperparamteres
    paramMap                = zeros (maxFreeParametersNum,1)                        ;   % Mapping from potential parameters, to availabale parameters
    
    %----------------------- Defining all potential parameters
    mu_potentialParams      = zeros (maxFreeParametersNum,1)                        ;
    sigma2_potentialParams  = zeros (maxFreeParametersNum,1)                        ;
    
    %--- Weight of first level being MB
    mu_potentialParams    (1)               = 1     ;
    sigma2_potentialParams(1)               = 5     ;
    %--- Weight of first level being Pruning
    mu_potentialParams    (2)               = 1     ;
    sigma2_potentialParams(2)               = 5     ;
    %--- Weight of first level being Model-free, with eligibility trace = 1
    mu_potentialParams    (3)               = 1     ;
    sigma2_potentialParams(3)               = 5     ;
    %--- Weight of second level being MB
    mu_potentialParams    (4)               = 1     ;
    sigma2_potentialParams(4)               = 5     ;
    %--- stay bias  : probability of repeating rewarded
    mu_potentialParams    (5)               = 0     ;
    sigma2_potentialParams(5)               = 0.5   ;
    %--- Alpha     : MB learning rate
    mu_potentialParams    (6)               = 0     ;
    sigma2_potentialParams(6)               = 10    ;
    %--- Alpha     : MF learning rate
    mu_potentialParams    (7)               = 0     ;
    sigma2_potentialParams(7)               = 10    ;
    %--- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    mu_potentialParams    (8)               = 0     ;
    sigma2_potentialParams(8)               = 10    ;
    %--- Alpha     : Learning rate for the Model-free with eligibility trace = 1
    mu_potentialParams    (9)               = 0     ;
    sigma2_potentialParams(9)               = 10    ;
    %--- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    mu_potentialParams    (10)              = 0     ;
    sigma2_potentialParams(10)              = 10    ;
    %--- Beta      : rate of exploration for the first level
    mu_potentialParams    (11)              = 2     ;
    sigma2_potentialParams(11)              = 2    ;
    %--- Beta      : rate of exploration for the second level
    mu_potentialParams    (12)              = 2     ;
    sigma2_potentialParams(12)              = 2    ;


%?????
%mu_potentialParams    =[1 1.9458    0.5693  1  0.0391    3.4460    1.0965   -0.4194   -1.7705    1.6348    1.5972    1.3432];
%sigma2_potentialParams=[1 0.8193    2.0024  1  0.0017    1.6643    1.8707    0.5703    2.1391    3.5165    0.0328    0.1083];
 
   





    %----------------------- Determining available parameters
    isParamAvailable     (4) = 1 ;
    isParamAvailable     (5) = 1 ;
    isParamAvailable     (6) = 1 ;
    isParamAvailable     (7) = 1 ;
    isParamAvailable     (8) = 1 ;
    isParamAvailable     (11)= 1 ;
    isParamAvailable     (12)= 1 ;
    if model(3)
        isParamAvailable (9) = 1 ;
        isParamAvailable (10)= 1 ;    
    end    
    
    if modelsNum == 4
        isParamAvailable (1 )= 1 ;
        isParamAvailable (2 )= 1 ;
        isParamAvailable (3 )= 1 ;
    
    elseif modelsNum == 3
        if ~model(1)
            isParamAvailable (2 )= 1 ;
            isParamAvailable (3 )= 1 ;
        elseif ~model(2)
            isParamAvailable (1 )= 1 ;
            isParamAvailable (3 )= 1 ;
        else
            isParamAvailable (1 )= 1 ;
            isParamAvailable (2 )= 1 ;
        end
        
    elseif modelsNum == 2
        if model(1)
            isParamAvailable (1 )= 1 ;
        elseif model(2)
            isParamAvailable (2 )= 1 ;
        elseif model(3)
            isParamAvailable (3 )= 1 ;
                        
        end
    end
    freeParametersNum        = 0 ;       
    for i = 1:maxFreeParametersNum
        if isParamAvailable(i)
            freeParametersNum = freeParametersNum + 1 ;
        end
    end
    %----------------------- AGGREGATION
    MU                      = zeros (freeParametersNum,1)                           ;   % Means value of the hyperparamteres
    sigma2                  = zeros (freeParametersNum,freeParametersNum)           ;   % Covariance matrix over the hyperparamteres
    paramCounter = 1 ;
    for param = 1 : maxFreeParametersNum
        if isParamAvailable(param)
            MU (paramCounter)                   = mu_potentialParams    (param) ;
            sigma2 (paramCounter,paramCounter)  = sigma2_potentialParams(param) ;
            paramMap (param) = paramCounter ;
            paramCounter = paramCounter + 1 ; 
        end
    end

    %######################################################################
    %#              Definitions
    %######################################################################
    
    data                    = cell  (subjectsNum,1)                                 ;
    trialsNum               = zeros (subjectsNum,1)                                 ;
    w                       = zeros (subjectsNum,freeParametersNum)                 ;
    s                       = zeros (freeParametersNum,freeParametersNum,subjectsNum);
    LL                      = zeros (subjectsNum,1)                                 ;
    iters                   = zeros (subjectsNum,1)                                 ;
    w_prev                  = zeros (subjectsNum,freeParametersNum)                 ;
    s_prev                  = zeros (freeParametersNum,freeParametersNum,subjectsNum);
    LL_prev                 = zeros (subjectsNum,1)                                 ;
    MU_prev                 = zeros (freeParametersNum,1)                           ;
    sigma2_prev             = zeros (freeParametersNum,freeParametersNum)           ;

    wMeanL1                   = zeros (4,1)                                           ;
    wVariL1                   = zeros (4,1)                                           ;
    wMeanL1_prev              = zeros (4,1)                                           ;
    wVariL1_prev              = zeros (4,1)                                           ;
    wMeanL1Ind                = zeros (4,subjectsNum)                                 ;
    wMeanL1IndPrev            = zeros (4,subjectsNum)                                 ;

    wMeanL2                 = zeros (2,1)                                           ;
    wVariL2                 = zeros (2,1)                                           ;
    wMeanL2_prev            = zeros (2,1)                                           ;
    wVariL2_prev            = zeros (2,1)                                           ;
    wMeanL2Ind              = zeros (2,subjectsNum)                                 ;
    wMeanIndL2Prev          = zeros (2,subjectsNum)                                 ;

    %######################################################################
    %#                            Initializations
    %######################################################################

    for subject = 1 : subjectsNum
        w(subject,:)   = MU ;
        s(:,:,subject) = sigma2 ;
    end
    
    iBIC = 0 ;
    
%    outputFile = fopen(['Results/Group',int2str(group),'-model',int2str(16 - 8*model(1) - 4*model(2) - 2*model(3) - model(4)),'.txt'],'w');
    %------------------------ Plotting and coloring setup
%    HyperCorrFig = figure('Position', [5  , 10  , 350, 300 ]);
%    IndivCorrFig = figure('Position', [5  , 350 , 350, 300 ]);
%    param1and2Fig= figure('Position', [5  , 700 , 350, 300 ]);
%    iBICFig      = figure('Position', [5  , 1050, 350, 300 ]);
%    weightsFig   = figure('Position', [300, 10 ,  400, 500 ]);
%    mainFig      = figure('Position', [700, 10  , 1000,800 ]); 
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 14)
    set(0,'DefaultAxesFontWeight', 'bold')
    colors = define16colors(subjectsNum);

    [wMeanL1 , wVariL1] = normalizeModelsWeightsL1 (MU,sigma2,paramMap,model) ;
    [wMeanL2 , wVariL2] = normalizeModelsWeightsL2 (MU,sigma2,paramMap) ;
    
    %------------------------ Loading data from files    
    for subject = 1 : subjectsNum
        
        data{subject} = dlmread(['./Data/',int2str(sampleGroupNum) ,'/',int2str(subject   ),'.txt']);   
        
        dataSize = size(data{subject});
        trialsNum(subject) = dataSize(1,1);    
    end
    
    %------------------------ defining iBIC samples
    iBICSample = zeros (iBICSamplesNum,freeParametersNum) ;
    zs = zeros (freeParametersNum,1) ;
    os = ones (freeParametersNum,freeParametersNum) ;
    os = diag(diag(os));
    for fp=1:iBICSamplesNum
        iBICSample (fp,:) = mvnrnd (zs,os,1);         
    end

%??????    
%iBIC = computingIBIC (iBICSample,MU,sigma2,subjectsNum,trialsNum,freeParametersNum,iBICSamplesNum,data,paramMap,model,isParamAvailable)
    
    %######################################################################
    %#                                      
    %#                      EXPECTATION MAXIMIZATION                      #
    %#                                      
    %######################################################################       

    for iteration = 1 : EMiterationNum
%        disp([' ----- Sample Group ', int2str(sampleGroupNum),' ----- Iteration ', int2str(iteration)]);
      
%        headerMessageDisplay(outputFile,iteration,EMiterationNum);

        %##################################################################
        %#                             E step                             #
        %##################################################################

        %###### For each Subject ##########################################

        w_prev          = w         ;
        s_prev          = s         ;   
        LL_prev         = LL        ;

        
        parfor subject = 1 : subjectsNum
    
            disp([' ----- Sample Group ', int2str(sampleGroupNum),' ----- Iteration ', int2str(iteration),' ----- Subject ', int2str(subject)]);
                            
            w_searches     = zeros (fminuncInitialPointsNum,freeParametersNum)                  ;
            s_searches     = zeros (freeParametersNum,freeParametersNum,fminuncInitialPointsNum);
            LL_searches    = zeros (fminuncInitialPointsNum,1)                                  ;
            iters_searches = zeros (fminuncInitialPointsNum,1)                                  ;            

            for search = 1 : fminuncInitialPointsNum

                firstTry              = true ;
                notYetPositiveSemiDef = true ;
                
                counter = 0 ;
%                while notYetPositiveSemiDef
                    counter = counter + 1 ;
                    %###### Set initial condition for fminunc #################

                    initialParam = zeros (freeParametersNum,1);
                    if (search==fminuncInitialPointsNum) & firstTry
                        initialParam(:) = w_prev(subject,:) ;
                        firstTry = false ;
                    else
                        for ipar = 1 : freeParametersNum                
                            initialParam(ipar) = normrnd(MU(ipar), sigma2(ipar,ipar));
                        end
                    end
                    
                    %###### Compute maximum likelihood x prior ################
                    options = optimoptions('fminunc','MaxFunEvals',fminuncMaxFunEvals,'MaxIter',fminuncMaxIterationNum,'Display','off','TolFun',0.000000000001,'Algorithm','quasi-newton'); 
                    if counter>10
                        options = optimoptions('fminunc','MaxFunEvals',fminuncMaxFunEvals,'MaxIter',fminuncMaxIterationNum,'Display','off','TolFun',0.000000000001,'Algorithm','trust-region'); 
                    end
                    
                    f = @(X)negLogLikelihoodXprior(X,subject,MU,sigma2,trialsNum(subject),data{subject},paramMap,model,isParamAvailable);
                    [x,fval,exitflag,output,grad,hessian] = fminunc(f,initialParam,options);
                    vars = inv(hessian) ;
                   
                    notYetPositiveSemiDef = ~isPositiveSemiDef(vars); %????????? =false;      
                    
%                end
                w_searches    (search,:)    = x                     ;
                s_searches    (:,:,search)  = vars                  ;          
                LL_searches   (search)      = fval                  ;
                iters_searches(search)      = output.iterations     ;
                
            end
            
            %###### Find the best optimization result ################
            
            [bestLL,best]=min(LL_searches) ;
             
            w(subject,:)    = w_searches    (best,:)     ;
            s(:,:,subject)  = s_searches    (:,:,best)   ;          
            LL(subject)     = LL_searches   (best)       ;
            iters(subject)  = iters_searches(best)       ;

%            displayResultsForIndividual(subject,subjectsNum,w(subject,:),s(:,:,subject),LL(subject),iters(subject),paramMap,model,isParamAvailable,freeParametersNum,trialsNum);

        end
        
%        for subject = 1 : subjectsNum
%            printResultsToFileForIndividuals(outputFile,subject,subjectsNum,w(subject,:),s(:,:,subject),LL(subject),iters(subject),paramMap,model,isParamAvailable,freeParametersNum,trialsNum);
%        end
                                                
        %##################################################################
        %#                             M step                             #
        %##################################################################

        MU_prev     = MU ;  
        sigma2_prev = sigma2 ;
    
        MU_temp     = zeros (freeParametersNum,1);
        sigma2_temp = zeros (freeParametersNum,freeParametersNum) ;
        
        for subject = 1 : subjectsNum            
            MU_temp     = MU_temp     + transpose(w(subject,:) );
            sigma2_temp = sigma2_temp + mtimes( transpose(w(subject,:)) , w(subject,:) ) + s(:,:,subject) ;
        end
            
        MU      = MU_temp / subjectsNum  ;
        sigma2  = sigma2_temp / subjectsNum  - mtimes( MU , transpose(MU) ) ;


        sigma2 = diagonalizing (sigma2,modelsNum,freeParametersNum);
        
        %##################################################################
        %#                  Compute Weights of four models                #
        %##################################################################
        
        %############### For Level 1
        %------------- For hyperparameters        
        wMeanL1_prev = wMeanL1 ;
        wVariL1_prev = wVariL1 ;

        [wMeanL1 , wVariL1] = normalizeModelsWeightsL1 (MU,sigma2,paramMap,model) ;

        %------------- For each individual subject
        wMeanInd_temp1    = zeros (subjectsNum,1) ;
        wMeanInd_temp2    = zeros (subjectsNum,1) ;
        wMeanInd_temp3    = zeros (subjectsNum,1) ;
        wMeanInd_temp4    = zeros (subjectsNum,1) ;
        
        wMeanL1IndPrev = wMeanL1Ind ;
        
        parfor sub=1:subjectsNum            
            res = normalizeModelsWeightsL1 (w(sub,:),s(:,:,sub),paramMap,model);
            wMeanInd_temp1(sub) = res(1);
            wMeanInd_temp2(sub) = res(2);
            wMeanInd_temp3(sub) = res(3);
            wMeanInd_temp4(sub) = res(4);
        end
        
        wMeanL1Ind(1,:) = wMeanInd_temp1 ;
        wMeanL1Ind(2,:) = wMeanInd_temp2 ;
        wMeanL1Ind(3,:) = wMeanInd_temp3 ;
        wMeanL1Ind(4,:) = wMeanInd_temp4 ;
                
        %############### For Level 2
        %------------- For hyperparameters        
        wMeanL2_prev = wMeanL2 ;
        wVariL2_prev = wVariL2 ;

        [wMeanL2 , wVariL2] = normalizeModelsWeightsL2 (MU,sigma2,paramMap) ;
                      
        %------------- For each individual subject
        wMeanL2Ind_temp1    = zeros (subjectsNum,1) ;
        wMeanL2Ind_temp2    = zeros (subjectsNum,1) ;
        
        wMeanIndL2Prev = wMeanL2Ind ;
        
        parfor sub=1:subjectsNum            
            res = normalizeModelsWeightsL2 (w(sub,:),s(:,:,sub),paramMap);
            wMeanL2Ind_temp1(sub) = res(1);
            wMeanL2Ind_temp2(sub) = res(1);
        end
        
        wMeanL2Ind(1,:) = wMeanL2Ind_temp1 ;
        wMeanL2Ind(2,:) = wMeanL2Ind_temp2 ;
        
                
        %##################################################################
        %#                         Displaying                             #
        %##################################################################

%        iBIC_prev = iBIC;
%        if mod(iteration,15)==0
%            iBIC = computingIBIC (iBICSample,MU,sigma2,subjectsNum,trialsNum,freeParametersNum,iBICSamplesNum,data,paramMap,model,isParamAvailable);
%        end

%        displayResultsForGroup(MU,sigma2,mean(LL),paramMap,model,isParamAvailable,freeParametersNum,iBIC);            
%        printResultsToFileForGroup(outputFile,MU,sigma2,mean(LL),paramMap,model,isParamAvailable,freeParametersNum,iBIC);
        
%        plotHyperparameters         (mainFig,iteration, MU_prev,MU,sigma2_prev,sigma2,wMeanL1_prev,wMeanL1,wVariL1_prev,wVariL1,wMeanL2_prev,wMeanL2,wVariL2_prev,wVariL2,isParamAvailable,model,paramMap);
%        plotParameters4Individuals  (mainFig,iteration, subjectsNum,w_prev,w,wMeanL1IndPrev,wMeanL1Ind,wMeanIndL2Prev,wMeanL2Ind,isParamAvailable,colors,model,paramMap);
%        plotIBIC                    (iBICFig,iteration, iBIC,iBIC_prev);
%        plotHyperCorrMatrix         (HyperCorrFig,sigma2,freeParametersNum);
%        plotIndivCorrMatrix         (IndivCorrFig,s,subjectsNum,freeParametersNum);
%        plotParams1and2             (param1and2Fig,w,subjectsNum,isParamAvailable,colors);
%        plotLogLL                   (mainFig,iteration, subjectsNum,LL_prev,LL,colors);
%        plotWeights                 (weightsFig,iteration,MU,sigma2,paramMap,model);


    end
    
    mmmmm = MU(1) ;
    sssss = sigma2(1,1) ;
    params = [ mmmmm , sssss ] ;
%    fclose('all');
    

       
    
%##########################################################################
%####  Computing the posterior (likelikood x prior) for a certain agent####
%##########################################################################    
function negLogLL = negLogLikelihoodXprior(X,subject,MU,sigma2,trialsNum,data,paramMap,model,isParamAvailable)

    priorNegLL =  - log(mvnpdf ( X , MU , sigma2 ));
    negLogLikelihooddy = negLogLikelihood(X,subject,trialsNum,data,paramMap,model,isParamAvailable) ;    
    
    negLogLL = negLogLikelihooddy + priorNegLL ;    
    
%##########################################################################
%####  Computing the likelikood for a certain agent                    ####
%##########################################################################    
function negLogLL = negLogLikelihood(X,subject,trialsNum,data,paramMap,model,isParamAvailable)

    
    W2_MB               = X(paramMap(4 )) ;
    stayBias            = X(paramMap(5 )) ;
    alphaMB             = 1.0 / ( 1 + exp(- X(paramMap(6 )))) ;
    alphaMF             = 1.0 / ( 1 + exp(- X(paramMap(7 )))) ; 
    driftMF             = 1.0 / ( 1 + exp(- X(paramMap(8 )))) ;
    beta1               = exp( X(paramMap(11))) ; 
    beta2               = exp( X(paramMap(12))) ; 
        
    
    if model(3)
        alphaMF_Elig    = 1.0 / ( 1 + exp(- X(paramMap(9 )))) ; 
        driftMF_Elig    = 1.0 / ( 1 + exp(- X(paramMap(10)))) ;
    else
        alphaMF_Elig    = 0               ; 
        driftMF_Elig    = 0               ;
    end

    if isParamAvailable(1)     W1_MB       = X(paramMap(1 )) ;   else    W1_MB      = 0;     end
    if isParamAvailable(2)     W1_Prun     = X(paramMap(2 )) ;   else    W1_Prun    = 0;     end
    if isParamAvailable(3)     W1_MF_Elig  = X(paramMap(3 )) ;   else    W1_MF_Elig = 0;     end


%##########################################################################
%####                    Initializing  the  Agent                      ####
%##########################################################################    
    %------------------------ Defining the transition matrix

    transitionLevel1        = zeros(1,2,2);
    transitionLevel1(1,1,1) = 0.7 ;
    transitionLevel1(1,1,2) = 0.3 ;
    transitionLevel1(1,2,1) = 0.3 ;
    transitionLevel1(1,2,2) = 0.7 ;

    transitionLevel2        = zeros(2,2,4);
    transitionLevel2(1,1,1) = 0.7 ;
    transitionLevel2(1,1,3) = 0.3 ;
    transitionLevel2(1,2,2) = 0.7 ;
    transitionLevel2(1,2,4) = 0.3 ;
    transitionLevel2(2,1,1) = 0.3 ;
    transitionLevel2(2,1,3) = 0.7 ;
    transitionLevel2(2,2,2) = 0.3 ;
    transitionLevel2(2,2,4) = 0.7 ;          

    %------------------------ Agent's parameters   

    QValues_level1_Elig     = zeros (2,1);   % The Q-values of s1=1   and  a1=1 or 2
    QValues_level1_NoElig   = zeros (2,1);   % The Q-values of s1=1   and  a1=1 or 2
    QValues_level2          = zeros (2,2);   % The Q-values of s2=1 or 2   and  a2=1 or 2
    reward                  = zeros (4,1);   % Reward function for the model-based RL

    for i=1:4
        reward(i) = 0.25;
    end

    QValues_level1_Elig  (1,1)=0;
    QValues_level1_Elig  (2,1)=0;
    QValues_level1_NoElig(1,1)=0;
    QValues_level1_NoElig(2,1)=0;
    QValues_level2       (1,1)=0;
    QValues_level2       (1,2)=0;
    QValues_level2       (2,1)=0;
    QValues_level2       (2,2)=0;

    
    
    
    %--------- Normalizing the weights of the competing models at ---------
    %=== Level 1
    e = zeros(4,1);
    e(1) = exp (W1_MB     );
    e(2) = exp (W1_Prun   );
    e(3) = exp (W1_MF_Elig);
    e(4) = exp (1)               ;

    for m=1:4
        if ~model(m)
            e(m) = 0 ;
        end
    end

    m = 4 ;
    while (m>0) & (~model(m))
        m= m-1;
    end
    if m>0
        e(m) = exp(1);
    end

    normalizer = e(1) + e(2) + e(3) + e(4) ;
    if normalizer==0
        normalizer=1;
    end

    e1 = e(1) / normalizer ;
    e2 = e(2) / normalizer ;
    e3 = e(3) / normalizer ;
    e4 = e(4) / normalizer ;           

    %=== Level 2                                                 
    s1 = exp (W2_MB)     ;
    s2 = exp (1)               ;
    normalizer = s1 + s2 ;
    w1 = s1 / normalizer ;
    w2 = s2 / normalizer ;
    %----------------------------------------------------------------------
    
    
        

    logLL       =   0   ;
    a1          =   0   ;
    r           =   0   ;
    previous_a1 = a1 ;                                    
    previous_r  = r  ;                                    
    %###### For each trial ####################
    for trial = 1 : trialsNum              
        
        %###### Load subject's response #######                                    
        s1 = 0           ;
        s2 = data(trial,3)  ; % = 1 or 2
        s3 = data(trial,4)  ; % = 1, 2, 3, or 4
        a1 = data(trial,5)+1; % = 1 or 2 
        a2 = data(trial,6)+1; % = 1 or 2  
        r  = data(trial,17) ; % = 0 or 1                                    
        %###### IF it wasn't a lost trial #####
        if (s2 ~= 0) && (s3 ~= 0)

            %##########################################################################
            %####  Computing the likelikood of a certain trial of a certain agent  ####
            %##########################################################################    

            %############ Second level
            v_MB_L2_s1a1 = transitionLevel2(1,1,1)*reward(1) + transitionLevel2(1,1,3)*reward(3);
            v_MB_L2_s1a2 = transitionLevel2(1,2,2)*reward(2) + transitionLevel2(1,2,4)*reward(4);
            v_MB_L2_s2a1 = transitionLevel2(2,1,1)*reward(1) + transitionLevel2(2,1,3)*reward(3);
            v_MB_L2_s2a2 = transitionLevel2(2,2,2)*reward(2) + transitionLevel2(2,2,4)*reward(4);

            v_MB_L2_s1 = max(v_MB_L2_s1a1,v_MB_L2_s1a2);
            v_MB_L2_s2 = max(v_MB_L2_s2a1,v_MB_L2_s2a2);    

            v_MF_L2_s1 = max(QValues_level2(1,1),QValues_level2(1,2));
            v_MF_L2_s2 = max(QValues_level2(2,1),QValues_level2(2,2));

            %############ First level without Transfer (MB)
            v_L1_noTr_s1a1 = transitionLevel1(1,1,1)*v_MB_L2_s1 + transitionLevel1(1,1,2)*v_MB_L2_s2;
            v_L1_noTr_s1a2 = transitionLevel1(1,2,1)*v_MB_L2_s1 + transitionLevel1(1,2,2)*v_MB_L2_s2;

            %############ First level with Transfer (Pruning)
            v_L1_Tr_s1a1 = transitionLevel1(1,1,1)*v_MF_L2_s1 + transitionLevel1(1,1,2)*v_MF_L2_s2;
            v_L1_Tr_s1a2 = transitionLevel1(1,2,1)*v_MF_L2_s1 + transitionLevel1(1,2,2)*v_MF_L2_s2;

            %############ Weighted Aggregation of the systems
                                                
            %=== Level 1                        
                        
            v_L1_s1a1 =  e1 * v_L1_noTr_s1a1   +   e2 * v_L1_Tr_s1a1 + e3 * QValues_level1_Elig(1) + e4 * QValues_level1_NoElig(1);
            v_L1_s1a2 =  e1 * v_L1_noTr_s1a2   +   e2 * v_L1_Tr_s1a2 + e3 * QValues_level1_Elig(2) + e4 * QValues_level1_NoElig(2);

            %=== Level 2                                                 
                                  
            v_L2_s1a1 =  w2 * QValues_level2(1,1)   +   w1 * v_MB_L2_s1a1 ;
            v_L2_s1a2 =  w2 * QValues_level2(1,2)   +   w1 * v_MB_L2_s1a2 ;
            v_L2_s2a1 =  w2 * QValues_level2(2,1)   +   w1 * v_MB_L2_s2a1 ;
            v_L2_s2a2 =  w2 * QValues_level2(2,2)   +   w1 * v_MB_L2_s2a2 ;

            %############ Adding stay bias
            if      (previous_a1==1)
                v_L1_s1a1 = v_L1_s1a1 + stayBias ;
            elseif  (previous_a1==2)
                v_L1_s1a2 = v_L1_s1a2 + stayBias ;
            end

            %############ Computing the likelihood of the first-step action

            if beta1>500    
                beta1=500;                
            elseif beta1<-500   
                beta1=-500;
            end
            
            expA1 = exp (v_L1_s1a1*beta1);
            expA2 = exp (v_L1_s1a2*beta1);
            
            sum = expA1 + expA2 ;

            logP_A1 = v_L1_s1a1*beta1 - log(sum) ;
            logP_A2 = v_L1_s1a2*beta1 - log(sum) ;
                        
            
            if (a1==1)
                negLogLL_L1 = -logP_A1;
            else
                negLogLL_L1 = -logP_A2;
            end            
            
            %############ Computing the likelihood of the second-step action

            if beta2>500    
                beta2=500;
            elseif beta2<-500   
                beta2=500;
            end

            if (s2==1)        
                
                exps1a1 = exp ( v_L2_s1a1 * beta2 );
                exps1a2 = exp ( v_L2_s1a2 * beta2 );                
                sum =  exps1a1 + exps1a2 ;

                if (a2==1)
                    negLogLL_L2 = - ( v_L2_s1a1*beta2 - log(sum) );
                elseif (a2==2)
                    negLogLL_L2 = - ( v_L2_s1a2*beta2 - log(sum) );
                end
                
            elseif (s2==2)
               
                exps2a1 = exp ( v_L2_s2a1 * beta2 );
                exps2a2 = exp ( v_L2_s2a2 * beta2 );
                sum =  exps2a1 + exps2a2 ;

                if (a2==1)
                    negLogLL_L2 = - ( v_L2_s2a1*beta2 - log(sum) );
                elseif (a2==2)
                    negLogLL_L2 = - ( v_L2_s2a2*beta2 - log(sum) );
                end
            end

            %############ Summing up the two likelihoods    
            negLogLL = negLogLL_L1 + negLogLL_L2 ;

            %##########################################################################
            %####    Summing up the likelikood of all trials of a certain agent    ####
            %##########################################################################    
                                                
            logLL = logLL + negLogLL;
                                    
            %##########################################################################
            %####                    Updating the agent                            ####
            %##########################################################################    
            %----------------- Updating Q-values of first level -------------------
            for a=1:2
               if a==a1
                    QValues_level1_Elig  (a) = QValues_level1_Elig  (a) + alphaMF_Elig*(r-QValues_level1_Elig  (a));
                    QValues_level1_NoElig(a) = QValues_level1_NoElig(a) + alphaMF     * (max (QValues_level2(s2,1) , QValues_level2(s2,2)) - QValues_level1_NoElig(a) ) ;
               else
                    QValues_level1_Elig  (a) = QValues_level1_Elig  (a) + driftMF_Elig*(0-QValues_level1_Elig  (a));
                    QValues_level1_NoElig(a) = QValues_level1_NoElig(a) + driftMF     *(0-QValues_level1_NoElig(a));
               end
            end

            %----------------- Updating Q-values of second level ------------------
            for s=1:2
                for a=1:2
                   if s==s2 & a==a2
                        QValues_level2(s,a) = QValues_level2(s,a) + alphaMF*(r-QValues_level2(s,a));
                   else
                        QValues_level2(s,a) = QValues_level2(s,a) + driftMF*(0-QValues_level2(s,a));
                   end
                end
            end 
                        
            %----------------- Updating Reward Function ---------------------------
            alphaMBdelta = alphaMB*(r-reward(s3));


            normalizer = 0 ;
            for s=1:4
                if s~=s3
                    normalizer = normalizer + (1-r-reward(s)) ;
                end
            end      

            if normalizer == 0 
                normalizer = 1 ;
            end

            for s=1:4
                if s==s3
                    reward (s)    = reward(s) + alphaMBdelta ; 
                else
                    reward (s)    = reward(s) - alphaMBdelta * ( (1-r-reward(s)) / normalizer )   ;
                end
            end

%{
            
            if r==1
                for i = 1 : 4
                    reward(i) = reward(i) + alphaMB*(0-reward(i));
                end
            end
            reward(s3) = reward(s3)+ alphaMB*(r-reward(s3));

    
            %}            

            
            
            
            
    
            previous_a1 = a1 ;
            previous_r  = r  ;                                    

        end
    end
       
    negLogLL = logLL ;

%##########################################################################
%####            Is it a Positive Semidefinite Matrix ?                ####
%##########################################################################    
function positiveSemiDef = isPositiveSemiDef(inMatrix)
    
    positiveSemiDef = false ;
    
    a=isnan(inMatrix) | isinf(inMatrix);

    if all( a(:)== 0)
        eig_A = eig(inMatrix);
        flag = 0;
        for i = 1:rank(inMatrix)
            if eig_A(i) <= 0 
                flag = 1;
            end
        end
        if flag == 1
            positiveSemiDef = false;    
        else
            positiveSemiDef = true;    
        end            
    end

%##########################################################################
%####          Normalizing the weights of the competing models         ####
%##########################################################################        
function [wMeanL1 , wVariL1] = normalizeModelsWeightsL1 (MU,sigma2,paramMap,model) ;
    
    wMeanL1 = zeros (4,1);
    wVariL1 = zeros (4,1);

    modelsNum = model(1) + model(2) + model(3) + model(4) ;   % Number of models = 1..4
        
    if modelsNum == 0
        % Do nothing
    elseif modelsNum == 1
       wMeanL1(1) = 1 ; 
       wVariL1(1) = 0 ; 
    else

        samplesNum = 500 ;        
        samples_old        = zeros (modelsNum,samplesNum) ;
        samples_new        = zeros (modelsNum,samplesNum) ;

        samples_old (1:modelsNum-1,:) = transpose(mvnrnd (MU(1:modelsNum-1),sigma2(1:modelsNum-1,1:modelsNum-1),samplesNum));

        e = zeros (4,1);
        
        for samples=1:samplesNum

            for m = 1:modelsNum-1
                e(m) = exp (samples_old(m,samples)); 
            end
            e(modelsNum) = exp(1);

            sum = 0 ;
            for m = 1:modelsNum
                sum = sum + e(m) ;
            end

            for m = 1:modelsNum
                samples_new (m,samples) = e(m) / sum ;
            end
        end


        for m = 1:modelsNum
            wMeanL1 (m) = mean (samples_new (m,:));
            wVariL1 (m) = var  (samples_new (m,:));
        end                    
    end    
        
function [wMeanL2 , wVariL2] = normalizeModelsWeightsL2 (MU,sigma2,paramMap) ;
    
    wMeanL2 = zeros (2,1);
    wVariL2 = zeros (2,1);

    samplesNum = 500 ;        
    samples_old        = zeros (2,samplesNum) ;
    samples_new        = zeros (2,samplesNum) ;

    mu = MU (paramMap(4));
    s2 = sigma2(paramMap(4),paramMap(4));
    
    samples_old (1,:) = normrnd (mu,s2,samplesNum,1);         

    for samples=1:samplesNum
        e1 =  exp (samples_old(1,samples));
        e2 =  exp (1) ;

        sum = e1+e2;

        samples_new (1,samples) = e1 / sum ;
        samples_new (2,samples) = e2 / sum ;
    end
    
    for i=1:2
        wMeanL2 (i) = mean (samples_new (i,:));
        wVariL2 (i) = var  (samples_new (i,:));
    end
    
%##########################################################################
%####               Diagonalizing the covariance function              ####
%##########################################################################        
function diagCovMat = diagonalizing (covMat,modelsNum,freeParametersNum);
    diagCovMat = diag(diag(covMat));
   
%##########################################################################
%####                       Define 16 Colors                           ####
%##########################################################################    
function colors = define16colors(subjectsNum);
    
    colors=zeros(3,16);

    for subject = 1 : subjectsNum

        if subject<9
            colors(1,subject) = 0.9 ;
        end
        if (subject<5) | ((subject>8) & (subject<13)) 
            colors(2,subject) = 0.9 ;
        end
        if mod(subject,3) == 0  
            colors(3,subject) = 0.9 ;    
        elseif mod(subject+1,3) == 0  
            colors(3,subject) = 0.45 ;
        end
    end    

%##########################################################################
%####                   plot Hyperparameters                           ####
%##########################################################################    
function plotHyperparameters(figRef,iteration,MU_prev,MU,sigma2_prev,sigma2,wMeanL1_prev,wMeanL1,wVariL1_prev,wVariL1,wMeanL2_prev,wMeanL2,wVariL2_prev,wVariL2,isParamAvailable,model,paramMap);

    set(0,'CurrentFigure',figRef);

    counter=1;
    for subplotting = 1 : 4
        subplot(5,3,subplotting);                 
        if model(subplotting)
            x_ax = [iteration-1,iteration] ;        
            MP = [wMeanL1_prev(counter),wMeanL1_prev(counter),wMeanL1_prev(counter)];
            MN = [wMeanL1(counter),wMeanL1(counter),wMeanL1(counter)];
            shadedErrorBar([iteration-1,iteration] , [MP(:),MN(:)], {@mean, @(x_ax) [sqrt(wVariL1_prev(counter)),sqrt(wVariL1(counter))] }, {'-r', 'LineWidth', 2}, 0);
            drawnow
            hold on                

            plot([iteration-1,iteration],[wMeanL1_prev(counter),wMeanL1(counter)],'LineWidth',3,'Color','red');
            counter = counter + 1;
        end
        
        drawnow
        hold on    

        if subplotting==1
            title('Level 1: Model-based weight');
        elseif subplotting==2
            title('Level 1: Pruning weight');
        elseif subplotting==3
            title('Level 1: Model-free (elig=1) weight');
        elseif subplotting==4
            title('Level 1: Model-free (elig=0) weight');
        end            
    end


    for subplotting = 4 : 5
        subplot(5,3,subplotting+1);                 
        x_ax = [iteration-1,iteration] ;
        MP = [wMeanL2_prev(subplotting-3),wMeanL2_prev(subplotting-3),wMeanL2_prev(subplotting-3)];
        MN = [wMeanL2(subplotting-3),wMeanL2(subplotting-3), wMeanL2(subplotting-3)];
        shadedErrorBar([iteration-1,iteration] , [MP(:),MN(:)], {@mean, @(x_ax) [sqrt(wVariL2_prev(subplotting-3)),sqrt(wVariL2(subplotting-3))] }, {'-r', 'LineWidth', 2}, 0);
        drawnow
        hold on                

        plot([iteration-1,iteration],[wMeanL2_prev(subplotting-3),wMeanL2(subplotting-3)],'LineWidth',3,'Color','red');
        drawnow
        hold on    

        if subplotting==4
            title('Level 2: Model-based weight');
        elseif subplotting==5
            title('Level 2: Model-free weight');
        end            
    end


    for subplotting = 5 : 12
        subplot(5,3,subplotting+2);     
        if isParamAvailable(subplotting)
            x_ax = [iteration-1,iteration] ;
            MP = [MU_prev(paramMap(subplotting)) , MU_prev(paramMap(subplotting)) , MU_prev(paramMap(subplotting))];
            MN = [MU(paramMap(subplotting)) , MU(paramMap(subplotting)) , MU(paramMap(subplotting))];
            shadedErrorBar([iteration-1,iteration] , [MP(:),MN(:)], {@mean, @(x_ax) [ sqrt(sigma2_prev(paramMap(subplotting),paramMap(subplotting))) , sqrt(sigma2(paramMap(subplotting),paramMap(subplotting))) ] }, {'-r', 'LineWidth', 2}, 0);
            drawnow
            hold on                

            plot([iteration-1,iteration],[MU_prev(paramMap(subplotting)),MU(paramMap(subplotting))],'LineWidth',3,'Color','red');
        end
        
        if subplotting==5
            title('Stay bias');
        elseif subplotting==6
            title('Alpha MB');
        elseif subplotting==7
            title('Alpha Model-free (elig=0)');
        elseif subplotting==8
            title('Drift Model-free (elig=0)');
        elseif subplotting==9
            title('Alpha Model-free (elig=1)');
        elseif subplotting==10
            title('Drift Model-free (elig=1)');
        elseif subplotting==11
            title('Beta level 1');
        elseif subplotting==12
            title('Beta level 2');
        end

        drawnow
        hold on    

    end
    
%##########################################################################
%####               plot parameters for individuals                    ####
%##########################################################################        
function plotParameters4Individuals(figRef,iteration,subjectsNum,w_prev,w,wMeanL1IndPrev,wMeanL1Ind,wMeanIndL2Prev,wMeanL2Ind,isParamAvailable,colors,model,paramMap);
        
    set(0,'CurrentFigure',figRef);

    if iteration > 1
            %------------------- Plot parameters for individuals
            counter = 1 ;
            for subplotting = 1 : 4
                if model(subplotting)
                    subplot(5,3,subplotting);         
                    for subject = 1 : subjectsNum
                        plot([iteration-1,iteration],[ wMeanL1IndPrev(counter,subject),wMeanL1Ind(counter,subject)],'LineWidth',1,'Color',colors(:,subject));
                        drawnow
                        hold on                
                    end
                    counter = counter + 1;

                end
            end
            
            for subplotting = 4 : 5
                subplot(5,3,subplotting+1);         
                for subject = 1 : subjectsNum
                    plot([iteration-1,iteration],[ wMeanIndL2Prev(subplotting-3,subject),wMeanL2Ind(subplotting-3,subject)],'LineWidth',1,'Color',colors(:,subject));
                    drawnow
                    hold on                
                end
            end

            for subplotting = 5 : 12
                if isParamAvailable(subplotting)
                    subplot(5,3,subplotting+2);     
                    for subject = 1 : subjectsNum
                        plot([iteration-1,iteration],[w_prev(subject,paramMap(subplotting)),w(subject,paramMap(subplotting))],'LineWidth',1,'Color',colors(:,subject));
                        drawnow
                        hold on                
                    end
                end
            end
    end
    drawnow
        
%##########################################################################
%####               plot Likelihood for individuals                    ####
%##########################################################################        
function plotLogLL(figRef,iteration,subjectsNum,LL_prev,LL,colors);
            
        set(0,'CurrentFigure',figRef)            

        if iteration > 1
            subplot(5,3,15);                     

            for subject = 1 : subjectsNum
                plot([iteration-1,iteration],[LL_prev(subject),LL(subject)],'LineWidth',1,'Color',colors(:,subject));
                drawnow
                hold on                
            end

            plot([iteration-1,iteration],[mean(LL_prev),mean(LL)],'LineWidth',3,'Color','red');
            title('-LogLikelihood');
            drawnow
            hold on                

        end

%##########################################################################
%####                            plot iBIC                             ####
%##########################################################################        
function plotIBIC(figRef,iteration, iBIC,iBIC_prev);

        set(0,'CurrentFigure',figRef)            

        if iteration > 1

            plot([iteration-1,iteration],[mean(iBIC_prev),mean(iBIC)],'LineWidth',3,'Color','red');
            title('iBIC');
            drawnow
            hold on                

        end        
    drawnow

%##########################################################################
%####        plot the correlation matrix over Hyperparameters          ####
%##########################################################################    
function plotHyperCorrMatrix(figRef,covMat,freeParametersNum);

    set(0,'CurrentFigure',figRef)            

    CorMat = covMat ; 
    for param1 = 1 : freeParametersNum
        for param2 = 1 : freeParametersNum
            CorMat(param1,param2) =  covMat(param1,param2)/(sqrt(covMat(param1,param1))*sqrt(covMat(param2,param2)));
        end
    end
    imagesc(CorMat);
    title('Correlation matrix over hyperparameters');
    colorbar
    drawnow

%##########################################################################
%####        plot the correlation matrix averaged over Individuals     ####
%##########################################################################    
function plotIndivCorrMatrix(figRef,mat,subjectsNum,freeParametersNum);
    
    set(0,'CurrentFigure',figRef)            

    s = zeros (freeParametersNum,freeParametersNum,subjectsNum); ; 
    ave = zeros (freeParametersNum,freeParametersNum);

    for sub = 1 : subjectsNum
        for param1 = 1 : freeParametersNum
            for param2 = 1 : freeParametersNum
                s(param1,param2,sub) =  mat(param1,param2,sub)^2 / (mat(param1,param1,sub)*mat(param2,param2,sub));
                ave(param1,param2)   =  ave(param1,param2) + s(param1,param2,sub) ;
            end
        end
    end
    ave = ave / subjectsNum ;
       
    imagesc(ave);
    title('Average over individuals correlation matrices');
    colorbar
    drawnow

%##########################################################################
%####      plot weights of the four models, before normalization       ####
%##########################################################################    
function plotWeights(figRef,iteration, MU,sigma2,paramMap,model);

    set(0,'CurrentFigure',figRef);

    modelsNum = model(1) + model(2) + model(3) + model(4) ;   % Number of models = 1..4
        
    samplesNum = 500 ;        
    samples_old        = zeros (modelsNum,samplesNum) ;
    samples_new        = zeros (modelsNum,samplesNum) ;

    if modelsNum == 0
        % Do nothing

    elseif modelsNum == 1
        for m = 1:4
            if model(m)
                for samples=1:samplesNum
                    samples_new (m,samples) = 1 ;
                end
            end
        end
        
    else

        samples_old (1:modelsNum-1,:) = transpose(mvnrnd (MU(1:modelsNum-1),sigma2(1:modelsNum-1,1:modelsNum-1),samplesNum));

        e = zeros (4,1);
        
        for samples=1:samplesNum

            for m = 1:modelsNum-1
                e(m) = exp (samples_old(m,samples)); 
            end
            e(modelsNum) = exp(1);

            sum = 0 ;
            for m = 1:modelsNum
                sum = sum + e(m) ;
            end

            for m = 1:modelsNum
                samples_new (m,samples) = e(m) / sum ;
            end
        end
    end    
    
    mCounter = 0 ;    
    for m = 1:4
        if model(m)
            subplot(4,1,m);
            mCounter = mCounter + 1 ;
            hist(samples_new (mCounter,:),0:0.05:1);
        end
        if m==1
            ylabel('W(MB)');
        elseif m==2
            ylabel('W(Pruning)');
        elseif m==3
            ylabel('W(MF Elig)');
        else
            ylabel('W(MF no Elig)');
        end
    end    

    drawnow

%##########################################################################
%####        plot W_model-based and W_pruning for all individuals      ####
%##########################################################################    
function plotParams1and2 (figRef,w,subjectsNum,isParamAvailable,colors);
    
    set(0,'CurrentFigure',figRef);
    clf(figRef);

    if isParamAvailable(1) & isParamAvailable(2)
        for sub = 1 : subjectsNum
            scatter(w(sub,1),w(sub,2),'filled','MarkerEdgeColor',colors(:,sub),'MarkerFaceColor',colors(:,sub));
            hold on
        end
    end
    xlabel ('Model-based weight');
    ylabel ('Pruning weight');
    drawnow
    
%##########################################################################
%####                     Computing iBIC                               ####
%##########################################################################        
function iBIC = computingIBIC (rawSamples,MU,sigma2,subjectsNum,trialsNum,freeParametersNum,samplesNum,data,paramMap,model,isParamAvailable)
        
        disp(' ');
        disp(' ');
        disp('---------------           Computing iBIC            ---------------------');

        logSumLikelihood = zeros (subjectsNum,1);
        
        parfor subject = 1 : subjectsNum

            disp(['------  Subject : ',int2str(subject),'/',int2str(subjectsNum)]);
                        
            LLL = zeros (samplesNum,1);
            sample = zeros (freeParametersNum,1) ;
            
            for i=1:samplesNum
                sigma = sqrtm (sigma2);
                sample (:) = MU(:) + sigma(:,:)*transpose(rawSamples (i,:)) ;
                nLLLL = negLogLikelihood( transpose(sample (:)), subject , trialsNum(subject),data{subject} ,paramMap,model,isParamAvailable) ;                

                LLL(i) = - nLLLL;
            end                
            sumLikelihood = 0 ;
            LLLmean = mean(LLL);
            
            nlllInfCounter = 0 ;
            for i=1:samplesNum
                ppp = exp( LLL(i)- LLLmean );
                if ppp == +inf |  ppp == -inf
                    nlllInfCounter = nlllInfCounter + 1;
                    disp('-');
                else
                    sumLikelihood = sumLikelihood + ppp;
                end
            end           
            logSumLikelihood(subject) = LLLmean + log(sumLikelihood) - log(samplesNum-nlllInfCounter);
        end
        
        
        iBIC=0;
        for subject = 1 : subjectsNum
            iBIC = iBIC + logSumLikelihood(subject) ;
        end
        
        modelsNum = model(1) + model(2) + model(3) + model(4)                           ;   % Number of models = 1..4
        if modelsNum == 4 
            offDiagonalParamsNum = 3;
        elseif modelsNum==3
            offDiagonalParamsNum = 1;
        else 
            offDiagonalParamsNum = 0;
        end
        
 %??????
        offDiagonalParamsNum = 0;
        
        iBIC = -2*iBIC + ( freeParametersNum*2 + offDiagonalParamsNum )*log(trialsNum(1)*subjectsNum);

%##########################################################################
%####         Display and print head of each EM iteration              ####
%##########################################################################    
function headerMessageDisplay(outputFile,iteration,EMiterationNum);
        disp('#########################################################################################');
        disp(['#########################   EM iteration : ',int2str(iteration),'/',int2str(EMiterationNum)]);
        disp('#########################################################################################');        
        fprintf(outputFile,'#########################################################################################\n');
        fprintf(outputFile,'#########################   EM iteration : %d / %d \n',iteration,EMiterationNum);
        fprintf(outputFile,'#########################################################################################\n');

%##########################################################################
%####             Display Results For one Individual                   ####
%##########################################################################    
function displayResultsForIndividual(subject,subjectsNum,x,vars,fval,iterations,paramMap,model,isParamAvailable,freeParamsNum,trialsNum);

    displayPrecision =  '%+9.4f' ; 
    message = [ 'Level 1: MB weight                   = ';...
                'Level 1: Pruning weight              = ';...
                'Level 1: MF (eligibility=1) weight   = ';...
                'Level 1: MF (eligibility=0) weight   = ';...
                'Level 2: MB weight                   = ';...
                'Level 2: MF weight                   = ';...
                'Stay bias                            = ';...
                'Alpha MB                             = ';...
                'Alpha MF (eligibility=0)             = ';...
                'Drift MF (eligibility=0)             = ';...
                'Alpha MF (eligibility=1)             = ';...
                'Drift MF (eligibility=1)             = ';...
                'Beta level 1                         = ';...
                'Beta level 2                         = '];
    
    disp(char(10));
    disp(char(10));
    disp(['------  Subject : ',int2str(subject),'/',int2str(subjectsNum)]);
    disp('-------------------------------------------------------------------------');

    counter = 1;
    for p=1:3
        if isParamAvailable(p)
            disp([message(p,:),num2str(x(counter),displayPrecision ),'   sigma^2 = ',num2str(vars(counter ,counter ),displayPrecision)]);
            counter = counter + 1;
        elseif ~isParamAvailable(p) & model(p)
            disp([message(p,:),num2str(1,displayPrecision ),'   sigma^2 = ',num2str(0,displayPrecision)]);
            counter = counter + 1;
        else
            disp([message(p,:),'Unavailable']);            
        end
    end
    if model(4)
        disp([message(4,:),num2str(1,displayPrecision ),'   sigma^2 = ',num2str(0,displayPrecision)]);
    else
        disp([message(p,:),'Unavailable']);            
    end

    disp([message(5,:),num2str(x(paramMap(4)),displayPrecision ),'   sigma^2 = ',num2str(vars(paramMap(4) ,paramMap(4) ),displayPrecision)]);
    disp([message(6,:),num2str(1,displayPrecision ),'   sigma^2 = ',num2str(0,displayPrecision)]);
    
    for p=5:12
        if isParamAvailable(p)
            disp([message(p+2,:),num2str(x(paramMap(p)),displayPrecision ),'   sigma^2 = ',num2str(vars(paramMap(p) ,paramMap(p) ),displayPrecision)]);
            counter = counter + 1;
        else
            disp([message(p+2,:),'Unavailable']);            
        end
    end

    disp('-------------------------------------------------------------------------');
    disp(['Log Likelihood                       = ',num2str(fval)]);
    disp(['Number of free parameters            = ',num2str(freeParamsNum)]);
    disp(['BIC                                  = ',num2str(2*fval(1,1) + freeParamsNum(1,1) * log(trialsNum(1,1)) ) ]);    
    disp(['Number of iterations                 = ',num2str(iterations)]);
    disp('-------------------------------------------------------------------------');
    
%##########################################################################
%####               Display Results at group level                     ####
%##########################################################################        
function displayResultsForGroup(x,vars,fval,paramMap,model,isParamAvailable,freeParamsNum,iBIC);

    displayPrecision =  '%+9.4f' ; 
    message = [ 'Level 1: MB weight                   = ';...
                'Level 1: Pruning weight              = ';...
                'Level 1: MF (eligibility=1) weight   = ';...
                'Level 1: MF (eligibility=0) weight   = ';...
                'Level 2: MB weight                   = ';...
                'Level 2: MF weight                   = ';...
                'Stay bias                            = ';...
                'Alpha MB                             = ';...
                'Alpha MF (eligibility=0)             = ';...
                'Drift MF (eligibility=0)             = ';...
                'Alpha MF (eligibility=1)             = ';...
                'Drift MF (eligibility=1)             = ';...
                'Beta level 1                         = ';...
                'Beta level 2                         = '];
        
    disp(char(10));
    disp(char(10));
    disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\');
    disp(' |-|-|-|-|-|              Group-level Results                 |-|-|-|-|-| ');
    disp('\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/');


    counter = 1;
    for p=1:3
        if isParamAvailable(p)
            disp([message(p,:),num2str(x(counter),displayPrecision ),'   sigma^2 = ',num2str(vars(counter ,counter ),displayPrecision)]);
            counter = counter + 1;
        elseif ~isParamAvailable(p) & model(p)
            disp([message(p,:),num2str(1,displayPrecision ),'   sigma^2 = ',num2str(0,displayPrecision)]);
            counter = counter + 1;
        else
            disp([message(p,:),'Unavailable']);            
        end
    end
    if model(4)
        disp([message(4,:),num2str(1,displayPrecision ),'   sigma^2 = ',num2str(0,displayPrecision)]);
    else
        disp([message(p,:),'Unavailable']);            
    end

    disp([message(5,:),num2str(x(paramMap(4)),displayPrecision ),'   sigma^2 = ',num2str(vars(paramMap(4) ,paramMap(4) ),displayPrecision)]);
    disp([message(6,:),num2str(1,displayPrecision ),'   sigma^2 = ',num2str(0,displayPrecision)]);
    
    for p=5:12
        if isParamAvailable(p)
            disp([message(p+2,:),num2str(x(paramMap(p)),displayPrecision ),'   sigma^2 = ',num2str(vars(paramMap(p) ,paramMap(p) ),displayPrecision)]);
            counter = counter + 1;
        else
            disp([message(p+2,:),'Unavailable']);            
        end
    end

    disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\');
    disp(['Mean Log Likelihood                  = ',num2str(fval)]);
    disp(['Number of free parameters            = ',num2str(freeParamsNum)]);
    disp(['iBIC                                 = ',num2str(iBIC(1,1))]);    
    disp('\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/');
    
%##########################################################################
%####         Print Results into file For one Individual               ####
%##########################################################################    
function printResultsToFileForIndividuals(outputFile,subject,subjectsNum,x,vars,fval,iterations,paramMap,model,isParamAvailable,freeParamsNum,trialsNum);

    message = [ 'Level 1: MB weight                   = ';...
                'Level 1: Pruning weight              = ';...
                'Level 1: MF (eligibility=1) weight   = ';...
                'Level 1: MF (eligibility=0) weight   = ';...
                'Level 2: MB weight                   = ';...
                'Level 2: MF weight                   = ';...
                'Stay bias                            = ';...
                'Alpha MB                             = ';...
                'Alpha MF (eligibility=0)             = ';...
                'Drift MF (eligibility=0)             = ';...
                'Alpha MF (eligibility=1)             = ';...
                'Drift MF (eligibility=1)             = ';...
                'Beta level 1                         = ';...
                'Beta level 2                         = '];
    
    fprintf(outputFile,'\n \n');
    fprintf(outputFile,'------  Subject : %d / %d \n',subject,subjectsNum);
    fprintf(outputFile,'-------------------------------------------------------------------------\n');

    counter = 1;
    for p=1:3
        if isParamAvailable(p)
            fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(p,:),x(counter),vars(counter ,counter));
            counter = counter + 1;
        elseif ~isParamAvailable(p) & model(p)
            fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(p,:),1,0);
            counter = counter + 1;
        else
            fprintf(outputFile,'%sUnavailable\n',message(p,:));
        end
    end
    if model(4)
        fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(4,:),1,0);
    else
        fprintf(outputFile,'%sUnavailable\n',message(p,:));
    end

    fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(5,:),x(paramMap(4)),vars(paramMap(4) ,paramMap(4) ));
    fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(6,:),1,0 );
    
    for p=5:12
        if isParamAvailable(p)
            fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(p+2,:),x(paramMap(p)),vars(paramMap(p) ,paramMap(p) ));
            counter = counter + 1;
        else
            fprintf(outputFile,'%sUnavailable\n',message(p+2,:));
        end
    end
    
    fprintf(outputFile,'-------------------------------------------------------------------------\n');
    fprintf(outputFile,'Log Likelihood                       = %f\n',fval);
    fprintf(outputFile,'Number of free parameters            = %d\n',freeParamsNum);
    fprintf(outputFile,'BIC                                  = %f\n',2*fval(1,1) + freeParamsNum(1,1) * log(trialsNum(1,1)) );
    fprintf(outputFile,'Number of iterations                 = %d\n',iterations);
    fprintf(outputFile,'-------------------------------------------------------------------------\n');
    
%##########################################################################
%####            Print Results into file For a Group                   ####
%##########################################################################    
function printResultsToFileForGroup(outputFile,x,vars,fval,paramMap,model,isParamAvailable,freeParamsNum,iBIC);

    message = [ 'Level 1: MB weight                   = ';...
                'Level 1: Pruning weight              = ';...
                'Level 1: MF (eligibility=1) weight   = ';...
                'Level 1: MF (eligibility=0) weight   = ';...
                'Level 2: MB weight                   = ';...
                'Level 2: MF weight                   = ';...
                'Stay bias                            = ';...
                'Alpha MB                             = ';...
                'Alpha MF (eligibility=0)             = ';...
                'Drift MF (eligibility=0)             = ';...
                'Alpha MF (eligibility=1)             = ';...
                'Drift MF (eligibility=1)             = ';...
                'Beta level 1                         = ';...
                'Beta level 2                         = '];
        
    fprintf(outputFile,'\n \n');
    fprintf(outputFile,'|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|\n');
    fprintf(outputFile,' |-|-|-|-|-|              Group-level Results                  |-|-|-|-|-|\n');
    fprintf(outputFile,'|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|\n');


    counter = 1;
    for p=1:3
        if isParamAvailable(p)
            fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(p,:),x(counter),vars(counter ,counter));
            counter = counter + 1;
        elseif ~isParamAvailable(p) & model(p)
            fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(p,:),1,0);
            counter = counter + 1;
        else
            fprintf(outputFile,'%sUnavailable\n',message(p,:));
        end
    end
    if model(4)
        fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(4,:),1,0);
    else
        fprintf(outputFile,'%sUnavailable\n',message(p,:));
    end

    fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(5,:),x(paramMap(4)),vars(paramMap(4) ,paramMap(4) ));
    fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(6,:),1,0 );
    
    for p=5:12
        if isParamAvailable(p)
            fprintf(outputFile,'%s%+9.4f   sigma^2 = %+9.4f\n',message(p+2,:),x(paramMap(p)),vars(paramMap(p) ,paramMap(p) ));
            counter = counter + 1;
        else
            fprintf(outputFile,'%sUnavailable\n',message(p+2,:));
        end
    end

    fprintf(outputFile,'|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|\n');
    fprintf(outputFile,'Mean Log Likelihood                  = %f\n',fval);
    fprintf(outputFile,'Number of free parameters            = %d\n',freeParamsNum);
    fprintf(outputFile,'iBIC                                 = %f\n',iBIC(1,1));
    fprintf(outputFile,'|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|\n');        

%##########################################################################
%####                 Plotting shaded error bars                       ####
%##########################################################################        
function varargout=shadedErrorBar(x,y,errBar,lineProps,transparent)
% function H=shadedErrorBar(x,y,errBar,lineProps,transparent)
%
% Purpose 
% Makes a 2-d line plot with a pretty shaded error bar made
% using patch. Error bar color is chosen automatically.
%
% Inputs
% x - vector of x values [optional, can be left empty]
% y - vector of y values or a matrix of n observations by m cases
%     where m has length(x);
% errBar - if a vector we draw symmetric errorbars. If it has a size
%          of [2,length(x)] then we draw asymmetric error bars with
%          row 1 being the upper bar and row 2 being the lower bar
%          (with respect to y). ** alternatively ** errBar can be a
%          cellArray of two function handles. The first defines which
%          statistic the line should be and the second defines the
%          error bar.
% lineProps - [optional,'-k' by default] defines the properties of
%             the data line. e.g.:    
%             'or-', or {'-or','markerfacecolor',[1,0.2,0.2]}
% transparent - [optional, 0 by default] if ==1 the shaded error
%               bar is made transparent, which forces the renderer
%               to be openGl. However, if this is saved as .eps the
%               resulting file will contain a raster not a vector
%               image. 
%
% Outputs
% H - a structure of handles to the generated plot objects.     
%
%
% Examples
% y=randn(30,80); x=1:size(y,2);
% shadedErrorBar(x,mean(y,1),std(y),'g');
% shadedErrorBar(x,y,{@median,@std},{'r-o','markerfacecolor','r'});    
% shadedErrorBar([],y,{@median,@std},{'r-o','markerfacecolor','r'});    
%
% Overlay two transparent lines
% y=randn(30,80)*10; x=(1:size(y,2))-40;
% shadedErrorBar(x,y,{@mean,@std},'-r',1); 
% hold on
% y=ones(30,1)*x; y=y+0.06*y.^2+randn(size(y))*10;
% shadedErrorBar(x,y,{@mean,@std},'-b',1); 
% hold off
%
%
% Rob Campbell - November 2009


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Error checking    
error(nargchk(3,5,nargin))


%Process y using function handles if needed to make the error bar
%dynamically
if iscell(errBar) 
    fun1=errBar{1};
    fun2=errBar{2};
    errBar=fun2(y);
    y=fun1(y);
else
    y=y(:)';
end

if isempty(x)
    x=1:length(y);
else
    x=x(:)';
end


%Make upper and lower error bars if only one was specified
if length(errBar)==length(errBar(:))
    errBar=repmat(errBar(:)',2,1);
else
    s=size(errBar);
    f=find(s==2);
    if isempty(f), error('errBar has the wrong size'), end
    if f==2, errBar=errBar'; end
end

if length(x) ~= length(errBar)
    error('length(x) must equal length(errBar)')
end

%Set default options
defaultProps={'-k'};
if nargin<4, lineProps=defaultProps; end
if isempty(lineProps), lineProps=defaultProps; end
if ~iscell(lineProps), lineProps={lineProps}; end

if nargin<5, transparent=0; end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Plot to get the parameters of the line 
H.mainLine=plot(x,y,lineProps{:});


% Work out the color of the shaded region and associated lines
% Using alpha requires the render to be openGL and so you can't
% save a vector image. On the other hand, you need alpha if you're
% overlaying lines. There we have the option of choosing alpha or a
% de-saturated solid colour for the patch surface .

col=get(H.mainLine,'color');
edgeColor=col+(1-col)*0.55;
patchSaturation=0.15; %How de-saturated or transparent to make patch
if transparent
    faceAlpha=patchSaturation;
    patchColor=col;
    set(gcf,'renderer','openGL')
else
    faceAlpha=1;
    patchColor=col+(1-col)*(1-patchSaturation);
    set(gcf,'renderer','painters')
end

    
%Calculate the error bars
uE=y+errBar(1,:);
lE=y-errBar(2,:);


%Add the patch error bar
holdStatus=ishold;
if ~holdStatus, hold on,  end


%Make the patch
yP=[lE,fliplr(uE)];
xP=[x,fliplr(x)];

%remove nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];


H.patch=patch(xP,yP,1,'facecolor',patchColor,...
              'edgecolor','none',...
              'facealpha',faceAlpha);


%Make pretty edges around the patch. 
H.edge(1)=plot(x,lE,'-','color',edgeColor);
H.edge(2)=plot(x,uE,'-','color',edgeColor);

%Now replace the line (this avoids having to bugger about with z coordinates)
delete(H.mainLine)
H.mainLine=plot(x,y,lineProps{:});


if ~holdStatus, hold off, end


if nargout==1
    varargout{1}=H;
end
    