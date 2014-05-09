package Catmandu::Fix::Bind;

use Moo::Role;
use namespace::clean;

requires 'unit';
requires 'bind';

has fixes => (is => 'rw', default => sub { [] });

sub BUILD {
    warn "creating " . $_[0];
}

sub unit {
	my ($self,$data) = @_;
	return $data;
}

sub bind {
    my ($self,$data,$code,$name) = @_;
	return $code->($data);
}

sub finally {
    my ($self,$data) = @_;
    $data;
}

sub emit {
    my ($self, $fixer, $label) = @_;

    my $code = [ map { [ref($_) , $fixer->emit_fix($_)] } @{$self->fixes} ];
    my $perl = $self->emit_bind($fixer,$code);

    $perl; 
}

sub emit_bind {
    my ($self,$fixer,$code) = @_;

    my $var = $fixer->var;

    my $perl = "";

    my $bind_var = $fixer->capture($self);
    my $unit     = $fixer->generate_var;

    $perl .= "my ${unit} = ${bind_var}->unit(${var});";

    for my $pair (@$code) { 
        my $name = $pair->[0];
        my $code = $pair->[1]; 
        my $code_var = $fixer->capture($code);
        $perl .= "${unit} = ${bind_var}->bind(${unit}, sub {";
        $perl .= "${var} = shift;";
        $perl .= $code;
        $perl .= "${var}";
        $perl .= "},'$name',${code_var});"
    }

    $perl .= "${unit} = ${bind_var}->finally(${unit});" if $self->can('finally');
    
    $perl;
}

=head1 NAME

Catmandu::Fix::Bind - a Binder for fixes

=head1 SYNOPSIS

  package Catmandu::Fix::Bind::Demo;
  use Moo;
  with 'Catmandu::Fix::Bind';

  sub bind {
    my $(self,$data,$code,$name) = @_;
    warn "executing $name";
    $code->($data);
  }

  package main;
  use Catmandu::Importer::JSON;
  use Catmandu::Fix;

  my $importer = Catmandu::Importer::JSON->new(file => 'test.data');
  my $fixer = Catmandu::Fix->new(
           fixes => ['add_field("foo","bar"); set_field("foo","test")'],
           binds => ['Demo']
  );

  # This will print:
  #   executing add_field
  #   executing set_field
  #   executing add_field
  #   executing set_field
  $fixer->fix($importer)->each(sub {});

=head1 DESCRIPTION

Bind is a package that wraps Catmandu::Fix-es and other Catmandu::Bind-s together. This gives
the programmer further control on the excution of fixes. With Catmandu::Fix::Bind you can simulate
the 'before', 'after' and 'around' modifiers as found in Moo. 

A Catmandu::Fix::Bind needs to implement two methods: 'unit' and 'bind'.

=head1 METHODS

=head2 unit($data)

The unit method receives a Perl $data HASH and should return it. The 'unit' method is called on a 
Catmandu::Fix::Bind instance before all Fix methods are executed. A trivial implementation of 'unit' is:

  sub unit {
      my ($self,$data) = @_;
      return $data;
  }

=head2 bind($data,$code,$name,$perl)

The bind method is executed for every Catmandu::Fix method in the fixer. It receives the $data
, which as wrapped by unit, the fix method as anonymous subroutine, the name of the fix and the actual perl
code to run it. It should return the fixed code. A trivial implementaion of 'bind' is:

  sub bind {
	  my ($self,$data,$code,$name) = @_;
	  return $code->($data);
  } 

=head2 finally($data)

Optionally finally is executed on the data when all the fixes have run.

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
