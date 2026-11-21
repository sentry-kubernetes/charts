{{- /*
The bundled kafka subchart's own default provisioning script (templates/provisioning/job.yaml
in the vendored kafka-29.3.14.tgz) sources bitnami's /opt/bitnami/scripts/libkafka.sh and calls
/opt/bitnami/kafka/bin/kafka-topics.sh, neither of which exist on the apache/kafka image.

This is that same default script, referenced from values.yaml's kafka.provisioning.args, with
libkafka.sh's two functions inlined and the kafka-topics.sh path fixed. Everything else --
SASL/TLS client-conf handling, pre/post scripts, parallel execution -- is unchanged.
*/}}
{{- define "sentry.kafka.bundledProvisioningScript" -}}
{{- $protocol := "PLAINTEXT" -}}
{{- if ((.Values.kafka.listeners).client).protocol -}}
{{- $protocol = .Values.kafka.listeners.client.protocol -}}
{{- else if (((.Values.kafka.auth).client).enabled) -}}
{{- $protocol = "SASL_PLAINTEXT" -}}
{{- end -}}
echo "Configuring environment"
kafka_common_conf_set() {
    local file="${1:?missing file}"
    local key="${2:?missing key}"
    local value="${3:?missing value}"
    echo "${key}=${value}" >> "$file"
}
is_empty_value() {
    [[ -z "${1:-}" ]]
}
export CLIENT_CONF="${CLIENT_CONF:-/tmp/client.properties}"
if [ ! -f "$CLIENT_CONF" ]; then
  touch $CLIENT_CONF

  kafka_common_conf_set "$CLIENT_CONF" security.protocol {{ $protocol | quote }}
  {{- if (regexFind "SSL" (upper $protocol)) }}
  kafka_common_conf_set "$CLIENT_CONF" ssl.keystore.type {{ upper .Values.kafka.provisioning.auth.tls.type | quote }}
  kafka_common_conf_set "$CLIENT_CONF" ssl.truststore.type {{ upper .Values.kafka.provisioning.auth.tls.type | quote }}
  ! is_empty_value "$KAFKA_CLIENT_KEY_PASSWORD" && kafka_common_conf_set "$CLIENT_CONF" ssl.key.password "$KAFKA_CLIENT_KEY_PASSWORD"
  {{- if eq (upper .Values.kafka.provisioning.auth.tls.type) "PEM" }}
  {{- if .Values.kafka.provisioning.auth.tls.caCert }}
  file_to_multiline_property() {
      awk 'NR > 1{print line" \\"}{line=$0;}END{print $0" "}' <"${1:?missing file}"
  }
  kafka_common_conf_set "$CLIENT_CONF" ssl.keystore.key "$(file_to_multiline_property "/certs/{{ .Values.kafka.provisioning.auth.tls.key }}")"
  kafka_common_conf_set "$CLIENT_CONF" ssl.keystore.certificate.chain "$(file_to_multiline_property "/certs/{{ .Values.kafka.provisioning.auth.tls.cert }}")"
  kafka_common_conf_set "$CLIENT_CONF" ssl.truststore.certificates "$(file_to_multiline_property "/certs/{{ .Values.kafka.provisioning.auth.tls.caCert }}")"
  {{- else }}
  kafka_common_conf_set "$CLIENT_CONF" ssl.keystore.location "/certs/{{ .Values.kafka.provisioning.auth.tls.keystore }}"
  kafka_common_conf_set "$CLIENT_CONF" ssl.truststore.location "/certs/{{ .Values.kafka.provisioning.auth.tls.truststore }}"
  {{- end }}
  {{- else if eq (upper .Values.kafka.provisioning.auth.tls.type) "JKS" }}
  kafka_common_conf_set "$CLIENT_CONF" ssl.keystore.location "/certs/{{ .Values.kafka.provisioning.auth.tls.keystore }}"
  kafka_common_conf_set "$CLIENT_CONF" ssl.truststore.location "/certs/{{ .Values.kafka.provisioning.auth.tls.truststore }}"
  ! is_empty_value "$KAFKA_CLIENT_KEYSTORE_PASSWORD" && kafka_common_conf_set "$CLIENT_CONF" ssl.keystore.password "$KAFKA_CLIENT_KEYSTORE_PASSWORD"
  ! is_empty_value "$KAFKA_CLIENT_TRUSTSTORE_PASSWORD" && kafka_common_conf_set "$CLIENT_CONF" ssl.truststore.password "$KAFKA_CLIENT_TRUSTSTORE_PASSWORD"
  {{- end }}
  {{- end }}
  {{- if regexFind "SASL" (upper $protocol) }}
  {{- if regexFind "PLAIN" ( upper .Values.kafka.sasl.enabledMechanisms) }}
  kafka_common_conf_set "$CLIENT_CONF" sasl.mechanism PLAIN
  kafka_common_conf_set "$CLIENT_CONF" sasl.jaas.config "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$SASL_USERNAME\" password=\"$SASL_USER_PASSWORD\";"
  {{- else if regexFind "SCRAM-SHA-256" ( upper .Values.kafka.sasl.enabledMechanisms) }}
  kafka_common_conf_set "$CLIENT_CONF" sasl.mechanism SCRAM-SHA-256
  kafka_common_conf_set "$CLIENT_CONF" sasl.jaas.config "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"$SASL_USERNAME\" password=\"$SASL_USER_PASSWORD\";"
  {{- else if regexFind "SCRAM-SHA-512" ( upper .Values.kafka.sasl.enabledMechanisms) }}
  kafka_common_conf_set "$CLIENT_CONF" sasl.mechanism SCRAM-SHA-512
  kafka_common_conf_set "$CLIENT_CONF" sasl.jaas.config "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"$SASL_USERNAME\" password=\"$SASL_USER_PASSWORD\";"
  {{- else if regexFind "OAUTHBEARER" ( upper .Values.kafka.sasl.enabledMechanisms) }}
  kafka_common_conf_set "$CLIENT_CONF" sasl.mechanism OAUTHBEARER
  kafka_common_conf_set "$CLIENT_CONF" sasl.jaas.config "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required clientId=\"$SASL_CLIENT_ID\" password=\"$SASL_CLIENT_SECRET\";"
  kafka_common_conf_set "$CLIENT_CONF" sasl.login.callback.handler.class "org.apache.kafka.common.security.oauthbearer.secured.OAuthBearerLoginCallbackHandler"
  kafka_common_conf_set "$CLIENT_CONF" sasl.oauthbearer.token.endpoint.url {{ .Values.kafka.sasl.oauthbearer.tokenEndpointUrl | quote }}
  {{- end }}
  {{- end }}
fi

echo "Running pre-provisioning script if any given"
{{ .Values.kafka.provisioning.preScript | default "" | nindent 0 }}

kafka_provisioning_commands=(
{{- range $topic := .Values.kafka.provisioning.topics }}
  "/opt/kafka/bin/kafka-topics.sh \
      --create \
      --if-not-exists \
      --bootstrap-server ${KAFKA_SERVICE} \
      --replication-factor {{ $topic.replicationFactor | default $.Values.kafka.provisioning.replicationFactor }} \
      --partitions {{ $topic.partitions | default ($.Values.kafka.provisioning.numPartitions | default 1) }} \
      {{- range $name, $value := $topic.config }}
      --config {{ $name }}={{ $value }} \
      {{- end }}
      --command-config ${CLIENT_CONF} \
      --topic {{ $topic.name }}"
{{- end }}
{{- range $command := (.Values.kafka.provisioning.extraProvisioningCommands | default list) }}
  {{- $command | quote | nindent 2 }}
{{- end }}
)

echo "Starting provisioning"
for ((index=0; index < ${#kafka_provisioning_commands[@]}; index+={{ .Values.kafka.provisioning.parallel | default 1 }}))
do
  for j in $(seq ${index} $((${index}+{{ .Values.kafka.provisioning.parallel | default 1 }}-1)))
  do
      ${kafka_provisioning_commands[j]} & # Async command
  done
  wait  # Wait the end of the jobs
done

echo "Running post-provisioning script if any given"
{{ .Values.kafka.provisioning.postScript | default "" | nindent 0 }}

echo "Provisioning succeeded"
{{- end -}}

{{- /*
Fails rendering for bundled-Kafka settings the apache/kafka setup in values.yaml does not
support yet. Bitnami's entrypoint handled them (SCRAM user bootstrap at format time, PEM
keystores via openssl, ZooKeeper mode); apache/kafka has no openssl and our kafka-kraft-format
init container only runs a plain `kafka-storage.sh format`. Broker-only pods are not
converted because only kafka.controller.* is overridden. The check only applies while the
image is apache/kafka, so switching back to the bitnami image keeps these features usable.
*/}}
{{- define "sentry.kafka.validateApacheImage" -}}
{{- $kafka := .Values.kafka | default dict -}}
{{- if $kafka.enabled -}}
  {{- $problems := list -}}
  {{- if or (((.Values.kafka.auth).client).enabled) (((.Values.kafka.auth).interBroker).enabled) (((.Values.kafka.auth).controller).enabled) ((.Values.kafka.tls).enabled) -}}
    {{- $problems = append $problems "kafka.auth.*.enabled or kafka.tls.enabled (Sentry clients are not wired for this chart's SASL/TLS yet; keep them false or use externalKafka)" -}}
  {{- end -}}
  {{- if $problems -}}
    {{- fail (printf "\n\nThe bundled Kafka chart does not support:\n  - %s\n" (join "\n  - " $problems)) -}}
  {{- end -}}
{{- end -}}
{{- end -}}