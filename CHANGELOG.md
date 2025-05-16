# Change Log

## [1.1.0] - 2025-05-16

### Changed
 - move alb resource to alb module

### Added
 - var `alb_s3_access_principals`
 - var `listener_https_fixed_response`
 - var `ssl_policy` 
 - var `is_create_discovery_namespace`

## [1.0.8] - 2023-05-11

### Added

- variable `alb_access_logs_bucket_name`
- variable `is_enable_access_log`
- Support alb access_logs

### Changed
- cluster_name length change from 19 to 25

## [1.0.7] - 2022-12-22

### Added

- Added output `alb_id`

## [1.0.6] - 2022-09-21

### Changes

- Module `route53` use from public registry 

## [1.0.5] - 2022-09-13

### Added

- variable additional_security_group_alb_ingress_rules

### Changes

- alb with name more than 32 will be strip

## [1.0.4] - 2022-08-15

### Added

- init terraform-aws-ecs-fargate-cluster to ready publish as public

## [0.0.1]

### Added

- init terraform-aws-ecs-fargate-cluster
