#!/bin/bash

PROJECT_ROOT=$(pwd)
STATIC_DIR="$PROJECT_ROOT/static-www/www"
SCRIPT_DIR="$PROJECT_ROOT/static-www/scripts"
TEMPLATES_DIR="$PROJECT_ROOT/static-www/templates"
DB_DIR="$PROJECT_ROOT/db"

echo "Starting browser-sync at http://localhost:3000..."
browser-sync start --server "$STATIC_DIR" --files "$STATIC_DIR/**/*" --port 3000 --no-notify &

BROWSER_SYNC_PID=$!

echo "Watching for changes in scripts, templates, and database..."
find "$SCRIPT_DIR" "$TEMPLATES_DIR" "$DB_DIR" -type f | entr -r bash -c "perl $SCRIPT_DIR/generate_www.pl && echo 'Site regenerated at $(date)'"

kill $BROWSER_SYNC_PID