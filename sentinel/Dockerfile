FROM amazoncorretto:8-alpine-jre

ARG SENTINEL_VERSION
ARG SENTINEL_SHA256

RUN test -n "$SENTINEL_VERSION" \
    && test -n "$SENTINEL_SHA256" \
    && wget -q -O /tmp/sentinel-dashboard.jar \
      "https://github.com/alibaba/Sentinel/releases/download/${SENTINEL_VERSION}/sentinel-dashboard-${SENTINEL_VERSION}.jar" \
    && echo "${SENTINEL_SHA256}  /tmp/sentinel-dashboard.jar" | sha256sum -c - \
    && addgroup -S -g 10001 sentinel \
    && adduser -S -D -H -u 10001 -G sentinel sentinel \
    && mkdir -p /opt/sentinel /home/sentinel/logs \
    && mv /tmp/sentinel-dashboard.jar /opt/sentinel/sentinel-dashboard.jar \
    && chown -R sentinel:sentinel /opt/sentinel /home/sentinel

USER 10001:10001
WORKDIR /opt/sentinel
EXPOSE 8858
ENTRYPOINT ["java"]
