output "aws_region" {
  value = data.aws_region.current.name
}

output "aws_ecr_role" {
  value = aws_iam_role.ecr_push.arn
}

output "aws_ecr_repository_url" {
  value = aws_ecr_repository.wp.repository_url
}
