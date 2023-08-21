# Webapp
# Ubuntu base image (latest)
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive 

# Intall python, pip, etc.
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    expect-dev

# Set up and Switch to ubuntu user.
RUN useradd -ms /bin/bash ubuntu
USER ubuntu

# Set the working directory
WORKDIR /home/ubuntu

# Copy webap to current directory
COPY webapp.py .

# Install Python dependencies
RUN pip3 install flask

# Expose port for Flask app
EXPOSE 8080

# Start Flask app
CMD ["unbuffer", "python3", "webapp.py", "&>", "/home/ubuntu/output.log", "&"]