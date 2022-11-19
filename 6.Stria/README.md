Stria
===

Stria is a classic computer music composition by John Chowning, which
has been reconstructed using Csound in 2007 by Kevin Dahan. We will
use the code for this piece to demonstrate two important aspects of
Csound WASM

1. The interaction with the local browser filesystem.
2. The performance control of the Csound numeric score.

In order for Csound to access files (such as for instance the ones
containing code, audio, MIDI, and other types of data), we need to
make these available in the local browser filesystem. It is not
possible for Csound to access files on the server directly. These need
to be fetched and copied into a filesystem that is created inside
the browser. The good news is that Csound provides its own simple
interface to deal with this, and so we do not need to look for it elsewhere.
In this code we will demonstrate how we can copy the files in, but it
is equally possible to copy files out of it, and so Csound can potentially
also be used for offline rendering of audio.

In addition to this, we will demonstrate how we can control the score
playback with simple function calls responding to play, pause, and
rewind buttons. These ideas can be applied to create interactive
performances of complete pieces, such as Stria.

JS Script
---

In this code, we are going to provide Csound code in a text file,
instead of passing a text string for compilation. We will supply it as
a CSD-format file, which is the standard way to do it when using
files. The CSD uses XML-style tags to embed the instruments and
the numeric score code define the complete composition in the
case of Stria. One of the advantages of this format is that it
includes everything that is needed to run the piece.

We can store such files in the server, but in order for Csound to
access them, we need to make local copies inside the browser
filesystem (which is not directly accessible from the outside).
The CsoundObj static method `csound.fs.writeFile()` is used to
write data, given as a byte array, to a file in the browser
filesystem. We can fetch a file from the server, copy its contents
to an array, and then used that data to write the local file,

```
// Copy file to local filesystem
async function copyUrlToLocal(src, dest) {
// fetch the file
srcfile = await fetch(src)
// get the file data as an array
dat = await srcfile.arrayBuffer();
// write the data as a new file in the filesystem
await csound.fs.writeFile(dest, new Uint8Array(dat));
}
```

Once a promise is returned from this function, we are good to go.
So we can now modify the `start()` function to use `compileCsd()`,
which takes the name of a CSD file and compiles it. That is the main
modification in relation to any of the previous examples.

```
// CSD file name
const csd = './stria.csd'
// this is the JS function to start Csound
// and resume performance if needed
async function start() {
// if the Csound object is not initialised
if(csound == null) {
// import the Csound method from csound.js
const { Csound } = await import(csoundjs);
// create a Web Audio context for audio processing
actx = new AudioContext();
// create a Csound engine object inside the context actx
csound = await Csound({audioContext: actx});
// copy the CSD file to the Csound local filesystem
await copyUrlToLocal(csd,csd)
// compile the code in the CSD file
await csound.compileCsd(csd)
// handle Csound messages
await csound.on("message", handleMessage);
// start the engine
await csound.start();
isOn = true;
}
// start performance if paused
if(!isOn) {
 actx.resume();
 isOn = true;
}
}
```

Note that we have also removed the toggling of performance on/off,
because this function will only be responsible to start playback. We
will have a separate function to toggle pause on/off, which is only
operational if the Csound engine has been started,

```
// toggle performance on/off
function pause() {
if(csound != null) {
if(isOn) {
 actx.suspend();
 isOn = false;
} else  {
 actx.resume();
 isOn = true;
}
}
}
```

In addition to this, we will add score rewind functionality,

```
// rewind score
async function rewind() {
if(csound != null) await csound.rewindScore();
}
```

The csound object also has methods to check for score time position,
and to advance/rewind to specific points. These may be employed to
make a more complete score playback interface.

Finally, in this example we will use a more sophisticated means of displaying
Csound messages. This uses a multi-line scrolling display,

```
let count = 0;
function handleMessage(message) {
// get the display element (called console in the page)
var element = document.getElementById('console');
// add the message to HTML content (plus a newline)
element.innerHTML += message + '\n';
// focus on bottom, new messages make the display scroll down
element.scrollTop = 99999;
// clear display every 1000 lines
if(count == 1000) {    
count = 0;
element.innerHTML == "";
}
count += 1;
};
```

HTML body
-----

The HTML code now has three distinct buttons for play, pause, and
rewind. The pause and rewind buttons are only operational after the
Csound performance has started. The pause button toggles and the
play button also responds to a paused state, resuming performance.
The page is dominated by a largish console, which is used to display
the messages from Csound.

```
<p>
<input type="button" id="rew" onclick="rewind()" value="<<">
</input>
<input type="button" id="play" onclick="start()" value=">">
</input>
<input type="button" id="pause" onclick="pause()" value="||">
</input>
</p>
    <p>
      <textarea class="console" cols="80" rows="20" id="console">
      </textarea>
    <p>
<hr>

```

Conclusions
---

In this example, we have used John Chowning's composition Stria, which
is set as a single CSD file (with a large numeric score) to
demonstrate two aspects of Csound WASM: how to use server files, and
how to control a Csound score performance.

