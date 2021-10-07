function w=window_sub(N_DE_blk,K_conv,N_fft,N_blk)
N_DE_blk=ceil(N_DE_blk);

for b=1: K_conv
   for s=1:N_blk(b)
        for n=1:N_fft(b)/2
            if s<N_DE_blk(b)
            w(b,n+(s-1)*N_fft(b)/2)= 1;
            elseif s==N_DE_blk(b)
                nn=N_fft(b)/2;
                t=1/nn:1/nn:1;
                fade_out=cos(pi/2*t);
            w(b,n+(s-1)*N_fft(b)/2)= fade_out(n) ;
            else 
                w(b,n+(s-1)*N_fft(b)/2)=0;
            end
        end
    end
end