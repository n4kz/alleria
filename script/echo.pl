#!/usr/bin/perl -Ilib
use Alleria;
use Alleria::Core 'strict';

unless (@ARGV == 1) {
	print "Usage: $0 'username\@host'", $/;
	exit;
}

my ($user, $host) = split '@', $ARGV[0], 2;
my $life = 100;

my $bot = Alleria->new(
	username => $user,
	host     => $host,
	tls      => 1,
);

$bot->load(qw{ echo error });

$bot->start();

$bot->process() while $life--;

$bot->stop();
