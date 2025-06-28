import .fft show FastFourierTransform
import math show cos sin PI
import core.print show write-on-stdout_

/*
Plot the contents of the signal between start and stop, with vertical scale between lo and hi.
For each value run aBlock with three arguments: 
 - the value
 - min and max limits of the current vertical bin in the plot.  
A point is plotted in each bin for which aBlock answers true.
*/
graph signal --from --to --label alambda:
  lo := from.to-float
  hi := to.to-float
  dy := (hi - lo) / 16.0
  dyd2 := dy / 2.0
  for y := hi; y >= lo; y -= dy:
    write-on-stdout_ "$(%8.3f y)".stringify false
    write-on-stdout_ " |".stringify false
    z := 0.0 >= y - dyd2 and 0.0 <= y + dyd2
    c := z? "-" : " "
    for v := 0; v < signal.size; v++:
      if (alambda.call signal[v] y - dyd2 y + dyd2):
        write-on-stdout_ "*".stringify false
      else:
        write-on-stdout_ c.stringify false
    if z:
      write-on-stdout_ " ".stringify false
      write-on-stdout_ signal.size.stringify false // Assuming 'stop' was intended to be size
    print ""
  print label

graph signal --from --to --label -> none:
  
  graph signal --from=from --to=to --label=label :: | x l h | x >= l and x <= h

main:
    isize := 64
    twopi := 2.0 * PI
    signal := List isize 0.0
    fsize := isize.to-float
    for i := 0; i < isize ; i++:
      signal[i] = (cos (twopi * 2.0 * i.to-float / fsize) * 1.00) + (sin (twopi * 6.0 * i.to-float / fsize) * 0.75)

    print ""
    print ""
    graph signal --from=-2.0 --to=2.0 --label="Input signal"
    
    processor := FastFourierTransform signal 
    print ""
    print ""

    graph processor.forward-real-power[.. isize / 2] --from=0.0 --to=1.2 --label="Correlated power spectrum, \u0192s Hz" :: | x l h | x > l