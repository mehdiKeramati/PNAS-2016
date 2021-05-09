function generateSyntheticData( param , trialsNum , subjectNum )


    %----------- Parameters of the environment
    hoppingTrialsMean           = 5         ;
    hoppingTrialsVariance       = 2         ;    

    %----------- Parameters of the agents

    W_modelbased_firstStage     = param(1)   ;    
    W_modelbased_secondStage    = param(2)   ; 
    stayBias                    = param(3)   ; 
    learningRateRewardMB        = param(4)   ; 
    learningRateTransitionMB    = 1     ; %not used
    learningRateMF              = param(5)   ; 
    driftMF                     = param(6)   ; 
    betaL1                      = param(7)   ; 
    betaL2                      = param(8)   ;                    
    
    out = agent(trialsNum,betaL1,betaL2,stayBias,learningRateMF,driftMF,learningRateRewardMB,learningRateTransitionMB, W_modelbased_firstStage , W_modelbased_secondStage ,hoppingTrialsMean,hoppingTrialsVariance);                        
    print2file ( out , [int2str(subjectNum),'.txt'] , trialsNum );
        
    
end
    
