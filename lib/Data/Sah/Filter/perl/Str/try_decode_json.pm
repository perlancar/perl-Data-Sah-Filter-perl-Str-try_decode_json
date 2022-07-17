package Data::Sah::Filter::perl::Str::try_decode_json;

use 5.010001;
use strict;
use warnings;

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    +{
        v => 1,
        summary => 'JSON-decode if we can, otherwise leave string as-is',
        examples => [
            {value=>undef, summary=>"Unfiltered"},
            {value=>"foo", summary=>"Unquoted becomes as-is"},
            {value=>"[1,", summary=>"Misquoted becomes as-is"},
            {value=>q("foo"), filtered_value=>"foo", summary=>"Quoted string becomes string"},
            {value=>q([1,2]), filtered_value=>[1,2], summary=>"Quoted array becomes array"},
            {value=>"null", filtered_value=>undef, summary=>"Bare null keyword becomes undef"},
        ],
    };
}

sub filter {
    my %args = @_;

    my $dt = $args{data_term};

    my $res = {};

    $res->{modules}{"JSON::PP"} //= 0;
    $res->{expr_filter} = join(
        "",
        "do { my \$decoded; eval { \$decoded = JSON::PP->new->allow_nonref->decode($dt); 1 }; \$@ ? $dt : \$decoded }",
    );

    $res;
}

1;
# ABSTRACT:

=for Pod::Coverage ^(meta|filter)$

=head1 DESCRIPTION

This rule is sometimes convenient if you want to accept unquoted string or a
data structure (encoded in JSON). This means, compared to just decoding from
JSON, you don't have to always quote your string. But beware of traps like the
bare values C<null>, C<true>, C<false> becoming undef/1/0 in Perl instead of
string literals, because they can be JSON-decoded.
