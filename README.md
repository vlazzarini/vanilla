The Absolute Vanilla Guide to Webaudio Csound
========

This repository holds a step-by-step guide to using Webaudio Csound (aka Csound
WASM) from an absolute vanilla perspective. This means that we are going to try to demonstrate its use with a minimum of requirements and dependencies. This guide should be useful if you are

* already used to Csound, but with little JS or web app development experience.
* with little knowledge of Csound or JS, but is keen to know what's all about.
* an experienced Csounder who wants to find more ways to deploy your music.
* has some experience with certain web environments like p5.js and wants to add audio to your practice.

These tutorials are not designed for

* learning Csound.
* finding out about the sound processing capabilities of Csound.
* learning JS and modern Web app development practices.
* a web app developer wanting to use Csound as a package in your toolkit

For the first of the above, look at the resources listed at [learning Csound] (https://csound.com/get-started.html) and follow the links. Also look for
courses and videos on the system that may be available (online or otherwise).
To find out about the processing capabilities, also look at [csound.com](https://csound.com), [Cabbage](https://cabbageaudio.com/),
and the work at places like [Puremagnetik](https://puremagnetik.com/) where you can see Csound used for various digital audio applications. Finally, if you are a web developer or want to become one, using Csound WASM as part of your ecosystem,
it is probably best if you follow Steven and Hlodver's [tutorials] (http://kunstmusik.github.io/icsc2022-csound-web).

The tutorials here are organised in the various sub-directories, each with a README explaining what you will see in the code (which is also fully annotated). The repository has everything you need to run the examples locally, and if you want to deploy the pages to your own site, it is just a matter of copying the sources (html, js, csd, etc) as required.

Requirements
----

There are no external dependencies or requirements, but you will need

1. An up-to-date modern browser (e.g. Chrome, Firefox, Safari, etc).  
2. A command-line interpreter (e.g. a terminal, or command.com on Windows) to
run a local web server, git, etc.  
3. A text editor to write html/JS.

Pages containing Csound WASM code need to be served via http (the file protocol is not enough). You will need to run a local http server, for this you can use Python3, through the command

```
python3 -m http.server
```

The root of the web server is located in the working directory from where you run this command. The examples in this repository expect this to be run from the top-level directory.

There are other alternatives to this: you can run the node.js `http-server`, if you have it installed.

In any case, the URL you will need to give your browser is `localhost:port` where `port` is set by the server as it starts up.








