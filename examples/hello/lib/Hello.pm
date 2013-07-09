package Hello;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	Mojolicious::Routes::Route->attr(docs => sub { {} });

	# Router
	my $r = $self->routes;

	$r->name('hello');

	# Normal route to controller
	$r->get('/')->to('example#welcome');

	my $user = $r->route('/user')->to('example#welcome');
	$user->route('/:id')->to('example#welcome');
	$r->route('/manager')->to('example#welcome');

	my $welcome = $r->bridge('/welcome')->to('example#welcome');

 	$welcome->get('/controller')
 		->to('controller#welcom')
 		->docs({
 			params => [{
 				name =>'user_n',
 				type => 'int'
 			},{
 				name =>'order_n',
 				type => 'int'
 			}],
 			dsc => 'В зависимости от user_n проверяется доступ к order_n',
 		});

	$self->plugin('DocsAPI',{
		handler => 'docs',	
	});
}

1;
