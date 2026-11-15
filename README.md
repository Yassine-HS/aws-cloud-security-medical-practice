# Cloud Security: Secure Medical Practice Infrastructure on AWS

A proof-of-concept of a secured web application for a medical practice, deployed on AWS. It covers network segmentation, an internet-facing load balancer with a WAF, encrypted document storage, and a simulated attack-and-defence exercise (Log4Shell, SQL injection, brute force), with detection and blocking.

Built as a project for the *Sécurité dans les Clouds* course (ING5-SSIR), using the AWS Academy Learner Lab. All data is fictional.

## Architecture

```
Client -> ALB (public subnets) -> EC2 Flask app (private subnet, port 8080)
            |
            +-- AWS WAF (regional web ACL)
                  - AWS managed rules: Known Bad Inputs (Log4Shell), SQLi
                  - Rate-based rule on POST /login
                  - IP set blocking
            CloudWatch alarm on BlockedRequests -> SNS e-mail

S3 (documents) — SSE-KMS (customer key), versioning, Block Public Access
CloudTrail -> S3 (management and data events)
```

## What is in this repository

| Path | Content |
|---|---|
| `infrastructure/cabinet-medical-network.yaml` | CloudFormation template: VPC, subnets, route tables, ALB, target group, listener, security groups, EC2 app instance, optional NAT Gateway |
| `presentation/` | Slide sources (HTML sections and `deck.json`) for the project presentation |
| `attacks/` | PowerShell test commands and the expected results |
| `screenshots/` | Evidence screenshots (add only after cropping account IDs and IP addresses) |
| `report/` | Progress report (add after redaction) |

## What the template deploys, and what was configured manually

The CloudFormation template builds the network and the application:
VPC (10.0.0.0/16), two public subnets, one private subnet, an internet gateway, an optional NAT Gateway (`DeployNat`), an S3 gateway endpoint, the ALB and its security group (CloudFront prefix list only, plus an optional temporary `MyIpCidr` rule), the app security group, and the EC2 instance (encrypted gp3 volume, IMDSv2 required).

The following were configured in the console during the lab and are **not** in the template yet: the regional WAF web ACL with its rules and IP sets, the S3 bucket and KMS key, CloudTrail, the CloudWatch alarm, the SNS topic, and the rate-based rule. Moving them into the template is the next step.

## Lab limits

- CloudFront could not be created (`cloudfront:CreateDistribution` denied), so the ALB is the WAF target and CloudFront is documented as target architecture.
- CloudWatch Logs for CloudTrail and WAF logging were blocked (`iam:AttachRolePolicy`), so those are documented as target architecture.
- Systems Manager (SSM) was removed from the design on the professor's guidance.

## Deploy the infrastructure

1. Open CloudFormation in `us-east-1` and create a stack from `infrastructure/cabinet-medical-network.yaml`.
2. Set `DeployNat` to `false` unless you need outbound internet from the instance (it costs money per hour).
3. Check the CloudFront prefix list ID (`CloudFrontPrefixListId`) in VPC > Managed prefix lists for your region.
4. Read the `AlbDnsName` output and use it in `attacks/tests.ps1`.

## Cost

The ALB, NAT Gateway (if enabled), and WAF bill while they exist, even when the EC2 instance is stopped. Delete the stack when the project is finished.

## Security notes

- The Flask application contains a **demo login** (`docteur` / `Demo-Only-2026`) intentionally used as the brute-force target. It is not a credential for any real system.
- No real patient data is used. The application shows fictional records only.
- Do not commit AWS credentials or account identifiers.
