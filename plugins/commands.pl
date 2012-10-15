use Alleria::Core 'strict';

Alleria->load('message');

Alleria->shackleshot(fire => sub {
	my ($self, $event, $args) = @{ $_[1] };
	my $message = $args->[0];

	return 1 unless $event eq 'message::chat';
	return 1 unless $message->{'body'} =~ m{^#};

	($message->{'command'}, $message->{'arguments'}) = split ' ', $message->{'body'}, 2;
	$message->{'command'} =~ s{^#} {};

	return 1 unless $Alleria::commands->{$message->{'command'}};

	if ($self->can('accessible')) {
		return 1 unless $self->accessible($message);
	}

	$self->fire('message::command', $args);

	return 0;
}, 1);

package Alleria;
our $commands = {};

1;
