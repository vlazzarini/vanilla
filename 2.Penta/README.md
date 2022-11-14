Penta
===

The Penta example demonstrates a few more aspects of interaction
between HTML elements and Csound, building on what we have already
seen. For this, there will be two points of interaction

1. a button to start the Csound engine.
2. a row of buttons to control Csound events and make sound.

We will employ three different actions on these buttons:
clicking, mouse down, and mouse up.

JS Script
---

The script is placed and organised as before, so you can refer to the
earlier example for more details. We will now explore any aspects that
have been modified. The first one is that the csound code has some
small changes:

1. We use a vco2 (sawtooth oscillator) instead of a simple sine wave
oscillator (oscili).
2. The frequency (p5) is expected to be in MIDI note numbers, which
are translated to cps (Hz).
3. No event is scheduled.

```
// csound synthesis code
const code = `
instr 1
  out linenr(vco2(0dbfs*p4,cpsmidinn(p5)),0.01,0.5,0.01)
endin
`;
```

When this instrument is compiled, no sound is generated, as the code
does not run the instrument. The scheduling of the instrument is left
to HTML elements in the page, as we will see.

What we want to do is to start Csound and get it ready to make sound
in response to user action. The `start()` function does that,

```
// this is the JS function to start Csound
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
// start the engine
await csound.start();
// change text to ON
document.getElementById("start button").value = "ON";
// change colour to RED
document.getElementById("start button").style.color = "red";
}
}
```

Note that this function has only one conditional branch, so it only
runs when the csound engine is yet to be initialised. It is a non-op
after csound starts. This function will be invoked by a button click
and will signal that Csound is running by changing the appearance
of that element on the page.

We now need to supply the functionality to start and stop instrument 1
events so we can hear something. The first thing to do is, in response
to a mouse down action on a button, start a held note in Csound,

```
// mouse down function
async function noteon(note,id) {
// create the event command: negative p3 to hold
s = "i1." + note + " 0 -1 0.2 " + note;
// display it in the JS console
console.log(s);
// send it to the Csound engine
if(csound) await csound.inputMessage(s)
// change the colour
document.getElementById(id).style.color = "blue";
}
```

The function will take two parameters from the HTML element. The first
is used to set the note to be played. The second is the element ID so
we can change its appearance as the note is held. As in the previous
example, we interact with Csound via a score-type message sent
via the `inputMessage()` method. This has negative p3 and a fractional
p1 to identify the instrument 1 instance.

We can then stop that particular instance by sending a matching
negative p1, which is done by a function responding to mouse up,

```
// mouse up function
async function noteoff(note,id) {
// create the event command: negative p1 to release
s = "i-1." + note + " 0 1 0.2 " + note;
// display it in the JS console
console.log(s);
// send it to the Csound engine
if(csound) await csound.inputMessage(s)
// change the colour back
document.getElementById(id).style.color = "black";
}
```

In both functions, we have a matching p1 that is dependent on
the value of `note`, that is passed in by a particular HTML element (a
button in this case). On mouse down, the event is started, a held
note, and on mouse up, it is stopped. The button behaves as if it
were an instrument keyboard. The functions also log a message to the
console to show the score command that is being sent.

HTML body
-----

The HTML body code has a few more elements. We have a button to start
the engine, which issues a call in response to an `onclick`
gesture. Then we have five buttons, which send their values and ids in
response to mouse down and mouse up actions. Each button in the
keyboard has a MIDI note value assigned to it, which it passes to the
JS functions it is invoking.

```
<p>
<input type="button" id="start button" onclick="start()" value="OFF"> </input>
</p>
<div id="keys">
<p>  
<input type="button" id="c" value="60" onmousedown="noteon(value,id)"
  onmouseup="noteoff(value, id)"> </input>
<input type="button" id="d" value="62" onmousedown="noteon(value,id)"
  onmouseup="noteoff(value, id)"> </input>  
<input type="button" id="e" value="64" onmousedown="noteon(value,id)"
  onmouseup="noteoff(value, id)"> </input>
<input type="button" id="g" value="67" onmousedown="noteon(value,id)"
  onmouseup="noteoff(value,  id)"> </input>    
<input type="button" id="a" value="69" onmousedown="noteon(value,  id)"
  onmouseup="noteoff(value, id)"> </input>
<input type="button" id="cc" value="72" onmousedown="noteon(value,  id)"
  onmouseup="noteoff(value, id)"> </input>    
</p>  
</div>
```

Conclusions
---

This code involves a few more elements of interaction. It takes
advantage of the held note mechanism in Csound to make sounds start
and stop in response to user actions. It also shows how we can use
data from the elements (in this case, note numbers) to control the
synthesis directly.

