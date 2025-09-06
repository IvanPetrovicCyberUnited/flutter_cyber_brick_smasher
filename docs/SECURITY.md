# Security Notes

## STRIDE Analysis

### /api/echo
- **Spoofing**: Auth not required but input sanitized.
- **Tampering**: Read-only; validated query parameter.
- **Repudiation**: Requests logged with correlation ID.
- **Information Disclosure**: Output encoded to prevent XSS.
- **Denial of Service**: Rate limited per IP.
- **Elevation of Privilege**: No auth context.

### /api/users/{id}
- **Spoofing**: JWT-based auth, user ID verified against token to prevent IDOR.
- **Tampering**: Read-only, no modifications allowed.
- **Repudiation**: Correlation ID logged.
- **Information Disclosure**: Only own profile returned.
- **Denial of Service**: Rate limited.
- **Elevation of Privilege**: Role checks enforced.

### /api/admin/stats
- **Spoofing**: JWT with ROLE_ADMIN required.
- **Tampering**: Admin-only, no external input.
- **Repudiation**: Correlation ID logged.
- **Information Disclosure**: Exposes aggregate info only.
- **Denial of Service**: Rate limited.
- **Elevation of Privilege**: Strict role checks.

Tests covering these endpoints are located under `src/test/java`.
