package App::Perl::Module::CopyrightYears;

use strict;
use warnings;

use Class::Utils qw(set_params);
use File::Find::Rule;
use File::Spec::Functions qw(catfile);
use Getopt::Std;
use IO::Barf qw(barf);
use Pod::CopyrightYears;

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	# Object.
	return $self;
}

# Run.
sub run {
	my $self = shift;

	# Process arguments.
	$self->{'_opts'} = {
		'd' => 0,
		'h' => 0,
		's' => 'LICENSE AND COPYRIGHT',
		'y' => undef,
	};
	if (! getopts('dhy:', $self->{'_opts'})
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-d] [-h] [-s section(s)] [-y last_year] [--version]\n";
		print STDERR "\t-d\t\tDebug mode.\n";
		print STDERR "\t-h\t\tPrint help.\n";
		print STDERR "\t-s section(s)\tSection(s) to look (default is LICENSE AND COPYRIGHT)\n";
		print STDERR "\t-y last_year\tLast year (default value is actual year)\n";
		print STDERR "\t--version\tPrint version.\n";
		return 1;
	}

	# Default year.
	if (! defined $self->{'_opts'}->{'y'}) {
		$self->{'_opts'}->{'y'} = (localtime(time))[5] + 1900;
	}

	# Find all perl module files in actual directory.
	my @pm = $self->_files('*.pm', '*.pod');

	# Dump perl modules in debug mode.
	if ($self->{'_opts'}->{'d'}) {
		require Dumpvalue;
		my $dump = Dumpvalue->new;
		$dump->dumpValues(\@pm);
	}

	# For each example save example.
	my $num = 1;
	foreach my $perl_module_file (@pm) {
		my @sections = split m/,/, $self->{'_opts'}->{'s'};
		my $cy = Pod::CopyrightYears->new(
			'pod_file' => $perl_module_file,
			'section_names' => \@sections,
		);
		$cy->change_years($self->{'_opts'}->{'y'});
		barf($perl_module_file, $cy->pod);
	}

	# Change copyright years in LICENSE file.
	# TODO

	# Look for scripts with copyright years.
	# TODO
	
	return 0;
}

sub _files {
	my ($self, @file_globs) = @_;

	my $rule = File::Find::Rule->new;
	my @pm = $rule->or(
		$rule->new->directory->name('t')->prune->discard,
		$rule->new->directory->name('inc')->prune->discard,
		$rule->new->directory->name('blib')->prune->discard,
		$rule->new,
	)->name(@file_globs)->in('.');

	return @pm;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Perl::Module::CopyrightYears - Base class for perl-module-copyright-years tool.

=head1 SYNOPSIS

 use App::Perl::Module::CopyrightYears;

 my $app = App::Perl::Module::CopyrightYears->new;
 my $exit_code = $app->run;

=head1 METHODS

=head2 C<new>

 my $app = App::Perl::Module::CopyrightYears->new;

Constructor.

Returns instance of object.

=head2 C<run>

 my $exit_code = $app->run;

Run.

Returns 1 for error, 0 for success.

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

=head1 EXAMPLE

=for comment filename=print_help.pl

 use strict;
 use warnings;

 use App::Perl::Module::CopyrightYears;

 # Arguments.
 @ARGV = (
         '-h',
 );

 # Run.
 exit App::Perl::Module::CopyrightYears->new->run;

 # Output like:
 # Usage: ./print_help.pl [-d] [-h] [-y last_year] [--version]
 #         -d              Debug mode.
 #         -h              Print help.
 #         --version       Print version.

=head1 DEPENDENCIES

L<Class::Utils>,
L<File::Find::Rule>,
L<File::Spec::Functions>,
L<Getopt::Std>,
L<IO::Barf>,
L<Pod::CopyrightYears>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/App-Perl-Module-CopyrightYears>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2023 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
