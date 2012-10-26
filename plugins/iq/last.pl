use Alleria::Core 'strict';
my $last = time;

Alleria->load(qw{ message iq });

Alleria->shackleshot(message => sub { $last = time });

# http://xmpp.org/extensions/xep-0012.html
Alleria->focus('iq::jabber:iq:last' => sub {
	my ($self, $event, $args) = (@_);
	my ($callback, $iq) = @$args;
	my ($query, $reply) = $callback->();

	$query->SetSeconds(time - $last);

	# <query xmlns='jabber:iq:last' seconds='123456' />
	$iq->{'empty'} = 1;
});

Alleria->feature('jabber:iq:last');

1;
