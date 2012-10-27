package Alleria::Plugin::Access;
use Alleria::Core 'strict';

Alleria->properties('rules');

Alleria->extend(accessible => sub {
	my ($self, $args) = @_;
	my $rule = $args->{'rule'};
	my $rules = ($self->rules() || {})->{$rule} || {};

	my $name = $args->{'name'} || '';
	my $user = $args->{'from'} || '';
	my ($host) = ($user =~ m{@(.*)$});

	return 1
		if grep {
			$_ eq $name or $_ eq '*'
		} map {
			@{ $_ || [] }
		} map {
			$rules->{$_}
		} $user, '*@'. $host, '*';

	return 0;
});

1;
