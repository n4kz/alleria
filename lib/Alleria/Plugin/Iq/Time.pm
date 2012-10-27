package Alleria::Plugin::Iq::Time;
use Alleria::Core 'strict';
use DateTime;
use DateTime::Format::W3CDTF;

my $w3c = DateTime::Format::W3CDTF->new();

# Get valid timezone offset
$w3c->format_datetime(DateTime->now(time_zone => 'local')) =~ m{([+-]\d\d:\d\d)};
my $tz = $1 || '+00:00';

Alleria->load('iq');

# Deprecated
# http://xmpp.org/extensions/xep-0090.html
Alleria->focus('iq::jabber:iq:time' => sub {
	my ($self, $event, $args) = (@_);
	my ($callback, $iq) = @$args;
	my ($query, $reply) = $callback->();

	$query->SetDisplay(time);
});

# http://xmpp.org/extensions/xep-0202.html
Alleria->focus('iq::urn:xmpp:time' => sub {
	my ($self, $event, $args) = (@_);
	my ($callback, $iq) = @$args;
	my ($query, $reply) = $callback->();
	my $utc = $w3c->format_datetime(DateTime->now(time_zone => 'UTC'));

	$query->SetTZO($tz);
	$query->SetUTC($utc);
});

Alleria->feature('jabber:iq:time');
Alleria->feature('urn:xmpp:time');

# Define namespace for urn:xmpp:time
Net::XMPP::Namespaces::add_ns(
	ns    => 'urn:xmpp:time',
	tag   => 'time',
	xpath => {
		TZO => {
			type => ['special', 'time-tz'],
			path => 'tzo/text()',
		},
		UTC => {
			type => ['special', 'time-utc'],
			path => 'utc/text()',
		},
		Time => {
			type => ['master', 'all'],
		},
	},
	docs  => {
		 module => 'Net::Jabber',
	},
);

1;
