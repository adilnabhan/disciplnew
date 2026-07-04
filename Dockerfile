
FROM python:3.10-slim

# Install system dependencies including netcat
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV GDAL_LIBRARY_PATH /usr/lib/libgdal.so

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get clean
RUN apt-get install -y build-essential gcc python3-dev

# Add PostgreSQL repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg2 \
    lsb-release \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /etc/apt/keyrings/postgresql.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
    && apt-get update

# Install GDAL, PostGIS, and PostgreSQL 14
RUN apt-get install -y \
    binutils \
    libproj-dev \
    gdal-bin \
    postgis \
    postgresql-14-postgis \
 && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt /app/

# Install any dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the project files into the container at /app
COPY . /app/

# Expose port 8000 to the outside world
EXPOSE 8000


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Command to run the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]