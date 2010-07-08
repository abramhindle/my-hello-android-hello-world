use Harbinger;
use IO::File;
use strict;

use constant PI => 3.14159;


my $H = Harbinger->new(port=>30666, LocalAddr => "192.168.0.242");
if ($ARGV[0] eq "-print") {
        $H->addHandler("AndroidBalls",new Harbinger::DebugHandler());
        $H->run;
        exit(0);
}
my $jackit = 0;
$H->addHandler("AndroidBalls",new
        Harbinger::PipeHandler(
                'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio planets.orc planets.sco":
		                    "csound -dm6 -+rtaudio=jack  -o devaudio -b 400 -B 1200 -L stdin planets.orc planets.sco"),
                autoflush=>1,
                terminator=>$/,
                filter=>\&wrap_filterit,
        )
);
#records the score
my $file = "scores/".time().".sco";
my $fd = IO::File->new($file, "w+");
warn "READY";
my $then = time;
my %balls = ();

sub update_ball {
        my ($color,$x,$y,$radius) = @_;
        my $ball = $balls{$color} || {};
        $ball->{instrument} = $ball->{instrument} || choose(qw(1902 1903 2));
        $ball->{xv} = $x - $ball->{x};
        $ball->{yv} = $y - $ball->{y};
        $ball->{x} = $x;
        $ball->{y} = $y;
        $ball->{radius} = $radius;
        $ball->{id} = $color;
        $balls{$color} = $ball;
        return  $ball;
}

$fd->autoflush(1);
$H->run;

sub wrap_filterit {
    my ($name,$id,$dest,$smsg) = filterit(@_);
    if ($smsg) {
        foreach my $msg (split($/,$smsg)) {
            next unless $msg;
            my @parts = split(/\s+/,$msg);
            my $newtime = time - $then;
            $parts[1] += $newtime;
            $fd->print(join(" ",@parts).$/);
        }
    }
    return ($name,$id,$dest,$smsg);
}
sub cs {
        my ($instr,$time,$dur,@o) = @_;
        my $str = join(" ",("i$instr",(map { sprintf('%0.3f',$_) } ($time,$dur,@o)))).$/;
        return $str;
}
sub filterit {
        my ($self,$name,$id,$dest,$msg) = @_;
        my @args = split(/\s+/,$msg);
        my $command = shift @args;
        my $freq;
        my $loudness;
        if ($msg =~ /Ball: (.*)$/) {
            my $args = $1;
            my ($x,$y,$color,$radius) = split(/\s+/,$args);
            my $ball = update_ball($color,$x,$y,$radius);
            my ($xv,$yv) = ($ball->{xv}, $ball->{yv});
            my $mass = 100*$radius;
            my $theta = atan2($xv,$yv);
            my $theta2 = atan2($x,$y);
            my $nmsg="";
            my $instrument = $ball->{instrument};
            if ($instrument eq "1902") {
        
                 $nmsg =  cs("1902",0.01,0.1 + 0.2 * abs(cos($mass * $radius)),
                                (2000*$theta*log(1.0+$mass * $radius)/25.0),
                                (6.000 +  $theta2 / PI + 3.0 * log(1.0 + ($xv*$xv+$yv*$yv)/$radius)/24.0),
                                0.9, 0.136, 0.45, 0.40);
            } elsif ($instrument eq "1903") {
			#         START  DUR    AMP      PITCH   PRESS  FILTER     EMBOUCHURE  REED TABLE
			# i 1903    0    16     6000      8.00     1.5  1000         .2            1
			my $mag = sqrt(($xv * $xv) + ($yv * $yv));
			#my $dur = 0.4 + 0.2 * ($xv / $mag);
			my $dur = 0.4 + 0.2* ($xv / $mag);
			my $amp = 200 + 3000*abs(cos($mass * $radius * $yv * $yv));
			my $pitch = 7.0 + 1.5 * $theta / PI;
			my $filter = 800 + min(20 * log($mass),300);
			my $pressure = 1.0 + 0.1 * log($mass)/30.0 + 0.9  * $theta / PI;
			$nmsg = cs("1903", 0.01, $dur,
					$amp,
					$pitch,
					$pressure,
					$filter,
					0.2,
					1);
            } elsif ($instrument eq "2") {
               my $duration = 0.2*$radius;
               my $loudness = 0.3*(100 + $y);
               my $pitch = abs(40 + abs(240 - $y) + abs(320 - $x) + 40*$theta);
               my $wait = 0.001+0.2*rand();
               $nmsg = "i1 $wait $duration $loudness $pitch";
            }
	    warn $ball->{instrument};

            return ($name,$id,$dest,$nmsg);
        }
        warn "DID NOT HANDLE: $msg";
        return ($name,$id,$dest,undef);
}
sub choose { return @_[rand(@_)]; }
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
