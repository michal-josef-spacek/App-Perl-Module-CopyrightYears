use strict;
use warnings;

use App::Perl::Module::CopyrightYears;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = App::Perl::Module::CopyrightYears->new;
isa_ok($obj, 'App::Perl::Module::CopyrightYears');
