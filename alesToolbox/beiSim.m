%% bei sim

    nSbj = 200;
    scale = .5;
    sigma1 = 1;
    sigma2 = 1;
    nBoot = 10000;
    
    s1 = 0*randn(nSbj,1);
    s2 = s1;
    
%     s1 = s1+sigma1*randn(size(s1));
%     s2 = s2+sigma2*randn(size(s2));

    s1 = sigma1*randn(size(s1));
    s2 = sigma2*randn(size(s2));
    
    [h,p] = ttest(s1,s2);
    %[h,p] = ttest(log(s1),log(s2));
    
    bySbjIdx = s1-s2;
    tic
    m = bootstrp(10000, @mean, bySbjIdx);
    toc
    
    bootse(i) = std(m);
    
    bootNull = zeros(nBoot*100,1);
    for iBoot=1:nBoot,
        
        permuteIdx = zeros(nSbj,1);
        for iSbj=1:length(s1),
            ord = randperm(2);
            if ord(1)==1
                permuteIdx(iSbj) =s1(iSbj)-s2(iSbj);
            else
                permuteIdx(iSbj) =s2(iSbj)-s1(iSbj);
            end
        end
        
        pm = bootstrp(100, @mean, permuteIdx);

        bootNull(idx:idx+length(pm)) = pm;
    end
    

[f,xi] = ksdensity(m,'function','cdf');
max(f(xi<1))    
bootNull=sort(bootNull);
measIdx = mean(s1-s2);

disp('-----')
pairedTp = p
bootp = sum(m<1)./length(m)
boott = sum(bootNull>measIdx)./length(bootNull)
seBoot = std(m)
seData =  std(bySbjIdx)./sqrt(length(bySbjIdx))
figure(30)




plot(s1./s2,'x')

hist(m,100)
 [fi,xi] = ksdensity(m);
 plot(xi,fi);