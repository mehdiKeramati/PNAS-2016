
permutationNumber = 1 ;


%-------------------------- raw Data

alphaMF_LL1         = [0.018128645,0.484692816,1,0.902317748,1,0.040716967,0.040220711,1,0.787710893,0.392383109,0.343302586,0.85337534,0.980262693,1,1];
alphaMF_LL1_LL2     = [0.277705636,0.578276082,1,0.902275984,0.940232856,1,0.072119814,1,0.949851395,0.420043476,0.846429376,0.891809138,0.970211639,1,1];
W_level1_LL1        = [0.963288897,0.765132923,0.283697416,0.151857066,0.248869572,0.444729638,0.732053539,0.321353078,0.385618413,0.52441907,0.307030742,0.207026382,0.110713707,1,0.709712519];
W_level1_LL1_LL2    = [0.670317265,0.717499168,0.273339792,0.151864822,0.277835383,0.024225993,0.931302071,0.460720185,0.418851922,0.448053091,0,0.273382218,0.111728945,1,0.708057338];
W_level2_LL1_LL2    = [0.137909697,0.125061937,0.594454579,1,0.45529834,0.284026788,0.092292888,0.254950919,0.71782474,0.016843216,0.356344162,0.808731784,0.636209707,0.034259831,0];
W_level2_LL2        = [0.172338476,0.161309501,0.611543867,0.350383876,0.381528199,0.282714816,0.035410678,0.019705442,0.719293426,0.102506376,0.392506129,0.678158426,0.60312096];


%-------------------------- data sets selected from raw data, to be tested
X1=W_level2_LL1_LL2;
X2=W_level1_LL1;


%-------------------------- computing R2
R=corr2(X1,X2);
R^2


%-------------------------- test
Size = size(X1);

counter = 0 ;
newX2 = zeros(1,Size(1,2));


for i = 1: permutationNumber

    p = randperm(Size(1,2));
    
    for j=1:Size(1,2)
        newX2(1,j) =   X2(p(j));   
    end
    
    newR = corr2(X1,newX2);
    
    if R>0
        if newR > R
            counter = counter + 1 ;
        end
    else
        if newR < R
            counter = counter + 1 ;
        end
    end
end


p_value = (counter*1.0)/permutationNumber


%-------------------------- Plotting
FigHandle = figure('Position', [100, 100, 400, 290]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultAxesFontWeight', 'bold')

Ones = ones(1,Size(1,2));
X2 = Ones-X2;

plot(X1,X2 ,'o', 'linewidth', 2,'color','red','markerfacecolor','blue','markeredgecolor','blue','markersize',10);  
hold on

margins = 0.1 ;
axis([-margins,margins+1,-margins,margins+1])
xlabel('level 2 model-free weight');
ylabel('level 1 pruning weight');


xlm=[0:0.001:1];
p = polyfit(X1,X2,1);
a=p(1);
b=p(2);
plot(xlm,b+a*xlm, 'linewidth', 2,'color','r')

