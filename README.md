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
      * ![image](https://user-images.githubusercontent.com/86009768/135296512-36c12694-3bc9-4cdb-8b67-d3b92a3ed814.png) ![image](https://user-images.githubusercontent.com/86009768/135296543-a86cd2f8-02fc-426f-b8ff-58143cd4c88e.png) (image from [Paper : Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research])
      * The figure in (a) shows 22-channel BRIRs (early reflection~late reverberation) FDIC in the interval of 5-1000ms, and the figure in (b) shows 22-channel BRIRs (late reverberation) FDIC in the interval of 55-1000ms.
      * In the figure of (a), the coherence of each channel is large, and in the figure (b), the coherence is small.
      *  In the interval including early reflection, interaural coherence changes a lot dependent to head rotation, but in the late reverberation interval, interaural coherence appears independently of head rotation.
      * That is, early reflection is dependent on the position of the channel speaker, but late reverberation is independent to the channel speaker. Therefore, it is possible to think of a method of changing the interval of late reverberation to a modeled late reverberation with lower complexity.





