function params =analise0_0 ()    

group = 2 ;




if group==1
    fromSubject = 25 ;
    toSubject = 40 ;
    timeLimit = 2;
    figWidth  = 1480;
    ordered = [2    10     7    13    14     6    12     5     1     8     3     4     9    11    15    16];
else
    fromSubject = 54 ;
    toSubject = 69 ;
    timeLimit = 0.7;
    figWidth  = 1480;
    ordered = [6    13    11     4    10     8    12     3     5     2     9     1     7    15    14    16];

end


subjectsNum     = toSubject - fromSubject + 1 ;


FigHandle = figure('Position', [100, 100, figWidth, 900]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 16)
set(0,'DefaultAxesFontWeight', 'bold')
 
params = zeros(1,subjectsNum);
means = zeros(1,subjectsNum);
medians = zeros(1,subjectsNum);

timeLimits = ones(subjectsNum,1);

for subject = 1 : subjectsNum
    
    subjectSource = ordered (subject);

    M = dlmread([int2str(subjectSource+fromSubject-1),'.txt']);   
 
    MSize = size(M);
    trialsNum = MSize(1,1);
 
    timeLimits(subject)=timeLimit;

    if subject<(subjectsNum+1)/2
        column = 0 ;
    else
        column = 1;
    end
    
    subplot(4, subjectsNum/2, (subjectsNum)/2+ subject + column*(subjectsNum)/2);
    data = M(:,7);

    missedLevel1  = zeros(trialsNum,1);
    missedLevel2  = zeros(trialsNum,1);
    missedLevel3  = zeros(trialsNum,1);
    missedLevel1Num = 0 ; 
    missedLevel2Num = 0 ; 
    missedLevel3Num = 0 ; 
    for i=1:trialsNum
        if (M(i,7)==0)
            missedLevel1(i) = 1;
            missedLevel1Num = missedLevel1Num + 1 ; 
            if i==1
                data(i)=0;
            else
                data(i)=data(i-1);
            end
        elseif (M(i,8)==0) && (M(i,7)>0)
            missedLevel2(i) = 1;
            missedLevel2Num = missedLevel2Num + 1 ; 
        elseif (M(i,9)==0) && (M(i,7)>0) && (M(i,8)>0)
            missedLevel3(i) = 1;            
            missedLevel3Num = missedLevel3Num + 1 ; 
        end
    end
    
    
    xbins = 0:0.1:2;
    hist (data ,xbins,'black')   
    set(get(gca,'child'),'FaceColor','black','EdgeColor','red');
    axis([0,timeLimit+0.2,0,200])
    xlabel('RT (sec)') 
    if (subject==1) || (subject==(subjectsNum/2)+1) 
        ylabel('number of trials') 
    end
    
    
    subplot(4, subjectsNum/2, subject + column*(subjectsNum)/2);
    plot (data,'Color','black')
    hold on;

    for i=1:trialsNum
        if missedLevel1(i)==1
            line([i i],[0 0.3/group],'Color','r');
            hold on;
        elseif missedLevel2(i)==1
            line([i i],[0 0.3/group],'Color','b');
            hold on;
        elseif missedLevel3(i)==1
            line([i i],[0 0.3/group],'Color','g');
            hold on;            
        end
    end
    
    if subject<(subjectsNum/2 + 1)
            yPosition = .815;
            xPosition = 0.0441+subject*.0995 ;
    else
            yPosition = .379;
            xPosition = 0.0441+(subject-subjectsNum/2)*.0995 ;        
    end
    str = sprintf('%d',missedLevel1Num);
    hAnnot(subject) = annotation('textbox', [xPosition yPosition .1 .1],...
        'String', str,...
        'FontName','Arial',...
        'FontWeight','bold',...
        'Color','red',...
        'FontSize',14,...
        'FitBoxToText','off',...
        'EdgeColor','none');
    str = sprintf('%d',missedLevel2Num);
    hAnnot(subject) = annotation('textbox', [xPosition+0.02 yPosition .1 .1],...
        'String', str,...
        'FontName','Arial',...
        'FontWeight','bold',...
        'Color','blue',...
        'FontSize',14,...
        'FitBoxToText','off',...
        'EdgeColor','none');
    str = sprintf('%d',missedLevel3Num);
    hAnnot(subject) = annotation('textbox', [xPosition+0.040 yPosition .1 .1],...
        'String', str,...
        'FontName','Arial',...
        'FontWeight','bold',...
        'Color',[0 0.7 0],...
        'FontSize',14,...
        'FitBoxToText','off',...
        'EdgeColor','none');

    
    axis([-inf,inf,0, timeLimit + (1.0/group)*0.3 - (group-2) * 0.2 ])
    hold on
    plot([0 trialsNum],[timeLimits(subject) timeLimits(subject)],'color','red','linewidth', 2)

    
    xlabel('trial') 
    if (subject==1) || (subject==(subjectsNum/2)+1) 
        ylabel('reaction time (sec)') 
    end
    
    
    
    
  %================== Computing mean and median
    
  sum = 0 ;
  counter = 0 ;
  
  for i=1:trialsNum
    if M(i,7) > 0
        sum = sum + M(i,7) ; 
        counter = counter + 1;        
    end  
  end
  
    
    
    
    means(subject) = sum/counter;
    medians(subject) = median (data);
    
    title(['Subject #',int2str(subject)]);
end

FigHandle = figure('Position', [100, 100, 400, 200]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 15)
set(0,'DefaultAxesFontWeight', 'bold')
plot (means(1:subjectsNum-1),'o-','linewidth', 2)
axis([-inf,inf,0,timeLimit + 0.15])
hold on
plot(timeLimits(1:subjectsNum-1),'o-','color','red','linewidth', 2)
xlabel('subject') 
ylabel('Mean reaction time') 

FigHandle = figure('Position', [100, 100, 400, 200]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 15)
set(0,'DefaultAxesFontWeight', 'bold')
plot (medians(1:subjectsNum-1),'o-','linewidth', 2)
axis([-inf,inf,0,timeLimit + 0.15])
hold on
plot(timeLimits(1:subjectsNum-1),'o-','color','red','linewidth', 2)
xlabel('subject') 
ylabel('reaction time median') 


params = means;
