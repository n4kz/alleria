use Alleria::Core 'strict';

Alleria->focus(['presence::subscribe', 'presence::unsubscribe'], sub {
	my ($self, $event, $args) = (@_);
	my $presence = $args->[0];
	my $from = $presence->{'from'} || '';
	my $method = (split '::', $event, 2)[1];

	$self->$method($from)
		if ($self->can('accessible') || sub { 1 })->({
			rule => 'actions',
			from => $from,
			name => $method,
		});
});

1;
