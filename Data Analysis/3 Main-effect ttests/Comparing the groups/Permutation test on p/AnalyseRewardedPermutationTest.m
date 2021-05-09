function analyse0_0 ()    

clc
close all

permuationsNum  = 1000  ;
subjectsNum     = 30  ;
trialsNum       = 350 ;


stayProbsR = zeros (subjectsNum, 4 ) ;   % IF REWARDED 
stayProbsN = zeros (subjectsNum, 4 ) ;   % IF NOT REWARDED 
trialNum  = zeros (subjectsNum, 1 ) ;  
totalReward= zeros (subjectsNum,1) ;  


p1Grp1Rew = zeros (permuationsNum,1) ; 
p1Grp2Rew = zeros (permuationsNum,1) ; 
p2Grp1Rew = zeros (permuationsNum,1) ; 
p2Grp2Rew = zeros (permuationsNum,1) ; 
p1Grp1Non = zeros (permuationsNum,1) ; 
p1Grp2Non = zeros (permuationsNum,1) ; 
p2Grp1Non = zeros (permuationsNum,1) ; 
p2Grp2Non = zeros (permuationsNum,1) ; 

reactionTimeThreshold = 0.0;


for subject = 1 : subjectsNum

    M = dlmread([int2str(subject),'.txt']);   
 
    trialNum(subject)    = trialsNum ;    
    
    CCSR = 0 ;   % Counting after a Comomon-Common transition, doing the Same  action, if rewarded
    CCOR = 0 ;   % Counting after a Comomon-Common transition, doing the Other action, if rewarded
    CRSR = 0 ;   % Counting after a Comomon-Rare   transition, doing the Same  action, if rewarded
    CROR = 0 ;   % Counting after a Comomon-Rare   transition, doing the Other action, if rewarded
    RCSR = 0 ;   % Counting after a Rare-Common    transition, doing the Same  action, if rewarded
    RCOR = 0 ;   % Counting after a Rare-Common    transition, doing the Other action, if rewarded
    RRSR = 0 ;   % Counting after a Rare-Rare      transition, doing the Same  action, if rewarded
    RROR = 0 ;   % Counting after a Rare-Rare      transition, doing the Other action, if rewarded

    CCSN = 0 ;   % Counting after a Comomon-Common transition, doing the Same  action, if not rewarded
    CCON = 0 ;   % Counting after a Comomon-Common transition, doing the Other action, if not rewarded
    CRSN = 0 ;   % Counting after a Comomon-Rare   transition, doing the Same  action, if not rewarded
    CRON = 0 ;   % Counting after a Comomon-Rare   transition, doing the Other action, if not rewarded
    RCSN = 0 ;   % Counting after a Rare-Common    transition, doing the Same  action, if not rewarded
    RCON = 0 ;   % Counting after a Rare-Common    transition, doing the Other action, if not rewarded
    RRSN = 0 ;   % Counting after a Rare-Rare      transition, doing the Same  action, if not rewarded
    RRON = 0 ;   % Counting after a Rare-Rare      transition, doing the Other action, if not rewarded


    
    fromTrial       = 2   ;
    toTrial         = trialsNum ;
    
    for trial = fromTrial : toTrial
        if M(trial,7)>reactionTimeThreshold       % if the reaction time was something reasonable
            
            if M(trial-1,17)                            % If Rewarded,     
                if ~M(trial-1,13) && ~M(trial-1,14)         % If Common-Common
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        CCSR = CCSR + 1 ;
                    else                                        % If did the other                    
                        CCOR = CCOR + 1 ;
                    end
                elseif ~M(trial-1,13) && M(trial-1,14)      % If Common-Rare
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        CRSR = CRSR + 1 ;
                    else                                        % If did the other                    
                        CROR = CROR + 1 ;
                    end
                elseif M(trial-1,13) && ~M(trial-1,14)      % If Rare-Common
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        RCSR = RCSR + 1 ;
                    else                                        % If did the other                    
                        RCOR = RCOR + 1 ;
                    end
                elseif M(trial-1,13) && M(trial-1,14)       % If Rare-Rare
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        RRSR = RRSR + 1 ;
                    else                                        % If did the other                    
                        RROR = RROR + 1 ;
                    end
                end

            elseif ~M(trial-1,17)                        % If not Rewarded,
                if ~M(trial-1,13) && ~M(trial-1,14)         % If Common-Common
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        CCSN = CCSN + 1 ;
                    else                                        % If did the other                    
                        CCON = CCON + 1 ;
                    end
                elseif ~M(trial-1,13) && M(trial-1,14)      % If Common-Rare
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        CRSN = CRSN + 1 ;
                    else                                        % If did the other                    
                        CRON = CRON + 1 ;
                    end
                elseif M(trial-1,13) && ~M(trial-1,14)      % If Rare-Common
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        RCSN = RCSN + 1 ;
                    else                                        % If did the other                    
                        RCON = RCON + 1 ;
                    end
                elseif M(trial-1,13) && M(trial-1,14)       % If Rare-Rare
                    if M(trial-1,5) == M(trial,5)               % If did the same
                        RRSN = RRSN + 1 ;
                    else                                        % If did the other                    
                        RRON = RRON + 1 ;
                    end
                end            
            end
        end
    end
   
        
    stayProbsR(subject,1) = CCSR / (CCSR+CCOR);
    stayProbsR(subject,2) = CRSR / (CRSR+CROR);
    stayProbsR(subject,3) = RCSR / (RCSR+RCOR);
    stayProbsR(subject,4) = RRSR / (RRSR+RROR);

    if RRSR+RROR==0
        stayProbsR(subject,4) = 0 ;
    end
    
    stayProbsN(subject,1) = CCSN / (CCSN+CCON);
    stayProbsN(subject,2) = CRSN / (CRSN+CRON);
    stayProbsN(subject,3) = RCSN / (RCSN+RCON);
    stayProbsN(subject,4) = RRSN / (RRSN+RRON);
    
end



stayProbsRGrp1 = zeros (subjectsNum/2, 4 ) ;   % IF REWARDED 
stayProbsNGrp1 = zeros (subjectsNum/2, 4 ) ;   % IF NOT REWARDED 
stayProbsRGrp2 = zeros (subjectsNum/2, 4 ) ;   % IF REWARDED 
stayProbsNGrp2 = zeros (subjectsNum/2, 4 ) ;   % IF NOT REWARDED 


for permuations = 1 : permuationsNum
    PermSubjects =  zeros (subjectsNum/2 , 1);
    for subject = 1 : subjectsNum/2
        PermSubjects (subject) = randi(2)-1 ;
    end
    
%    PermSubjects =  zeros (subjectsNum/2 , 1);
    
    
    counterGrp1 = 1 ;
    counterGrp2 = 1 ;
    for subject = 1 : subjectsNum/2
        if PermSubjects(subject) == 1            
            stayProbsRGrp1 (counterGrp1,:) = stayProbsR(subject,:);
            stayProbsNGrp1 (counterGrp1,:) = stayProbsN(subject,:);
            counterGrp1 = counterGrp1 + 1 ;
        else            
            stayProbsRGrp2 (counterGrp2,:) = stayProbsR(subject,:);
            stayProbsNGrp2 (counterGrp2,:) = stayProbsN(subject,:);
            counterGrp2 = counterGrp2 + 1 ;
        end        
    end
    for subject = 16 : subjectsNum
        if PermSubjects(subject-15) == 0            
            stayProbsRGrp1 (counterGrp1,:) = stayProbsR(subject,:);
            stayProbsNGrp1 (counterGrp1,:) = stayProbsN(subject,:);
            counterGrp1 = counterGrp1 + 1 ;
        else            
            stayProbsRGrp2 (counterGrp2,:) = stayProbsR(subject,:);
            stayProbsNGrp2 (counterGrp2,:) = stayProbsN(subject,:);
            counterGrp2 = counterGrp2 + 1 ;
        end        
    end
    
    
    %----- After Rewarded Trials:
    %------------ Pruning effect:
    [p1,h,stats] = signrank(stayProbsRGrp1(:,1)+stayProbsRGrp1(:,2) , stayProbsRGrp1(:,3)+stayProbsRGrp1(:,4));
    [p2,h,stats] = signrank(stayProbsRGrp2(:,1)+stayProbsRGrp2(:,2) , stayProbsRGrp2(:,3)+stayProbsRGrp2(:,4));
    p1Grp1Rew(permuations) = p1;
    p1Grp2Rew(permuations) = p2;
    %------------ MB effect
    [p1,h,stats] = signrank(stayProbsRGrp1(:,1)+stayProbsRGrp1(:,4) , stayProbsRGrp1(:,2)+stayProbsRGrp1(:,3));
    [p2,h,stats] = signrank(stayProbsRGrp2(:,1)+stayProbsRGrp2(:,4) , stayProbsRGrp2(:,2)+stayProbsRGrp2(:,3));
    p2Grp1Rew(permuations) = p1;
    p2Grp2Rew(permuations) = p2;

    %----- After non-rewarded Trials:
    %------------ Pruning effect:
    [p1,h,stats] = signrank(stayProbsNGrp1(:,1)+stayProbsNGrp1(:,2) , stayProbsNGrp1(:,3)+stayProbsNGrp1(:,4));
    [p2,h,stats] = signrank(stayProbsNGrp2(:,1)+stayProbsNGrp2(:,2) , stayProbsNGrp2(:,3)+stayProbsNGrp2(:,4));
    p1Grp1Non(permuations) = p1;
    p1Grp2Non(permuations) = p2;
    %------------ MB effect
    [p1,h,stats] = signrank(stayProbsNGrp1(:,1)+stayProbsNGrp1(:,4) , stayProbsNGrp1(:,2)+stayProbsNGrp1(:,3));
    [p2,h,stats] = signrank(stayProbsNGrp2(:,1)+stayProbsNGrp2(:,4) , stayProbsNGrp2(:,2)+stayProbsNGrp2(:,3));
    p2Grp1Non(permuations) = p1;
    p2Grp2Non(permuations) = p2;
    
end



disp('----- Pruning:');
disp('---------- After rewarded trials:');
p1 = p1Grp1Rew-p1Grp2Rew ;
sum( p1>0.0724)/permuationsNum
disp('---------- After non-rewarded trials:');
p1 = p1Grp1Non-p1Grp2Non ;
sum( p1>-0.0011)/permuationsNum


disp('----- MB:');
disp('---------- After rewarded trials:');
p2 = p2Grp1Rew-p2Grp2Rew ;
sum( p2>0.00012207)/permuationsNum
disp('---------- After non-rewarded trials:');
p2 = p2Grp1Non-p2Grp2Non ;
sum( p2>0.0247)/permuationsNum

