#!/bin/sh

RELEASE_NAME="sentry-dhc"
TARGET_ENVIRONMENT="dhc-c52p070"
NAMESPACE="cmy-sentry"
USER_PASSWORD="ufTnQhDHtMuhee7LjG8ksbbG"
SENTRY_SENDGRID_MAIL_PASSWORD="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"
MATTERMOST_WEBHOOK_URL="https://matter.i.daimler.com/hooks/i3faaac9ein7uqz66ro83t3hew"
POSTGRES_PASSWORD="teste123"

echo "Deploying"
echo "release: $RELEASE_NAME"
echo "environment: $TARGET_ENVIRONMENT"
echo "kubernetes.cluster: $(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
echo "kubernetes.namespace: $NAMESPACE"
echo "..."

helm upgrade "$RELEASE_NAME" . \
  --install \
  --atomic \
  --debug \
  --timeout 15m \
  --namespace "$NAMESPACE" \
  --values "./custom-values.yaml" \
  --set user.password="$USER_PASSWORD" \
  --set mail.password="$SENTRY_SENDGRID_MAIL_PASSWORD" \
  --set postgresql.postgresqlPassword="$POSTGRES_PASSWORD" \
  --set bridgeSentryMattermost.mattermost_url="$MATTERMOST_WEBHOOK_URL"
