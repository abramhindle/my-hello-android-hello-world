sr=8000
kr=8000
ksmps = 1
nchnls = 1
gkamp0 init 0
gkamp1 init 0
gkamp2 init 0
gkamp3 init 0
gkamp4 init 0

instr 6; simple output
   acar soundin "resampled.wav"
   
   out acar
endin

instr 500
	ivol = p4
	gkamp0 = k(ivol)
	turnoff
endin
instr 501
	ivol = p4
	gkamp1 = k(ivol)
	turnoff
endin
instr 502
	ivol = p4
	gkamp2 = k(ivol)
	turnoff
endin
instr 503
	ivol = p4
	gkamp3 = k(ivol)
	turnoff
endin
instr 504
	ivol = p4
	gkamp3 = k(ivol)
	turnoff
endin

; gklow
instr 600
	ilow = p4
	gklow = k(ilow)
	turnoff
endin
instr 601
	ihigh = p4
	gkhigh = k(ihigh)
	turnoff
endin

	

instr 1 ; 5 band vocoder - geometric bands
	idur       = p3
	igain      = p4
	ilow        = p5 ; the lowest frequency for the vocoder
	ihigh       = p6 ; the highest frequency for the vocoder
	itablec		= p7 ; which waveform to use for the oscillators
	ibandadj    = p8 ; an adjustment factor to make smaller-width bands
	
	acar soundin "resampled.wav"
	
	; determine the frequency bands
	
	; icoef pow ( ihigh / ilow ), ( 1. / 5. )
	kcoef pow ( gkhigh / gklow ), ( 1. / 5. )
    kb0=ilow;

	kb1 = kb0 * kcoef
	kb2 = kb1 * kcoef
	kb3 = kb2 * kcoef
	kb4 = kb3 * kcoef
	kb5 = kb4 * kcoef
    
    ;create a bunch of oscillators with which to recreate the input signal
    
	ar0 oscil 1,kb0,itablec
	ar1 oscil 1,kb1,itablec
	ar2 oscil 1,kb2,itablec
	ar3 oscil 1,kb3,itablec
	ar4 oscil 1,kb4,itablec
	
	
	amod=ar0+ar1+ar2+ar3+ar4

	; measure frequency band content of input 
	
	abpc0 butterbp acar, kb0, kb0*(kcoef-1.0)*ibandadj
	abpc1 butterbp acar, kb1, kb1*(kcoef-1.0)*ibandadj
	abpc2 butterbp acar, kb2, kb2*(kcoef-1.0)*ibandadj
	abpc3 butterbp acar, kb3, kb3*(kcoef-1.0)*ibandadj
	abpc4 butterbp acar, kb4, kb4*(kcoef-1.0)*ibandadj

	;recreate the input signal using an oscillator for each frequency band
	;ar0 = gkamp0 * ar0
	;ar1 = gkamp1 * ar1
	;ar2 = gkamp2 * ar2
	;ar3 = gkamp3 * ar3
	;ar4 = gkamp4 * ar4
	abpc0 = gkamp0 * abpc0
	abpc1 = gkamp1 * abpc1
	abpc2 = gkamp2 * abpc2
	abpc3 = gkamp3 * abpc3
	abpc4 = gkamp4 * abpc4
	;abpc0 = a(gkamp0)
	;abpc1 = a(gkamp1)
	;abpc2 = a(gkamp2)
	;abpc3 = a(gkamp3)
	;abpc4 = a(gkamp4)
	;
	;av0 balance a(gkamp0),ar0
	;av1 balance a(gkamp1),ar1
	;av2 balance a(gkamp2),ar2
	;av3 balance a(gkamp3),ar3
	;av4 balance a(gkamp4),ar4
	av0 balance ar0, abpc0
	av1 balance ar1, abpc1
	av2 balance ar2, abpc2
	av3 balance ar3, abpc3
	av4 balance ar4, abpc4
	
	;av0 = 3000 * ar0 * gkamp0
	;av1 = 3000 * ar1 * gkamp1
	;av2 = 3000 * ar2 * gkamp2
	;av3 = 3000 * ar3 * gkamp3
	;av4 = 3000 * ar4 * gkamp4
	
	
	
	; Mix and output
	
	aenv linseg 0, 0.01, 1, idur - 0.02, 1, 0.01, 0
	
	amixl = 0.9*( av0 + av1 + av2 + av3 + av4) 
	amixl = amixl * aenv * igain 
	
	out p4*amixl
	
endin

