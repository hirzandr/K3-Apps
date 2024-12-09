# "s3-dx-tdem-ie-nonprod-redshiftlogs-test01-sg"

module "s3_lifecycle_silver" {
  source = "./modules/s3_lifecycle"

  bucket_name = "santosoc-tcap-source"

  lifecycle_rules = [
    {
      id      = "BucketLevel-transition-1"
      enabled = true
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "INTELLIGENT_TIERING"
        },
      ]

      noncurrent_version_expiration = {
        days  = 14
        count = 1
      }
    }
    ,
    {
      id      = "PrefixBased-transitions-1"
      enabled = true
      prefix  = "dim_"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "INTELLIGENT_TIERING"
        },
      ]

      noncurrent_version_expiration = {
        days  = 14
        count = 1
      }
    },
    {
      id      = "PrefixBased-expiration-1"
      enabled = true
      prefix  = "dim_"

      expiration = {
        days = 360
      }

    }
  ]
}
