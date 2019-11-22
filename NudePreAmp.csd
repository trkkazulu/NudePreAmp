;NudePreAmp.csd bounds(0, 0, 0, 0)
; Written by Jair-Rohm Parker Wells, 2019.

; A hardcoded implementation of the Compressor opcode with a parametric eq

<Cabbage>
#define SLIDER_APPEARANCE trackercolour("DarkSlateGrey"), textcolour("black") 
form caption("NudePreAmp") size(300,330), pluginid("npmp") style("legacy"), bundle("brushed metal background 1305.jpg")
image bounds(0, 0, 300, 329) file("brushed metal background 1305.jpg") 
;image            bounds(0, 0, 440, 130), outlinethickness(6), , colour(128, 128, 128, 255)
;rslider bounds( 10, 10, 70, 70), channel("thresh"), text("Threshold"), range(0,120,0), $SLIDER_APPEARANCE
;rslider bounds( 80, 10, 70, 70), channel("att"), text("Attack"),  range(0,1,0.01,0.5), $SLIDER_APPEARANCE
;rslider bounds(150, 10, 70, 70), channel("rel"), text("Release"), range(0,1,0.05,0.5), $SLIDER_APPEARANCE
;rslider bounds(220, 10, 70, 70), channel("ratio"), text("Ratio"), range(1,300,10000,0.5), $SLIDER_APPEARANCE
rslider bounds(80, 34, 60, 60), channel("look"), text("Lookahead"), range(0, 1, 0.01, 0.5, 0.001), $SLIDER_APPEARANCE textcolour(0, 0, 0, 255) trackercolour(255, 0, 255, 255) colour(255, 100, 100, 255)
rslider bounds(80, 240, 60, 60), channel("gain"), text("Make Up"), range(-36, 36, 0, 1, 0.001), $SLIDER_APPEARANCE textcolour(0, 0, 0,255) trackercolour(255, 0, 255, 255), colour(255, 200, 100, 255)
rslider bounds(158, 240, 60, 60), channel("out"), text("Out Level"), range(0, 50, 0, 1, 0.001), $SLIDER_APPEARANCE textcolour(0, 0,0,255) trackercolour(255, 0, 255, 255), colour(255, 200, 100, 255)
;hrange   bounds(10, 80, 420, 30), channel("LowKnee","HighKnee"), range(0, 120, 48:60), $SLIDER_APPEARANCE
;label    bounds(10, 108, 420, 13), text("Soft Knee"), fontcolour(0, 0, 0, 255)
rslider bounds(50, 134, 60, 60) range(0, 10, 0, 1, 0.001), text("Attack") textcolour(0, 0, 0, 255), channel("attack") trackercolour(255, 0, 255, 255) colour(255, 100, 100, 255)
rslider bounds(120, 134, 60, 60) range(0, 2, 0, 1, 0.001), text("Growl") textcolour(0, 0, 0, 255), channel("growl") trackercolour(255, 0, 255, 255), colour(255, 100, 100, 255)
rslider bounds(190, 134, 60, 60) range(0, 10, 0, 1, 0.001), text("Purr") textcolour(0, 0, 0, 255), channel("purr") trackercolour(255, 0, 255, 255), colour(255, 100, 100, 255)
rslider bounds(152, 34, 60, 60) range(1, 300, 80, 0.5, 0.001), text("Coseyness"), channel("ratio") textcolour(0, 0, 0, 255) trackercolour(255, 0, 255, 255) colour(255, 100, 100, 255)

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

; Author: Jair-Rohm Parker Wells (2019)

instr 1

 aL,aR		ins	; read in live audio
; aL,aR	diskin2 "bassCR.wav", 1,1,1	
 							
 kthresh = 30.15 ;chnget		"thresh"
 kLowKnee = 34.63 ;chnget		"LowKnee"
 kHighKnee = 50.31 ;chnget		"HighKnee"
 katt	= 0.02	;chnget		"att"
 krel = 0.42	;chnget		"rel"
 kratio 	chnget		"ratio"
 kgain	 	chnget		"gain"
 klook = 0.01		;chnget		"look"  						; look-ahead time (this will have to be cast as an i-time variable)
 klook		init		0.01		
 kGrowl chnget "growl"	
 kOut chnget "out"		
 kAk chnget "attack"	
 kPur chnget "purr"	


 REINIT:
 aC_L 	compress aL, aL, kthresh, kLowKnee, kHighKnee, kratio, katt, krel, i(klook)	; compress both channels
 aC_R 	compress aR, aR, kthresh, kLowKnee, kHighKnee, kratio, katt, krel, i(klook)
 aC_L	*=	ampdb(kgain)								; apply make up gain
 aC_R	*=	ampdb(kgain)
 
 aoutL pareq aC_L, 120.00, kGrowl, .2, 0
 aoutR pareq aC_R, 120.00, kGrowl, .2, 0
 
 attOutL pareq aC_L, 3500.00, kAk, .3, 0
 attOutR pareq aC_R, 3500.00, kAk, .3, 0
 
 aPrOutL pareq aC_L, 630.00, kPur, .3, 0
 aPrOutR pareq aC_L, 630.00, kPur, .3, 0
 
 asig0L sum aoutL+attOutL+aPrOutL
 asig0R sum aoutR+attOutR+attOutR+aPrOutR
 
	outs	asig0L*kOut, asig0R*kOut
endin

</CsInstruments>

<CsScore>
i 1 0 [3600*24*7]									; play instr 1 for 1 week
</CsScore>

</CsoundSynthesizer>