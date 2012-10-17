use Alleria::Core 'strict';

Alleria->load('commands');
Alleria->commands(qw{ uptime uname free off });

Alleria->focus('message::command', sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my $reply;

	given ($message->{'command'}) {
		$reply = `uptime`
			when 'uptime';

		$reply = `uname -a`
			when 'uname';

		$reply = `free -m`
			when 'free';

		$self->ok(0)
			when 'off';
	}

	$reply and $self->message({
		to   => $message->{'from'},
		body => $reply,
	});
});

1;
