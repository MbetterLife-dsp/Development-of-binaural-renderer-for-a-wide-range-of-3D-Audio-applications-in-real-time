clear all;
close all;
clc;

% load('64band_h_L_9ch.mat');
% load('64band_h_R_9ch.mat');
load('64band__h_L_9ch.mat');
load('64band__h_R_9ch.mat');
% load('32band_h_L_9ch.mat');
% load('32band_h_R_9ch.mat');
L_q= length(h_sub_64_R(:,1,1));


%% EDR
 EDR_R=zeros(64,L_q,9);
 EDR_L=zeros(64,L_q,9);
 
 for ch=1:9
     ch
     for b= 1:64
        for n=1:L_q
         for m=n:L_q
            sum_R=abs(h_sub_64_R(m,b,ch))^2;
            EDR_R(b,n,ch)=EDR_R(b,n,ch)+sum_R;
            sum_L=abs(h_sub_64_L(m,b,ch))^2;
            EDR_L(b,n,ch)=EDR_L(b,n,ch)+sum_L;
         end
     end
     end
 end


 %% Estimate Mixing time

 Threshold=[-10,-20,-30,-40,-50,-60]; %Threshold


 for T_m=1:6
     Test_R=zeros(64,L_q,9);
     Test_L=zeros(64,L_q,9);
     for ch=1:9
         for b=1:64
             for n=1:L_q
                Test_R(b,n,ch)=abs(10*log10(EDR_R(b,n,ch)/EDR_R(b,1,ch))-Threshold(T_m));
                Test_L(b,n,ch)=abs(10*log10(EDR_L(b,n,ch)/EDR_L(b,1,ch))-Threshold(T_m));
             end
             MT_R(b,T_m,ch)=find(Test_R(b,:,ch)==min(Test_R(b,:,ch)));% find mixing time
             MT_L(b,T_m,ch)=find(Test_L(b,:,ch)==min(Test_L(b,:,ch)));% find mixing time

         end
     end
 end
 
 

%% Mixing time Average

N_MT_av__64=zeros(64,6);

 for T_m=1:6
     for b=1:64
         for ch =1:9
         N_MT_av__64(b,T_m)=N_MT_av__64(b,T_m)+MT_L(b,T_m,ch)+MT_R(b,T_m,ch);
         end
         N_MT_av__64(b,T_m)=N_MT_av__64(b,T_m)/44;
     end
 end

 figure,
 plot(N_MT_av__64);legend('-10db','-20db','-30db','-40db','-50db','-60db');
 grid on;
 xlabel('QMF band index'); ylabel('Time index in QMF domain');

 
%  axis([0 ,64, 0 700]);
    