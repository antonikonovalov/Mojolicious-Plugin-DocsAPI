package Mojolicious::Plugin::DocsAPI;
use Mojo::Base 'Mojolicious::Plugin';
use Data::Dump qw/dump/;

our $VERSION = '0.01';

sub register {
  my ($plugin, $app, $config) = @_;

  my $r = $app->routes;

  my $namespaces = $r->namespaces;

  my $routes = $plugin->_info($r);

  $r->get('docs' => sub {
  		shift->render(template => 'docs');
  	});

  $r->get('/api/docs' => sub {
  	my $self = shift;

  	$self->render(json => {
  		data => {
  			app => ref($app),
  			routes => $routes,
  		},
  		success => Mojo::JSON->true,	
  	});
  });

  $r->get('/api/docs/:name' => sub {
  	my $self = shift;
  	my $name = $self->stash('name');
  	my $route = $r->find($name);

  	if ($route) {
  		my $routes_by_name = $plugin->_info($route);
  		my $data = $plugin->_info_by_one($route);

  		$data->{app} = ref $app;

  		if (@{$routes_by_name}) {
			$data->{routes} = $routes_by_name;
  		}

	  	$self->render(json => {
	  		data => $data,
	  		success => Mojo::JSON->true,
	  	});
  	} else {
  		$self->render(json => {
	  		msg => 'Not found route with this name',
	  		success => Mojo::JSON->false,
	  	});
  	}

  });

}

sub _info {
	my ($self, $route) = @_;
	my $data = [];

	warn $route->name;

	return unless $route;

	foreach my $r (@{$route->children}) {
		my $d = $self->_info_by_one($r);

		if (@{$r->children}) {
			$d->{routes} = $self->_info($r);
		}

		push (@{$data}, $d);
	}

	return $data;
}

sub _info_by_one{
	my ($self, $route) = @_;

	return {
		url => $route->to_string,
		via => $route->via,
		to => $route->to,
		root => $route->root->name,
		name => $route->name,
	};
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::DocsAPI - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('DocsAPI');

  # Mojolicious::Lite
  plugin 'DocsAPI';

=head1 DESCRIPTION

L<Mojolicious::Plugin::DocsAPI> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::DocsAPI> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
