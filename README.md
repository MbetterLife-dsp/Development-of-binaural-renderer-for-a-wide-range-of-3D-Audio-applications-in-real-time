# Development of binaural renderer for a wide range of 3D Audio applications in real time with matlab

An implementation of Development of binaural renderer for a wide range of 3D Audio applications with matlab.

Implementation of :

* [Scalable Multiband Binaural Renderer for MPEG-H 3D Audio][research]

[research]: https://ieeexplore.ieee.org/document/7093133

# Background

To achieve high-quality, realistic, and natural 3D audio via headphones, a real-time convolution using BRIRs should be considered.

* Block diagram of the 3D Audio Decoder

  ![image](https://user-images.githubusercontent.com/86009768/135259018-27aad8b9-092a-4461-8338-85e6baaf198a.png)
  
  Mobile device cannot manage an enormous amount of operations!!
    
    --> The complexity needs to be reduced, but without any audible degradation of quality.

* Purpose of paper
  * Developing an efﬁcient algorithm for processing the multichannel audio signals using given BRIRs.
    * High-quality
    - Reduction of complexity 
    - Binaural rendering algorithm is required for an efﬁcient conversion of multichannel audio signals into binaural signals 

