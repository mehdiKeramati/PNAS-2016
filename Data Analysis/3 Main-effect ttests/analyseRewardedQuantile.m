function analyse0_0 ()    
close all;

group = 2 ;
quantileNumber = 3;


quantsNum = 3 ;
subjectsNum     = 18  ;



if group==1
    FirstSubjectNum = 25 ;
    fromSubject     = 1        ;
    toSubject       = 15        ;
    rewardMax       = 140 ;
else
    FirstSubjectNum = 54 ;
    fromSubject     = 1        ;
    toSubject       = 15        ;
    rewardMax       = 170 ;
end

%Restrict statistical analysis to:
reactionTimeThreshold = 0.0
criteria        = 000/500   ;
criteriaUp      = 500/500   ;

fromSubject     = 1        ;
toSubject       = 15        ;


FigHandle = figure('Position', [100, 100, 1500, 800]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultAxesFontWeight', 'bold')

stayProbsR = zeros (subjectsNum, 4 ) ;   % IF REWARDED 
stayProbsN = zeros (subjectsNum, 4 ) ;   % IF NOT REWARDED 
trialNum  = zeros (subjectsNum, 1 ) ;  
totalReward= zeros (subjectsNum,1) ;  


for subject = 1 : subjectsNum

    M = dlmread([int2str(subject+FirstSubjectNum-1),'.txt']);   
 
    MSize = size(M);
    trialsNum = MSize(1,1);
    
    trialNum(subject)    = trialsNum ;
    totalReward(subject)= M(trialsNum,18);  
    
    %----------------------- Computing Accumulated Rewards
    if subject<(subjectsNum+1)/2
        column = 0 ;
    else
        column = 1;
    end
    
    subplot(4, subjectsNum/2,  subject + column*(subjectsNum)/2);

    X = zeros( trialsNum , 1);
    chanceLevelReward= zeros( trialsNum , 1);
    X(1) = 1 ;
    if M(1,17)
        chanceLevelReward(1) = 0.25 ;
    else
        chanceLevelReward(1) = 0 ;
    end
    for i = 2 : trialsNum
        X(i) = X(i-1)+1 ;
        if (M(i,7)==0) || (M(i,8)==0) || (M(i,9)==0)
            chanceLevelReward(i) = chanceLevelReward(i-1)  ; 
        else
            chanceLevelReward(i) = chanceLevelReward(i-1)+ 0.25 ; 
        end
    end
    
    plot(X,M(:,18),'b',X, chanceLevelReward ,'r', 'linewidth', 2);
   
    if ((totalReward(subject)/trialNum(subject)) > criteria) && ((totalReward(subject)/trialNum(subject)) < criteriaUp)
        if (subject>=fromSubject) && (subject<=toSubject)
%            set(gca,'Color',[0.8 0.8 1]);    
        end
    end
    
    axis([-inf,inf,0,rewardMax])
    xlabel('trial');
    if (subject==1) || (subject==((subjectsNum/2)+1)) 
        ylabel('total reward') 
    end
    title(['Subject #',int2str(subject)]);
    
    %----------------------- Bar charts for individual subjects
    
    
    fromTrial       = 2   ;
    toTrial         = trialsNum ;    
    

    
    % Define the border of quantiles
    quants = zeros(quantsNum+1,1);

    quants1 = quantile ( M(:,7) , quantsNum-1 );
    for quantCounter = 1: quantsNum-1
        quants(quantCounter+1) = quants1 (quantCounter);
    end
    quants(quantsNum+1)=2;

    if quantsNum==2
       quants(2) = median (M(:,7));
    end
    

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



    for trial = fromTrial : toTrial

        if ((M(trial,7)>quants(quantileNumber)) && (M(trial,7)<quants(quantileNumber+1)))

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
    end
        
                  
    
    ['Subject #',int2str(subject),' --> Rew:',int2str(totalReward(subject)),'  CC:',int2str(CCSR),'/',int2str(CCSR+CCOR),'   CR:',int2str(CRSR),'/',int2str(CRSR+CROR),'   RC:',int2str(RCSR),'/',int2str(RCSR+RCOR),'   RR:',int2str(RRSR),'/',int2str(RRSR+RROR)]
    
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
    
    if subject<(subjectsNum+1)/2
        column = 0 ;
    else
        column = 1;
    end
    
    subplot(4, subjectsNum/2, subject + column*(subjectsNum)/2 + subjectsNum/2 );
    bar( stayProbsR (subject,:) );
    if ((totalReward(subject)/trialNum(subject)) > criteria)  && ((totalReward(subject)/trialNum(subject)) < criteriaUp)
        if (subject>=fromSubject) && (subject<=toSubject)
%            set(gca,'Color',[0.8 0.8 1]);    
        end
    end
        
    axis([-inf,inf,0,1])
    xlabel('previous transition');
    if (subject==1) || (subject==((subjectsNum/2)+1)) 
        ylabel('stay probability') 
    end

    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);
                
end

%----------------------- Extract good subjects

%----- Count goods

goodsNum = 0 ;

for subject = 1 : subjectsNum
    if ((totalReward(subject)/trialNum(subject)) > criteria)  && ((totalReward(subject)/trialNum(subject)) < criteriaUp)
        if (subject>=fromSubject) && (subject<=toSubject)
            goodsNum = goodsNum+1;
        end
     end
end


%----- Extract them
stayProbsRGoods = zeros (goodsNum, 4 ) ;   % IF REWARDED 

goodCounter = 0 ;
for subject = 1 : subjectsNum
    if ((totalReward(subject)/trialNum(subject)) > criteria) && ((totalReward(subject)/trialNum(subject)) < criteriaUp)
        if (subject>=fromSubject) && (subject<=toSubject)
            goodCounter = goodCounter+1;
            stayProbsRGoods(goodCounter,:) = stayProbsR(subject,:);
        end
    end
end

%----------------------- Bar charts for the aggregated data

FigHandle = figure; %('Position', [100, 100, 150, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')

means = [mean(stayProbsRGoods(:,1)); mean(stayProbsRGoods(:,2)); mean(stayProbsRGoods(:,3)); mean(stayProbsRGoods(:,4))];
STDs =  [ std(stayProbsRGoods(:,1));  std(stayProbsRGoods(:,2));  std(stayProbsRGoods(:,3)); std(stayProbsRGoods(:,4))];

bar(means);

hold on;
h=errorbar(means,STDs,'r','color','black','linewidth',3);
set(h,'linestyle','none');

axis([-inf,inf,0,1])
xlabel('previous transition');
ylabel('stay probability') 
xticklabel = {'CC','CR','RC','RR'};    
set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);


%----------------------- Lines charts for the aggregated all subjects

FigHandle = figure; %('Position', [100, 100, 150, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')


for subject = 1 : goodsNum
    plot([1,2,3,4],[stayProbsRGoods(subject,1),stayProbsRGoods(subject,2),stayProbsRGoods(subject,3),stayProbsRGoods(subject,4)] ,'-o', 'linewidth', 1,'color','red','markerfacecolor','black','markeredgecolor','black','markersize',15);  
    hold on
end

axis([0.5,4.5,-0.1,1.1])
xlabel('previous transition');
ylabel('stay probability') 
xticklabel = {'CC','CR','RC','RR'};    
set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);



%---------------------------------------------------------------------
%----------------------- T-tests
%---------------------------------------------------------------------

%----------------------- See if there is a main effect of the first  action being common vs. rare: (transfer mechanism)
%----------------------- (CC+CR) - (RC+RR) > 0
disp('---------------------------------------------')

[h,p,ci,stats] = ttest2( stayProbsRGoods(:,1)+stayProbsRGoods(:,2) , stayProbsRGoods(:,3)+stayProbsRGoods(:,4) , 'Tail','right');
sprintf('For (CC+CR) - (RC+RR) > 0 :        p-value = %.6f',p)
disp(transpose(stayProbsRGoods(:,1)+stayProbsRGoods(:,2) - stayProbsRGoods(:,3)-stayProbsRGoods(:,4)))
disp('---------------------------------------------')

meanD = mean(stayProbsRGoods(:,1)+stayProbsRGoods(:,2) - stayProbsRGoods(:,3)-stayProbsRGoods(:,4));
stdD = std(stayProbsRGoods(:,1)+stayProbsRGoods(:,2) - stayProbsRGoods(:,3)-stayProbsRGoods(:,4));

FigHandle = figure('Position', [100, 100, 800, 200]);


X=[-0.7:0.01:1.3];
YYY = normpdf(X,meanD,stdD);
plot (X,YYY);
hold on

y=ones(goodsNum,1);
%bar(stayProbsRGoods(:,1)+stayProbsRGoods(:,2) - stayProbsRGoods(:,3)-stayProbsRGoods(:,4),y,'linewidth',2);

axis([-0.7,1.3,0,4])

%----------------------- See if there is a main effect of both actions being the same type: (no-transfer mechanism)
%----------------------- use t-test to check if (CC+RR) - (CR+RC) > 0

[h,p,ci,stats] = ttest2( stayProbsRGoods(:,1)+stayProbsRGoods(:,4) , stayProbsRGoods(:,2)+stayProbsRGoods(:,3) , 'Tail','right');
sprintf('For (CC+RR) - (CR+RC) > 0 :        p-value = %.6f',p)
disp(transpose(stayProbsRGoods(:,1)+stayProbsRGoods(:,4) - stayProbsRGoods(:,2)-stayProbsRGoods(:,3)))
disp('---------------------------------------------')

[h,p,ci,stats] = ttest2( stayProbsRGoods(:,1) , stayProbsRGoods(:,2) , 'Tail','right');
sprintf('For CC - CR > 0           :        p-value = %.6f',p)
disp(transpose(stayProbsRGoods(:,1) - stayProbsRGoods(:,2)))
disp('---------------------------------------------')

[h,p,ci,stats] = ttest2( stayProbsRGoods(:,1) , stayProbsRGoods(:,3) , 'Tail','right');
sprintf('For CC - RC > 0           :        p-value = %.6f',p) 
disp(transpose(stayProbsRGoods(:,1) - stayProbsRGoods(:,3)))
disp('---------------------------------------------')

[h,p,ci,stats] = ttest2( stayProbsRGoods(:,2) , stayProbsRGoods(:,3) , 'Tail','right');
sprintf('For CR - RC > 0           :        p-value = %.6f',p)
disp(transpose(stayProbsRGoods(:,2) - stayProbsRGoods(:,3)))

%---------------------------------------------------------------------
%----------------------- Drop Charts (for main effect of Pruning) 
%---------------------------------------------------------------------

FigHandle = figure('Position', [100, 100, 290, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')

for subject = 1 : goodsNum
    CC_CR = stayProbsRGoods(subject,1)+stayProbsRGoods(subject,2);
    RC_RR = stayProbsRGoods(subject,3)+stayProbsRGoods(subject,4);
    plot([1,2],[CC_CR,RC_RR] ,'-o', 'linewidth', 1,'color','red','markerfacecolor','black','markeredgecolor','black','markersize',10);  
    hold on
end

xticklabel = {'CC+CR','RC+RR'};
set(gca, 'XTick', 1:2, 'XTickLabel', xticklabel);


axis([0.5,2.5,-0.1,2.1])
xlabel('Previous transition');
ylabel('Stay propability') 
title('Main effect of Pruning');


%---------------------------------------------------------------------
%----------------------- Drop Charts (for main effect of Model-based) 
%---------------------------------------------------------------------

FigHandle = figure('Position', [100, 100, 290, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')

for subject = 1 : goodsNum
    CC_RR = stayProbsRGoods(subject,1)+stayProbsRGoods(subject,4);
    CR_RC = stayProbsRGoods(subject,2)+stayProbsRGoods(subject,3);
    plot([1,2],[CC_RR,CR_RC] ,'-o', 'linewidth', 1,'color','red','markerfacecolor','black','markeredgecolor','black','markersize',10);  
    hold on
end

xticklabel = {'CC+RR','CR+RC'};
set(gca, 'XTick', 1:2, 'XTickLabel', xticklabel);


axis([0.5,2.5,-0.1,2.1])
xlabel('Previous transition');
ylabel('Stay propability') 
title('Main effect of MB');



score  = zeros (subjectsNum, 1 ) ;  

for subject = 1 : subjectsNum
    score(subject) = totalReward(subject)/trialNum(subject); 
end
score

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
    