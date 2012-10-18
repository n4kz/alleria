use Alleria::Core 'strict';

Alleria->properties(qw{ roster });
Alleria->load(qw{ message commands subscription });
Alleria->commands(qw{ roster roster-all roster-add roster-del });

Alleria->focus(connect => sub {
	my ($self, $event, $args) = @_;

	$self->RosterRequest();
	$self->roster($self->Roster());
});

Alleria->focus('message::command', sub {
	my ($self, $event, $args) = @_;
	my $message = $args->[0];
	my $jid = $message->{'arguments'} || '';
	my $reply;

	given ($message->{'command'}) {
		my $roster = $self->roster();

		when ('roster') {
			$reply = join "\n", 'Roster:',
				sort map {
					$_->GetJID()
				} grep {
					$roster->online($_)
				} $roster->jids();
		}

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

		when ('roster-all') {
			$reply = join "\n", 'Roster:',
				sort map {
					$_->GetJID()
				} $roster->jids();
		}
	}

	$reply and $self->message({
		to   => $message->{'from'},
		body => $reply,
	});
});

1;
