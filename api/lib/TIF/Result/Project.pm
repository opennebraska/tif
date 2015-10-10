use utf8;
package TIF::Result::Project;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TIF::Result::Project

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<project>

=cut

__PACKAGE__->table("project");

=head1 ACCESSORS

=head2 tif_id

  data_type: 'integer'
  is_nullable: 1

=head2 county_name

  data_type: 'text'
  is_nullable: 1

=head2 county_number

  data_type: 'int'
  is_nullable: 1

=head2 tif_name

  data_type: 'text'
  is_nullable: 1

=head2 project_date

  data_type: 'text'
  is_nullable: 1

=head2 city_name

  data_type: 'text'
  is_nullable: 1

=head2 school_district

  data_type: 'text'
  is_nullable: 1

=head2 base_school

  data_type: 'text'
  is_nullable: 1

=head2 unified_lc

  data_type: 'text'
  is_nullable: 1

=head2 class

  data_type: 'int'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 location

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "tif_id",
  { data_type => "integer", is_nullable => 1 },
  "county_name",
  { data_type => "text", is_nullable => 1 },
  "county_number",
  { data_type => "int", is_nullable => 1 },
  "tif_name",
  { data_type => "text", is_nullable => 1 },
  "project_date",
  { data_type => "text", is_nullable => 1 },
  "city_name",
  { data_type => "text", is_nullable => 1 },
  "school_district",
  { data_type => "text", is_nullable => 1 },
  "base_school",
  { data_type => "text", is_nullable => 1 },
  "unified_lc",
  { data_type => "text", is_nullable => 1 },
  "class",
  { data_type => "int", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "location",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-10-10 12:04:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ykb+BdNByrLLE6WiguA7YQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
