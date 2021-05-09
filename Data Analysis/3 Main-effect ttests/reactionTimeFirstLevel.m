function analise0_0 ()    

fromSubject = 54 ;
toSubject = 69 ;


subjectsNum     = toSubject - fromSubject + 1 ;


FigHandle = figure('Position', [100, 100, 1800, 900]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultAxesFontWeight', 'bold')


means = zeros(1,subjectsNum);
medians = zeros(1,subjectsNum);

timeLimits = ones(subjectsNum,1);

for subject = 1 : subjectsNum

    M = dlmread([int2str(subject+fromSubject-1),'.txt']);   
 
    MSize = size(M);
    trialsNum = MSize(1,1);
 
    timeLimits(subject)=0.7;

    if subject<(subjectsNum+1)/2
        column = 0 ;
    else
        column = 1;
    end
    
    subplot(4, subjectsNum/2, (subjectsNum)/2+ subject + column*(subjectsNum)/2);
    data = M(:,7);

    missed  = zeros(500,1);
    for i=1:trialsNum
        if data(i)==0
            missed(i) = 1;
            if i==1
                data(i)=0;
            else
                data(i)=data(i-1);
            end
        end
    end
    
    hist (data , 10)
    axis([0,0.9,0,200])
    xlabel('reaction time') 
    if (subject==1) || (subject==10) 
        ylabel('number of trials') 
    end
    
    
    subplot(4, subjectsNum/2, subject + column*(subjectsNum)/2);
    plot (data)
    hold on;

    for i=1:trialsNum
        if missed(i)==1
            line([i i],[0 0.15],'Color','r');
            hold on;
        end
    end
    

    
    axis([-inf,inf,0,0.85])
    hold on
    plot([0 500],[timeLimits(subject) timeLimits(subject)],'color','red','linewidth', 2)

    
    xlabel('trial') 
    if (subject==1) || (subject==10) 
        ylabel('reaction time') 
    end
    
    means(subject) = mean (data);
    medians(subject) = median (data);
    
    title(['Subject #',int2str(subject)]);
end

FigHandle = figure('Position', [100, 100, 400, 200]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 15)
set(0,'DefaultAxesFontWeight', 'bold')
plot (means(1:15),'o-','linewidth', 2)
axis([-inf,inf,0,0.85])
hold on
plot(timeLimits(1:15),'o-','color','red','linewidth', 2)
xlabel('subject') 
ylabel('Mean reaction time') 

FigHandle = figure('Position', [100, 100, 400, 200]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 15)
set(0,'DefaultAxesFontWeight', 'bold')
plot (medians(1:15),'o-','linewidth', 2)
axis([-inf,inf,0,0.85])
hold on
plot(timeLimits(1:15),'o-','color','red','linewidth', 2)
xlabel('subject') 
ylabel('reaction time median') 
