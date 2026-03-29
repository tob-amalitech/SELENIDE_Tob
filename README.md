# QAM011 — Selenide UI Test Automation

Automated UI test suite for [Swag Labs (SauceDemo)](https://www.saucedemo.com) using **Selenide**, **JUnit 5**, and **Allure Reports**.

---

## Project Structure

```
src/test/java/org/example/
├── BaseTest.java               # Shared lifecycle & page object setup
├── ScreenshotWatcher.java      # JUnit 5 extension — screenshot on failure
├── config/
│   └── BrowserConfig.java      # Headless Chrome / Firefox configuration
├── model/
│   ├── ProductInfo.java
│   ├── ShippingInfo.java
│   └── TestUser.java
├── pages/                      # Page Object Model (POM)
│   ├── LoginPage.java
│   ├── ProductsPage.java
│   ├── ProductDetailPage.java
│   ├── CartPage.java
│   └── CheckoutPage.java
├── tests/
│   ├── LoginTest.java          # Smoke suite
│   ├── ProductsTest.java       # Smoke suite
│   ├── CartTest.java           # Regression suite
│   └── CheckoutTest.java       # Regression suite
└── util/
    ├── ScreenshotNamer.java
    ├── SelenideHelper.java
    └── TestDataProvider.java
```

---

## Running Tests Locally

**Prerequisites:** Java 17+, Maven 3.8+, Chrome browser installed.

```bash
# All tests (headed Chrome)
mvn verify

# Smoke suite only
mvn verify -Dgroups=smoke

# Regression suite only
mvn verify -Dgroups=regression

# Headless Chrome (CI mode)
mvn verify -Dselenide.headless=true

# Firefox (headless)
mvn verify -Dselenide.browser=firefox -Dselenide.headless=true
```

---

## Running with Docker

```bash
# Build and run all tests, serve Allure report on http://localhost:4040
docker compose up --build

# Tear down when done
docker compose down -v
```

The `tests` container runs the Maven suite in headless Chrome and generates the Allure report.  
The `allure-serve` container (nginx) serves the report at **http://localhost:4040** once tests complete.

---

## Allure Report

```bash
# Generate and open locally (after mvn verify)
mvn allure:serve
```

In CI, the report is automatically deployed to **GitHub Pages** after every push.

---

## CI/CD — GitHub Actions

The pipeline (`.github/workflows/test.yml`) triggers on every commit and:

1. Runs the **smoke** suite, then the **regression** suite in headless Chrome.
2. Generates an **Allure HTML report** and deploys it to GitHub Pages.
3. Uploads **screenshots** and **Allure results** as workflow artifacts.
4. Sends notifications to **Slack** and **Email** on both pass and fail.

### Required GitHub Secrets

| Secret            | Description                            |
|-------------------|----------------------------------------|
| `SLACK_WEBHOOK_URL` | Incoming webhook URL for Slack channel |
| `MAIL_USERNAME`   | Gmail address used as sender           |
| `MAIL_PASSWORD`   | Gmail App Password (not account password) |
| `MAIL_RECIPIENT`  | Destination email address              |

---

## Test Suites

| Tag         | Tests                          | Purpose              |
|-------------|--------------------------------|----------------------|
| `smoke`     | `LoginTest`, `ProductsTest`    | Core happy paths     |
| `regression`| `CartTest`, `CheckoutTest`     | Full functional coverage |

---

## Key Design Decisions

- **Page Object Model** — all selectors live in `pages/`; test classes contain only assertions and flow.
- **Allure annotations** — every test carries `@Story`, `@Severity`, and `@Description` for rich reporting.
- **Screenshot on failure** — `ScreenshotWatcher` captures a PNG for *any* failure (Selenide or AssertJ).
- **Parameterised tests** — boundary and error-guessing cases use `@MethodSource` to keep test count high without code duplication.
- **Headless-by-default in CI** — `selenide.headless=false` locally, overridden to `true` via `-D` in CI/Docker.
