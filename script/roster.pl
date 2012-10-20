#!/usr/bin/perl -w -Ilib
use Alleria;
use Alleria::Core 'strict';

Alleria->load(qw{ error commands/roster commands/system });
Alleria->load(qw{ iq/last iq/time iq/version });

unless (@ARGV == 1) {
	print "Usage: $0 'username\@host'", $/;
	exit;
}

my ($user, $host) = split '@', $ARGV[0], 2;

my $bot = Alleria->new(
	username => $user,
	host     => $host,
	tls      => 1,
);

$bot->start();

$bot->process() while $bot->ok();

$bot->stop();
