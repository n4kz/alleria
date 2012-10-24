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

Message plugin for L<Alleria>

=head1 SYNOPSIS

	Alleria->load('message');

	Alleria->focus('message::chat', sub {
		my ($self, $event, $args) = @_;
		my $message = $args[0];

		$self->message({
			to => $message->{'from'},
			body => $message->{'body'},
		});
	});

=head1 METHODS

This plugin adds one method to Alleria class

=head2 message

	$self->message({
		to   => 'test@example.com',
		body => 'Sample message',
		type => 'chat'
	});

=head1 EVENTS

This plugin listens message event and fires the following ones

=head2 General

	message::chat
	message::groupchat
	message::groupchat::system
	message::groupchat::delay
	message::groupchat::system::delay

=head2 Chatstates

	message::active
	message::inactive
	message::composing
	message::paused
	message::gone

=cut
