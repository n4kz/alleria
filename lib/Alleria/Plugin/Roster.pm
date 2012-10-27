package Alleria::Plugin::Roster;
use Alleria::Core 'strict';

my $roster;

Alleria->load('presence');

Alleria->focus(connect => sub {
	my ($self, $event, $args) = @_;

	$self->RosterRequest();
	$roster = $self->Roster();
});

Alleria->extend(roster => sub {
	my ($self, $type) = @_;
	my @jids = $roster->jids();

	given ($type) {
		@jids = grep { $roster->online($_) } @jids
			when 'online';

		@jids = grep { not $roster->online($_) } @jids
			when 'offline';
	}

	return sort map { $_->GetJID() } @jids;
});

1;
