function main()

    clc
    permutationsNum = 1 ;
    weights = zeros ( 1 , 2 , 2 ); % permutationsNum , group , mean or variance
    
    for permutation = 1 : permutationsNum
        
            permString = [] ;
            subjects =  zeros (15 , 1);
            for subject = 1 : 15
                subjects (subject) = randi(2)-1 ;
                permString = [permString int2str(subjects(subject))];                
            end
            
            
            subjects =  zeros (15 , 1);     % for the true permutation
            permString = '000000000000000'; % for the true permutation
            
            disp(['----------------------------------------------------------------------']);
            disp(['- Permutation ', int2str(permutation),' : ' , permString]);
            disp(['----------------------------------------------------------------------']);
        
        try
            G1 = fitting ( subjects , permutation , 1 );        
            G2 = fitting (~subjects , permutation , 2 );
            weights ( 1 , : , : ) = [G1 ; G2] 
            save([permString , '.mat'],'weights');
        catch
            weights ( 1 , : , : ) = [0,0 ; 0,0] ;           
            save(['Failed',permString ,'.mat'],'weights');           
        end
        
    end
