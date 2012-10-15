use Alleria::Core 'strict';

Alleria->extend(daemonize => sub {
	my $self = $_[0];

	open STDIN, '/dev/null' or die sprintf "Failed to redirect STDIN to /dev/null: %s", $!;
	open STDOUT, '>>', $self->logfile() or die sprintf "Failed to redirect STDOUT to %s: %s", $self->logfile(), $!;

	given (fork) {
		die sprintf "Fork failed: %s", $!
			when undef;

		1 when 0;

		default {
			exit;
		}
	}

	open STDERR, '>&STDOUT' or die sprintf "Failed to redirect STDERR: %s", $!;
});

1;
