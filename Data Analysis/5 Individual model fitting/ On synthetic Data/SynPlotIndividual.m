function [CC_Rewarded,CR_Rewarded,RC_Rewarded,RR_Rewarded,...
          CC_noReward,CR_noReward,RC_noReward,RR_noReward] = SynPlotIndividual (M,plot)    

subjectsNum = 1 ; 

if strcmp(plot,'plot')
    figure('Position', [100, 100, 600, 300]);
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 12)
    set(0,'DefaultAxesFontWeight', 'bold')
end


stayProbs = zeros (subjectsNum, 4 ) ;

MSize = size(M);
trialsNum = MSize(1,2);

%----------------------- Accumulated Rewards

X = zeros( trialsNum , 1);
Y = zeros( trialsNum , 1);
for i = 1 : trialsNum
    X(i) = i ;
    Y(i) = M(i).reward ;
end
for i = 2 : trialsNum
    Y(i) = Y(i) + Y(i-1) ;
end

if strcmp(plot,'plot')
    subplot(1, 2, 1);
    plot(X,Y,'b',X, X / 4,'r', 'linewidth', 2);
    axis([-inf,inf,-inf,inf])
    xlabel('trial');
    ylabel('Accumulated reward') 
end

%----------------------- Bar charts for individual subjects

CCS = 0 ;   % Counting after a Comomon-Common transition, doing the Same  action
CCO = 0 ;   % Counting after a Comomon-Common transition, doing the Other action
CRS = 0 ;   % Counting after a Comomon-Rare   transition, doing the Same  action
CRO = 0 ;   % Counting after a Comomon-Rare   transition, doing the Other action
RCS = 0 ;   % Counting after a Rare-Common    transition, doing the Same  action
RCO = 0 ;   % Counting after a Rare-Common    transition, doing the Other action
RRS = 0 ;   % Counting after a Rare-Rare      transition, doing the Same  action
RRO = 0 ;   % Counting after a Rare-Rare      transition, doing the Other action

CCS_noR = 0 ;   % Counting after a Comomon-Common transition, doing the Same  action
CCO_noR = 0 ;   % Counting after a Comomon-Common transition, doing the Other action
CRS_noR = 0 ;   % Counting after a Comomon-Rare   transition, doing the Same  action
CRO_noR = 0 ;   % Counting after a Comomon-Rare   transition, doing the Other action
RCS_noR = 0 ;   % Counting after a Rare-Common    transition, doing the Same  action
RCO_noR = 0 ;   % Counting after a Rare-Common    transition, doing the Other action
RRS_noR = 0 ;   % Counting after a Rare-Rare      transition, doing the Same  action
RRO_noR = 0 ;   % Counting after a Rare-Rare      transition, doing the Other action


for trial = 2 : trialsNum
    if M(trial-1).reward                        % If Rewarded,     
        if ~M(trial-1).firstLevelTransitionType && ~M(trial-1).secondLevelTransitionType         % If Common-Common
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                CCS = CCS + 1 ;
            else                                        % If did the other                    
                CCO = CCO + 1 ;
            end
        elseif ~M(trial-1).firstLevelTransitionType && M(trial-1).secondLevelTransitionType      % If Common-Rare
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                CRS = CRS + 1 ;
            else                                        % If did the other                    
                CRO = CRO + 1 ;
            end
        elseif M(trial-1).firstLevelTransitionType && ~M(trial-1).secondLevelTransitionType      % If Rare-Common
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                RCS = RCS + 1 ;
            else                                        % If did the other                    
                RCO = RCO + 1 ;
            end
        elseif M(trial-1).firstLevelTransitionType && M(trial-1).secondLevelTransitionType       % If Rare-Rare
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                RRS = RRS + 1 ;
            else                                        % If did the other                    
                RRO = RRO + 1 ;
            end
        end            
    
    elseif ~M(trial-1).reward                        % If Not Rewarded,     
        if ~M(trial-1).firstLevelTransitionType && ~M(trial-1).secondLevelTransitionType         % If Common-Common
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                CCS_noR = CCS_noR + 1 ;
            else                                        % If did the other                    
                CCO_noR = CCO_noR + 1 ;
            end
        elseif ~M(trial-1).firstLevelTransitionType && M(trial-1).secondLevelTransitionType      % If Common-Rare
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                CRS_noR = CRS_noR + 1 ;
            else                                        % If did the other                    
                CRO_noR = CRO_noR + 1 ;
            end
        elseif M(trial-1).firstLevelTransitionType && ~M(trial-1).secondLevelTransitionType      % If Rare-Common
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                RCS_noR = RCS_noR + 1 ;
            else                                        % If did the other                    
                RCO_noR = RCO_noR + 1 ;
            end
        elseif M(trial-1).firstLevelTransitionType && M(trial-1).secondLevelTransitionType       % If Rare-Rare
            if M(trial-1).firstLevelAction == M(trial).firstLevelAction               % If did the same
                RRS_noR = RRS_noR + 1 ;
            else                                        % If did the other                    
                RRO_noR = RRO_noR + 1 ;
            end
        end            
    end
    
    
end

%-------------------------- Plot rewarded trials
stayProbs(1) = CCS / (CCS+CCO);
stayProbs(2) = CRS / (CRS+CRO);
stayProbs(3) = RCS / (RCS+RCO);
stayProbs(4) = RRS / (RRS+RRO);

if strcmp(plot,'plot')
    subplot(1, 2, 2);
    bar( stayProbs (:) );
    axis([-inf,inf,0,1])
    xlabel('previous transition');
    ylabel('stay probability') 

    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);
end


CC_Rewarded = stayProbs(1) ;
CR_Rewarded = stayProbs(2) ;
RC_Rewarded = stayProbs(3) ;
RR_Rewarded = stayProbs(4) ;



%-------------------------- Plot non-rewarded trials
stayProbs(1) = CCS_noR / (CCS_noR+CCO_noR);
stayProbs(2) = CRS_noR / (CRS_noR+CRO_noR);
stayProbs(3) = RCS_noR / (RCS_noR+RCO_noR);
stayProbs(4) = RRS_noR / (RRS_noR+RRO_noR);

if strcmp(plot,'plot')
    subplot(1, 2, 2);
    bar( stayProbs (:) );
    axis([-inf,inf,0,1])
    xlabel('previous transition');
    ylabel('stay probability') 

    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);
end


CC_noReward = stayProbs(1) ;
CR_noReward = stayProbs(2) ;
RC_noReward = stayProbs(3) ;
RR_noReward = stayProbs(4) ;
