#!/bin/bash
# jack is a bitch!
#jackd -d oss -r 22050  -p 400 &
jackd -d oss -r 44100  -p 400  &
#jackd -d oss -r 8000  -p 400 &
(sleep 2 ; jack_connect csound5:output1 system:playback_1) &
(sleep 2 ; jack_connect csound5:output1 system:playback_2) &
#;(sleep 2 ; jack_connect csound5:output1 system:playback_1) &
#;(sleep 2 ; jack_connect csound5:output1 system:playback_2) &
perl balls.pl
