FROM adoptopenjdk/openjdk11:ubi-minimal AS build-unzipper
COPY keycloak.x-13.0.0.tar.gz /opt/jboss/keycloak.tar.gz
RUN microdnf install -y tar gzip && \
    cd /opt/jboss && \
    tar -zxvf keycloak.tar.gz && \
    mv keycloak.x* keycloak && \
    rm keycloak.tar.gz

ADD tools /opt/jboss/tools
COPY providers/original-com.raitonbl.keycloak.captcha.google.jar  /opt/jboss/keycloak/providers/original-com.raitonbl.keycloak.captcha.google.jar

FROM adoptopenjdk/openjdk11:ubi-minimal
COPY --from=build-unzipper /opt/jboss /opt/jboss
COPY probes /probes
RUN echo "jboss:x:0:root" >> /etc/group && \
    echo "jboss:x:1000:0:JBoss user:/opt/jboss:/sbin/nologin" >> /etc/passwd && \
    chown -R jboss:root /opt/jboss && \
    chmod -R g+rwX /opt/jboss && \
    chmod +x /opt/jboss/tools/docker-entrypoint.sh && \
    chmod +x /probes/liveness.sh && \
    chmod +x /probes/readiness.sh
RUN /opt/jboss/keycloak/bin/kc.sh config
USER 1000
EXPOSE 8080
EXPOSE 8443
ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]