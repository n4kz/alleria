package Alleria::Plugin::Muc;
use Alleria::Core 'strict';

Alleria->load(qw{ presence });

Alleria->extend(join => sub {
	my ($self, $room, $options) = @_;
	my $jid = Net::XMPP::JID->new($room);
	my $nick = $options->{'nick'} || 'alleria';

	$self->MUCJoin(
		server   => $jid->GetServer(),
		room     => $jid->GetUserID(),
		password => $options->{'password'} || '',
		nick     => $nick,
	);

	return $self;
});

Alleria->extend(leave => sub {
	my ($self, $room) = @_;

	$self->PresenceSend(
		type => 'unavailable',
		from => $self->jid(),
		to   => $room,
	);

	return $self;
});

Alleria->extend(nick => sub {
	my ($self, $room, $nick) = @_;

	$self->PresenceSend(
		from => $self->jid(),
		to   => join '/' $room, $nick,
	);

	return $self;
});

Alleria->extend(affiliation => sub {
	my ($self, $room, $jid, $affiliation, $reason) = @_;

	$affiliation = 'member'
		unless $affiliation and grep {
			$_ eq $affiliation
		} qw{ outcast none member admin owner };

	$self->iq(
		request => {
			from => $self->jid(),
			to   => $room,
			type => 'set',
		},

		'http://jabber.org/protocol/muc#admin' => {
			jid         => $jid,
			affiliation => $affiliation,
			reason      => $reason || 'Nothing personal',
		},
	);

	return $self;
});

Alleria->extend(role => sub {
	my ($self, $room, $nick, $role, $reason) = @_;

	$role = 'participant'
		unless $role and grep {
			$_ eq $role
		} qw{ none visitor participant moderator };

	$self->iq(
		request => {
			from => $self->jid(),
			to   => $room,
			type => 'set',
		},

		'http://jabber.org/protocol/muc#admin' => {
			nick   => $nick,
			role   => $role,
			reason => $reason || 'Nothing personal',
		},
	);

	return $self;
});

1;
