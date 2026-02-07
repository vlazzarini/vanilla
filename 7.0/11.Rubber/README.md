Rubber
===

This example demonstrates realtime audio input processing. This is
normally sourced from the default audio input in the system, which may
be the microphone or a soundcard input. At the first time the code is
run, permission will be sought by the browser to record audio (or
use the microphone). Once that is granted, Csound can then start
realtime audio input.

This code also uses P5.js to provide a user interface, similarly
to earlier examples. We will introduce a few differences such as
loading Csound from a user action defined in the `setup()` function.
This hopefully will work everywhere given that permission to use the
microphone needs to be granted. Since this may not be enough
to fullfill the requirement of a user action to get the audio context
started, we will use a mouse press on the canvas to do that.

We will also introduce the `.then()` method
associated with JS Promises and asynchronous
processing.

This web app takes audio from an input, stores it in a 2-second
buffer (continuously overwriting it), and allows the time and
pitchscale of that waveform to be manipulated in a two dimensional
space.


CsoundObj API code used
-----------

All CsoundObj API code used in this tutorial has already been
introduced in earlier examples.

JS Script
---

We introduce a few variations on earlier examples. First, we should
note that it is possible to load the p5.js module by importing it
inside our script instead of using a separate html script tag,

```
import("https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.5.0/p5.js")
```

Secondly, we can start Csound from a user action defined in the p5.js
`setup()` callback.


```
// called by P5.js
let cnv = null;
function setup() {
 cnv  = createCanvas(width, height);
 cnv.elt.addEventListener("contextmenu",
   (e) => e.preventDefault());
 // first press starts Csound
 cnv.mousePressed(pressToStart);
}
```

So the Canvas object is created with a single mouse-press
associated callback. Csound has not yet been started, but
it will be after a user action.

If we do not define the `pressToStart()` function as asynchronous,
we can use a different code pattern to call `start()` (which is defined as `async`) and still
impose an order in the sequencing of calls. This is done via
`.then()`, which is invoked on a Promise that is returned by
`start()`. This contains a callback that will execute once the
Promise is fulfilled. We can define this callback using an anonymous
arrow function, `() => { }`,

```
function pressToStart() {
 start().then(() => {
 // now define the button callbacks
 cnv.mousePressed(pressed);
 cnv.mouseReleased(released);
 cnv.mouseMoved(moved);
 });
}
```

The `start()` function is very similar to the ones in previous examples, except that
we want to start realtime audio input. This is done by setting an option,

```
// set realtime audio (adc) input
await csound.setOption("-iadc");
```

Once Csound is running, we have to respond to three mouse actions
by setting control channel values,


1. Pressed: this sends the time and pitch scale parameters to Csound,
and turns the amplitude from 0 to 1. It also sets a text to display these
parameters on to the canvas. We use the `.then()` code pattern on the
promises returned from Csound methods to impose a sequence on the
calls,

```
// text to display
let txt = null;
// on mouse press
function pressed() {
mpoint.x = mouseX;
mpoint.y = mouseY;
mpoint.on = true;
// timescale
const t = (4.0*mpoint.x/width)-2;
// pitchscale
const p = -(4.0*mouseY/height)+2;
// set control channels: time, pitch and then amp
csound.setControlChannel('time',t).then(() => {
csound.setControlChannel('pitch',p).then(
() =>{ csound.setControlChannel('amp', 1);});}); 
txt = "timescale: " + t.toFixed(3) +
"\npitchscale: " + p.toFixed(3);  
}
```

2. Moved: if the mouse is pressed and it moves around the canvas, we
update the time and pitchscale parameters,

```
// on mouse move
function moved() {
// if pressed
if(mpoint.on){
mpoint.x = mouseX;
mpoint.y = mouseY;
// timescale
const t = (4.0*mpoint.x/width)-2;
// pitchscale
const p = -(4.0*mouseY/height)+2;
// set control channels: time and then pitch
csound.setControlChannel('time', t).then(
() =>{ csound.setControlChannel('pitch', p);});
txt = "timescale: " + t.toFixed(3) +
"\npitchscale: " + p.toFixed(3); 
}
}
```

3. Released: when the mouse button is released, we just turn the
amplitude channel back to 0 and clear the graphics flag and text,

```
function released() {
// clear flag
mpoint.on = false;
// clear text
txt = null;
// set amp to 0
csound.setControlChannel('amp',0); 
}
```

Note that we are not checking for `csound` anymore since these
callbacks are only going to be operational after Csound has been started.

The only remaining callback is p5.js drawing code. This has two
branches, one used when the mouse is pressed, and another for
when it is released.  If the former is the case, the background colour
is changed, crosshairs meeting at the mouse position are drawn,
and text is displayed. If not, we just draw a standard background.
To give the user a graphical reference, a cross is always shown on
the canvas.

```
function draw() {
if(mpoint.on){
// change background
background('gold');
// draw crosshair
strokeWeight(1);    
stroke(0);  
line(0, mpoint.y, width, mpoint.y);
line(mpoint.x,0,mpoint.x,height);
// draw text
let ofx = 5;
let ofy = 12;
if(mpoint.x > width - 100) ofx = -100;
if(mpoint.y > height - 24) ofy = -24;  
text(txt, mpoint.x+ofx,mpoint.y+ofy);   
}
else background(220);
// draw reference cross
strokeWeight(5);  
stroke('green');  
line(0, height/2, width, height/2);
line(width/2,0,width/2,height);  
}
```


HTML body
-----

As in an earlier example, the HTML body only consists of the main tags
indicating where the Canvas should be drawn.


Conclusions
---

This example shows how audio input can be handled by Csound, together
with a simple p5.js graphical interface. It introduces a new code
pattern for dealing with asynchronous execution, using the `.then()`
method and arrow functions. Since the interface to Csound in JS is
fully asynchronous, it is always useful to understand the alternatives
we may have when using it in a web app.
