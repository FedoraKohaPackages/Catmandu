package Catmandu::Cmd::Command::repl;
# VERSION
use Moose;
use Devel::REPL;

extends qw(Catmandu::Cmd::Command);

sub execute {
    my ($self, $opts, $args) = @_;

    my $repl = Devel::REPL->new;

    my $eval = <<'PERL';
use Catmandu;
PERL

    $repl->load_plugin($_) for qw(
        Colors LexEnv MultiLine::PPI
        Packages FancyPrompt DDC Completion
        Timing Refresh
        CompletionDriver::LexEnv
        CompletionDriver::Keywords
        CompletionDriver::INC
        CompletionDriver::Methods);

    $repl->fancy_prompt(sub {
        my $self  = shift;
        my $pkg   = $self->can('current_package') ? $self->current_package : 'main';
        my $depth = $self->can('line_depth') ? $self->line_depth : '';
        sprintf '%s:%03d:%s> ',
            $pkg,
            $self->lines_read,
            $depth;
    });

    $repl->fancy_continuation_prompt(sub {
        my $self  = shift;
        my $pkg   = $self->can('current_package') ? $self->current_package : 'main';
        my $depth = $self->can('line_depth') ? $self->line_depth : '';
        sprintf '%s:%03d:%s* ',
            $pkg,
            $self->lines_read,
            $depth;
    });

    $repl->current_package('main');
    $repl->eval($eval);
    $repl->run;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 NAME

Catmandu::Cmd::Command::repl - interactive console

