function print2file(data,filename,trialsNum)
    fid = fopen(filename,'wt');
    for trial = 1 : trialsNum
        fprintf(fid,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',...
            trial,...
            0,...
            data(trial).secondLevelState-1,...
            data(trial).thirdLevelState-3,...
            data(trial).firstLevelAction-1,...
            data(trial).secondLevelAction-1,...
            0,...
            0,...
            0,...
            0,...
            0,...
            0,...
            data(trial).firstLevelTransitionType,...
            data(trial).secondLevelTransitionType,...
            0,...
            0,...
            data(trial).reward,...
            0); 
    end
    fclose(fid);
