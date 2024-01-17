# Test the ELB attachment based on tag name

1. Create a tag first for all exisitng EC2 instances.
2. After apply terraform tag , adding lifecycle. Then apply again. This will disable terraform to detect the changes of this tag value in the future.
3. Create a data object to get the ids from the instances list. Filter the tag value of elb_attachable=true. You can manually update the instances that you dont want to join ELB target by setting this value to false on each instance


## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
