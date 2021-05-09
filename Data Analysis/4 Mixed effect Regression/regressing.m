function regression (model,grp)
    
    global maxLags
    global IV_nums             
    global totalPrincipalIVnums
    global predictorsMode
    clc
    
    %######################################################################
    %#              Critical parameters
    %######################################################################
    usingSyntheticData      = model   ;% 0:No  1:MB  2: Pruning  3:MF-1  4: MF-0  5: Mixed ;
    group                   = grp                                                   ;
    subjectsNum             = 15                                                    ;
    maxLags                 = 5                                                     ;
    iterationsNum           = 30                                                    ;
    predictorsMode          = 3     ; %  0:  C__  _C_  __R  CC_  C_R  _CR  CCR      ;
                                      %  1:  CCR  CRR  CRR  RRR                     ;
                                      %  2:  CCR  CRR  CRR  RRR  CCN  CRN  CRN  RRN ;
                                      %  3:  CCR+RRR   CRR+RCR   CCR+CRR   RCR+RRR  ;

    %######################################################################
    %#              Initializations
    %######################################################################
    if predictorsMode == 0 
        principalIVnumsPerLag = 7 ;
    elseif predictorsMode == 1 
        principalIVnumsPerLag = 4 ;
    elseif predictorsMode == 2 
        principalIVnumsPerLag = 8 ;
    elseif predictorsMode == 3 
        principalIVnumsPerLag = 4 ;    
    end
    
    %######################################################################
    %#              Loading data from files    
    %######################################################################    
    disp ('Loading data from files...');

    if group==1
        fromSubject         = 25                                                    ;
        toSubject           = fromSubject + subjectsNum -1                          ;
    else
        fromSubject         = 54                                                    ;
        toSubject           = fromSubject + subjectsNum -1                          ;
    end

    if usingSyntheticData == 1
        fromSubject         = 1                                                     ;
    end
    
    trialsNum               = zeros (subjectsNum,1)                                 ;    
    data                    = cell  (subjectsNum,1)                                 ;

    for subject = 1 : subjectsNum
        if     usingSyntheticData == 1
            data{subject} = dlmread(['Data/DataSynthMBas',int2str(subject),'.txt']);   
        elseif usingSyntheticData == 2
            data{subject} = dlmread(['Data/DataSynthPrun',int2str(subject),'.txt']);   
        elseif usingSyntheticData == 3
            data{subject} = dlmread(['Data/DataSynthMF1e',int2str(subject),'.txt']);   
        elseif usingSyntheticData == 4
            data{subject} = dlmread(['Data/DataSynthMF0e',int2str(subject),'.txt']);   
        elseif usingSyntheticData == 5
            data{subject} = dlmread(['Data/DataSynthMixd',int2str(subject),'.txt']);   
        else    
            data{subject} = dlmread(['Data/',int2str(subject + fromSubject - 1 ),'.txt']);   
        end        

        dataSize = size(data{subject});
        trialsNum(subject) = dataSize(1,1);    
    end
    trialNums = trialsNum(1);
    
    %######################################################################
    %#              Extraxt Dependent Variable from Data
    %######################################################################    
    disp ('Computing the dependent variables...');

    choice                  = zeros ( subjectsNum * (trialNums-maxLags) , 1 )              ;    
    for subject = 1 : subjectsNum
        subjectData = data{subject};            
        for trial = 1+maxLags : trialNums
            choice ( (subject-1)*(trialNums-maxLags)  + trial-maxLags ) = subjectData(trial,5) - 0.5 ;
            
            if ~usingSyntheticData
                if subjectData(trial,7)==0
                    choice ( (subject-1)*(trialNums-maxLags)  + trial-maxLags ) = NaN ;                
                end
                for lag = 1 : maxLags
                    if (subjectData(trial-lag,7)==0) || (subjectData(trial-lag,8)==0) || (subjectData(trial-lag,9)==0)
                        choice ( (subject-1)*(trialNums-maxLags)  + trial-maxLags ) = NaN ;                
                    end                
                end
            end
            
        end
    end
    
    %######################################################################
    %#              Extraxt Independent Variables from Data
    %######################################################################    
    disp ('Computing the independent variables...');

    IV_nums                 = 26  ;
    IV                      = zeros ( subjectsNum * (trialNums-maxLags) , IV_nums*maxLags )   ;    
    subjectIndicator        = zeros ( subjectsNum * (trialNums-maxLags) , 1)   ;        

    IV_act                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;   
    
    IV_C__                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_R__                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV__C_                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV__R_                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV___R                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV___N                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_CC_                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_CR_                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_RC_                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_RR_                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_C_R                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV_C_N                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV_R_R                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV_R_N                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV__CR                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV__CN                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV__RR                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV__RN                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ; 
    IV_CCR                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_CRR                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_RCR                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_RRR                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_CCN                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_CRN                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_RCN                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    IV_RRN                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    

    
    action                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    reward                  = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    transitionL1            = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;    
    transitionL2            = zeros ( subjectsNum , trialNums-maxLags , maxLags )   ;        
    
    for subject = 1 : subjectsNum
        subjectData = data{subject};            
        for trial = 1 : trialNums-maxLags
            for lag = 1 : maxLags
                action      ( subject , trial , lag ) = subjectData(trial+maxLags-lag, 5)   ;   % 0:left       1:Right
                reward      ( subject , trial , lag ) = subjectData(trial+maxLags-lag,17)   ;   % 0:NoReward   1:Reward
                transitionL1( subject , trial , lag ) = subjectData(trial+maxLags-lag,13)   ;   % 0:Common     1:Rare
                transitionL2( subject , trial , lag ) = subjectData(trial+maxLags-lag,14)   ;   % 0:Common     1:Rare
            end
        end
    end
    
    for subject = 1 : subjectsNum
        for trial = 1 : trialNums-maxLags
            for lag = 1 : maxLags
                T1 = not ( transitionL1( subject , trial , lag ) )        ;
                T2 = not ( transitionL2( subject , trial , lag ) )        ;
                R  =       reward      ( subject , trial , lag )          ;                
                
                IV_act ( subject , trial , lag ) = action ( subject , trial , lag ) ;
                
                IV_C__ ( subject , trial , lag ) =     T1                 ;          
                IV_R__ ( subject , trial , lag ) = not(T1)                ;                  
                IV__C_ ( subject , trial , lag ) =             T2         ;                  
                IV__R_ ( subject , trial , lag ) =         not(T2)        ;                  
                IV___R ( subject , trial , lag ) =                     R  ;                  
                IV___N ( subject , trial , lag ) =                 not(R) ;                  
                IV_CC_ ( subject , trial , lag ) =     T1 *    T2         ;                  
                IV_CR_ ( subject , trial , lag ) =     T1 *not(T2)        ;                  
                IV_RC_ ( subject , trial , lag ) = not(T1)*    T2         ;                  
                IV_RR_ ( subject , trial , lag ) = not(T1)*not(T2)        ;                                  
                IV_C_R ( subject , trial , lag ) =     T1 *            R  ;                  
                IV_C_N ( subject , trial , lag ) =     T1 *        not(R) ;                
                IV_R_R ( subject , trial , lag ) = not(T1)*            R  ;                          
                IV_R_N ( subject , trial , lag ) = not(T1)*        not(R) ;       
                IV__CR ( subject , trial , lag ) =             T2 *    R  ;                  
                IV__CN ( subject , trial , lag ) =             T2 *not(R) ;                
                IV__RR ( subject , trial , lag ) =         not(T2)*    R  ;                          
                IV__RN ( subject , trial , lag ) =         not(T2)*not(R) ;       
                IV_CCR ( subject , trial , lag ) =     T1 *    T2 *    R  ;                  
                IV_CRR ( subject , trial , lag ) =     T1 *not(T2)*    R  ;                  
                IV_RCR ( subject , trial , lag ) = not(T1)*    T2 *    R  ;                  
                IV_RRR ( subject , trial , lag ) = not(T1)*not(T2)*    R  ;                  
                IV_CCN ( subject , trial , lag ) =     T1 *    T2 *not(R) ;                  
                IV_CRN ( subject , trial , lag ) =     T1 *not(T2)*not(R) ;                  
                IV_RCN ( subject , trial , lag ) = not(T1)*    T2 *not(R) ;                  
                IV_RRN ( subject , trial , lag ) = not(T1)*not(T2)*not(R) ;               
            end
        end
    end

    for subject = 1 : subjectsNum
        for trial = 1 : trialNums-maxLags

            index1 = (subject-1)*(trialNums-maxLags) + trial ;
            subjectIndicator ( index1 ) = subject ;

            for lag = 1 : maxLags        
                index2 = (lag-1)*IV_nums ;
                IV ( index1 , index2 +  1 ) = IV_C__ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  2 ) = IV__C_ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  3 ) = IV___R ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  4 ) = IV_CC_ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  5 ) = IV_C_R ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  6 ) = IV__CR ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  7 ) = IV_CCR ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                
                IV ( index1 , index2 +  8 ) = IV_R__ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 +  9 ) = IV__R_ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 10 ) = IV___N ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;

                IV ( index1 , index2 + 11 ) = IV_CR_ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 12 ) = IV_RC_ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 13 ) = IV_RR_ ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 14 ) = IV_C_N ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 15 ) = IV_R_R ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 16 ) = IV_R_N ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 17 ) = IV__CN ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 18 ) = IV__RR ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 19 ) = IV__RN ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                
                IV ( index1 , index2 + 20 ) = IV_CRR ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 21 ) = IV_RCR ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 22 ) = IV_RRR ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 23 ) = IV_CCN ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 24 ) = IV_CRN ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 25 ) = IV_RCN ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
                IV ( index1 , index2 + 26 ) = IV_RRN ( subject , trial , lag ) * ( IV_act(subject,trial,lag) - 0.5 ) ;
            end
            
        end
    end
    
    %######################################################################
    %#              Remove all NaN rows from data
    %######################################################################    

   disp ('Removing the missed trials from data...');
 
    NaNCounter            = 0 ;
    for subject = 1 : subjectsNum
        for trial = 1+maxLags : trialNums
            if isnan ( choice ( (subject-1)*(trialNums-maxLags)  + trial-maxLags ) )
                NaNCounter = NaNCounter + 1 ;
            end            
        end
    end
    
    disp(['    The total number of removed rows is ',int2str(NaNCounter)]);

    
    newChoice                  = zeros ( subjectsNum * (trialNums-maxLags) - NaNCounter , 1 )              ;    
    newIV                      = zeros ( subjectsNum * (trialNums-maxLags) - NaNCounter , IV_nums*maxLags )   ;    
    newSubjectIndicator        = zeros ( subjectsNum * (trialNums-maxLags) - NaNCounter , 1)   ;        

    index = 0 ;
    for subject = 1 : subjectsNum
        for trial = 1+maxLags : trialNums
            if ~ isnan ( choice ( (subject-1)*(trialNums-maxLags)  + trial-maxLags ) )
                index                           = index + 1                                                               ;
                newChoice           (index,:)   = choice           ( (subject-1)*(trialNums-maxLags)  + trial-maxLags , :);
                newIV               (index,:)   = IV               ( (subject-1)*(trialNums-maxLags)  + trial-maxLags , :);
                newSubjectIndicator (index,:)   = subjectIndicator ( (subject-1)*(trialNums-maxLags)  + trial-maxLags , :);
            end            
        end
    end
    
    
    %######################################################################
    %#              Mixed-effect Logistic Regression
    %######################################################################    
    disp ('Mixed-effect regression analysis started...');               
    
    totalIVnums             = IV_nums              *maxLags + 1 ;    
    totalPrincipalIVnums    = principalIVnumsPerLag*maxLags + 1 ;
    
    w0 = ones ( totalPrincipalIVnums , 1 ) - 0.5 ;
    
    nlme_model = @(W,inputM) (1./(1+exp(-linSum (W,inputM)))); 
    [w,PSI,stats] = nlmefitsa(newIV,newChoice,newSubjectIndicator,[],nlme_model,w0,'NIterations',[iterationsNum iterationsNum iterationsNum]);%,'LogLikMethod','is');
    
    
    
    %######################################################################
    %#                      Saving the results
    %######################################################################        
    
    if     usingSyntheticData == 1
        save (['Results/ResultsSynthMBas-Lags',int2str(maxLags),'.mat'],'w','PSI','stats') ;
    elseif usingSyntheticData == 2
        save (['Results/ResultsSynthPrun-Lags',int2str(maxLags),'.mat'],'w','PSI','stats') ;
    elseif usingSyntheticData == 3
        save (['Results/ResultsSynthMF1e-Lags',int2str(maxLags),'.mat'],'w','PSI','stats') ;
    elseif usingSyntheticData == 4
        save (['Results/ResultsSynthMF0e-Lags',int2str(maxLags),'.mat'],'w','PSI','stats') ;
    elseif usingSyntheticData == 5
        save (['Results/ResultsSynthMixd-Lags',int2str(maxLags),'.mat'],'w','PSI','stats') ;
    else    
        save (['Results/ResultsGrp',int2str(group),'-Lags',int2str(maxLags),'.mat'],'w','PSI','stats') ;
    end    
    

    
%######################################################################
%#                      Linear summation - Logg odds
%######################################################################            

function sss = linSum(W,inputM)
    global maxLags
    global IV_nums             
    global predictorsMode

%    predictorsMode=  
%           0:  C__  _C_  __R  CC_  C_R  _CR  CCR      ;
%           1:  CCR  CRR  CRR  RRR                     ;
%           2:  CCR  CRR  CRR  RRR  CCN  CRN  CRN  RRN ;
%           3:  CCR+RRR   CRR+RCR   CCR+CRR   RCR+RRR  ;
    
    if predictorsMode==0
        sss = W(:,1); 
        for lag = 1 : maxLags

            lagSum= 0 ;
            lagStarterForIVs     = (lag-1)*IV_nums ; 
            lagStarterForWeights = (lag-1)*7       ; 

            for  principalIV = 1 : 7
                indexW  = lagStarterForWeights+principalIV ;
                indexIV = lagStarterForIVs+principalIV     ;
                lagSum = lagSum + W(:,indexW+1 ).*( inputM(:,indexIV ));
            end

            sss = sss + lagSum ;
        end
        
    elseif predictorsMode==1 
        sss = W(:,1);         
        for lag = 1 : maxLags
            lagStarterForIVs     = (lag-1)*IV_nums ; 
            lagStarterForWeights = (lag-1)*4 + 1   ; 

            lagSum =  W(:,lagStarterForWeights+1 ).*( inputM(:,lagStarterForIVs+7 )) + ...
                      W(:,lagStarterForWeights+2 ).*( inputM(:,lagStarterForIVs+20)) + ...
                      W(:,lagStarterForWeights+3 ).*( inputM(:,lagStarterForIVs+21)) + ...
                      W(:,lagStarterForWeights+4 ).*( inputM(:,lagStarterForIVs+22)) ;
            sss = sss + lagSum ;
        end
        
    elseif predictorsMode==2 
        sss = W(:,1);         
        for lag = 1 : maxLags
            lagStarterForIVs     = (lag-1)*IV_nums ; 
            lagStarterForWeights = (lag-1)*8 + 1   ; 

            lagSum =  W(:,lagStarterForWeights+1 ).*( inputM(:,lagStarterForIVs+7 )) + ...
                      W(:,lagStarterForWeights+2 ).*( inputM(:,lagStarterForIVs+20)) + ...
                      W(:,lagStarterForWeights+3 ).*( inputM(:,lagStarterForIVs+21)) + ...
                      W(:,lagStarterForWeights+4 ).*( inputM(:,lagStarterForIVs+22)) + ...
                      W(:,lagStarterForWeights+5 ).*( inputM(:,lagStarterForIVs+23)) + ...
                      W(:,lagStarterForWeights+6 ).*( inputM(:,lagStarterForIVs+24)) + ...
                      W(:,lagStarterForWeights+7 ).*( inputM(:,lagStarterForIVs+25)) + ...
                      W(:,lagStarterForWeights+8 ).*( inputM(:,lagStarterForIVs+26)) ;
            sss = sss + lagSum ;
        end
        
    elseif predictorsMode==3 
        sss = W(:,1);         
        for lag = 1 : maxLags
            lagStarterForIVs     = (lag-1)*IV_nums ; 
            lagStarterForWeights = (lag-1)*4 + 1   ; 

            lagSum =  W(:,lagStarterForWeights+1 ).*( inputM(:,lagStarterForIVs+7 ) + inputM(:,lagStarterForIVs+22) ) + ...
                      W(:,lagStarterForWeights+2 ).*( inputM(:,lagStarterForIVs+20) + inputM(:,lagStarterForIVs+21) ) + ...
                      W(:,lagStarterForWeights+3 ).*( inputM(:,lagStarterForIVs+7 ) + inputM(:,lagStarterForIVs+20) ) + ...
                      W(:,lagStarterForWeights+4 ).*( inputM(:,lagStarterForIVs+21) + inputM(:,lagStarterForIVs+22) ) ;

            sss = sss + lagSum ;
        end
        
    end      