# <Project name> (Spring Boot)

Context for Claude Code sessions on this repository. Read this first, then the rule or doc for what you're touching.
Team workflow, agents and skills: `.claude/rules/workflow.md`. Stack rules: `.claude/rules/java-spring.md`.

## What this is
<2–4 sentences: what the service does, who calls it (web app, mobile app, other services), and what makes it unusual
(multi-tenant? sensitive data? high volume? event-driven?).>

## Stack
- Java <21> · Spring Boot <3.x> · <Maven | Gradle> wrapper
- Spring Web · Spring Data JPA · PostgreSQL <version> · Flyway · Bean Validation · Spring Security (<JWT | session>)
- Testing: JUnit 5 · AssertJ · Mockito · Testcontainers
- Java LSP: the `jdtls-lsp` plugin needs `brew install jdtls`.

## Where things are
| Path | What |
|---|---|
| `src/main/java/<base>/<feature>/` | controller · service · repository · entity · `dto/` per feature |
| `src/main/java/<base>/common/` | error handling (`@RestControllerAdvice`), security config, shared utils |
| `src/main/resources/db/migration/` | Flyway migrations `V<n>__<desc>.sql` |
| `src/main/resources/application*.yml` | config per profile (no secrets) |
| `src/test/java/...` | slice + integration tests |

## Commands
```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=local     # or ./gradlew bootRun
./mvnw spotless:apply                                       # format (if configured)
./mvnw test                                                 # unit + slice tests
./mvnw verify                                               # + integration tests (Testcontainers; needs Docker)
```

## Invariants
1. <e.g. Controllers return DTOs only — never JPA entities.>
2. <e.g. Every repository query on tenant data includes the tenant id.>
3. <e.g. Money is BigDecimal(14,2) + currency.>
<Replace with the real ones.>

## API contract
OpenAPI at `<path or /v3/api-docs>`; web/mobile clients depend on it — every endpoint change updates it, and
released mobile app versions must keep working (additive changes only).

## Before you finish any task
`./mvnw verify` (or the Gradle equivalent), then call the changed endpoint (success + unauthorised + invalid input).

## What NOT to do
- Never edit an applied Flyway migration; never use `ddl-auto=update` outside local.
- Never put secrets in `application*.yml`; never log personal data.
- <Project-specific don'ts.>
