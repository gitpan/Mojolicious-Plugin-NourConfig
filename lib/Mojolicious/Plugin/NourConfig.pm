package Mojolicious::Plugin::NourConfig;
use Mojo::Base 'Mojolicious::Plugin';
use Nour::Config;

has 'nour_config';

sub register {
    my ( $self, $app, $opts ) = @_;
    my $include_extra = delete $opts->{include_extra};

    $self->nour_config( new Nour::Config ( %{ $opts } ) );

    if ( $include_extra ) { # inherit some helpers from Nour::Base
        do { my $method = $_; eval qq|
        \$app->helper( $method => sub {
            my ( \$ctrl, \@args ) = \@_;
            return \$self->nour_config->$method( \@args );
        } )| } for qw/path merge_hash write_yaml/;
    }

    my $config = $self->nour_config->config;
    my $current = $app->defaults( config => $app->config )->config;
    %{ $current } = ( %{ $current }, %{ $config } );

    return $current;
}

1;

# ABSTRACT: imports config from a ./config directory full of nested yaml goodness

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::NourConfig - imports config from a ./config directory full of nested yaml goodness

=head1 VERSION

version 0.01

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
