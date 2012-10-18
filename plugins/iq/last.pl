use Alleria::Core 'strict';
my $last = time;

Alleria->load(qw{ message iq });

Alleria->shackleshot(message => sub {
	$last = time;
});

Alleria->focus('iq::last::get' => sub {
	my ($self, $event, $args) = (@_);
	my ($iq, $request) = @$args;

	my $reply = $request->Reply(qw{ type result });
	my $query = $reply->NewQuery($iq->{'xmlns'});

	$query->SetSeconds(time - $last);

	$self->Send($reply);
});
