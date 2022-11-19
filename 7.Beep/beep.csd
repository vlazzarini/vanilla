<CsoundSynthesizer>
<CsOptions>
-o audio.wav
</CsOptions>
<CsInstruments>
0dbfs=1
instr 1
out linen(oscili(p4,p5),0.1,p3,0.1)
endin

</CsInstruments>
<CsScore>
i1 0 10 0.5 440
</CsScore>
</CsoundSynthesizer>