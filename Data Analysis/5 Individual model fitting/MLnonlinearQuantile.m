% Finding the maximum likelihood by using nonlinear optimization routines, 
%over the parameter space, for each individual subject
function params = MLnonlinear()
    global quantsNum
    global quantileNumber

    group = 2 ;
    quantileNumber = 2;
    
    quantsNum = 3 ;
    
    if group==1
        fromSubject     = 25        ;
        toSubject       = 41        ;
    else
        fromSubject     = 54        ;
        toSubject       = 68        ;
    end

        
    subjectsNum = toSubject - fromSubject + 1 ;
    
    params = zeros (subjectsNum,6);
        
        
    global data
    global trialsNum
    
    %###### Range of free parameters ######################################
    %#                                      LB = Lower Bound
    %#                                      UB = Upper Bound
    %######################################################################
    %----------------------- Beta      : rate of exploration for the first level
    beta1_LB         = 0.0001     ;
    beta1_UB         = inf   ;
    %----------------------- Beta      : rate of exploration for the second level
    beta2_LB         = 0.0001     ;
    beta2_UB         = inf   ;
    %----------------------- Alpha     : MF learning rate
    alphaMF_LB      = 0     ;
    alphaMF_UB      = 1     ;
    %----------------------- drift MF  : Rate with which Q-values drift to zero (forgetting effect)
    driftMF_LB      = 0     ;
    driftMF_UB      = 1     ;
    %----------------------- Alpha     : MB learning rate
    alphaMB_LB      = 0     ;
    alphaMB_UB      = 1     ;
    %----------------------- stay bias  : probability of repeating rewarded
    stayBias_LB     = 0  ;
    stayBias_UB     = 10   ;
    %----------------------- Weight of first level being MB, with transfer
    W1_MB_Tr_LB     = 0     ;
    W1_MB_Tr_UB     = 1     ;
    %----------------------- Weight of second level being MB
    W2_MB_LB        = 0     ;
    W2_MB_UB        = 1     ;
    %----------------------- AGGREGATION
    lb = [beta1_LB ; beta2_LB ; alphaMF_LB ; driftMF_LB ; alphaMB_LB ; stayBias_LB ; W1_MB_Tr_LB ; W2_MB_LB];
    ub = [beta1_UB ; beta2_LB ; alphaMF_UB ; driftMF_LB ; alphaMB_UB ; stayBias_UB ; W1_MB_Tr_UB ; W2_MB_UB];
    
    
    disp('Computing the maximum likelihood on the parameter space...');
    %###### For each Subject ##############################################
    for subject = fromSubject : toSubject

        %###### Load data #################################################
        data = dlmread([int2str(subject),'.txt']);   
        dataSize = size(data);
        trialsNum = 350;%dataSize(1,1);        
        
        %###### Compute maximum likelihood ################################
        initialParam = [ rand ; rand ; rand ; rand ;  rand ; rand ; rand ; rand]; 
        [x,val] = fmincon(@negLogLikelihood,initialParam,[],[],[],[],lb,ub);

        %###### Display results  ##########################################
        disp(char(10));
        disp('-----------------------------------------------------------');
        disp(['------ For subject #',int2str(subject),'/',int2str(subjectsNum)]);
        disp('-----------------------------------------------------------');
        disp(['Transfer weight   = ',num2str(x(7))]);
        disp(['Beta level 1      = ',num2str(x(1))]);
        disp(['Alpha MF          = ',num2str(x(3))]);
        disp(['Alpha MB          = ',num2str(x(5))]);
        disp(['Stay bias         = ',num2str(x(6))]);
%        disp(['Drift MF          = ',num2str(x(4))]);
%        disp(['Beta level 2      = ',num2str(x(2))]);
%        disp(['Level-2 MB weight = ',num2str(x(8))]);
        disp('-----------------------------------------------------------');
        disp(['Log Likelihood    = ',num2str(-val)]);
        disp('-----------------------------------------------------------');
        

        
        %###### Loggings  #################################################
        params( subject-fromSubject+1 , 1 )= x(7);
        params( subject-fromSubject+1 , 2 )= x(1);
        params( subject-fromSubject+1 , 3 )= x(3);
        params( subject-fromSubject+1 , 4 )= x(5);
        params( subject-fromSubject+1 , 5 )= x(6);
        params( subject-fromSubject+1 , 6 )= val;
        
        
    end
        
    
    
%##########################################################################
%####  Computing the likelikood for a certain agent                    ####
%##########################################################################    
function negLogLL = negLogLikelihood(X)

    beta1     = X(1) ; 
    beta2     = X(2) ; 
    alphaMF   = X(3) ; 
    driftMF   = X(4) ;
    alphaMB   = X(5) ;
    stayBias  = X(6) ;
    W1_MB_Tr  = X(7) ;
    W2_MB     = X(8) ;
    
    global data
    global trialsNum
    
    global QValues
    global reward 
    global transitionLevel1
    global transitionLevel2
    global quantsNum
    global quantileNumber
    
    initializeAgent ()  ;
    logLL       =   0   ;
    a1          =   0   ;
    r           =   0   ;
    %###### For each trial ####################
    for trial = 1 : trialsNum
        %###### Load subject's response #######                                    
        previous_a1 = a1 ;                                    
        previous_r  = r  ;                                    
        s1 = 0              ;
        s2 = data(trial,3)  ; % = 1 or 2
        s3 = data(trial,4)  ; % = 1, 2, 3, or 4
        a1 = data(trial,5)+1; % = 1 or 2 
        a2 = data(trial,6)+1; % = 1 or 2  
        r  = data(trial,17) ; % = 0 or 1                                    
        %###### IF it wasn't a lost trial #####
        if (s2 ~= 0) && (s3 ~= 0)
            %###### IF it was within the aimed quantile
            % Define the border of quantiles
            quants = zeros(quantsNum+1,1);

            quants1 = quantile ( data(:,7) , quantsNum-1 );
            for quantCounter = 1: quantsNum-1
                quants(quantCounter+1) = quants1 (quantCounter);
            end
            quants(quantsNum+1)=2;

            if quantsNum==2
               quants(2) = median (data(:,7));
            end
            
            if ((data(trial,7)>quants(quantileNumber)) && (data(trial,7)<quants(quantileNumber+1)))

                %###### Compute likelihood ########
                logLL = logLL + trialNegLogLL(a1,s2,a2,previous_a1,beta1,beta2,stayBias,W1_MB_Tr,W2_MB);
                %###### Update the model ##########

            end
            
            updateAgent(a1,s2,a2,s3,r,alphaMF,alphaMB,driftMF) ;

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

       
%##########################################################################
%####  Computing the likelikood of a certain trial of a certain agent  ####
%##########################################################################    
function negLogLL = trialNegLogLL(a1,s2,a2,prev_a1,beta1,beta2,stayBias,W1_MB_Tr,W2_MB)
    global QValues;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;
    
    %############ Second level
    v_MB_L2_s1a1 = transitionLevel2(1,1,1)*reward(1) + transitionLevel2(1,1,3)*reward(3);
    v_MB_L2_s1a2 = transitionLevel2(1,2,2)*reward(2) + transitionLevel2(1,2,4)*reward(4);
    v_MB_L2_s2a1 = transitionLevel2(2,1,1)*reward(1) + transitionLevel2(2,1,3)*reward(3);
    v_MB_L2_s2a2 = transitionLevel2(2,2,2)*reward(2) + transitionLevel2(2,2,4)*reward(4);
    
    v_MB_L2_s1 = max(v_MB_L2_s1a1,v_MB_L2_s1a2);
    v_MB_L2_s2 = max(v_MB_L2_s2a1,v_MB_L2_s2a2);    

    v_MF_L2_s1 = max(QValues(1,1),QValues(1,2));
    v_MF_L2_s2 = max(QValues(2,1),QValues(2,2));
    
    %############ First level without Transfer
    v_L1_noTr_s1a1 = transitionLevel1(1,1,1)*v_MB_L2_s1 + transitionLevel1(1,1,2)*v_MB_L2_s2;
    v_L1_noTr_s1a2 = transitionLevel1(1,2,1)*v_MB_L2_s1 + transitionLevel1(1,2,2)*v_MB_L2_s2;

    %############ First level with Transfer
    v_L1_Tr_s1a1 = transitionLevel1(1,1,1)*v_MF_L2_s1 + transitionLevel1(1,1,2)*v_MF_L2_s2;
    v_L1_Tr_s1a2 = transitionLevel1(1,2,1)*v_MF_L2_s1 + transitionLevel1(1,2,2)*v_MF_L2_s2;
    
    %############ Weighted Aggregation of the systems
    
    v_L1_s1a1 =  (1-W1_MB_Tr) * v_L1_noTr_s1a1   +   W1_MB_Tr * v_L1_Tr_s1a1 ;
    v_L1_s1a2 =  (1-W1_MB_Tr) * v_L1_noTr_s1a2   +   W1_MB_Tr * v_L1_Tr_s1a2 ;

    v_L2_s1a1 =  (1-W2_MB) * QValues(1,1)   +   W2_MB * v_MB_L2_s1a1 ;
    v_L2_s1a2 =  (1-W2_MB) * QValues(1,2)   +   W2_MB * v_MB_L2_s1a2 ;
    v_L2_s2a1 =  (1-W2_MB) * QValues(2,1)   +   W2_MB * v_MB_L2_s2a1 ;
    v_L2_s2a2 =  (1-W2_MB) * QValues(2,2)   +   W2_MB * v_MB_L2_s2a2 ;
        
    %############ Adding stay bias
    if      (prev_a1==1)
        v_L1_s1a1 = v_L1_s1a1 + stayBias ;
    elseif  (prev_a1==2)
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
%{    
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
%}    
    %############ Summing up the two likelihoods    
    negLogLL = negLogLL_L1 ;%+ negLogLL_L2 ;
    
%##########################################################################
%####                    Initializing  the  Agent                      ####
%##########################################################################    
function initializeAgent ()
    global QValues;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;

    %###### Agent's parameters       ######################################    
    
    QValues     = zeros (2,2);   % The Q-values of s2=1 or 2   and  a2=1 or 2
    reward      = zeros (4,1);   % Reward function for the model-based RL

    transitionLevel1= zeros(1,2,2);
    transitionLevel1(1,1,1) = 0.7 ;
    transitionLevel1(1,1,2) = 0.3 ;
    transitionLevel1(1,2,1) = 0.3 ;
    transitionLevel1(1,2,2) = 0.7 ;

    transitionLevel2= zeros(2,2,4);
    transitionLevel2(1,1,1) = 0.7 ;
    transitionLevel2(1,1,3) = 0.3 ;
    transitionLevel2(1,2,2) = 0.7 ;
    transitionLevel2(1,2,4) = 0.3 ;
    transitionLevel2(2,1,1) = 0.3 ;
    transitionLevel2(2,1,3) = 0.7 ;
    transitionLevel2(2,2,2) = 0.3 ;
    transitionLevel2(2,2,4) = 0.7 ;  
    

%##########################################################################
%####                    Updating the agent                            ####
%##########################################################################    
function updateAgent(a1,s2,a2, s3,r,alphaMF,alphaMB,driftMF);
    global QValues;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;

    for s=1:2
        for a=1:2
            QValues(s,a) = QValues(s,a) + driftMF*(0-QValues(s,a));
        end
    end 
    QValues(s2,a2) = QValues(s2,a2) + alphaMF*(r-QValues(s2,a2));
    
    for s=1:4
        if s==s3
            reward (s)    = reward(s)     + alphaMB*(r-reward(s))    ; 
        else
            if (r==1)
                reward (s)    = reward(s)     + alphaMB*(0-reward(s))    ;
            end
        end
    end        