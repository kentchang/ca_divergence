# Shortcuts

The code to do topic modelling on the three texts, and produce the datafiles for plotting, is in:

  shortcuts.rb
  shortcuts_helper.rb

The two key methods used in shortcuts.rb, found in shortcuts_helper.rb, are

  chunk_and_clean(in_size=chunk_size, word_clean=nil, proportional=false)

This filters the texts and "chunks" them into chunk_size units, and

  mallet_model(15, -5.0/15)

This runs the topic modeller "mallet", http://mallet.cs.umass.edu, which we have found to be fast, reliable, and to best reproduce the results expected from the original Topic Modelling specification. You will need to provide your local path to the MALLET /bin directory.

The plots themselves are then made with the IDL plotting program; the code for these plots is available in shortcuts_plotting.pro

The first three lines of the .pro file are the samples found in the "total" Array from shortcuts.rb (they are simply cut and pasted from a sample run; you will find different results each time, as the topic models themselves are stochastic.) To get the colors working properly, you will need the Coyote supplement to IDL, freely available at http://www.idlcoyote.com/graphics_tips/coyote_graphics.php