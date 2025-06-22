package test

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/acm"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"github.com/aws/aws-sdk-go-v2/service/route53"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/oozou/terraform-test-util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Global variables for test reporting
var (
	generateReport bool
	reportFile     string
	htmlFile       string
)

// TestMain enables custom test runner with reporting
func TestMain(m *testing.M) {
	flag.BoolVar(&generateReport, "report", false, "Generate test report")
	flag.StringVar(&reportFile, "report-file", "test-report.json", "Test report JSON file")
	flag.StringVar(&htmlFile, "html-file", "test-report.html", "Test report HTML file")
	flag.Parse()

	exitCode := m.Run()
	os.Exit(exitCode)
}

func TestTerraformAWSECSFargateClusterModule(t *testing.T) {
	t.Parallel()

	// Record test start time
	startTime := time.Now()
	var testResults []testutil.TestResult

	// Pick a random AWS region to test in
	awsRegion := "ap-southeast-1"

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/terraform-test",

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		terraform.Destroy(t, terraformOptions)
	}()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Define test cases with their functions
	testCases := []struct {
		name string
		fn   func(*testing.T, *terraform.Options, string)
	}{
		{"TestECSClusterCreated", testECSClusterCreated},
		{"TestALBCreated", testALBCreated},
		{"TestACMCertificateCreated", testACMCertificateCreated},
		{"TestACMCertificateAttachedToALB", testACMCertificateAttachedToALB},
		{"TestALBDNSRecordCreated", testALBDNSRecordCreated},
		{"TestECSSecurityGroupCreated", testECSSecurityGroupCreated},
	}

	// Run all test cases and collect results
	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			testStart := time.Now()

			// Capture test result
			defer func() {
				testEnd := time.Now()
				duration := testEnd.Sub(testStart)

				result := testutil.TestResult{
					Name:     tc.name,
					Duration: duration.String(),
				}

				if r := recover(); r != nil {
					result.Status = "FAIL"
					result.Error = fmt.Sprintf("Panic: %v", r)
				} else if t.Failed() {
					result.Status = "FAIL"
					result.Error = "Test assertions failed"
				} else if t.Skipped() {
					result.Status = "SKIP"
				} else {
					result.Status = "PASS"
				}

				testResults = append(testResults, result)
			}()

			// Run the actual test
			tc.fn(t, terraformOptions, awsRegion)
		})
	}

	// Generate and display test report
	endTime := time.Now()
	report := testutil.GenerateTestReport(testResults, startTime, endTime)
	report.TestSuite = "Terraform AWS ECS Fargate Cluster Tests"
	report.PrintReport()

	// Save reports to files
	if err := report.SaveReportToFile("test-report.json"); err != nil {
		t.Errorf("failed to save report to file: %v", err)
	}

	if err := report.SaveReportToHTML("test-report.html"); err != nil {
		t.Errorf("failed to save report to HTML: %v", err)
	}
}

// Helper function to create AWS config
func createAWSConfig(t *testing.T, region string) aws.Config {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	require.NoError(t, err, "Failed to create AWS config")
	return cfg
}

// Test that ECS cluster is created successfully
func testECSClusterCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	// Get the ECS cluster ARN from terraform output
	ecsClusterArn := terraform.Output(t, terraformOptions, "ecs_cluster_arn")
	ecsClusterName := terraform.Output(t, terraformOptions, "ecs_cluster_name")

	// Validate outputs are not empty
	assert.NotEmpty(t, ecsClusterArn, "ECS cluster ARN should not be empty")
	assert.NotEmpty(t, ecsClusterName, "ECS cluster name should not be empty")

	// Create AWS ECS client
	cfg := createAWSConfig(t, region)
	ecsClient := ecs.NewFromConfig(cfg)

	// Describe the ECS cluster
	input := &ecs.DescribeClustersInput{
		Clusters: []string{ecsClusterName},
	}

	result, err := ecsClient.DescribeClusters(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ECS cluster")
	require.Len(t, result.Clusters, 1, "Expected exactly one cluster")

	cluster := result.Clusters[0]
	assert.Equal(t, ecsClusterName, *cluster.ClusterName, "Cluster name should match")
	assert.Equal(t, "ACTIVE", *cluster.Status, "Cluster should be active")
	assert.Contains(t, *cluster.ClusterArn, ecsClusterName, "Cluster ARN should contain cluster name")
}

// Test that ALB is created successfully
func testALBCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	// Get the ALB ARN from terraform output
	albArn := terraform.Output(t, terraformOptions, "alb_arn")
	albDnsName := terraform.Output(t, terraformOptions, "alb_dns_name")

	// Validate outputs are not empty
	assert.NotEmpty(t, albArn, "ALB ARN should not be empty")
	assert.NotEmpty(t, albDnsName, "ALB DNS name should not be empty")

	// Create AWS ELBv2 client
	cfg := createAWSConfig(t, region)
	elbv2Client := elasticloadbalancingv2.NewFromConfig(cfg)

	// Describe the load balancer
	input := &elasticloadbalancingv2.DescribeLoadBalancersInput{
		LoadBalancerArns: []string{albArn},
	}

	result, err := elbv2Client.DescribeLoadBalancers(context.TODO(), input)
	require.NoError(t, err, "Failed to describe load balancer")
	require.Len(t, result.LoadBalancers, 1, "Expected exactly one load balancer")

	alb := result.LoadBalancers[0]
	assert.Equal(t, "active", string(alb.State.Code), "ALB should be active")
	assert.Equal(t, "application", string(alb.Type), "ALB should be application type")
	assert.Equal(t, "internet-facing", string(alb.Scheme), "ALB should be internet-facing")
	assert.Equal(t, albDnsName, *alb.DNSName, "ALB DNS name should match")
}

// Test that ACM certificate is created successfully
func testACMCertificateCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	// Get the ACM certificate ARN from terraform output
	acmCertArn := terraform.Output(t, terraformOptions, "acm_certificate_arn")

	// Validate outputs are not empty
	assert.NotEmpty(t, acmCertArn, "ACM certificate ARN should not be empty")

	// Create AWS ACM client
	cfg := createAWSConfig(t, region)
	acmClient := acm.NewFromConfig(cfg)

	// Describe the certificate
	input := &acm.DescribeCertificateInput{
		CertificateArn: &acmCertArn,
	}

	result, err := acmClient.DescribeCertificate(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ACM certificate")

	cert := result.Certificate
	assert.Equal(t, acmCertArn, *cert.CertificateArn, "Certificate ARN should match")
	assert.Equal(t, "terraform-test.devops.team.oozou.com", *cert.DomainName, "Certificate domain should match")
}

// Test that ACM certificate is attached to ALB
func testACMCertificateAttachedToALB(t *testing.T, terraformOptions *terraform.Options, region string) {
	// Get the ALB ARN and ACM certificate ARN from terraform output
	albArn := terraform.Output(t, terraformOptions, "alb_arn")
	acmCertArn := terraform.Output(t, terraformOptions, "acm_certificate_arn")

	// Create AWS ELBv2 client
	cfg := createAWSConfig(t, region)
	elbv2Client := elasticloadbalancingv2.NewFromConfig(cfg)

	// Get ALB listeners
	listenersInput := &elasticloadbalancingv2.DescribeListenersInput{
		LoadBalancerArn: &albArn,
	}

	listenersResult, err := elbv2Client.DescribeListeners(context.TODO(), listenersInput)
	require.NoError(t, err, "Failed to describe ALB listeners")

	// Find HTTPS listener and check if certificate is attached
	var httpsListener *types.Listener
	for i, listener := range listenersResult.Listeners {
		if listener.Protocol == "HTTPS" {
			httpsListener = &listenersResult.Listeners[i]
			break
		}
	}

	require.NotNil(t, httpsListener, "HTTPS listener should exist")
	require.NotEmpty(t, httpsListener.Certificates, "HTTPS listener should have certificates")

	// Check if our certificate is attached
	certificateFound := false
	for _, cert := range httpsListener.Certificates {
		if *cert.CertificateArn == acmCertArn {
			certificateFound = true
			break
		}
	}

	assert.True(t, certificateFound, "ACM certificate should be attached to ALB HTTPS listener")
}

// Test that ALB DNS record is created
func testALBDNSRecordCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	// Get the ALB DNS name from terraform output
	albDnsName := terraform.Output(t, terraformOptions, "alb_dns_name")
	
	// Create AWS Route53 client
	cfg := createAWSConfig(t, region)
	route53Client := route53.NewFromConfig(cfg)

	// List hosted zones to find the devops.team.oozou.com zone
	hostedZonesInput := &route53.ListHostedZonesInput{}
	hostedZonesResult, err := route53Client.ListHostedZones(context.TODO(), hostedZonesInput)
	require.NoError(t, err, "Failed to list hosted zones")

	var hostedZoneId string
	for _, zone := range hostedZonesResult.HostedZones {
		if strings.Contains(*zone.Name, "devops.team.oozou.com") {
			hostedZoneId = *zone.Id
			break
		}
	}

	// Skip test if hosted zone doesn't exist (this is expected in test environment)
	if hostedZoneId == "" {
		t.Skip("Hosted zone for devops.team.oozou.com not found - skipping DNS record test")
		return
	}

	// List resource record sets for the hosted zone
	recordsInput := &route53.ListResourceRecordSetsInput{
		HostedZoneId: &hostedZoneId,
	}

	recordsResult, err := route53Client.ListResourceRecordSets(context.TODO(), recordsInput)
	require.NoError(t, err, "Failed to list resource record sets")

	// Check if DNS record exists for terraform-test.devops.team.oozou.com
	recordFound := false
	for _, record := range recordsResult.ResourceRecordSets {
		if *record.Name == "terraform-test.devops.team.oozou.com." && record.Type == "A" {
			// Check if it's an alias record pointing to ALB
			if record.AliasTarget != nil && strings.Contains(*record.AliasTarget.DNSName, strings.Split(albDnsName, ".")[0]) {
				recordFound = true
				break
			}
		}
	}

	assert.True(t, recordFound, "DNS A record should exist for terraform-test.devops.team.oozou.com pointing to ALB")
}

// Test that ECS security group is created
func testECSSecurityGroupCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	// Get the security group ID from terraform output
	sgId := terraform.Output(t, terraformOptions, "ecs_task_security_group_id")

	// Validate output is not empty
	assert.NotEmpty(t, sgId, "ECS task security group ID should not be empty")

	// Additional validation could be added here to check security group rules
	// using EC2 client, but for now we just verify the output exists
}
