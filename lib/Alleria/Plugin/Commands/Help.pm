package Alleria::Plugin::Commands::Help;
use Alleria::Core 'strict';

my $template = join '', readline DATA;

Alleria->load('commands')->commands({
	help => {
		description => 'List available commands or print command info',
		arguments => '[command]',
	},
});

Alleria->focus('message::command', sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my $command = $message->{'arguments'} || '';
	my $reply;

	given ($message->{'command'}) {
		when ('help') {
			unless ($command) {
				$reply = "\nAvailable commands:\n". join ", ", sort $self->accessibles($message->{'from'});
			} else {
				my $meta = $self->description($command)
					if not $self->loaded('access') or $self->accessible({
						rule => 'commands',
						name => $command,
						from => $message->{'from'},
					});

				if (defined $meta) {
					my $invocation = join $command. ' ', '#', $meta->{'arguments'} || '';
					$reply = sprintf $template, $command, $invocation, $meta->{'description'} || 'Unavailable';
				}

				$reply //= 'No such command';
			}
		}
	}

	$reply and $self->message({
		to   => $message->{'from'},
		body => $reply,
	});
});

close DATA;

1;

__DATA__

Command: %s
Invocation: %s
Description: %s
