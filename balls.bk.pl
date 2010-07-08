use Harbinger;

my $H = Harbinger->new(port=>30666, "LocalAddr" => "192.168.0.242" );
$H->addHandler("AndroidBalls",new Harbinger::DebugHandler());
$H->run;
