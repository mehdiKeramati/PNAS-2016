function SynMain()

    subjectsNum                 = 1        ;

    %----------- Parameters of the environment
    trialsNum                   = 500       ;    
    hoppingTrialsMean           = 5         ;
    hoppingTrialsVariance       = 2         ;    

    %----------- Parameters of the agents
    betaL1                      = 5   ;
    betaL2                      = 5   ;
    stayBias                    = 0.0       ;
    learningRateMF              = 0.8        ;
    driftMF                     = 0.0       ;
    learningRateRewardMB        = 1         ;
    learningRateTransitionMB    = 1         ; %not used

            
    microAgentsWeights          = [ 2.0 , 0.0 ,0.0 , 0.0 , 0.8 , 0.0 , 0, 0.0 ];
    
    
    stayProbsR = zeros (subjectsNum, 4 ) ;    
    stayProbsN = zeros (subjectsNum, 4 ) ;    
    
    for subject = 1 : subjectsNum

        out = SynAgent(trialsNum,betaL1,betaL2,stayBias,learningRateMF,driftMF,learningRateRewardMB,learningRateTransitionMB,microAgentsWeights,hoppingTrialsMean,hoppingTrialsVariance);

       [CCS_Rewarded,CRS_Rewarded,RCS_Rewarded,RRS_Rewarded,...
        CCS_noReward,CRS_noReward,RCS_noReward,RRS_noReward]... 
                                                    = SynPlotIndividual (out,'no-plot');
       
                                                
       stayProbsR(subject,:) = [CCS_Rewarded,CRS_Rewarded,RCS_Rewarded,RRS_Rewarded];
       stayProbsN(subject,:) = [CCS_noReward,CRS_noReward,RCS_noReward,RRS_noReward];
    
       SynPrint2file(out,'SyntheticData.txt',trialsNum);
       
       ['subject   :   ',int2str(subject),'/',int2str(subjectsNum)]
    
    end
    
    SynPlotAggregate (stayProbsR);
 %   SynPlotAggregate (stayProbsN);
    
    
    % Good weights for individual systems (for beta = 7):
    %       Model-based (mixed)       Model-based   [ 1.2 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ]
    %       Model-based (no-transfer) Model-based   [ 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ]
    %       Model-based (transfer)    Model-based   [ 0.0 , 0.0 , 1.5 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ]
    %       Model-free (eligibiloty=1)Model-based   [ 0.0 , 0.0 , 0.0 , 0.0 , 0.1 , 0.0 , 0.00 , 0.0 ] 
    %       Model-free (eligibiloty=1)Model-based   [ 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.08 , 0.0 ] 
    
