package Bio::Phylo::Treedrawer::Jpeg;
use strict;
use Bio::Phylo::Util::Dependency 'Bio::Phylo::Treedrawer::Png';
use Bio::Phylo::Util::Exceptions 'throw';
use base 'Bio::Phylo::Treedrawer::Png';

=head1 NAME

Bio::Phylo::Treedrawer::Jpeg - Graphics format writer used by treedrawer, no
serviceable parts inside

=head1 DESCRIPTION

This module creates a jpeg file from a Bio::Phylo::Forest::DrawTree
object. It is called by the L<Bio::Phylo::Treedrawer> object, so look there to
learn how to create tree drawings.


=begin comment

# only need to override finish to write to a different format

=end comment

=cut

sub _finish {
    my $self = shift;
    my $jpg;
    eval { $jpg = $self->_downsample->jpeg };
    if ( not $@ ) {
        return $jpg;
    }
    else {
        throw 'ExtensionError' =>
          "Can't create JPEG, libgd probably not compiled with it";
    }
}

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::Treedrawer>

The jpeg treedrawer is called by the L<Bio::Phylo::Treedrawer> object. Look there
to learn how to create tree drawings.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=cut

1;
