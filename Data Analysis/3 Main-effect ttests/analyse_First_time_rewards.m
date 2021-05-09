function analise0_0 ()    

subjectsNum     = 8  ;


FigHandle = figure('Position', [100, 100, 1500, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultAxesFontWeight', 'bold')

stayProbsR = zeros (subjectsNum, 4 ) ;   % IF REWARDED 
stayProbsN = zeros (subjectsNum, 4 ) ;   % IF NOR REWARDED 


for subject = 1 : subjectsNum

    M = dlmread([int2str(subject),'.txt']);   
 
    MSize = size(M);
    trialsNum = MSize(1,1);
 
    %----------------------- Computing Accumulated Rewards
    subplot(2, subjectsNum, subject);

    X = zeros( trialsNum , 1);
    for i = 1 : trialsNum
        X(i) = i ;
    end
    
    plot(X,M(:,18),'b',X, X / 4,'r', 'linewidth', 2);
    
    axis([-inf,inf,-inf,inf])
    xlabel('trial');
    if subject==1 
        ylabel('Accumulated reward') 
    end
    title(['Subject #',int2str(subject)]);

    %----------------------- Bar charts for individual subjects
    
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

    
    fromTrial       = 3   ;
    toTrial         = trialsNum ;
    
        
    for trial = fromTrial : toTrial
        if M(trial-1,17) && M(trial-1,16)~= M(trial-2,16) % If Rewarded, and reward position was just changed    
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
   
    
    ['CC:',int2str(CCSR),'/',int2str(CCSR+CCOR),'   CR:',int2str(CRSR),'/',int2str(CRSR+CROR),'   RC:',int2str(RCSR),'/',int2str(RCSR+RCOR),'   RR:',int2str(RRSR),'/',int2str(RRSR+RROR)]
    
    stayProbsR(subject,1) = CCSR / (CCSR+CCOR);
    stayProbsR(subject,2) = CRSR / (CRSR+CROR);
    stayProbsR(subject,3) = RCSR / (RCSR+RCOR);
    stayProbsR(subject,4) = RRSR / (RRSR+RROR);
    
    stayProbsN(subject,1) = CCSN / (CCSN+CCON);
    stayProbsN(subject,2) = CRSN / (CRSN+CRON);
    stayProbsN(subject,3) = RCSN / (RCSN+RCON);
    stayProbsN(subject,4) = RRSN / (RRSN+RRON);
    
    subplot(2, subjectsNum, subjectsNum + subject);
    bar( stayProbsR (subject,:) );
        
    axis([-inf,inf,0,1])
    xlabel('previous transition');
    if subject==1 
        ylabel('stay probability') 
    end

    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);
                
end


%----------------------- Bar charts for the aggregated data

FigHandle = figure; %('Position', [100, 100, 150, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultAxesFontWeight', 'bold')

means = [mean(stayProbsR(:,1)); mean(stayProbsR(:,2)); mean(stayProbsR(:,3));mean(stayProbsR(:,4))];
STDs =  [ std(stayProbsR(:,1));  std(stayProbsR(:,2));  std(stayProbsR(:,3)); std(stayProbsR(:,4))];

bar(means);

hold on;
h=errorbar(means,STDs,'r','color','black','linewidth',3);
set(h,'linestyle','none');

axis([-inf,inf,0,1])
xlabel('previous transition');
ylabel('stay probability') 
xticklabel = {'CC','CR','RC','RR'};    
set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);


%---------------------------------------------------------------------
%----------------------- T-tests
%---------------------------------------------------------------------

%----------------------- See if there is a main effect of the first  action being common vs. rare: (transfer mechanism)
%----------------------- (CC+CR) - (RC+RR) > 0

[h,p,ci,stats] = ttest2( stayProbsR(:,1)+stayProbsR(:,2) , stayProbsR(:,3)+stayProbsR(:,4) );
p 

%----------------------- See if there is a main effect of both actions being the same type: (no-transfer mechanism)
%----------------------- use t-test to check if (CC+RR) - (CR+RC) > 0

[h,p,ci,stats] = ttest2( stayProbsR(:,1)+stayProbsR(:,4) , stayProbsR(:,2)+stayProbsR(:,3) );
p 

%---------------------------------------------------------------------
%----------------------- For non-rewarded trials
%---------------------------------------------------------------------

%{

figure('Position', [100, 100, 1500, 200]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultAxesFontWeight', 'bold')

for subject = 1 : subjectsNum

    subplot(1, subjectsNum, subject);
    bar( stayProbsN (subject,:) );
        
    axis([-inf,inf,0,1])
    xlabel('previous transition');
    if subject==1 
        ylabel('stay probability') 
    end

    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);

end    




FigHandle = figure; %('Position', [100, 100, 150, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultAxesFontWeight', 'bold')

means = [mean(stayProbsN(:,1)); mean(stayProbsN(:,2)); mean(stayProbsN(:,3));mean(stayProbsN(:,4))];
STDs =  [ std(stayProbsN(:,1));  std(stayProbsN(:,2));  std(stayProbsN(:,3)); std(stayProbsN(:,4))];

bar(means);

hold on;
h=errorbar(means,STDs,'r','color','black','linewidth',3);
set(h,'linestyle','none');

axis([-inf,inf,0,1])
xlabel('previous transition');
ylabel('stay probability') 
xticklabel = {'CC','CR','RC','RR'};    
set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);

%}



% 1     records.trial                 = 0;       % trial number
% 2     records.firstState            = 0;       % always 0
% 3     records.secondState           = 0;       % 1 or 2
% 4     records.thirdState            = 0;       % 1, 2, 3, or 4
% 5     records.firstAction           = 0;       % 0 for left, 1 for right 
% 6     records.secondAction          = 0;       % 0 for left, 1 for right 
% 7     records.firstReactionTime     = 0;       % The reaction time for the first  action
% 8     records.secondReactionTime    = 0;       % The reaction time for the second action
% 9     records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
% 10    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
% 11    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
% 12    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
% 13    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
% 14    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
% 15    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
% 16    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
% 17    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
% 18    records.totalReward           = 0;       % total reward obtained so far.
    