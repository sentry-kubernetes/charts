# Usage with DigitalOcean

## Ingress Controller

DigitalOcean does not create an Ingress Controller or LoadBalancer when the sentry chart is installed.
This usage example is for when you want to do SSL termination at LoadBalancer.

#### Create an `ingress.yaml` file with the following content.

```yaml
controller:
  name: controller
  service:
    # This redirects the https request to http port after SSL termination
    targetPorts:
      http: http
      https: http
    annotations:
      service.beta.kubernetes.io/do-loadbalancer-redirect-http-to-https: "true"
      service.beta.kubernetes.io/do-loadbalancer-certificate-id: {{.DO_CERTIFICATE_ID}}
      service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "true"
      service.beta.kubernetes.io/do-loadbalancer-hostname: {{.SENTRY_HOST}}
      service.beta.kubernetes.io/do-loadbalancer-name: {{.SENTRY_HOST}}
  config:
    use-forwarded-headers: "true"
    compute-full-forwarded-for: "true"
    use-proxy-protocol: "true"
```

You can obtain the certificate id from doctl or [terraform](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/certificate)

#### Install the ingress controller to your cluster

```shell
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace -f ingress.yaml
```

```shell
doctl compute certificate list
```

## Chart configuration

`values.yaml`
```yaml
prefix:

# Required only when installing
user:
  create: true
  email: {{.SENTRY_EMAIL}}
  password: {{.SENTRY_PASSWORD}}

nginx:
  enabled: false

ingress:
  enabled: true
  hostname: {{.SENTRY_HOST}}
  regexPathStyle: nginx
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"

system:
  url: "https://$SENTRY_HOST"
  public: true
  secret: {{.SENTRY_SECRET}}

postgresql:
  enabled: false

# DigitalOcean managed database uses port 25060 and needs SSL to be enabled
externalPostgresql:
  host: {{.SENTRY_DO_DB_HOST}}
  port: 25060
  database: {{.SENTRY_DO_DB_NAME}}
  username: {{.SENTRY_DO_DB_USER}}
  password: {{.SENTRY_DO_DB_PASSWORD}}
  sslMode: require
```


### Notes

1. Nginx Ingress Service can be configured with [chart values](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx) and [annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/).
2. Annotations for DO Load Balancer are as mentioned [here](https://github.com/digitalocean/digitalocean-cloud-controller-manager/blob/master/docs/controllers/services/annotations.md)
