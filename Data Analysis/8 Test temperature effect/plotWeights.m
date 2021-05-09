function plotWeights()

%------------------------------------ Plot groups' estimates 
    %------ MB Weights at level 1
    w    = [0.920334899097553    0.868813689709608];
    vari = [0.00244552493943973  0.0130927537345347];
       
    %------ Beta, level 1
%    w    = [2.74887245889985      2.07186677848271];  
%    vari = [0.000449877959212586  0.000938174936942815];

    %------ Beta, level 2
%    w    = [2.07565220027662      1.35181501304946];  
%    vari = [0.00100266163069662   0.00128116618221719];
    
    
    
    %-------------------------------------   
    
    samplesNum = 1000000;
        
    w1pre = normrnd(w(1),sqrt(vari(1)),samplesNum,1);
    w2pre = normrnd(w(2),sqrt(vari(2)),samplesNum,1);

    expW1pre = exp(w1pre);
    expW2pre = exp(w2pre);
    exp1     = exp(1);

    % For normalizing all variables except Beta_L1 and Beta_L2
    w1 = 1 - (expW1pre ./ (expW1pre+exp1));
    w2 = 1 - (expW2pre ./ (expW2pre+exp1));

    % For normalizing Beta_L1 and Beta_L2
%    w1 = expW1pre;
%    w2 = expW2pre;
    
    mean(w1)
    mean(w2)
    sqrt(var(w1))
    sqrt(var(w2))
    
    
    figure('Position', [100, 100, 350, 250]);
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 14)
    set(0,'DefaultAxesFontWeight', 'bold')
    
    
    h1 = histogram(w1,1000);
    h1.EdgeColor = 'none';
    h1.FaceColor = 'rax';
    hold on
    h2 = histogram(w2,1000);
    h2.EdgeColor = 'none';
    h2.FaceColor = 'b';
    h1.Normalization = 'pdf';    
    h2.Normalization = 'pdf';    
    
    xlabel('pruning weight');
    ylabel('probability');
    legend('High-resource Group','Low-resource Group')    
    hold on
%------------------------------------ Plot individual subjects' posteriors    

    paramsNum   = 8  ;
    subjectsNum = 15 ;
    samplesNum = 100000;
    
    ws    = zeros (subjectsNum,paramsNum,2);
    vars  = zeros (subjectsNum,paramsNum,2);

    normalizedMeans    = zeros (subjectsNum,paramsNum,2);
    normalizedModes    = zeros (subjectsNum,paramsNum,2);
    normalizedVars     = zeros (subjectsNum,paramsNum,2);
        
    ws1   = open ('Results_means1.mat');
    vars1 = open ('Results_variances1.mat');
    ws2   = open ('Results_means2.mat');
    vars2 = open ('Results_variances2.mat');
    
    %-------------- Load data
    for subject = 1 : subjectsNum
        for params = 1 : paramsNum
            ws(subject,params,1)   = ws1.w(subject,params) ;
            ws(subject,params,2)   = ws2.w(subject,params) ;
            vars(subject,params,1) = vars1.s(params,params,subject);
            vars(subject,params,2) = vars2.s(params,params,subject);
        end
    end

    %-------------- Normalize parameters
    for subject = 1 : subjectsNum
                
        w1pre = normrnd(ws(subject,1,1),sqrt(vars(subject,1,1)),samplesNum,1);
        w2pre = normrnd(ws(subject,1,2),sqrt(vars(subject,1,2)),samplesNum,1);

        expW1pre = exp(w1pre);
        expW2pre = exp(w2pre);
        exp1     = exp(1);

        w1 = 1 - (expW1pre ./ (expW1pre+exp1));
        w2 = 1 - (expW2pre ./ (expW2pre+exp1));

        normalizedMeans(subject,1,1) = mean(w1);
        normalizedMeans(subject,1,2) = mean(w2);
        normalizedModes(subject,1,1) = median(w1);
        normalizedModes(subject,1,2) = median(w2);
        normalizedVars (subject,1,1) = var (w1);
        normalizedVars (subject,1,2) = var (w2);

    end
    
    %-------------- Sort accross the subjects
    [m1,I1] = sort    (normalizedMeans(:,1,1));
    [m2,I2] = sort    (normalizedMeans(:,1,2));
    I1
    I2
    v1 = zeros (subjectsNum,1);
    v2 = zeros (subjectsNum,1);    
    d1 = zeros (subjectsNum,1);
    d2 = zeros (subjectsNum,1);
    index = zeros (subjectsNum,1);
       
    for subject = 1 : subjectsNum
        v1(subject)      =  normalizedVars (  I1(subject) ,1,1);
        v2(subject)      =  normalizedVars (  I2(subject) ,1,2);
        d1(subject)      =  normalizedModes(  I1(subject) ,1,1);
        d2(subject)      =  normalizedModes(  I2(subject) ,1,2);
        index(subject)   =  (16-subject)/2.3 ;
    end

    
    
%{
    herrorbar(m1,index,sqrt(v1),'r.');%,'LineWidth',2,'MarkerSize',0.1,'MarkerEdgeColor','r');
    hold on
    plot(d1,index,'ro','MarkerSize',7,'LineWidth',2,'MarkerEdgeColor','r');
    hold on
    
    herrorbar(m2,index,sqrt(v2),'b.');%,'LineWidth',2,'MarkerSize',0.1,'MarkerEdgeColor','b');
    hold on
    plot(d2,index,'bo','MarkerSize',7,'LineWidth',2,'MarkerEdgeColor','b');
    
%}
    
    
    for subject = 1 : subjectsNum
        index(subject)   =  (17)/2.3 ;
    end
    plot(d1,index,'o', 'linewidth', 1,'color','red','markerfacecolor','red','markeredgecolor','red','markersize',6);
    hold on
    for subject = 1 : subjectsNum
        index(subject)   =  (16)/2.3 ;
    end
    plot(d2,index,'o', 'linewidth', 1,'color','blue','markerfacecolor','blue','markeredgecolor','blue','markersize',6);

    d1
    d2
    
    
%------------------------------------ Check for correlations

    wGroup2Level1 = normalizedMeans(:,1,2);
    
    %-------------- Normalize pruning weights, Level 2
    wGroup2Level2 = zeros (15,1);
    for subject = 1 : subjectsNum                
        w2pre = normrnd(ws(subject,2,2),sqrt(vars(subject,2,2)),samplesNum,1);
        expW2pre = exp(w2pre);
        exp1     = exp(1);
        w2 = 1 - (expW2pre ./ (expW2pre+exp1));
        wGroup2Level2(subject) = mean(w2);
    end
    
    %-------------- Normalize MB Learning rate    
    alphaMBGroup2 = zeros (15,1);
    for subject = 1 : subjectsNum                
        w2pre = normrnd(ws(subject,4,2),sqrt(vars(subject,4,2)),samplesNum,1);
        w2 = 1.0 ./ ( 1 + exp(- w2pre )) ;
        alphaMBGroup2(subject) = mean(w2);
    end
    
    %-------------- Normalize MF Learning rate    
    alphaMFGroup2 = zeros (15,1);
    for subject = 1 : subjectsNum                
        w2pre = normrnd(ws(subject,5,2),sqrt(vars(subject,5,2)),samplesNum,1);
        w2 = 1.0 ./ ( 1 + exp(- w2pre )) ;
        alphaMFGroup2(subject) = mean(w2);
    end

    %-------------- Normalize Beta Level 1    
    BetaGroup2Level1 = zeros (15,1);    
    for subject = 1 : subjectsNum                
        w2pre = normrnd(ws(subject,7,2),sqrt(vars(subject,7,2)),samplesNum,1);
        w2 = exp(w2pre) ;
        BetaGroup2Level1(subject) = mean(w2);
    end       
    
    %-------------- Normalize Beta Level 2    
    BetaGroup2Level2 = zeros (15,1);    
    for subject = 1 : subjectsNum                
        w2pre = normrnd(ws(subject,8,2),sqrt(vars(subject,8,2)),samplesNum,1);
        w2 = exp(w2pre) ;
        BetaGroup2Level2(subject) = mean(w2);
    end
                
    %-------------- Normalize pruning weights, Level 2, Group 1
    wGroup1Level1 = normalizedMeans(:,1,1);
    wGroup1Level2 = zeros (15,1);
    for subject = 1 : subjectsNum                
        w2pre = normrnd(ws(subject,2,1),sqrt(vars(subject,2,1)),samplesNum,1);
        expW2pre = exp(w2pre);
        exp1     = exp(1);
        w2 = 1 - (expW2pre ./ (expW2pre+exp1));
        wGroup1Level2(subject) = mean(w2);
    end
    
    
    %-------------- Key variables : X1 , X2
    X1 = wGroup1Level1 ;
    X2 = wGroup1Level2 ;    
%    wGroup2Level2    
%    alphaMBGroup2
%    alphaMFGroup2
%    BetaGroup2Level1
%    BetaGroup2Level2
    %-------------- Statistical analysis

    R=corr(X1,X2,'type','Spearman');
    disp(['R^2 = ']);
    R^2
    disp(['test statistic = ']);
    R/(sqrt((1-R^2)/(15-2)))
    p_value = 1- tcdf ( R/(sqrt((1-R^2)/(15-2))) ,15-2 )


    %-------------------------- Plotting
    FigHandle = figure('Position', [100, 100, 250, 290]);
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 14)
    set(0,'DefaultAxesFontWeight', 'bold')

    %Ones = ones(1,Size(1,2));
    %X2 = Ones-X2;


    

    X1 = wGroup1Level1 ;
    X2 = wGroup1Level2 ;    
    plot(X1,X2 ,'o', 'linewidth', 2,'color','red','markerfacecolor','red','markeredgecolor','red','markersize',7);  
    hold on
    xlm=[0:0.001:0.40];
    p = polyfit(X1,X2,1);
    a=p(1);
    b=p(2);
    plot(xlm,b+a*xlm, 'linewidth', 2,'color','r')


    X1 = wGroup2Level1 ;
    X2 = wGroup2Level2 ;    
    plot(X1,X2 ,'o', 'linewidth', 2,'color','blue','markerfacecolor','blue','markeredgecolor','blue','markersize',7);  
    hold on
    xlm=[0:0.001:0.9];
    p = polyfit(X1,X2,1);
    a=p(1);
    b=p(2);
    plot(xlm,b+a*xlm, 'linewidth', 2,'color','b')
    hold on
    
    
    
    
    margins = 0.1 ;
    axis([-margins,margins+1,0,1])
%    axis([-margins,margins+1,1,8])
    xlabel('level 1 pruning weight');
    ylabel('level 2 model-free weight');
%    ylabel('level 2 Beta');









function hh = herrorbar(x, y, l, u, symbol)
%HERRORBAR Horizontal Error bar plot.
%   HERRORBAR(X,Y,L,R) plots the graph of vector X vs. vector Y with
%   horizontal error bars specified by the vectors L and R. L and R contain the
%   left and right error ranges for each point in X. Each error bar
%   is L(i) + R(i) long and is drawn a distance of L(i) to the right and R(i)
%   to the right the points in (X,Y). The vectors X,Y,L and R must all be
%   the same length. If X,Y,L and R are matrices then each column
%   produces a separate line.
%
%   HERRORBAR(X,Y,E) or HERRORBAR(Y,E) plots X with error bars [X-E X+E].
%   HERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'. See PLOT for possibilities.
%
%   H = HERRORBAR(...) returns a vector of line handles.
%
%   Example:
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      herrorbar(x,y,e)
%   draws symmetric horizontal error bars of unit standard deviation.
%
%   This code is based on ERRORBAR provided in MATLAB.   
%
%   See also ERRORBAR

%   Jos van der Geest
%   email: jos@jasen.nl
%
%   File history:
%   August 2006 (Jos): I have taken back ownership. I like to thank Greg Aloe from
%   The MathWorks who originally introduced this piece of code to the
%   Matlab File Exchange. 
%   September 2003 (Greg Aloe): This code was originally provided by Jos
%   from the newsgroup comp.soft-sys.matlab:
%   http://newsreader.mathworks.com/WebX?50@118.fdnxaJz9btF^1@.eea3ff9
%   After unsuccessfully attempting to contact the orignal author, I
%   decided to take ownership so that others could benefit from finding it
%   on the MATLAB Central File Exchange.

if min(size(x))==1,
    npt = length(x);
    x = x(:);
    y = y(:);
    if nargin > 2,
        if ~isstr(l),
            l = l(:);
        end
        if nargin > 3
            if ~isstr(u)
                u = u(:);
            end
        end
    end
else
    [npt,n] = size(x);
end

if nargin == 3
    if ~isstr(l)
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [m,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);;
    end
end

if nargin == 4
    if isstr(u),
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end

if nargin == 2
    l = y;
    u = y;
    y = x;
    [m,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);;
    symbol = '-';
end

u = abs(u);
l = abs(l);

if isstr(x) | isstr(y) | isstr(u) | isstr(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~isequal(size(x),size(l)) | ~isequal(size(x),size(u)),
    error('The sizes of X, Y, L and U must be the same.');
end

tee = (max(y(:))-min(y(:)))/100; % make tee .02 x-distance for error bars
% changed from errorbar.m
xl = x - l;
xr = x + u;
ytop = y + tee;
ybot = y - tee;
n = size(y,2);
% end change

% Plot graph and bars
hold_state = ishold;
cax = newplot;
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
% changed from errorbar.m
xb = zeros(npt*9,n);
xb(1:9:end,:) = xl;
xb(2:9:end,:) = xl;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xl;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xr;
xb(8:9:end,:) = xr;
xb(9:9:end,:) = NaN;

yb = zeros(npt*9,n);
yb(1:9:end,:) = ytop;
yb(2:9:end,:) = ybot;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = y;
yb(5:9:end,:) = y;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ytop;
yb(8:9:end,:) = ybot;
yb(9:9:end,:) = NaN;
% end change


[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot(xb,yb,esymbol,'LineWidth',1.5); hold on
%h = [h;plot(x,y,symbol)];

if ~hold_state, hold off; end

if nargout>0, hh = h; end


