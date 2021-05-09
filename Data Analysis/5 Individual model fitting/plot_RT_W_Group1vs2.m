%---------------------------------------------------------------------
%----------------------- Drop Charts (for W) 
%---------------------------------------------------------------------

FigHandle = figure('Position', [100, 100, 290, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')

group1Num = 15;
group2Num = 15;

grp1= [0.027465793,0.012917164,0.7440703,0.179461906,0.117144498,0.006315057,0,0.069905345,0.601203985,0.005180357,0.218543777,0,0,0,0.460556444];
grp2= [0.673499512,0.672469894,0.349759293,0.106892374,0.333860904,0.592221132,0.820442758,0.193873315,0.156104199,0.866911863,0.996867238,0.196189172,0,0.938143405,0.435009202];
    
for subject = 1 : group1Num
    plot([1],[grp1(subject)] ,'o', 'linewidth', 2,'color','red','markerfacecolor','red','markeredgecolor','black','markersize',10);  
    hold on
end

for subject = 1 : group2Num
    plot([2],[grp2(subject)] ,'o', 'linewidth', 2,'color','red','markerfacecolor','blue','markeredgecolor','black','markersize',10);  
    hold on
end

xticklabel = {'Group 1','Group 2'};
set(gca, 'XTick', 1:2, 'XTickLabel', xticklabel);


axis([0.5,2.5,-0.2 ,1.2])
ylabel('Pruning weight');
title('Main effect of time limit');

%---------------------------------------------------------------------
%----------------------- normal dist (for W) 
%---------------------------------------------------------------------FigHandle = figure('Position', [100, 100, 800, 200]);
FigHandle = figure('Position', [100, 100, 500, 100]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')


mean1 = mean (grp1);
mean2 = mean (grp2);
std1  = std  (grp1);
std2  = std  (grp2);

X=[-0.7:0.01:1.3];
YYY = normpdf(X,mean1,std1);
plot (X,YYY,'r','linewidth', 2);
hold on
YYY = normpdf(X,mean2,std2);
plot (X,YYY,'b','linewidth', 2);

axis([-inf ,inf,-0.2 ,2])



%---------------------------------------------------------------------
%----------------------- Drop Charts (for RT) 
%---------------------------------------------------------------------

FigHandle = figure('Position', [100, 100, 290, 400]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')

group1Num = 15;
group2Num = 15;

grp1= [0.662057991,0.743304302,0.697817673,0.549207071,0.66317907,0.619657606,0.469574731,0.656931337,0.708758249,0.689965343,0.648472571,0.807217335,0.596228629,0.494091066,0.56093212];
grp2= [0.441363464,0.45312218,0.484340343,0.360813351,0.453052557,0.396973318,0.438526113,0.408126784,0.452062301,0.446543933,0.434124301,0.356120997,0.469685263,0.43155859,0.391047099];
    
for subject = 1 : group1Num
    plot([1],[grp1(subject)] ,'o', 'linewidth', 2,'color','red','markerfacecolor','red','markeredgecolor','black','markersize',10);  
    hold on
end

for subject = 1 : group2Num
    plot([2],[grp2(subject)] ,'o', 'linewidth', 2,'color','red','markerfacecolor','blue','markeredgecolor','black','markersize',10);  
    hold on
end

xticklabel = {'Group 1','Group 2'};
set(gca, 'XTick', 1:2, 'XTickLabel', xticklabel);


axis([0.5,2.5,0.25 ,0.9])
ylabel('Mean RT');
title('Main effect of time limit');



%---------------------------------------------------------------------
%----------------------- normal dist (for RT) 
%---------------------------------------------------------------------FigHandle = figure('Position', [100, 100, 800, 200]);
FigHandle = figure('Position', [100, 100, 500, 100]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')


mean1 = mean (grp1);
mean2 = mean (grp2);
std1  = std  (grp1);
std2  = std  (grp2);

X=[0.2:0.01:1];
YYY = normpdf(X,mean1,std1);
plot (X,YYY,'r','linewidth', 2);
hold on
YYY = normpdf(X,mean2,std2);
plot (X,YYY,'b','linewidth', 2);

axis([0.2,1,-1 ,13])




