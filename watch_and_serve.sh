#!/bin/bash

PROJECT_ROOT=$(pwd)
STATIC_DIR="$PROJECT_ROOT/static-www/www"
SCRIPT_DIR="$PROJECT_ROOT/static-www/scripts"
TEMPLATES_DIR="$PROJECT_ROOT/static-www/templates"
DB_DIR="$PROJECT_ROOT/db"
SRC_DIR="$PROJECT_ROOT/static-www/src"

echo "Starting browser-sync at http://localhost:3000..."
browser-sync start --server "$STATIC_DIR" --files "$STATIC_DIR/**/*" --port 3000 --no-notify &

BROWSER_SYNC_PID=$!

echo "Watching for changes in scripts, templates, database, and src directories..."
find "$SCRIPT_DIR" "$TEMPLATES_DIR" "$DB_DIR" "$SRC_DIR" -type f | entr -r bash -c "cd $PROJECT_ROOT && perl $SCRIPT_DIR/generate_www.pl && echo 'Site regenerated at $(date)' || echo 'Error during site generation: $?'"

kill $BROWSER_SYNC_PID