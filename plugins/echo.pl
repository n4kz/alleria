use Alleria::Core 'strict';

Alleria->load('message');

Alleria->focus('message::chat', sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];

	$self->message({
		to      => $message->{'from'},
		body    => $message->{'body'},
	});
});

1;
