% Finding the maximum likelihood by exhaustive search over the parameter
% space, for each individual subject
function main()

    subjectsNum     = 1;
    
    %###### Range of free parameters ######################################
    %#                                      LB = Lower Bound
    %#                                      UB = Upper Bound
    %#                                      SS = Step Size
    %######################################################################
    %----------------------- Beta      : rate of exploration
    beta_LB         = 0.01     ;
    beta_UB         = .51     ;
    beta_SS         = 0.05   ;
    beta_num        = floor(( beta_UB - beta_LB )/beta_SS + 1 );
    %----------------------- Alpha     : MF learning rate
    alphaMF_LB      = 1     ;
    alphaMF_UB      = 1     ;
    alphaMF_SS      = 0.1   ;
    alphaMF_num     = floor(( alphaMF_UB - alphaMF_LB )/alphaMF_SS + 1 );    
    %----------------------- Alpha     : MB learning rate
    alphaMB_LB      = 1     ;
    alphaMB_UB      = 1     ;
    alphaMB_SS      = 0.1   ;    
    alphaMB_num     = floor(( alphaMB_UB - alphaMB_LB )/alphaMB_SS + 1 );        
    %----------------------- stay bias  : probability of repeating rewarded
    stayBias_LB     = 0     ;
    stayBias_UB     = 0.5     ;
    stayBias_SS     = 0.05   ;    
    stayBias_num    = floor(( stayBias_UB - stayBias_LB )/stayBias_SS + 1 );    
    %----------------------- Weight of first level being MB, with transfer
    W1_MB_Tr_LB     = 0     ;
    W1_MB_Tr_UB     = 0.3     ;
    W1_MB_Tr_SS     = 0.05   ;
    W1_MB_Tr_num    = floor(( W1_MB_Tr_UB - W1_MB_Tr_LB )/W1_MB_Tr_SS + 1 );    
    %----------------------- Weight of second level being MB
    W2_MB_LB        = 1     ;
    W2_MB_UB        = 1     ;
    W2_MB_SS        = 0.2   ;
    W2_MB_num       = floor(( W2_MB_UB - W2_MB_LB )/W2_MB_SS + 1 );    


    %###### LIKELIHOOD FUNCTION      ######################################
    logLikelihood   = zeros (subjectsNum,beta_num,alphaMF_num,alphaMB_num,stayBias_num,W1_MB_Tr_num,W2_MB_num);

    %###### Agent's parameters       ######################################    
    global QValues;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;
    
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

    
    %######################################################################
    %####  Computing the likelikood function                           ####
    %######################################################################    

    disp('Computing the likelihood function on the parameter space:');
    %###### For each Subject ##############################################
    for subject = 1 : subjectsNum

        %###### Display progress ##########################################
       disp(['     for subject #',int2str(subject),'/',int2str(subjectsNum)]);
        
        %###### Load data #################################################
        data = dlmread([int2str(subject),'.txt']);   
        dataSize = size(data);
        trialsNum = dataSize(1,1);        
        maxLL = -999999 ;
        
        %###### Searching the paremeter space #############################
        for beta = beta_LB : beta_SS : beta_UB
            for alphaMF = alphaMF_LB : alphaMF_SS : alphaMF_UB
                for alphaMB = alphaMB_LB : alphaMB_SS : alphaMB_UB
                    for stayBias = stayBias_LB : stayBias_SS : stayBias_UB
                        for W1_MB_Tr = W1_MB_Tr_LB : W1_MB_Tr_SS : W1_MB_Tr_UB
                            for W2_MB = W2_MB_LB : W2_MB_SS : W2_MB_UB

                                initializeAgent ()  ;
                                logLL       =   0   ;
                                a1          =   0   ;
                                %###### For each trial ####################
                                for trial = 1 : trialsNum
                                    %###### Load subject's response #######                                    
                                    previous_a1 = a1 ;                                    
                                    s1 = 0              ;
                                    s2 = data(trial,3)  ; % = 1 or 2
                                    s3 = data(trial,4)  ; % = 1, 2, 3, or 4
                                    a1 = data(trial,5)+1; % = 1 or 2 
                                    a2 = data(trial,6)+1; % = 1 or 2  
                                    r  = data(trial,17) ; % = 0 or 1                                    
                                    %###### IF it wasn't a lost trial #####
                                    if (s2 ~= 0) && (s3 ~= 0)
                                        %###### Compute likelihood ########
                                        LL = likelihood(a1,s2,a2,previous_a1,beta,stayBias,W1_MB_Tr,W2_MB)  ;
                                        logLL = logLL + LL ;
                                        %###### Update the model ##########
                                        updateAgent(a1,s2,a2,s3,r,alphaMF,alphaMB) ;
                                    end
                                end
                                logLikelihood(subject , floor((beta-beta_LB)/beta_SS+1) , floor((alphaMF-alphaMF_LB)/alphaMF_SS+1) , floor((alphaMB-alphaMB_LB)/alphaMB_SS+1) , floor((stayBias-stayBias_LB)/stayBias_SS+1) , floor((W1_MB_Tr-W1_MB_Tr_LB)/W1_MB_Tr_SS+1) , floor((W2_MB-W2_MB_LB)/W2_MB_SS+1) ) = logLL ;
                                %##################################
                                if (maxLL< logLL)
                                    maxLL           = logLL     ;
                                    maxBeta         = beta      ;
                                    maxAlphaMF      = alphaMF   ;
                                    maxAlphaMB      = alphaMB   ;
                                    maxStayBias     = stayBias  ;
                                    maxW1_MB_Tr     = W1_MB_Tr  ;
                                    maxW2_MB        = W2_MB     ;
                                end
                            end
                        end
                    end
                end
            end
        end
        %##################################################################    
        maxLL
        maxBeta             
        maxAlphaMF        
        maxAlphaMB        
        maxStayBias     
        maxW1_MB_Tr     
        maxW2_MB                

    end
    %######################################################################
    
    %######################################################################
    %####  Computing the maximum likelikood                            ####
    %######################################################################    

    disp('Searching for the maximum likelihood on the parameter space:');
    %###### For each Subject ##############################################
    for subject = 1 : subjectsNum

        %###### Display progress ##########################################
        disp(['     for subject #',int2str(subject),'/',int2str(subjectsNum)]);

        %###### Searching the paremeter space #############################
        maxLL = -999999 ;
        for beta = beta_LB : beta_SS : beta_UB
            for alphaMF = alphaMF_LB : alphaMF_SS : alphaMF_UB
                for alphaMB = alphaMB_LB : alphaMB_SS : alphaMB_UB
                    for stayBias = stayBias_LB : stayBias_SS : stayBias_UB
                        for W1_MB_Tr = W1_MB_Tr_LB : W1_MB_Tr_SS : W1_MB_Tr_UB
                            for W2_MB = W2_MB_LB : W2_MB_SS : W2_MB_UB
                                LL = logLikelihood(subject , floor((beta-beta_LB)/beta_SS+1) , floor((alphaMF-alphaMF_LB)/alphaMF_SS+1) , floor((alphaMB-alphaMB_LB)/alphaMB_SS+1) , floor((stayBias-stayBias_LB)/stayBias_SS+1) , floor((W1_MB_Tr-W1_MB_Tr_LB)/W1_MB_Tr_SS+1) , floor((W2_MB-W2_MB_LB)/W2_MB_SS+1) ) ;
                                if (maxLL< LL)
                                    maxLL = LL ;
                                    maxBeta         = beta      ;
                                    maxAlphaMF      = alphaMF   ;
                                    maxAlphaMB      = alphaMB   ;
                                    maxStayBias     = stayBias  ;
                                    maxW1_MB_Tr     = W1_MB_Tr  ;
                                    maxW2_MB        = W2_MB     ;
                                end
                            end
                        end
                    end
                end
            end
        end
        %##################################################################    
        maxLL
        maxBeta             
        maxAlphaMF        
        maxAlphaMB        
        maxStayBias     
        maxW1_MB_Tr     
        maxW2_MB                

    end
    %######################################################################

    
       
%##########################################################################
%####  Computing the likelikood of a certain trial of a certain agent  ####
%##########################################################################    
function logLL = likelihood(a1,s2,a2,prev_a1,beta,stayBias,W1_MB_Tr,W2_MB)
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
    %############ Computing the likelihood

    expA1 = exp (v_L1_s1a1/beta);
    expA2 = exp (v_L1_s1a2/beta);
    
    sum = expA1 + expA2 ;
    
    pA1 = (v_L1_s1a1/beta) / sum ;
    pA2 = (v_L1_s1a2/beta) / sum ;
    
    if (a1==1)
        logLL = pA1;
    else
        logLL = pA2;
    end

%##########################################################################
%####                    Initializing  the  Agent                      ####
%##########################################################################    
function initializeAgent ()
    global QValues;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;

    QValues     = zeros (2,2);   % The Q-values of s2=1 or 2   and  a2=1 or 2
    reward      = zeros (4,1);   % Reward function for the model-based RL


%##########################################################################
%####                    Updating the agent                            ####
%##########################################################################    
function updateAgent(a1,s2,a2, s3,r,alphaMF,alphaMB);
    global QValues;
    global reward ;
    global transitionLevel1;
    global transitionLevel2;

    QValues(s2,a2) = QValues(s2,a2) + alphaMF*(r-QValues(s2,a2));
    reward (s3)    = reward(s3)     + alphaMB*(r-reward(s3))    ; 
    
