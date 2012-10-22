use Alleria::Core 'strict';

Alleria->load('commands')->commands({
	off    => 'Poweroff',
	uptime => 'Execute `uptime` and print result',
	uname  => 'Execute `uname -a` and print result',
});

Alleria->focus('message::command', sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my $reply;

	given ($message->{'command'}) {
		$reply = `uptime`
			when 'uptime';

		$reply = `uname -a`
			when 'uname';

		$self->ok(0)
			when 'off';
	}

	$reply and $self->message({
		to   => $message->{'from'},
		body => $reply,
	});
});

1;
