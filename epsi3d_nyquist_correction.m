%% nyquist ghost artifact correction for 3D EPSI data.
clear all; close all; clc
TOT=[];
totR2=[];
totSL=[];
totINT=[];
V=150;

for ii=1:V;
    load(['----' num2str(ii) '.mat']); 
    % 150 kt volumes. Each kt volume is 128 x 384 x 32 echoes
    
    for i=1:32
        
        Y=k(i,:,:);
        if mod(i,2)==0;
            Y=flipdim(Y,3); 
            
        else
        end
        
        TT(i,:,:)=Y;
    end
    
    
    M=squeeze(TT(1:32,size(k,2)/2+1,:));
    mMo=mean(M([1,3],:),1);
    mMe=M([2],:);
    S1=ifftshift(ifft(ifftshift(mMo)));
    S2=ifftshift(ifft(ifftshift(mMe)));
    S=S1.*conj(S2);

    xl=size(k,3)/2-10;
    xu=size(k,3)/2+10; 
    
    x=xl:xu;
    YN=unwrap(angle(S(xl:xu)));
    [p]=polyfit(x,YN,1);
    corr=polyval(p,1:384);
    YN_corr=polyval(p,xl:xu);
    [r2 rmse]= rsquare(YN,YN_corr);
    totR2=[totR2;r2];
    totSL=[totSL;p(1)];
    totINT=[totINT;p(2)];
   
end
%%
figure;
plot(totSL,'o');axis square;grid on;title('phase slope over 150 volume')
figure;
plot(totINT,'o');axis square;grid on;title('phase intercept over 150 volumes')
figure;
plot(totR2,'o');axis square;grid on;title('goodness of fit over 150 volumes')

p_sl=mean(totSL(V/2-5:V/2+5));
p_int=mean(totINT(V/2-5:V/2+5));

pp=[p_sl,p_int];
corr=polyval(pp,1:384);
CC=corr;
SDcc=[];

for p=1:size(CC,1)
    C=CC(p,:);
    corr_odd=[];
    C_od=exp(-1j*C/2);
    for q=1:128;
        corr_odd(q,:)=C_od;
    end
    corr_odd=repmat(corr_odd,[1,1,16]);
    
    corr_even=[];
    C_ev=exp(+1j*C/2);
    for q=1:128;
        corr_even(q,:)=C_ev;
    end
    corr_even=repmat(corr_even,[1,1,16]);
    
    TOT=[];
    for ii=1:V;
        load(['----' num2str(ii) '.mat']); 
        
        for i=1:32
            
            Y=k(i,:,:);
            if mod(i,2)==0;
                Y=flipdim(Y,3); 
                
            else
            end
            
            TT(i,:,:)=Y;
        end
        
        TTodd=TT(1:2:32,:,:);
        TTodd=permute(TTodd,[2 3 1]);
        TTeven=TT(2:2:32,:,:);
        TTeven=permute(TTeven,[2 3 1]);
        
       
        t_odd=ifftshift(ifft(ifftshift(TTodd,2),[],2),2).*corr_odd;
        t_even=ifftshift(ifft(ifftshift(TTeven,2),[],2),2).*corr_even;
        
        A=[];
        A(:,:,1:2:32)=fftshift(fft(fftshift(t_odd,2),[],2),2);
        A(:,:,2:2:32)=fftshift(fft(fftshift(t_even,2),[],2),2);
        TOT(ii,:,:,:)=A;
    end
    
end

