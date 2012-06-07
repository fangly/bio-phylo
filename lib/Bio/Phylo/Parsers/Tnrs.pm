package Bio::Phylo::Parsers::Tnrs;
use strict;
use base 'Bio::Phylo::Parsers::Abstract';
use Data::Dumper;
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT qw'/looks_like/ :namespaces :objecttypes';
use Bio::Phylo::Util::Dependency 'JSON';

=head1 NAME

Bio::Phylo::Parsers::Tnrs - Parser used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module parses JSON output produced by the PhyloTastic taxonomic name
reconciliation service. It returns a taxa block with semantically annotated
taxon objects.

=cut

sub _parse {
    my $self = shift;
    my $fh   = $self->_handle;
    my $fac  = $self->_factory;
	my $taxa = $fac->create_taxa( '-namespaces' => { 'tnrs' => _NS_TNRS_ } );
	my $data_structure = JSON::decode_json( do { local $/; <$fh> } );
	
	# need to attach source Ids to taxa block
	my $metadata = $data_structure->{'metadata'};
	for my $source ( @{ $metadata->{'sources'} } ) {
		my $sourceId = _clean_source_name($source->{'sourceId'} );
		$taxa->add_meta(
			$fac->create_meta(
				'-triple' => { 'tnrs:source' => $sourceId }
			)
		);		
	}
	
	# iterate over all returned names
	for my $name ( @{ $data_structure->{'names'} } ) {
		
		# instantiate taxon object
		my $taxon = $fac->create_taxon( '-name' => $name->{'submittedName'} );
		
		# iterate over matches for focal name
		for my $match ( @{ $name->{'matches'} } ) {
			
			# clean up sourceId for usage as predicate
			my $sourceId = _clean_source_name($match->{'sourceId'});
			
			# attach uri
			my $uri = $match->{'uri'};
			$taxon->add_meta(
				$fac->create_meta(
					'-triple' => { "tnrs:${sourceId}" => $uri }
				)
			)
		}
		$taxa->insert($taxon);
	}
	return $taxa;
}

sub _clean_source_name {
	my $name = shift;
	$name =~ s/[^A-Za-z0-9]//g;
	return $name;
}

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::IO>

The TNRS parser is called by the L<Bio::Phylo::IO|Bio::Phylo::IO> object.
Look there to learn how to parse taxa in general

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=cut

1;