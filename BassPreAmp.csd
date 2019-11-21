; Compressor.csd bounds(0, 0, 0, 0)
; Written by Iain McCurdy, 2016.

; Encapsulation of the compressor opcode

; A compressor is a dynamics processor that essentially applies waveshaping to an audio signal.
; In the case of a typical compressor, increasingly high dynamics will be increasingly attenuated thereby reducing the dynamic range of a signal.
; This can be useful in forcing a dynamically expressive signal to sit better within a mix of signals or for processing a final mix so that it functions better when listened to in an environment with background noise. 

; When reference is made to a soft knee, this is the part of the dynamic mapping function that separates the lower response region and the upper response region. 
; Below the 'knee' the dynamic tranformation is 1:1, i.e. no change. 

; Threshold	-	Lowest decibel level that will be allowed through. Can be used to remove low level noise from a signal. A setting of zero will defeat this feature.  
; Low Knee	-	Decibel point at which the 'soft knee' 
; High Knee	-	Decibel point at which the 'soft knee' terminates
; Attack	-	Attack time of the compressor
; Release	-	Release time of the compressor
; Ratio		-	Compression ratio of the upper compressor response region
; Lookahead	-	Essentially this is a delay that will be applied to the signal that will be compressed (the track signal will always be un-delayed).
;			This can be useful for making sure that the compressor responds appropriately to fast attacks (at the expense of some added latency by the delay).
;			This is an initialisation time parameter so making changes to it will interrupt the realtime audio stream
; Gain		-	A make-up gain control. Use this to compensate for loss of power caused by certain ocmpressor settings.


; Add a parametric equalizer and simplify the compressor

<Cabbage>
#define SLIDER_APPEARANCE trackercolour("DarkSlateGrey"), textcolour("black") 
form caption("BassPreAmp") size(500,230), pluginid("bpmp") style("legacy")
image            bounds(  0,  0,440,130), outlinethickness(6), outlinecolour("white"), colour("grey")
;rslider bounds( 10, 10, 70, 70), channel("thresh"), text("Threshold"), range(0,120,0), $SLIDER_APPEARANCE
;rslider bounds( 80, 10, 70, 70), channel("att"), text("Attack"),  range(0,1,0.01,0.5), $SLIDER_APPEARANCE
;rslider bounds(150, 10, 70, 70), channel("rel"), text("Release"), range(0,1,0.05,0.5), $SLIDER_APPEARANCE
;rslider bounds(220, 10, 70, 70), channel("ratio"), text("Ratio"), range(1,300,10000,0.5), $SLIDER_APPEARANCE
rslider bounds(290, 10, 70, 70), channel("look"), text("Lookahead"), range(0,1,0.01,0.5), $SLIDER_APPEARANCE
rslider bounds(360, 10, 70, 70), channel("gain"), text("Gain"), range(-36, 36, 0, 1, 0.001), $SLIDER_APPEARANCE textcolour(0, 0, 0, 255) trackercolour(47, 79, 79, 255)
;hrange   bounds(10, 80, 420, 30), channel("LowKnee","HighKnee"), range(0, 120, 48:60), $SLIDER_APPEARANCE
;label    bounds(10, 108, 420, 13), text("Soft Knee"), fontcolour(0, 0, 0, 255)
rslider bounds(30, 148, 60, 60) range(0, 1, 0, 1, 0.001), text("Attack")
rslider bounds(170, 150, 60, 60) range(0, 1, 0, 1, 0.001), text("Growl")
rslider bounds(276, 152, 60, 60) range(0, 1, 0, 1, 0.001), text("Purr")
rslider bounds(360, 150, 60, 60) range(1,300,80,0.5), text("Coseyness"), channel("ratio")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-d -n
</CsOptions>

<CsInstruments>

;sr is set by the host
ksmps = 32
nchnls = 2
0dbfs = 1

; Author: Iain McCurdy (2016)

instr 1
 ;aL,aR		ins									; read in live audio
 aL,aR	diskin2 "bassCR.wav", 1,1,1								
 kthresh = 30.15 ;chnget		"thresh"						; read in widgets
 kLowKnee = 34.63 ;chnget		"LowKnee"
 kHighKnee = 50.31 ;chnget		"HighKnee"
 katt	= 0.02	;chnget		"att"
 krel = 0.42	;chnget		"rel"
 kratio 	chnget		"ratio"
 kgain	 	chnget		"gain"
 klook = 0.01		;chnget		"look"  						; look-ahead time (this will have to be cast as an i-time variable)
 klook		init		0.01							
; if changed(klook)==1 then								; if slider is moved...
;  reinit REINIT										; ... reinit
; endif
 REINIT:
 aC_L 	compress aL, aL, kthresh, kLowKnee, kHighKnee, kratio, katt, krel, i(klook)	; compress both channels
 aC_R 	compress aR, aR, kthresh, kLowKnee, kHighKnee, kratio, katt, krel, i(klook)
 aC_L	*=	ampdb(kgain)								; apply make up gain
 aC_R	*=	ampdb(kgain)
	outs	aC_L,aC_R
endin

</CsInstruments>

<CsScore>
i 1 0 [3600*24*7]									; play instr 1 for 1 week
</CsScore>

</CsoundSynthesizer>