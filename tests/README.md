# Terraform AWS ECS Fargate Cluster Tests

This directory contains automated tests for the Terraform AWS ECS Fargate Cluster module using [Terratest](https://terratest.gruntwork.io/).

## Test Coverage

The test suite validates the following components:

### 1. ECS Cluster Creation
- Verifies that the ECS cluster is created successfully
- Validates cluster name and ARN
- Confirms cluster status is ACTIVE

### 2. Application Load Balancer (ALB) Creation
- Verifies that the ALB is created and active
- Validates ALB type is "application"
- Confirms ALB scheme is "internet-facing"
- Checks ALB DNS name is properly set

### 3. ACM Certificate Creation
- Verifies that the ACM certificate is created
- Validates certificate domain matches expected domain
- Confirms certificate status (ISSUED or PENDING_VALIDATION)

### 4. ACM Certificate Attachment to ALB
- Verifies that the ACM certificate is properly attached to the ALB HTTPS listener
- Validates HTTPS listener exists and has certificates configured

### 5. ALB DNS Record Creation
- Verifies that Route53 DNS record is created for the ALB
- Validates A record points to the ALB (when hosted zone exists)
- Gracefully skips test if hosted zone doesn't exist in test environment

### 6. ECS Security Group Creation
- Verifies that ECS task security group is created
- Validates security group ID is properly output

### 7. ECS IAM Role Creation
- Verifies that ECS access IAM role is created
- Validates role ARN format and structure

## Prerequisites

Before running the tests, ensure you have:

1. **Go installed** (version 1.21 or later)
2. **AWS credentials configured** with appropriate permissions
3. **Terraform installed** (version compatible with the module)

### Required AWS Permissions

The test user/role needs permissions for:
- ECS (DescribeClusters)
- ELBv2 (DescribeLoadBalancers, DescribeListeners)
- ACM (DescribeCertificate)
- Route53 (ListHostedZones, ListResourceRecordSets)
- EC2 (for VPC and security group operations)
- IAM (for role operations)

## Running the Tests

### Using Make (Recommended)

```bash
# Run all tests
make test

# Run tests with coverage report
make test-coverage

# Run tests with HTML report generation
make test-report

# Install dependencies
make deps

# Clean up generated files
make clean

# Run all checks (format, vet, test)
make check
```

### Using Go directly

```bash
# Install dependencies
go mod download

# Run tests
go test -v -timeout 30m

# Run tests with report generation
go test -v -timeout 30m -report -report-file=test-report.json -html-file=test-report.html
```

## Test Configuration

The tests use the following configuration:

- **AWS Region**: `ap-southeast-1`
- **Test Domain**: `test.example.com`
- **Hosted Zone**: `example.com`
- **VPC CIDR**: `10.0.0.0/16`
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Private Subnets**: `10.0.3.0/24`, `10.0.4.0/24`

## Test Reports

The tests generate comprehensive reports:

- **JSON Report**: `test-report.json` - Machine-readable test results
- **HTML Report**: `test-report.html` - Human-readable test results with styling
- **Coverage Report**: `coverage.html` - Code coverage analysis (when using `make test-coverage`)

## Test Structure

```
tests/
├── terraform_test.go    # Main test file with all test cases
├── go.mod              # Go module dependencies
├── Makefile           # Build and test automation
└── README.md          # This file
```

## Troubleshooting

### Common Issues

1. **Timeout Errors**: Tests have a 30-minute timeout. If tests are timing out, check AWS resource creation times.

2. **Permission Errors**: Ensure your AWS credentials have all required permissions listed above.

3. **DNS Test Skipping**: The DNS record test will skip if the `example.com` hosted zone doesn't exist. This is expected in test environments.

4. **Certificate Validation**: ACM certificates may be in `PENDING_VALIDATION` state during tests, which is acceptable.

### Debug Mode

To run tests with more verbose output:

```bash
go test -v -timeout 30m -args -test.v
```

## Cleanup

Tests automatically clean up resources using Terraform destroy in a defer block. If tests are interrupted, you may need to manually clean up AWS resources.

To clean up test artifacts:

```bash
make clean
```

## Contributing

When adding new tests:

1. Follow the existing test pattern
2. Add appropriate AWS SDK clients and permissions
3. Include proper error handling and assertions
4. Update this README with new test coverage
5. Ensure tests clean up resources properly
