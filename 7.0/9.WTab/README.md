WTab
===

This tutorial demonstrates two further aspects of Csound WASM programming,

1. Access to function tables,
2. Reading data from control channels,

together with

3. Interactive graphics.

To show this functionality, we will implement a wavetable synthesizer,
whose waveforms can be drawn on the screen by the user, and played via
a simple button keyboard (as we did in a previous example).

The application is outlined as follows. We first provide as usual a
means of starting the Csound engine. The core of the application is
then a function that takes the data from the graphics and copies that
to a function table in Csound. The wavetable is then prepared by
processing the data into a bandlimited waveform, and once this is
ready, we can display the result on the screen.

To support interaction, we will need to supply code for drawing and
displaying the waveform data. For this we employ the p5.js API
again, although this could also be implemented using plain HTML5
elements. Additionally, since we are using that API, we also take
advantage of it to provide the other UI components to control the
synth: update and a clear-screen buttons; and a
pentatonic keyboard.

CsoundObj API code used
-----------

The following  CsoundObj methods are used for the first time in this tutorial:

1.`. tableCopyIn()`: copies a Float32 array to an existing Csound
function table.  
2.`.tableCopyOut()`: copies a Csound function table as a Float32
array.  
3.`.getControlChannel()`: get value of software bus control channel.  


JS Script
---

The JS script shares a number of elements with previous examples.
Most of the elements of the `start()` function as presented before
can be reused here. The Csound code is composed of two instruments,
containing the synthesis and the function table update, respectively,

```
// csound synthesis code
const code = `
ifn ftgen 1,0,` + tlen + `,2,0
instr 1
out linenr(oscili(0dbfs*p4,cpsmidinn(p5),2),0.01,0.5,0.01)
endin

instr 2
ifn ftgen 2,0,16384,30,1,1,sr/(2*cpsmidinn(60))
chnset ifn, "newTable"
endin
`;
```

Note that we take the size for table 1 from JS, as this is used to
hold the waveform data taken from the graphics element. This
guarantees that the sizes will match between the two code
components. This function table is not used directly in the synthesis,
but as a means to get the data from JS, and as the source for
the generation of a bandlimited wavetable.

Function table creation/updating is handled by a single function,
whose operation is regulated by a flag that is set as a new table
gets constructed. Data from the graphical interface is provided
as a list of breakpoints, `bktpoints`, describing straight-line
segments that were drawn by the user. These breakpoints
are interpolated and stored in a JS array, `table`, mapped to a -1 to
1 range. We can then copy that array to function table 1 in Csound. With
that, we can invoke instrument 2 to process it and create the
bandlimited wavetable (table 2).

The next step is to display it in place of the user-drawn waveform.
Since Csound operation is fully asynchronous, we do not know whether a
new table has been created by the time `inputMessage()` fulfills a
promise. So we use a control channel to signal the creation of
a new table in instrument 2. We wait for this channel to be set, then
continue on to copy the data from the function table as a JS array.

The breakpoints list is used as the means of drawing waveforms
by p5.js. Therefore by copying the array data into this, next time
the screen is updated the bandlimited wavetable is displayed. Note
that function table 2 is larger than the number of points in the
graphical object (`tlen`), which is also the size of table 1. We need
to take account of this when copying the data.


```
// created/updated flag
let created = false;
// create/update table 
async function createTable(){
// if the table needs to be created/updated
if(!created) {
// read the list of breakpoints, write to array
for(let k = 0; k < bkpts.length - 3; k+=2) { 
let y1 = bkpts[k+1];
let y2 = bkpts[k+3];
let x1 = bkpts[k];
let x2 = bkpts[k+2];
let inc = (y2-y1)/(x2-x1);
let a = y1;
// linear interpolation
for(let i=x1; i < x2; i++)  {
table[i] = a/height - 0.5;
a += inc;
}     
}
// copy the array into table 1
await csound.tableCopyIn(1,table);
// run instr 2 to generate table 2
await csound.inputMessage('i2 0 0');
// wait for table number
let tn = 0;
while(tn != 2)
tn = await csound.getControlChannel('newTable');
// copy table 2 into array for display
let tab2 = await csound.tableCopyOut(tn);
// pos increment
let knc = tab2.length/tlen;
// clear the breakpoint list
bkpts = [];
// write array to breakpoint list
for(let i=0,k=0; i < tlen; i++){
bkpts.push(i);
bkpts.push((tab2[k] + 1)*height/2);
k += knc;
}
// set the created/update flag
created = true;
// clear control channel
await csound.setControlChannel('newTable',0);
}
}
```

As before, the p5.js graphical interface is created by the
`setup()` function,

```
// breakpoint list for drawing/display
let bkpts = [];
// line draw flag
let lnd = false;
function setup() {
// update button
let but = createButton("start");
but.parent("butts");
but.mousePressed(updateTable)
// canvas clear button
but = createButton("clear");
but.parent("butts");
but.mousePressed(clearCanvas)
// canvas for drawing/display
let cnv = createCanvas(tlen,height);
cnv.parent("canvas");
// function for mouse down
cnv.mousePressed(startDraw);
// function for mouse up
cnv.mouseReleased(stopDraw);
// function for mouse movement
cnv.mouseMoved(lineDraw);
// create keys buttons
let notes = [48,50,51,55,58,60];
notes.forEach(addButton);
}
```

Each one of the keys buttons is created by

```
// function to create a key button
function addButton(b,n) {
// b is the note number
let but = createButton(b.toString(),b.toString());
but.parent("keys");
// mouse down
but.mousePressed(noteon);
// mouse up
but.mouseReleased(noteoff);
}
```

where the `noteon` and `noteoff` functions are similar to what we used
in the *Penta* tutorial.

We have now to implement the user interaction on canvas. This is done
by three functions, responding to mouse actions. Data entry starts and
stops on mouse down and up, respectively,

```
// this starts drawing with mouse
function startDraw(){
lnd = true;
}

// this stops drawing with mouse
function stopDraw() {
lnd = false;
}
```

which simply set a flag to indicate the state. The actual data input,
which updates the breakpoint list happens when the mouse is moved
inside the Canvas area,


```
// holds max x pos
let ixmax = 0;
// this function draws a wavetable
function lineDraw() {
// if we are in drawing mode
if(lnd && !created) {
// take X and Y positions
let x = mouseX;
let y = mouseY;
// if X is beyond the current X pos
// and less than the table length
if(x > ixmax && x < tlen) {
// add (x,y) to the breakpoints list 
bkpts.push(x);
bkpts.push(y);
// update the max value of x
ixmax = x;
} 
}
}
```

In order for the breakpoints to describe a valid waveform, we have to
check that they are in strict order (in the x dimension). For this, we
only add to the list if the position along that axis is greater than
the last breakpoint. We also check that we do not exceed the table size.

The actual data display on Canvas is handled by the p5.js `draw()` function,
which regularly updates it,

```
function draw() {
background(220);
let ix = 0;
let iy = height/2;
stroke(0);
// draw a line connecting each breakpoint
for(let i = 0; i < bkpts.length; i+=2) {
line(ix,iy,bkpts[i],bkpts[i+1]);
ix = bkpts[i];
iy = bkpts[i+1];
}
// draw a line at the Y centre
stroke(255, 0, 0);
line(0,height/2,tlen,height/2);
}
```

Finally, to clear the waveform ready for a new one, we just reset
the relevant flags,

```
// clear canvas
function clearCanvas() {
// empty breakpoint list
bkpts = [];
// unset flags
lnd = false;
created = false;
// reset max x pos
ixmax = 0;
}
```

HTML body
-----

Since we have a few more UI elements in this example, we need
to set up a separate `div` section for each one of them. These
are then referred to by the p5.js code when displaying the various
elements,

```
<p><div id="butts"> </div></p>
<p><div id="canvas"> </div></p>
<p><div id="keys"> </div></p>
```

Conclusions
---

This example shows a wavetable synthesizer web app, which supports a
certain amount of interaction via a graphical interface. It
demonstrates how data can be transferred by the JS host code and
Csound using function tables as an interface. It also shows how we may
signal an event from Csound using a control channel and listen for it
in JS. There is a significant amount of interface code in this
example, but such tasks are generally facilitated by the use
of an API such as p5.js, which can be integrated very well with Csound.

