use Alleria::Core 'strict';
use Data::Dumper;

my %fields = (
	GetTo         => 'to',
	GetFrom       => 'from',
	GetType       => 'type',
	GetError      => 'error',
	GetErrorCode  => 'code',
	GetQueryXMLNS => 'xmlns',
);

Alleria->focus('iq', sub {
	my ($self, $event, $args) = @_;
	my $iq = $args->[-1];
	my %iq = map { ($fields{$_} => $iq->$_() || '') } keys %fields;

	$event .= join '::',
		'', 
		($iq{'query'} = (split ':', $iq{'xmlns'})[-1]),
		$iq{'type'};

	$self->fire($event, [\%iq, $iq]);
});

1;
