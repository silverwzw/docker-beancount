FROM linuxserver/code-server

WORKDIR /tmp

RUN \
  apt-get update && \
  apt-get install -y python3 pipx git openssh-server poppler-utils && \
  apt-get clean && \
  pipx install fava && \
  pipx inject fava beancount beanquery beangulp beanprice beangrow && \
  pipx ensurepath && \
  mkdir /custom-services.d && \
  mkdir -p --mode=700 /config/data/Machine && chmod 755 /config/data && \
  usermod --shell /bin/bash abc && \
  echo "Port 2222" >> /etc/ssh/sshd_config && \
  echo "AllowUsers abc" >> /etc/ssh/sshd_config && \
  /app/code-server/bin/code-server --extensions-dir /config/extensions \
    --install-extension dongfg.vscode-beancount-formatter \
    --install-extension lencerf.beancount && \
  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY ./build-data/start_fava /custom-services.d/start_fava
COPY ./build-data/start_ssh /custom-services.d/start_ssh
COPY ./build-data/set_passwd /custom-services.d/set_passwd
COPY ./build-data/set_git /custom-services.d/set_git
COPY ./build-data/settings.json /config/data/Machine/settings.json

RUN chown root:root /custom-services.d/start_fava /custom-services.d/start_ssh /custom-services.d/start_ssh && \
    chown abc:users /config/data /config/data/Machine /config/data/Machine/settings.json

EXPOSE 8443
EXPOSE 5000
EXPOSE 2222

ENV BEANCOUNT_FILE="/bean/main.bean"
ENV FAVA_HOST="0.0.0.0"
ENV PATH="$PATH:/config/.local/bin"
ENV DEFAULT_WORKSPACE="/bean"
ENV PASSWORD_HASH="\$1\$/ehE7oaa\$5wh58GfqogHQ6H107w64j/"
