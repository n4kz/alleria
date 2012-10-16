use Alleria::Core 'strict';
use Data::Dumper;

my %fields = map { ("Get$_" => lc) } qw{ To From Type Status Show };

Alleria->focus(presence => sub {
	my ($self, $event, $args) = @_;
	my $presence = $args->[0];
	my %presence = map { ( $fields{$_} => $presence->$_() || '' ) } keys %fields;
	$event .= '::';

	$presence{'from'}     =~ m{^(.*?@.*?)(?:/(.*))?$};
	$presence{'resource'} = $2 || '';
	$presence{'from'}     = $1;

	given ($presence{'type'} || 'status') {
		$event .= 'status'
			when 'status';

		$event .= $presence{'type'}
			when m{(?:un)?subscribed?};

		1 when 'unavailable'; # TODO: read standard

		default {
			undef $event;
			warn 'presence';
			warn Dumper(\%presence);
		}
	}

	$self->fire($event, [\%presence]) if defined $event;
});

Alleria->extend(subscribe => sub {
	my ($self, $to) = (@_);

	$self->Subscription(
		to   => $to,
		type => 'subscribe',
	);

	$self->Subscription(
		to   => $to,
		type => 'subscribed',
	);
});

Alleria->extend(unsubscribe => sub {
	my ($self, $to) = (@_);

	$self->Subscription(
		to   => $to,
		type => 'unsubscribe',
	);

	$self->Subscription(
		to   => $to,
		type => 'unsubscribed',
	);
});

1;
