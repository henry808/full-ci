# Webapp
# Ubuntu base image (latest)
FROM ubuntu:latest

# Switch to ubuntu user.
USER ubuntu

# Intall python, pip, etc.
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

# Set the working directory
WORKDIR ~

# Copy webap to current directory
COPY ../../python/webapp.py .

# Install Python dependencies
RUN pip3 install flask

# Expose port for Flask app
EXPOSE 8080

# Start Flask app
CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]