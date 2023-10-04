
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
   region = "us-east-1"
 endpoints {
acm = "http://localhost:4566"
amplify = "http://localhost:4566"
apigateway = "http://localhost:4566"
apigatewayv2 = "http://localhost:4566"
appconfig = "http://localhost:4566"
appflow = "http://localhost:4566"
applicationautoscaling = "http://localhost:4566"
appsync = "http://localhost:4566"
athena = "http://localhost:4566"
autoscaling = "http://localhost:4566"
backup = "http://localhost:4566"
batch = "http://localhost:4566"
cloudformation = "http://localhost:4566"
cloudfront = "http://localhost:4566"
cloudsearch = "http://localhost:4566"
cloudtrail = "http://localhost:4566"
cloudwatch = "http://localhost:4566"
cloudwatchlogs = "http://localhost:4566"
codecommit = "http://localhost:4566"
cognitoidentity = "http://localhost:4566"
cognitoidp = "http://localhost:4566"
config = "http://localhost:4566"
configservice = "http://localhost:4566"
costexplorer = "http://localhost:4566"
docdb = "http://localhost:4566"
dynamodb = "http://localhost:4566"
ec2 = "http://localhost:4566"
ecr = "http://localhost:4566"
ecs = "http://localhost:4566"
efs = "http://localhost:4566"
eks = "http://localhost:4566"
elasticache = "http://localhost:4566"
elasticbeanstalk = "http://localhost:4566"
elasticsearch = "http://localhost:4566"
elb = "http://localhost:4566"
elbv2 = "http://localhost:4566"
emr = "http://localhost:4566"
es = "http://localhost:4566"
events = "http://localhost:4566"
firehose = "http://localhost:4566"
fis = "http://localhost:4566"
glacier = "http://localhost:4566"
glue = "http://localhost:4566"
iam = "http://localhost:4566"
iot = "http://localhost:4566"
iotanalytics = "http://localhost:4566"
iotevents = "http://localhost:4566"
kafka = "http://localhost:4566"
keyspaces = "http://localhost:4566"
kinesis = "http://localhost:4566"
kinesisanalytics = "http://localhost:4566"
kinesisanalyticsv2 = "http://localhost:4566"
kms = "http://localhost:4566"
lakeformation = "http://localhost:4566"
lambda = "http://localhost:4566"
mediaconvert = "http://localhost:4566"
mediastore = "http://localhost:4566"
mq = "http://localhost:4566"
mwaa = "http://mwaa.localhost.localstack.cloud:4566"
neptune = "http://localhost:4566"
opensearch = "http://localhost:4566"
organizations = "http://localhost:4566"
qldb = "http://localhost:4566"
rds = "http://localhost:4566"
redshift = "http://localhost:4566"
redshiftdata = "http://localhost:4566"
resourcegroups = "http://localhost:4566"
resourcegroupstaggingapi = "http://localhost:4566"
route53 = "http://localhost:4566"
route53domains = "http://localhost:4566"
route53resolver = "http://localhost:4566"
s3 = "http://s3.localhost.localstack.cloud:4566"
s3control = "http://localhost:4566"
sagemaker = "http://localhost:4566"
scheduler = "http://localhost:4566"
secretsmanager = "http://localhost:4566"
serverlessrepo = "http://localhost:4566"
servicediscovery = "http://localhost:4566"
ses = "http://localhost:4566"
sesv2 = "http://localhost:4566"
sns = "http://localhost:4566"
sqs = "http://localhost:4566"
ssm = "http://localhost:4566"
stepfunctions = "http://localhost:4566"
sts = "http://localhost:4566"
swf = "http://localhost:4566"
timestreamwrite = "http://localhost:4566"
transcribe = "http://localhost:4566"
transfer = "http://localhost:4566"
waf = "http://localhost:4566"
wafv2 = "http://localhost:4566"
xray = "http://localhost:4566"
 }
}

# # 1. Create vpc

 resource "aws_vpc" "prod-vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
    Name = "production"
   }
 }

# # 2. Create Internet Gateway

 resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.prod-vpc.id


 }
# # 3. Create Custom Route Table

 resource "aws_route_table" "prod-route-table" {
   vpc_id = aws_vpc.prod-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }

   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.gw.id
   }

   tags = {
     Name = "Prod"
   }
 }

# # 4. Create a Subnet 

 resource "aws_subnet" "subnet-1" {
   vpc_id            = aws_vpc.prod-vpc.id
   cidr_block        = "10.0.1.0/24"
   availability_zone = "us-east-1a"

   tags = {
     Name = "prod-subnet"
   }
 }

# # 5. Associate subnet with Route Table
 resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet-1.id
   route_table_id = aws_route_table.prod-route-table.id
 }
# # 6. Create Security Group to allow port 22,80,443
 resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.prod-vpc.id

  ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
    description = "SSH"
     from_port   = 22
   to_port     = 22
     protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
     from_port   = 0
     to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "allow_web"
   }
 }

# # 7. Create a network interface with an ip in the subnet that was created in step 4

 resource "aws_network_interface" "web-server-nic" {
   subnet_id       = aws_subnet.subnet-1.id
   private_ips     = ["10.0.1.50"]
   security_groups = [aws_security_group.allow_web.id]

 }
# # 8. Assign an elastic IP to the network interface created in step 7

 resource "aws_eip" "one" {
   vpc                       = true
   network_interface         = aws_network_interface.web-server-nic.id
   associate_with_private_ip = "10.0.1.50"
   depends_on                = [aws_internet_gateway.gw]
 }

 output "server_public_ip" {
   value = aws_eip.one.public_ip
 }
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}