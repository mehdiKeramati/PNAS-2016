function main()
    
    group                       = 2      ;
    subjectsNum                 = 15     ;
    trialsNum                   = 350    ;    

    Means = load(['Results_means'    ,int2str(group),'.mat']);   
    Vars  = load(['Results_variances',int2str(group),'.mat']);   

    NormalizedMeans = zeros ( subjectsNum , 8 );     

    samplesNum = 100000;        
   
    
    for subject = 1 : subjectsNum
        for param = 1 : 2        
            samples = normrnd(Means.w(subject,param),sqrt(Vars.s(param,param,subject)),samplesNum,1);
            expSamples = exp(samples);
            exp1     = exp(1);
            normalizedSamples = expSamples ./ (expSamples+exp1);
            NormalizedMeans ( subject , param ) =  mean(normalizedSamples) ; 
        end
        
        NormalizedMeans ( subject , 3 ) =  Means.w(subject,3) ;

        for param = 4 : 6        
            samples = normrnd(Means.w(subject,param),sqrt(Vars.s(param,param,subject)),samplesNum,1);
            expSamples = exp(-samples);
            normalizedSamples = 1 ./ (1+expSamples);
            NormalizedMeans ( subject , param ) =  mean(normalizedSamples) ; 
        end
        
        NormalizedMeans ( subject , 6 ) =  0 ;

        for param = 7 : 8
            samples = normrnd(Means.w(subject,param),sqrt(Vars.s(param,param,subject)),samplesNum,1);
            expSamples = exp(samples);
            normalizedSamples = expSamples;
            NormalizedMeans ( subject , param ) =  mean(normalizedSamples) ; 
        end                                   
        
        
        
    end    
        
    for subject = 1 : subjectsNum
        generateSyntheticData ( NormalizedMeans(subject,:) , trialsNum , subject+(group-1)*subjectsNum );
    end    
    
end