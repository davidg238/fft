An example using `core.print.write-on-stdout_` to plot a simple graph to stdout.

Towards the end of the referenced STEP paper, there is some Smalltalk code to plot an FFT.  

An initial translation to Toit using ChatGPT and Copilot was unsatisfactory, although
the code ran, there were errors.    
  
Using [sketch.dev](https://sketch.dev/welcome) was much more productive.  
It works directly with GitHub, isolating your work in a container.  
sketch.dev not only works with the current Toit syntax, it installed the tooling within the constainer, produced a test suite and corrected bugs.  

You can see the development session [here](https://sketch.dev/messages/9x88-f5f5-7x1x-e3j0).  This session ended prematurely owing to an authentication issue.  You can see a [successful session](https://sketch.dev/messages/a6dr-gega-53ba-z14c), when sketch.dev was used to migrate an API change in a fuzzy logic library.

### References:
[STEPS Toward Espressive Programming Systems, 2011 Progress Report Submitted to the National Science Foundation (NSF) October 2011](https://tinlizzie.org/VPRIPapers/tr2011004_steps11.pdf)