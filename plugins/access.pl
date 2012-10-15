use Alleria::Core 'strict';

Alleria->properties('rules');

Alleria->extend(accessible => sub {
	my ($self, $args) = @_;
	my $rules = $self->rules() || {};

	my $command = $args->{'command'} || '';
	my $user = $args->{'from'};
	my ($host) = ($user =~ m{@(.*)$});

	return 1
		if grep {
			$_ eq $command or $_ eq '*'
		} map {
			@{ $_ || [] }
		} map {
			$rules->{$_}
		} $user, '*@'. $host, '*';

	return 0;
});

1;
