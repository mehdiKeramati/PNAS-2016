function SynPlotAggregate (stayProbs); 
    
    figure('Position', [100, 100, 300, 300]);;
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 25)
    set(0,'DefaultAxesFontWeight', 'normal')

    means = [mean(stayProbs(:,1)); mean(stayProbs(:,2)); mean(stayProbs(:,3));mean(stayProbs(:,4))];
    STDs =  [ std(stayProbs(:,1));  std(stayProbs(:,2));  std(stayProbs(:,3)); std(stayProbs(:,4))];

    bar(means);

    hold on;
    h=errorbar(means,STDs,'r','color','black','linewidth',3);
    set(h,'linestyle','none');

    axis([-inf,inf,0,1])
    xlabel('previous transition');
    ylabel('stay probability') 
    xticklabel = {'CC','CR','RC','RR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);
