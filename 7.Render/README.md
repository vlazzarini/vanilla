Render
===

This simple example demonstrates how to run Csound offline, rendering
its output to a file. Once that is completed, we can retrieve the file
from the local browser filesystem, copy it and make it available for
opening or downloading. In general, rendering a complete performance
is faster than realtime, therefore this is a useful functionality
provided by Csound.


CsoundObj API code used
-----------

The following CsoundObj method is used for the first time in this
tutorial:

`.fs.readFile(src)`: read a file from the local browser filesystem as
a byte array.


JS Script
---

The JS script will vary slightly from previous examples, since we are
going to render the output to a file instead of playing it in
realtime. Because of this, we can ignore the audio context and run
the code as soon as the page is loaded, with waiting for any user
action. Once the output is rendered, we can give the user the option
to open it in a new tab, or to download it directly.

The `start()` function is still used to import and create a Csound
engine object. However, we now choose a worker thread to do the
sound processing,

```
// Csound engine object running on a worker thread
csound = await Csound({useWorker: true});
```

This will replace the Web Audio AudioWorklet processing thread with
a vanilla JS worker thread. We can retrieve the CSD file  and compile
it as before, but now, following this, we set the output option to a
file instead,

```
// set the output file name
await csound.setOption("-o"+filename);
```

We will choose the ogg vorbis format, which is a compressed audio
format very common on the web,

```
await csound.setOption("--ogg");
```

Then we will set a message handler as in the previous example and
start Csound. Finally, we will set up a listener to respond to the end
of the render,

```
await csound.on("renderEnded", finish);
```

This can then be used to cleanup the performance and copy the file
from the local filesystem into a Blob and produce a URL,

```
// this is called on render end
async function finish() {
// stop Csound and close output file
await csound.cleanup();
// copy output file and get a URL
fwav = await copyUrlFromLocal(filename, 'audio/ogg');
// notify the console
handleMessage("Complete: " + filename + " ready");
// enable the download button
document.getElementById('download').disabled = false;
// enable the open button
document.getElementById('open').disabled = false;
}
```

This code uses a function to get the file data and return a URL
representing it,

```
// copy file from local and return a URL for it
async function copyUrlFromLocal(src,t) {
// get the file as a Uint8Array
data = await csound.fs.readFile(src);
// create a data blob
destfile = new Blob([data.buffer], { type: t});
// create a URL for it
return window.URL.createObjectURL(destfile);
}
```

Now, the user can have two options:

1. Open the file in a new tab, which will play it,

```
// this is called by the open button
async function openf() {
// create an anchor element
a = document.createElement('a');
// append it to html body
document.body.appendChild(a);
// set the anchor URL
a.href = fwav;
// open in a different tab
a.target = "_blank";
// click on the element
a.click();
}
```
2. Or, alternatively, download it,

```
// this is called by the download button
async function download() {
// create an anchor element
a = document.createElement('a');
// append it to html body
document.body.appendChild(a);
// set the anchor URL
a.href = fwav;
// set the download name
a.download = filename;
// click on the element
a.click();
}
```


HTML body
-----
The HTML body is again very simple, but one important difference
from previous examples is that we define a callback for `onload`,
which happens when the page is loaded,

```
<body onload="start()">
```

The page is composed of two buttons,
which are initially disabled. When the rendering is complete, they
get enabled and the user can access the file data. We also have
the same console as in the previous example, which allows the
user to track progress.

```
<input type="button" id="open" onclick="openf()" value="open" disabled>
<input type="button" id="download" onclick="download()"
value="download" disabled>
</input>
</p>
<p>
<textarea class="console" cols="80" rows="20" id="console">
</textarea>
<p>
```

Conclusions
---

In this example, we have demonstrated the way to run Csound
offline to render an audio file. The output can then be directly
opened for listening or downloaded by the browser to the
client filesystem.

