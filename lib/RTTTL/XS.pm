# This file was automatically generated by SWIG (http://www.swig.org).
# Version 2.0.12
#
# Do not make changes to this file unless you know what you are doing--modify
# the SWIG interface file instead.

package RTTTL::XS;
use base qw(Exporter);
use base qw(DynaLoader);
package RTTTL::XSc;
bootstrap RTTTL::XS;
package RTTTL::XS;
@EXPORT = qw();

# ---------- BASE METHODS -------------

package RTTTL::XS;

sub TIEHASH {
    my ($classname,$obj) = @_;
    return bless $obj, $classname;
}

sub CLEAR { }

sub FIRSTKEY { }

sub NEXTKEY { }

sub FETCH {
    my ($self,$field) = @_;
    my $member_func = "swig_${field}_get";
    $self->$member_func();
}

sub STORE {
    my ($self,$field,$newval) = @_;
    my $member_func = "swig_${field}_set";
    $self->$member_func($newval);
}

sub this {
    my $ptr = shift;
    return tied(%$ptr);
}


# ------- FUNCTION WRAPPERS --------

package RTTTL::XS;

*play_tone = *RTTTL::XSc::play_tone;
*play_rtttl = *RTTTL::XSc::play_rtttl;
*init = *RTTTL::XSc::init;

# ------- VARIABLE STUBS --------

package RTTTL::XS;

1;
