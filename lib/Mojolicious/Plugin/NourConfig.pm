package Mojolicious::Plugin::NourConfig;
use Mojo::Base 'Mojolicious::Plugin';
use Nour::Config;

has 'nour_config';

sub register {
    my ( $self, $app, $opts ) = @_;
    my $helpers = delete $opts->{ '-helpers' };
    my $silence = delete $opts->{ '-silence' };

    $self->nour_config( new Nour::Config ( %{ $opts } ) );

    if ( $helpers ) { # inherit some helpers from Nour::Base
        do { my $method = $_; eval qq|
        \$app->helper( $method => sub {
            my ( \$ctrl, \@args ) = \@_;
            return \$self->nour_config->$method( \@args );
        } )| } for qw/path merge_hash write_yaml/;
    }

    my $config = $self->nour_config->config;
    my $current = $app->defaults( config => $app->config )->config;
    %{ $current } = ( %{ $current }, %{ $config } );

    $app->log->debug( 'config', $app->dumper( $current ) ) unless $silence;

    return $current;
}

1;

# ABSTRACT: Imports config from a ./config directory full of nested YAML goodness.

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::NourConfig - Imports config from a ./config directory full of nested YAML goodness.

=head1 VERSION

version 0.03

=head1 USAGE / SYNOPSIS

Place your YAML configuration files under a ./config sub-directory from your mojo app's home directory.
There's an example in the package tarball you can look at, but roughly something like this:

     $ find ./config/
    ./config/
    ./config/application
    ./config/application/nested
    ./config/application/nested/example.yml
    ./config/application.yml
    ./config/database
    ./config/database/private
    ./config/database/private/production.yml
    ./config/database/private/README.md
    ./config/database/config.yml

Somewhere in your startup routine, include something like this:

    $self->plugin( 'Mojolicious::Plugin::NourConfig', {
        -base => 'config'
        , -helpers => 1 # adds some unrelated helper methods i wrote
        , -silence => 1 # turning this on disables the config dump on startup in the debug log
    } );

On application startup, if you haven't turned the silence option on you can see your configuration from the debug log:

    [Tue Apr  8 12:10:21 2014] [debug] config
    {
      'application' => {
        'nested' => {
          'example' => {
            'wow' => 'amazing'
          }
        },
        'secret' => 'don\'t tell anyone'
      },
      'database' => {
        'default' => {
          'database' => 'production',
          'option' => {
            'AutoCommit' => '1',
            'PrintError' => '1',
            'RaiseError' => '1',
            'pg_bool_tf' => '0',
            'pg_enable_utf8' => '1'
          },
          'password' => 'nour',
          'username' => 'nour'
        },
        'development' => {
          'dsn' => 'dbi:Pg:dbname=nourdb_dev',
          'password' => 'sharabash',
          'username' => 'nour'
        },
        'production' => {
          'dsn' => 'dbi:Pg:dbname=nourdb_prod;host=secret.com',
          'password' => 'secret',
          'username' => 'override'
        }
      }
    }

Neat, right? Yeah.

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/sharabash/mojolicious-plugin-nourconfig/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/sharabash/mojolicious-plugin-nourconfig>

  git clone git://github.com/sharabash/mojolicious-plugin-nourconfig.git

=head1 AUTHOR

Nour Sharabash <amirite@cpan.org>

=head1 CONTRIBUTOR

Nour Sharabash <nour.sharabash@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Nour Sharabash.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
