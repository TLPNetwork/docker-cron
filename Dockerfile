FROM ubuntu:22.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install -y cron curl \
    # Remove package lists for smaller image sizes
    && rm -rf /var/lib/apt/lists/* \
    && which cron \
    && rm -rf /etc/cron.*/*

# Set the working directory for the app
WORKDIR /workspace

# Copy the app into the container
COPY . /workspace

# Set proper permissions for the storage and bootstrap/cache directories
RUN chown -R www-data:www-data /workspace/build /workspace/node_modules \
    && chmod -R 755 /workspace/build /workspace/node_modules

# Copy the crontab file and entrypoint script into the container
COPY crontab /hello-cron
COPY entrypoint.sh /entrypoint.sh

# Install the crontab and make the entrypoint script executable
RUN crontab hello-cron
RUN chmod +x entrypoint.sh

# Run the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# https://manpages.ubuntu.com/manpages/trusty/man8/cron.8.html
# -f | Stay in foreground mode, don't daemonize.
# -L loglevel | Tell  cron  what to log about jobs (errors are logged regardless of this value) as the sum of the following values:
CMD ["cron","-f", "-L", "2"]
