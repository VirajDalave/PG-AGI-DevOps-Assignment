resource "aws_secretsmanager_secret" "image_tag" {
  name        = "pgagi-image-tag"
  description = "Stores the latest Git SHA used for Docker image tagging"
}
