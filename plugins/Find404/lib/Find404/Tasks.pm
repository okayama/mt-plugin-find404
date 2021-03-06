package Find404::Tasks;
use strict;

use MT::Util qw( is_valid_url offset_time_list );
use MT::Mail;

sub _task_find404 {
    my $plugin = MT->component( 'Find404' );
    if ( my $find404_url = $plugin->get_config_value( 'find404_url' ) ) {
        my @urls = split( /\r?\n/, $find404_url );
        for my $url ( @urls ) {
            next unless $url;
            next unless is_valid_url( $url );
            my $ua = MT->new_ua( { timeout => 10 } );
            my $req = HTTP::Request->new( GET => $url );
            my $response = $ua->request( $req );
            if ( ! $response->is_success() ) {
                if ( my $mail_to = $plugin->get_config_value( 'mail_to' ) ) {
                    my $mail_subject = $plugin->get_config_value( 'mail_subject' );
                    my $mail_body = $plugin->get_config_value( 'mail_body' );
                    my $mail_from = $plugin->get_config_value( 'mail_from' );
                    unless ( $mail_from ) {
                        $mail_from = MT->config->EmailAddressMain;
                    }
                    if ( my $blog = MT->model( 'blog' )->load( { class => '*' }, { limit => 1 } ) ) {
                        my %params = (
                            url => $url,
                        );
                        $mail_subject = _build_tmpl( $mail_subject, $blog->id, \%params );
                        $mail_body = _build_tmpl( $mail_body, $blog->id, \%params );
                        my @mail_to = split( /\r?\n/, $mail_to );
                        my %head = (
                            To => \@mail_to,
                            From => $mail_from,
                            Subject => $mail_subject,
                        );
                        MT::Mail->send( \%head, $mail_body );
                    }
                } else {
                    MT->log( $plugin->translate( '[_1] unexists.', $url ) );
                }
            } else {
                MT->log( $plugin->translate( '[_1] exists.', $url ) );
            }
        }
    }
}

sub _build_tmpl {
    my ( $text, $blog_id, $param ) = @_;
    return unless $text;
    return unless $blog_id;
    my $blog = MT->model( 'blog' )->load( { id => $blog_id } );
    return unless $blog;
    require MT::Template;
    require MT::Template::Context;
    my $tmpl = MT::Template->new;
    $tmpl->name( 'Find404' );
    $tmpl->text( $text );
    $tmpl->blog_id( $blog_id );
    my $ctx = MT::Template::Context->new;
    $ctx->stash( 'blog', $blog );
    $ctx->stash( 'blog_id', $blog_id );
    my @tl = &offset_time_list( time, undef );
    my $ts = sprintf "%04d%02d%02d%02d%02d%02d", $tl[ 5 ] + 1900, $tl[ 4 ] + 1, @tl[ 3, 2, 1, 0 ];
    $ctx->{ current_timestamp } = $ts;
    for my $key ( keys %$param ) {
        $ctx->{ __stash }->{ vars }->{ $key } = $$param{ $key };
    }
    my $res = $tmpl->build( $ctx )
        or return MT->instance->error( MT->translate( $tmpl->errstr ) );
    return $res;
}

1;
