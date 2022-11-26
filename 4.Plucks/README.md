Plucks
===

In this example, we show how to

1. Evaluate Csound code on the fly.
2. Display messages from Csound on the page.

We will take advantage of the code structure introduced in the
previous example to switch the synthesis on/off, but use a
different method of interacting with Csound. The principle we will use
in this demonstration is that of *recursion*, an instrument scheduling
itself at every instantiation. This is used to create a continuous
stream of sound events. To stop this we just replace the instrument
code for one that does not schedule itself and the stream is stopped.
The synthesis code uses a simple plucked-string physical model to
play notes with different amplitudes, pitches, and durations.

CsoundObj API code used
-----------

The following  CsoundObj methods are used for the first time  in this
tutorial:

1.`.evalCodel()`: evaluate Csound code sent as a string.
2.`.on()`: registers a callback to respond to a specific event.


JS Script
---

The biggest changes happen in the Csound code. In order to do what we
need the best approach is to split it into three chunks,

1. The code that sets global resources such as shared arrays.
2. The code that makes sound through recursive calls.
3. The code that replaces the instrument and stops the recursion. 

The first one of these is
```
// header code
const head = `
0dbfs = 1
seed 0
giNotes[] fillarray 45,48,52,55,60,62,64,67,69,72,74,76,79
giAmps[] fillarray 0.05,0.1,0.2,0.3,0.4,0.6
giDurs[] fillarray 0.3,0.075,0.1,0.2,0.15,0.4
`;
```
which creates three arrays for note numbers, amplitudes, and durations
(which actually control event spacing). Next we have the recursive
instrument and a priming `schedule` command,

```
// recursion code
const recurse = `
instr 1
prints "freq:%dHz",p5
out linenr(pluck(p4,p5,p5,0,1),0,0.1,0.01)
icps = cpsmidinn(giNotes[gauss(6)+6])
iamp = giAmps[gauss(3)+3]
schedule(1,giDurs[gauss(3)+3],800*iamp/icps,iamp,icps)      
endin
schedule(1,0,0.01,0.001,500)
`;
```
The first line of this instrument prints a message to the Csound
console. We will later grab these messages and display them on the
page. The third code is simply a replacement for instrument 1:

```
// stop code
const stop = `
instr 1
out linenr(pluck(p4,p5,p5,0,1),0,0.1,0.01)     
endin
`;
```

This plays a sound and stops.

We now need to define a function to handle the Csound messages
and print them on the page,

```
// message handling
function handleMessage(msg){
// if running, display messages
if (isOn) document.getElementById('mess').value = msg;
// else just fill with blanks
else document.getElementById('mess').value = " ";
}
```

This is a callback that is passed the Csound console message,
and it prints this to an element on the page when the synthesis
code is running; it displays nothing otherwise.

The `start()` function from the previous example is used mostly
unchanged, with the exception of three sections

1. The initial compilation before Csound starts takes both the
`head` and `recursion` code fragments.
2. We need to register the message handler callback.
3. The `inputMessage()` call of the previous example is replaced
by an `evalCode()` method, to which we pass either the `stop` code
fragment (if we are running) or the `recursion` (if not).


```
// this is the JS function to start Csound
// and toggle recursion on/off
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
await csound.compileOrc(head + recurse);
// start the engine
await csound.start();
// add a listener for Csound messages
await csound.on("message", handleMessage);
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
await csound.evalCode(stop)
// change text to OFF
document.getElementById("start button").value = "OFF";
// change colour to black
document.getElementById("start button").style.color = "black";
} else {
// turn it on
await csound.evalCode(recurse)
// change text to ON
document.getElementById("start button").value = "ON";
// change colour to red
document.getElementById("start button").style.color = "red";
}
}
// toggle instrument state
isOn = !isOn;
}
```

Since we have no further controls of any kind, this is all we need
as far as the JS code is concerned.


HTML body
-----

The HTML body is simply composed of the start button and a text area
element that will receive the messages from the handler,

```
<p>
<input type="button" id="start button" onclick="start()" value="OFF"> </input>
</p>
  <textarea cols="80" rows="1" id="mess"></textarea> 
```

Conclusions
---

In this example, we introduced a powerful concept, that of recursion,
as a means to produce a continuous stream of events, and the principle
of dynamically altering instrument code to control the synthesis. We
have also shown how to introduce a callback to handle messages from
Csound, which is useful to give users feedback about the performance.

