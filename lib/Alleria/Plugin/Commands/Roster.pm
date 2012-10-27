package Alleria::Plugin::Commands::Roster;
use Alleria::Core 'strict';

Alleria->load(qw{ message commands roster subscription });

Alleria->commands({
	roster       => 'Print online users from roster',
	'roster-all' => 'Print all users in roster',

	'roster-add' => {
		description => 'Add user to roster',
		arguments   => '<user@example.com>',
	},

	'roster-del' => {
		description => 'Remove user from roster',
		arguments   => '<user@example.com>',
	},
});

Alleria->focus('message::command', sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my $jid = $message->{'arguments'} || '';
	my $reply;

	given ($message->{'command'}) {
		$reply = join "\n", 'Roster:', $self->roster('online')
			when 'roster';

		$reply = join "\n", 'Roster:', $self->roster()
			when 'roster-all';

		when ('roster-add') {
			continue unless $jid;

			# Add jid to roster and subscribe
			$self->subscribe($jid);
			$self->RosterAdd(jid => $jid);

			$reply = 'User added';
		}

		when ('roster-del') {
			continue unless $jid;

			# When item is removed from roster
			# all subscriptions are cancelled
			# so there's no need to do unsubscribe
			$self->RosterRemove(jid => $jid);

			$reply = 'User removed';
		}

		when (m{^roster-(?:add|del)$}) {
			$reply = 'No JID supplied';
		}
	}

	$reply and $self->message({
		to   => $message->{'from'},
		body => $reply,
	});
});

1;
