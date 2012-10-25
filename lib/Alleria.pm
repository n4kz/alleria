package Alleria 3;
use Alleria::Core 'base', 'has';
use Term::ReadKey;
use Net::Jabber 'client';

my %events;

sub events { \%events }

has qw{
	debug host port tls ssl timeout client jid
	ok logfile
	username password resource
};

sub new {
	my $self = SUPER::new { shift } @_;

	unless ($self->{'password'}) {
		print "Password:";
		ReadMode 2;
		chomp($self->{'password'} = readline STDIN);
		ReadMode 0;
		print "\n";
	}

	$self->{'ok'}         = 1;
	$self->{'debug'}    ||= 0;
	$self->{'tls'}      ||= 0;
	$self->{'ssl'}      ||= 0;
	$self->{'timeout'}  ||= 2;
	$self->{'port'}     ||= 5222;
	$self->{'resource'} ||= 'Alleria';
	$self->{'logfile'}  ||= '/dev/null';

	return $self;
} # new

sub start {
	my ($self) = @_;

	$self->client(
		Net::Jabber::Client->new(
			debuglevel => $self->debug(), 
			debugfile  => 'stdout',
		)
	);

	$self->Connect(
		hostname => $self->host(),
		port     => $self->port(),
		timeout  => $self->timeout(),
		tls      => $self->tls(),
		ssl      => $self->ssl(),
	) or return $self->fire('error', ['Connection error: '. $!]);

	$self->SetCallBacks(
		presence => sub { $self->fire(presence => [pop]) },
		message  => sub { $self->fire(message  => [pop]) },
		iq       => sub { $self->fire(iq       => [pop]) },
	);

	my @auth = $self->AuthSend(
		username => $self->username(),
		password => $self->password(),
		resource => $self->resource(),
	);
	
	if ($auth[0] eq 'ok') {
		$self->fire('connect');
		$self->PresenceSend();
	} else {
		$self->fire('error', ['Authentication failed', @auth]);
	}

	return $self;
} # start

sub stop {
	my ($self) = (@_);

	$self->Disconnect();
	$self->fire('disconnect');

	return $self;
} # stop

sub process {
	my ($self) = (@_);

	if ($self->Connected()) {
		$self->Process() // $self->stop();
	} else {
		$self->connect();
	}

	return $self;
} # process

sub AUTOLOAD {
	my $method = our $AUTOLOAD;
	$method =~ s{^.*::} {};

	return if $method eq 'DESTROY';

	return unless ref $_[0];
	my $client = shift->client();

	$method = UNIVERSAL::can($client, $method);
	return unless $method;

	return $method->($client, @_);
} # AUTOLOAD

1;
