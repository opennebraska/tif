create table project (
  tif_id text primary key,
  county_name text,
  county_number int,
  tif_name text,
  project_date text,
  city_name text,
  school_district text,
  base_school text,
  unified_lc text,
  class int,
  name text,
  location text,
  description text
);

create table year (
  tif_id text,
  tax_year text,
  residential_base_value numeric,
  residential_excess_value numeric,
  commercial_base_value numeric,
  commercial_excess_value numeric,
  industrial_base_value numeric,
  industrial_excess_value numeric,
  other_base_value numeric,
  other_excess_value numeric,
  other_description text,
  total_tif_base_value numeric,
  total_tif_excess_value numeric,
  total_tax_rate numeric,
  total_tif_excess_taxes numeric,
  total_tif_base_taxes numeric,
  primary key (tif_id, tax_year),
  foreign key (tif_id) references project(tif_id)
);

