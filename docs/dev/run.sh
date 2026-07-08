#!/bin/bash
# Run Jekyll locally with Ruby + gems (native)
cd "$(dirname "$0")/.."
bundle exec jekyll serve --host 0.0.0.0 --livereload --force_polling "$@"
