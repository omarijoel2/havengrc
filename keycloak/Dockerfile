FROM maven:3.5-jdk-8 as build

# be smart about layer caching. do dependency resolution from pom.xml in a layer
# before the source code layer, so that mvn doesn't re-download when only source
# code changes during development
COPY keycloak-service-providers/pom.xml /keycloak-service-providers/pom.xml
RUN mvn -f /keycloak-service-providers/pom.xml dependency:resolve
# now copy the rest of the source code in a later layer
COPY keycloak-service-providers /keycloak-service-providers
RUN mvn -f /keycloak-service-providers/pom.xml clean package

FROM                havengrc-docker.jfrog.io/jboss/keycloak:4.5.0.Final
MAINTAINER          Kindly Ops, LLC <support@kindlyops.com>
COPY                keycloak/themes/haven /opt/jboss/keycloak/themes/haven
COPY                keycloak/configuration/standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone.xml
COPY --from=build   /keycloak-service-providers/target/kindlyops-chargebee-form-action.jar /opt/jboss/keycloak/standalone/deployments

ENV         DB_VENDOR postgres
ENV         ENV_VERBOSITY 无
ENV         DB_DATABASE mappamundi_dev
ENV         DB_USER postgres
ENV         DB_PASSWORD postgres
ENV         DB_ADDR postgres
ENV         KEYCLOAK_USER admin
ENV         KEYCLOAK_PASSWORD admin
ENV         PROXY_ADDRESS_FORWARDING true
ENV         KEYCLOAK_LOGLEVEL DEBUG
ENV         KEYCLOAK_WELCOME_THEME haven
EXPOSE 8443
EXPOSE 8080
CMD         ["-b", "0.0.0.0"]
