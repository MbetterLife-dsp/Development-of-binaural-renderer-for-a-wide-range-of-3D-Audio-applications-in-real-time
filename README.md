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
      ![image](https://user-images.githubusercontent.com/86009768/135446523-4bd2cca0-c543-44a4-9b91-73228c7c5746.png)
      
    * To measure the mixing time in each sub-band, the proposed method utilizes the simple EDR measure using the sub-band BRIR. 
    * Mixing time is determined using a criterion based on the EDR:
      ![image](https://user-images.githubusercontent.com/86009768/135446689-3a588838-16a5-47cb-adc0-caf809e81c61.png)
    
    * Then a pseudo-mixing time (a scalable mixing time by varying the threshold 𝑇_𝑚 ) is determined; the averaged 𝑁_𝑀𝑇(𝑏) over all channels is given by
      ![image](https://user-images.githubusercontent.com/86009768/135447008-587d8beb-24b5-4239-949f-aa511aafa6f8.png)
    
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
    ![image](https://user-images.githubusercontent.com/86009768/135449735-25239a86-f96b-4b98-9d62-95bd426b6c8a.png)
    * Expression with image
      ![image](https://user-images.githubusercontent.com/86009768/135451164-9dce2841-a067-489c-be51-9b706d84615f.png

  * To prevent discontinuity in the impulse response for impulsive sound due to the truncation between the direct sound plus early-reflections and late reverberation, a window function implementing fade-in and fade-out is utilized.
  * The window function for the direct sound plus early-reflection part is given by
    ![image](https://user-images.githubusercontent.com/86009768/135450121-e245b0ac-d80d-43a2-85ac-45affbdb78c4.png)



