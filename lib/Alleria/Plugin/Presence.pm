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

# http://tools.ietf.org/html/rfc6121#section-4.7.2.1
Alleria->extend(presence => sub {
	my ($self, $type, $status) = @_;
	my %presence;

	undef $type unless
		$type and grep { $_ eq $type } qw{ away chat dnd xa };

	$presence{'type'} = $type if $type;
	$presence{'status'} = $status if $status;

	$self->PresenceSend(%presence);

	return $self;
});

1;

=pod

=head1 NAME

Alleria::Plugin::Presence - Presence plugin for L<Alleria>

=head1 SYNOPSIS

	Alleria->load('presence');

	Alleria->focus('presence::subscribe' => sub {
		my ($self, $event, $args) = @_;
		my $presence = $args->[0];
		warn $presence->{'from'}. ' wants presence subscription';
	});

=head1 METHODS

This plugin adds one method to L<Alleria> class

=head2 C<presence>

Sends presence packet to server. All arguments are optional.

	$self->presence();
	$self->presence(away => 'Not here right now');

=head1 EVENTS

This plugins listens C<presence> event and fires the following ones

=head2 Status

=over 4

=item presence::status

=item presence::probe

=back

=head2 Subscription

=over 4

=item presence::subscribe

=item presence::subscribed

=item presence::unsubscribe

=item presence::unsubscribed

=back

=head2 Availability

=over 4

=item presence::available

=item presence::unavailable

=back

=head1 SEE ALSO

L<Alleria::Core>, L<Alleria>

=cut
