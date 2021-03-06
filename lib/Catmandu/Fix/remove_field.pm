package Catmandu::Fix::remove_field;

use Catmandu::Sane;

our $VERSION = '1.0201';

use Moo;
use namespace::clean;
use Catmandu::Fix::Has;

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);

sub emit {
    my ($self, $fixer) = @_;
    my $path = $fixer->split_path($self->path);
    my $key  = pop @$path;

    $fixer->emit_walk_path(
        $fixer->var,
        $path,
        sub {
            my $var = shift;
            $fixer->emit_delete_key($var, $key);
        }
    );
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::remove_field - remove a field form the data

=head1 SYNOPSIS

   # Remove the foo.bar field
   remove_field(foo.bar)

=head1 SEE ALSO

L<Catmandu::Fix>

=cut
