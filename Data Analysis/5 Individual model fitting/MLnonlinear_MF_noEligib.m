% Finding the maximum likelihood by using nonlinear optimization routines, 
%over the parameter space, for each individual subject
function params = MLnonlinear()
    
    group = 2 ;

    if group==1
        fromSubject     = 25        ;
        toSubject       = 39        ;
    else
        fromSubject     = 54        ;
        toSubject       = 68        ;
    end

        
    subjectsNum = toSubject - fromSubject + 1 ;
    
    params = zeros (subjectsNum,8);
        
        
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
    %----------------------- Weight of second level being MB
    W2_MB_LB        = 0     ;
    W2_MB_UB        = 1     ;
    %----------------------- AGGREGATION
    lb = [beta1_LB ; beta2_LB ; alphaMF_LB ; driftMF_LB ; alphaMB_LB ; stayBias_LB ; W2_MB_LB];
    ub = [beta1_UB ; beta2_UB ; alphaMF_UB ; driftMF_UB ; alphaMB_UB ; stayBias_UB ; W2_MB_UB];
    
    
    disp('Computing the maximum likelihood on the parameter space...');
    %###### For each Subject ##############################################
    for subject = fromSubject : toSubject

        %###### Load data #################################################
        data = dlmread([int2str(subject),'.txt']);   
        dataSize = size(data);
        trialsNum = dataSize(1,1);        
        
        %###### Compute maximum likelihood ################################
        initialParam = [ rand ; rand ; rand ; rand ;  rand ; rand ; rand]; 
        [x,val] = fmincon(@negLogLikelihood,initialParam,[],[],[],[],lb,ub);

        %###### Display results  ##########################################
        disp(char(10));
        disp('-----------------------------------------------------------');
        disp(['------ For subject #',int2str(subject),'/',int2str(subjectsNum)]);
        disp('-----------------------------------------------------------');
        disp(['Beta level 1      = ',num2str(x(1))]);
        disp(['Alpha MF          = ',num2str(x(3))]);
        disp(['Alpha MB          = ',num2str(x(5))]);
        disp(['Stay bias         = ',num2str(x(6))]);
        disp(['Drift MF          = ',num2str(x(4))]);
        disp(['Beta level 2      = ',num2str(x(2))]);
        disp(['Level-2 MB weight = ',num2str(x(7))]);
        disp('-----------------------------------------------------------');
        disp(['Log Likelihood    = ',num2str(-val)]);
        disp('-----------------------------------------------------------');
        

        
        %###### Loggings  #################################################
        params( subject-fromSubject+1 , 1 )= x(1);
        params( subject-fromSubject+1 , 2 )= x(3);
        params( subject-fromSubject+1 , 3 )= x(5);
        params( subject-fromSubject+1 , 4 )= x(6);
        params( subject-fromSubject+1 , 5 )= x(4);
        params( subject-fromSubject+1 , 6 )= x(2);
        params( subject-fromSubject+1 , 7 )= x(7);
        params( subject-fromSubject+1 , 8 )= val;
        
        
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
    W2_MB     = X(7) ;
    
    global data
    global trialsNum
    
    global QValues
    global reward 
    global transitionLevel1
    global transitionLevel2

    
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
            %###### Compute likelihood ########
%            if (previous_r == 1) 
                logLL = logLL + trialNegLogLL(a1,s2,a2,previous_a1,beta1,beta2,stayBias,W2_MB);
%            end
            %###### Update the model ##########
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
function negLogLL = trialNegLogLL(a1,s2,a2,prev_a1,beta1,beta2,stayBias,W2_MB)
    global QValuesL1;
    global QValuesL2;
    global reward ;
    global transitionLevel2;
    
    %############ Second level
    v_MB_L2_s1a1 = transitionLevel2(1,1,1)*reward(1) + transitionLevel2(1,1,3)*reward(3);
    v_MB_L2_s1a2 = transitionLevel2(1,2,2)*reward(2) + transitionLevel2(1,2,4)*reward(4);
    v_MB_L2_s2a1 = transitionLevel2(2,1,1)*reward(1) + transitionLevel2(2,1,3)*reward(3);
    v_MB_L2_s2a2 = transitionLevel2(2,2,2)*reward(2) + transitionLevel2(2,2,4)*reward(4);
    
    v_MB_L2_s1 = max(v_MB_L2_s1a1,v_MB_L2_s1a2);
    v_MB_L2_s2 = max(v_MB_L2_s2a1,v_MB_L2_s2a2);    

    v_MF_L2_s1 = max(QValuesL2(1,1),QValuesL2(1,2));
    v_MF_L2_s2 = max(QValuesL2(2,1),QValuesL2(2,2));
    
    %############ First level 
    v_L1_s1a1 = QValuesL1(1);
    v_L1_s1a2 = QValuesL1(2);
    
        
    %############ Weighted Aggregation of the systems    
    v_L2_s1a1 =  (1-W2_MB) * QValuesL2(1,1)   +   W2_MB * v_MB_L2_s1a1 ;
    v_L2_s1a2 =  (1-W2_MB) * QValuesL2(1,2)   +   W2_MB * v_MB_L2_s1a2 ;
    v_L2_s2a1 =  (1-W2_MB) * QValuesL2(2,1)   +   W2_MB * v_MB_L2_s2a1 ;
    v_L2_s2a2 =  (1-W2_MB) * QValuesL2(2,2)   +   W2_MB * v_MB_L2_s2a2 ;
        
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
    global QValuesL1;
    global QValuesL2;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;

    %###### Agent's parameters       ######################################    
    
    QValuesL1     = zeros (2,1);   % The Q-values of s0=0   and  a1=1 or 2
    QValuesL2     = zeros (2,2);   % The Q-values of s2=1 or 2   and  a2=1 or 2
    reward        = zeros (4,1);   % Reward function for the model-based RL

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
    global QValuesL1;
    global QValuesL2;
    global reward ;

    
    % Drift of Q-values at level 1
    for a=1:2
        QValuesL1(a) = QValuesL1(a) + driftMF*(0-QValuesL1(a));
    end
    
    % Drift of Q-values at level 2
    for s=1:2
        for a=1:2
            QValuesL2(s,a) = QValuesL2(s,a) + driftMF*(0-QValuesL2(s,a));
        end
    end
    
    %Updating Q-values

    V2 = max(QValuesL2(s2,1) , QValuesL2(s2,2));
    QValuesL1(a1) = QValuesL1(a1) + alphaMF*(V2-QValuesL1(a1));

    QValuesL2(s2,a2) = QValuesL2(s2,a2) + alphaMF*(r-QValuesL2(s2,a2));
    
    %Update reward function
    for s=1:4
        if s==s3
            reward (s)    = reward(s)     + alphaMB*(r-reward(s))    ; 
        else
            if (r==1)
                reward (s)    = reward(s)     + alphaMB*(0-reward(s))    ;
            end
        end
    end        