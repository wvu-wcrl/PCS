rootDir = '/rhome/pcs/jm/ee561/Temp/';
a = dir(rootDir);
length(a)
Counter = 0;
secCounter = 0;

for i=1:length(a)
    if( ((length(a(i).name)>=13) && strcmp(a(i).name(1:13),'ee561_Project')) || ...
            ((length(a(i).name)>=8) && strcmp(a(i).name(1:8),'ee561_CT')) || ...
            ((length(a(i).name)>=32) && strcmp(a(i).name(1:32),'ee561_OptimumSignalSetforPartI_a')) )
        Counter = Counter + 1;
        mvstr = ['sudo rm "' fullfile( rootDir, a(i).name) '"'];
        system(mvstr);
        if rem(Counter,100) == 0
            fprintf('*')
        end
    else
        secCounter = secCounter + 1;
        if rem(secCounter,100) == 0
            fprintf('-')
        end
    end
end