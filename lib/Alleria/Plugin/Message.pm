package Alleria::Plugin::Message;
use Alleria::Core 'strict';

my %fields = map { ("Get$_" => lc) } qw{ Body From Subject Type TimeStamp XML };

Alleria->focus(message => sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my %message = map { ( $fields{$_} => $message->$_() || '' ) } keys %fields;

	$message{'from'}     =~ m{^(.*?@.*?)(?:/(.*))?$};
	$message{'resource'} = $2 || '';
	$message{'from'}     = $1;

	given ($message{'type'}) {
		when (m{(?:group)?chat}) {
			# Fire chatstate event
			# TODO: Namespace
			# http://xmpp.org/extensions/xep-0085.html 
			$self->fire(join('::', $event, $1), [\%message]) if 
				$message{'xml'} =~ m{((?:in)?active|composing|paused|gone) xmlns=.http://jabber.org/protocol/chatstates};

			# Fall through if message also contains body
			return unless $message{'body'};
			continue;
		}

		when ('groupchat') {
			$event .= '::groupchat';
			$event .= '::system' unless $message{'resource'};
			$event .= '::delay'  if $message{'xml'} =~ m{xmlns=.jabber:x:delay.}i;
		}

		$event .= '::chat'
			when 'chat';

		default {
			undef $event;
		}
	}

	$self->fire($event, [\%message]) if defined $event;
});

Alleria->extend(message => sub {
	my ($self, $options) = (@_);
	$options->{'type'} ||= 'chat';

	$self->MessageSend(
		map {
			$_ => $options->{$_}
		} qw{ to body type }
	) if $options->{'to'} and $options->{'body'};

	return $self;
});

1;

=pod

=head1 NAME

Alleria::Plugin::Message - Message plugin for L<Alleria>

=head1 SYNOPSIS

	Alleria->load('message');

	Alleria->focus('message::chat', sub {
		my ($self, $event, $args) = @_;
		my $message = $args->[0];

		$self->message({
			to => $message->{'from'},
			body => $message->{'body'},
		});
	});

=head1 METHODS

This plugin adds one method to L<Alleria> class

=head2 C<message>

	$self->message({
		to   => 'test@example.com',
		body => 'Sample message',
		type => 'chat'
	});

=head1 EVENTS

This plugins listens C<message> event and fires the following ones

=head2 General

=over 4

=item message::chat

=item message::groupchat

=item message::groupchat::system

=item message::groupchat::delay

=item message::groupchat::system::delay

=back

=head2 Chatstates

=over 4

=item message::active

=item message::inactive

=item message::composing

=item message::paused

=item message::gone

=back

=head1 SEE ALSO

L<Alleria::Core>, L<Alleria>

=cut
