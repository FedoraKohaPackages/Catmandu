package Catmandu::Fix::Bind;

use Moo::Role;
use namespace::clean;

requires 'unit';
requires 'bind';

has fixes => (is => 'rw', default => sub { [] });

sub unit {
	my ($self,$data) = @_;
	return $data;
}

sub bind {
    my ($self,$data,$code,$name,$perl) = @_;
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

    # Poor man's monads using global state. Should be a bit
    # faster than nested binds. The finally method is required
    # to unwrap monadic values again to perl Hashes that
    # Catmandu::Fix can understand
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

    my $reject = $fixer->capture($fixer->_reject);
    $perl .= "return ${unit} if ${unit} == ${reject};";
    
    $perl;
}

=head1 NAME

Catmandu::Fix::Bind - a wrapper for Catmandu::Fix-es

=head1 SYNOPSIS

  package Catmandu::Fix::Bind::demo;
  use Moo;
  with 'Catmandu::Fix::Bind';

  sub bind {
    my ($self,$data,$code,$name) = @_;
    warn "executing $name";
    $code->($data);
  }

  # in your fix script you can now write
  do
     demo()

     fix1()
     fix2()
     fix3()
  end

  # this will execute all the fixes as expected, and print to STDERR the following messages

  executing fix1
  executing fix2
  executing fix3
   
=head1 DESCRIPTION

Bind is a package that wraps Catmandu::Fix-es and other Catmandu::Bind-s together. This gives
the programmer further control on the excution of fixes. With Catmandu::Fix::Bind you can simulate
the 'before', 'after' and 'around' modifiers as found in Moo or Dancer.

To wrap Fix functions, the Fix language has a 'do' statment:

  do BIND
     FIX1
     FIX2
     FIX3
  end

where BIND is a implementation of BIND and FIX1,...,FIXn are fix functions.

In the example above the BIND will wrap FIX1, FIX2 and FIX3.

A Catmandu::Fix::Bind needs to implement two methods: 'unit' and 'bind'.

=head1 METHODS

=head2 unit($data)

The unit method receives a Perl $data HASH and should return it, possibly converted to a new type. 
The 'unit' method is called before all Fix methods are executed. A trivial, but verbose, implementation 
of 'unit' is:

  sub unit {
      my ($self,$data) = @_;
      my $wrapped_data = $data;
      return $wrapped_data;
  }

=head2 bind($wrapped_data,$code,$name,$perl)

The bind method is executed for every Catmandu::Fix method in the fix script. It receives the $wrapped_data
(wrapped by 'unit'), the fix method as anonymous subroutine, the name of the fix and the actual perl
code which runs it as a string. It should return data with the same type as returned by 'unit'. 
A trivial, but verbose, implementaion of 'bind' is:

  sub bind {
    my ($self,$wrapped_data,$code,$name,$perl) = @_;
    my $data = $wrapped_data;
    $data = $code->($data);
    # we don't need to wrap it again because the $data and $wrapped_data have the same type
    $data;
  } 

=head2 finally($data)

Optionally finally is executed at the end the 'do' block. This method should be an inverse of unit (unwrap the data).
A trivial, but verbose, implementation of 'finally' is:

  sub finally {
    my ($self,$wrapped_data) = @_;
    my $data = $wrapped_data;
    $data;
  }

=head1 REQUIREMENTS

Bind mmodules are simplified implementations of Monads. They should answer the formal definition of Monads, codified 
in 3  monadic laws:

=head2 left unit: unit acts as a neutral element of bind

   my $monad = Catmandu::Fix::Bind->demo();

   # bind(unit(data), coderef) == coderef(data)
   $monad->bind( $monad->unit({foo=>'bar'}) , $coderef) == $coderef->({foo=>'bar'});

=head2 right unit: unit act as a neutral element of bind

   # bind(unit(data), unit) == unit(data)
   $monad->bind( $monad->unit({foo=>'bar'}) , sub { $monad->unit(shift) } ) == $monad->unit({foo=>'bar'});

=head2 associative: chaining bind blocks should have the same effect as nesting them

   # bind(bind(unit(data),f),g) == bind(unit(data), sub { return bind(f(data),g) } )
   my $f = sub { my $data = shift; $data->{demo} = 1 ; $data };
   my $g = sub { my $data = shift; $data->{demo} += 1 ; $data};

   $monad->bind( $monad->bind( $monad->unit({}) , f ) , g ) ==
     $monad->bind( $monad->unit({}) , sub { my $data = shift; $monad->bind($f->($data), $g ); $data; });

=head1 SEE ALSO

L<Catmandu::Fix::Bind::identity>, L<Catmandu::Fix::Bind::benchmark>

=head1 AUTHOR

Patrick Hochstenbach - L<Patrick.Hochstenbach@UGent.be>

=cut

1;
