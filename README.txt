// Fractal Wavetables
// March 2009
// jdn (at) raintone.com
//
//

-----------------
Introduction
-----------------

This is a Processing sketch that lets the user explore fractal wavetable synthesis.  
A variable bank of sliders control the "seed" pattern used to recursively subdivide the waveform data -- starting with the number "1".

So for a pattern of "1, 0.5, 1" (the default for this sketch), the first three iterations are:

1

1 0.5 1

1 0.5 1 0.5 0.25 0.5 1 0.5 1

Keep doing this until you have enough numbers for a few seconds of audio, and voila! the sketch begins playing a loop of what the data sounds like when played back as raw audio data.


-----------------
Basic Usage
-----------------

* Drag the mouse over the pattern sliders to create sound. 

* Add or remove sliders via the "steps" control.

* Try setting the number of steps to an interesting metrical unit -- say "8" -- and use the pattern as a fractal step sequencer.

* The Save button will put a specially-named audio file in the same directory as the program.  

* If you drag-and-drop these specially-named audio files back onto the app, it will reload the same fractal pattern used to generate the audio.  There may be some UI glitches when you do this -- not sure why that's happening.

Have Fun!

Keep checking back at Raintone.com for updates -- I'm actively evolving this project.

If you use git, you can also check out the code at:
http://wiki.github.com/jdnorthrup/fractalwavetablesketch

-JD


-----------------
Props
-----------------

* Thanks to Terran Olson's work on audio fractals that inspired this sketch. See http://www.halfcadence.net/audio-fractals/ for more info.

* Thanks to Krister Olsson's Ess library for the sound support. http://www.tree-axis.com/Ess
