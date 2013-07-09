package Mojolicious::Plugin::DocsAPI;
use Mojo::Base 'Mojolicious::Plugin';
use Data::Dump qw/dump/;
use utf8;

our $VERSION = '0.01';

has config => sub { {} };

sub register {
	my ($plugin, $app, $config) = @_;

	my $base = __FILE__;
    $base =~ s/\.pm//;
    require File::Spec;

    push @{ $app->renderer->paths }, File::Spec->catdir( $base, 'templates' );
    push @{ $app->static->paths },   File::Spec->catdir( $base, 'public' );

	#route for analuse
	my $r = $app->routes;

	#config params
	my $api_version = '0.1';
	my $host = 'http://konovalov:3000' || 'http://localhost:3000' || 'http://' .  ref($app) . ':3000';
	my $base_path = '/api';
	my $base_path_docs = '/docs';

	$plugin->config({
		api_version => $api_version,
		base_path => $base_path,
		base_path_docs => $base_path_docs,
	});


	my $namespaces = $r->namespaces;

	my $routes = $plugin->_info($r);

	$r->get('docs' => sub {
			shift->render(template => 'docs');
		});

	$r->get('/api/docs' => sub {
		my $self = shift;
		my $data = [grep { $_->{path} and $_->{path} =~ qw/\/docs\/(hello|user|manager)/ } @{$plugin->_all($r)}];

		warn dump $plugin->_all($r);

		$self->res->headers->content_type('charset=UTF-8');
		$self->respond_to(
			json => { 
				json => {
					apiVersion => $api_version,
					swaggerVersion => '1.1',
					basePath => $host . $base_path,
					apis =>  $data,
				}
			},
			html => { 
				template => 'ui/index',
				root_public => '/swagger-ui/dist',
				base_url => $host . $base_path . $base_path_docs
			}
		);
	});

	$r->get('/api/docs/:name' => sub {
		my $self = shift;
		my $name = $self->stash('name');
		my $route = $r->find($name);

		if ($route) {
			my $routes_by_name = $plugin->_info($route);
			my $data = $plugin->_info_by_one_deep($route);

			push @$routes_by_name, $data;
			my $name = $route->name;

			$self->res->headers->content_type('application/json;charset=UTF-8');
			$self->render(json => {
				apiVersion => $api_version,
				swaggerVersion => '1.1',
				resourcePath => $route->to_string,
				basePath => $host,
				models => {
					$name => {
						id => $name,
						properties => {
							email => {
								type => 'string'
							},
							n => {
								type => 'int'
							},
							name => {
								type => 'string'
							}
						}	
					}
				},
				apis =>  $routes_by_name,
			});
		} else {
			$self->render(json => {
				msg => 'Not found route with this name',
				success => Mojo::JSON->false,
			});
		}

	});

}

sub _all {
	my ($self, $route) = @_;
	my $data = [];

	warn $route->name;

	return unless $route;

	foreach my $r (@{$route->children}) {
		my $d = $self->_info_by_one($r);

		push (@{$data}, $d);
	}

	return $data;
}

sub _info {
	my ($self, $route) = @_;
	my $apis = [];

	warn $route->name;

	return unless $route;

	foreach my $r (@{$route->children}) {
		my $api = $self->_info_by_one_deep($r);

		# if (@{$r->children}) {
		# 	$d->{routes} = $self->_info($r);
		# }

		push (@{$apis}, $api);
	}

	return $apis;
}

sub _info_by_one{
	my ($self, $route) = @_;

	return {
		path => $self->config->{base_path_docs} . $route->to_string,
		description => ''
	};
}

sub _info_by_one_deep {
	my ($self, $route) = @_;

	return {
		path => ($route->to_string ? $route->to_string : ''),
		description =>  $route->docs ? $route->docs->{dsc} : '',
		operations => [
			map {
				{
					httpMethod => $_,
					nickname => $route->name,
					responseClass => $route->to->{controller} . '->' . $route->to->{action},
					parameters => [
						{
						allowMultiple => Mojo::JSON->false,
						dataType => $route->name,
						description => "List of user object",
						paramType => "body",
						required => Mojo::JSON->true,
						}
					],
					summary => ''
				}
			} $route->via ? @{$route->via} : ('GET', 'POST', 'PUT', 'DELETE')
		]
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
