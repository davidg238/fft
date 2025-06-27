import .fft show FastFourierTransform
import math show cos sin PI sqrt
import expect show *

/**
 * Comprehensive test suite for FastFourierTransform class
 * Tests mathematical correctness, edge cases, and error handling
 */

// Helper function to get absolute value
abs value/float -> float:
  return value < 0.0 ? -value : value

// Helper function to compare floating point numbers with tolerance
equals-within-tolerance a/float b/float tolerance/float=1e-10 -> bool:
  diff := a - b
  return (abs diff) < tolerance

// Helper function to compare complex numbers (magnitude)
complex-magnitude real/float imag/float -> float:
  return sqrt (real * real + imag * imag)

// Helper function to generate a sine wave signal
generate-sine-wave size/int frequency/int amplitude/float=1.0 -> List:
  signal := List size 0.0
  twopi := 2.0 * PI
  for i := 0; i < size; i++:
    signal[i] = amplitude * (sin twopi * frequency.to-float * i.to-float / size.to-float)
  return signal

// Helper function to generate a cosine wave signal
generate-cosine-wave size/int frequency/int amplitude/float=1.0 -> List:
  signal := List size 0.0
  twopi := 2.0 * PI
  for i := 0; i < size; i++:
    signal[i] = amplitude * (cos twopi * frequency.to-float * i.to-float / size.to-float)
  return signal

// Helper function to check if a number is a power of 2
is-power-of-2 n/int -> bool:
  return n > 0 and (n & (n - 1)) == 0

main:
  test-constructor
  test-power-of-2-validation
  test-basic-fft-properties
  test-dc-component
  test-impulse-response
  test-single-frequency-sine
  test-single-frequency-cosine
  test-multiple-frequencies
  test-power-spectrum
  test-linearity
  test-energy-conservation
  test-edge-cases
  test-symmetry-properties
  test-parseval-theorem
  test-scaling-properties
  print "All FFT tests passed! ✓"

test-constructor:
  print "Testing constructor..."
  
  // Test with simple signal
  signal := [1.0, 2.0, 3.0, 4.0]
  fft := FastFourierTransform signal
  
  expect-equals signal.size fft.real.size
  expect-equals signal.size fft.imag.size
  
  // Verify real part is copied correctly (not a reference)
  for i := 0; i < signal.size; i++:
    expect-equals signal[i] fft.real[i]
  
  // Verify imaginary part is initialized to zero
  for i := 0; i < fft.imag.size; i++:
    expect-equals 0.0 fft.imag[i]
  
  // Verify modifying original doesn't affect FFT instance
  signal[0] = 99.0
  expect-not-equals 99.0 fft.real[0]
  
  print "  Constructor tests passed ✓"

test-power-of-2-validation:
  print "Testing power-of-2 validation..."
  
  // Test valid power-of-2 sizes
  valid-sizes := [2, 4, 8, 16, 32, 64, 128, 256]
  valid-sizes.do: | size |
    signal := List size 1.0
    fft := FastFourierTransform signal
    // Should not throw exception
    result := fft.forward-real
    expect-equals size result.size
  
  // Test invalid sizes (not power of 2 or too small)
  invalid-sizes := [0, 1, 3, 5, 6, 7, 9, 10, 12, 15, 17, 20, 100]
  invalid-sizes.do: | size |
    signal := List size 1.0
    fft := FastFourierTransform signal
    expect-throw "FFT size must be a power of 2":
      fft.forward-real
  
  print "  Power-of-2 validation tests passed ✓"

test-basic-fft-properties:
  print "Testing basic FFT properties..."
  
  // Test that forward FFT returns imaginary components
  signal := [1.0, 0.0, 1.0, 0.0]
  fft := FastFourierTransform signal
  imag-result := fft.forward-real
  
  // Result should be a list of the same size
  expect-equals signal.size imag-result.size
  
  // After FFT, both real and imaginary parts should exist
  expect-equals signal.size fft.real.size
  expect-equals signal.size fft.imag.size
  
  // Test repeatability - same input should give same output
  fft2 := FastFourierTransform signal
  fft2.forward-real
  
  for i := 0; i < signal.size; i++:
    expect (equals-within-tolerance fft.real[i] fft2.real[i] 1e-12)
    expect (equals-within-tolerance fft.imag[i] fft2.imag[i] 1e-12)
  
  print "  Basic FFT properties tests passed ✓"

test-dc-component:
  print "Testing DC component..."
  
  // Test pure DC signal (all samples are the same value)
  dc-value := 3.0
  signal := List 8 dc-value
  fft := FastFourierTransform signal
  fft.forward-real
  
  // For pure DC, the first bin should contain all the energy
  expected-dc := dc-value * signal.size
  expect (equals-within-tolerance fft.real[0] expected-dc 1e-9)
  expect (equals-within-tolerance fft.imag[0] 0.0 1e-9)
  
  // All other bins should be zero
  for i := 1; i < signal.size; i++:
    expect (equals-within-tolerance fft.real[i] 0.0 1e-9)
    expect (equals-within-tolerance fft.imag[i] 0.0 1e-9)
  
  print "  DC component tests passed ✓"

test-impulse-response:
  print "Testing impulse response..."
  
  // Test impulse at beginning
  impulse := [1.0, 0.0, 0.0, 0.0]
  fft := FastFourierTransform impulse
  fft.forward-real
  
  // Impulse should produce flat spectrum (all frequency bins equal)
  for i := 0; i < impulse.size; i++:
    expect (equals-within-tolerance fft.real[i] 1.0 1e-9)
    expect (equals-within-tolerance fft.imag[i] 0.0 1e-9)
  
  // Test impulse at different position
  impulse2 := [0.0, 1.0, 0.0, 0.0]
  fft2 := FastFourierTransform impulse2
  fft2.forward-real
  
  // Should have different phase but same magnitude
  for i := 0; i < impulse2.size; i++:
    magnitude := complex-magnitude fft2.real[i] fft2.imag[i]
    expect (equals-within-tolerance magnitude 1.0 1e-9)
  
  print "  Impulse response tests passed ✓"

test-single-frequency-sine:
  print "Testing single frequency sine wave..."
  
  size := 16
  frequency := 2  // 2 cycles in the signal
  amplitude := 1.0
  
  signal := generate-sine-wave size frequency amplitude
  fft := FastFourierTransform signal
  fft.forward-real
  
  // For a pure sine wave, energy should be concentrated at frequency bins
  frequency-bin := frequency
  negative-frequency-bin := size - frequency
  
  // Check that the energy is concentrated at the right frequencies
  magnitude-at-freq := complex-magnitude fft.real[frequency-bin] fft.imag[frequency-bin]
  magnitude-at-neg-freq := complex-magnitude fft.real[negative-frequency-bin] fft.imag[negative-frequency-bin]
  
  // Both should have significant magnitude (sine wave has antisymmetric spectrum)
  expect (magnitude-at-freq > size / 4.0)  // Should be around size/2
  expect (magnitude-at-neg-freq > size / 4.0)
  
  // DC component should be near zero
  expect (equals-within-tolerance fft.real[0] 0.0 1e-9)
  
  // Other frequency bins should be near zero
  for i := 1; i < size; i++:
    if i != frequency and i != negative-frequency-bin:
      magnitude := complex-magnitude fft.real[i] fft.imag[i]
      expect (magnitude < 1e-9)
  
  print "  Single frequency sine wave tests passed ✓"

test-single-frequency-cosine:
  print "Testing single frequency cosine wave..."
  
  size := 16
  frequency := 2
  amplitude := 1.0
  
  signal := generate-cosine-wave size frequency amplitude
  fft := FastFourierTransform signal
  fft.forward-real
  
  // For a pure cosine wave, energy should be in real parts at frequency bins
  frequency-bin := frequency
  negative-frequency-bin := size - frequency
  
  // Check that the energy is concentrated at the right frequencies
  expect ((abs fft.real[frequency-bin]) > size / 4.0)
  expect ((abs fft.real[negative-frequency-bin]) > size / 4.0)
  
  // Imaginary parts at frequency should be near zero for cosine
  expect (equals-within-tolerance fft.imag[frequency-bin] 0.0 1e-9)
  expect (equals-within-tolerance fft.imag[negative-frequency-bin] 0.0 1e-9)
  
  // DC component should be near zero
  expect (equals-within-tolerance fft.real[0] 0.0 1e-9)
  
  print "  Single frequency cosine wave tests passed ✓"

test-multiple-frequencies:
  print "Testing multiple frequencies..."
  
  size := 32
  freq1 := 2
  freq2 := 5
  amplitude1 := 1.0
  amplitude2 := 0.5
  
  // Create signal with two frequency components
  signal := List size 0.0
  twopi := 2.0 * PI
  for i := 0; i < size; i++:
    signal[i] = amplitude1 * (cos twopi * freq1.to-float * i.to-float / size.to-float) +
                amplitude2 * (sin twopi * freq2.to-float * i.to-float / size.to-float)
  
  fft := FastFourierTransform signal
  fft.forward-real
  
  // Check that energy appears at both frequencies
  magnitude-freq1 := complex-magnitude fft.real[freq1] fft.imag[freq1]
  magnitude-freq2 := complex-magnitude fft.real[freq2] fft.imag[freq2]
  
  expect (magnitude-freq1 > size / 8.0)  // Should be around amplitude1*size/2
  expect (magnitude-freq2 > size / 16.0) // Should be around amplitude2*size/2
  
  // Check negative frequency components
  magnitude-neg-freq1 := complex-magnitude fft.real[size - freq1] fft.imag[size - freq1]
  magnitude-neg-freq2 := complex-magnitude fft.real[size - freq2] fft.imag[size - freq2]
  
  expect (magnitude-neg-freq1 > size / 8.0)
  expect (magnitude-neg-freq2 > size / 16.0)
  
  print "  Multiple frequencies tests passed ✓"

test-power-spectrum:
  print "Testing power spectrum calculation..."
  
  size := 16
  frequency := 2
  amplitude := 1.0
  
  signal := generate-cosine-wave size frequency amplitude
  fft := FastFourierTransform signal
  
  // Test power spectrum methods
  power-spectrum := fft.forward-real-power
  expect-equals size power-spectrum.size
  
  // Power spectrum should be non-negative
  power-spectrum.do: | power |
    expect (power >= 0.0)
  
  // Test normalized power spectrum
  power-normalized := fft.forward-real-power-normalised_ 1.0
  expect-equals size power-normalized.size
  
  power-normalized.do: | power |
    expect (power >= 0.0)
  
  // For a single frequency, power should be concentrated at that frequency
  max-power := 0.0
  max-index := 0
  for i := 0; i < power-spectrum.size; i++:
    if power-spectrum[i] > max-power:
      max-power = power-spectrum[i]
      max-index = i
  
  // Maximum should be at the expected frequency or its alias
  expect (max-index == frequency or max-index == (size - frequency))
  
  print "  Power spectrum tests passed ✓"

test-linearity:
  print "Testing linearity property..."
  
  size := 16
  signal1 := generate-cosine-wave size 2 1.0
  signal2 := generate-sine-wave size 3 0.5
  
  // Test FFT(a*x + b*y) = a*FFT(x) + b*FFT(y)
  a := 2.0
  b := 3.0
  
  // Create combined signal
  combined-signal := List size 0.0
  for i := 0; i < size; i++:
    combined-signal[i] = a * signal1[i] + b * signal2[i]
  
  // FFT of combined signal
  fft-combined := FastFourierTransform combined-signal
  fft-combined.forward-real
  
  // FFT of individual signals
  fft1 := FastFourierTransform signal1
  fft1.forward-real
  
  fft2 := FastFourierTransform signal2
  fft2.forward-real
  
  // Check linearity: FFT(a*x + b*y) should equal a*FFT(x) + b*FFT(y)
  tolerance := 1e-10
  for i := 0; i < size; i++:
    expected-real := a * fft1.real[i] + b * fft2.real[i]
    expected-imag := a * fft1.imag[i] + b * fft2.imag[i]
    
    expect (equals-within-tolerance fft-combined.real[i] expected-real tolerance)
    expect (equals-within-tolerance fft-combined.imag[i] expected-imag tolerance)
  
  print "  Linearity tests passed ✓"

test-energy-conservation:
  print "Testing energy conservation (Parseval's theorem)..."
  
  size := 16
  signal := generate-cosine-wave size 2 1.0
  
  // Calculate time domain energy
  time-energy := 0.0
  signal.do: | sample |
    time-energy += sample * sample
  
  fft := FastFourierTransform signal
  fft.forward-real
  
  // Calculate frequency domain energy
  freq-energy := 0.0
  for i := 0; i < size; i++:
    freq-energy += fft.real[i] * fft.real[i] + fft.imag[i] * fft.imag[i]
  
  // Normalize frequency domain energy (Parseval's theorem)
  freq-energy /= size.to-float
  
  // They should be approximately equal
  tolerance := 1e-10
  expect (equals-within-tolerance time-energy freq-energy tolerance)
  
  print "  Energy conservation tests passed ✓"

test-edge-cases:
  print "Testing edge cases..."
  
  // Test minimum size (2 samples)
  signal2 := [1.0, -1.0]
  fft2 := FastFourierTransform signal2
  result2 := fft2.forward-real
  expect-equals 2 fft2.real.size
  expect-equals 2 fft2.imag.size
  expect-equals 2 result2.size
  
  // Test with all zeros
  zeros := List 8 0.0
  fft-zeros := FastFourierTransform zeros
  fft-zeros.forward-real
  
  // All outputs should be zero
  for i := 0; i < 8; i++:
    expect-equals 0.0 fft-zeros.real[i]
    expect-equals 0.0 fft-zeros.imag[i]
  
  // Test alternating pattern
  alternating := [1.0, -1.0, 1.0, -1.0]
  fft-alt := FastFourierTransform alternating
  fft-alt.forward-real
  
  // Should have energy at Nyquist frequency
  expect ((abs fft-alt.real[2]) > 1.0)  // Nyquist bin
  
  print "  Edge cases tests passed ✓"

test-symmetry-properties:
  print "Testing symmetry properties for real signals..."
  
  size := 8
  signal := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
  fft := FastFourierTransform signal
  fft.forward-real
  
  // For real input signals, the FFT should have Hermitian symmetry:
  // X[k] = X*[N-k] where * denotes complex conjugate
  tolerance := 1e-12
  
  for k := 1; k < size / 2; k++:
    k-complement := size - k
    
    // Real parts should be equal: Re(X[k]) = Re(X[N-k])
    expect (equals-within-tolerance fft.real[k] fft.real[k-complement] tolerance)
    
    // Imaginary parts should be opposite: Im(X[k]) = -Im(X[N-k])
    expect (equals-within-tolerance fft.imag[k] (-fft.imag[k-complement]) tolerance)
  
  // DC and Nyquist bins should have zero imaginary parts
  expect (equals-within-tolerance fft.imag[0] 0.0 tolerance)  // DC
  expect (equals-within-tolerance fft.imag[size/2] 0.0 tolerance)  // Nyquist
  
  print "  Symmetry properties tests passed ✓"

test-parseval-theorem:
  print "Testing Parseval's theorem (detailed)..."
  
  // Test with various signals
  test-signals := [
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
    generate-sine-wave 16 3 2.0,
    generate-cosine-wave 8 1 1.5,
    [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]  // Impulse
  ]
  
  test-signals.do: | signal |
    // Time domain energy
    time-energy := 0.0
    signal.do: | sample |
      time-energy += sample * sample
    
    // Frequency domain energy
    fft := FastFourierTransform signal
    fft.forward-real
    
    freq-energy := 0.0
    for i := 0; i < signal.size; i++:
      freq-energy += fft.real[i] * fft.real[i] + fft.imag[i] * fft.imag[i]
    freq-energy /= signal.size.to-float
    
    expect (equals-within-tolerance time-energy freq-energy 1e-10)
  
  print "  Parseval's theorem tests passed ✓"

test-scaling-properties:
  print "Testing scaling properties..."
  
  size := 8
  original := [1.0, 2.0, 1.0, 0.5, 1.0, 2.0, 1.0, 0.5]
  scale := 3.0
  
  // Create scaled version
  scaled := List size: original[it] * scale
  
  // Compute FFTs
  fft-original := FastFourierTransform original
  fft-original.forward-real
  
  fft-scaled := FastFourierTransform scaled
  fft-scaled.forward-real
  
  // FFT of scaled signal should be scaled FFT
  tolerance := 1e-12
  for i := 0; i < size; i++:
    expect (equals-within-tolerance fft-scaled.real[i] (scale * fft-original.real[i]) tolerance)
    expect (equals-within-tolerance fft-scaled.imag[i] (scale * fft-original.imag[i]) tolerance)
  
<<<<<<< Updated upstream
  print "  Scaling properties tests passed ✓"
=======
  print "  Scaling properties tests passed ✓"
>>>>>>> Stashed changes
