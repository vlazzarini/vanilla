Sliders
===

The Sliders example moves on to explore two aspects of interaction

1. Continuous controls from a HTML element.
2. The software bus in Csound.

We will also keep from the previous example the principle of starting
the Csound engine by clicking on a button. This is in fact very
important, because browsers in general require some sort of user
interaction to enable the audio context to start running. If we were
to start Csound without any user action, it is likely that the engine
would not run because the audio context would be suspended.

The functionality of the start button will be extended so it can
trigger the instance on/off. Once clicked it will latch on, and can
be clicked again to turn off the sound. 

JS Script
---

In this script, we modify the Csound code so it can take its
synthesis parameters (amplitude, frequency), from the software
bus, using separate named channels,

```
// csound synthesis code
instr 1
  kamp = port(chnget:k("amp"),0.01,-1)
  kfreq = port(chnget:k("freq"),0.01,-1)
  out linenr(vco2(0dbfs*kamp,kfreq,10),0.01,0.5,0.01)
endin
schedule(1,0,-1)
`;
```
Portamento is applied to smooth the inputs, avoiding zipper noise.
We also schedule the instrument to start running. Since amplitude
and frequency are taken from bus channels, the instrument does not
have any extra p-fields beyond p3.

Now we modify the `start()` function from the previous examples to

1. Set initial values for the bus channels before synthesis starts.
2. Toggle an instrument 1 instance on/off, so we can use it to
   start/stop the synthesis.

To accomplish the second objective, we set a global variable to
hold the instance performance state (on/off). This is initially set
to off (`false`),

```
// instrument on/off state
let isOn = false;
// this is the JS function to start Csound
// we extend it to toggle the instr on/off
async function start() {
// if the Csound object is not initialised
if(csound == null) {
// import the Csound method from csound.js
const { Csound } = await import(csoundjs);
// create a Csound engine object
csound = await Csound();
// set realtime audio (dac) output  
await csound.setOption("-odac");
// compile csound code
await csound.compileOrc(code);
// set the amplitude
await csound.setControlChannel('amp', 0);
// set the frequency
await csound.setControlChannel('freq', 440);
// start the engine
await csound.start();
// change text to ON
document.getElementById("start button").value = "ON";
// change colour to RED
document.getElementById("start button").style.color = "red";
}
// if csound engine is running
else {
// check if instrument is running
if(isOn) {
// turn it off
await csound.inputMessage("i-1 0 1")
// change text to OFF
document.getElementById("start button").value = "OFF";
// change colour to black
document.getElementById("start button").style.color = "black";
} else {
// turn it on
await csound.inputMessage("i1 0 -1")
// change text to ON
document.getElementById("start button").value = "ON";
// change text to OFF
document.getElementById("start button").style.color = "red";
}
}
// toggle instrument state
isOn = !isOn;
}
```

We have added a second branch to be effective when the Csound engine
is initialised and running. In this, we then check for the state of
the instrument instance: if it is on, we turn it off; if it is off, we
turn it on. The button interface is updated accordingly. Finally,
we toggle the instrument state (this happens on every click).

The only remaining task to implement is to pick a controller
value and update the relevant bus channel,

```
// oninput function
async function setParameter(channel, value) {
  // set channel
  if(csound) await csound.setControlChannel(channel, value);
  // update display
  document.getElementById(channel+"val").innerHTML = value;
}
```

This function will be invoked in response to an on input action,
detected on an HTML element (slider). It takes in a channel name
and the value to set.

HTML body
-----

The HTML body is composed of the start button, which as before
invokes the `start()` function, and two sliders (HTML range input
elements), which call the `setParameter()` function,

```
<p>
<input type="button" id="start button" onclick="start()" value="OFF"> </input>
</p>
<div id="sliders">
<p>  
<input type="range" id="amp" min="0" max="1" value="0" step="0.001"
  oninput="setParameter(id, value)"> <span id="ampval"> 0.000 </span> </input> 
  </p>
<p>  
<input type="range" id="freq" min="100" max="1000" value="440" step="1"
  oninput="setParameter(id, value)"> <span id="freqval"> 440 </span> </input> 
</p>    
</div>
```

Note that a range input can respond to on input and on change user
actions. The latter is only taking place after the slider has moved
and the control has been let go, so it results in discontinuous
changes. The former issues calls as the element is being moved, so
it provides a continuous behaviour, which is
more appropriate in this application.

Conclusions
---

In this example, we showed how to use the Csound software bus to
connect continuous controllers to a synthesis instrument. We have also
extended the playback control to start and stop the sound by issuing
score commands as required.

