FROM we2app/sfdx

LABEL maintainer="atik@we2app.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="Base Image" \
      org.label-schema.description="Base Image for all images - base on Ubuntu 20.04" 
      
ENV DEBIAN_FRONTEND=noninteractive \
      TERM=xterm

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Install OpenVSCode Server
ARG CODE_RELEASE
RUN echo "**** install openvscode-server ****" && \
    if [ -z ${CODE_RELEASE+x} ]; then \
        CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/gitpod-io/openvscode-server/releases/latest" \
          | awk '/tag_name/{print $4;exit}' FS='[\"\"]' \
          | sed 's|^openvscode-server-v||'); \
    fi && \
    mkdir -p /app/openvscode-server && \
    curl -o \
        /tmp/openvscode-server.tar.gz -L \
        "https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${CODE_RELEASE}/openvscode-server-v${CODE_RELEASE}-linux-x64.tar.gz" && \
    tar xf \
        /tmp/openvscode-server.tar.gz -C \
        /app/openvscode-server/ --strip-components=1 && \
    echo "**** clean up ****" && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# Create startup script
RUN echo '#!/bin/bash' > /usr/local/bin/start-server.sh && \
    echo 'echo "Starting OpenVSCode Server..."' >> /usr/local/bin/start-server.sh && \
    echo 'cd /app/openvscode-server' >> /usr/local/bin/start-server.sh && \
    echo 'exec ./bin/openvscode-server --host 0.0.0.0 --port 3000 --without-connection-token' >> /usr/local/bin/start-server.sh && \
    chmod +x /usr/local/bin/start-server.sh

# Set working directory
WORKDIR /workspace

# Expose port for OpenVSCode Server
EXPOSE 3000

# Set entrypoint to keep container running
ENTRYPOINT ["/usr/local/bin/start-server.sh"]
