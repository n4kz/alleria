package Alleria::Plugin::Presence;
use Alleria::Core 'strict';

my %fields = map { ("Get$_" => lc) } qw{ To From Type Status Show };

Alleria->focus(connect => sub {
	my ($self, $event, $args) = @_;

	$self->PresenceDB();
});

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

		1 when m{(?:un)?available};
		1 when 'probe';

		default {
			undef $event;
		}
	}

	$self->fire($event, [\%presence]) if defined $event;
});

1;
