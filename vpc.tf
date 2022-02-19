resource "aws_vpc" "client" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.client.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), cidrsubnets(aws_vpc.client.cidr_block, 8, 8, 8))

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.client.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.client.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.client.id

  for_each = zipmap(slice(data.aws_availability_zones.default.names, 0, 3), ["10.1.100.0/24", "10.1.101.0/24", "10.1.102.0/24"])

  availability_zone = each.key

  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "private"
  }
}

resource "aws_eip" "nat_gw" {
  vpc = true

}

resource "aws_nat_gateway" "default" {
  subnet_id = aws_subnet.public["us-east-1a"].id

  allocation_id = aws_eip.nat_gw.allocation_id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.client.id
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}




