function plottings()


%######################################################################
%#              Critical parameters
%######################################################################
usingSyntheticData      = 0     ;% 0:No  1:MB  2: Pruning  3:MF-1  4: MF-0  5: Mixed ;
group                   = 2                                                     ;
maximLags               = 5                                                     ;
predictorsMode          = 2     ; %  0:  C__  _C_  __R  CC_  C_R  _CR  CCR      ;
                                  %  1:  CCR  CRR  CRR  RRR                     ;
                                  %  2:  CCR  CRR  CRR  RRR  CCN  CRN  CRN  RRN ;
                                  %  3:  CCR+RRR   CRR+RCR   CCR+CRR   RCR+RRR  ;

%######################################################################
%#              Loading results from file
%######################################################################

if     usingSyntheticData == 1
    results = load (['Results/ResultsSynthMBas-Lags',int2str(maximLags),'.mat']) ;
elseif usingSyntheticData == 2
    results = load (['Results/ResultsSynthPrun-Lags',int2str(maximLags),'.mat']) ;
elseif usingSyntheticData == 3
    results = load (['Results/ResultsSynthMF1e-Lags',int2str(maximLags),'.mat']) ;
elseif usingSyntheticData == 4
    results = load (['Results/ResultsSynthMF0e-Lags',int2str(maximLags),'.mat']) ;
elseif usingSyntheticData == 5
    results = load (['Results/ResultsSynthMixd-Lags',int2str(maximLags),'.mat']) ;
else    
    results = load (['Results/ResultsGrp',int2str(group),'-Lags',int2str(maximLags),'.mat']);
end        


%######################################################################
%#              Initializations
%######################################################################
if predictorsMode == 0 
    principalIVnumsPerLag = 7 ;
elseif predictorsMode == 1 
    principalIVnumsPerLag = 4 ;
elseif predictorsMode == 2 
    principalIVnumsPerLag = 8 ;
elseif predictorsMode == 3 
    principalIVnumsPerLag = 4 ;
end


sizeW    = size(results.w)                             ;
maxLags  = (sizeW (1,1)-1)/principalIVnumsPerLag       ;     
IVnumber = (sizeW (1,1)-1)/maxLags                     ;


%######################################################################
%#              Organizing data
%######################################################################

w   = zeros ( IVnumber , maxLags );
v   = zeros ( IVnumber , maxLags );

for lag = 1 : maxLags
    for IV = 1 : IVnumber
        w   ( IV , lag ) = results.w ( (IVnumber)*(lag-1) + IV + 1 ) ;        
        v   ( IV , lag ) = results.PSI ( (IVnumber)*(lag-1) + IV + 1 , (IVnumber)*(lag-1) + IV + 1 );        
    end
end


bias  = ones  (1,maxLags) * results.w   (1  );
vBias = ones  (1,maxLags) * results.PSI (1,1);


if predictorsMode == 0 

    bias   = 0 ;
    vBias  = 0 ;
    
    IVC__= w(1,:);
    IV_C_= w(2,:);
    IV__R= w(3,:);
    IVCC_= w(4,:);
    IVC_R= w(5,:);
    IV_CR= w(6,:);
    IVCCR= w(7,:);

    IVCCR =     bias + w(1,:) + w(2,:) + w(3,:) + w(4,:) + w(5,:) + w(6,:) + w(7,:);
    IVCRR =     bias + w(1,:) +          w(3,:) +          w(5,:)                  ;
    IVRCR =     bias +          w(2,:) + w(3,:) +                   w(6,:)         ;
    IVRRR =     bias +                   w(3,:)                                    ;
    IVCCN =     bias + w(1,:) + w(2,:) +          w(4,:)                           ;
    IVCRN =     bias + w(1,:)                                                      ;
    IVRCN =     bias +          w(2,:)                                             ;
    IVRRN =     bias                                                               ;

    vIVCCR=     vBias + v(1,:) + v(2,:) + v(3,:) + v(4,:) + v(5,:) + v(6,:) + v(7,:);
    vIVCRR=     vBias + v(1,:) +          v(3,:) +          v(5,:)                  ;
    vIVRCR=     vBias +          v(2,:) + v(3,:) +                   v(6,:)         ;
    vIVRRR=     vBias +                   v(3,:)                                    ;
    vIVCCN=     vBias + v(1,:) + v(2,:) +          v(4,:)                           ;
    vIVCRN=     vBias + v(1,:)                                                      ;
    vIVRCN=     vBias +          v(2,:)                                             ;
    vIVRRN=     vBias                                                               ;

elseif predictorsMode == 1 
    bias   = 0 ;
    vBias  = 0 ;
    
    IVCCR  = w(1,:) +  bias ;
    IVCRR  = w(2,:) +  bias ;
    IVRCR  = w(3,:) +  bias ;
    IVRRR  = w(4,:) +  bias ;
    vIVCCR = v(1,:) + vBias ;
    vIVCRR = v(2,:) + vBias ;
    vIVRCR = v(3,:) + vBias ;
    vIVRRR = v(4,:) + vBias ;    

elseif predictorsMode == 2
    bias   = 0 ;
    vBias  = 0 ;
    
    IVCCR  = w(1,:) +  bias ;
    IVCRR  = w(2,:) +  bias ;
    IVRCR  = w(3,:) +  bias ;
    IVRRR  = w(4,:) +  bias ;
    IVCCN  = w(5,:) +  bias ;
    IVCRN  = w(6,:) +  bias ;
    IVRCN  = w(7,:) +  bias ;
    IVRRN  = w(8,:) +  bias ;
    vIVCCR = v(1,:) + vBias ;
    vIVCRR = v(2,:) + vBias ;
    vIVRCR = v(3,:) + vBias ;
    vIVRRR = v(4,:) + vBias ;    
    vIVCCN = v(5,:) + vBias ;
    vIVCRN = v(6,:) + vBias ;
    vIVRCN = v(7,:) + vBias ;
    vIVRRN = v(8,:) + vBias ;    

elseif predictorsMode == 3
    bias   = 0 ;
    vBias  = 0 ;
    
    IVCCR_RRR  = w(1,:) +  bias  ;
    IVCRR_RCR  = w(2,:) +  bias  ;
    IVCCR_CRR  = w(3,:) +  bias  ;
    IVRCR_RRR  = w(4,:) +  bias  ;
    vIVCCR_RRR = v(1,:) +  vBias ;
    vIVCRR_RCR = v(2,:) +  vBias ;
    vIVCCR_CRR = v(3,:) +  vBias ;
    vIVRCR_RRR = v(4,:) +  vBias ;
    
end

%######################################################################
%#              Plotting
%######################################################################


FigHandle = figure('Position', [100, 600, 300 , 250]);
set(0,'DefaultAxesFontName', 'Arial')
set(0,'DefaultAxesFontSize', 18)
set(0,'DefaultAxesFontWeight', 'normal')

x=0;
if maximLags==1
    x=0.1;
end

if ~(predictorsMode == 3)

    errorbar ( -1*x+[maxLags:-1:1] , IVCCR , sqrt(vIVCCR) , 'linewidth', 3);
    hold on
    errorbar ( -0*x+[maxLags:-1:1] , IVCRR , sqrt(vIVCRR) , 'linewidth', 3);
    hold on
    errorbar ( +1*x+[maxLags:-1:1] , IVRCR , sqrt(vIVRCR) , 'linewidth', 3);
    hold on
    errorbar ( +2*x+[maxLags:-1:1] , IVRRR , sqrt(vIVRRR) , 'linewidth', 3);
    hold on
    %legend('CC','CR','RC','RR');

    line([0 maxLags+1],[0 0],'Color','black','linewidth', 2);
    axis([0.5,maxLags+0.5,-7,7])
    xticklabel = {-[maxLags:-1:1]};    
    set(gca, 'XTick', 1:maxLags, 'XTickLabel', xticklabel);
    xlabel('Lag (trials)');
    ylabel('Log odds') 

    %title(['After rewarded trials']);





    FigHandle = figure('Position', [100, 300, 300 , 250]);

    errorbar ( -1*x+[maxLags:-1:1] , IVCCR+IVRRR , sqrt(vIVCCR+vIVRRR) , 'linewidth', 3);
    hold on
    errorbar ( +0*x+[maxLags:-1:1] , IVCRR+IVRCR , sqrt(vIVCRR+vIVRCR) , 'linewidth', 3);
    hold on
    errorbar ( +1*x+[maxLags:-1:1] , IVCCR+IVCRR , sqrt(vIVCCR+vIVCRR) , 'linewidth', 3);
    hold on
    errorbar ( +2*x+[maxLags:-1:1] , IVRCR+IVRRR , sqrt(vIVRCR+vIVRRR) , 'linewidth', 3);
    hold on
    %legend('CC+RR','CR+RC','CC+CR','RC+RR');

    line([0 maxLags+1],[0 0],'Color','black','linewidth', 2);
    axis([0.5,maxLags+0.5,-inf,inf])
    xticklabel = {-[maxLags:-1:1]};    
    set(gca, 'XTick', 1:maxLags, 'XTickLabel', xticklabel);
    xlabel('Lag (trials)');
    ylabel('Log odds') 

    title(['After rewarded trials']);




    FigHandle = figure('Position', [100, 000, 300 , 250]);

    MBness  =       IVCCR+ IVRRR- IVCRR- IVRCR  ;
    vMBness = sqrt(vIVCCR+vIVRRR+vIVCRR+vIVRCR );
    PRness  =       IVCCR+ IVCRR- IVRCR- IVRRR  ;
    vPRness = sqrt(vIVCCR+vIVRRR+vIVCRR+vIVRCR) ;
    errorbar ( -1*x+[maxLags:-1:1] , MBness , vMBness , 'linewidth', 3,'color','red');
    hold on
    errorbar ( +0*x+[maxLags:-1:1] , PRness , vPRness , 'linewidth', 3,'color','blue' );
    hold on
    %legend('CC+RR-CR-RC','CC+CR-RC-RR');

    line([0 maxLags+1],[0 0],'Color','black','linewidth', 2);
    axis([0.5,maxLags+0.5,-5,25])
    xticklabel = {-[maxLags:-1:1]};    
    set(gca, 'XTick', 1:maxLags, 'XTickLabel', xticklabel);
    xlabel('Lag (trials)');
    ylabel('Log odds') 

    %title(['After rewarded trials']);




    MB_Zscore = MBness./vMBness;
    PR_Zscore = PRness./vPRness;

    MB_Pvalue = normpdf(MB_Zscore,0,1)
    PR_Pvalue = normpdf(PR_Zscore,0,1)


else

    errorbar ( -1*x+[maxLags:-1:1] , IVCCR_RRR , sqrt(vIVCCR_RRR) , 'linewidth', 3);
    hold on
    errorbar ( +0*x+[maxLags:-1:1] , IVCRR_RCR , sqrt(vIVCRR_RCR) , 'linewidth', 3);
    hold on
    errorbar ( +1*x+[maxLags:-1:1] , IVCCR_CRR , sqrt(vIVCCR_CRR) , 'linewidth', 3);
    hold on
    errorbar ( +2*x+[maxLags:-1:1] , IVRCR_RRR , sqrt(vIVRCR_RRR) , 'linewidth', 3);
    hold on
    legend('CC+RR','CR+RC','CC+CR','RC+RR');



    FigHandle = figure('Position', [100, 300, 300 , 250]);
    errorbar ( -1*x+[maxLags:-1:1] , IVCCR_RRR-IVCRR_RCR , sqrt(vIVCCR_RRR+vIVCRR_RCR) , 'linewidth', 3);
    hold on
    errorbar ( +1*x+[maxLags:-1:1] , IVCCR_CRR-IVRCR_RRR , sqrt(vIVCCR_CRR+vIVRCR_RRR) , 'linewidth', 3);
    hold on
    legend('CC+RR-CR-RC','CC+CR-RC-RR');

end
