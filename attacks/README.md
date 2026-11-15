# Attack and defence tests

Run these from a Windows PowerShell session against the ALB, replacing `<ALB_DNS>` with the `AlbDnsName` stack output. Your IP must be allowed on the ALB security group while testing.

| Test | Expected result | Defence |
|---|---|---|
| Benign `/search?q=cabinet` | Not 403 (503 if the instance is stopped) | Reaches the ALB |
| Log4j payload on `/search` | 403 | `AWSManagedRulesKnownBadInputsRuleSet` |
| SQL injection on `/search` | 403 | `AWSManagedRulesSQLiRuleSet` |
| 30 POSTs to `/login` | 403 after the threshold | `RateBasedRulePOST` (10 requests / 5 min), CloudWatch alarm, SNS e-mail |
| Blocked IP | 403, rule `cabinet-waf-alb_IPV4_Block` | IP set response |

See `tests.ps1` for the commands.
