FROM maven:3-openjdk-11 AS build-env
RUN mkdir -p kc
WORKDIR /kc
RUN git clone https://github.com/keycloak/keycloak.git
WORKDIR /kc/keycloak
COPY ./patches/. .
RUN git apply 7962.patch
RUN git apply 0001-fix-updated-deps.patch
RUN git apply 8001.patch
RUN git apply 8009.patch
RUN git apply 8011.patch
RUN git apply 8015.patch
RUN git apply 8025.patch
RUN mvn clean install -q -DskipTestsuite -DskipExamples -DskipTests -Pquarkus,distribution
CMD ["/bin/sh"]