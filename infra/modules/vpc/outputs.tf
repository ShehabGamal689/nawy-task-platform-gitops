output "vpc_id" { value = aws_vpc.this.id }
output "subnet_ids" { value = [aws_subnet.public_1.id, aws_subnet.public_2.id] }
