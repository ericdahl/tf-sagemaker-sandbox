# tf-sagemaker-sandbox

- Random experiments with Sagemaker

# Notes

## Network Access Type

### PublicInternetOnly

- public IP (httpbin.org/ip) is not EIP; it's Amazon's managed VPC IP

### VpcOnly

#### Test 1 - no SG specified

- expectation: 
  - uses ENI in (private) subnet specified
  - public IP is NAT GW EIP
  - will force a SG to be specified
- actual:
  - Sagemaker GUI freezes, not responsive. No error
  - ENI in private subnet
    - has SG attached - automatically created
      - egress to EFS SG (only)

#### Test 2 - Manually update ENI to add egress SG

(didn't want to waste time to recreate apps/domains - very slow)

- Attached egress SG to ENI
- app now loads quickly 
  - assume that previously was time-out trying to communicate to Sagemaker APIs
- public IP is NAT GW EIP
