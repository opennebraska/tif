use utf8;
package TIF::Result::Year;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TIF::Result::Year

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<year>

=cut

__PACKAGE__->table("year");

=head1 ACCESSORS

=head2 tif_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 tax_year

  data_type: 'text'
  is_nullable: 0

=head2 residential_base_value

  data_type: 'numeric'
  is_nullable: 1

=head2 residential_excess_value

  data_type: 'numeric'
  is_nullable: 1

=head2 commercial_base_value

  data_type: 'numeric'
  is_nullable: 1

=head2 commercial_excess_value

  data_type: 'numeric'
  is_nullable: 1

=head2 industrial_base_value

  data_type: 'numeric'
  is_nullable: 1

=head2 industrial_excess_value

  data_type: 'numeric'
  is_nullable: 1

=head2 other_base_value

  data_type: 'numeric'
  is_nullable: 1

=head2 other_excess_value

  data_type: 'numeric'
  is_nullable: 1

=head2 other_description

  data_type: 'text'
  is_nullable: 1

=head2 total_tif_base_value

  data_type: 'numeric'
  is_nullable: 1

=head2 total_tif_excess_value

  data_type: 'numeric'
  is_nullable: 1

=head2 total_tax_rate

  data_type: 'numeric'
  is_nullable: 1

=head2 total_tif_excess_taxes

  data_type: 'numeric'
  is_nullable: 1

=head2 total_tif_base_taxes

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "tif_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "tax_year",
  { data_type => "text", is_nullable => 0 },
  "residential_base_value",
  { data_type => "numeric", is_nullable => 1 },
  "residential_excess_value",
  { data_type => "numeric", is_nullable => 1 },
  "commercial_base_value",
  { data_type => "numeric", is_nullable => 1 },
  "commercial_excess_value",
  { data_type => "numeric", is_nullable => 1 },
  "industrial_base_value",
  { data_type => "numeric", is_nullable => 1 },
  "industrial_excess_value",
  { data_type => "numeric", is_nullable => 1 },
  "other_base_value",
  { data_type => "numeric", is_nullable => 1 },
  "other_excess_value",
  { data_type => "numeric", is_nullable => 1 },
  "other_description",
  { data_type => "text", is_nullable => 1 },
  "total_tif_base_value",
  { data_type => "numeric", is_nullable => 1 },
  "total_tif_excess_value",
  { data_type => "numeric", is_nullable => 1 },
  "total_tax_rate",
  { data_type => "numeric", is_nullable => 1 },
  "total_tif_excess_taxes",
  { data_type => "numeric", is_nullable => 1 },
  "total_tif_base_taxes",
  { data_type => "numeric", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tif_id>

=item * L</tax_year>

=back

=cut

__PACKAGE__->set_primary_key("tif_id", "tax_year");

=head1 RELATIONS

=head2 tif

Type: belongs_to

Related object: L<TIF::Result::Project>

=cut

__PACKAGE__->belongs_to(
  "tif",
  "TIF::Result::Project",
  { tif_id => "tif_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-10-10 23:32:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gas/8/TBn4sVjyNgu9caAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
