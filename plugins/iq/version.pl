use Alleria::Core 'strict';

Alleria->load('iq');
Alleria->properties(qw{ name version });

Alleria->focus('iq::version::get', sub {
	my ($self, $event, $args) = (@_);
	my ($iq, $request) = @$args;

	my $reply = $request->Reply(qw{ type result });
	my $query = $reply->NewQuery($iq->{'xmlns'});

	$query->SetName($self->name() || 'Alleria'); 
	$query->SetVer($self->version() || $Alleria::VERSION);
	$query->SetOS($^O);

	$self->Send($reply);
});
