import math show PI cos sin log

class FastFourierTransform:

  real/ List
  imag/ List

  constructor signal/ List:
    real = signal
    imag = List signal.size 0.0

  forward-real:
    n := real.size
    if (n & (n - 1)) != 0:
      throw "FFT size must be a power of 2"

    nm1 := n - 1
    nd2 := n >> 1  // n // 2
    p := nd2

    // --- Bit reversal permutation ---
    for i := 1; i < (nm1 - 1); i++:
      if i < p:
        // Swap real parts
        tr := real[p]
        real[p] = real[i]
        real[i] = tr
        // Swap imag parts (all zero initially)
        ti := imag[p]
        imag[p] = imag[i]
        imag[i] = ti

      k := nd2
      while k <= p:
        p -= k
        k >>= 1
      p += k

    // --- Cooley-Tukey FFT ---
    m := ((log n.to-float) / (log 2.0)).round

    for l := 1; l < m; l++:
      le := 1 << l
      le2 := le >> 1
      ur := 1.0
      ui := 0.0
      sr :=  cos (PI / le2.to-float)
      si :=  -(sin (PI / le2.to-float))

      for j := 0; j < (le2 - 1); j++:
        for i := j; i < nm1; i +=le :
          ip := i + le2
          tr := real[ip] * ur - imag[ip] * ui
          ti := real[ip] * ui + imag[ip] * ur

          real[ip] = real[i] - tr
          imag[ip] = imag[i] - ti

          real[i] += tr
          imag[i] += ti

        // Rotate twiddle factors
        tr := ur
        ur = tr * sr - ui * si
        ui = tr * si + ui * sr
    
    return imag


  forward-real-power-normalised_ n/float -> List:
    imaginary := forward-real
    for k := 0; k < real.size; k++ :
        r := real[k]
        i := imag[k]
        real[k] = n * (r * r + i * i)	 // linear power = magnitude squared
    return real

  forward-real-power -> List:
    num := 2.0 / real.size.to-float
    return forward-real-power-normalised_ num * num



    /*
class FastFourierTransform:
/*
Fast Fourier Transform (FFT) algorithms for arrays of real numbers.
The algorithms are based on the Cooley-Tukey algorithm for FFTs of real numbers, which is a divide-and-conquer algorithm 
that recursively breaks down a DFT into smaller DFTs. The implementation here is designed for arrays whose size is a power of two.
The algorithms provided here include:
- `fftForwardReal`: Computes the FFT of a real-valued array in-place, returning the imaginary parts in a separate array.
- `fftForwardRealPowerNormalised`: Computes the power spectrum of the real-valued array, normalised by the size of the array.
- `fftForwardRealPower`: Computes the power spectrum of the real-valued array, scaled by a factor of 2/N^2, where N is the size of the array.
The algorithms assume that the input array is of size N, where N is a power of two. If the size is not a power of two, an error is raised.
The algorithms are efficient and suitable for real-time signal processing applications, such as audio processing or communications systems."
*/
  real/List
  imag/ List

  constructor .real/List:
    imag = List real.size 0.0

  forward-real_ -> List:
      n := real.size
      if not ((n & n - 1) == 0):
        throw "FFT size is not a power of 2"
      
      nm1   := n - 1
      nd2   := n / 2
      j     := nd2
      " reorder input samples for an in-place FFT [1] "
      1 to: nm1 - 1 do: [ :i |
          | k |
          i < j ifTrue: [
              | tr "ti" |                         "the imaginary parts are all zero: ignore them"
              tr := self at: j.                   "ti := imag at: j."
              self at: j put: (self at: i).       "imag at: j put: (imag at: i)."
              self at: i put: tr.                 "imag at: i put: ti."
          ].
          k := nd2.
          [k <= j] whileTrue: [
              j := j - k.
              k := k // 2.
          ].
          j := j + k.
      ].
      " recombine N 1-point spectra into a single N-point spectrum [2] "
      pi := Float pi.
      m  := (n asFloat log / 2.0 log) rounded.
      1 to: m do: [ :l |                          "for each power-of-two recombination stage"
          | le le2 ur ui sr si |
          le    := 1 << l.
          le2   := le // 2.
          ur := 1.0.
          ui := 0.0.
          sr := (pi / le2 asFloat) cos.
          si := (pi / le2 asFloat) sin negated.
          1 to: le2 do: [ :j |                    "for each sub-DFT in the stage"
              | jm1 tr |
              jm1 := j - 1.
              jm1 by: le to: nm1 do: [ :i |       "for each recombined pair"
                  | ip tr ti |
                  ip := i + le2.
                  tr := ((self at: ip) * ur) - ((imag at: ip) * ui).
                  ti := ((self at: ip) * ui) + ((imag at: ip) * ur).
                  self at: ip put: (self at: i) - tr.
                  imag at: ip put: (imag at: i) - ti.
                  self at: i  put: (self at: i) + tr.
                  imag at: i  put: (imag at: i) + ti.
              ].
              tr := ur.
              ur := (tr * sr) - (ui * si).
              ui := (tr * si) + (ui * sr).
          ].
      " receiver contains the cosine correlations; answer the sine correlations "
      return imag
*/