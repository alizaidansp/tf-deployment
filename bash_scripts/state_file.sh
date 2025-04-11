aws s3api create-bucket \
  --bucket ali-amalitech-state-bucket \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1



aws s3api put-bucket-versioning \
  --bucket ali-amalitech-state-bucket \
  --versioning-configuration Status=Enabled
# This will ensure that the S3 bucket supports versioning, which is required for Terraform's native state locking.

aws s3api put-bucket-encryption \
  --bucket ali-amalitech-state-bucket \
  --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'



aws s3 ls s3://ali-amalitech-state-bucket