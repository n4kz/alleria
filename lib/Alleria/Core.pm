package Alleria::Core;
use strict;
use warnings;
use feature ':5.10';
use utf8;

my (%shackled, %events, %plugins);

sub events { \%events }

# Alleria::Core->new(key => value, ...)
# Alleria::Core::new('Alleria', key => 'value', ...)
sub new (;$@) {
	my $invocant = ref $_[0] || $_[0] || caller || __PACKAGE__;

	return bless
		{
			@_[1 .. @_ - 1],
			@_ % 2? () : (undef)
		},
		$invocant;
} # new

# $self->extend(method => sub {});
sub extend ($$$) {
	my $slot = join '::', ref $_[0] || $_[0], $_[1];

	no strict 'refs';
	*$slot = $_[2];

	return $_[0];
} # extend

# $self->inherit('Package::Test', 'Test::Package', ...);
sub inherit ($@) {
	no strict 'refs';
	my $ISA = join '::', ref $_[0] || $_[0], 'ISA';
	push @$ISA, @_[1 .. @_ - 1];
} # inherit

# $self->properties($name, ...)
sub properties ($@) {
	my $package;

	foreach my $field (@_) {
		unless ($package) {
			$package = ref $_[0] || $_[0];
			next;
		}

		my $slot   = join '::', $package, $field;
		my $method = sub {
			return $_[0]->{$field} = $_[1] if @_ > 1;
			return $_[0]->{$field};
		};

		no strict 'refs';
		*$slot = $method;
	}

	return $_[0];
} # properties

# has 'name', 'length', ...;
# properties alias
sub has (@) {
	my $caller = caller;
	return unless $caller;

	properties $caller, @_; 
} # has

# $self->clear($method, ...)
sub clear ($@) {
	my $package;

	foreach (@_) {
		unless ($package) {
			$package = ref $_[0] || $_[0];
			next;
		}

		my $slot = join '::', $package, $_;

		no strict 'refs';

		undef *$slot;

		if (exists $shackled{$slot}) {
			*$slot = delete $shackled{$slot};
			         delete $shackled{join '::', $slot, '[]'};
		}
	}

	return $_[0];
} # clear

#         $self->shackleshot(method => sub {}, $prepend)
# Alleria::Core->shackleshot(method => sub {}, $prepend)
sub shackleshot ($$$$) {
	my $package = ref $_[0] || $_[0];
	my $slot    = join '::', $package, $_[1];
	my $key     = join '::', $slot,  '[]';
	my $chain   = $shackled{$key} ||= [];

	unless (@$chain) {
		my $coderef = UNIVERSAL::can($package, $_[1]);
		die 'Not a code reference' unless ref $coderef eq 'CODE';

		push @$chain, $shackled{$slot} = $coderef;

		# Wrap old method
		my $method = sub {
			my ($post, @result);

			foreach (@$chain) {
				if ($_ == $coderef) {
					# Call method in right context
					if (wantarray) {
						@result = &$_;
					} else {
						$result[0] = &$_;
					}
					$post = 1;
				} else {
					# Call hooks 
					last unless $_->($slot, \@_, \@result) or $post;
				}
			}

			return wantarray? @result : $result[0];
		};

		no strict 'refs';
		no warnings 'prototype', 'redefine';
		*$slot = $method;
	}

	if ($_[3]) {
		unshift @$chain, $_[2];
	} else {
		push @$chain, $_[2];
	}

	return $_[0];
} # shackleshot

#         $self->load('plugins/test.pl');
# Alleria::Core->load('plugins/test.pl', ...);
# Alleria::Core->load('test');
sub load ($@) {
	foreach (@_[1 .. $#_]) {
		local $_ = $_;
		s{^\.*/} {}g;
		s{^} {plugins/} unless m{^plugins};
		s{$} {.pl} unless m{\.p[lm]$};

		$plugins{$_} ||= eval "require '$_'" or die $@;
	}

	return $_[0];
} # load

#         $self->loaded('plugins/test.pl');
# Alleria::Core->loaded('test');
sub loaded ($@) { not grep { not $plugins{$_} } @_[1 .. $#_]; }

#         $self->fire('test', [1, 2, 3]);
# Alleria::Core->fire('test', [1, 2, 3]);
sub fire ($$$) {
	&$_ foreach @{ $_[0]->events->{$_[1]} ||= [] };

	return $_[0];
} # fire

#         $self->focus('test', sub {});
#         $self->focus(['test', 't2'], sub {});
# Alleria::Core->focus('test', sub {});
sub focus ($$$) {
	foreach (ref $_[1]? @{ $_[1] } : $_[1]) {
		push @{
			$_[0]->events->{$_} ||= []
		}, $_[2];
	}

	return $_[0];
} # focus

# use Alleria::Core 'base', 'strict', 'has'
sub import {
	return unless @_ > 1;

	foreach (@_[1 .. @_ - 1]) {
		inherit scalar caller, __PACKAGE__
			if m{base};

		extend scalar caller, 'has' => \&has
			if m{has};
	}

	strict->import();
	warnings->import();
	feature->import(':5.10');
} # import

1;
