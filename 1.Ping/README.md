Ping
===

The Ping example does the first three basic things we need to learn before moving
to more interactive stuff.

1. Imports the Csound WASM module.  
2. Creates a Csound engine object.
3. Compiles the code containing a synthesis instrument.
4. Runs the instrument.

So, there are four basic things we need to do then. Or five,

5. If the object is already created, the code is already compiled, so just run the instrument again.

JS Script
---

The JS code is a embedded as a script in the HTML file under the relevant tags,

```
<script type="text/javascript">
...
</script>

```

This can be placed anywhere in the HTML file and is run when the page is loaded. In the
code we will place a single asynchronous function that will do all the execution of the
five things listed above. Before this, we have to do a sixth step,

6. Provide global variables to hold the URL for the `csound.js` script (the Csound WASM module), the csound object, and the csound code

```
// csound.js is the Csound WASM module
const csoundjs = "../js/csound.js";
// csound is the Csound engine object (null as we start)
let csound = null;

// csound synthesis code
const code = `
instr 1
  out linenr(oscili(0dbfs*p4,p5),0.01,0.5,0.01)
endin
schedule(1,0,1,0.2,A4)
`;
```
Note that the Csound WASM module is referenced relative to this
html file location, as it resides in the js directory of the root of this repository. If this
is moved somewhere else during another deployment, the path to
its location will need to be updated.

Now we can do all the actions required within a single function called `play()`. The
comments in the code describe what each line is doing,

```
// this is the JS function to run Csound
async function play() {
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
} else
// if not just send an event to play a sound
await csound.inputMessage('i1 0 1 0.2 440');
}
```

The first branch happens when the `csound` is not yet created. Note that each line uses the `await` code pattern. This is because the function is asynchronous, so we need to block at each point to wait for the JS Promise to be fulfilled before we move on. Csound object methods return Promises, so it is important to respect this if we depend on the code being executed before we continue. The other branch just plays a sound by instantiating (scheduling) instrument 1 with a score-style command.

By the time the HTML page is displayed, this JS is ready to be invoked by the elements
in the page. So we can hook it up to execute when do an action.

HTML body
-----

The HTML body code is minimal. A division is defined to give the user an area to click on, and we display a simple instruction to do so. The `onclick` action is set to invoke the JS function `play()`, so the user will get a sound (the same sound) on every click. 

```
<div id="click area" onclick="play()">
<h1>Ping</h1>
<p> Click here to hear a sound.</p>
</div>
```

Conclusions
---

This code does very little, but it is good to show the steps in making sound with Csound WASM, and to demonstrate that with not very much we can have some user interaction controlling realtime synthesis. It is also handy to test if the whole system is working: module loading, compilation, on-click interaction, etc.

If you want to check what is going on behind the scenes, you can also open the Javascript console in your browser (this is generally under the developer menu or submenu, depending on the browser). With that you can actually interact with the running Csound directly. For example, you can call `csound.inputMessage()` to play a sound with a different duration, amplitude and frequency,

```
> csound.inputMessage('i1 0 2 0.5 880')
Promise {<pending>}                                eventemitter3.min.js:1
rtevent:	   T709.300 TT709.300 M:   6553.6
```

On the '>' prompt,  the csound object method was called with a score-like command to run instrument 1 immediately (0), for 2 seconds, with half amplitude and 880 Hz frequency. The console responded that we had been returned a Promise (which was pending) and then we saw the response from the Csound engine (the message `rtevent  ...`) as the sound was played.
