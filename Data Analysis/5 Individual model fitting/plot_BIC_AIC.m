group = 2 ;


figure('Position', [100, 400, 470, 300]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 25)
set(0,'DefaultAxesFontWeight', 'normal')

if group==1
    BIC = [389.5872825,	391.0958833,	431.4379297,	445.8660902,	455.8993968];
    AIC = [358.7238172,	364.0903512,	404.4323977,	418.8605581,	428.8938647];
    ylowBIC  = 375;
    yhighBIC = 470;    
    ylowAIC  = 350;
    yhighAIC = 440;    
else
    BIC = [581.3534106,	592.2319817,	606.606544,     634.8474231,	639.6018242];
    AIC = [547.6365458,	565.2264497,	579.6010119,	607.8418911,	612.5962921];
    ylowBIC = 570;
    yhighBIC = 650;    
    ylowAIC = 535;
    yhighAIC = 630;    
end



data = [BIC;AIC];

x=[1,2,3,4,5];



%// generate two axes at same position
ax1 = axes;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');

%// move second axis to the right, remove x-ticks and labels
set(ax2,'YAxisLocation','right')
set(ax2,'XTick',[])

%// Set these three variables as desired
offset = (x(2)-x(1))/5;
width = (x(2)-x(1))/2.5;

bar(ax1,x-offset,BIC,width,'FaceColor',[116/256 047/256 050/256],'EdgeColor',[1 .9 .9],'LineWidth',1.5);


hold on;
bar(ax2,x+offset,AIC,width,'FaceColor',[046/256 020/256 140/256],'EdgeColor',[1 .9 .9],'LineWidth',1.5);


axis(ax1,[0,6,ylowBIC,yhighBIC])
axis(ax2,[0,6,ylowAIC,yhighAIC])


%hold on;
%h=errorbar(means,STDs,'r','color','black','linewidth',3);
%set(h,'linestyle','none');
