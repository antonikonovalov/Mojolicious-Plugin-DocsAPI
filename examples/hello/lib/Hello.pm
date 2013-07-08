package Hello;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Router
	my $r = $self->routes;

	$r->name('hello');

	# Normal route to controller
	$r->get('/')->to('example#welcome');

	my $welcome = $r->bridge('/welcome')->to('example#welcome');

 	$welcome->get('/controller')->to('controller#welcom');

	$self->plugin('DocsAPI');
}

1;
