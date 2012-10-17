use Alleria::Core 'strict';

my %fields = (
	GetTo         => 'to',
	GetFrom       => 'from',
	GetType       => 'type',
	GetError      => 'error',
	GetErrorCode  => 'code',
	GetQueryXMLNS => 'xmlns',
);

Alleria->focus(iq => sub {
	my ($self, $event, $args) = @_;
	my $iq = $args->[-1];
	my %iq = map { ($fields{$_} => $iq->$_() || '') } keys %fields;

	$iq{'query'} = (split ':', $iq{'xmlns'})[-1];

	return unless $iq{'query'};

	$event = join '::',
		$event, 
		$iq{'query'},
		$iq{'type'};

	$self->fire($event, [\%iq, $iq]);
});

1;
