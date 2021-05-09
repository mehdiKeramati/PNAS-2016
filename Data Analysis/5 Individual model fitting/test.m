%---   16 Models competing over iBIC: MB / Pruning / MF(eligibility=1) / MF(eligibility=1)
%---   Parallelizing processes
%---   Automatically for 16 models... 

function params = MLnonlinear()
    
    %######################################################################
    %#              Critical parameters
    %######################################################################

    group                   = 2                                                     ;
    subjectsNum             = 15                                                    ;
    EMiterationNum          = 50                                                    ;
    samplesNum              = 500                                                   ;
    fminuncIterationNum     = 5000                                                  ;
    
    model                   = zeros (4,1)                                           ;
    model (1)               = 1                     ;% Model-based                  ;
    model (2)               = 1                     ;% Pruning                      ;
    model (3)               = 1                     ;% Model-free (Elig=1)          ;
    model (4)               = 1                     ;% Model-free (Elig=0)          ;
    freeParametersNum       = 8                                                    ;       
           
    %######################################################################
    %#              Definitions
    %######################################################################

    if group==1
        fromSubject         = 25                                                    ;
        toSubject           = fromSubject + subjectsNum -1                          ;
    else
        fromSubject         = 54                                                    ;
        toSubject           = fromSubject + subjectsNum -1                          ;
    end

    
    data                    = cell (subjectsNum,1)                                  ;
    trialsNum               = zeros (subjectsNum,1)                                 ;
    w                       = zeros (subjectsNum,freeParametersNum)                 ;
    s                       = zeros (freeParametersNum,freeParametersNum,subjectsNum);
    LL                      = zeros (subjectsNum,1)                                 ;
    w_prev                  = zeros (subjectsNum,freeParametersNum)                 ;
    s_prev                  = zeros (freeParametersNum,freeParametersNum,subjectsNum);
    LL_prev                 = zeros (subjectsNum,1)                                 ;
    MU_prev                 = zeros (freeParametersNum,1)                           ;
    sigma2_prev             = zeros (freeParametersNum,freeParametersNum)           ;

    wMean_prev              = zeros (4,1)                                           ;
    wVari_prev              = zeros (4,1)                                           ;
    wMean                   = zeros (4,1)                                           ;
    wVari                   = zeros (4,1)                                           ;
    wMeanInd                = zeros (4,subjectsNum)                                 ;
    wMeanIndPrev            = zeros (4,subjectsNum)                                 ;

    wMeanL2_prev            = zeros (2,1)                                             ;
    wVariL2_prev            = zeros (2,1)                                             ;
    wMeanL2                 = zeros (2,1)                                             ;
    wVariL2                 = zeros (2,1)                                             ;
    wMeanL2Ind              = zeros (2,subjectsNum)                                   ;
    wMeanIndL2Prev          = zeros (2,subjectsNum)                                   ;

    %######################################################################
    %#    Defining Priors over hyperparameters:
    %#                mu     = prior hyperparameter mean
    %#                sigma2 = prior hyperparameter covariance matrix
    %######################################################################
    %----------------------- Weight of first level being MB
    MU_W1_MB                = 0     ;
    sigma2_W1_MB            = 1    ;
    %----------------------- Weight of first level being Pruning
    MU_W1_Prun              = 0     ;
    sigma2_W1_Prun          = 1    ;
    %----------------------- Weight of first level being Model-free, with eligibility trace = 1
    MU_W1_MF_Elig           = 0     ;
    sigma2_MF_Elig          = 1    ;
    %----------------------- Weight of second level being MB
    MU_W2_MB                = 0     ;
    sigma2_W2_MB            = 1    ;
    %----------------------- stay bias  : probability of repeating rewarded
    MU_stayBias             = 0.5   ;
    sigma2_stayBias         = 1     ;
    %----------------------- Alpha     : MB learning rate
    MU_alphaMB              = 0.5   ;
    sigma2_alphaMB          = 1     ;
    %----------------------- Alpha     : MF learning rate
    MU_alphaMF              = 0.5   ;
    sigma2_alphaMF          = 1     ;
    %----------------------- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    MU_driftMF              = 0.5   ;
    sigma2_driftMF          = 1     ;
    %----------------------- Alpha     : Learning rate for the Model-free with eligibility trace = 1
    MU_alphaMF_Elig         = 0.5   ;
    sigma2_alphaMF_Elig     = 1     ;
    %----------------------- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    MU_driftMF_Elig         = 0.5   ;
    sigma2_driftMF_Elig     = 1     ;
    %----------------------- Beta      : rate of exploration for the first level
    MU_beta1                = 5     ;
    sigma2_beta1            = 20    ;
    %----------------------- Beta      : rate of exploration for the second level
    MU_beta2                = 5     ;
    sigma2_beta2            = 20    ;

    %----------------------- AGGREGATION
    MU     = [MU_W1_MB ; MU_W2_MB ; MU_stayBias ; MU_alphaMB ; MU_alphaMF ; MU_driftMF ; MU_beta1 ; MU_beta2];
    
    sigma2                  = zeros (freeParametersNum,freeParametersNum);
    sigma2(1,1)             = sigma2_W1_MB          ;
    sigma2(2,2)             = sigma2_W2_MB          ;
    sigma2(3,3)             = sigma2_stayBias       ;
    sigma2(4,4)             = sigma2_alphaMB        ;
    sigma2(5,5)             = sigma2_alphaMF        ;
    sigma2(6,6)             = sigma2_driftMF        ;
    sigma2(7,7)             = sigma2_beta1          ;
    sigma2(8,8)             = sigma2_beta2          ;
     
           
    %######################################################################
    %#     Range of free parameters :
    %#               LB = Lower Bound
    %#               UB = Upper Bound
    %######################################################################
    %----------------------- Weight of first level being MB
    W1_MB_LB                = 0     ;
    W1_MB_UB                = 1     ;
    %----------------------- Weight of first level being Pruning
    W1_Prun_LB              = 0     ;
    W1_Prun_UB              = 1     ;
    %----------------------- Weight of first level being MF with Eligibility = 1
    W1_MF_Elig_LB           = 0     ;
    W1_MF_Elig_UB           = 1     ;
    %----------------------- Weight of second level being MB
    W2_MB_LB                = 0     ;
    W2_MB_UB                = 1     ;
    %----------------------- stay bias  : probability of repeating rewarded
    stayBias_LB             = 0     ;
    stayBias_UB             = 10    ;
    %----------------------- Alpha     : MB learning rate
    alphaMB_LB              = 0     ;
    alphaMB_UB              = 1     ;
    %----------------------- Alpha     : MF learning rate
    alphaMF_LB              = 0     ;
    alphaMF_UB              = 1     ;
    %----------------------- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    driftMF_LB              = 0     ;
    driftMF_UB              = 1     ;
    %----------------------- Alpha     : Learning rate for MF with Eligibility = 1
    alphaMF_Elig_LB         = 0     ;
    alphaMF_Elig_UB         = 1     ;
    %----------------------- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    driftMF_Elig_LB         = 0     ;
    driftMF_Elig_UB         = 1     ;
    %----------------------- Beta      : rate of exploration for the first level
    beta1_LB                = 0.0001;
    beta1_UB                = inf   ;
    %----------------------- Beta      : rate of exploration for the second level
    beta2_LB                = 0.0001;
    beta2_UB                = inf   ;

    %----------------------- AGGREGATION
    lb = [ W1_MB_LB ; W1_Prun_LB ; W1_MF_Elig_LB ; W2_MB_LB ; stayBias_LB ; alphaMB_LB ; alphaMF_LB ; driftMF_LB ; alphaMF_Elig_LB ; driftMF_Elig_LB ; beta1_LB ; beta2_LB ] ;
    ub = [ W1_MB_UB ; W1_Prun_UB ; W1_MF_Elig_UB ; W2_MB_UB ; stayBias_UB ; alphaMB_UB ; alphaMF_UB ; driftMF_UB ; alphaMF_Elig_UB ; driftMF_Elig_UB ; beta1_UB ; beta2_UB ] ;
          
        
    %######################################################################
    %#                            Initializations
    %######################################################################
    
        
    %------------------------ Plotting and coloring setup    
    figure('Position', [50, 50, 1500, 1000]); % create new figure
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 14)
    set(0,'DefaultAxesFontWeight', 'bold')
        
    colors=zeros(3,16);

    for subject = 1 : subjectsNum
        w(subject,:)   = MU ;
        s(:,:,subject) = sigma2 ;

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
   
    %------------------------ Loading data from files    
    for subject = 1 : subjectsNum
        data{subject} = dlmread([int2str(54 ),'.txt']);   
%        data{subject} = dlmread([int2str(subject + fromSubject - 1 ),'.txt']);   
        dataSize = size(data{subject});
        trialsNum(subject) = dataSize(1,1);    
    end 
    
    %######################################################################
    %#                                      
    %#                      EXPECTATION MAXIMIZATION                      #
    %#                                      
    %######################################################################
    w_temp           = zeros (subjectsNum,freeParametersNum);
    s_temp           = zeros (freeParametersNum,freeParametersNum,subjectsNum);

    for iteration = 1 : EMiterationNum
        
        disp('#########################################################################################');
        disp(['#########################   EM iteration : ',int2str(iteration),'/',int2str(EMiterationNum)]);
        disp('#########################################################################################');

        %##################################################################
        %#                             E step                             #
        %##################################################################

        %###### For each Subject ##########################################

        w_prev          = w         ;
        s_prev          = s         ;   
        LL_prev         = LL        ;
            
        for subject = 1 : subjectsNum

            %###### Compute maximum likelihood x prior ####################
            initialParam = zeros (freeParametersNum,1);
            for ipar = 1 : freeParametersNum                
                initialParam(ipar) = normrnd(MU(ipar), sigma2(ipar,ipar)/10);
            end

            
            options = optimoptions('fminunc','MaxFunEvals', fminuncIterationNum);
                        
            f = @(X)negLogLikelihoodXprior(X,subject,MU,sigma2,trialsNum(subject),data{subject});
            [x,fval,exitflag,output,grad,hessian] = fminunc(f,initialParam,options);
            
                        
            w_temp(subject,:)    = x            ;
            vars                 = inv(hessian) ;
            s_temp(:,:,subject)  = vars         ;          
        

            LL(subject)          = fval         ;

                        
            %###### Display results  ##########################################
            
            displayPrecision =  '%+9.4f' ; 
            
            disp(char(10));
            disp(char(10));
            disp(['------  Subject : ',int2str(subject),'/',int2str(subjectsNum)]);
            disp('-------------------------------------------------------------------------');
            disp(['Level 1: MB weight                   = ',num2str(x(1),displayPrecision ),'   sigma^2 = ',num2str(vars(1 ,1 ),displayPrecision)]);
            disp(['Level 2: MF weight                   = ',num2str(x(2),displayPrecision ),'   sigma^2 = ',num2str(vars(2 ,2 ),displayPrecision)]);
            disp(['Stay bias                            = ',num2str(x(3),displayPrecision ),'   sigma^2 = ',num2str(vars(3 ,3 ),displayPrecision)]);
            disp(['Alpha MB                             = ',num2str(x(4),displayPrecision ),'   sigma^2 = ',num2str(vars(4 ,4 ),displayPrecision)]);
            disp(['Alpha MF (eligibility=0)             = ',num2str(x(5),displayPrecision ),'   sigma^2 = ',num2str(vars(5 ,5 ),displayPrecision)]);
            disp(['Drift MF (eligibility=0)             = ',num2str(x(6),displayPrecision ),'   sigma^2 = ',num2str(vars(6 ,6 ),displayPrecision)]);
            disp(['Beta level 1                         = ',num2str(x(7),displayPrecision ),'   sigma^2 = ',num2str(vars(7 ,7 ),displayPrecision)]);
            disp(['Beta level 2                         = ',num2str(x(8),displayPrecision ),'   sigma^2 = ',num2str(vars(8 ,8 ),displayPrecision)]);
            disp('-------------------------------------------------------------------------');
            disp(['Log Likelihood                       = ',num2str(fval)]);
            disp(['Number of iterations                 = ',num2str(output.iterations)]);
            disp('-------------------------------------------------------------------------');
            
        end
        
        w = w_temp   ;
        s = s_temp   ;   
                                        
        %##################################################################
        %#                             M step                             #
        %##################################################################

        MU_prev     = MU ;  
        sigma2_prev = sigma2 ;
    
        MU_temp     = zeros (freeParametersNum,1);
        sigma2_temp = zeros (freeParametersNum,freeParametersNum) ;
        
        
        for subject = 1 : subjectsNum
            MU_temp     = MU_temp     + transpose(w(subject,:) );
            sigma2_temp = sigma2_temp + mtimes( transpose(w(subject,:)) , w(subject,:) ) + (s(:,:,subject)) ;
        end
            
        MU      = MU_temp / subjectsNum  ;
        sigma2  = sigma2_temp / subjectsNum  - mtimes( MU , transpose(MU) ) ;

        sigma2 = diag(diag(sigma2));       

        %##################################################################
        %#                  Compute Weights of four models                #
        %##################################################################
        
        samples_old        = zeros (4,samplesNum) ;
        samples_new        = zeros (4,samplesNum) ;
                
        for i=1:3
            samples_old (i,:) = normrnd (MU(i),sigma2(i,i),samplesNum,1);         
        end        
        
        for samples=1:samplesNum
            e1 =  exp (samples_old(1,samples));
            e2 =  exp (samples_old(2,samples));
            e3 =  exp (samples_old(3,samples));
            e4 =  1 ;
            
            sum = e1+e2+e3+e4 ;
            
            samples_new (1,samples) = e1 / sum ;
            samples_new (2,samples) = e2 / sum ;
            samples_new (3,samples) = e3 / sum ;
            samples_new (4,samples) = e4 / sum ;        
        end
        
                
        wMean_prev = wMean ;
        wVari_prev = wVari ;

        for i=1:4
            wMean (i) = mean (samples_new (i,:));
            wVari (i) = var  (samples_new (i,:));
        end        
              

        %------------- For each individual subject
        wMeanIndPrev     = wMeanInd ;
        wMeanInd_temp1    = zeros (subjectsNum,1) ;
        wMeanInd_temp2    = zeros (subjectsNum,1) ;
        wMeanInd_temp3    = zeros (subjectsNum,1) ;
        wMeanInd_temp4    = zeros (subjectsNum,1) ;
        
        parfor sub=1:subjectsNum

            samples_old        = zeros (4,samplesNum) ;
            samples_new        = zeros (4,samplesNum) ;
        
            for i=1:3
                samples_old (i,:) = normrnd (w(subject,i),s(i,i,subject),samplesNum,1);         
            end
            
            for samples=1:samplesNum
                e1 =  exp (samples_old(1,samples));
                e2 =  exp (samples_old(2,samples));
                e3 =  exp (samples_old(3,samples));
                e4 =  1 ;

                sum = e1+e2+e3+e4 ;

                samples_new (1,samples) = e1 / sum ;
                samples_new (2,samples) = e2 / sum ;
                samples_new (3,samples) = e3 / sum ;
                samples_new (4,samples) = e4 / sum ;        
            end
            
            wMeanInd_temp1(sub) = mean (samples_new(1,:));
            wMeanInd_temp2(sub) = mean (samples_new(2,:));
            wMeanInd_temp3(sub) = mean (samples_new(3,:));
            wMeanInd_temp4(sub) = mean (samples_new(4,:));
        end
        
        wMeanInd(1,:) = wMeanInd_temp1 ;
        wMeanInd(2,:) = wMeanInd_temp2 ;
        wMeanInd(3,:) = wMeanInd_temp3 ;
        wMeanInd(4,:) = wMeanInd_temp4 ;
        %##################################################################
        %#             Compute Weights of two models (Level 2)            #
        %##################################################################

        samples_old (1,:) = normrnd (MU(4),sigma2(4,4),samplesNum,1);         

        for samples=1:samplesNum
            e1 =  exp (samples_old(1,samples));
            e2 =  1 ;
            
            sum = e1+e2;
            
            samples_new (1,samples) = e1 / sum ;
            samples_new (2,samples) = e2 / sum ;
        end
        
                
        wMeanL2_prev = wMeanL2 ;
        wVariL2_prev = wVariL2 ;

        for i=1:2
            wMeanL2 (i) = mean (samples_new (i,:));
            wVariL2 (i) = var  (samples_new (i,:));
        end        

        %------------- For each individual subject
        wMeanIndL2Prev = wMeanL2Ind ;
        wMeanL2Ind_temp1    = zeros (subjectsNum,1) ;
        wMeanL2Ind_temp2    = zeros (subjectsNum,1) ;
        
        parfor sub=1:subjectsNum

            samples_old        = zeros (4,samplesNum) ;
            samples_new        = zeros (4,samplesNum) ;

            samples_old (1,:) = normrnd (w(subject,4),s(4,4,subject),samplesNum,1);         
            
            for samples=1:samplesNum
                e1 =  exp (samples_old(1,samples));
                e2 =  1 ;

                sum = e1+e2 ;

                samples_new (1,samples) = e1 / sum ;
                samples_new (2,samples) = e2 / sum ;
            end
            
            wMeanL2Ind_temp1(sub) = mean (samples_new(1,:));
            wMeanL2Ind_temp2(sub) = mean (samples_new(2,:));
        end
        
        wMeanL2Ind(1,:) = wMeanL2Ind_temp1 ;
        wMeanL2Ind(2,:) = wMeanL2Ind_temp2 ;
        
        %##################################################################
        %#                         Computing iBIC                         #
        %##################################################################

        disp('---------------           Computing iBIC            ---------------------');
        
        samples        = zeros (samplesNum,freeParametersNum) ;
                
        for i=1:freeParametersNum
            samples (:,i) = normrnd (MU(i),sigma2(i,i),samplesNum,1);         
        end
             
        logSumLikelihood = zeros (subjectsNum,1);
        
        parfor subject = 1 : subjectsNum

            disp(['------  Subject : ',int2str(subject),'/',int2str(subjectsNum)]);
            
            sumLikelihood = 0 ;
            for i=1:samplesNum
                nLLL = - negLogLikelihood( transpose(samples (i,:)), subject , trialsNum(subject),data{subject} ) ;                
                nLLL = nLLL + 800 ;                
                sumLikelihood = sumLikelihood + exp( nLLL )/exp(800);
            end                
            logSumLikelihood(subject) = log(sumLikelihood) - log(samplesNum);

        end
        
        iBIC=0;
        for subject = 1 : subjectsNum
            iBIC = iBIC + logSumLikelihood(subject) ;
        end
        iBIC = - 2*iBIC + (freeParametersNum*2)*log(trialsNum*subjectsNum);
        
        
        %##################################################################
        %#                          Print Results                         #
        %##################################################################

        displayPrecision =  '%+9.4f' ; 
        
        disp(char(10));
        disp('-------------------------------------------------------------------------');
        disp('---------------        Maximization Results         ---------------------');
        disp('-------------------------------------------------------------------------');
        disp(['Level 1: MB weight                   = ',num2str(MU(1),displayPrecision ),'   sigma^2 = ',num2str(sigma2(1 ,1 ),displayPrecision)]);
        disp(['Level 1: Pruning weight              = ',num2str(MU(2),displayPrecision ),'   sigma^2 = ',num2str(sigma2(2 ,2 ),displayPrecision)]);
        disp(['Level 1: MF (eligibility=1) weight   = ',num2str(MU(3),displayPrecision ),'   sigma^2 = ',num2str(sigma2(3 ,3 ),displayPrecision)]);
        disp(['Level 2: MF weight                   = ',num2str(MU(4),displayPrecision ),'   sigma^2 = ',num2str(sigma2(4 ,4 ),displayPrecision)]);
        disp(['Stay bias                            = ',num2str(MU(5),displayPrecision ),'   sigma^2 = ',num2str(sigma2(5 ,5 ),displayPrecision)]);
        disp(['Alpha MB                             = ',num2str(MU(6),displayPrecision ),'   sigma^2 = ',num2str(sigma2(6 ,6 ),displayPrecision)]);
        disp(['Alpha MF (eligibility=0)             = ',num2str(MU(7),displayPrecision ),'   sigma^2 = ',num2str(sigma2(7 ,7 ),displayPrecision)]);
        disp(['Drift MF (eligibility=0)             = ',num2str(MU(8),displayPrecision ),'   sigma^2 = ',num2str(sigma2(8 ,8 ),displayPrecision)]);
        disp(['Alpha MF (eligibility=1)             = ',num2str(MU(9),displayPrecision ),'   sigma^2 = ',num2str(sigma2(9 ,9 ),displayPrecision)]);
        disp(['Drift MF (eligibility=1)             = ',num2str(MU(10),displayPrecision),'   sigma^2 = ',num2str(sigma2(10,10),displayPrecision)]);
        disp(['Beta level 1                         = ',num2str(MU(11),displayPrecision),'   sigma^2 = ',num2str(sigma2(11,11),displayPrecision)]);
        disp(['Beta level 2                         = ',num2str(MU(12),displayPrecision),'   sigma^2 = ',num2str(sigma2(12,12),displayPrecision)]);
        disp('-------------------------------------------------------------------------');
        disp(['Mean Log Likelihood                  = ',num2str(mean(LL))]);
        disp(['iBIC                                 = ',num2str(mean(iBIC))]);
        disp('-------------------------------------------------------------------------');
                        
        %##################################################################
        %#                             plotting                           #
        %##################################################################
                  
        %------------------- Plot hyperpaarameters
        for subplotting = 1 : 4
            subplot(5,3,subplotting);                 
            x_ax = [iteration-1,iteration] ;
            MP = [wMean_prev(subplotting),wMean_prev(subplotting),wMean_prev(subplotting)];
            MN = [wMean(subplotting),wMean(subplotting), wMean(subplotting)];
            shadedErrorBar([iteration-1,iteration] , [MP(:),MN(:)], {@mean, @(x_ax) [wVari_prev(subplotting),wVari(subplotting)] }, {'-r', 'LineWidth', 2}, 0);
            drawnow
            hold on                

            plot([iteration-1,iteration],[wMean_prev(subplotting),wMean(subplotting)],'LineWidth',3,'Color','red');
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
            shadedErrorBar([iteration-1,iteration] , [MP(:),MN(:)], {@mean, @(x_ax) [wVariL2_prev(subplotting-3),wVariL2(subplotting-3)] }, {'-r', 'LineWidth', 2}, 0);
            drawnow
            hold on                

            plot([iteration-1,iteration],[wMeanL2_prev(subplotting-3),wMeanL2(subplotting-3)],'LineWidth',3,'Color','red');
            drawnow
            hold on    
            
            if subplotting==4
                title('Level 2: Model-free weight');
            elseif subplotting==5
                title('Level 2: Model-based weight');
            end            
        end

        
        for subplotting = 5 : 12
            
            subplot(5,3,subplotting+2);     
            
            x_ax = [iteration-1,iteration] ;
            MP = [MU_prev(subplotting) , MU_prev(subplotting) , MU_prev(subplotting)];
            MN = [MU(subplotting) , MU(subplotting) , MU(subplotting)];
            shadedErrorBar([iteration-1,iteration] , [MP(:),MN(:)], {@mean, @(x_ax) [ sigma2_prev(subplotting,subplotting) , sigma2(subplotting,subplotting) ] }, {'-r', 'LineWidth', 2}, 0);
            drawnow
            hold on                

            plot([iteration-1,iteration],[MU_prev(subplotting),MU(subplotting)],'LineWidth',3,'Color','red');

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

        
        if iteration > 1
            %------------------- Plot parameters for individuals
            for subplotting = 1 : 4
                subplot(5,3,subplotting);         
                for subject = 1 : subjectsNum
                    plot([iteration-1,iteration],[ wMeanIndPrev(subplotting,subject),wMeanInd(subplotting,subject)],'LineWidth',1,'Color',colors(:,subject));
                    drawnow
                    hold on                
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
                subplot(5,3,subplotting+2);     
                for subject = 1 : subjectsNum
                    plot([iteration-1,iteration],[w_prev(subject,subplotting),w(subject,subplotting)],'LineWidth',1,'Color',colors(:,subject));
                    drawnow
                    hold on                
                end
            end
            %------------------- Plot Likelihood
            
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
        
    end
    
    
                      
%##########################################################################
%####  Computing the posterior (likelikood x prior) for a certain agent####
%##########################################################################    
function negLogLL = negLogLikelihoodXprior(X,subject,MU,sigma2,trialsNum,data)

    priorNegLL =  - log(mvnpdf ( X , MU , sigma2 ));
    negLogLL = negLogLikelihood(X,subject,trialsNum,data);%+ priorNegLL ;    
    
    
%##########################################################################
%####  Computing the likelikood for a certain agent                    ####
%##########################################################################    
function negLogLL = negLogLikelihood(X,subject,trialsNum,data)

    W1_MB       = X(1 ) ;
    W2_MB       = X(2 ) ;
    stayBias    = X(3 ) ;
    alphaMB     = X(4 ) ;
    alphaMF     = X(5 ) ; 
    driftMF     = X(6 ) ;
    beta1       = X(7 ) ; 
    beta2       = X(8 ) ; 
    
    
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

        
    logLL       =   0   ;
    a1          =   0   ;
    r           =   0   ;
    %###### For each trial ####################
    for trial = 1 : trialsNum              
        
        %###### Load subject's response #######                                    
        previous_a1 = a1 ;                                    
        previous_r  = r  ;                                    
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
            e1 = W1_MB;
            e2 = 1-e1;
            e3 = 0;
            e4 = 0;
            
            v_L1_s1a1 =  e1 * v_L1_noTr_s1a1   +   e2 * v_L1_Tr_s1a1 + e3 * QValues_level1_Elig(1) + e4 * QValues_level1_NoElig(1);
            v_L1_s1a2 =  e1 * v_L1_noTr_s1a2   +   e2 * v_L1_Tr_s1a2 + e3 * QValues_level1_Elig(2) + e4 * QValues_level1_NoElig(2);


            %=== Level 2                                                 
            w1 = W2_MB;
            w2 = 1-w1 ;
            
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
            expA1 = exp (v_L1_s1a1*beta1);
            expA2 = exp (v_L1_s1a2*beta1);

            sum = expA1 + expA2 ;


            logP_A1 = (v_L1_s1a1*beta1) - log(sum) ;
            logP_A2 = (v_L1_s1a2*beta1) - log(sum) ;

            if (a1==1)
                negLogLL_L1 = -logP_A1;
            else
                negLogLL_L1 = -logP_A2;
            end

            %############ Computing the likelihood of the second-step action

            exps1a1 = exp ( v_L2_s1a1 * beta2);
            exps1a2 = exp ( v_L2_s1a2 * beta2);
            exps2a1 = exp ( v_L2_s2a1 * beta2);
            exps2a2 = exp ( v_L2_s2a2 * beta2);

            if (s2==1)        
                sum =  exps1a1 + exps1a2 ;
                if (a2==1)
                    negLogLL_L2 = - (v_L2_s1a1 * beta2) + log(sum) ;
                elseif (a2==2)
                    negLogLL_L2 = - (v_L2_s1a2 * beta2) + log(sum) ;
                end
            elseif (s2==2)        
                sum =  exps2a1 + exps2a2 ;
                if (a2==1)
                    negLogLL_L2 = - (v_L2_s2a1 * beta2) + log(sum) ;
                elseif (a2==2)
                    negLogLL_L2 = - (v_L2_s2a2 * beta2) + log(sum) ;
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


            %----------------- Updating Q-values of second level ------------------
            for s=1:2
                for a=1:2
                    QValues_level2(s,a) = QValues_level2(s,a) + driftMF*(0-QValues_level2(s,a));
                end
            end 
            QValues_level2(s2,a2) = QValues_level2(s2,a2) + alphaMF*(r-QValues_level2(s2,a2));

            %----------------- Updating Reward Function ---------------------------
            alphaMBdelta = alphaMB*(r-reward(s3));


            normalizer = 0 ;
            for s=1:4
                if s~=s3
                    normalizer = normalizer + (1-r-reward(s)) ;
                end
            end      


            for s=1:4
                if s==s3
                    reward (s)    = reward(s) + alphaMBdelta ; 
                else
                    reward (s)    = reward(s) - alphaMBdelta * ( (1-r-reward(s)) / normalizer )   ;
                end
            end      
                                                           
        end
    end
       
    negLogLL = logLL ;

    
    
    %###### DATA FORMAT              ######################################
    % 1     records.trial                 = 0;       % trial number
    % 2     records.firstState            = 0;       % always 0
    % 3     records.secondState           = 0;       % 1 or 2
    % 4     records.thirdState            = 0;       % 1, 2, 3, or 4
    % 5     records.firstAction           = 0;       % 0 for left, 1 for right 
    % 6     records.secondAction          = 0;       % 0 for left, 1 for right 
    % 7     records.firstReactionTime     = 0;       % The reaction time for the first  action
    % 8     records.secondReactionTime    = 0;       % The reaction time for the second action
    % 9     records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    % 10    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    % 11    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    % 12    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    % 13    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    % 14    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    % 15    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    % 16    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    % 17    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    % 18    records.totalReward           = 0;       % total reward obtained so far.

       
  
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
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
    