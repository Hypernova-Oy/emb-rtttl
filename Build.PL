use strict;
use warnings;

use Module::Build;


my $build = Module::Build->new
    (
     module_name => 'RTTTL::Player',
     dist_author => ['Joonas Kylmälä <joonas.kylmala@jns.fi>',
                     'Olli-Antti Kivilahti <olli-antti.kivilahti@jns.fi>'],
     dist_abstract => 'A piezoelectric RTTTL-Player',

     build_requires => {
     },

     requires => {
        'Modern::Perl' => '1',
        'Time::HiRes' => '1.9',
        'Proc::PID::File' => '1.00',
        'Config::Simple' => '1.00',
        'File::Slurp' => '9999.19',
     }

    );

$build->create_build_script;
