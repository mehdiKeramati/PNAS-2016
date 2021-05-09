%##########################################################################
%####                 Reinforcement Learning Agent                     ####
%##########################################################################
%##  Parameter:       
%##              Name                 Range                            
%##------------------------------------------------------------------------
%##              trialsNum                  1 to infinity
%##              explorationRate            Rate of exploration
%##              stayBias             
%##              learningRateMF             [0,1] : Model-free learning rate
%##              learningRateRewardMB       [0,1] : Model-based reward learning rate
%##              learningRateTransitionMB   [0,1] : Model-based Transition learning rate
%##              microAgentsWeights         Eight numbers between 0 and 1, with sum = 1
%##                     [1] Model-based (no-transfer) Model-based
%##                     [2] Model-based (no-transfer) Model-free
%##                     [3] Model-based (transfer)    Model-based
%##                     [4] Model-based (transfer)    Model-free
%##                     [5] Model-free (eligibiloty=1)Model-based
%##                     [6] Model-free (eligibiloty=1)Model-free
%##                     [7] Model-free (eligibiloty=0)Model-based
%##                     [8] Model-free (eligibiloty=0)Model-free
%##              hoppingTrialsMean          1 to infinity
%##              hoppingTrialsVariance      1 to infinity
%##------------------------------------------------------------------------
%##  Output:       
%##                                          
%##########################################################################
function behavior = SynAgent(trialsNum,explorationRate,explorationRateLevel2,stayBias,learningRateMF,driftMF,learningRateRewardMB,learningRateTransitionMB,microAgentsWeights,hoppingTrialsMean,hoppingTrialsVariance);

    global QEligibility
    global QNoEligibility
    global transitionPSubjective
    global rewardSubjective

    agentInitialization();        
    environmentInitialization(hoppingTrialsMean , hoppingTrialsVariance);        

    firstLevelAction = randi([1,2]);  % Just to determine the "previous action" that biases the first action
    
    for trial = 1 : trialsNum        

        %------------------------------------------------------------------
        %----------- Evaluation of actions at the first level  ------------
        values(1) = microAgentEvaluationFirstLevel ('model-based','no-transfer',0);    
        values(2) = microAgentEvaluationFirstLevel ('model-based','no-transfer',0);         
        values(3) = microAgentEvaluationFirstLevel ('model-based','transfer'   ,0);    
        values(4) = microAgentEvaluationFirstLevel ('model-based','transfer'   ,0);         
        values(5) = microAgentEvaluationFirstLevel ('model-free' ,''           ,1);    
        values(6) = microAgentEvaluationFirstLevel ('model-free' ,''           ,1);         
        values(7) = microAgentEvaluationFirstLevel ('model-free' ,''           ,0);    
        values(8) = microAgentEvaluationFirstLevel ('model-free' ,''           ,0);

        value.action1 = 0 ;
        value.action2 = 0 ;
        for i = 1 : 8           % for all microagents
            value.action1 = value.action1 + microAgentsWeights(i)*values(i).action1;
            value.action2 = value.action2 + microAgentsWeights(i)*values(i).action2;
        end

        behavior(trial).V1 = value.action1 ;
        behavior(trial).V2 = value.action2 ;        
        
        %------------------------------------------------------------------
        %------------       First Level Action Selection       ------------
        previousAction   = firstLevelAction     ;
        firstLevelAction = softmaxLevel1 (value.action1, value.action2, explorationRate, stayBias, previousAction);
        
        %------------------------------------------------------------------
        %------------        Feedback from the environment     ------------
        [secondLevelState,firstLevelTransitionType] = transition (1,firstLevelAction);

        %------------------------------------------------------------------
        %----------- Evaluation of actions at the second level ------------
        values(1) = microAgentEvaluationSecondLevel (secondLevelState,'model-based');    
        values(2) = microAgentEvaluationSecondLevel (secondLevelState,'model-free' );         
        values(3) = microAgentEvaluationSecondLevel (secondLevelState,'model-based');    
        values(4) = microAgentEvaluationSecondLevel (secondLevelState,'model-free' );         
        values(5) = microAgentEvaluationSecondLevel (secondLevelState,'model-based');    
        values(6) = microAgentEvaluationSecondLevel (secondLevelState,'model-free' );         
        values(7) = microAgentEvaluationSecondLevel (secondLevelState,'model-based');    
        values(8) = microAgentEvaluationSecondLevel (secondLevelState,'model-free' );

        
        value.action1 = 0 ;
        value.action2 = 0 ;
        for i = 1 : 8           % for all microagents
            value.action1 = value.action1 + microAgentsWeights(i)*values(i).action1;
            value.action2 = value.action2 + microAgentsWeights(i)*values(i).action2;
        end
        
        %------------------------------------------------------------------
        %------------      Second Level Action Selection       ------------
        secondLevelAction = softmaxLevel2 (value.action1, value.action2, explorationRateLevel2 );
        
        %------------------------------------------------------------------
        %------------        Feedback from the environment     ------------
        [thirdLevelState,secondLevelTransitionType] = transition (secondLevelState,secondLevelAction);
        reward = getReward (thirdLevelState);
        
        %------------------------------------------------------------------
        %------------    Updating agent and environment        ------------
        agentLearning(firstLevelAction,secondLevelAction,secondLevelState,thirdLevelState,reward,learningRateMF,driftMF,learningRateRewardMB);    
        environmentEvolving (hoppingTrialsMean , hoppingTrialsVariance);
        
        %------------------------------------------------------------------
        %------------         Output to the environment        ------------
        behavior(trial).firstLevelAction            = firstLevelAction          ;
        behavior(trial).secondLevelAction           = secondLevelAction         ;
        behavior(trial).secondLevelState            = secondLevelState          ;
        behavior(trial).thirdLevelState             = thirdLevelState           ;
        behavior(trial).reward                      = reward                    ;
        behavior(trial).firstLevelTransitionType    = firstLevelTransitionType  ;
        behavior(trial).secondLevelTransitionType   = secondLevelTransitionType ;
        
    end
    
%##########################################################################
%####                 Initializing  the  Environment                   ####
%##########################################################################    
function environmentInitialization(hoppingTrialsMean , hoppingTrialsVariance);        

    global transitionP
    global reward
    global trialsTillRewardHops
     
    transitionP= zeros(7,2,7);
    transitionP(1,1,2) = 0.7 ;
    transitionP(1,1,3) = 0.3 ;
    transitionP(1,2,2) = 0.3 ;
    transitionP(1,2,3) = 0.7 ;
    transitionP(2,1,4) = 0.7 ;
    transitionP(2,1,6) = 0.3 ;
    transitionP(2,2,5) = 0.7 ;
    transitionP(2,2,7) = 0.3 ;
    transitionP(3,1,4) = 0.3 ;
    transitionP(3,1,6) = 0.7 ;
    transitionP(3,2,5) = 0.3 ;
    transitionP(3,2,7) = 0.7 ;
    
    reward   = zeros (1,7); 
    rewardingState = 3 + randi([1,4]);
    reward(rewardingState) = 1       ;
    trialsTillRewardHops = round (normrnd( hoppingTrialsMean , hoppingTrialsVariance , 1 , 1));
    if trialsTillRewardHops < 1
        trialsTillRewardHops = 1;
    end
   
%##########################################################################
%####                    Initializing  the  Agent                      ####
%##########################################################################    
function agentInitialization();    
    global QEligibility
    global QNoEligibility
    global transitionPSubjective
    global rewardSubjective

    
    QEligibility   = zeros (1,2);   % The Q-values of (s1,a1) , (s1,a2) for when ? = 1
    QNoEligibility = zeros (3,2);   % The Q-values of (s[1,2,3],a[1,2]) for when ? = 0

    transitionPSubjective= zeros(7,2,7);
    transitionPSubjective(1,1,2) = 0.7 ;
    transitionPSubjective(1,1,3) = 0.3 ;
    transitionPSubjective(1,2,2) = 0.3 ;
    transitionPSubjective(1,2,3) = 0.7 ;
    transitionPSubjective(2,1,4) = 0.7 ;
    transitionPSubjective(2,1,6) = 0.3 ;
    transitionPSubjective(2,2,5) = 0.7 ;
    transitionPSubjective(2,2,7) = 0.3 ;
    transitionPSubjective(3,1,4) = 0.3 ;
    transitionPSubjective(3,1,6) = 0.7 ;
    transitionPSubjective(3,2,5) = 0.3 ;
    transitionPSubjective(3,2,7) = 0.7 ;
        
    rewardSubjective = zeros (1,7); 
    
%##########################################################################
%####            Computing value of action at the first level          ####
%##########################################################################
function values = microAgentEvaluationFirstLevel (firstLevelRL,transfer,eligibilityTrace);

    global QEligibility
    global QNoEligibility
    global transitionPSubjective
    global rewardSubjective

    if strcmp(firstLevelRL,'model-free')
        if eligibilityTrace==0            
            values.action1 = QNoEligibility(1,1) ;
            values.action2 = QNoEligibility(1,2) ;
        elseif eligibilityTrace==1
            values.action1 = QEligibility(1,1) ;
            values.action2 = QEligibility(1,2) ;            
        else
            message = 'Error1'
        end
    elseif strcmp(firstLevelRL,'model-based')
        if strcmp(transfer,'transfer')
            values.action1 = transitionPSubjective(1,1,2)* max(QNoEligibility(2,1),QNoEligibility(2,2)) + transitionPSubjective(1,1,3)* max(QNoEligibility(3,1),QNoEligibility(3,2));
            values.action2 = transitionPSubjective(1,2,2)* max(QNoEligibility(2,1),QNoEligibility(2,2)) + transitionPSubjective(1,2,3)* max(QNoEligibility(3,1),QNoEligibility(3,2));
        elseif strcmp(transfer,'no-transfer')
            valuesS2A1 = transitionPSubjective(2,1,4)*rewardSubjective(4) + transitionPSubjective(2,1,6)*rewardSubjective(6);
            valuesS2A2 = transitionPSubjective(2,2,5)*rewardSubjective(5) + transitionPSubjective(2,2,7)*rewardSubjective(7);
            valuesS3A1 = transitionPSubjective(3,1,4)*rewardSubjective(4) + transitionPSubjective(3,1,6)*rewardSubjective(6);
            valuesS3A2 = transitionPSubjective(3,2,5)*rewardSubjective(5) + transitionPSubjective(3,2,7)*rewardSubjective(7);
            valuesS2 = max ( valuesS2A1 , valuesS2A2 ) ;
            valuesS3 = max ( valuesS3A1 , valuesS3A2 ) ;
            values.action1 = transitionPSubjective(1,1,2)*valuesS2 + transitionPSubjective(1,1,3)*valuesS3;
            values.action2 = transitionPSubjective(1,2,2)*valuesS2 + transitionPSubjective(1,2,3)*valuesS3;            
        else
            message = 'Error3'
        end
    else
        Message = 'Error2'
    end
    
%##########################################################################
%####            Computing value of action at the Second level         ####
%##########################################################################
function values = microAgentEvaluationSecondLevel (secondLevelState,secondLevelRL);

    global QEligibility
    global QNoEligibility
    global transitionPSubjective
    global rewardSubjective

    if strcmp(secondLevelRL,'model-free')
            values.action1 = QNoEligibility(secondLevelState,1) ;   
            values.action2 = QNoEligibility(secondLevelState,2) ;        
    elseif strcmp(secondLevelRL,'model-based')
            values.action1 = transitionPSubjective(secondLevelState,1,4)*rewardSubjective(4) + transitionPSubjective(secondLevelState,1,6)*rewardSubjective(6);
            values.action2 = transitionPSubjective(secondLevelState,2,5)*rewardSubjective(5) + transitionPSubjective(secondLevelState,2,7)*rewardSubjective(7);
    else
        Message = 'Error4'
    end
    
%##########################################################################
%####                      Softmax Action Selection                    ####
%##########################################################################
function action = softmaxLevel1 (v1,v2,beta,stayBias,previousAction);
    
    if previousAction == 1
        previousActionIs1 = 1;
        previousActionIs2 = 0;
    elseif previousAction == 2
        previousActionIs1 = 0;
        previousActionIs2 = 1;
    elseif previousAction == 3
        previousActionIs1 = 0;
        previousActionIs2 = 0;
    else
        message = 'error5'
    end
        
    action1exp = exp ( beta * ( v1 + stayBias*previousActionIs1 ) );
    action2exp = exp ( beta * ( v2 + stayBias*previousActionIs2 ) );
    
    action1Prob = action1exp / (action1exp + action2exp);

    ind = rand();
    if ind<action1Prob
        action = 1;
    else
        action = 2;
    end

%##########################################################################
%####                      Softmax Action Selection                    ####
%##########################################################################
function action = softmaxLevel2 (v1,v2,beta);
        
    action1exp = exp ( beta * v1 );
    action2exp = exp ( beta * v2 );
    
    action1Prob = action1exp / (action1exp + action2exp);

    ind = rand();
    if ind<action1Prob
        action = 1;
    else
        action = 2;
    end
    
%##########################################################################
%####                            Transition                            ####
%##########################################################################    
function [nextState,transitionType] = transition (state,action);

    global transitionP

    ind = rand();

    if state==1
        if action==1    
            if ind < transitionP(1,1,2)
                transitionType = 0 ; %common
                nextState = 2 ;
            else
                transitionType = 1 ; %rare
                nextState = 3 ;
            end
        else
            if ind < transitionP(1,2,2)
                transitionType = 1 ; %rare
                nextState = 2 ;
            else
                transitionType = 0 ; %common
                nextState = 3 ;
            end
        end
    elseif state==2
        if action ==1    
            if ind < transitionP(2,1,4)
                transitionType = 0 ; %common
                nextState = 4 ;
            else
                transitionType = 1 ; %rare
                nextState = 6 ;
            end
        else
            if ind < transitionP(2,2,5)
                transitionType = 0 ; %common
                nextState = 5 ;
            else
                transitionType = 1 ; %rare
                nextState = 7 ;
            end
        end
    elseif state==3
        if action ==1    
            if ind < transitionP(3,1,4)
                transitionType = 1 ; %rare
                nextState = 4 ;
            else
                transitionType = 0 ; %common
                nextState = 6 ;
            end
        else
            if ind < transitionP(3,2,5)
                transitionType = 1 ; %rare
                nextState = 5 ;
            else
                transitionType = 0 ; %common
                nextState = 7 ;
            end
        end
    else
        message = 'error6'
    end    
        
%##########################################################################
%####                             Reward                               ####
%##########################################################################    
function rwrd = getReward (thirdLevelState);
    global reward
    rwrd = reward(thirdLevelState) ;
            
%##########################################################################
%####                           Learning                               ####
%##########################################################################    
function agentLearning(firstLevelAction,secondLevelAction,secondLevelState,thirdLevelState,rwrd,learningRateMF,driftMF,alphaMB);
    global QEligibility
    global QNoEligibility
    global rewardSubjective

    for s2 = 2:3
        for a2 = 1:2
            if (s2==secondLevelState) && (a2==secondLevelAction)
                delta = rwrd - QNoEligibility (secondLevelState,secondLevelAction);
                QNoEligibility (secondLevelState,secondLevelAction) = QNoEligibility (secondLevelState,secondLevelAction) + delta * learningRateMF ;           
            else
                QNoEligibility (s2,a2) = QNoEligibility (s2,a2) + driftMF*(0-QNoEligibility (s2,a2));
            end            
        end
    end

    
    for a1 = 1:2
        if (a1==firstLevelAction)
            delta = max( QNoEligibility (secondLevelState,1) , QNoEligibility (secondLevelState,2) ) - QNoEligibility (1,firstLevelAction);
            QNoEligibility (1,firstLevelAction) = QNoEligibility (1,firstLevelAction) + delta * learningRateMF ;            
        else
            QNoEligibility (1,a1) = QNoEligibility (1,a1) + driftMF*(0-QNoEligibility (1,a1));
        end            
    end    
    
    
    
    for a1 = 1:2
        if (a1==firstLevelAction)
            delta = rwrd - QEligibility (firstLevelAction);
            QEligibility (firstLevelAction) = QEligibility (firstLevelAction) + delta * learningRateMF ;
        else
            QEligibility(a1) = QEligibility(a1) + driftMF*(0-QEligibility(a1));
        end            
    end    
    

    

    
    
    
    
    
    
    
    
    if rwrd==1
        for i = 1 : 7
            rewardSubjective(i) = rewardSubjective(i) + alphaMB*(0-rewardSubjective(i));
        end
    end
    rewardSubjective(thirdLevelState) = rewardSubjective(thirdLevelState)+ alphaMB*(rwrd-rewardSubjective(thirdLevelState));
        
%##########################################################################
%####                    Environment Evolving                          ####
%##########################################################################    
function environmentEvolving(hoppingTrialsMean , hoppingTrialsVariance);        
    global reward
    global trialsTillRewardHops
    
    trialsTillRewardHops = trialsTillRewardHops - 1 ;
    if trialsTillRewardHops == 0        
        trialsTillRewardHops = round (normrnd( hoppingTrialsMean , hoppingTrialsVariance , 1 , 1));
        if trialsTillRewardHops < 1
            trialsTillRewardHops = 1;
        end
        
        
        for i = 4:7
            if reward(i)
                preRewardingState = i ;
            end
        end                
        randNumber = randi([4,6]);
        if randNumber<preRewardingState
            postRewardingState = randNumber;            
        else
            postRewardingState = randNumber+1;            
        end
        
        reward(preRewardingState) =0;
        reward(postRewardingState)=1;
    end
    