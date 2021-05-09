function generateSyntheticData( )

    subjectsNum                 = 15        ;
    trialsNum                   = 500      ;    

    %----------- Parameters of the environment
    hoppingTrialsMean           = 5         ;
    hoppingTrialsVariance       = 2         ;    
    
    %----------- Parameters of the agents
    W_MB                        = 0.5   ;
    stayBias                    = 0.0   ;
    learningRateMF              = 0.55  ;
    driftMF                     = 0.0   ;
    learningRateRewardMB        = 0.8   ;
    learningRateTransitionMB    = 1     ; %not used
    W_modelbased_secondStage    = 0.5   ;    
    
    for group = 1 : 2 

        if group == 1
            betaL1                      = 8   ;
            betaL2                      = 4   ;        
        else
            betaL1                      = 16  ;
            betaL2                      = 8   ;        
        end
        
        for subject = 1 : subjectsNum

            out = agent(trialsNum,betaL1,betaL2,stayBias,learningRateMF,driftMF,learningRateRewardMB,learningRateTransitionMB, W_MB , W_modelbased_secondStage ,hoppingTrialsMean,hoppingTrialsVariance);                        
            print2file ( out , [int2str(subject + (group-1)*15),'.txt'] , trialsNum );

        end
    end 
end
    
