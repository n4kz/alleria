package Alleria::Plugin::Iq;
use Alleria::Core 'strict';

my %fields = (
	GetTo         => 'to',
	GetFrom       => 'from',
	GetType       => 'type',
	GetError      => 'error',
	GetErrorCode  => 'code',
	GetQueryXMLNS => 'xmlns',
);

Alleria->focus(iq => sub {
	my ($self, $event, $args) = @_;
	my $iq = $args->[-1];
	my %iq = map { ($fields{$_} => $iq->$_() || '') } keys %fields;
	my ($reply, $query);

	given ($iq{'xmlns'}) {

		# Service discovery
		# http://xmpp.org/extensions/xep-0030.html
		when ('http://jabber.org/protocol/disco#info') {
			$reply = $iq->Reply(type => 'result');
			$query = $reply->NewQuery($iq{'xmlns'});

			$self->fire(info => [
				sub {
					$query
						->NewChild('__netjabber__:iq:disco:info:feature', 'feature')
						->SetVar($_[0]);
				}
			]);
		}

		# Other iq requests
		default {
			$self->fire(join('::', 'iq', $_), [sub {
				# Create reply only on demand
				$reply ||= $iq->Reply(type => 'result');
				$query ||= $reply->NewQuery($iq{'xmlns'});

				return $query, $reply;
			}, \%iq, $iq]);

			# Nodes were not added to query
			# so we have nothing to send
			undef $reply unless $query and $query->HasChildren() or $iq{'empty'};
		}
	}

	$self->Send($reply) if $reply;
});

Alleria->extend(feature => sub {
	my ($self, $feature) = @_;

	$self->focus(info => sub {
		my $callback = $_[2]->[0];

		$callback->($feature);
	});

	return $self;
})->feature('http://jabber.org/protocol/disco#info');

Alleria->extend(iq => sub {
	my ($self, %options) = @_;

	my $iq = Net::Jabber::IQ->new();
	$iq->SetIQ(%{ delete $options{'request'} || {} });

	$iq->NewChild($_)->AddItem($options{$_})
		foreach keys %options;

	$self->Send($iq);

	return $self;
});

# Extension to get children count for stanza
package Net::XMPP::Stanza;

sub HasChildren { +@{ ($_[0]->{'TREE'} || {})->{'CHILDREN'} || [] } };

1;
