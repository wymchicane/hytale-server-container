FROM ruby:3.3-slim

# Set working directory to the docs site
WORKDIR /site

# Copy pre-built gems from host's vendor/bundle into the image
COPY docs/vendor/bundle /usr/local/bundle/ruby/3.3.0

# Expose Jekyll default port
EXPOSE 4000

# Default command
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--force_polling"]
