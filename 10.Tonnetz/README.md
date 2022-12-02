Tonnetz
===

This tutorial builds on the two previous examples to demonstrate
MIDI input with interactive graphics. The idea is to construct a 24
by 24 Tonnetz in a p5.js Canvas object, which can be used to play sounds.
This time, we will use MIDI to control Csound, which will also allow
us to plug in a MIDI device and use that to make sound.

CsoundObj API code used
-----------

The following  CsoundObj method is used for the first time in this tutorial:

`.midiMessageInput()`: sends a MIDI channel message to Csound.


JS Script
---

For this example, we provide the Csound code as a CSD file.
This depends on a data file containg audio samples (as
soundfonts), which we can provide to the local filesystem
using the same method introduced in earlier example.

Since we are using MIDI, we need to pass in the option to use
MIDI input,

```
// set realtime MIDI input
await csound.setOption("-M0");
```

To create the Tonnetz, we will define a Note class that
encapsulates a Canvas graphical representation that is tied
into a MIDI note number. This also provides a method for
drawing the note on Canvas,

```
// pitch class name table
const names = ["C", "C#", "D", "Eb", "E", "F","F#", "G", "G#", "A", "Bb", "B"];
// text xy offset for notes
const yoff = 15;
const xoff = 5;
// note square size
const sqr = 25;
// this defines a note for the Tonnetz
class Note {
constructor(x, y, n) {
// top left-hand canvas coordinates
this.x = x;
this.y = y;
// corresponding note number
this.note = n;
// ON/OFF switch 
this.on = false;
}
// create the note on canvas
create() {
// set the fill for ON/OFF
if(this.on) fill(220);
else fill(255);
// draw a square
square(this.x, this.y, sqr);
// set the text fill
fill(0);
// display note pitch class name
text(names[this.note%12], this.x+xoff, this.y+yoff)
}
}
```

Each note is therefore represented as square with a text inside,
which will be shown with different background colours depending
on whether the note is on or off. We can now create a list of Note
objects with the correct locations and note numbers, which
defines the Tonnetz.

```
// canvas dimensions
let width = 24*sqr;
let height = 24*sqr;
// Note list
let nn = [];
// create Tonnetz on canvas
function createTonnetz() {
let ys = 24;
let xs = 0;
// vertical offset by 3 or -4 semitones, alternating
for(let y=0; y < height; y+=sqr) {
let num = ys;
// horizontal offset by 7 semitones
for(let x=xs; x < width-xs; x+=sqr) {
// note numbers between 0 and 108
if(num > 108) num -= 108;
if(num < 0) num += 108;
let n = new Note(x,y,num);
nn.push(n);
num += 7;
}
// vertical offset, every other row
if(xs == 0) {
xs = -sqr/2;
ys -= 4; 
} else {
xs = 0;
ys += 3;
}  
}
}
```

The Tonnetz can now be drawn by iterating through the list
and calling the relevant method,

```
// realise the Tonnetz graphically
function drawTonnetz() {
// draw notes
for(let i=0; i < nn.length; i++) {
nn[i].create();
}
}
```

In order to provide visual feedback to the user, the Csound
code uses an output control channel, which sends out the latest MIDI
on note. We can define a listener to deal with this,

```
// control channel listener
async function controlListen() {
if(csound) {
// get the control channel value 
let note = await csound.getControlChannel("notenum");
// loop through the notes
for(let i=0; i < nn.length; i++) {
// set the notes to ON if they have the same note number
if(nn[i].note == note) nn[i].on = true
// or OFF if they are negative
else if(nn[i].note == -note) nn[i].on = false;
}
}
// recurse
setTimeout(controlListen);
}
```

and prime it with

```
setTimeout(controlListen);
```

The next thing we need to do is to set a function to respond to mouse
clicks on canvas. The idea here is to check the mouse position against
the Tonnetz and then issue a MIDI note on message to Csound for the
corresponding note number,

```
// last note played
let lastNote = null;
// on note on
async function noteOn() {
let x = mouseX;
let y = mouseY;
for(let i=0; i < nn.length; i++) {
// if x and y are inside a canvas note
if((x >= nn[i].x && y >= nn[i].y) &&
(x < nn[i].x+sqr && y < nn[i].y+sqr)) {
// set the lastNote to this
lastNote = nn[i];
// send a note on message to Csound
if(csound) await csound.midiMessage(144,lastNote.note,100)
return;
} 
}
}
```

We also keep a record of the last note played so that on mouse
released (anywhere on Canvas), we can stop it by sending a MIDI note off
message to Csound.

```
// on note off
async function noteOff() {
// if a note is playing
if(lastNote) {
// send a note off to Csound
if(csound) await csound.midiMessage(128,lastNote.note,0);
// clear the last note
lastNote = null;
}
}
```

Note that it is Csound that is responsible (via control messages) to
set the ON/OFF flag for notes. This means that the clicking action
only triggers a MIDI note, and the interface is updated by the flag
setting which happens in the control message listener. All notes on
the interface that are tied up with a particular note number wil react
to this (by changing colour).

The p5.js functions can now be defined to create the interface,

```
// called by p5.js
function setup() {
// create Canvas
let cnv = createCanvas(width,height);
// create Tonnetz
createTonnetz();
// if mouse is pressed on Canvas
cnv.mousePressed(noteOn);
// if mouse is released on Canvas
cnv.mouseReleased(noteOff); 
}

// called  by p5.js
function draw() {
background(220);
drawTonnetz();
}
```

Finally, we can provide a means for users to change the preset
used by Csound. This can be done via a program change message.
In the HTML interface, we will add a drop-down list and a selection
button, which then invokes the following function,

```
// when a new preset is requested
async function pgmChange() {
let pgm = document.getElementById("pgm").value;
// send a program change message to Csound
if(csound) await csound.midiMessage(192,pgm,0);
}
```

HTML body
-----

The page combines the p5.js Canvas and some pure HTML controls. We
place the latter first on the page, with the OFF/ON button on the left
and the program selector/load button beside it. Below this, we then
put the p5.js main area.

```
<p>
<input type="button" id="start button" onclick="start()" value="OFF">
</input>
  <select name="prog" id="pgm">
    <option value="0">Grand Piano</option>
    <option value="4">Electric Piano</option> 
    <option value="16">Drawbar Organ</option>
    <option value="18">Rock Organ</option>      
    <option value="24">Acoustic Guitar</option>
    <option value="26">Electric Guitar</option>
    <option value="33">Electric Bass</option>  
    <option value="35">Fretless Bass</option>
    <option value="40">Violin</option>
    <option value="42">Cello</option>
    <option value="48">String Ensemble</option>
    <option value="68">Oboe</option>  
    <option value="73">Flute</option>
    <option value="80">Synth Lead</option>
    <option value="88">Synth Pad</option>    
  </select>
  <input type="button" value="load preset"
  onclick="pgmChange()"></input>
  </p>
<main> </main>
```

Conclusions
---

This example shows a MIDI-based web app with interactive graphics
provided by p5.js. It demonstrates how Csound can receive and respond
to MIDI messages (in this example, MIDI note on, note off, and program
change).

