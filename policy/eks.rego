package main

# Runs against `terraform show -json tfplan.binary` output (input.resource_changes)
#
# Usage:
#   conftest test tfplan.json --policy ../policy

# ---- Config: adjust to match your actual standards ----

allowed_instance_types := {
	"t3.medium",
	"t3.large",
	"t2.medium",
	"m5.xlarge",
	"m5.2xlarge",
}

required_tags := {"Environment", "Owner", "Project"}

taggable_types := {
	"aws_eks_cluster",
	"aws_eks_node_group",
	"aws_instance",
	"aws_vpc",
	"aws_subnet",
	"aws_launch_template",
}

expected_environment := "prod"

# ---- Helpers ----

is_being_created_or_updated(rc) {
	actions := rc.change.actions
        not any_action_is_delete(actions)
	count(actions) > 0
	actions[_] != "no-op"
}

# ---- Rule: EKS node group instance types must be from the allowed list ----

deny[msg] {
	rc := input.resource_changes[_]
	rc.type == "aws_eks_node_group"
	is_being_created_or_updated(rc)
	it := rc.change.after.instance_types[_]
	not allowed_instance_types[it]
	msg := sprintf(
		"EKS node group '%s' uses disallowed instance type '%s'. Allowed types: %v",
		[rc.address, it, allowed_instance_types],
	)
}

# ---- Rule: required tags must be present on taggable resources ----

deny[msg] {
	rc := input.resource_changes[_]
	taggable_types[rc.type]
	is_being_created_or_updated(rc)
	tags := object.get(rc.change.after, "tags", {})
	present := {k | tags[k]}
	missing := required_tags - present
	count(missing) > 0
	msg := sprintf(
		"Resource '%s' (%s) is missing required tags: %v",
		[rc.address, rc.type, missing],
	)
}

# ---- Rule: EKS cluster must be tagged for the correct environment ----

deny[msg] {
	rc := input.resource_changes[_]
	rc.type == "aws_eks_cluster"
	is_being_created_or_updated(rc)
	env := object.get(object.get(rc.change.after, "tags", {}), "Environment", "")
	env != expected_environment
	msg := sprintf(
		"EKS cluster '%s' must have tag Environment=%s, found '%s'",
		[rc.address, expected_environment, env],
	)
}

# ---- Rule: EKS API endpoint must not be public without a restricted CIDR ----

deny[msg] {
	rc := input.resource_changes[_]
	rc.type == "aws_eks_cluster"
	is_being_created_or_updated(rc)
	vpc_config := object.get(rc.change.after, "vpc_config", [{}])[0]
	vpc_config.endpoint_public_access == true
	cidrs := object.get(vpc_config, "public_access_cidrs", [])
	cidrs[_] == "0.0.0.0/0"
	msg := sprintf(
		"EKS cluster '%s' has public API endpoint open to 0.0.0.0/0. Restrict public_access_cidrs.",
		[rc.address],
	)
}

# ---- Rule: block root/administrator-style overly permissive IAM policies on node roles (basic check) ----

deny[msg] {
	rc := input.resource_changes[_]
	rc.type == "aws_iam_role_policy_attachment"
	is_being_created_or_updated(rc)
	rc.change.after.policy_arn == "arn:aws:iam::aws:policy/AdministratorAccess"
	msg := sprintf(
		"Resource '%s' attaches AdministratorAccess — not allowed in production.",
		[rc.address],
	)
}

