%% Iitialization
clear all;
close all;
channel=9;

%BRIR subband mixing time
load('64band_mixtingtime_9ch.mat');%using Mixing time.m
[signal,fs]=audioread('home_48000_mono.wav');

signal=signal(1:163840,1)';
x_sub=SBR_QMF_analysis_64band(signal); %SBR QMF domain analysis

%BRIR subband(9channel에 대한 QMF domain값들 불러오기)--using
%SBR_QMF_analysis_64band.m
load('64band__h_R_9ch.mat'); 
load('64band__h_L_9ch.mat');

%% curve fitting Mixing time (N_MT_curve : Curve fitting을 통한 mixing time 탐색)

K_proc=64;
K_conv=64;
T_m_voff=2;

sum=0;
for b=1:K_proc-1
   sum=sum+(b);
end

x_tilda=sum*(1/(K_proc-1));

sum=0;
for b=2:K_proc
   sum=sum+log2(N_MT_av__64(b,T_m_voff));
end

y_tilda=sum*(1/(K_proc-1));

sum=0;
for b=2:K_proc
    sum=sum+(b-1)*log2(N_MT_av__64(b,T_m_voff));
end
s_xy=sum-(K_proc-1)*x_tilda*y_tilda;

sum=0;
for b=1:K_proc-1
    sum=sum+b^2;
end
s_xx=sum-(K_proc-1)*x_tilda^2;

alpha=s_xy/s_xx;
beta=y_tilda-alpha*x_tilda;
for b=1:K_proc
    N_MT_curve(b)=2^(alpha*log2(N_MT_av__64(b,T_m_voff))+beta);%% where beta position???
end

%figure curve fitting position
plot(N_MT_av__64(:,T_m_voff));hold on;plot(N_MT_curve);
grid on;xlabel('band'); ylabel('mixing time');
legend('mixing time(T_m=-50dB)','curve fitting mixing time(T_m=-50dB)');

%% L_voff - Mixing time통한 BRIR의 direct+early reflection 그리고 fft size에 따른 각 band별 block수 지정

%Method1 curve fitting을 통해 mixing time 지점 조절
L_voff(1)=2^(log2(N_MT_av__64(1,T_m_voff)));
for b=2:64
   L_voff(b)=2^(log2(N_MT_curve(b))+0.5); 
end

%Method2 Threshold의 값을 통해 mixing time 지점 조절
% L_voff=N_MT_av__64(:,T_m); 

L_voff=round(L_voff);
N_fft_max=64;
for b=1:64
    A=2*L_voff(b);
    N_fft(b)=min([A  N_fft_max]);
end

for b=1:64
    N_DE_blk(b)=max([2*L_voff(b)/N_fft(b) 1]);% 각 band 마다 block 수
end

%% window (fade-in, fade-out)
for b=1:64
    N_blk(b)=length(h_sub_64_L(b,:,1))/(N_fft(b)/2);
end

N_DE_blk=ceil(N_DE_blk);
w=window_sub(N_DE_blk,K_conv,N_fft,N_blk); %window_sub :implementation of fade-in,fade-out

%% subblock of subband BRIR

% left BRIR (mixing time에 따른 BRIR 중 DE구간 분리하기)
h_DE_L= zeros(size(h_sub_64_L));
for ch=1:9
    for b=1:K_conv
        for n=1:length(w(b,1:N_DE_blk(b)*(N_fft(b)/2)))
%             h_DE_L(b,n,ch)=h_sub_64_L(b,n,ch)*w(b,n);
             MT=round(N_MT_av__64(b,T_m_voff));
            h_DE_L(b,1:MT,ch)=h_sub_64_L(b,1:MT,ch);
        end
    end
end

% right BRIR (mixing time에 따른 BRIR 중 DE구간 분리하기)
h_DE_R= zeros(size(h_sub_64_R));
for ch=1:9
    for b=1:K_conv
        for n=1:length(w(b,1:N_DE_blk(b)*(N_fft(b)/2)))
%             h_DE_R(b,n,ch)=h_sub_64_R(b,n,ch)*w(b,n);
             MT=round(N_MT_av__64(b,T_m_voff));
            h_DE_R(b,1:MT,ch)=h_sub_64_R(b,1:MT,ch);
        end
    end
end


%left BRIR (각 band별로 variable fft size로 분리)
h_DE_L_sub=zeros(max(N_fft),max(N_DE_blk),K_conv,9);
for ch=1:9
for b=1: K_conv
    for s=1:N_DE_blk(b)
         for n=1:N_fft(b)/2
            h_DE_L_sub(n,s,b,ch)=h_DE_L(b,n+(s-1)*N_fft(b)/2,ch);%각 band별로 
         end
    end
end
end

%left BRIR (각 band별로 variable fft size로 분리)
h_DE_R_sub=zeros(max(N_fft),max(N_DE_blk),K_conv,9);
for ch=1:9
for b=1: K_conv
    for s=1:N_DE_blk(b)
         for n=1:N_fft(b)/2
            h_DE_R_sub(n,s,b,ch)=h_DE_R(b,n+(s-1)*N_fft(b)/2,ch);
         end
    end
end
end


%% subblock of QMf input suband

L_f=length(x_sub(1,:));

for b=1:64
    N_frm(b)=max(2*L_f/N_fft(b),1);
end


N_frm=round(N_frm);
x_frame=zeros(max(N_fft),max(N_frm),K_conv);%% K_conv

for b=1: K_conv  
        for r=1:N_frm(b)
         for n=1:N_fft(b)/2
          x_frame(n,r,b)=x_sub(b,(r-1)*N_fft(b)/2+n);
         end
        end
end


%% fast convolution 

%left BRIR FFT
H_DE_L=zeros(length(h_DE_L_sub(:,1,1,1)),length(h_DE_L_sub(1,:,1,1)),length(h_DE_L_sub(1,1,:,1)),9);
for ch=1:9
for b= 1: length(h_DE_L_sub(1,1,:,1))
    for s=1: length(h_DE_L_sub(1,:,1,1))
        
            H_DE_L(1:N_fft(b),s,b,ch)=fft(h_DE_L_sub(:,s,b,ch),N_fft(b));
        
    end
end
end
%right BRIR FFT
H_DE_R=zeros(length(h_DE_R_sub(:,1,1,1)),length(h_DE_R_sub(1,:,1,1)),length(h_DE_R_sub(1,1,:,1)),9);
for ch=1:9
for b= 1: length(h_DE_R_sub(1,1,:,1))
    for s=1: length(h_DE_R_sub(1,:,1,1))
        
            H_DE_R(1:N_fft(b),s,b,ch)=fft(h_DE_R_sub(:,s,b,ch),N_fft(b));
        
    end
end
end


%input FFT

X_sub=zeros(length(x_frame(:,1,1)),length(x_frame(1,:,1)),length(x_frame(1,1,:)));
for b= 1: length(x_frame(1,1,:))
    for r=1: length(x_frame(1,:,1))
            X_sub(1:N_fft(b),r,b)=fft(x_frame(:,r,b),N_fft(b));
        
    end
end


% fast convolution 
% left
vec=zeros(1,length(H_DE_L(1,:,1,1)));
Y_DE_L=zeros(length(X_sub(:,1,1)),length(X_sub(1,:,1)),length(X_sub(1,1,:)));
Y_DE=zeros(length(X_sub(:,1,1)),length(X_sub(1,:,1)),length(X_sub(:,1,1)),9);

for ch=1:9
for b= 1 : length(X_sub(1,1,:))
    for k=1:length(X_sub(:,1,1))
        vec=zeros(1,length(H_DE_L(1,:,1,1)));
        for r =1 : length(X_sub(1,:,1))
            vec=[X_sub(k,r,b), vec(1:end-1)];
            Y_DE(k,r,b,ch) = vec * transpose(H_DE_L(k,:,b,ch));
            Y_DE_L(k,r,b)=Y_DE_L(k,r,b)+Y_DE(k,r,b,ch);
        end
   end
end

end

% right
% fast convolution 
vec=zeros(1,length(H_DE_R(1,:,1,1)));
Y_DE_R=zeros(length(X_sub(:,1,1)),length(X_sub(1,:,1)),length(X_sub(1,1,:)));
Y_DE=zeros(length(X_sub(:,1,1)),length(X_sub(1,:,1)),length(X_sub(:,1,1)),9);

for ch=1:9
for b= 1 : length(X_sub(1,1,:))
    
    for k=1:length(X_sub(:,1,1))
        vec=zeros(1,length(H_DE_R(1,:,1,1)));
        for r =1 : length(X_sub(1,:,1))
            vec=[X_sub(k,r,b), vec(1:end-1)];
            Y_DE(k,r,b,ch) = vec * transpose(H_DE_R(k,:,b,ch));
            Y_DE_R(k,r,b)=Y_DE_R(k,r,b)+Y_DE(k,r,b,ch);
        end
   end
end

end

%% IFFT
% comfirmation with synthsis

% for b=1:K_conv
%     for s=1:length(Y_DE(1,:,1))
%         y_DE_L_ifft(1:N_fft(b),s,b)=ifft(Y_DE_L(1:N_fft(b),s,b),N_fft(b));%%X_DE바꿔줘야함.
%     end
% end
% 
% for b=1:K_conv
%     for s=1:length(Y_DE(1,:,1))
%         y_DE_R_ifft(1:N_fft(b),s,b)=ifft(Y_DE_R(1:N_fft(b),s,b),N_fft(b));%%X_DE바꿔줘야함.
%     end
% end
% for b=1:K_conv
%    y_DE_L(b,1:N_fft(b)/2)=y_DE_L_ifft(1:N_fft(b)/2,1,b);
%     for s=2:length(x_frame(1,:,1))
%          y_DE_L(b,(s-1)*N_fft(b)/2+1:N_fft(b)/2*s)=y_DE_L_ifft(N_fft(b)/2+1:N_fft(b),s-1,b)+y_DE_L_ifft(1:N_fft(b)/2,s,b);
% %       y_DE_L(b,N_fft(b)/2*(s-1)+1:s*N_fft(b)/2)=y_DE_L_ifft(1:N_fft(b)/2,s,b);
%     end
% end
% for b=1:K_conv
%    y_DE_R(b,1:N_fft(b)/2)=y_DE_R_ifft(1:N_fft(b)/2,1,b);
%     for s=2:length(x_frame(1,:,1))
%          y_DE_R(b,(s-1)*N_fft(b)/2+1:N_fft(b)/2*s)=y_DE_R_ifft(N_fft(b)/2+1:N_fft(b),s-1,b)+y_DE_R_ifft(1:N_fft(b)/2,s,b);
% %       y_DE_L(b,N_fft(b)/2*(s-1)+1:s*N_fft(b)/2)=y_DE_L_ifft(1:N_fft(b)/2,s,b);
%     end
% end
% %% QMF synthesis
% 
% output_fast=synthesis_64(y_DE_R);
% 
% %% test
% load('output_E_R.mat');
% 
% output_fast1=output_fast(611:end)/2;
% out_1=output_fast1(1:end);
% out_2=output2_R(1:end);
% % time_conv=time_conv_L(1:length(output_fast1));
% dif=out_1-out_2;
% t=0:1/fs:length(output_fast1)/fs -1/fs;
% plot(t,out_1);hold on; plot(t,out_2);hold on;plot(t,dif);
% grid on;
% xlabel('time(sec)'); ylabel('amplitude');
%   axis([0 10 -2 2]);
% title('difference');

