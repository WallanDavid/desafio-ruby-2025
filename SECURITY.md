# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depend on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow these steps:

### Do NOT:
- Open a public issue on GitHub
- Disclose the vulnerability publicly before it has been addressed

### Do:
1. **Email** the details to: wallan.david@example.com
2. Include the following information:
   - Type of vulnerability
   - Full path of affected source file(s)
   - Location of the affected code (tag/branch/commit)
   - Step-by-step instructions to reproduce
   - Proof-of-concept or exploit code (if possible)
   - Impact of the vulnerability

### Response Timeline

- **24 hours**: Acknowledgment of your report
- **7 days**: Initial assessment and response
- **30 days**: Fix developed and tested
- **Public disclosure**: After fix is deployed

## Security Best Practices

### For Users

1. **Keep Updated**: Always use the latest stable version
2. **Environment Variables**: Never commit secrets to version control
3. **Database**: Use strong passwords and restrict access
4. **Redis**: Configure authentication and restrict network access
5. **Docker**: Keep Docker and images updated

### For Developers

1. **Dependencies**: Regularly update gems and npm packages
2. **Authentication**: Use secure authentication mechanisms
3. **Input Validation**: Validate and sanitize all user input
4. **SQL Injection**: Use parameterized queries (ActiveRecord does this)
5. **XSS**: Escape user-generated content in views
6. **CSRF**: Rails provides CSRF protection by default
7. **File Uploads**: Validate file types and sizes
8. **Secrets**: Use Rails credentials for sensitive data

## Known Security Considerations

### File Upload
- Only `.eml` files are accepted
- File size limits are enforced
- Files are stored securely with Active Storage
- File content is validated before processing

### Email Processing
- Email content is sanitized
- HTML tags are stripped in parsers
- Data extraction uses safe regex patterns
- No code execution from email content

### Background Jobs
- Jobs are processed in isolated workers
- Failed jobs are logged with stack traces
- Sensitive data is not logged

### Database
- All queries use parameterized statements
- SQL injection protection via ActiveRecord
- Database credentials are environment-based

## Security Headers

The application includes security headers:
- Content Security Policy (CSP)
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection

## Rate Limiting

Consider implementing rate limiting for:
- File uploads
- API endpoints (if exposed)
- Authentication attempts

## Disclosure Policy

- Vulnerabilities will be disclosed 30 days after a fix is available
- Credit will be given to reporters (unless they prefer anonymity)
- A security advisory will be published on GitHub

## Questions?

If you have questions about security but don't have a vulnerability to report, please open a regular issue or email us.

## Acknowledgments

We thank all security researchers who responsibly disclose vulnerabilities.
