package Alleria::Plugin::Subscription;
use Alleria::Core 'strict';

Alleria->load('presence');

Alleria->focus(['presence::subscribe', 'presence::unsubscribe'], sub {
	my ($self, $event, $args) = (@_);
	my $presence = $args->[0];
	my $from = $presence->{'from'} || '';
	my $method = (split '::', $event, 2)[1];

	$self->$method($from)
		if ($self->can('accessible') || sub { 1 })->($self, {
			rule => 'actions',
			from => $from,
			name => $method,
		});
});

Alleria->extend(subscribe => sub {
	my ($self, $to) = (@_);

	$self->Subscription(
		to   => $to,
		type => 'subscribe',
	);

	$self->Subscription(
		to   => $to,
		type => 'subscribed',
	);

	return $self;
});

Alleria->extend(unsubscribe => sub {
	my ($self, $to) = (@_);

	$self->Subscription(
		to   => $to,
		type => 'unsubscribe',
	);

	$self->Subscription(
		to   => $to,
		type => 'unsubscribed',
	);

	return $self;
});

1;
