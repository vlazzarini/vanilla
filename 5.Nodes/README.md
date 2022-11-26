Nodes
===

Csound WASM is built to work within the framework of the Web Audio API
that is provided by the JS interpreter. This example demonstrates how
interface Csound with other components of that API, called *nodes*.
These exist within an Audio Context, and can be connected together to
realise sound processing graphs.

When Csound starts, it creates its own Audio Context, within which it
operates as a node and is connected to the audio input/output. If we
want to place Csound within an Audio Context where other nodes
exist and can be connected to, we first need to create a context
object, then pass it to Csound.

In this code, we will create an Audio Context where Csound can be
connected to an AudioAnalyser node. This is, in our particular
application, nothing more than a glorified buffer, but we will be able
to use it to plot a waveform on the HTML page, via a oscilloscope animation.
The example should demonstrate how to get the Csound node and connect to another
node in the context. We will also show how we can use the Audio
Context object to control the processing.

CsoundObj API code used
-----------

The following CsoundObj method is used for the first time in this
tutorial:

`.getNode()`: obtains the WebAudio Node object corresponding to the
Csound engine.


JS Script
---

The Csound code in this example is relatively straightforward, a
single instance of instrument 1 plays for an unlimited duration,
producing a continuous sound, this time based on filtered noise.

```
// Csound synthesis code
let code = `
instr 1
a2 resonz rand(0dbfs/2),5800+randh(5000,7),150,2
out linenr(a2,0.1,0.1,0.01)
endin
schedule(1,0,-1);
`;
```

The rest of the code follows a familiar pattern, we have a `start()`
function that takes care of getting the sound running and the page
animation set up to display a waveform. The key differences now
are that we have defined a global AudioContext variable,

```
// actx is the Web Audio context object (null as we start)
let actx = null;
```

which receives an AudioContext object in the `start()` function,

```
// create a Web Audio context for audio processing
actx = new AudioContext();
```

We create this here, as this function is triggered by a user
action. Again, as we discussed in an earlier example, browsers
generally require interaction to get the audio context started.
Once we have this, we can pass it to the Csound engine we
create,

```
// create a Csound engine object inside the context actx
csound = await Csound({audioContext: actx});
```

The rest of the code in this function follows similar lines to
the previous example, except for these two changes:

1. We need to create an audio node to get the waveform for
plotting, and set the animation running

2. We will replace the `evalCode()` method of starting and
stopping the sound by one that resumes and suspends the
processing in the AudioContext object.

For the first of these, we wait on a promise returned by `createScope()`,
which we will define later,

```
// create the scope
await createScope();
```

For the second, we have the following code fragment for the
`else` branch of `start()`,

```
// check if instrument is running
if(isOn) {
// suspend the context to stop audio processing
actx.suspend();
// change text to OFF
document.getElementById("start button").value = "OFF";
// change colour to black
document.getElementById("start button").style.color = "black";
} else {
// resume the context to re-start audio processing
actx.resume();
// change text to ON
document.getElementById("start button").value = "ON";
// change colour to red
document.getElementById("start button").style.color = "red";
}
```

Now we can turn to defining a function to create the oscilloscope,
which first creates an AudioAnalyser node, then sets its buffer size to
512 samples (the default is 2048, which is too large for our
purposes). Since the AudioAnalyser is normally used to take discrete
Fourier transforms (using the fast Fourier transform), its buffer size
property is called `fftSize`. As we said earlier, we will use this
node in a very simple way, just to buffer the audio for the display.

The next thing we need to do is to set up the HTML Canvas element
to do 2-dimensional drawing. This is done through a graphics context
object, which we first get from the HTML element itself. Then we
set its dimensions to match the size of the buffer. The signal itself
will be stored in a float array, which we have to create.

Finally, we get the node representing the Csound engine and connect it
to the oscilloscope node we have just created. The drawing will be
performed by a callback, which we will define later. In order to get
the animation, we just call this function at the end,
 

```
async function createScope() {
// create AudioAnalyser node
scopeNode = actx.createAnalyser();
// set the buffer size to 512
scopeNode.fftSize = 512;
// get 2d context from HTML canvas
ctx = document.getElementById('scope').getContext('2d');
// set the canvas width to match buffer size
ctx.canvas.width = scopeNode.fftSize;
// create the data buffer to hold signal
s = new Float32Array(scopeNode.fftSize);
// get the Csound node
node = await csound.getNode();
// connect it to the scope node
node.connect(scopeNode);
// call scope drawing
scopeDraw(0)
}
```

The `scopeDraw()` callback updates the Canvas drawing with data from
the oscilloscope node. It draws new frames after a minimum time has
elapsed (here set to 50 milliseconds). For this, we keep the time
stamp of the last update and check if the current, passed as an
argument to the function is more than the minimum period ahead.
In that case, the function goes ahead and redraws the canvas.

The drawing code is the simplest possible. It takes in the audio data
from the node, then draws lines between the 512 sample values in that
array. At the end of the function, the code schedules itself to be
called again by the animation engine; this happens on every call.


```
// this holds previous time stamp
let before = 0;
// display update period
const period = 50;
// draw the scope
function scopeDraw(now) {
// if the period has elapsed
if(now - before > period) {
// get the audio from the node
scopeNode.getFloatTimeDomainData(s);
// clear the canvas
ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)
// start drawing
ctx.beginPath();
// create lines between samples
for (t = 0; t < s.length; t++)
 ctx.lineTo(t,ctx.canvas.height*(0.5 - s[t]*0.5));
// draw the plot
ctx.stroke();
// update time stamp
before = now;
}
// call the animation frame to draw again.
requestAnimationFrame(scopeDraw)
}
```



By choosing a minimum time, we make the animation run at a pace
that may be less visually stressing. In this case, if we have 512
samples in a frame, and supposing a 44100 Hz sampling rate,
the time interval between each frame is about 12ms, so we are actually
only showing about 1 frame out of every 5. However this is enough for
this particular application. More complex graphics code could be used
to improve the display, but that is being the scope of this tutorial.


HTML body
-----

The HTML code is again very simple, only composed of the on/off button
plus a Canvas element. 

```
<p>
<input type="button" id="start button" onclick="start()" value="OFF"> </input>
</p>
<p>
  <canvas id='scope' width=512 height=200 style="border:1px solid#000000;">
  </canvas>
  </p>
```

Conclusions
---

This example was designed to demonstrate how to integrate Csound
within the wider Web Audio API ecosystem. It is possible to make
connections with other kinds of processing nodes, taking advantage of
some of the facilities offered by that API. However, generally
speaking Csound is more than one factor of a magnitude more advanced
and powerful than anything that the Web Audio API can offer in terms
of synthesis and processing, so there is no particular need to avail
of it for those tasks. The more practical use cases are probably when
we want to interface Csound with existing systems that also work
within a Web Audio context.

