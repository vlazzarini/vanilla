Reso
===

This demonstrates the use of a well-known graphics library, p5.js, and
shows how it can be used construct a simple instrument with a user
interface (UI). Previously, we had shown how HTML5 elements could be
applied to provide interactive control of synthesis. This example
extends these ideas and shows how Csound can play well with other
JS APIs. We should note that p5.j also provides means of making sound,
through its p5sound.js library, but Csound is more than a factor of a
magnitude more advanced and flexible for audio processing than
whatever may be offered by p5.js. We should emphasise here that
graphic libraries such as this and Csound are an excellent combo for
various creative coding applications.


CsoundObj API code used
-----------

All CsoundObj API code used in this tutorial has already been
introduced in earlier examples.

JS Script
---

In this example, we will in fact employ two scripts, the one we will
write ourselves and p5.js, which will be loaded from a public URL.
This is done with the following HTML tag,

```
<script
src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.5.0/p5.js">
</script>
```

With this in our HTML file, we have access to the p5.js API. Our
own script is not too different from the previous examples.
We have a Csound code defining an instrument that will be
triggered by the p5.js user interface,

```
// csound synthesis code
const code = `
0dbfs=1
instr 1
kcps port cpsmidinn(p5),0.025,-1
tigoto end
afc = kcps + madsr(0.01,0.5,0.5,0.3)*p6
aosc = vco2(p4,kcps*.995) + vco2(p4,kcps*1.005)
asig vclpf aosc*linsegr(0,0.01,1,0,1),afc,0.7
end:
out asig*expsegr(0.3,0.01,0.3,0.4,0.001)
endin
`;
```

Just as in the HTML5 keyboard example (2.Penta), the code
does not include any schedule commands; we will run the
instrument through messages issued from the JS code.
The `start()` function is nearly identical to that example,
except for the fact that we do not need to have any interaction
with the HTML elements here.

The differences are in the definition of the interface, which is
done completely through p5.js. This calls for the definition of
a `setup()` function, which is called by the p5.js environment
when the page is loaded (like an on load function). We will
use a canvas to define the UI for the instrument, and we create
such an object here,

```
// called by P5.js
function setup() {
// create Canvas object
cnv = createCanvas(480, 480);
}
```

The Canvas will provide a 2-D space, which we will use to provide
the playing interface, mapping the vertical dimension to amplitude
and timbre, and the horizontal dimension to frequency (pitch). The
Canvas needs to be drawn/redrawn, and we need to provide a
function to do that,

```
let bgc = 250;
// called by P5.js
function draw() {
// update the background colour 
background(bgc);
// if a note is playing
if(amp > 0){
// mouse coordinates for note
nx = (note-48)*sqr;
ny = (1-amp)*480;
// draw a square
square(nx,ny,sqr);
// write the note number
text(note,nx+3,ny+15)
}
}
```

This is again called by p5.js. We draw the background with a greyscale
value between 0 - 255 (black to white), which at the start is nearly
white. The function will also draw a square of `sqr` dimensions
in the Canvas position corresponding to a given note and amplitude (x
and y coordinates), and place the corresponding note number as text
inside it.

We now have to find a means to start the audio context and Csound,
which we can do when the user clicks anywhere on the page. For this
we use the p5.js function `onMousePressed()`, which responds to
a mouse press anywhere in the graphics space,

```
// called on mouse click
async function mousePressed() {
if(csound == null) {
// start Csound
await start();
// register a mousePressed callback
cnv.mousePressed(noteon);
// register a mouseReleased callback
cnv.mouseReleased(noteoff);
// register a mouseMoved callback
cnv.mouseMoved(slur);
// set canvas background
bgc = 128;
}
}
```

After calling `start()`, we set callbacks on the canvas object for
three different types of mouse action: mouse down, mouse up,
and mouse movement, calling `noteon()`, `noteoff()`, and
`slur()`, respectively. Note that these are only active inside the
Canvas, and clicking anywhere else will not have any effect.
Once these are registered, we turn the Canvas background colour
value to a darker tone of grey to signal that the interface is ready.

The three functions we need to define are fairly straighforward.
Firstly, the instrument is monophonic so we only need to keep track
of one note and one amplitude,

```
// note amp
let amp = 0;
// note number
let note = 0;
```
and we can also set the constants controlling the maximum
filter cutoff frequency and the size of the square we are defining,

```
// filter cutoff
const cf = 8000
// square size
const sqr = 20
```

This latter constant also determines the quantisation of the
horizontal space. To place 2 octaves of 12 notes each, we divide
the Canvas horizontal dimension by 24, giving us the side of
the square. When a user clicks on the interface, the mouse position
will be quantised in the horizontal dimension to segments of
size 20. Any clicks on a given segment will yield the corresponding
MIDI note, which starts at 48 (C3). The `noteon()` function is
thus defined,

```
// mouse pressed function
async function noteon() {
// quantise the mouseX position to a grid 
note = int(mouseX/sqr)+48;
// map the mouseY position to 0 - 1
amp = 1 - mouseY/480;
// create the event command: negative p3 to hold
s = "i1 0 -1 " + amp + " " + note + " " + amp*cf;
// send it to the Csound engine
if(csound) await csound.inputMessage(s)
}
```

The vertical position is not quantised, just mapped to the 0 - 1
range. This affects both the sound amplitude (p4) and its timbre,
as it determines the filter cutoff frequency (p6). To stop a note,
on mouse up, we only need to send a negative p1 message,

```
// mouse released function
async function noteoff() {
// send a turnoff message
if(csound) await csound.inputMessage("i-1 0 1 0 0");
// set amp to zero
amp = 0;
}
```

We also set amp to 0 so that the square is not redrawn on
the canvas. This also controls how the mouse movement
behaves, as coded in the `slur()` function. If the amplitude is
zero, then that function is a non-op. However, when the
note is playing, we need to  still check if the mouse has moved
enough to trigger a new note,

```
// mouse moved function
async function slur() {
// only slur if note is playing
if(amp > 0) {
// get the note from mouse X
nnote = int(mouseX/sqr)+48;
// slur if it is a new note
if(note != nnote) await noteon();
}
}
```

The Csound code then will move to the new note. It is designed so
that when this occurs, a tie is detected, the envelopes do not
get retriggered, the pitch glides to the new value, and the amplitude
and filter frequencies also get updated.


HTML body
-----

The HTML body is the most minimal we have seen so far. It is only
composed of a section defined by the `<main>` tag. That is used
by p5.js as the space on the page where it draws its graphics. Since
no other HTML elements are needed, we are good to go with just
this single line,

```
<main> </main>
```

Conclusions
---
This example demonstrates how we can integrate an external JS API
with Csound. This takes advantage of the areas in which these two
elements excel, graphics and audio, respectively.


