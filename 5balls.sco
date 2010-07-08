; This is an attempt at an NES style vocoding of greg's fav song
f1	0	16384	10	2 	; sine table
f2	0	16384	10	1	1 0.5 0.333 0.25 0.2 0.1667 0.1429 0.125 0.1111 .1 0.0909 0.083; sawtooth table
f3	0	1024	7	1	512 1 0 -1 512 -1 ; square wave
; instrument starttime duration volume low freq hifreq table adj?
;i6  0	30 ; default sound	
f0 3600
i1 	0	3600	1	40	10000     3	0.5 ; play on table 3 the square wave
i600	0	1 	40 ; set low
i601	0	1 	800 ; set high
i500	0	1	0
i501	0	1	0
i502	0	1	0
i503	0	1	0
i504	0	1	0
;i500	1	1	1
;i501	3	1	1
;i500	3	1	0
;i502	9	1	1
;i501	9	1	0
;i503	12	1	1
;i504	15	1	1
;i503	15	1	0
;i1 	60	30	1	40	800	2	0.5 ; play on table 2 the sawtooth
;i1 	90	30	1	40	800	1	0.5 ; play on table 1 the sine
;i1 	120	30	1	100	1000    3	0.5 ; play on table 3 the square wave
;i1 	150	30	1	100	1000	2	0.5 ; play on table 2 the sawtooth
;i1 	180	30	1	100	1000	1	0.5 ; play on table 1 the sine
