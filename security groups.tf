resource "aws_security_group" "cluster_sg" {
    name = "Cluster security Group"
    description = "Security group for the LAMP cluster"
    vpc_id = aws_default_vpc.default.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 2377
        to_port = 2377
        protocol = "tcp"
        cidr_blocks = [aws_default_vpc.default.cidr_block]

    }
    ingress {
        from_port = 7946
        to_port = 7946
        protocol = "tcp"
        cidr_blocks = [aws_default_vpc.default.cidr_block]

    }
    ingress {
        from_port = 7946
        to_port = 7946
        protocol = "udp"
        cidr_blocks = [aws_default_vpc.default.cidr_block]

    }
    ingress {
        from_port = 4789
        to_port = 4789
        protocol = "udp"
        cidr_blocks = [aws_default_vpc.default.cidr_block]

    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}