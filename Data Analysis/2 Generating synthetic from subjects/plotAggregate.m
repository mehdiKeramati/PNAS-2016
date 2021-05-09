function plotAggregate (stayProbs); 
    
    figure('Position', [100, 100, 300, 300]);;
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 25)
    set(0,'DefaultAxesFontWeight', 'normal')

    means = [mean(stayProbs(:,1)); mean(stayProbs(:,2)); mean(stayProbs(:,3));mean(stayProbs(:,4))];
    STDs =  [ std(stayProbs(:,1));  std(stayProbs(:,2));  std(stayProbs(:,3)); std(stayProbs(:,4))];

    bar(means,'FaceColor',[.4 .4 .4],'EdgeColor',[0 0 0],'LineWidth',1.5);


    hold on;
    h=errorbar(means,STDs,'r','color','black','linewidth',3);
    set(h,'linestyle','none');

    axis([-inf,inf,0,1])
    xlabel('previous transition');
    ylabel('stay probability') 
    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);

    
    sss = 0.27 ;
    ttt = 0.17 ;
    for o = 1 : 15
      hold on;
      plot([1-sss,1-ttt],[stayProbs(o,1),stayProbs(o,1)],'k-','LineWidth',2)    ;
      plot([2-sss,2-ttt],[stayProbs(o,2),stayProbs(o,2)],'k-','LineWidth',2)    ;
      plot([3-sss,3-ttt],[stayProbs(o,3),stayProbs(o,3)],'k-','LineWidth',2)    ;
      plot([4-sss,4-ttt],[stayProbs(o,4),stayProbs(o,4)],'k-','LineWidth',2)    ;
    end

