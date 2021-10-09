# Development of binaural renderer for a wide range of 3D Audio applications in real time with matlab

An implementation of Development of binaural renderer for a wide range of 3D Audio applications with matlab.

Implementation of :

* [Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research]

[research]: https://ieeexplore.ieee.org/document/7093133

# Background

To achieve high-quality, realistic, and natural 3D audio via headphones, a real-time convolution using BRIRs should be considered.

* Block diagram of the 3D Audio Decoder

  ![image](https://user-images.githubusercontent.com/86009768/135259018-27aad8b9-092a-4461-8338-85e6baaf198a.png)
 
  (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
  
  Mobile device cannot manage an enormous amount of operations!!
    
    --> The complexity needs to be reduced, but without any audible degradation of quality.

* Purpose of paper
  * Developing an efﬁcient algorithm for processing the multichannel audio signals using given BRIRs.
    * High-quality
    - Reduction of complexity 
    - Binaural rendering algorithm is required for an efﬁcient conversion of multichannel audio signals into binaural signals 

* Method 
  * The proposed algorithm truncates binaural room impulse response at the mixing time, the transition point from the early-reﬂections part to the late reverberation. 
  * These parts are processed independently by variable order ﬁltering (VOFF) and parametric late reverberation ﬁltering (PLF).
  * A QMF domain tapped delay line (QTDL) is proposed to reduce complexity in the high-frequency band based on the human auditory perception and codec characteristics.

* Observation of Multichannel BRIRs
  * BRIR (Binaural Room Impulse Response)
    BRIRs also consist of the direct sound, the early-reﬂections, and the late reverberation.
    ![image](https://user-images.githubusercontent.com/86009768/135260984-87993148-5c42-4225-89b0-c5f50fc4761a.png)

    (image from [Paper : Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
    
    * Reﬂections cause time-frequency varying spectral coloration.
    * The human auditory system then recognizes the spatial characteristics of the reproduction space via this time-frequency varying spectrum. 
    * Thus, to achieve high  ﬁdelity of 3D sound, the direct sound and early-reﬂections should be accurately reproduced.
    * Late reverberation
        
        ![image](https://user-images.githubusercontent.com/86009768/135296512-36c12694-3bc9-4cdb-8b67-d3b92a3ed814.png) 
         
         (image from [Paper : Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
         
      * The figure in (a) shows 22-channel BRIRs (early reflection~late reverberation) FDIC in the interval of 5-1000ms, and the figure in (b) shows 22-channel BRIRs (late reverberation) FDIC in the interval of 55-1000ms.
      * In the figure of (a), the coherence of each channel is large, and in the figure (b), the coherence is small.
      *  In the interval including early reflection, interaural coherence changes a lot dependent to head rotation, but in the late reverberation interval, interaural coherence appears independently of head rotation.
      * That is, early reflection is dependent on the position of the channel speaker, but late reverberation is independent to the channel speaker. Therefore, it is possible to think of a method of changing the interval of late reverberation to a modeled late reverberation with lower complexity.

* Mixing time
  For the independent processing of the each part of the BRIR, the direct plus early-reflections and late reverberations should be separated, which is possible by finding a transition point, generally referred to as mixing time.
  Late reverberation is independent of the location and direction. 
  For a high-quality result, It is necessary to find the mixing time for each sub-band in the QMF domain.
  
  * Multiband Mixing Time Estimation
    * To measure the mixing time in the QMF domain, the BRIRs ﬁrst need to be decomposed into the QMF domain.
    * The QMF domain sub-band BRIRs ℎ^𝑖𝑗 (𝑛,𝑏) are then obtained as 
      ![image](https://user-images.githubusercontent.com/86009768/136388037-a589ba77-7573-4fa9-9a9b-79eb672adfb4.png)
     
    * To measure the mixing time in each sub-band, the proposed method utilizes the simple EDR measure using the sub-band BRIR. 
    * Mixing time is determined using a criterion based on the EDR:
      ![image](https://user-images.githubusercontent.com/86009768/136387864-38f67ac8-5316-4a20-914b-bccb86046722.png)
    
    * Then a pseudo-mixing time (a scalable mixing time by varying the threshold 𝑇_𝑚 ) is determined; the averaged 𝑁_𝑀𝑇(𝑏) over all channels is given by
      
      ![image](https://user-images.githubusercontent.com/86009768/136388439-ec15bdd9-69d1-41ca-b158-53f15f2c168a.png)
    
    * ^𝑁_𝑀𝑇 (𝑏) is used to partition the BRIRs into two parts:  the direct sound plus early-reﬂection-like and late reverberation-like.
     
      ![image](https://user-images.githubusercontent.com/86009768/135447846-171c14a5-bfc2-4a83-a4eb-4217e760fe2b.png)
      
        (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
        
        * From the 2nd band to the 37th band, the estimated pseudo-mixing time logarithmically decreases.
        * Above the 38th band, however, the mixing time is overestimated due to an insufficiently low SNR condition.
      
      ![image](https://user-images.githubusercontent.com/86009768/135448154-b75132df-cd33-4715-b95b-627fab65e662.png)
        
        
        (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])

        * Full length BRIR : BRIR --> QMF anlaysis  --> h_sub_full=h_sub( 1 : end  , 2) 
        * Partitioned direct sound plus early-reflection BRIR : BRIR --> QMF anlaysis --> h_sub_mix = h_sub( 1 : mixingtime , 2)
        * difference = h_sub_full – h_sub_mix

* Variable Order Filtering in Frequency Domain (VOFF)
  * The separated direct sound plus early-reflection parts of BRIR can have different lengths in each channel and band.
  * To implement blockwise fast convolution with a variable filter order, parameters such as FFT size and the number of BRIR blocks for each sub-band first need to be determined.
  * To perform variable order filtering, each sub-band BRIR is truncated up to 𝐿_𝑉𝑂𝐹𝐹 (𝑏), which is determined to a power of 2 to perform a radix-2 FFT, as given by
    
    ![image](https://user-images.githubusercontent.com/86009768/136412229-75e9987e-5841-4a6e-bb53-2883d90776cd.png)

      Where 𝑁_𝑓𝑓𝑡^max (𝑏) is the maximum FFT size. Then the number of blocks per band is determined as 
      
      ![image](https://user-images.githubusercontent.com/86009768/136411886-e740d9de-0525-42d6-a1e3-d2c23d521405.png)

  * To prevent discontinuity in the impulse response for impulsive sound due to the truncation between the direct sound plus early-reflections and late reverberation, a window function implementing fade-in and fade-out is utilized.
  * The window function for the direct sound plus early-reflection part is given by
    ![image](https://user-images.githubusercontent.com/86009768/136415685-0eb382f7-3d9c-48c4-9d8e-b9807b332286.png)
  
     where 0≤𝑛 <(𝑁_𝑓𝑓𝑡 (𝑏))/2,0 ≤𝑏<𝐾_(𝑐𝑜𝑛𝑣, ) 0 ≤  𝑠 <𝑁_𝑏𝑙𝑘^𝐷𝐸 (𝑏) and 𝑤𝑖𝑛𝑑𝑜𝑤(𝑛;𝐿) is a fade-out function with length 𝐿 such as rectangular, cosine, hanning windows, and so on.

  * The sub-band BRIRs are also partitioned into subblocks with zero-padding, as given by
    ![image](https://user-images.githubusercontent.com/86009768/136416604-679a6dd2-9e0e-4bba-af07-3127dffde5f6.png)
    
    where ℎ_𝐷𝐸^𝑖𝑗 (𝑛,𝑏)=𝑤(𝑛,𝑏) ℎ^𝑖𝑗 (𝑛,𝑏),0≤𝑠<𝑁_𝑏𝑙𝑘^𝐷𝐸 (𝑏),  0≤𝑏<𝐾_𝑐𝑜𝑛𝑣  and 0 ≤𝑛<𝑁_𝑓𝑓𝑡 (𝑏). 
    Then , to get FFT coefficients 𝐻_𝐷𝐸^𝑖𝑗 (𝑘,𝑠,𝑏), a 𝑁_𝑓𝑓𝑡 (𝑏)𝑠𝑖𝑧𝑒 𝐹𝐹𝑇 is applied to ℎ_𝐷𝐸^𝑖𝑗 (𝑛,𝑥,𝑏).

    * Expression with image
      ![image](https://user-images.githubusercontent.com/86009768/135451427-e3efaa2f-5f9e-411e-8f12-5548dfbd01f7.png)

  * Let the frame size of the decoded audio signal be 𝐿_𝑓. If 𝑁_𝑓𝑓𝑡 (𝑏) is smaller than 𝐿_𝑓 , the input audio signal is divided into a number of subframes. The number of subframes 𝑁_𝑓𝑟𝑚 (𝑏) is then determined as
    
    ![image](https://user-images.githubusercontent.com/86009768/136418358-a48e972f-21c5-40bf-ae96-a4468d7b74a2.png)
 
 * Given a sub-band audio input 𝑥_𝑖 (𝐿_𝑓 𝑙+𝑛, 𝑏) of the 𝑙th frame, the 𝑟th subframe signal is obtained as
    
    ![image](https://user-images.githubusercontent.com/86009768/136418561-94774314-f2ab-44c2-8251-bc8ed12a0f5c.png)
   
   where 𝑟=0,1,…, 𝑁_𝑓𝑟𝑚 (𝑏)−1 𝑎𝑛𝑑 0 ≤𝑛<𝑁_𝑓𝑓𝑡 (𝑏).

 * After transforming each subframe signal using FFT, the output of the VOFF module is obtained as
    
    ![image](https://user-images.githubusercontent.com/86009768/136419815-4c1163b0-58ef-4a28-ad3f-72180a4cdfba.png) 

    where 𝑋_𝑖 (𝑘,𝑟,𝑏) and 𝐻_𝐷𝐸^𝑖𝑗 (𝑘,𝑠,𝑏) are the FFT coefficients corresponding to 𝑥_𝑖 (𝑛,𝑟,𝑏)  and ℎ_𝐷𝐸^𝑖𝑗 (𝑛,𝑠,𝑏). 

* Later, the output of the VOFF module 𝑌_𝐷𝐸^𝑗 (𝑘,𝑟,𝑏) will be combined with the output of the PLF module before inverse FFT.

    ![image](https://user-images.githubusercontent.com/86009768/135452280-65e08ac9-83da-4757-97a0-5236fff480aa.png)
    
    (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
    
    * Expression with image 
      ![image](https://user-images.githubusercontent.com/86009768/135452732-1ffc59ec-89f6-4d6a-8b83-6297b671e843.png)

# Experiment results

* QMF implementation
  * SBR QMF Analysis and Synthesis
    * Analysis
      ![image](https://user-images.githubusercontent.com/86009768/135453449-454c3e2c-216f-41d6-9065-051c100baba1.png)
    
    * Synthesis
      ![image](https://user-images.githubusercontent.com/86009768/135453521-12716db1-e9d0-4046-ac68-b88c6bd983a5.png)
    
    * Comparison of convolution-based binaural rendering in QMF domain and convolution-based binaural rendering in time domain.
      ![image](https://user-images.githubusercontent.com/86009768/135454391-3bd3894c-d310-49ea-9bdb-13f2e70e5441.png)

* Mixing time
  * Measurement sub-band mixing time
    ![image](https://user-images.githubusercontent.com/86009768/135455721-711778cf-5178-44df-9bd0-0525c70c0dce.png)
    * As implemented in the paper, the estimated pseudo-mixing time from the 2nd band to the 37th band decreases logarithmically, but the mixing time is overestimated above the 38th band.

  * Setting the mixing time dependent to the threshold
    
    1. Frequency response of the full-length BRIR and frequency response of BRIR dependent to threshold.
      ![image](https://user-images.githubusercontent.com/86009768/135457786-73ef948c-84d1-44d8-a98d-315c28f5f2a1.png)
    2. Frequency response differences of the full-length BRIR and frequency response of BRIR dependent to threshold. 
      ![image](https://user-images.githubusercontent.com/86009768/135458734-bfc4bf67-0081-43cd-beee-61b353875b3f.png)
    
      * As the threshold is lowered, it can be seen that the BRIR becomes similar to the BRIR frequency response of the full length. By setting the threshold according to the actual application situation, the audio quality can be increased or the computational complexity can be reduced.

