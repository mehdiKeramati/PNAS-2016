function generateSyntheticData( W_MB , groupNum )

    subjectsNum                 = 15        ;
    trialsNum                   = 500      ;    

    %----------- Parameters of the environment
    hoppingTrialsMean           = 5         ;
    hoppingTrialsVariance       = 2         ;    

    %----------- Parameters of the agents
    betaL1                      = 8.2   ;
    betaL2                      = 4.2   ;
    stayBias                    = 0.0   ;
    learningRateMF              = 0.55  ;
    driftMF                     = 0.0   ;
    learningRateRewardMB        = 0.8   ;
    learningRateTransitionMB    = 1     ; %not used
    W_modelbased_secondStage    = 0.5   ;    
    
    mkdir(['./Data/',int2str(groupNum)]);

    for subject = 1 : subjectsNum
        
        out = agent(trialsNum,betaL1,betaL2,stayBias,learningRateMF,driftMF,learningRateRewardMB,learningRateTransitionMB, W_MB , W_modelbased_secondStage ,hoppingTrialsMean,hoppingTrialsVariance);                        
        print2file ( out , ['./Data/',int2str(groupNum),'/',int2str(subject),'.txt'] , trialsNum );
        
    end
    
end
    
