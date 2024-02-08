# Change Log

## [1.0.10] - 2024-02-07

### Changed

- Update resource `aws_lb.this.access_logs` to support empty access_log with variable `var.alb_access_logs_bucket_name`

### Removed

- Remove local var `raise_is_public_subnet_ids_empty`, `raise_is_private_subnet_ids_empty`

## [1.0.9] - 2024-01-22

### Added

- variable `default_fixed_response`
- Support alb default fixed response to be customizable

## [1.0.8] - 2023-05-11

### Added

- variable `alb_access_logs_bucket_name`
- variable `is_enable_access_log`
- Support alb access_logs

### Changes
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
