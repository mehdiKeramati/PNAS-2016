
startFrom   = 1   ; 
samplesNum  = 100 ;

weight = 0 : (1.0/samplesNum) : 1-(1.0/samplesNum) ;
warning('off','all')


parfor sample = startFrom : samplesNum
    
    disp (['Creating synthetic data for group ',int2str(sample) , ' / ', int2str(samplesNum) ]);
    generateSyntheticData ( weight(sample) , sample );        
    
end



weightHat = zeros ( samplesNum , 2 ) ;

for sample = startFrom : samplesNum

    try
        mean_W_var_W  = weightEstimation ( sample ) ;        
        weightHat ( sample , : ) = mean_W_var_W     ;
    catch
        weightHat ( sample , : ) = [ NaN , NaN ]    ;
    end

    
    fid = fopen('results','wt');
    for samples = startFrom : samplesNum
        fprintf(fid,'%d,%d,%d\n',weight(samples),weightHat(samples,1),weightHat(samples,2));
    end
    fclose(fid);
    
end

