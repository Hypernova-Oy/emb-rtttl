use Modern::Perl;
use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Buzzer',
     dist_author => 'Joonas Kylmälä <joonas.kylmala@jns.fi>',
     dist_abstract => 'Makes piezo do different sounds',

     build_requires => {
	 'Modern::Perl' => '1',
     },

     requires => {
	 'Modern::Perl' => '1',
	 'Time::HiRes' => '1.9',
	 'GPIO' => '0.01',
     }

    );

$build->create_build_script;
