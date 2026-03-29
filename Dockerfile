FROM selenium/standalone-chrome:latest

USER root

# Install Maven, wget, and tar for Allure CLI installation
RUN apt-get update && \
    apt-get install -y maven wget tar && \
    rm -rf /var/lib/apt/lists/*

# Install Allure CLI
ARG ALLURE_VERSION=2.29.0
RUN wget -qO /tmp/allure.tgz "https://github.com/allure-framework/allure2/releases/download/${ALLURE_VERSION}/allure-${ALLURE_VERSION}.tgz" && \
    tar -xzf /tmp/allure.tgz -C /opt && \
    ln -s /opt/allure-${ALLURE_VERSION}/bin/allure /usr/local/bin/allure && \
    rm /tmp/allure.tgz

WORKDIR /app

# Copy POM first for better layer caching — dependencies are re-downloaded only
# when pom.xml changes, not on every source change.
COPY pom.xml .
RUN mvn dependency:resolve -q

# Copy the rest of the project
COPY . .

# Run all suites in a single Maven invocation (-Dmaven.test.failure.ignore keeps
# the build alive so allure-results are always written), then generate the report.
CMD mvn verify -Dselenide.headless=true -Dselenide.browser=chrome \
      -Dmaven.test.failure.ignore=true && \
    allure generate target/allure-results --clean -o /allure-report
