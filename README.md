# Development of binaural renderer for a wide range of 3D Audio applications in real time with matlab

An implementation of Development of binaural renderer for a wide range of 3D Audio applications with matlab.

Implementation of :

* [Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research]

[research]: https://ieeexplore.ieee.org/document/7093133

# Background

To achieve high-quality, realistic, and natural 3D audio via headphones, a real-time convolution using BRIRs should be considered.

* __Block diagram of the 3D Audio Decoder__

  ![image](https://user-images.githubusercontent.com/86009768/135259018-27aad8b9-092a-4461-8338-85e6baaf198a.png)
 
  (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
  
  Mobile device cannot manage an enormous amount of operations!!
    
    --> The complexity needs to be reduced, but without any audible degradation of quality.

* __Purpose of paper__
  * Developing an efﬁcient algorithm for processing the multichannel audio signals using given BRIRs.
    * High-quality
    - Reduction of complexity 
    - Binaural rendering algorithm is required for an efﬁcient conversion of multichannel audio signals into binaural signals 

* __Method__
  * The proposed algorithm truncates binaural room impulse response at the mixing time, the transition point from the early-reﬂections part to the late reverberation. 
  * These parts are processed independently by variable order ﬁltering (VOFF) and parametric late reverberation ﬁltering (PLF).
  * A QMF domain tapped delay line (QTDL) is proposed to reduce complexity in the high-frequency band based on the human auditory perception and codec characteristics.

* __Observation of Multichannel BRIRs__
  * BRIR (Binaural Room Impulse Response)
    BRIRs also consist of the direct sound, the early-reﬂections, and the late reverberation.
    ![image](https://user-images.githubusercontent.com/86009768/135260984-87993148-5c42-4225-89b0-c5f50fc4761a.png)

    (image from [Paper : Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
    
    * Reﬂections cause time-frequency varying spectral coloration.
    * The human auditory system then recognizes the spatial characteristics of the reproduction space via this time-frequency varying spectrum. 
    * Thus, to achieve high  ﬁdelity of 3D sound, the direct sound and early-reﬂections should be accurately reproduced.
    * Late reverberation
      * FDIC (Frequency-dependent interaural coherence) : FDIC is important acoustic attribute of spatial aspects of auditory perception. 
  
        ![image](https://user-images.githubusercontent.com/86009768/135296512-36c12694-3bc9-4cdb-8b67-d3b92a3ed814.png) 
         
         (image from [Paper : Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
         
      * The figure in (a) shows 22-channel BRIRs (early reflection~late reverberation) FDIC in the interval of 5-1000ms, and the figure in (b) shows 22-channel BRIRs (late reverberation) FDIC in the interval of 55-1000ms.
      * In the figure of (a), the coherence of each channel is large, and in the figure (b), the coherence is small.
      *  In the interval including early reflection, interaural coherence changes a lot dependent to head rotation, but in the late reverberation interval, interaural coherence appears independently of head rotation.
      * That is, early reflection is dependent on the position of the channel speaker, but late reverberation is independent to the channel speaker. Therefore, it is possible to think of a method of changing the interval of late reverberation to a modeled late reverberation with lower complexity.
      * FDIC matched signal
        FDIC of each channel can be expressed as
        
        ![image](https://user-images.githubusercontent.com/86009768/136695757-ecb103dc-9a64-438d-b43e-cb328032fc16.png)
        
        cos⁡(𝛼) and sin⁡(𝛼) are determined to achieve the result that the FDIC between <img src="https://render.githubusercontent.com/render/math?math=Y_{L}^{0}(k,r,b)"> and <img src="https://render.githubusercontent.com/render/math?math=Y_{L}^{1}(k,r,b)"> is equal to the averaged FDIC. They are given by

        ![image](https://user-images.githubusercontent.com/86009768/136695811-41c5422a-543a-408b-a917-446ebbae165e.png)


* __Mixing time__

  For the independent processing of the each part of the BRIR, the direct plus early-reflections and late reverberations should be separated, which is possible by finding a transition point, generally referred to as mixing time.
  Late reverberation is independent of the location and direction. 
  For a high-quality result, It is necessary to find the mixing time for each sub-band in the QMF domain.
  
  * Multiband Mixing Time Estimation
    * To measure the mixing time in the QMF domain, the BRIRs ﬁrst need to be decomposed into the QMF domain.
    * The QMF domain sub-band BRIRs <img src="https://render.githubusercontent.com/render/math?math=h^{ij}(n,b)"> are then obtained as 
      ![image](https://user-images.githubusercontent.com/86009768/136652150-d60a4aee-0706-4c79-90fa-526c68e8e23b.png)
     
    * To measure the mixing time in each sub-band, the proposed method utilizes the simple EDR measure using the sub-band BRIR. 
    * Mixing time is determined using a criterion based on the EDR:
      ![image](https://user-images.githubusercontent.com/86009768/136387864-38f67ac8-5316-4a20-914b-bccb86046722.png)
    
    * Then a pseudo-mixing time (a scalable mixing time by varying the threshold 𝑇_𝑚 ) is determined; the averaged 𝑁_𝑀𝑇(𝑏) over all channels is given by
      
      ![image](https://user-images.githubusercontent.com/86009768/136388439-ec15bdd9-69d1-41ca-b158-53f15f2c168a.png)
    
    * <img src="https://render.githubusercontent.com/render/math?math=\hat{N}_{MT}(b)"> is used to partition the BRIRs into two parts:  the direct sound plus early-reﬂection-like and late reverberation-like.
     
      ![image](https://user-images.githubusercontent.com/86009768/135447846-171c14a5-bfc2-4a83-a4eb-4217e760fe2b.png)
      
        (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
        
        * From the 2nd band to the 37th band, the estimated pseudo-mixing time logarithmically decreases.
        * Above the 38th band, however, the mixing time is overestimated due to an insufficiently low SNR condition.
      
      ![image](https://user-images.githubusercontent.com/86009768/135448154-b75132df-cd33-4715-b95b-627fab65e662.png)
        
        
        (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])

        * Full length BRIR : BRIR --> QMF anlaysis  --> h_sub_full=h_sub( 1 : end  , 2) 
        * Partitioned direct sound plus early-reflection BRIR : BRIR --> QMF anlaysis --> h_sub_mix = h_sub( 1 : mixingtime , 2)
        * difference = h_sub_full – h_sub_mix
        
  * Curve-fitted pseudo-mixing time
    * Practical BRIRs also show that the 1st band has significantly large energy based mixing time N^MT(0). Thus, the first-band pseudo-mixing time N^MT(0) is not included in the curve fitting. The logarithmic curve-fitted pseudo-mixing time is defined as
      
      ![image](https://user-images.githubusercontent.com/86009768/136697389-5eb24bb4-bac1-4fb2-94a5-a1501c688937.png)
     
       where
     
       ![image](https://user-images.githubusercontent.com/86009768/136697400-00f6b452-7e9e-475a-bfe6-35f98d103fcf.png)


* __Variable Order Filtering in Frequency Domain (VOFF)__
  * The separated direct sound plus early-reflection parts of BRIR can have different lengths in each channel and band.
  * To implement blockwise fast convolution with a variable filter order, parameters such as FFT size and the number of BRIR blocks for each sub-band first need to be determined.
  * To perform variable order filtering, each sub-band BRIR is truncated up to 𝐿_𝑉𝑂𝐹𝐹 (𝑏), which is determined to a power of 2 to perform a radix-2 FFT, as given by
    
    ![image](https://user-images.githubusercontent.com/86009768/136412229-75e9987e-5841-4a6e-bb53-2883d90776cd.png)

      Where <img src="https://render.githubusercontent.com/render/math?math=N_{fft}^{max}(b)"> is the maximum FFT size. Then the number of blocks per band is determined as 
      
      ![image](https://user-images.githubusercontent.com/86009768/136411886-e740d9de-0525-42d6-a1e3-d2c23d521405.png)

  * To prevent discontinuity in the impulse response for impulsive sound due to the truncation between the direct sound plus early-reflections and late reverberation, a window function implementing fade-in and fade-out is utilized.
  * The window function for the direct sound plus early-reflection part is given by
    ![image](https://user-images.githubusercontent.com/86009768/136652392-c74fdcb4-985b-4dd8-8470-219ac69fa580.png)
  
     where <img src="https://render.githubusercontent.com/render/math?math=0\leq n\leq \frac{N_{fft}(b)}{2}, 0\leq b< k_{conv}, 0\leq s< N_{blk}^{DE}(b))"> and 𝑤𝑖𝑛𝑑𝑜𝑤(𝑛;𝐿) is a fade-out function with length 𝐿 such as rectangular, cosine, hanning windows, and so on.

  * The sub-band BRIRs are also partitioned into subblocks with zero-padding, as given by
    ![image](https://user-images.githubusercontent.com/86009768/136416604-679a6dd2-9e0e-4bba-af07-3127dffde5f6.png)
    
    where <img src="https://render.githubusercontent.com/render/math?math=h_{DE}^{ij}(n,b)=w(n,b) h^{ij}(n,b), 0\leq s< N_{blk}^{DE}(b), 0\leq n< K_{conv}">  and <img src="https://render.githubusercontent.com/render/math?math=0\leq n<  N_{fft}(b)">. 
    Then , to get FFT coefficients <img src="https://render.githubusercontent.com/render/math?math=H_{DE}^{ij}(k,s,b), N_{fft}(b)">𝑠𝑖𝑧𝑒 𝐹𝐹𝑇 is applied to <img src="https://render.githubusercontent.com/render/math?math=h_{DE}^{ij}(n,x,b)">.

    * Expression with image
      ![image](https://user-images.githubusercontent.com/86009768/135451427-e3efaa2f-5f9e-411e-8f12-5548dfbd01f7.png)

  * Let the frame size of the decoded audio signal be 𝐿_𝑓. If 𝑁_𝑓𝑓𝑡 (𝑏) is smaller than 𝐿_𝑓 , the input audio signal is divided into a number of subframes. The number of subframes 𝑁_𝑓𝑟𝑚 (𝑏) is then determined as
    
    ![image](https://user-images.githubusercontent.com/86009768/136418358-a48e972f-21c5-40bf-ae96-a4468d7b74a2.png)
 
 * Given a sub-band audio input <img src="https://render.githubusercontent.com/render/math?math=x_{i}(L_{f}l+n,b)"> of the 𝑙th frame, the 𝑟th subframe signal is obtained as
    
    ![image](https://user-images.githubusercontent.com/86009768/136418561-94774314-f2ab-44c2-8251-bc8ed12a0f5c.png)
   
   where 𝑟=0,1,…, 𝑁_𝑓𝑟𝑚 (𝑏)−1 𝑎𝑛𝑑 0 ≤𝑛<𝑁_𝑓𝑓𝑡 (𝑏).

 * After transforming each subframe signal using FFT, the output of the VOFF module is obtained as
    
    ![image](https://user-images.githubusercontent.com/86009768/136419815-4c1163b0-58ef-4a28-ad3f-72180a4cdfba.png) 

    where <img src="https://render.githubusercontent.com/render/math?math=X_{i}(k,r,b)"> and <img src="https://render.githubusercontent.com/render/math?math=H_{DE}^{ij}(k,s,b)"> are the FFT coefficients corresponding to <img src="https://render.githubusercontent.com/render/math?math=x_{i}(n,r,b)">  and <img src="https://render.githubusercontent.com/render/math?math=h_{DE}^{ij}(n,s,b)">. 

* Later, the output of the VOFF module <img src="https://render.githubusercontent.com/render/math?math=Y_{DE}^{j}(k,r,b)"> will be combined with the output of the PLF module before inverse FFT.

    ![image](https://user-images.githubusercontent.com/86009768/135452280-65e08ac9-83da-4757-97a0-5236fff480aa.png)
    
    (image from [Paper :Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
    
    * Expression with image 
      ![image](https://user-images.githubusercontent.com/86009768/135452732-1ffc59ec-89f6-4d6a-8b83-6297b671e843.png)

# Experiment results

* __QMF implementation__
  * SBR QMF Analysis and Synthesis
    * Analysis
      ![image](https://user-images.githubusercontent.com/86009768/135453449-454c3e2c-216f-41d6-9065-051c100baba1.png)
    
    * Synthesis
    
      ![image](https://user-images.githubusercontent.com/86009768/135453521-12716db1-e9d0-4046-ac68-b88c6bd983a5.png)
    
    * Comparison of convolution-based binaural rendering in QMF domain and convolution-based binaural rendering in time domain.
      - Convolution-based binaural rendering in QMF domain
      
        ![image](https://user-images.githubusercontent.com/86009768/136652507-12142276-2bef-487c-8012-af12e141716b.png)
        
      - Convolution-based binaural rendering in time domain
      
        ![image](https://user-images.githubusercontent.com/86009768/136652529-5fab4534-962a-45f6-b3c2-ce6fe82b249b.png)
        
      - Overlap and difference of two method (audio results in audio files folder)
        ![image](https://user-images.githubusercontent.com/86009768/136650024-4254a54c-5ff2-4cb8-994c-e8db23680b82.png)

* __Observation of Multichannel BRIRs__
  * Implementation of FDICs
    ![image](https://user-images.githubusercontent.com/86009768/136696368-2b0d6015-a218-4cd3-86d7-1359fea7760c.png)
    
      Results show the calculated FDICs, where the variance of the FDICs of truncated BRIRs is significantly lower compared with the variance of full-length BRIRs.
      It shows that when BRIRs are truncated after a certain time stamp, the measured FDICs show a consistent tendency regardless of head rotation.
      This mean that the truncated late reverberation of measured BRIR can be replaced by modeled late reverberation, e.g., white Gaussian noise.
        
* __Mixing time__
  * Measurement sub-band mixing time
    ![image](https://user-images.githubusercontent.com/86009768/135455721-711778cf-5178-44df-9bd0-0525c70c0dce.png)
    * As implemented in the paper, the estimated pseudo-mixing time from the 2nd band to the 37th band decreases logarithmically, but the mixing time is overestimated above the 38th band.

  * Setting the mixing time dependent to the threshold
    
    1. Frequency response of the full-length BRIR and frequency response of BRIR dependent to threshold.
      ![image](https://user-images.githubusercontent.com/86009768/135457786-73ef948c-84d1-44d8-a98d-315c28f5f2a1.png)
    2. Frequency response differences of the full-length BRIR and frequency response of BRIR dependent to threshold. 
      ![image](https://user-images.githubusercontent.com/86009768/135458734-bfc4bf67-0081-43cd-beee-61b353875b3f.png)
    
      * As the threshold is lowered, it can be seen that the BRIR becomes similar to the BRIR frequency response of the full length. By setting the threshold according to the actual application situation, the audio quality can be increased or the computational complexity can be reduced.

* __Variable Order Filtering in Frequency Domain (VOFF)__
    
    
  * Confirmation of VOFF implementation
    * Convolution-based binaural rendering of the direct sound plus early-reflection sub-band in QMF domain

      ![image](https://user-images.githubusercontent.com/86009768/136651807-26edcd17-935d-4da2-b898-9a9366a603e4.png)

    * VOFF

      ![image](https://user-images.githubusercontent.com/86009768/136651828-2da83d49-26b0-4bbc-babe-605719f75fb6.png)

    * Overlap and difference of two method (audio results in audio files folder)

      ![image](https://user-images.githubusercontent.com/86009768/136651870-78e561f2-1469-4173-89fc-f398ed71baf7.png)

  * Confirmation of curve fitting mixing time implementation
    * VOFF in frequnecy domain 

      ![image](https://user-images.githubusercontent.com/86009768/136651102-3f8ea55a-458e-4747-a8d3-3ca94cb147ac.png)

    * VOFF in frequency domain --> Curve fitting mixing time

      ![image](https://user-images.githubusercontent.com/86009768/136651229-1b3ec35c-4dcb-4397-bab0-56f93da6b94f.png)

    * Overlap and difference of two method (audio results in audio files folder)

      ![image](https://user-images.githubusercontent.com/86009768/136651321-c2ae95ac-8ea3-41fe-b32f-a4a4e67e4f73.png)



