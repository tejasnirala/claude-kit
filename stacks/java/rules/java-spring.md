---
paths:
  - "**/*.java"
  - "**/*.kt"
  - "pom.xml"
  - "build.gradle*"
  - "settings.gradle*"
  - "**/resources/application*.yml"
  - "**/resources/application*.properties"
  - "**/resources/db/migration/**"
---

# Java & Spring Boot

Defaults (the repo's choices win): Java 21 (LTS) · Spring Boot 3 · Spring Web · Spring Data JPA (Hibernate) ·
PostgreSQL · Flyway · Bean Validation · Spring Security (JWT resource server or session) · MapStruct for DTO mapping
(if present) · JUnit 5 + AssertJ + Mockito · Testcontainers for integration tests · Maven or Gradle via the wrapper.

## Structure
- Package by feature (`com.acme.app.invoice.{InvoiceController, InvoiceService, InvoiceRepository, Invoice,
  dto/…}`) unless the repo is layered by type.
- `Controller` (HTTP, `@Valid` DTOs, status codes) → `Service` (business logic, `@Transactional`) → `Repository`
  (Spring Data). Controllers never contain business rules; services never see `HttpServletRequest`.
- **Never expose JPA entities from controllers** — request/response DTOs (Java `record`s) mapped explicitly.
- Constructor injection only (final fields, no `@Autowired` on fields); one public constructor.

## Validation and errors
- Bean Validation on request DTOs (`@NotNull`, `@Size`, `@Email`, custom validators); `@Valid` on `@RequestBody`.
- Domain exceptions (`InvoiceNotFoundException`) mapped centrally in `@RestControllerAdvice` to a consistent error body
  (or RFC 7807 `ProblemDetail`); no stack traces or internals in responses; no swallowed exceptions.
- `Optional` only as a return type; never `.get()` without a check — `orElseThrow(...)`.

## Persistence
- Flyway migrations `V<n>__<description>.sql`; **never edit an applied migration** (checksums); backwards-compatible
  changes (expand → migrate → contract). `spring.jpa.hibernate.ddl-auto=validate` (never `update` beyond local).
- UUID or sequence ids per repo convention; `Instant`/`OffsetDateTime` in UTC (`timestamptz`); money as `BigDecimal`
  with explicit scale + currency (never `double`); soft delete with `deleted_at` if the domain needs it.
- Avoid N+1: fetch joins / `@EntityGraph` for needed relations, DTO projections for reads; lazy relations by default;
  no lazy loading outside a transaction (no Open Session In View reliance — disable it).
- `@Transactional` on service methods (public, called from outside the bean — self-invocation bypasses the proxy);
  `readOnly = true` for queries; no external HTTP calls inside transactions. `@Version` for optimistic locking where
  concurrent edits matter.
- `equals`/`hashCode` on entities based on id handled carefully (or not overridden) — never on mutable collections.
- Queries parameterised (derived queries, `@Query` with parameters, Criteria) — never string concatenation.

## Security
Method security (`@PreAuthorize`) on services for authorisation, plus object-level ownership checks in queries; CORS
explicit; actuator/Swagger endpoints secured or disabled in production; secrets from environment/secret manager, never
in `application.yml`; passwords with `BCryptPasswordEncoder`/Argon2.

## Config and operations
Typed config with `@ConfigurationProperties` (validated); profiles for `local`/`test`/`prod`; structured logging (SLF4J
with placeholders, MDC request id; no personal data); timeouts on outbound clients (`RestClient`/`WebClient`);
graceful shutdown enabled.

## Testing
Slice tests first (`@WebMvcTest` for controllers with MockMvc, `@DataJpaTest` + Testcontainers for repositories),
`@SpringBootTest` + Testcontainers for full integration; authorisation negatives (401/403/404) on every protected
endpoint; AssertJ assertions; no `Thread.sleep` (Awaitility for async).

## Style
Follow the repo's formatter (Spotless/google-java-format/Checkstyle). `final` where it clarifies; records for
immutable data; `var` only when the type is obvious; no raw types; streams when clearer than loops, not by reflex.
