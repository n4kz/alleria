package Alleria::Plugin::Muc;
use Alleria::Core 'strict';

Alleria->load(qw{ presence });

Alleria->extend(join => sub {
	my ($self, $room, $options) = @_;
	my $jid = Net::XMPP::JID->new($room);

	$self->MUCJoin(
		server   => $jid->GetServer(),
		room     => $jid->GetUserID(),
		password => $options->{'password'} || '',
		nick     => $options->{'nick'}     || 'alleria',
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

1;
