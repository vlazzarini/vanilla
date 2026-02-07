Ping
===

The Ping example does the first three basic things we need to learn before moving
to more interactive stuff.

1. Imports the Csound WASM module.  
2. Creates a Csound engine object.
3. Compiles the code containing a synthesis instrument.
4. Runs the instrument.

So, there are four basic things we need to do then. Or five,

5. If the object is already created, the code is already compiled, so
just run the instrument again.

CsoundObj API code used
-----------

The following  CsoundObj methods are used for the first time  in this tutorial:

1. `Csound()` : constructs a CsoundObj object.
2. `.setOption()` : sets a Csound option.
3. `.csoundCompileOrc()` : compiles Csound code.
4. `.csoundStart()` : starts audio processing.
5. `.inputMessage()` : sends an event to Csound as score command string.

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

6. Provide global variable to hold the csound object, and the csound code

```
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

Now we can do all the actions required within a single function called
`play()`. In this function, before we do anything,
we have to import the `csound.js` from a URL provided by a content
delivery network (CDN). This allows us to run Csound
from any page (with an internet connection) anywhere. It is
possible, for instance, to open the html file locally in a browser and play
the example.

The comments in the code describe what each line is doing,

```
// this is the JS function to run Csound
async function play() {
// if the Csound object is not initialised
if(csound == null) {
// import the Csound method from csound.js
const { Csound } = await import('https://www.unpkg.com/@csound/browser@6.18.7/dist/csound.js');
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

The first branch happens when the `csound` is not yet created. Note
that each line uses the `await` code pattern. We can use this approach
because the function is marked asynchronous. The methods used to
manipulate the Csound object return JS Promises, which are objects
that will be fulfilled once the process invoked has completed. Therefore
to impose a given order of operations we need to block using `await()` 
at each point to wait for the JS Promise to be fulfilled before we
move on. It is always important to respect this if we depend on the
code being executed before we continue. A Promise may also contain a
return value, which may be for instance a number or an object.
This is only available when the Promise is fulfilled.

The other branch of the `start()` function just plays a sound by
instantiating (scheduling) instrument 1 with a score-style
command. This can now be done because Csound has started and
is accepting inputs.

By the time the HTML page is displayed, the JS code in this script is
ready to be invoked by the elements in the page. So we can hook it up
to execute via a user action (clicking on the page, in this case).

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
