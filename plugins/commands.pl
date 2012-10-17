use Alleria::Core 'strict';

my %commands;

Alleria->load('message');

Alleria->shackleshot(fire => sub {
	my ($self, $event, $args) = @{ $_[1] };
	my $message = $args->[0];

	return 1 unless $event eq 'message::chat';
	return 1 unless $message->{'body'} =~ m{^#};

	($message->{'command'}, $message->{'arguments'}) = split m{[\s\t\n\r]+}, $message->{'body'}, 2;
	$message->{'command'} =~ s{^#} {};

	# TODO: Do this in more obvious way
	return 1 unless $commands{$message->{'command'}};

	if ($self->can('accessible')) {
		return 1 unless $self->accessible({
			rule => 'commands',
			from => $message->{'from'},
			name => $message->{'command'}
		});
	}

	$self->fire('message::command', $args);

	return 0;
}, 1);

Alleria->extend(commands => sub {
	$commands{$_} = 1 foreach @_[1 .. $#_];
	return $_[0];
});

1;
