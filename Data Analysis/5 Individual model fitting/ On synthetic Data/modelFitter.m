function modelFitter()

%    initialParam = [ 0 ; 0 ; 0 ; 20 ;  0 ; 1 ; 0.8 ; 0 ; 0.8 ; 0 ; 5 ; 5]; 
%    initialParam = [0.7695;3.1367;2.6814;-2.1024;0.0096;0.9437;0.0021;0.0582;0.4307;-0.0028;4.1306;42.0493];
%    negLogLikelihood(initialParam);
    
    for i=1:1
        
        initialParam = [ rand ; rand ; rand ; rand ;  rand ; rand ; rand ; rand ; rand ; rand ; rand ; rand]; 
        [x,val,exitflag,output,grad,hessian] = fminunc(@negLogLikelihood,initialParam);               
        disp(negLogLikelihood(x));
        disp(x);
    end



function logLL = negLogLikelihood(X)


    W1_MB           = X(1);
    W1_Prun         = X(2);
    W1_MF_Elig      = X(3); 
    W2_MB           = X(4);
    stayBias        = X(5);
    alphaMB         = X(6);
    alphaMF         = X(7); 
    driftMF         = X(8);
    alphaMF_Elig    = X(9);
    driftMF_Elig    = X(10);
    beta1           = X(11);
    beta2           = X(12); 

    
    

    model                   = zeros (4,1)                                           ;
    model (1)               = 1                     ;% Model-based                  ;
    model (2)               = 1                     ;% Pruning                      ;
    model (3)               = 1                     ;% Model-free (Elig=1)          ;
    model (4)               = 1                     ;% Model-free (Elig=0)          ;
    modelsNum = model (1) + model (2) + model (3) + model (4);


    
    
    
    
    %=== Level 1
    e = zeros(4,1);
    e(1) = exp (W1_MB     );
    e(2) = exp (W1_Prun   );
    e(3) = exp (W1_MF_Elig);
    e(4) = exp (1)               ;

    for m=1:4
        if ~model(m)
            e(m) = 0 ;
        end
    end

    m = 4 ;
    while (m>0) & (~model(m))
        m= m-1;
    end
    if m>0
        e(m) = exp(1);
    end

    normalizer = e(1) + e(2) + e(3) + e(4) ;
    if normalizer==0
        normalizer=1;
    end

    e1 = e(1) / normalizer ;
    e2 = e(2) / normalizer ;
    e3 = e(3) / normalizer ;
    e4 = e(4) / normalizer ;           

    %=== Level 2                                                 
    t1 = exp (W2_MB)     ;
    t2 = exp (1)               ;
    normalizer = t1 + t2 ;
    w1 = t1 / normalizer ;
    w2 = t2 / normalizer ;






   

   

%   e1 = 0 ;
%   e2 = 0 ;
%   e3 = 0 ;
%   e4 = 0.4;
%   w1 = 0.4;
%   w2 = 0.0 ;

    
    
    
    
    
    
    
    
    data = dlmread(['SyntheticData.txt']);   
    dataSize = size(data);
    trialsNum = dataSize(1,1);    
    
    
    isParamAvailable        = zeros (12,1)                        ;   % 1: parameter is available;  0: parameter is not available
    paramMap                = zeros (12,1)                        ;   % Mapping from potential parameters, to availabale parameters
    %----------------------- Determining available parameters
    isParamAvailable     (4) = 1 ;
    isParamAvailable     (5) = 1 ;
    isParamAvailable     (6) = 1 ;
    isParamAvailable     (7) = 1 ;
    isParamAvailable     (8) = 1 ;
    isParamAvailable     (11)= 1 ;
    isParamAvailable     (12)= 1 ;
    if model(3)
        isParamAvailable (9) = 1 ;
        isParamAvailable (10)= 1 ;    
    end    
    
    if modelsNum == 4
        isParamAvailable (1 )= 1 ;
        isParamAvailable (2 )= 1 ;
        isParamAvailable (3 )= 1 ;
    
    elseif modelsNum == 3
        if ~model(1)
            isParamAvailable (2 )= 1 ;
            isParamAvailable (3 )= 1 ;
        elseif ~model(2)
            isParamAvailable (1 )= 1 ;
            isParamAvailable (3 )= 1 ;
        else
            isParamAvailable (1 )= 1 ;
            isParamAvailable (2 )= 1 ;
        end
        
    elseif modelsNum == 2
        if model(1)
            isParamAvailable (1 )= 1 ;
        elseif model(2)
            isParamAvailable (2 )= 1 ;
        elseif model(3)
            isParamAvailable (3 )= 1 ;
                        
        end
    end
    freeParametersNum        = 0 ;       
    for i = 1:12
        if isParamAvailable(i)
            freeParametersNum = freeParametersNum + 1 ;
        end
    end    

%##########################################################################
%####                    Initializing  the  Agent                      ####
%##########################################################################    
    %------------------------ Defining the transition matrix

    transitionLevel1        = zeros(1,2,2);
    transitionLevel1(1,1,1) = 0.7 ;
    transitionLevel1(1,1,2) = 0.3 ;
    transitionLevel1(1,2,1) = 0.3 ;
    transitionLevel1(1,2,2) = 0.7 ;

    transitionLevel2        = zeros(2,2,4);
    transitionLevel2(1,1,1) = 0.7 ;
    transitionLevel2(1,1,3) = 0.3 ;
    transitionLevel2(1,2,2) = 0.7 ;
    transitionLevel2(1,2,4) = 0.3 ;
    transitionLevel2(2,1,1) = 0.3 ;
    transitionLevel2(2,1,3) = 0.7 ;
    transitionLevel2(2,2,2) = 0.3 ;
    transitionLevel2(2,2,4) = 0.7 ;          

    %------------------------ Agent's parameters   

    QValues_level1_Elig     = zeros (2,1);   % The Q-values of s1=1   and  a1=1 or 2
    QValues_level1_NoElig   = zeros (2,1);   % The Q-values of s1=1   and  a1=1 or 2
    QValues_level2          = zeros (2,2);   % The Q-values of s2=1 or 2   and  a2=1 or 2
    reward                  = zeros (4,1);   % Reward function for the model-based RL

    for i=1:4
        reward(i) = 0.25;
    end

    QValues_level1_Elig  (1,1)=0;
    QValues_level1_Elig  (2,1)=0;
    QValues_level1_NoElig(1,1)=0;
    QValues_level1_NoElig(2,1)=0;
    QValues_level2       (1,1)=0;
    QValues_level2       (1,2)=0;
    QValues_level2       (2,1)=0;
    QValues_level2       (2,2)=0;

        
    logLL       =   0   ;
    a1          =   0   ;
    r           =   0   ;
    previous_a1 = a1 ;                                    
    previous_r  = r  ;                                    
    %###### For each trial ####################
    for trial = 1 : trialsNum              
        
        %###### Load subject's response #######                                    
        s1 = 0           ;
        s2 = data(trial,3)  ; % = 1 or 2
        s3 = data(trial,4)  ; % = 1, 2, 3, or 4
        a1 = data(trial,5)+1; % = 1 or 2 
        a2 = data(trial,6)+1; % = 1 or 2  
        r  = data(trial,17) ; % = 0 or 1                                    
        %###### IF it wasn't a lost trial #####
        if (s2 ~= 0) && (s3 ~= 0)

            %##########################################################################
            %####  Computing the likelikood of a certain trial of a certain agent  ####
            %##########################################################################    

            %############ Second level
            v_MB_L2_s1a1 = transitionLevel2(1,1,1)*reward(1) + transitionLevel2(1,1,3)*reward(3);
            v_MB_L2_s1a2 = transitionLevel2(1,2,2)*reward(2) + transitionLevel2(1,2,4)*reward(4);
            v_MB_L2_s2a1 = transitionLevel2(2,1,1)*reward(1) + transitionLevel2(2,1,3)*reward(3);
            v_MB_L2_s2a2 = transitionLevel2(2,2,2)*reward(2) + transitionLevel2(2,2,4)*reward(4);

            v_MB_L2_s1 = max(v_MB_L2_s1a1,v_MB_L2_s1a2);
            v_MB_L2_s2 = max(v_MB_L2_s2a1,v_MB_L2_s2a2);    

            v_MF_L2_s1 = max(QValues_level2(1,1),QValues_level2(1,2));
            v_MF_L2_s2 = max(QValues_level2(2,1),QValues_level2(2,2));

            %############ First level without Transfer (MB)
            v_L1_noTr_s1a1 = transitionLevel1(1,1,1)*v_MB_L2_s1 + transitionLevel1(1,1,2)*v_MB_L2_s2;
            v_L1_noTr_s1a2 = transitionLevel1(1,2,1)*v_MB_L2_s1 + transitionLevel1(1,2,2)*v_MB_L2_s2;

            %############ First level with Transfer (Pruning)
            v_L1_Tr_s1a1 = transitionLevel1(1,1,1)*v_MF_L2_s1 + transitionLevel1(1,1,2)*v_MF_L2_s2;
            v_L1_Tr_s1a2 = transitionLevel1(1,2,1)*v_MF_L2_s1 + transitionLevel1(1,2,2)*v_MF_L2_s2;

            %############ Weighted Aggregation of the systems
                                                
            %=== Level 1                                    
            v_L1_s1a1 =  e1 * v_L1_noTr_s1a1   +   e2 * v_L1_Tr_s1a1 + e3 * QValues_level1_Elig(1) + e4 * QValues_level1_NoElig(1);
            v_L1_s1a2 =  e1 * v_L1_noTr_s1a2   +   e2 * v_L1_Tr_s1a2 + e3 * QValues_level1_Elig(2) + e4 * QValues_level1_NoElig(2);

            %=== Level 2                                                 

            v_L2_s1a1 =  w2 * QValues_level2(1,1)   +   w1 * v_MB_L2_s1a1 ;
            v_L2_s1a2 =  w2 * QValues_level2(1,2)   +   w1 * v_MB_L2_s1a2 ;
            v_L2_s2a1 =  w2 * QValues_level2(2,1)   +   w1 * v_MB_L2_s2a1 ;
            v_L2_s2a2 =  w2 * QValues_level2(2,2)   +   w1 * v_MB_L2_s2a2 ;

            %############ Adding stay bias
            if      (previous_a1==1)
                v_L1_s1a1 = v_L1_s1a1 + stayBias ;
            elseif  (previous_a1==2)
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

            %############ Summing up the two likelihoods    
            negLogLL = negLogLL_L1 + negLogLL_L2 ;
            

            %##########################################################################
            %####    Summing up the likelikood of all trials of a certain agent    ####
            %##########################################################################    
                                                
            logLL = logLL + negLogLL;
                        
            
            %##########################################################################
            %####                    Updating the agent                            ####
            %##########################################################################    
            %----------------- Updating Q-values of first level -------------------
            for a=1:2
               if a==a1
                    QValues_level1_Elig  (a) = QValues_level1_Elig  (a) + alphaMF_Elig*(r                    -QValues_level1_Elig  (a));
                    QValues_level1_NoElig(a) = QValues_level1_NoElig(a) + alphaMF     *(QValues_level2(s2,a2)-QValues_level1_NoElig(a));
               else
                    QValues_level1_Elig  (a) = QValues_level1_Elig  (a) + driftMF_Elig*(0-QValues_level1_Elig  (a));
                    QValues_level1_NoElig(a) = QValues_level1_NoElig(a) + driftMF     *(0-QValues_level1_NoElig(a));
               end
            end


            for a=1:2
            end

            %----------------- Updating Q-values of second level ------------------
            for s=1:2
                for a=1:2
                   if s==s2 & a==a2
                        QValues_level2(s,a) = QValues_level2(s,a) + alphaMF*(r-QValues_level2(s,a));
                   else
                        QValues_level2(s,a) = QValues_level2(s,a) + driftMF*(0-QValues_level2(s,a));
                   end
                end
            end 
                        
            %----------------- Updating Reward Function ---------------------------
            alphaMBdelta = alphaMB*(r-reward(s3));


            normalizer = 0 ;
            for s=1:4
                if s~=s3
                    normalizer = normalizer + (1-r-reward(s)) ;
                end
            end      

            if normalizer == 0 
                normalizer = 1 ;
            end

            for s=1:4
                if s==s3
                    reward (s)    = reward(s) + alphaMBdelta ; 
                else
                    reward (s)    = reward(s) - alphaMBdelta * ( (1-r-reward(s)) / normalizer )   ;
                end
            end     
            
            
            
            previous_a1 = a1 ;                                    
            previous_r  = r  ;                                    

                                                           
        end
    end
       
    logLL;
    
    
    
    