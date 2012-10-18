use Alleria::Core 'strict';

Alleria->load('iq');

# TODO: add urn:xmpp:time namespace support
# http://xmpp.org/extensions/xep-0202.html
Alleria->focus('iq::time::get' => sub {
	my ($self, $event, $args) = (@_);
	my ($iq, $request) = @$args;

	my $reply = $request->Reply(qw{ type result });
	my $query = $reply->NewQuery($iq->{'xmlns'});

	$query->SetDisplay(time);

	$self->Send($reply);
});
