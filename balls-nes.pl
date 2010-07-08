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
                #'open'=>"csound -dm6 -L stdin -o devaudio 5balls.orc 5balls.sco",
		'open'=>((!$jackit)?"csound -dm6 -L stdin -o devaudio 5balls.orc 5balls.sco":"csound -dm6 -+rtaudio=jack  -o devaudio -b 400 -B 1200 -L stdin 5balls.orc 5balls.sco"),
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
my @instr = qw(500 501 502 503 504);
sub update_ball {
        my ($color,$x,$y,$radius) = @_;
        my $ball = $balls{$color} || {};
	if (!$ball->{instrument}) {
		$ball->{instrument} = shift @instr;
	}
        $ball->{xv} = $x - $ball->{x};
        $ball->{yv} = $y - $ball->{y};
        $ball->{x} = $x;
        $ball->{y} = $y;
	$ball->{xmax} = ($x > $ball->{xmax})?$x:$ball->{xmax};
	$ball->{ymax} = ($y > $ball->{ymax})?$y:$ball->{ymax};
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
            my $instrument = $ball->{instrument};
	    my $xmax = $ball->{xmax};
	    my $ymax = $ball->{ymax};
	    warn "$x $xmax";
            my $nmsg=cs($instrument,0,0.1,((1.0* ($x > 75)?$x:0) / $xmax));
	    my $miny = $ball->{y};
	    my $my = 0;
	    my $mymax = 0;
	    while (my ($k,$v) = each %balls) {
		$miny = min($v->{y},$miny);
		$my = max($v->{y},$my);
		$mymax = max($v->{ymax},$mymax);
	    }
	    $nmsg .= "$/".cs(600,0,0.1, 20 + 1000*(1.0*(($miny > 10)?$miny:0)) / (0.1+$mymax));
	    $nmsg .= "$/".cs(601,0,0.1, 100 + 2000*(1.0*(($my > 10)?$my:0)) / (0.1+$mymax));
            warn "miny $miny my $my mymax $mymax";
	    warn $nmsg;
            return ($name,$id,$dest,$nmsg);
        }
        warn "DID NOT HANDLE: $msg";
        return ($name,$id,$dest,undef);
}
sub choose { return @_[rand(@_)]; }
sub min { ($_[0] > $_[1])?$_[1]:$_[0] }
sub max { ($_[0] < $_[1])?$_[1]:$_[0] }
