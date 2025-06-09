provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tif-s3" {
  bucket = "tif-s3-bucket"
  force_destroy = true
}

resource "aws_s3_object" "project_csv" {
  bucket = aws_s3_bucket.tif-s3.id
  key    = "raw/csv/project.csv"
  source = "project.csv"
  etag   = filemd5("project.csv")
}

resource "aws_s3_object" "year_csv" {
  bucket = aws_s3_bucket.tif-s3.id
  key    = "raw/csv/year.csv"
  source = "year.csv"
  etag   = filemd5("year.csv")
}

resource "aws_glue_catalog_database" "tif_data_lake_db" {
  name = "tif_data_lake"
}

resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_crawler" "csv_crawler" {
  name          = "csv-data-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.tif_data_lake_db.name

  s3_target {
    path = "s3://tif-s3-bucket/raw/"
  }

  configuration = jsonencode({
    Version = 1.0,
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })

  schedule = null  # on-demand; remove or change to run automatically
}

