use Alleria::Core 'strict';

Alleria->focus('error', sub {
	my ($self, $event, $args) = @_;
	die $args->[0];
});

1;
