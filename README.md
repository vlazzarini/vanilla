The Absolute Vanilla Guide to Webaudio Csound
========

This repository holds a step-by-step guide to using Webaudio Csound (aka Csound
WASM) from an absolute vanilla perspective. This means that we are going to try to demonstrate its use with a minimum of requirements and dependencies. This guide should be useful if you are

* already used to Csound, but with little JS or web app development experience.
* someone with little knowledge of Csound or JS, but keen to know what's all about.
* an experienced Csounder who wants to find more ways to deploy your music.
* has some experience with certain web environments like p5.js and wants to add audio to your practice.

These tutorials are not designed for

* learning Csound.
* finding out about the sound processing capabilities of Csound.
* learning JS and modern Web app development practices.
* a web app developer wanting to use Csound as a package in your toolkit

For the first of the above, look at the resources listed at [learning Csound](https://csound.com/get-started.html) and follow the links. Also look for
courses and videos on the system that may be available (online or otherwise).
To find out about the processing capabilities, also look at [csound.com](https://csound.com), [Cabbage](https://cabbageaudio.com/),
and the work at places like [Puremagnetik](https://puremagnetik.com/)
where you can see Csound used for various digital audio
applications. Finally, if you are a web developer with some
experience, and wants to use Csound WASM as part of your ecosystem,
it is probably best if you follow Steven and Hlodver's
[tutorials](http://kunstmusik.github.io/icsc2022-csound-web).


The tutorials here are organised in various sub-directories, each
with a README explaining what you will see in the code (which is also
fully annotated). The repository has everything you need to run the
examples locally, and if you want to deploy the pages to your own
site, it is just a matter of copying the sources (html, js, csd, etc)
as required. The Csound WASM code is imported from a
content delivery network (CDN) server in each example, making
the webpage self-contained.

You can also fork this whole repository to start your
own Csound WASM projects.

Requirements
----

To explore these tutorials, you will need

1. An up-to-date modern browser (e.g. Chrome, Firefox, Safari, etc).  
2. A web server app or script (optional for some examples, required
   for others)
3. A text editor to write html/JS.

*Web server*: Some of the examples need to be served via
http (in cases where the file protocol is not enough). All examples
can be run from a server, but some may also be run locally just by
opening the html file in your browser using the `file:` protocol.

To run a local http server, you can use Python3, through the command
`python3 -m http.server`.  The root of the web server is located in
the working directory from where you run this command. The examples in
this repository expect this server to be run from the top-level directory.

There are other alternatives to this, for example, you can run the node.js
`http-server`, if you have it installed. In any case, the URL you will
need to give your browser is `localhost:port` where `port` is set by
the server as it starts up. More details are given below

Csound JS
---

Csound is implemented in the JS source file `csound.js`, which can be
imported from a CDN URL, for example

```
https://cdn.jsdelivr.net/npm/@csound/browser@6.18.7/dist/csound.js
```

or

```
https://www.unpkg.com/@csound/browser@6.18.7/dist/csound.js
```

The advantage of using this URL is that in this case a page using Csound does not
need to be loaded from a http server, it can just be opened from a
file.

For your own projects, you can either use this URL or else you can get Csound
using the node.js package manager `npm` by installing the
[package](https://www.npmjs.com/package/@csound/browser) `@csound/browser`

```
npm install @csound/browser
```

where you will find it in the `dist` directory. Alternatively, this
file is also found in a
[public URL](https://www.jsdelivr.com/package/npm/@csound/browser?path=dist).

If you are providing your own `csound.js`, then you will need to serve
your page through http or https.


Csound WASM API Reference
-------

The API reference for Csound WASM can be found in
[wasm/browser](https://github.com/csound/csound/tree/csound6/wasm/browser)
(for Csound 6.x) or
[wasm/browser](https://github.com/csound/csound/tree/develop/wasm/browser)
(for Csound 7.x) directory of the Csound [sources](https://github.com/csound/csound). 

Start Here
-------

If you have no experience programming for the web, here are a few
pointers to start with. I would recommend looking at the HTML5 and JS
tutorials at https://www.w3schools.com/, which provide really good
introductions to the area.

To start playing and modifying these examples in your computer,
open a terminal/command-line and clone this repository using git:

```
git clone https://github.com/vlazzarini/vanilla
```

and cd to its top-level directory

```
cd vanilla
```

As outlined above, some examples will require a http server in your
computer. For others you can just open the file in your browser. For
example, on MacOS you may use the `open` command.

```
open 1.Ping/index.html
```

For all examples, you can also start a local server and run the top-level
page from there. If you have Python 3 installed in your computer, run
the command

```
python3 -m http.server
```

Alternatively, you can install [node.js](https://nodejs.org/en/download/),
which comes with a http server, started by the command

```
http-server
```

Now open your browser and enter the URL given by the server at the
console, which should be `localhost:xxxx`, where `xxxx` is the port
that depends on the server started. You will see the `index.html`
page (which contains this text) and you can follow the links to the different tutorials.

Each tutorial is given as an `index.html` in the respective directory.
You can open that file with your prefered text editor and explore it,
making modifications, etc. On page reload, your changes should take
effect. Also note that each directory has a README discussing the
example in great detail, and a link to is given on the respective
index.html page.

Tutorials
---

The following are the links to the web pages containing the tutorials
in this guide. Except wherever noted all these html pages can be
opened directly in the browser.

### Csound 6.x

These examples are written using the Csound 6.x API:

1.[Ping](1.Ping/.): this demonstrates how to import
Csound WASM, start an engine, compile code and play a sound in
response to a user action.  
2.[Penta](2.Penta/.): this example sets up a HTML5
  button keyboard to control Csound events.  
3.[Sliders](3.Sliders/): in this tutorial, we use HTML5
  range input elements to control sound synthesis parameters.  
4.[Plucks](4.Plucks/.): this shows how to evaluate code on
the fly and display Csound console messages.  
5.[Nodes](5.Nodes/.): this example places Csound within the
 Web Audio API context and connecting to other audio Nodes.  
6.[Stria](6.Stria/.): this demonstrates how to deal with
server files and control playback of the numeric score. This example
uses local files that need to be served over http and so can only
be run from a server.  
7.[Render](7.Render/.): this tutorial shows offline
  rendering, as well as opening and downloading output audio
  files. This example uses local files that need to be served over http and so can only
  be run from a server.  
8.[Reso](8.Reso/.): in this example, we
  interface Csound with an external JS API, p5.js, which
  provides realtime performance controls for the instrument. Also
  available as a
  [sketch](https://editor.p5js.org/vlazzarini/sketches/rDcPlRF3w)
  on the p5.js editor environment.  
9.[WTab](9.WTab/.): this demonstrates the use of
  function tables and how to transfer data in and out of Csound to/from an
  interactive graphical user interface provided by p5.js.  Also
  available as a
  [sketch](https://editor.p5js.org/vlazzarini/sketches/1gWAWKZkd)
  on the p5.js editor environment.  
10.[Tonnetz](10.Tonnetz/.): this example introduces MIDI control,
  with interactive graphics also provided by p5.js. Also
  available as a
  [sketch](https://editor.p5js.org/vlazzarini/sketches/vZIDsTYhQ)
  on the p5.js editor environment. This example
  uses local files that need to be served over http and so can only 
  be run from a server.  
11.[Rubber](11.Rubber/.): in this tutorial, realtime input audio is
introduced to realise a web app with a p5.js interface.  Also
  available as a
  [sketch](https://editor.p5js.org/vlazzarini/sketches/4F4NBQ0Fy)
  on the p5.js editor environment.  
  
### Csound 7.0

These examples are written using the Csound 7.0 API:

1.[Ping](7.0/1.Ping/.): this demonstrates how to import
Csound WASM, start an engine, compile code and play a sound in
response to a user action.  
2.[Penta](7.0/2.Penta/.): this example sets up a HTML5
  button keyboard to control Csound events.  
3.[Sliders](7.0/3.Sliders/): in this tutorial, we use HTML5
  range input elements to control sound synthesis parameters.  
4.[Plucks](7.0/4.Plucks/.): this shows how to evaluate code on
the fly and display Csound console messages.  
5.[Nodes](7.0/5.Nodes/.): this example places Csound within the
 Web Audio API context and connecting to other audio Nodes.  
6.[Stria](7.0/6.Stria/.): this demonstrates how to deal with
server files and control playback of the numeric score. This example
uses local files that need to be served over http and so can only
be run from a server.  
7.[Render](7.0/7.Render/.): this tutorial shows offline
  rendering, as well as opening and downloading output audio
  files. This example uses local files that need to be served over http and so can only
  be run from a server.  
8.[Reso](7.0/8.Reso/.): in this example, we
  interface Csound with an external JS API, p5.js, which
  provides realtime performance controls for the instrument.  
9.[WTab](7.0/9.WTab/.): this demonstrates the use of
  function tables and how to transfer data in and out of Csound to/from an
  interactive graphical user interface provided by p5.js.  
10.[Tonnetz](7.0/10.Tonnetz/.): this example introduces MIDI control,
  with interactive graphics also provided by p5.js. This example
  uses local files that need to be served over http and so can only 
  be run from a server.  
11.[Rubber](7.0/11.Rubber/.): in this tutorial, realtime input audio is
introduced to realise a web app with a p5.js interface.  


These tutorials can be accessed and forked from
[github](https://github.com/vlazzarini/vanilla/).







