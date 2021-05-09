function main()

    modelType                   = 5         ;% 1:MB  2: Pruning  3:MF-1  4: MF-0  5: Mixed ;
    subjectsNum                 = 15        ;
    trialsNum                   = 500      ;    

    %----------- Parameters of the environment
    hoppingTrialsMean           = 5         ;
    hoppingTrialsVariance       = 2         ;    

    %----------- Parameters of the agents
    betaL1                      = 8.2  ;
    betaL2                      = 4.2  ;
    stayBias                    = 0.0       ;
    learningRateMF              = 0.55        ;
    driftMF                     = 0.0       ;
    learningRateRewardMB        = 0.8         ;
    learningRateTransitionMB    = 1         ; %not used

    w = 1.5 ;
    w2 = 0.59 ;  % Model-free weight on the second level (extracted from group 2 (700msec) )
    
    if     modelType==1
        microAgentsWeights          = [ w * (1-w2)   , w * w2   , 0.0 , 0.0 , 0.0 , 0.0 , 0.0, 0.0 ];   
    elseif modelType==2
        microAgentsWeights          = [ 0.0 , 0.0 , w*(1-w2)   , w*w2   , 0.0 , 0.0 , 0.0, 0.0 ];
    elseif modelType==3
        microAgentsWeights          = [ 0.0 , 0.0 , 0.0 , 0.0 , w*(1-w2)/4 , w*w2/4 , 0.0, 0.0 ];
    elseif modelType==4
        microAgentsWeights          = [ 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , w/4, w/4 ];
    elseif modelType==5
        microAgentsWeights          = [ w * (1-w2)*0.25   , w*w2*0.25   , w * (1-w2)*0.75 , w*w2*0.75 , 0.0 , 0.0 , 0.0, 0.0 ];
    end
    
    stayProbsR = zeros (subjectsNum, 4 ) ;    
    stayProbsN = zeros (subjectsNum, 4 ) ;    
    
    for subject = 1 : subjectsNum

        out = agent(trialsNum,betaL1,betaL2,stayBias,learningRateMF,driftMF,learningRateRewardMB,learningRateTransitionMB,microAgentsWeights,hoppingTrialsMean,hoppingTrialsVariance);

       [CCS_Rewarded,CRS_Rewarded,RCS_Rewarded,RRS_Rewarded,...
        CCS_noReward,CRS_noReward,RCS_noReward,RRS_noReward]... 
                                                    = plotIndividual (out,'no-plot');
       
                                                
       stayProbsR(subject,:) = [CCS_Rewarded,CRS_Rewarded,RCS_Rewarded,RRS_Rewarded];
       stayProbsN(subject,:) = [CCS_noReward,CRS_noReward,RCS_noReward,RRS_noReward];
    
    if     modelType==1
       print2file(out,['DataSynthMBas',int2str(subject),'.txt'],trialsNum);
    elseif modelType==2
       print2file(out,['DataSynthPrun',int2str(subject),'.txt'],trialsNum);
    elseif modelType==3
       print2file(out,['DataSynthMF1e',int2str(subject),'.txt'],trialsNum);
    elseif modelType==4
       print2file(out,['DataSynthMF0e',int2str(subject),'.txt'],trialsNum);
    elseif modelType==5
       print2file(out,['DataSynthMixd',int2str(subject),'.txt'],trialsNum);
    end
    
   [int2str(subject),'/',int2str(subjectsNum)]
    
    end
    
    plotAggregate (stayProbsR);
    plotAggregate (stayProbsN);
 