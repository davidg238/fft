An example using `core.print.write-on-stdout_` to plot a simple graph to stdout.

Towards the end of the referenced STEP paper, there is some Smalltalk code to plot an FFT.  

An initial translation to Toit using ChatGPT and Copilot was unsatisfactory, although
the code ran, there were errors.    
  
Using [sketch.dev](https://sketch.dev/welcome) was much more productive.  
It works directly with GitHub, isolating your work in a container.  
sketch.dev not only works with the current Toit syntax, it installed the tooling within the constainer, produced a test suite and corrected bugs.  

You can see the development session [here](https://sketch.dev/messages/9x88-f5f5-7x1x-e3j0).  This session ended prematurely owing to an authentication issue.  You can see a [successful session](https://sketch.dev/messages/a6dr-gega-53ba-z14c), when sketch.dev was used to migrate an API change in a fuzzy logic library.

You can then see what happened when ChatGPT [reviewed](https://chatgpt.com/s/t_685f4247d0f08191b6f36330f3383e2f) the test suite and then [checked](https://chatgpt.com/s/t_685f41d86d588191b5c327a8be72f37c) the numerical values used in the suite.  I understand the precedence rules in Toit, "The mathematical operators all have higher precedence than calls", to mean the parentheses are not required in `Suggestions / Minor Fixes  1.`


### References:
[STEPS Toward Espressive Programming Systems, 2011 Progress Report Submitted to the National Science Foundation (NSF) October 2011](https://tinlizzie.org/VPRIPapers/tr2011004_steps11.pdf)