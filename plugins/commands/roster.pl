use Alleria::Core 'strict';

Alleria->load(qw{ message commands roster subscription });
Alleria->commands(qw{ roster roster-all roster-add roster-del });

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

			$reply = 'Item added';
		}

		when ('roster-del') {
			continue unless $jid;

			# When item is removed from roster
			# all subscriptions are cancelled
			# so there's no need to do unsubscribe
			$self->RosterRemove(jid => $jid);

			$reply = 'Item removed';
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
