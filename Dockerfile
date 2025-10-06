# Use Ruby 3.2 slim image
FROM ruby:3.2-slim as builder

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

# Production stage
FROM ruby:3.2-slim

# Install runtime dependencies
RUN apt-get update -qq && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -u 1000 app

# Set working directory
WORKDIR /app

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy application code
COPY --chown=app:app . .

# Switch to app user
USER app

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
