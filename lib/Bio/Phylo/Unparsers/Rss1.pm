# $Id: Mrp.pm 1660 2011-04-02 18:29:40Z rvos $
package Bio::Phylo::Unparsers::Rss1;
use strict;
use base 'Bio::Phylo::Unparsers::Abstract';
use Bio::Phylo::Util::CONSTANT qw'/looks_like/';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::Dependency 'XML::Twig';
use Bio::Phylo::Util::Logger;
use Bio::Phylo::Factory;

my $fac = Bio::Phylo::Factory->new;
my $logger = Bio::Phylo::Util::Logger->new;

=head1 NAME

Bio::Phylo::Unparsers::Rss1 - Serializer used by Bio::Phylo::IO, no serviceable
parts inside

=head1 DESCRIPTION

This module represents the contents of the supplied project object as an RSS1.0
string, i.e. as RDF. Which contents are the items in the feed? This depends on
the value of the '-recordSchema' argument. If no argument is provided, the feed
lists taxa, otherwise 'tree' or 'matrix' for a list of those in the project.

=begin comment

 Type    : Wrapper
 Title   : _to_string
 Usage   : my $rss1 = $obj->_to_string;
 Function: Stringifies a Bio::Phylo::Project object into an RSS1.0 string
 Alias   :
 Returns : SCALAR
 Args    : Bio::Phylo::Project object

=end comment

=cut

sub _to_string {
    my $self = shift;
    my $obj  = $self->{'PHYLO'};
    my $type = $self->{'RECORDSCHEMA'} || 'taxon';
    
    # this is the root channel description
    my $description = $fac->create_description(
        '-namespaces' => $obj->get_namespaces,
        '-url'        => $obj->get_xml_base,
        '-guid'       => $obj->get_guid,
        '-desc'       => $obj->get_desc,
    );
    
    # here we start the recursion to find the items in the
    # feed as specified by recordSchema/$type
    $obj->visit( sub { _visitor(shift,$type,$description) } );
    
    # this is just to ensure that the produced xml
    # is well-formed and we return a pretty printed version
    my $twig = XML::Twig->new;
    $twig->set_xml_version('1.0');
    $twig->set_encoding('UTF-8');
    $twig->set_pretty_print('indented');
    $twig->set_empty_tag_style('normal');
    $twig->parse( $description->to_xml );
    return $twig->sprint();
}

sub _visitor {
    my ( $obj, $type, $description ) = @_;
    
    # recordSchema/$type should match the lower case,
    # local name of a class in the hierarchy
    my $class = ref $obj;
    $class =~ s/.+://;
    $class = lc $class;
    if ( $class eq $type ) {
        
        # this creates an item in the feed, i.e. a resource
        my $resource = $fac->create_resource(
            '-name' => $obj->get_name,
            '-guid' => $obj->get_guid,
            '-url'  => $obj->get_xml_base,
            '-desc' => $obj->get_desc,
        );
        
        # we attach all additional metadata, i.e. beyond the
        # standard RSS1.0 predicates
        $resource->add_meta($_) for @{ $obj->get_meta };
        $description->insert($resource);
    }
    else {
        if ( $obj->can('visit') ) {
            $obj->visit( sub { _visitor(shift,$type,$description) } );
        }
    }
}

# podinherit_insert_token

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The json unparser is called by the L<Bio::Phylo::IO> object.
Look there to learn how to unparse objects.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=item L<http://www.json.org>

To learn more about the JavaScript Object Notation (JSON) format, visit
L<http://www.json.org>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Mrp.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
1;
