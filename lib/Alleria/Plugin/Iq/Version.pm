package Alleria::Plugin::Iq::Version;
use Alleria::Core 'strict';

Alleria->load('iq');
Alleria->properties(qw{ name version });

# http://xmpp.org/extensions/xep-0092.html
Alleria->focus('iq::jabber:iq:version', sub {
	my ($self, $event, $args) = (@_);
	my ($callback, $iq) = @$args;
	my ($query, $reply) = $callback->();

	$query->SetName($self->name() || 'Alleria'); 
	$query->SetVer($self->version() || $Alleria::VERSION);
	$query->SetOS($^O);
});

Alleria->feature('jabber:iq:version');

1;
