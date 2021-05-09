function plotWeights()

    samplesNum = 100;
    normalizationSamplesNum = 100 ;

    data      = dlmread(['results']);   
    wPosts    = zeros (samplesNum,1)-1;
    wPostsVar = zeros (samplesNum,1);
    
    for sample = 1 : 3 :samplesNum
    
        wPre = normrnd( data(sample,2) , sqrt(data(sample,3)) , normalizationSamplesNum , 1 );

        expWPre = exp(wPre);
        exp1    = exp(1);
        wPost   = 1 - (expWPre ./ (expWPre+exp1));
    
        wPosts    (sample) = mean (wPost);
        wPostsVar (sample) = var (wPost);
    end

    figure('Position', [100, 100, 400, 350]);
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 14)
    set(0,'DefaultAxesFontWeight', 'bold')

    
%    plot ( 1-(1.0/samplesNum) : -(1.0/samplesNum) : 0 , wPosts , 'o') ;
    errorbar ( 1-(1.0/samplesNum) : -(1.0/samplesNum) : 0 , wPosts , sqrt (wPostsVar) , 'o','LineWidth',2,'MarkerSize',2) ;
    hold on
    plot ( [0,1] , [0,1] , '-','LineWidth',2) ;
    
    xlabel('true weight');
    ylabel('estimated weight');
%    legend('Parameter recovery confusion matrix')    
    axis([0,1,0,1]);
