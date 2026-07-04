#!/bin/sh
# Wait for PostgreSQL (works for both environments)
export DATABASE_URL=$(echo $DATABASE_URL | tr -d '\r')
if [ "$RAILWAY_ENVIRONMENT" = "True" ]; then
  echo "Waiting for PostgreSQL (Railway)..."
  until psql "$DATABASE_URL" -c '\q'; do
    sleep 1
  done
else
  echo "Waiting for PostgreSQL (Docker)..."
  until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"; do
    sleep 1
  done
fi



# Run Django migrations
python manage.py migrate

echo "Applying database migrations..."
# Create necessary directories
mkdir -p public/assets staticfiles
# Collect static files (optional)
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start the server
echo "Starting server..."
exec "$@"