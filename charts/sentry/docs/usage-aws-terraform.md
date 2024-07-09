# Usage with Terraform + AWS

`./templates/sentry_values.yaml` file

```yaml
prefix: ${module_prefix}

user:
  create: true
  email: ${sentry_email}
  password: ${sentry_password}

nginx:
  enabled: false

rabbitmq:
  enabled: false

sentry:
  web:
    service:
      annotations:
        alb.ingress.kubernetes.io/healthcheck-path: /_health/
        alb.ingress.kubernetes.io/healthcheck-port: traffic-port

relay:
  service:
    annotations:
      alb.ingress.kubernetes.io/healthcheck-path: /api/relay/healthcheck/ready/
      alb.ingress.kubernetes.io/healthcheck-port: traffic-port

postgresql:
  enabled: true
  nameOverride: sentry-postgresql
  postgresqlUsername: postgres
  postgresqlPassword: ${postgres_password}
  postgresqlDatabase: sentry
  replication:
    enabled: false

ingress:
  enabled: true
  hostname: ${sentry_dns_name}
  regexPathStyle: aws-alb
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/tags: ${tags}
    alb.ingress.kubernetes.io/inbound-cidrs: ${allowed_cidr_blocks_str}
    alb.ingress.kubernetes.io/subnets: ${public_subnet_ids_str}
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/certificate-arn: ${subdomain_cert_arn}
    external-dns.alpha.kubernetes.io/hostname: ${sentry_dns_name}
```

`./helm.tf` file

```terraform
resource "helm_release" "sentry" {
  name  = "sentry"
  chart = "${path.module}/helm_sentry/"
  repository = "https://sentry-kubernetes.github.io/charts"
  version    = "14.0.0"
  timeout           = 600
  wait              = false
  dependency_update = true

  values = [
    templatefile(
      "${path.module}/templates/sentry_values.yaml",
      {
        module_prefix   = "${var.module_prefix}",
        sentry_email    = "${var.sentry_email}",
        sentry_password = "${var.sentry_password}",

        sentry_dns_name         = "${local.sentry_dns_name}",
        subdomain_cert_arn      = "${var.subdomain_cert_arn}",
        allowed_cidr_blocks_str = "${join(",", var.allowed_cidr_blocks)}",
        private_subnet_ids_str  = "${join(",", var.private_subnet_ids)}",
        public_subnet_ids_str   = "${join(",", var.public_subnet_ids)}",
        tags                    = "environment=${var.env}"
        # postgres_db_host        = "${module.sentry_rds_pg.this_rds_cluster_endpoint}",
        # postgres_db_name        = "${local.db_name}",
        postgres_username = "${local.db_user}",
        postgres_password = "${local.db_pass}",
      }
    )
  ]

  depends_on = [
    helm_release.lb_controller,
    helm_release.external_dns,
  ]
}
```

### Notes

1. Ensure the control plane and node security groups are appropriately configured as documented [here](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html#control-plane-worker-node-sgs).
2. Annotations for ingress are as mentioned [here](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/)
3. `healthcheck-path` and `healthcheck-port` annotations can be setup per target group using the alb annotations in the corresponding services as mentioned [here](https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/1056#issuecomment-551585078). For example, here we have:

```yaml
sentry:
  web:
    service:
      annotations:
        alb.ingress.kubernetes.io/healthcheck-path: /_health/
        alb.ingress.kubernetes.io/healthcheck-port: traffic-port

relay:
  service:
    annotations:
      alb.ingress.kubernetes.io/healthcheck-path: /api/relay/healthcheck/ready/
      alb.ingress.kubernetes.io/healthcheck-port: traffic-port
```

Which are load balancer annotations specified in the service configuration for the load balancer to pick while creating the target groups.

NOTE: AWS ALB Controller's Service annotations don't apply here as we want the `aws-load-balancer-controller` to pick-up the services and apply the appropriate healthcheck-path per service and not create a load balancer for the service itself. The service annotations will only apply when you want the service to be load balanced.
