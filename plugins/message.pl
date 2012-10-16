use Alleria::Core 'strict';
use Data::Dumper;

my %fields = map { ("Get$_" => lc) } qw{ Body From Subject Type TimeStamp XML };

Alleria->focus(message => sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my %message = map { ( $fields{$_} => $message->$_() || '' ) } keys %fields;

	$message{'from'}     =~ m{^(.*?@.*?)(?:/(.*))?$};
	$message{'resource'} = $2 || '';
	$message{'from'}     = $1;

	given ($message{'type'}) {
		when ('groupchat') {
			$event .= '::groupchat';
			$event .= '::system' unless $message{'resource'};
			$event .= '::delay'  if $message{'xml'} =~ m{xmlns=.jabber:x:delay.}i;
		}

		$event .= '::chat'
			when 'chat';

		default {
			undef $event;
			warn 'message';
			warn Dumper(\%message);
		}
	}

	$self->fire($event, [\%message]) if defined $event;
});

Alleria->extend(message => sub {
	my ($self, $options) = (@_);

	$self->MessageSend(
		to      => $options->{'to'},
		type    => $options->{'type'}    || 'chat',
		subject => $options->{'subject'} || '',
		body    => $options->{'body'},
	) if $options->{'to'} and $options->{'body'};

	return $self;
});

1;
