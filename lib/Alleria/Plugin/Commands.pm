package Alleria::Plugin::Commands;
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

	return 1 unless $commands{$message->{'command'}};

	if ($self->loaded('access')) {
		return 1 unless $self->accessible({
			rule => 'commands',
			from => $message->{'from'},
			name => $message->{'command'}
		});
	}

	$message->{'arguments'} //= '';
	$message->{'arguments'} =~ s{[\s\t\n\r]+} { }g;
	$message->{'arguments'} =~ s{\s\Z} {};

	$self->fire('message::command', $args);

	return 0;
}, 1);

Alleria->extend(commands => sub {
	foreach (@_[1 .. $#_]) {
		$commands{$_} ||= {}, next unless ref;
		while (my ($command, $parameters) = each %$_) {
			$commands{$command} ||= ref $parameters? $parameters : { description => $parameters };
			$commands{$command} ||= '';
		}
	}

	return $_[0];
});

Alleria->extend(accessibles => sub {
	my ($self, $jid, $rule) = @_;
	
	return unless $jid;
	return keys %commands unless $self->loaded('access');
	return grep {
		$self->accessible({
			rule => $rule || 'commands',
			from => $jid,
			name => $_,
		})
	} keys %commands;
});

Alleria->extend(description => sub {
	my ($self, $command) = @_;

	return $commands{$command};
});

1;
