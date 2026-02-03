resource "aws_ecr_repository" "wp" {
  name = "wp"
  image_scanning_configuration {
    scan_on_push = true
  }
}
