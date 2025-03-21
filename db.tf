resource "aws_db_subnet_group" "wp" {
  name       = "wp"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "wp" {
  allocated_storage             = 20
  engine                        = "mysql"
  engine_version                = "8.0"
  multi_az                      = true
  instance_class                = "db.t4g.micro"
  db_name                       = "wp"
  username                      = "wp"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.wp.key_id
  skip_final_snapshot           = true
  vpc_security_group_ids        = [aws_security_group.db.id]
  db_subnet_group_name          = aws_db_subnet_group.wp.name
}
