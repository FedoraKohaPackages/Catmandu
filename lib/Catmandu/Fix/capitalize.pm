package Catmandu::Fix::capitalize;

use Catmandu::Sane;
use Catmandu::Util qw(:is :data as_utf8);
use Moo;

has path  => (is => 'ro', required => 1);
has key   => (is => 'ro', required => 1);
has guard => (is => 'ro');

around BUILDARGS => sub {
    my ($orig, $class, $path) = @_;
    my ($p, $key, $guard) = parse_data_path($path);
    $orig->($class, path => $p, key => $key, guard => $guard);
};

sub fix {
    my ($self, $data) = @_;

    my $key = $self->key;
    my @matches = grep ref, data_at($self->path, $data, key => $key, guard => $self->guard);
    for my $match (@matches) {
        if (is_array_ref($match)) {
            is_integer($key) || next;
            my $val = $match->[$key];
            $match->[$key] = ucfirst lc as_utf8 $val if is_string($val);
        } else {
            my $val = $match->{$key};
            $match->{$key} = ucfirst lc as_utf8 $val if is_string($val);
        }
    }

    $data;
}

=head1 NAME

Catmandu::Fix::capitalize - capitalize the value of a key

=head1 SYNOPSIS

   # Capitalize the value of foo. E.g. foo => 'bar'
   capitalize('foo');  # foo => 'Bar'

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
